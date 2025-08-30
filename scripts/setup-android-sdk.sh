#!/bin/bash

BUILDTOOLS_VERSION="36.0.0"
NDK_REVISION="28.1.13356709"
SDK_REVISION="13114758"
ANDROID_SDK_FILE=commandlinetools-linux-${SDK_REVISION}_latest.zip

if [[ "${ANDROID_HOME+x}" == "" ]]; then
    export ANDROID_HOME=$HOME/android-sdk
fi

export ANDROID_SDK_ROOT="$ANDROID_HOME"

if [ ! -d "$ANDROID_HOME" ]; then
    mkdir -p "$ANDROID_HOME"
    cd "$ANDROID_HOME/.." || exit 1
    rm -Rf "$(basename "$ANDROID_HOME")"

    # https://developer.android.com/studio/index.html#command-tools
    echo "Downloading Android SDK..."
    wget https://dl.google.com/android/repository/${ANDROID_SDK_FILE} -O tools-$SDK_REVISION.zip
    rm -Rf "$ANDROID_HOME"
    mkdir -p "$ANDROID_HOME/cmdline-tools"
    unzip -q tools-$SDK_REVISION.zip -d "$ANDROID_HOME/cmdline-tools"
    mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
    rm -vf tools-$SDK_REVISION.zip
fi

if [ -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
    SDK_MANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
elif [ -x "$ANDROID_HOME/cmdline-tools/bin/sdkmanager" ]; then
    SDK_MANAGER="$ANDROID_HOME/cmdline-tools/bin/sdkmanager"
else
    echo "ERROR: no usable sdkmanager found in $ANDROID_HOME" >&2
    echo "Checking other possible paths: (empty if not found)" >&2
    find "$ANDROID_HOME" -type f -name sdkmanager >&2
    return
fi

PATH=$PATH:$(dirname "$SDK_MANAGER")
export PATH

# Accept licenses
{ yes || true; } | sdkmanager --sdk_root="$ANDROID_HOME" --licenses

$SDK_MANAGER "build-tools;$BUILDTOOLS_VERSION" # for GeckoView
$SDK_MANAGER 'platforms;android-36' # for GeckoView
$SDK_MANAGER "ndk;$NDK_REVISION"  # for mozbuild; application-services

export ANDROID_NDK="$ANDROID_HOME/ndk/$NDK_REVISION"
[ -d "$ANDROID_NDK" ] || {
    echo "$ANDROID_NDK does not exist."
    return
}

echo "INFO: Using sdkmanager ... $SDK_MANAGER"
echo "INFO: Using NDK ... $ANDROID_NDK"
