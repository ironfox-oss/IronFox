# Contributing to IronFox

Thank you for helping improve IronFox. This guide covers how to report issues,
set up a build, change the code, and submit your changes. By participating,
you agree to follow our [Code of Conduct](CODE_OF_CONDUCT.md).

## Ways to contribute

- **Report bugs and suggest ideas** on the
  [unified issue tracker](https://codeberg.org/ironfox-oss/bugs/issues).
  Please search for existing reports first.
- **Translate** the app on
  [Weblate](https://hosted.weblate.org/engage/ironfox/).
- **Improve the documentation** in the
  [website repository](https://gitlab.com/ironfox-oss/ironfoxoss.org), where
  the feature and user docs live.
- **Send code changes** as described below.
- **Ask questions or discuss ideas** on
  [Matrix](https://matrix.to/#/#ironfox:unredacted.org) (recommended) or
  [Discord](https://discord.gg/zbdzfRVyVh).

For anything larger than a small fix, please open an issue or ask on Matrix
before starting, so the approach can be agreed first.

## Where the code lives

The main repository is on
[GitLab](https://gitlab.com/ironfox-oss/IronFox). It is mirrored to
[Codeberg](https://codeberg.org/ironfox-oss/IronFox) and
[GitHub](https://github.com/ironfox-oss/IronFox). Send merge requests to
GitLab. See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for a map of the
repository and a glossary of the project's terms.

## Setting up a build

You need roughly 50 GB of free disk space for one build variant: the
sources and toolchains take about 30 GB, and the build cache about 15 GB.

Clone your fork of the repository, or the main one if you only want to build:

```sh
git clone https://gitlab.com/ironfox-oss/IronFox.git
cd IronFox
```

Building with the container image is recommended. A native build is supported
on recent Fedora, macOS, secureblue and Ubuntu.

### With Docker or Podman

```sh
./scripts/run-container.sh
```

This builds the builder image locally and opens a shell inside it with the
repository mounted. Run the remaining steps in that shell. The script
auto-detects your engine. To choose one explicitly:

```sh
CONTAINER_ENGINE=docker ./scripts/run-container.sh
```

### Without a container

macOS users need [Homebrew](https://brew.sh/) first. Make sure `git` is
installed (secureblue already includes it), for example:

```sh
sudo dnf install git   # Fedora
brew install git       # macOS
sudo apt install git   # Ubuntu
```

Then install the build dependencies:

```sh
./scripts/bootstrap.sh
```

### Get sources

To use a different dependency version than the current one, edit
`scripts/versions.sh` **before** running this step.

```sh
./scripts/get_sources.sh
```

This can take a while depending on your network.

### Prepare sources

```sh
./scripts/prebuild.sh
```

Run this once per set of fresh sources. It patches the downloaded code in
place, so running it again on an already prepared tree fails. To start over,
fetch the sources again with `./scripts/get_sources.sh`.

### Build

```sh
./scripts/build.sh <build-variant>
```

`<build-variant>` is one of:

- `arm` - 32-bit ARM (`armeabi-v7a`)
- `arm64` - 64-bit ARM (`arm64-v8a`)
- `x86_64` - 64-bit x86
- `bundle` - Android App Bundle (AAB) with all supported ABIs

`bundle` also produces an APK per architecture and a universal APK.

### Building a single project

`build.sh` takes an optional second argument that selects what to build. It
defaults to `fenix`, which builds the whole app and is what you want in most
cases:

```sh
./scripts/build.sh arm64 [project]
```

`project` is one of `fenix`, `ac-core`, `ac`, `as`, `bundletool`, `gecko`,
`geckoview`, `glean`, `ironfox-core`, `llvm`, `microg`, `nimbus-fml`,
`phoenix`, `uniffi`, `up-ac` or `wasi`. Each builds that project and its
dependencies. Prefix a project with `rebuild-` (for example `rebuild-as`) to
build it and the projects that consume it. `rebuild-fenix` builds only Fenix.
Run the script with an invalid project name to print the full list.

## Build options

Build behavior is controlled by `IRONFOX_*` environment variables. They are
defined, with their defaults, in `scripts/env_common.sh`, which you should not
edit. Export a variable in your shell, or put it in an `env_override.sh` file
at the repository root (ignored by git):

```sh
export IRONFOX_RELEASE=1
./scripts/build.sh arm64
```

Commonly used variables:

- `IRONFOX_RELEASE` (default `0`): `1` builds the release channel instead of
  Nightly.
- `IRONFOX_BUILD_DATE_OVERRIDE` (default unset): an ISO 8601 UTC timestamp,
  such as `2026-10-20T00:00:00Z`, that replaces the build time. The Android
  version code is derived from the build time, so set this to get a fixed
  version code.
- `IRONFOX_LOCALES` (default: the contents of `configs/locales`): a single
  line of space-separated locale codes, such as `de fr es-ES`. Build fewer
  locales to speed up test builds.
- `IRONFOX_NO_PREBUILDS` (default `0`): `1` builds `uniffi-bindgen` and the
  WASI SDK from source instead of using our prebuilt copies.
- `IRONFOX_VERBOSE` (default `0`): `1` shows verbose build output.
- `IRONFOX_LOG_BUILD` (default `1`): write the build log to `IRONFOX_LOG_DIR`
  (default `build/logs`).
- `IRONFOX_OUTPUTS` (default `outputs/`): where built APKs are written.
- `IRONFOX_SIGN_SKIP_ADB` (default `0`): `1` skips the prompt to install over
  ADB after signing.
- `CONTAINER_ENGINE` (default: auto-detected): `docker` or `podman`, for
  `run-container.sh`.

`scripts/ironfox-studio.sh` opens the projects in Android Studio with the
build environment set up. It reads `IRONFOX_MACH_TARGET_ARCH` (`arm64`, `arm`,
`x86_64` or `bundle`, default `arm64`).

## Changing the code

IronFox modifies Firefox through three mechanisms. Prefer them in this order.

1. **Overlay files** (`patches/*-overlay/`). New files, and all non-trivial
   logic, go here. `prebuild.sh` copies each overlay tree over the matching
   source tree. Overlays exist for Android Components, Application Services,
   Fenix, Gecko and Glean.
2. **Patches** (`patches/*.patch`). Keep them to a minimum. When a feature
   needs to change upstream code, make the smallest patch that adds a hook (a
   call, a setting or an extension point), and put the real logic in an
   overlay file that the hook calls.
3. **`sed` edits** in `scripts/prebuild-if.sh`. Avoid these. Use `sed` only
   where the change has to be computed at build time, such as injecting a
   value that differs per build.

### Creating a patch

Prepare the sources, edit the target files under `external/`, then run:

```sh
./scripts/patch_create.sh
```

The script asks which project to patch (Application Services, Gecko or Glean)
and for a patch name. It commits your changes in that source tree and writes
`patches/<name>.patch`. Commits are signed, so a GPG signing key must be
configured. Prefix the name with the component it targets:

- `a-c-`: Android Components
- `a-s-`: Application Services
- `fenix-`: Fenix
- `geckoview-`: GeckoView
- `gecko-`: anywhere else in the Firefox repository
- `glean-`: Glean

Then register the patch in `scripts/patches.yaml` (`a-s-patches.yaml` for
Application Services and `glean-patches.yaml` for Glean). Each entry needs
`file`, `name`, `description`, `reason`, `effect` and `category`. The
website's feature pages are generated from this file.

A patch keeps the license of the files it modifies. See
[LICENSES.md](LICENSES.md).

### Testing a change

There is no automated test suite. Before you send a change:

1. Fetch fresh sources with `./scripts/get_sources.sh` and run
   `./scripts/prebuild.sh` to confirm that every patch still applies.
2. Build with `./scripts/build.sh <build-variant>` and install the APK on a
   device or emulator.
3. Check the behavior you changed.

In your merge request, say which device, Android version and build variant you
tested.

## Linting

Shell scripts are checked with [`shellcheck`](https://www.shellcheck.net/)
(static analysis) and [`shfmt`](https://github.com/mvdan/sh) (formatting). CI
runs these in the `lint-scripts` job, and a failure stops the pipeline before
any build starts.

`./scripts/get_sources.sh` installs both tools and enables a pre-commit hook
(through `core.hooksPath`) that lints staged scripts. The hook is a
convenience and can be skipped with `git commit --no-verify`, but CI is the
source of truth.

If you supply your own `shellcheck` and `shfmt`, set `IRONFOX_SHELLCHECK_DIR`
and `IRONFOX_SHFMT_DIR`, then enable the hook with:

```sh
./scripts/lint-hook.sh
```

Other commands:

```sh
./scripts/lint.sh                                  # run all checks
git ls-files 'scripts/*.sh' | xargs shfmt -w       # auto-fix formatting
```

Configuration is in `.shellcheckrc` (checks) and `.editorconfig` (formatting).

## Continuous integration

Merge request pipelines run on your fork, not on the main repository, and
they run only the `lint-scripts` job. The build, release and website jobs
need GitLab's 2xlarge runners, which only the main project has, so they are
skipped on forks. Build and test locally before you submit. A maintainer
builds your change after review.

## Changelog

`CHANGELOG.md` is written by maintainers at release time. Please do not edit
it.

## Commit messages

Sign your commits and start the subject with a type prefix, usually `feat:` or
`fix:`. Aim for a subject under about 72 characters. Add a body only when the
change depends on something the diff does not show.

## Submitting

1. Fork the repository and create a branch from `dev`. Do not target `main`.
2. Make sure `./scripts/lint.sh` passes and that you have built and tested
   your change.
3. Open a merge request against `dev` that describes what changed and why, and
   links any related issue. The merge request template lists what to include.

## Licensing

Scripts are licensed under the AGPL-3.0-or-later. Patches follow the license
of the files they modify. See [LICENSES.md](LICENSES.md) for details and
attributions.
