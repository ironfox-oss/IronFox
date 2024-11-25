![Banner](https://divestos.org/images/featureGraphics/Mull.png)

What's this?
------------

This is a fork of Relan's excellent [fennecbuild repository](https://gitlab.com/relan/fennecbuild).
It allows compiling the entirety of Fenix without prebuilts along with removal of the proprietary blobs.

This fork is specifically for compiling Mull.
It enables many features upstreamed by the Tor Uplift project using preferences from the [arkenfox-user.js project](https://github.com/arkenfox/user.js).
It was originally created as builds of the patchset from [bug 1419581](https://bugzilla.mozilla.org/show_bug.cgi?id=1419581).

This is compiled using fdroidserver.
You will need to copy the config files from -fdroiddata/ into their respective folders first.
Then run:
```
fdroid build us.spotco.fennec_dos:VERCODE
```
where VERCODE is a version code number.
VERCODE is currently prepended with 2 as an epoch for upgrade from old Fennec-based Mull.
The second to last number of the VERCODE corresponds to the architecture to compile.
0 = ARMv7, 1 = x86, 2 = AArch64

[<img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png"
     alt="Get it on F-Droid"
     height="80">](https://f-droid.org/packages/us.spotco.fennec_dos/)

Known Issues
------------
Please see the list of known issues and workarounds before opening an issue!
https://divestos.org/index.php?page=broken#mull

Updating
--------
- Setup: `git remote add upstream https://gitlab.com/relan/fennecbuild`
- Update:
```
git fetch upstream
git rebase upstream/master
```

Setting up the VM
-----------------
Getting a working fdroidserver is a bit tricky.
Here are some steps to get you in the right direction.
- Setup a VM, you'll want at least 16GB RAM and 64GB of storage
- Fedora 41 has been tested to work
- `git clone https://gitlab.com/fdroid/fdroidserver.git`
- `git clone https://gitlab.com/fdroid/fdroiddata.git`
- Install JDK 8 and 17, set 17 as default
- Put this in your path as your gradle, make sure the folder above it is writable for its cache:
```
wget https://gitlab.com/fdroid/fdroidserver/-/raw/master/gradlew-fdroid -O gradle
```
- Disable the Gradle daemon to prevent OOM:
```
mkdir -p ~/.gradle && echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties
```
- setup Android SDK/NDK:
```
mkdir android android-ndk
wget https://dl.google.com/android/repository/tools_r25.2.3-linux.zip
unzip tools_r*-linux.zip -d android/
android update sdk --no-ui
android update sdk --no-ui --filter build-tools-30.0.2,android-30,build-tools-30.0.0-preview,build-tools-29.0.3,android-29,build-tools-28.0.3,android-28 --all
wget https://dl.google.com/android/repository/android-ndk-r27c-linux.zip
unzip android-ndk-r27c-linux.zip -d android-ndk/
echo "ndk_paths = { '27.2.12479018: \"\$ANDROID_NDK\" }" >> fdroiddata/config.py
```
- Add the following to your .bashrc
```
export ANDROID_HOME=~/android
export ANDROID_NDK=~/android-ndk/android-ndk-r27b
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export PATH=$PATH:~/fdroidserver
```
- `source .bashrc`
- Fedora:
```
sudo ln -sf /usr/lib/jvm/java-17-openjdk /usr/lib/jvm/java-17-openjdk-amd64
sudo ln -sf /usr/lib/jvm/java-1.8.0-openjdk /usr/lib/jvm/java-8-openjdk-amd64
```

Licenses
--------

The scripts are licensed under the GNU Affero General Public License version 3 or later.

Changes in the patch are licensed according to the header in the files this patch adds or modifies (Apache 2.0 or MPL 2.0).

The artwork is licensed under the MPL 2.0.

The userjs-00-arkenfox.js file is licensed under MIT.

Notices
-------

Mozilla Firefox is a trademark of The Mozilla Foundation

Divested Computing Group is not affiliated with Mozilla

Mull is not sponsored or endorsed by Mozilla

Firefox source code is available at https://hg.mozilla.org
