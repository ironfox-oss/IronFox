import re, sys
from pathlib import Path

# Regexes
PROVIDER_START = re.compile(r'SafeBrowsingProvider\.withName\(\s*"([^"]+)"\s*\)')
CHAIN_CALL = re.compile(r'\.([a-zA-Z0-9_]+)\(\s*([^)]*)\)')
PREF_CONSTR = re.compile(r'new\s+Pref<[^>]*>\(\s*"([^"]+)"\s*,\s*([^;]+?)\)\s*;')
STRING_CONST = re.compile(r'private static final String\s+([A-Z0-9_]+)\s*=\s*"([^"]*)"\s*;')
GENERIC_CONST = re.compile(r'private static final (?:String|int)\s+([A-Z0-9_]+)\s*=\s*([^;]+);')
LISTS_TO_PREF = re.compile(r'listsToPref\s*\(\s*([^\)]*)\)')
CAT_TO_PREF = re.compile(r'catToPref\s*\(\s*([^\)]*)\)')
CAT_TO_AT = re.compile(r'catToAtPref\s*\(\s*([^\)]*)\)')
CAT_TO_CM = re.compile(r'catToCmListPref\s*\(\s*([^\)]*)\)')
CAT_TO_FP = re.compile(r'catToFpListPref\s*\(\s*([^\)]*)\)')

# BuildConfig ternary pattern
TERNARY = re.compile(r'BuildConfig\.([A-Z0-9_]+)\s*\?\s*(".*?"|[A-Z0-9_.]+)\s*:\s*(".*?"|[A-Z0-9_.]+)')

# Evaluate these build flags per request
BUILDFLAGS = {"MOZILLA_OFFICIAL": True, "DEBUG_BUILD": False}

def map_method_to_key(method):
    return {
        "version": "pver",
        "lists": "lists",
        "updateUrl": "updateURL",
        "getHashUrl": "gethashURL",
        "reportUrl": "reportURL",
        "reportPhishingMistakeUrl": "reportPhishingMistakeURL",
        "reportMalwareMistakeUrl": "reportMalwareMistakeURL",
        "advisoryUrl": "advisoryURL",
        "advisoryName": "advisoryName",
        "dataSharingUrl": "dataSharingURL",
        "dataSharingEnabled": "dataSharing.enabled",
    }.get(method, method)

def quote(val):
    esc = val.replace('\\','\\\\').replace('"','\\"')
    return f'"{esc}"'

def eval_ternary(arg, consts):
    def repl(m):
        flag = m.group(1)
        left = m.group(2)
        right = m.group(3)
        chosen = left if BUILDFLAGS.get(flag, False) else right
        lit = re.match(r'^"(.*)"$', chosen)
        if lit:
            return '"' + lit.group(1) + '"'
        if '.' in chosen:
            chosen_token = chosen.split('.')[-1]
        else:
            chosen_token = chosen
        if chosen_token in consts:
            return '"' + consts[chosen_token] + '"'
        return chosen
    return TERNARY.sub(repl, arg)

# Parse integer bitmask expressions: supports literals, shifts (<<), OR (|), parentheses,
# and references to other constants. Returns dict name->int for resolved entries.
BITMASK_RE = re.compile(r'(?m)(?:public|private|protected)?\s*static\s+final\s+int\s+([A-Z0-9_]+)\s*=\s*([^;]+);')

def extract_block(src, classname):
    m = re.search(r'\bclass\s+' + re.escape(classname) + r'\b', src)
    if not m:
        return None
    i = src.find('{', m.end())
    if i < 0:
        return None
    depth = 0
    for j in range(i, len(src)):
        if src[j] == '{':
            depth += 1
        elif src[j] == '}':
            depth -= 1
            if depth == 0:
                return src[i+1:j]
    return None

def parse_bitmasks(src_text):
    block = extract_block(src_text, "AntiTracking")
    scan_text = block if block is not None else src_text

    raw = {}
    for m in re.finditer(r'(?m)(?:public|private|protected)?\s*static\s+final\s+int\s+([A-Z0-9_]+)\s*=\s*([^;]+);', scan_text):
        raw[m.group(1)] = m.group(2).strip()

    def eval_expr(expr, known):
        expr = re.sub(r'\b[A-Z0-9_]+\.[A-Z0-9_]+\b', lambda mo: mo.group(0).split('.')[-1], expr)
        expr2 = re.sub(r'\b([A-Z0-9_]+)\b', lambda mo: str(known.get(mo.group(1), mo.group(1))), expr)
        if not re.fullmatch(r'[\d\s\|\&\^\(\)\<\>xXa-fA-F\+\-]+', expr2):
            raise ValueError("Unsafe or unsupported int expr: " + expr2)
        return int(eval(expr2, {}, {}))

    bitmasks = {}
    unresolved = dict(raw)
    progress = True
    while progress and unresolved:
        progress = False
        for k, v in list(unresolved.items()):
            try:
                val = eval_expr(v, bitmasks)
                bitmasks[k] = val
                del unresolved[k]
                progress = True
            except Exception:
                continue
    return {k: v for k, v in bitmasks.items() if isinstance(v, int)}

# Flatten listsToPref args into CSV using string constants when present.
def lists_to_pref_resolve(arg_expr, consts):
    items = []
    for lit, const in re.findall(r'"([^"]*)"|([A-Z0-9_]+)', arg_expr):
        if lit:
            items.append(lit)
        elif const and const in consts:
            items.append(consts[const])
    return ",".join(items)

# Emulate ContentBlocking cat helpers using parsed bitmasks and string consts.
def emulate_catToAtPref(cat_value, consts, bitmasks):
    order = ['TEST', 'AD', 'ANALYTIC', 'SOCIAL', 'CONTENT']
    parts = []
    for name in order:
        if bitmasks.get(name, 0) and (cat_value & bitmasks[name]):
            v = consts.get(name)
            if v:
                parts.append(v)
    return ",".join(parts)

def emulate_catToCmListPref(cat_value, consts, bitmasks):
    if bitmasks.get('CRYPTOMINING', 0) and (cat_value & bitmasks['CRYPTOMINING']):
        return consts.get('CRYPTOMINING', "")
    return ""

def emulate_catToFpListPref(cat_value, consts, bitmasks):
    if bitmasks.get('FINGERPRINTING', 0) and (cat_value & bitmasks['FINGERPRINTING']):
        return consts.get('FINGERPRINTING', "")
    return ""

def strip_qualifier(tok):
    tok = tok.strip()
    return tok.split('.')[-1] if '.' in tok else tok

def resolve_ContentBlocking_cat_calls(raw_arg, consts, bitmasks):
    m = re.search(r'ContentBlocking\.catToAtPref\s*\(\s*([^)]+)\)', raw_arg)
    if m:
        inner = strip_qualifier(m.group(1))
        if inner == 'NONE':
            return ""
        if inner in bitmasks:
            return emulate_catToAtPref(bitmasks[inner], consts, bitmasks)
        return ""
    m_cm = re.search(r'ContentBlocking\.catToCmListPref\s*\(\s*([^)]+)\)', raw_arg)
    if m_cm:
        inner = strip_qualifier(m_cm.group(1))
        if inner == 'NONE':
            return ""
        if inner in bitmasks:
            return emulate_catToCmListPref(bitmasks[inner], consts, bitmasks)
        return ""
    m_fp = re.search(r'ContentBlocking\.catToFpListPref\s*\(\s*([^)]+)\)', raw_arg)
    if m_fp:
        inner = strip_qualifier(m_fp.group(1))
        if inner == 'NONE':
            return ""
        if inner in bitmasks:
            return emulate_catToFpListPref(bitmasks[inner], consts, bitmasks)
        return ""
    m = re.search(r'ContentBlocking\.catToPref\s*\(\s*([^)]+)\)', raw_arg)
    if m:
        parts = [p.strip() for p in m.group(1).split(',')]
        last = parts[-1]
        lit = re.match(r'^"([^"]*)"$', last)
        if lit:
            return lit.group(1)
        last_tok = strip_qualifier(last)
        if last_tok in consts:
            return consts[last_tok]
        return ""
    return None

def extract_value(arg, consts, bitmasks):
    arg = arg.strip()
    arg = eval_ternary(arg, consts)
    m = re.match(r'^"([^"]*)"$', arg)
    if m:
        return m.group(1)
    m = LISTS_TO_PREF.search(arg)
    if m:
        return lists_to_pref_resolve(m.group(1), consts)
    for pat in (CAT_TO_PREF, CAT_TO_AT, CAT_TO_CM, CAT_TO_FP):
        m = pat.search(arg)
        if m:
            parts = [p.strip() for p in m.group(1).split(',')]
            last = parts[-1]
            lit = re.match(r'^"([^"]*)"$', last)
            if lit:
                return lit.group(1)
            last_tok = strip_qualifier(last)
            if last_tok in consts:
                return consts[last_tok]
            if last_tok in bitmasks:
                if pat is CAT_TO_AT:
                    return emulate_catToAtPref(bitmasks[last_tok], consts, bitmasks)
                if pat is CAT_TO_CM:
                    return emulate_catToCmListPref(bitmasks[last_tok], consts, bitmasks)
                if pat is CAT_TO_FP:
                    return emulate_catToFpListPref(bitmasks[last_tok], consts, bitmasks)
            return ""
    res = resolve_ContentBlocking_cat_calls(arg, consts, bitmasks)
    if res is not None:
        return res
    tok = strip_qualifier(arg)
    if tok in consts:
        return consts[tok]
    if arg in ("true","false"):
        return arg
    quoted = re.findall(r'"([^"]*)"', arg)
    if quoted:
        return ",".join(quoted)
    return arg

def format_pref_value(val):
    if val in ("true","false"):
        return val
    return quote(val)

def convert(src_text):
    consts = {}
    for m in STRING_CONST.finditer(src_text):
        consts[m.group(1)] = m.group(2)
    for m in GENERIC_CONST.finditer(src_text):
        name, rhs = m.group(1), m.group(2).strip()
        ms = re.match(r'^"([^"]*)"$', rhs)
        if ms:
            consts[name] = ms.group(1)
    bitmasks = parse_bitmasks(src_text)
    out_lines = []
    for m in PROVIDER_START.finditer(src_text):
        name = m.group(1)
        pos = m.end()
        build_idx = src_text.find('.build()', pos)
        if build_idx < 0:
            continue
        chain = src_text[pos:build_idx]
        for c in CHAIN_CALL.finditer(chain):
            method = c.group(1)
            raw_arg = c.group(2).strip().rstrip(',')
            value = extract_value(raw_arg, consts, bitmasks)
            key = map_method_to_key(method)
            pref_name = f'browser.safebrowsing.provider.{name}.{key}'
            out_lines.append(f'pref("{pref_name}", {format_pref_value(value)});')
        out_lines.append('')
    for m in PREF_CONSTR.finditer(src_text):
        pref_name = m.group(1)
        raw_arg = m.group(2).strip()
        raw_arg = re.sub(r'\s+', ' ', raw_arg)
        # try ContentBlocking.catToCmListPref(...)
        m_cm = re.search(r'ContentBlocking\.catToCmListPref\s*\(\s*([^\)]+)\)', raw_arg)
        if m_cm:
            inner = strip_qualifier(m_cm.group(1))
            if inner in bitmasks:
                value = emulate_catToCmListPref(bitmasks[inner], consts, bitmasks)
            else:
                value = ""
            out_lines.append(f'pref("{pref_name}", {format_pref_value(value)});')
            continue
        # try ContentBlocking.catToFpListPref(...)
        m_fp = re.search(r'ContentBlocking\.catToFpListPref\s*\(\s*([^\)]+)\)', raw_arg)
        if m_fp:
            inner = strip_qualifier(m_fp.group(1))
            if inner in bitmasks:
                value = emulate_catToFpListPref(bitmasks[inner], consts, bitmasks)
            else:
                value = ""
            out_lines.append(f'pref("{pref_name}", {format_pref_value(value)});')
            continue
        mlist = LISTS_TO_PREF.search(raw_arg)
        if mlist:
            value = lists_to_pref_resolve(mlist.group(1), consts)
            out_lines.append(f'pref("{pref_name}", {format_pref_value(value)});')
            continue
        res = resolve_ContentBlocking_cat_calls(raw_arg, consts, bitmasks)
        if res is not None:
            out_lines.append(f'pref("{pref_name}", {format_pref_value(res)});')
            continue
        value = extract_value(raw_arg, consts, bitmasks)
        out_lines.append(f'pref("{pref_name}", {format_pref_value(value)});')
    return "\n".join(out_lines)

def debug_parse(src_text):
    consts = {m.group(1): m.group(2) for m in STRING_CONST.finditer(src_text)}
    gen = {}
    for m in GENERIC_CONST.finditer(src_text):
        name, rhs = m.group(1), m.group(2).strip()
        ms = re.match(r'^"([^"]*)"$', rhs)
        if ms: gen[name] = ms.group(1)
    bitmasks = parse_bitmasks(src_text)
    print("STRING consts keys:", sorted(consts.keys()))
    print("GENERIC consts keys:", sorted(gen.keys()))
    print("Resolved bitmasks:", bitmasks)
    return consts, gen, bitmasks

def main():
    if len(sys.argv) < 3:
        print("Usage: script <ContentBlocking.java> <contentblocking-prefs.js>")
        sys.exit(1)
    src = Path(sys.argv[1]).read_text(encoding='utf-8')
    debug_parse(src)
    result = convert(src)
    Path(sys.argv[2]).write_text(result, encoding='utf-8')
    print("Wrote output")

if __name__ == '__main__':
    main()
