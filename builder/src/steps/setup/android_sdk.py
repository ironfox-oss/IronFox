import logging
import shutil

from pathlib import Path
from common.paths import Paths
from common.utils import current_platform, is_linux, is_macos, is_windows
from common.versions import Versions
from execution.definition import BuildDefinition

logger = logging.getLogger("AndroidSdkSetup")

sdk_tools = [
    f"platforms;{Versions.ANDROID_PLATFORM_VERSION}",
    f"build-tools;{Versions.BUILDTOOLS_VERSION}",
    f"ndk;{Versions.NDK_REVISION}",
]


def setup_android_sdk(d: BuildDefinition, paths: Paths):
    cmdlinetools = paths.android_home / "cmdline-tools"

    if is_linux():
        platform = "linux"
    elif is_macos():
        platform = "mac"
    elif is_windows():
        platform = "win"
    else:
        raise RuntimeError(f"Unknown platform: {current_platform()}")

    sdkman_name = "sdkmanager"
    if is_windows():
        sdkman_name += ".bat"

    sdkman = cmdlinetools / "latest" / "bin" / sdkman_name

    download_task = None
    if not paths.android_home.is_dir():

        sdk_file = f"commandlinetools-{platform}-{Versions.SDK_REVISION}_latest.zip"
        url = f"https://dl.google.com/android/repository/{sdk_file}"
        sha256 = "7ec965280a073311c339e571cd5de778b9975026cfcbe79f2b1cdcb1e15317ee"

        zip_file = paths.build_dir / sdk_file

        download_task = d.download(
            name=sdk_file,
            url=url,
            destination=zip_file,
            sha256=sha256,
        ).then(
            d.extract(
                name="Unpack cmdline-tools",
                archive_file=zip_file,
                extract_to=cmdlinetools,
                archive_format="zip",
                preserve_permissions=True,
            )
            .do_first(lambda: shutil.rmtree(paths.android_home, ignore_errors=True))
            .do_last(
                lambda: (
                    shutil.move(cmdlinetools / "cmdline-tools", cmdlinetools / "latest")
                )
            )
        )

    install_task = d.run_commands(
        name="Install SDK tools",
        cwd=Path.cwd(),
        assume_yes=True,
        commands=[
            f"{sdkman} --sdk_root={paths.android_home} {task}"
            for task in (["--licenses"] + sdk_tools)
        ],
    )

    if download_task:
        # If cmdline-tools is not already available,
        # defer sdk tools installation to after we install cmdline-tools
        download_task.before(install_task)

    logger.info(f"Using Android SDK: {paths.android_home}")
    logger.info(f"Using Android NDK: {paths.ndk_home}")


def setup_bundletool(d: BuildDefinition, paths: Paths):
    url = f"https://github.com/google/bundletool/releases/download/{Versions.BUNDLETOOL_TAG}/bundletool-all-{Versions.BUNDLETOOL_TAG}.jar"
    sha256 = "675786493983787ffa11550bdb7c0715679a44e1643f3ff980a529e9c822595c"
    d.download(
        name="Download bundletool",
        url=url,
        destination=paths.build_dir / "bundletool.jar",
        sha256=sha256,
    ).then(
        d.write_file(
            name="Create bundletool script",
            target=paths.build_dir / "bundletool",
            chmod=0o744,
            overwrite=True,
            contents=lambda: (
                f"""#!/bin/bash
                exec {paths.java_home / "bin" / "java"} -jar {paths.build_dir}/bundletool.jar "$@"
                """.encode()
            ),
        )
    )
