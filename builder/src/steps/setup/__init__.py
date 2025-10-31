"""Steps for setting up build environment for building IronFox."""

import logging

from commands.setup import SetupConfig
from common.paths import Paths
from common.utils import current_platform, is_linux, is_macos
from common.versions import Versions
from execution.definition import BuildDefinition

from steps.common.java import setup_java
from .android_sdk import setup_android_sdk, setup_bundletool
from .phoenix import setup_phoenix
from .rust import setup_rust

logger = logging.getLogger("Setup")


async def get_definition(config: SetupConfig, paths: Paths) -> BuildDefinition:
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
        depth=config.clone_depth,
    )

    clone_microg = d.clone(
        name="Clone microG",
        repo_url="https://github.com/microg/GmsCore",
        clone_to=paths.gmscore_dir,
        branch=Versions.GMSCORE_TAG,
        depth=config.clone_depth,
    )

    clone_app_services = d.clone(
        name="Clone application-services",
        repo_url="https://github.com/mozilla/application-services",
        clone_to=paths.application_services_dir,
        branch=Versions.APPSERVICES_BRANCH,
        depth=config.clone_depth,
    )

    clone_firefox = d.clone(
        name="Clone Firefox",
        repo_url="https://github.com/mozilla-firefox/firefox",
        clone_to=paths.firefox_dir,
        branch=Versions.FIREFOX_RELEASE_TAG,
        depth=config.clone_depth,
    )

    if is_linux():
        wasi_archive = f"{Versions.WASI_TAG}-firefox-linux.tar.xz"
        wasi_checksum = (
            "d008e2559bc230bb384bcb02fe229d3137af0ccfad58391efe0ec797992c9f0c"
        )
    elif is_macos():
        wasi_archive = f"{Versions.WASI_TAG}-firefox-osx.tar.xz"
        wasi_checksum = (
            "6c46f13458fe702272aa73bc06bf266091e6fe199da3793e1670c556f7937409"
        )
    else:
        raise RuntimeError(f"Unsupported platform: {current_platform()}")

    download_wasi = d.download(
        name="Download pre-built Wasi SDK sysroot",
        url=f"https://github.com/ironfox-oss/IronFox/releases/download/{Versions.WASI_TAG}/{wasi_archive}",
        destination=paths.build_dir / wasi_archive,
        sha256=wasi_checksum,
    ).then(
        d.extract(
            name="Extract Wasi SDK sysroot",
            archive_file=paths.build_dir / wasi_archive,
            extract_to=paths.wasi_sdk_dir,
            archive_format="xztar",
        )
    )

    clone_uniffi = d.clone(
        name="Clone uniffi-bindgen",
        repo_url="https://gitlab.torproject.org/tpo/applications/uniffi-rs",
        clone_to=paths.uniffi_dir,
        branch=Versions.UNIFFI_VERSION,
        depth=config.clone_depth,
    )

    return d
