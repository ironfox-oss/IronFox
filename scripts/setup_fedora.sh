#!/bin/bash

# Install required packages
sudo dnf install -y make \
                cmake \
                clang \
                java-1.8.0-openjdk-devel \
                java-17-openjdk-devel \
                wget \
                unzip

# Make 'gradle' available in PATH
mkdir "build/bin"
wget https://gitlab.com/fdroid/fdroidserver/-/raw/master/gradlew-fdroid -O "build/bin/gradle"
export PATH=$PATH:$(realpath build/bin)

# Disable Gradle daemons
mkdir -p ~/.gradle && echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties

# Setup NDK
wget https://dl.google.com/android/repository/android-ndk-r27c-linux.zip -O build/android-ndk.zip
pushd build
unzip android-ndk.zip
export ANDROID_NDK=$(realpath ./android-ndk-r27c)
popd

sudo ln -sf /usr/lib/jvm/java-17-openjdk /usr/lib/jvm/java-17-openjdk-amd64*
sudo ln -sf /usr/lib/jvm/java-1.8.0-openjdk /usr/lib/jvm/java-8-openjdk-amd64*