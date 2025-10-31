from pathlib import Path
from typing import List
from commands.base import BaseConfig
from commands.build import BuildConfig
from common.paths import Paths
from execution.definition import BuildDefinition, TaskDefinition


def _require_dir_exists(dir: Path):
    if not dir.exists() or not dir.is_dir():
        raise RuntimeError(f"{dir} does not exist or is not a directory!")


async def get_definition(
    base: BaseConfig,
    config: BuildConfig,
    paths: Paths,
) -> BuildDefinition:
    d = BuildDefinition("Build")

    paths.build_dir.mkdir(parents=True, exist_ok=True)

    _require_dir_exists(paths.android_home)
    _require_dir_exists(paths.ndk_home)
    _require_dir_exists(paths.ndk_toolchain_dir)
    _require_dir_exists(paths.libclang_dir)
    _require_dir_exists(paths.java_home)
    _require_dir_exists(paths.cargo_home)

    d.parallel(
        # fmt:off
        
        # Build UniFFI bindgen
        build_uniffi(d, paths),
        
        # Build microG
        build_microg(d=d, paths=paths),
        
        # Build Glean
        build_glean(d, paths),
        
        # Build application-services
        build_application_services(d, config, paths),
        # fmt:on
    )

    return d


def build_uniffi(
    d: BuildDefinition,
    paths: Paths,
) -> TaskDefinition:
    return d.run_commands(
        name="Build uniffi-bindgen",
        commands=[f"{paths.cargo_home}/bin/cargo build --release"],
        cwd=paths.uniffi_dir,
    )


def build_microg(
    d: BuildDefinition,
    paths: Paths,
) -> TaskDefinition:
    tasks = [
        "javaDocReleaseGeneration",
        ":play-services-ads-identifier:publishToMavenLocal",
        ":play-services-base:publishToMavenLocal",
        ":play-services-basement:publishToMavenLocal",
        ":play-services-fido:publishToMavenLocal",
        ":play-services-tasks:publishToMavenLocal",
    ]

    return d.run_commands(
        name="Build microG",
        commands=[f"{paths.gradle_exec} -x {' '.join(tasks)}"],
        cwd=paths.gmscore_dir,
        env={"GRADLE_MICROG_VERSION_WITHOUT_GIT": "1"},
    )


def build_glean(
    d: BuildDefinition,
    paths: Paths,
) -> TaskDefinition:
    tasks = ["publishToMavenLocal"]
    return d.run_commands(
        name="Build Glean",
        commands=[f"{paths.gradle_exec} {' '.join(tasks)}"],
        cwd=paths.glean_dir,
        env={"TARGET_CFLAGS": "-DNDEBUG"},
    )


def build_application_services(
    d: BuildDefinition,
    config: BuildConfig,
    paths: Paths,
) -> TaskDefinition:
    env = {"CI": "true"}
    return d.run_commands(
        name="Build A-S",
        commands=[
            f"{config.exec_sh} -c './libs/verify-android-environment.sh'",
            f"{paths.gradle_exec} :tooling-nimbus-gradle:publishToMavenLocal",
        ],
        cwd=paths.application_services_dir,
        env=env,
    )


def build_firefox(
    d: BuildDefinition,
    config: BuildConfig,
    paths: Paths,
) -> TaskDefinition:
    env = {"CI": "true"}
    return d.run_commands(
        name="Build Firefox [build]",
        commands=[
            "./mach build",
            "./mach package",
        ],
        cwd=paths.firefox_dir,
        env=env,
    )
