# Architecture

## Repository layout

- `scripts/`: build, patching, CI and utility scripts.
- `patches/`: `.patch` files and `*-overlay/` trees.
- `configs/`: build configuration (mozconfigs, cargo, npm, Phoenix, locales).
- `templates/`: templates for generated files, such as release notes, update
  manifests and per-component files.
- `tools/`: small wrapper scripts for build tools such as bundletool and
  gradle.
- `assets/`: images used by the README and the app.
- `docs/`: documentation.
- `external/`: downloaded sources and toolchains (not tracked).
- `build/`: build state and caches (not tracked).
- `outputs/`: built APKs and bundles (not tracked).

## How a build flows

1. `get_sources.sh` downloads Firefox, Application Services, Glean and the
   toolchains into `external/`, verifying each against the pinned checksum in
   `scripts/versions.sh`.
2. `prebuild.sh` applies the patches listed in `scripts/patches.yaml`,
   `scripts/a-s-patches.yaml` and `scripts/glean-patches.yaml`, copies the
   overlay trees from `patches/`, and runs the build-time `sed` edits in
   `scripts/prebuild-if.sh`.
3. `build.sh <build-variant>` compiles and signs the app, and writes the
   result to `outputs/`.

Most scripts are a thin wrapper (for example `build.sh`) around an
implementation file with an `-if` suffix (for example `build-if.sh`). Shared
environment variables are defined in `scripts/env_common.sh`.

## Ways the code is changed

See "Changing the code" in [CONTRIBUTING.md](../CONTRIBUTING.md). In short,
logic lives in overlay files, patches only add the hooks, and `sed` is a last
resort.

## Glossary

- **Gecko**: Firefox's browser engine. **GeckoView** is its Android embedding
  library.
- **Fenix**: the Firefox for Android app.
- **Android Components (AC)**: Mozilla's reusable Android browser library.
- **Application Services (AS)**: Mozilla's shared Rust libraries, such as sync
  and storage.
- **Glean**: Mozilla's telemetry library, which IronFox stubs out.
- **Phoenix**: the privacy and security configuration that IronFox builds on.
- **Overlay**: a tree of files copied over a source tree during prebuild.
- **Prebuild**: the step that patches and prepares the downloaded sources.
