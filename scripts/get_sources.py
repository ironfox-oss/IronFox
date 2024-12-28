#!/usr/bin/env python

import os
from config import GITHUB_REF_DOWNLOADS, GITHUB_REF_URL, GeckoPaths
from utils import download, query_yes_no, rmdirrec, zipextract_rmtoplevel

def get_sources(paths: GeckoPaths):
    print("Downloading sources...")

    for repo_name, repo, ref in GITHUB_REF_DOWNLOADS:
        repo_zip = paths.builddir / ("{}.zip".format(repo_name))
        repo_path = paths.rootdir / repo_name
        download(GITHUB_REF_URL.format(repo, ref), repo_zip)

        if not repo_zip.exists():
            raise RuntimeError(f"Source archive for {repo_name} does not exist.")

        if repo_path.exists():
            if len(os.listdir(repo_path)) > 0:
                print(f"{repo_path} already exists and is not an empty directory.")
                if query_yes_no("Do you want to overwrite its contents?"):
                    print(f"Deleting {repo_path}...")
                    rmdirrec(repo_path)
                else:
                    continue

        if not repo_path.exists():
            repo_path.mkdir(parents=True)

        print(f"Extracting {repo_zip}")
        zipextract_rmtoplevel(repo_zip, repo_path)
        print("\n")


if __name__ == "__main__":
    paths = GeckoPaths()

    if not paths.builddir.exists():
        paths.builddir.mkdir()

    get_sources(paths)

    paths_sh = paths.rootdir / "scripts/paths_local.sh"
    print(f"Writing {paths_sh}...")
    
    with open(paths_sh, "w") as f:
        f.write(
            f"""
paths_source="true"
patches={paths.patchdir}
android_components={paths.android_components}
application_services={paths.appservicesdir}
glean={paths.gleandir}
fenix={paths.fenix}
mozilla_release={paths.geckodir}
gmscore={paths.gmscoredir}
                """
        )
