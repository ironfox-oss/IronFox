"""File system path definitions for building IronFox."""

import os
from pathlib import Path

from common.utils import current_platform, host_target, is_macos, ndk_host_tag

from .versions import Versions


class Paths:
    """Defines file system paths for building IronFox."""

    def __init__(
        self,
        root_dir: Path,
        android_home: Path,
        java_home: Path,
        cargo_home: Path,
        gradle_exec: Path,
    ):
        """Create a new IronFoxPaths instance.

        Args:
            rootdir (Path): Path to the root IronFox source directory.
        """
        self._user_home = Path.home()
        self._rootdir = root_dir
        self._android_home = android_home
        self._java_home = java_home
        self._cargo_home = cargo_home
        self._gradle_exec = gradle_exec

    def mkdirs(self):
        """Create necessary directories if they do not exist."""
        self.build_dir.mkdir(parents=True, exist_ok=True)
        self.artifacts_dir.mkdir(parents=True, exist_ok=True)
        self.artifacts_apk_dir.mkdir(parents=True, exist_ok=True)
        self.artifacts_apks_dir.mkdir(parents=True, exist_ok=True)
        self.artifacts_aar_dir.mkdir(parents=True, exist_ok=True)

    @property
    def user_home(self) -> Path:
        """Path to the user's home directory"""
        return self._user_home

    @property
    def root_dir(self) -> Path:
        """Path to the root IronFox source directory."""
        return self._rootdir

    @property
    def android_home(self) -> Path:
        """Path to the Android SDK directory."""
        return self._android_home

    @property
    def ndk_home(self) -> Path:
        """Path to the Android NDK directory."""
        return self.android_home / "ndk" / Versions.NDK_REVISION

    @property
    def ndk_toolchain_dir(self) -> Path:
        return self.ndk_home / "toolchains" / "llvm" / "prebuilt" / ndk_host_tag()

    @property
    def libclang_dir(self) -> Path:
        if is_macos():
            return self.ndk_toolchain_dir / "lib"

        return self.ndk_toolchain_dir / "musl" / "lib"

    @property
    def java_home(self) -> Path:
        """Path to the JDK directory."""
        return self._java_home

    @property
    def cargo_home(self) -> Path:
        """Path to the .cargo directory."""
        return self._cargo_home

    @property
    def gradle_exec(self) -> Path:
        """Path to the 'gradle' executable."""
        return self._gradle_exec

    @property
    def artifacts_dir(self) -> Path:
        """Path to the artifacts directory in IronFox sources.

        The artifacts directory contains generated artifacts from IronFox builds including
        `geckoview-<arch>.aar`, APK files, etc.
        """
        return self.root_dir / "artifacts"

    @property
    def artifacts_apk_dir(self) -> Path:
        """Path to the artifacts directory that contains generated APK files."""
        return self.artifacts_dir / "apk"

    @property
    def artifacts_apks_dir(self) -> Path:
        """Path to the artifacts directory that contains generated APK-set (`.apks`) files."""
        return self.artifacts_dir / "apks"

    @property
    def artifacts_aar_dir(self) -> Path:
        """Path to the artifacts directory that contains generated AAR (`.aar`) files."""
        return self.artifacts_dir / "aar"

    @property
    def patches_dir(self) -> Path:
        """Path to the directory containing patch files for IronFox."""
        return self._rootdir / "patches"

    @property
    def machrc_file(self) -> Path:
        """Path to the `machrc` file used to configure the `mach` command during IronFox build."""
        return self.patches_dir / "machrc"

    @property
    def build_dir(self) -> Path:
        """Path to the build directory."""
        return self._rootdir / "build"

    @property
    def android_components_dir(self) -> Path:
        """Path to the android-components directory in Firefox source code."""
        return self.firefox_dir / "mobile" / "android" / "android-components"

    @property
    def application_services_dir(self) -> Path:
        """Path to the application-services source directory."""
        return self._rootdir / "application-services"

    @property
    def application_services_nss_dir(self) -> Path:
        """Path to the `nss` directory in application-services."""
        return (
            self.application_services_dir
            / "libs"
            / "desktop"
            / f"{host_target()}"
            / "nss"
        )

    @property
    def bundletool_file(self) -> Path:
        """Path to the `bundletool` executable."""
        return self._rootdir / "build" / "bundletool"

    @property
    def glean_dir(self) -> Path:
        """Path to the Glean source directory."""
        return self._rootdir / "glean"

    @property
    def fenix_dir(self) -> Path:
        """Path to the Fenix source directory in Firefox source code."""
        return self._rootdir / "gecko" / "mobile" / "android" / "fenix"

    @property
    def firefox_dir(self) -> Path:
        """Path to the mozilla-release (gecko) source directory."""
        return self._rootdir / "gecko"

    @property
    def mozconfig_file(self) -> Path:
        """Path to the mozconfig file"""
        return self.firefox_dir / "mozconfig"

    @property
    def gmscore_dir(self) -> Path:
        """Path to the gmscore (microG) source directory."""
        return self._rootdir / "gmscore"

    @property
    def wasi_sdk_dir(self) -> Path:
        """Path to the wasi-sdk directory."""
        return self._rootdir / "wasi-sdk"

    @property
    def uniffi_dir(self) -> Path:
        """Path to uniffi source directory."""
        return self._rootdir / "uniffi-bindgen"
