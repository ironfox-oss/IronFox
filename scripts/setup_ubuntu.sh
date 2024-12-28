#!/bin/bash

# Update package lists and install required packages
sudo apt update
sudo apt install -y make \
                    cmake \
                    clang \
                    openjdk-8-jdk \
                    openjdk-17-jdk \
                    wget \
                    unzip

# Make 'gradle' available in PATH
mkdir -p "build/bin"
wget https://gitlab.com/fdroid/fdroidserver/-/raw/master/gradlew-fdroid -O "build/bin/gradle"
chmod +x "build/bin/gradle"
export PATH=$PATH:$(realpath build/bin)

# Disable Gradle daemons
mkdir -p ~/.gradle && echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties

# Setup NDK
mkdir -p build
wget https://dl.google.com/android/repository/android-ndk-r27c-linux.zip -O build/android-ndk.zip
pushd build
unzip android-ndk.zip
export ANDROID_NDK=$(realpath ./android-ndk-r27c)
popd
