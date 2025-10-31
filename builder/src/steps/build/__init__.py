from pathlib import Path
from commands.base import BaseConfig
from commands.build import BuildConfig, BuildType
from common.paths import Paths
from common.locales import IRONFOX_LOCALES
from execution.definition import BuildDefinition, TaskDefinition
from execution.find_replace import on_line_text, on_lines


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

    d.chain(
        # fmt:off

        # These tasks are chained because they depend on the task
        # defined before them to be successful

        # Build application-services
        build_application_services(d, config, paths),
        
        # Build Firefox
        build_firefox(d, config, paths),
        
        # Build Android Components
        build_android_components(d, config, paths),
        
        # Build Fenix
        build_fenix(d, config, paths),
        # fmt:on
    ).depends_on(
        # fmt:off

        # These tasks can be run in parallel since they're independent of
        # each other. However, the tasks defined in the above chain(...)
        # call must be run AFTER the below tasks are successful, hence the
        # depends_on(...) call
        
        # Build UniFFI bindgen
        build_uniffi(d, paths),
        
        # Build microG
        build_microg(d=d, paths=paths),
        
        # Build Glean
        build_glean(d, paths),
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
    locales = " ".join(IRONFOX_LOCALES)
    env = {"MOZ_CHROME_MULTILOCALE": locales}
    return d.run_commands(
        name="Build Firefox",
        commands=[
            "./mach build",
            "./mach package",
            f"./mach package-multi-locale --locales {locales}",
            f"{paths.gradle_exec} -x javadocRelease :geckoview:publishReleasePublicationToMavenLocal",
        ],
        cwd=paths.firefox_dir,
        env=env,
    )


def build_android_components(
    d: BuildDefinition,
    config: BuildConfig,
    paths: Paths,
) -> TaskDefinition:
    return d.chain(
        *d.find_replace(
            name="Disable A-S auto-pubish",
            target_files=paths.android_components_dir / "local.properties",
            replacements=[
                # Publish concept-fetch (required by A-S) with auto-publication disabled,
                # otherwise automatically triggered publication of A-S will fail
                on_line_text(
                    match_lines=r"^autoPublish.application-services.dir=",
                    on_text=r".*",
                    replace="",
                )
            ],
        ),
        d.run_commands(
            name="Build Android Components",
            commands=[
                f"{paths.gradle_exec} :components:concept-fetch:publishToMavenLocal",
            ],
            cwd=paths.android_components_dir,
        ),
        # Enable the auto-publication workflow now that concept-fetch is published
        d.write_file(
            name="Enable A-S auto-pubish",
            target=paths.android_components_dir / "local.properties",
            contents=lambda: f"autoPublish.application-services.dir={paths.application_services_dir}".encode(),
            append=True,
        ),
        d.run_commands(
            name="Publish Android Components",
            commands=[
                f"{paths.gradle_exec} publishToMavenLocal",
            ],
            cwd=paths.android_components_dir,
        ),
    )


def build_fenix(
    d: BuildDefinition,
    config: BuildConfig,
    paths: Paths,
) -> TaskDefinition:
    task = (
        f":app:assembleRelease"
        if config.build_type == BuildType.APK
        else ":app:bundleRelease -Paab"
    )
    return d.run_commands(
        name="Build Fenix",
        commands=[f"{paths.gradle_exec} {task}"],
        cwd=paths.firefox_dir,
    )
