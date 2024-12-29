#!/bin/bash

libclang=""
if [[ "$fdroid_build" == "true" ]]; then
    libclang="$llvm/out/lib"
else
    libclang=$(find /usr -type f -regextype posix-extended -regex ".*/libclang(-[0-9]+)?\.so(\.[0-9]+)*" 2>/dev/null)
    if [[ ! -f "$libclang" ]]; then
        echo "Unable to find path to libclang.so. Search result:\n$libclang"
        exit 1
    else
        libclang=$(dirname "$libclang")
    fi
fi

export libclang