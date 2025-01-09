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

ENV BASHRC=/etc/bashrc

# Set up gradle from F-Droid
RUN mkdir -p /root/bin
ADD https://gitlab.com/fdroid/fdroidserver/-/raw/master/gradlew-fdroid /root/bin/gradle
RUN chmod +x "/root/bin/gradle"

# Set up gradle properties
RUN mkdir -p /root/.gradle && \
    echo "org.gradle.daemon=false" >> /root/.gradle/gradle.properties && \
    echo "org.gradle.configuration-cache=false" >> /root/.gradle/gradle.properties

# Set up Python virtual environment
RUN python3.9 -m venv /root/env

# Set JDK 17 as default
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk" >> $BASHRC
RUN echo "export PATH=\${JAVA_HOME}/bin:/root/bin:/root/env/bin:\${PATH}" >> $BASHRC

# cd into working directory
WORKDIR /app

# Create entrypoint script to activate Python venv

RUN echo '#!/bin/bash' > /opt/entrypoint.sh
RUN echo 'source /root/env/bin/activate' >> /opt/entrypoint.sh
RUN echo 'exec "$@"' >> /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/bin/bash"]
