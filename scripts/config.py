#!/usr/bin/env python

import os
from pathlib import Path


MOZILLA_REF_URL = "https://hg.mozilla.org/releases/{}/archive/{}.zip"
MOZILLA_REF_DOWNLOADS = {
    # (name, repository, ref)
    ("gecko", "mozilla-release", "FIREFOX-ANDROID_133_0_3_RELEASE"),
}

GIT_CLONE_REPOS = {
    # (name, repository, ref)
    ("glean", "https://github.com/mozilla/glean", "v61.2.0"),
    ("gmscore", "https://github.com/microg/GmsCore", "v0.3.6.244735"),
}

GIT_CLONE_SUBMODULE_REPOS = {
    # (name, repository, ref)
    ("wasi-sdk", "https://github.com/WebAssembly/wasi-sdk", "wasi-sdk-20"),
    ("appservices", "https://github.com/mozilla/application-services", "v133.0")
}

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
