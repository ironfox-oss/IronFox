#!/usr/bin/env python

import os
from pathlib import Path
import sys
import zipfile
import requests

from tqdm import tqdm


def download(url, filepath: Path):
    if filepath.exists():
        print(f"{filepath} already exists.")
        if query_yes_no("Do want to re-download?", default="no"):
            print(f"Removing {filepath}...")
            os.remove(filepath)
        else:
            return

    print("Downloading", url)

    response = requests.get(url, stream=True)
    total_size = int(response.headers.get("content-length", 0))
    block_size = 1024

    with tqdm(total=total_size, unit="B", unit_scale=True) as progress_bar:
        with open(filepath, "wb") as file:
            for data in response.iter_content(block_size):
                progress_bar.update(len(data))
                file.write(data)

    if total_size != 0 and progress_bar.n != total_size:
        raise RuntimeError("Could not download file")


def query_yes_no(question, default="yes"):
    """Ask a yes/no question via raw_input() and return their answer.

    "question" is a string that is presented to the user.
    "default" is the presumed answer if the user just hits <Enter>.
            It must be "yes" (the default), "no" or None (meaning
            an answer is required of the user).

    The "answer" return value is True for "yes" or False for "no".
    """
    valid = {"yes": True, "y": True, "ye": True, "no": False, "n": False}
    if default is None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    while True:
        sys.stdout.write(question + prompt)
        choice = input().lower()
        if default is not None and choice == "":
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' " "(or 'y' or 'n').\n")


def rmdirrec(path):
    for dirpath, _, filenames in os.walk(path, topdown=False):
        for file in filenames:
            os.remove(dirpath + "/" + file)
        os.rmdir(dirpath)


def zipextract_rmtoplevel(zip_path, extract_to):
    with zipfile.ZipFile(zip_path, "r") as zip_ref:
        file_paths = zip_ref.namelist()

        top_level_dir = os.path.commonpath(file_paths) + "/"

        for file_path in file_paths:
            relative_path = os.path.relpath(file_path, top_level_dir)
            if relative_path == ".":
                continue

            dest_path = os.path.join(extract_to, relative_path)
            os.makedirs(os.path.dirname(dest_path), exist_ok=True)

            if not file_path.endswith("/"):
                with zip_ref.open(file_path) as source, open(dest_path, "wb") as target:
                    target.write(source.read())
