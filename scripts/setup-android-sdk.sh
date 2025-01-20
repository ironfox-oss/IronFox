#!/bin/bash

SDK_REVISION=9123335
ANDROID_SDK_FILE=commandlinetools-linux-${SDK_REVISION}_latest.zip

if [[ "${ANDROID_HOME:-}" == "" ]]; then
    export ANDROID_HOME=$HOME/android-sdk
    export ANDROID_SDK_ROOT=$ANDROID_HOME
fi

if [ "$ANDROID_HOME" != "$ANDROID_SDK_ROOT" ]; then
    echo "\$ANDROID_HOME and \$ANDROID_SDK_ROOT are set to different values."
    echo "Setting \$ANDROID_HOME to \$ANDROID_SDK_ROOT..."
    export ANDROID_HOME="$ANDROID_SDK_ROOT"
fi

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

# Set up Android SDK
if grep -q "Fedora" /etc/os-release; then
    JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk" $SDK_MANAGER 'build-tools;35.0.0' # for GeckoView
    JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk" $SDK_MANAGER 'ndk;26.2.11394342'  # for GleanAS
    JAVA_HOME="/usr/lib/jvm/java-1.8.0-openjdk" $SDK_MANAGER 'ndk;27.2.12479018'  # for application-services
else
    $SDK_MANAGER 'build-tools;35.0.0' # for GeckoView
    $SDK_MANAGER 'ndk;26.2.11394342'  # for GleanAS
    $SDK_MANAGER 'ndk;27.2.12479018'  # for application-services
fi

export ANDROID_NDK=$ANDROID_HOME/ndk/27.2.12479018
[ -d "$ANDROID_NDK" ] || {
    echo "$ANDROID_NDK does not exist."
    return
};

echo "INFO: Using sdkmanager ... $SDK_MANAGER"
echo "INFO: Using NDK ... $ANDROID_NDK"

echo "--------------------------"
echo "Please update environment variables by running the following:"
echo ""
echo "    export ANDROID_HOME=$ANDROID_HOME"
echo "    export ANDROID_NDK=$ANDROID_NDK"
echo ""
echo "--------------------------"