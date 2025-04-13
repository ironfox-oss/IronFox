#!/usr/bin/env python3
#
# common.py - part of the FDroid server tools
#
# Copyright (C) 2010-2016, Ciaran Gultnieks, ciaran@ciarang.com
# Copyright (C) 2013-2017, Daniel Martí <mvdan@mvdan.cc>
# Copyright (C) 2013-2021, Hans-Christoph Steiner <hans@eds.org>
# Copyright (C) 2017-2018, Torsten Grote <t@grobox.de>
# Copyright (C) 2017, tobiasKaminsky <tobias@kaminsky.me>
# Copyright (C) 2017-2021, Michael Pöhn <michael.poehn@fsfe.org>
# Copyright (C) 2017,2021, mimi89999 <michel@lebihan.pl>
# Copyright (C) 2019-2021, Jochen Sprickerhof <git@jochen.sprickerhof.de>
# Copyright (C) 2021, Felix C. Stegerman <flx@obfusk.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import logging
import os
import sys
import zipfile
import androguard
from androguard.core.apk import APK
from androguard.core.axml import AXMLParser, format_value, START_TAG, END_TAG, TEXT, END_DOCUMENT
import androguard.util

def get_androguard_APK(apkfile, skip_analysis=False):
    return APK(apkfile, skip_analysis=skip_analysis)

def ensure_final_value(packageName, arsc, value):
    """Ensure incoming value is always the value, not the resid.

    androguard will sometimes return the Android "resId" aka
    Resource ID instead of the actual value.  This checks whether
    the value is actually a resId, then performs the Android
    Resource lookup as needed.
    """
    if value:
        returnValue = value
        if value[0] == '@':
            try:  # can be a literal value or a resId
                res_id = int('0x' + value[1:], 16)
                res_id = arsc.get_id(packageName, res_id)[1]
                returnValue = arsc.get_string(packageName, res_id)[1]
            except (ValueError, TypeError):
                pass
        return returnValue
    return ''


def get_apk_id_androguard(apkfile):
    """Read (appid, versionCode, versionName) from an APK.

    This first tries to do quick binary XML parsing to just get the
    values that are needed.  It will fallback to full androguard
    parsing, which is slow, if it can't find the versionName value or
    versionName is set to a Android String Resource (e.g. an integer
    hex value that starts with @).

    This function is part of androguard as get_apkid(), so this
    vendored and modified to return versionCode as an integer.

    """
    if not os.path.exists(apkfile):
        raise Exception("Reading packageName/versionCode/versionName failed, APK invalid: '{apkfilename}'"
                              .format(apkfilename=apkfile))

    appid = None
    versionCode = None
    versionName = None
    with zipfile.ZipFile(apkfile) as apk:
        with apk.open('AndroidManifest.xml') as manifest:
            axml = AXMLParser(manifest.read())
            count = 0
            while axml.is_valid():
                _type = next(axml)
                count += 1
                if _type == START_TAG:
                    for i in range(0, axml.getAttributeCount()):
                        name = axml.getAttributeName(i)
                        _type = axml.getAttributeValueType(i)
                        _data = axml.getAttributeValueData(i)
                        value = format_value(_type, _data, lambda _: axml.getAttributeValue(i))
                        if appid is None and name == 'package':
                            appid = value
                        elif versionCode is None and name == 'versionCode':
                            if value.startswith('0x'):
                                versionCode = int(value, 16)
                            else:
                                versionCode = int(value)
                        elif versionName is None and name == 'versionName':
                            versionName = value

                    if axml.getName() == 'manifest':
                        break
                elif _type in (END_TAG, TEXT, END_DOCUMENT):
                    raise RuntimeError('{path}: <manifest> must be the first element in AndroidManifest.xml'
                                       .format(path=apkfile))

    if not versionName or versionName[0] == '@':
        a = get_androguard_APK(apkfile)
        versionName = ensure_final_value(a.package, a.get_android_resources(), a.get_androidversion_name())
    if not versionName:
        versionName = ''  # versionName is expected to always be a str

    return appid, versionCode, versionName.strip('\0')

def main(params):
    # Disable logging since the output of this script is parsed
    androguard.util.set_log('ERROR')

    latest_vercode, latest_vername = None, None
    for apk in params:
        if not os.path.exists(apk) or not os.path.isfile(apk):
            raise RuntimeError(f"APK file {apk} does not exist or is not a file")

        appid, vercode, vername = get_apk_id_androguard(apk)
        # print("APK:", apk)
        # print("  ID:", appid)
        # print("  Version code:", vercode)
        # print("  Version name:", vername)

        if not latest_vercode or latest_vercode < vercode: # type: ignore
            latest_vercode = vercode
            latest_vername = vername

    if not latest_vercode:
        raise RuntimeError("Failed to find latest version code")

    if not latest_vername:
        raise RuntimeError("Failed to find latest version name")

    print("{}:{}".format(latest_vercode, latest_vername))

if __name__ == "__main__":
    main(sys.argv[1:])
