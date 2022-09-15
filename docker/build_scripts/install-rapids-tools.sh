#!/bin/bash

# Stop at any error, show all commands
set -exuo pipefail

apt update && apt install -y --no-install-recommends \
    curl \
    wget \
    numactl \
    libnuma-dev \
    librdmacm-dev \
    libibverbs-dev \
    openssh-client \
    libcudnn8-dev

export SCCACHE_VERSION=0.2.15
curl -o /tmp/sccache.tar.gz \
        -L "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${AUDITWHEEL_ARCH}-unknown-linux-musl.tar.gz" &&\
        tar -C /tmp -xvf /tmp/sccache.tar.gz &&\
        mv "/tmp/sccache-v${SCCACHE_VERSION}-${AUDITWHEEL_ARCH}-unknown-linux-musl/sccache" /usr/bin/sccache &&\
        chmod +x /usr/bin/sccache

export UCX_VERSION=1.13.0
mkdir -p /ucx-src /usr && cd /ucx-src \
 && git clone https://github.com/openucx/ucx -b v${UCX_VERSION} ucx-git-repo && cd ucx-git-repo \
 && ./autogen.sh \
 && ./contrib/configure-release \
    --prefix=/usr               \
    --enable-mt                 \
    --enable-cma                \
    --enable-numa               \
    --with-verbs                \
    --with-rdmacm               \
    --with-gnu-ld               \
    --with-sysroot              \
    --with-cuda=/usr/local/cuda \
    CPPFLAGS=-I/usr/local/cuda/include \
 && make -j \
 && make install \
 && cd /usr \
 && rm -rf /ucx-src/

# Install gha-tools v0.0.02
wget https://github.com/rapidsai/gha-tools/releases/download/v0.0.2/tools.tar.gz -O - | tar -xz -C /usr/local/bin
