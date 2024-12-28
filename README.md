What's this?
------------

This is a fork of DivestOS's [Mull Browser](https://github.com/Divested-Mobile/Mull-Fenix) based on Firefox.

Known Issues
------------
Please see the list of known issues and workarounds before opening an issue!
From Mull : https://divestos.org/index.php?page=broken#mull

Issues caused due to our changes will be listed here.

Building
--------

When building on Fedora, the following steps can be followd :

```
sudo dnf install -y \
    m4 \
    make \
    cmake \
    clang \
    gyp \
    java-1.8.0-openjdk-devel \
    java-17-openjdk-devel \
    ninja-build \
    shasum \
    zlib-devel  

# Currently, Fenix requires Python 3.9 to build
python3.9 -m venv env
source env/bin/activate

# Ensure JDK 17 is used by default
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH

source ./scripts/get_sources.py
source ./scripts/setup-android-sdk.sh
source ./scripts/paths_local.sh

./scripts/prebuild.sh <version-name> <version-code>
./scripts/build.sh
```

Updating
--------

Patches can be updated from https://gitlab.com/relan/fennecbuild.

Licenses
--------

The scripts are licensed under the GNU Affero General Public License version 3 or later.

Changes in the patch are licensed according to the header in the files this patch adds or modifies (Apache 2.0 or MPL 2.0).

The userjs-00-arkenfox.js file is licensed under MIT.

Notices
-------

Mozilla Firefox is a trademark of The Mozilla Foundation

This is not an officially supported Mozilla product. I'm in no way affiliated with Mozilla.

IronFox is not sponsored or endorsed by Mozilla

Firefox source code is available at https://hg.mozilla.org
