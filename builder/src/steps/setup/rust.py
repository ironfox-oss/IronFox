from common.paths import Paths
from common.versions import Versions
from execution.definition import BuildDefinition


def setup_rust(d: BuildDefinition, paths: Paths):
    setup_script = paths.build_dir / "setup-rust.sh"
    rustup = paths.cargo_home / "bin" / "rustup"
    d.download(
        name="Rust installer script",
        url="https://sh.rustup.rs",
        destination=setup_script,
        # TODO: Maybe we should skip checksum checks for this?
        sha256="17247e4bcacf6027ec2e11c79a72c494c9af69ac8d1abcc1b271fa4375a106c2",
    ).then(
        d.run_commands(
            name="Install Rust",
            commands=[f"sh {setup_script} -y"],
        )
    ).then(
        d.run_commands(
            name="Set default rust version",
            commands=[f"{rustup} default {Versions.RUST_VERSION}"],
        )
    ).then(
        *[
            d.run_commands(
                name=f"Install Rust target {target}",
                commands=[f"{rustup} target add {target}"],
            )
            for target in [
                "thumbv7neon-linux-androideabi",
                "armv7-linux-androideabi",
                "aarch64-linux-android",
                "i686-linux-android",
                "x86_64-linux-android",
            ]
        ]
    )
