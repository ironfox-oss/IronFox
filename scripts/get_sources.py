#!/usr/bin/env python

import os
import subprocess
from config import GIT_CLONE_REPOS, GIT_CLONE_SUBMODULE_REPOS, MOZILLA_REF_DOWNLOADS, MOZILLA_REF_URL, GeckoPaths
from utils import download, zipextract_rmtoplevel

def get_sources(paths: GeckoPaths):
    print("Downloading sources...")

    for repo_name, repo, ref in GIT_CLONE_REPOS:
        print(f"Cloning {repo_name}...")
        subprocess.check_call(["git", "clone", "--branch", ref, "--depth=1", repo, str(paths.rootdir / repo_name)])
    
    for repo_name, repo, ref in GIT_CLONE_SUBMODULE_REPOS:
        print(f"Cloning {repo_name}...")
        subprocess.check_call(["git", "clone", "--branch", ref, "--depth=1", repo, str(paths.rootdir / repo_name)])
        subprocess.check_call(["git", "submodule", "update", "--init", "--depth=1"], cwd=(paths.rootdir / repo_name))
        
    for repo_name, repo, ref in MOZILLA_REF_DOWNLOADS:
        do_download(repo_name, MOZILLA_REF_URL.format(repo, ref))

def do_download(repo_name, url):
    repo_zip = paths.builddir / ("{}.zip".format(repo_name))
    repo_path = paths.rootdir / repo_name
    download(url, repo_zip)

    if not repo_zip.exists():
        raise RuntimeError(f"Source archive for {repo_name} does not exist.")

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
export patches={paths.patchdir}
export rootdir={paths.rootdir}
export builddir="$rootdir/build"
export android_components={paths.android_components}
export application_services={paths.appservicesdir}
export glean={paths.gleandir}
export fenix={paths.fenix}
export mozilla_release={paths.geckodir}
export gmscore={paths.gmscoredir}
export wasi={paths.wasisdkdir}
export paths_source="true"
"""
        )
