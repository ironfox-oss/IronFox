FROM fedora:41

# Install required packages
RUN dnf install -y \
    cmake \
    clang \
    gyp \
    java-1.8.0-openjdk-devel \
    java-17-openjdk-devel \
    m4 \
    make \
    ninja-build \
    patch \
    perl \
    python3.9 \
    shasum \
    xz \
    zlib-devel \
    wget \
    git

ENV ENTRYPOINT=/opt/entrypoint.sh
ENV ANDROID_HOME=/root/android-sdk
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk

RUN echo "#!/bin/bash" > $ENTRYPOINT

# Set up Android SDK
ADD https://gitlab.com/ironfox-oss/IronFox/-/raw/main/scripts/setup-android-sdk.sh /tmp/setup-android-sdk.sh
RUN JAVA_HOME=$JAVA_HOME ANDROID_HOME=$ANDROID_HOME bash -x /tmp/setup-android-sdk.sh && \
    echo "export ANDROID_HOME=$ANDROID_HOME" >> $ENTRYPOINT && \
    echo "export ANDROID_SDK_ROOT=\$ANDROID_HOME" >> $ENTRYPOINT

# Set up gradle from F-Droid
RUN mkdir -p /root/bin
ADD https://gitlab.com/fdroid/fdroidserver/-/raw/master/gradlew-fdroid /root/bin/gradle
RUN chmod +x "/root/bin/gradle" && \
    echo "export PATH=\$PATH:/root/bin" >> $ENTRYPOINT

# Set up gradle properties
RUN mkdir -p /root/.gradle && \
    echo "org.gradle.daemon=false" >> /root/.gradle/gradle.properties && \
    echo "org.gradle.configuration-cache=false" >> /root/.gradle/gradle.properties

# Set up Python virtual environment
RUN python3.9 -m venv /root/env

# Set JDK 17 as default
RUN echo "export JAVA_HOME=$JAVA_HOME" >> $ENTRYPOINT \
    echo "export PATH=$JAVA_HOME/bin:/root/bin:/root/env/bin:\${PATH}" >> $ENTRYPOINT

# cd into working directory
WORKDIR /app

# Create entrypoint script to activate Python venv

RUN echo 'source /root/env/bin/activate' >> $ENTRYPOINT && \
    echo 'exec "$@"' >> $ENTRYPOINT && \
    chmod +x $ENTRYPOINT

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/bin/bash"]
