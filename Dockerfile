FROM fedora:43

# Ensure we're up to date
RUN dnf update -y --refresh

# Add + enable the Adoptium Working Group's repository
RUN dnf install -y adoptium-temurin-java-repository && \
    dnf config-manager setopt adoptium-temurin-java-repository.enabled=1 && \
    dnf makecache

# Install our dependencies...
RUN dnf install -y \
    cmake \
    clang \
    gawk \
    git \
    m4 \
    make \
    nasm \
    ninja-build \
    patch \
    perl \
    python3.9 \
    shasum \
    temurin-8-jdk \
    temurin-17-jdk \
    wget \
    xz \
    yq \
    zlib-devel

# cd into working directory
WORKDIR /app

CMD ["/bin/bash"]
