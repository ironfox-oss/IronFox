#!/bin/bash

SDK_REVISION=9123335
NDK_VERSION=27c
ANDROID_SDK_FILE=commandlinetools-linux-${SDK_REVISION}_latest.zip
ANDROID_NDK_FILE=android-ndk-r${NDK_VERSION}-linux.zip

if [ "$ANDROID_HOME" == "" ]; then
    export ANDROID_HOME=$HOME/android-sdk
fi

if [ "$ANDROID_NDK" == "" ]; then
    export ANDROID_NDK=$ANDROID_HOME/ndk/android-ndk-r${NDK_VERSION}
fi

if [ ! -d "$ANDROID_HOME" ]; then
    mkdir -p "$ANDROID_HOME"
    cd "$ANDROID_HOME/.."
    rm -Rf "$(basename "$ANDROID_HOME")"

    # https://developer.android.com/studio/index.html#command-tools
    echo "Downloading Android SDK..."
    wget https://dl.google.com/android/repository/${ANDROID_SDK_FILE} -O tools-$SDK_REVISION.zip
    rm -Rf $ANDROID_HOME
    mkdir -p "$ANDROID_HOME/cmdline-tools"
    unzip -q tools-$SDK_REVISION.zip -d "$ANDROID_HOME/cmdline-tools"
    mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest"
fi

if [ -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
    SDK_MANAGER="$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
elif [ -x "$ANDROID_HOME/cmdline-tools/bin/sdkmanager" ]; then
    SDK_MANAGER="$ANDROID_HOME/cmdline-tools/bin/sdkmanager"
else
    echo "ERROR: no usable sdkmanager found in $ANDROID_HOME" >&2
    echo "Checking other possible paths: (empty if not found)" >&2
    find "$ANDROID_HOME" -type f -name sdkmanager >&2
    exit 1
fi

if [ ! -d "$ANDROID_NDK" ]; then
    mkdir -p "$ANDROID_NDK"
    cd "$ANDROID_NDK/.."
    rm -Rf "$(basename "$NDK")"

    # https://developer.android.com/ndk/downloads
    echo "Downloading Android NDK..."
    wget https://dl.google.com/android/repository/${ANDROID_NDK_FILE} -O ndk-r${NDK_VERSION}.zip
    rm -Rf android-ndk-r$NDK_VERSION
    unzip -q ndk-r${NDK_VERSION}.zip
fi

echo "INFO: Using sdkmanager ... $SDK_MANAGER"
echo "INFO: Using NDK ... $ANDROID_NDK"

export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin