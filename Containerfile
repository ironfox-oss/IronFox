FROM fedora:44

# Cosmetic, bump to re-build container image
ENV IRONFOX_IMAGE_VERSION=1

# Ensure we're up to date
RUN dnf update -y --refresh

# Install our dependencies...
RUN dnf install -y \
  as \
  bash \
  binutils \
  ca-certificates \
  clang \
  cmake \
  cpp \
  curl \
  gawk \
  gcc \
  git \
  jq \
  libtool \
  lld \
  llvm \
  m4 \
  make \
  nasm \
  ninja-build \
  patch \
  perl \
  shasum \
  tar \
  unzip \
  xz \
  yq \
  zip \
  zlib-devel

# cd into working directory
WORKDIR /app

CMD ["/bin/bash"]
