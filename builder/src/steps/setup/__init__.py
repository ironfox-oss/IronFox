"""Steps for setting up build environment for building IronFox."""

import logging

from pathlib import Path

from commands.setup import SetupConfig
from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition

from steps.common.java import setup_java
from .android_sdk import setup_android_sdk, setup_bundletool
from .phoenix import setup_phoenix
from .rust import setup_rust

logger = logging.getLogger("Setup")


def get_definition(config: SetupConfig, paths: Paths) -> BuildDefinition:
    d = BuildDefinition(name="Setup")

    setup_java(d, paths)
    setup_android_sdk(d, paths)
    setup_bundletool(d, paths)
    setup_phoenix(d, paths)
    setup_rust(d, paths)

    clone_glean = d.clone(
        name="Clone Glean",
        repo_url="https://github.com/mozilla/glean",
        clone_to=paths.glean_dir,
        branch=Versions.GLEAN_TAG,
        depth=1,
    )

    clone_microg = d.clone(
        name="Clone microG",
        repo_url="https://github.com/microg/GmsCore",
        clone_to=paths.gmscore_dir,
        branch=Versions.GMSCORE_TAG,
        depth=1,
    )

    clone_app_services = d.clone(
        name="Clone application-services",
        repo_url="https://github.com/mozilla/application-services",
        clone_to=paths.application_services_dir,
        branch=Versions.APPSERVICES_BRANCH,
        depth=1,
    )

    clone_firefox = d.clone(
        name="Clone Firefox",
        repo_url="https://github.com/mozilla-firefox/firefox",
        clone_to=paths.firefox_dir,
        branch=Versions.FIREFOX_RELEASE_TAG,
        depth=1,
    )

    clone_wasi = d.clone(
        name="Clone WASI SDK",
        repo_url="https://github.com/WebAssembly/wasi-sdk",
        clone_to=paths.wasi_sdk_dir,
        branch=Versions.WASI_TAG,
        depth=1,
    )

    return d
