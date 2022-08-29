#!/bin/bash

# Stop at any error, show all commands
set -exuo pipefail

export DEBIAN_FRONTEND=noninteractive &&\
        apt-get update -y &&\
        apt-get install -y wget curl libcudnn8-dev

export SCCACHE_VERSION=0.2.15
curl -o /tmp/sccache.tar.gz \
        -L "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${AUDITWHEEL_ARCH}-unknown-linux-musl.tar.gz" &&\
        tar -C /tmp -xvf /tmp/sccache.tar.gz &&\
        mv "/tmp/sccache-v${SCCACHE_VERSION}-${AUDITWHEEL_ARCH}-unknown-linux-musl/sccache" /usr/bin/sccache &&\
        chmod +x /usr/bin/sccache

export UCX_VERSION=1.13.0
mkdir -p /ucx-src /opt/ucx && cd /ucx-src &&\
        git clone https://github.com/openucx/ucx -b v${UCX_VERSION} ucx-git-repo &&\
        cd ucx-git-repo && ./autogen.sh && ./contrib/configure-release --prefix=/opt/ucx &&\
        make && make install && cd /opt/ucx && rm -rf /ucx-src/

# Install gha-tools v0.0.02
wget https://github.com/rapidsai/gha-tools/releases/download/v0.0.2/tools.tar.gz -O - | tar -xz -C /usr/local/bin
