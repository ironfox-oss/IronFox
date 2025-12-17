from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition


def setup_phoenix(d: BuildDefinition, paths: Paths):
    download_phoenix_js = d.download(
        name="Download phoenix.js",
        url=f"https://gitlab.com/celenityy/Phoenix/-/raw/{Versions.PHOENIX_TAG}/android/phoenix.js",
        destination=paths.patches_dir
        / "gecko-overlay"
        / "ironfox"
        / "prefs"
        / "000-phoenix.js",
        sha256="4941d2ba3f77c02e426dd47bf1e1aec1fa554565e9a57323cda917f1cccecc50",
    )

    download_phoenix_extended_js = d.download(
        name="Download phoenix-extended.js",
        url=f"https://gitlab.com/celenityy/Phoenix/-/raw/{Versions.PHOENIX_TAG}/android/phoenix-extended.js",
        destination=paths.patches_dir
        / "gecko-overlay"
        / "ironfox"
        / "prefs"
        / "001-phoenix-extended.js",
        sha256="d556dea64ec31af394e1fa8c9a3d56689fbaad65fbedee40ed2d33acb7a7b4c2",
    )
