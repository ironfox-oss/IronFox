# IronFox Nightly vs. Release

This page serves to document deviations between standard IronFox *(`Release`)* builds and `Nightly` *(CI)* builds.

## Deviations

- IronFox **`Nightly`** uses a different `mozconfig` build file for certain branding elements.
    - The `mozconfig` branding file for `Release` builds can be found [here](https://gitlab.com/ironfox-oss/IronFox/-/blob/dev/patches/gecko-overlay/ironfox/mozconfigs/branding/ironfox.mozconfig).
    - The `mozconfig` branding file for `Nightly` builds can be found [here](https://gitlab.com/ironfox-oss/IronFox/-/blob/dev/patches/gecko-overlay/ironfox/mozconfigs/branding/ironfox-nightly.mozconfig).

- IronFox **`Nightly`** uses the package ID: `org.ironfoxoss.ironfox.nightly`.
    - IronFox `Release` builds use `org.ironfoxoss.ironfox`.

- IronFox **`Nightly`** does **not** reset the value of `devtools.debugger.remote-enabled` on launch.
    - This preference controls whether remote debugging is enabled. On `Release` builds, it is reset on the browser's launch, to improve privacy and security.
    - On `Nightly` builds, remote debugging is still disabled by default, but, in order to allow easier testing/troubleshooting, the preference will not automatically reset.
