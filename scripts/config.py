#!/usr/bin/env python

import os
from pathlib import Path


GITHUB_REF_URL = "https://github.com/{}/archive/{}.zip"
MOZILLA_REF_URL = "https://hg.mozilla.org/releases/{}/archive/{}.zip"
GITHUB_REF_DOWNLOADS = {
    # When changing names below, also change in class GeckoPaths
    
    # (name, repository, ref)
    ("glean", "mozilla/glean", "refs/tags/v61.2.0"),
    ("appservices", "mozilla/application-services" , "refs/tags/v133.0"),
    ("gmscore", "microg/GmsCore", "refs/tags/v0.3.6.244735"),
}

MOZILLA_REF_DOWNLOADS = {
    # (name, repository, ref)
    ("gecko", "mozilla-release", "FIREFOX-ANDROID_133_0_3_RELEASE"),
}

WASI_REPO = "https://github.com/WebAssembly/wasi-sdk"
WASI_TAG = "wasi-sdk-20"

class GeckoPaths:
    def __init__(self):
        self.rootdir = Path(os.path.dirname(os.path.dirname(os.path.realpath(__file__))))
        self.builddir = self.rootdir / "build"
        self.patchdir = self.rootdir / "patches"
        self.geckodir = self.rootdir / "gecko"
        self.gleandir = self.rootdir / "glean"
        self.appservicesdir = self.rootdir / "appservices"
        self.gmscoredir = self.rootdir / "gmscore"
        self.wasisdkdir = self.rootdir / "wasi-sdk"
        
        self.android_components = self.geckodir / "mobile/android/android-components"
        self.fenix = self.geckodir / "mobile/android/fenix"
