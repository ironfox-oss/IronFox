FROM fedora:42

# Add & enable Adoptium Repository
RUN dnf install -y adoptium-temurin-java-repository && \
    dnf config-manager setopt adoptium-temurin-java-repository.enabled=1

# Install required packages
RUN dnf install -y \
    cmake \
    clang \
    gawk \
    git \
    gyp \
    temurin-17-jdk \
    m4 \
    make \
    nasm \
    ninja-build \
    patch \
    perl \
    python3.9 \
    shasum \
    wget \
    xz \
    yq \
    zlib-devel

ENV ENVDOCKER=/opt/env_docker.sh
ENV ANDROID_HOME=/root/android-sdk
ENV JAVA_HOME=/usr/lib/jvm/temurin-17-jdk

RUN echo "#!/bin/bash" >> $ENVDOCKER

# Set up Android SDK
COPY scripts/setup-android-sdk.sh /tmp/setup-android-sdk.sh
RUN bash -x /tmp/setup-android-sdk.sh && \
    echo "export ANDROID_HOME=$ANDROID_HOME" >> $ENVDOCKER && \
    echo "export ANDROID_SDK_ROOT=\$ANDROID_HOME" >> $ENVDOCKER

# Set up gradle from F-Droid
RUN mkdir -p /root/bin
ADD https://gitlab.com/fdroid/gradlew-fdroid/-/raw/main/gradlew.py /root/bin/gradle
RUN chmod +x "/root/bin/gradle" && \
    echo "export PATH=\$PATH:/root/bin" >> $ENVDOCKER

# Set up Python virtual environment
RUN python3.9 -m venv /root/env

# Install requests
RUN pip install requests

# Set JDK 17 as default
RUN echo "export JAVA_HOME=$JAVA_HOME" >> $ENVDOCKER && \
    echo "export PATH=$JAVA_HOME/bin:/root/bin:/root/env/bin:\${PATH}" >> $ENVDOCKER

# cd into working directory
WORKDIR /app

# Create entrypoint script to activate Python venv
ENV ENTRYPOINT=/opt/entrypoint.sh
RUN echo '#!/bin/bash' > $ENTRYPOINT && \
    echo "source $ENVDOCKER" >> $ENTRYPOINT && \
    echo 'exec "$@"' >> $ENTRYPOINT && \
    chmod +x $ENTRYPOINT

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/bin/bash"]

