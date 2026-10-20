# Maintaining IronFox

## Updating to a new upstream version

Updating Firefox is often more than bumping versions and checksums. New
upstream code can break patches, `sed` edits, overlay files and build
scripts, so always build and test locally before pushing.

1. Update the commit, SHA-512 checksum and version of each source in
   `scripts/versions.sh` (Firefox, Application Services, l10n and Glean). They
   move together. Set `IRONFOX_VERSION_DATE` as well.
2. Compute each checksum from the tarball of the pinned commit:

   ```sh
   curl -L https://github.com/<org>/<repo>/archive/<commit>.tar.gz | sha512sum
   ```

3. Fetch fresh sources and prepare them:

   ```sh
   ./scripts/get_sources.sh
   ./scripts/prebuild.sh
   ```

   Fix every patch, `sed` edit and overlay file that no longer applies.
4. Build locally, install the APK, and smoke-test the app. Check the build
   logs in `build/logs` for new warnings.

   ```sh
   ./scripts/build.sh arm64
   ```

5. Write the release notes in `CHANGELOG.md`.
6. Push to `dev` and check the CI pipeline. Pushes to `dev` and `main`
   publish a release; put `[skip-release]` in the commit message to skip
   that.
