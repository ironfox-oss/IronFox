"""Version definitions for various components used to build IronFox."""


class Versions:
    """Version definitions for various components used to build IronFox."""

    FIREFOX_VERSION = "144.0.1"
    IRONFOX_VERSION = f"{FIREFOX_VERSION}"
    FIREFOX_RELEASE_TAG = f"FIREFOX-ANDROID_{FIREFOX_VERSION.replace('.', '_')}_RELEASE"

    # Uncomment this when building RC builds and comment out the above variable
    # FIREFOX_RELEASE_TAG="FIREFOX-ANDROID_${FIREFOX_VERSION//./_}_BUILD1"

    WASI_TAG = "wasi-sdk-20"
    WASI_CMAKE_VERSION = "3.5.0"
    GLEAN_VERSION = "65.0.2"
    GLEAN_TAG = f"v{GLEAN_VERSION}"
    GMSCORE_TAG = "v0.3.10.250932"
    PHOENIX_TAG = "2025.10.12.1"
    APPSERVICES_BRANCH = "release-v144"
    BUNDLETOOL_TAG = "1.18.2"
    RUST_MAJOR_VERSION = "1.90"
    RUST_VERSION = f"{RUST_MAJOR_VERSION}.0"
    CBINDGEN_VERSION = "0.29.0"
    UNIFFI_VERSION="0.29.0"
    UNIFFI_REVISION=f"{UNIFFI_VERSION}-047359"

    ANDROID_PLATFORM_VERSION = "android-36"
    BUILDTOOLS_VERSION = "36.0.0"
    NDK_REVISION = "28.2.13676358"
    SDK_REVISION = "13114758"

    # Java version required to build IronFox
    JAVA_VERSION = 17
