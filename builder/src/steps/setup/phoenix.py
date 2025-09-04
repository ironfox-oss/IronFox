from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition


def setup_phoenix(d: BuildDefinition, paths: Paths):
    download_phoenix_js = d.download(
        name="Download phoenix.js",
        url=f"https://gitlab.com/celenityy/Phoenix/-/raw/{Versions.PHOENIX_TAG}/android/phoenix.js",
        destination=paths.patches_dir / "preferences" / "phoenix.js",
        sha256="5f6aaac66f7c9c1da181ded905791bd5201228a4dff7813ee76cef8690a74c85",
    )

    download_phoenix_extended_js = d.download(
        name="Download phoenix-extended.js",
        url=f"https://gitlab.com/celenityy/Phoenix/-/raw/{Versions.PHOENIX_TAG}/android/phoenix-extended.js",
        destination=paths.patches_dir / "preferences" / "phoenix-extended.js",
        sha256="2392202836967a193ad8b2a876fbdd11da42f17fb62b49cca193aad4b7098f22",
    )
