FROM fedora:43

# Ensure we're up to date
RUN dnf update -y --refresh

# Install our dependencies...
RUN dnf install -y \
    cmake \
    clang \
    gawk \
    git \
    jq \
    m4 \
    make \
    nasm \
    ninja-build \
    patch \
    perl \
    shasum \
    xz \
    yq \
    zlib-devel

# cd into working directory
WORKDIR /app

CMD ["/bin/bash"]
