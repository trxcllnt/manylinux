#!/bin/bash

# Stop at any error, show all commands
set -Eexuo pipefail

if which apk; then
	apk add -y wget
elif which yum; then
	yum install -y wget
else
	apt update && apt install -y wget
fi

export SCCACHE_VERSION=0.2.15
wget -q -O - "https://github.com/mozilla/sccache/releases/download/v${SCCACHE_VERSION}/sccache-v${SCCACHE_VERSION}-${AUDITWHEEL_ARCH}-unknown-linux-musl.tar.gz" \
    | tar -C /usr/bin -zf - --wildcards --strip-components=1 -x */sccache \
 && chmod +x /usr/bin/sccache \

export UCX_VERSION=1.13.0
mkdir -p /ucx-src /usr && cd /ucx-src &&\
        git clone https://github.com/openucx/ucx -b v${UCX_VERSION} ucx-git-repo &&\
        cd ucx-git-repo && ./autogen.sh && ./contrib/configure-release --prefix=/usr &&\
        make && make install && cd /usr && rm -rf /ucx-src/

# Install gha-tools v0.0.02
wget https://github.com/rapidsai/gha-tools/releases/download/v0.0.2/tools.tar.gz -O - | tar -xz -C /usr/local/bin
