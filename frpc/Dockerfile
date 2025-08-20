ARG BUILD_FROM
FROM $BUILD_FROM

# FRPC release version (changeme if needed)
ARG FRPC_VERSION=0.58.1

# Install runtime deps
RUN apk add --no-cache jq curl

# Copy rootfs (S6 service + run script)
ADD rootfs /

# Fetch frpc binary for the current arch
RUN set -eux; \
    arch="$(apk --print-arch)"; \
    case "$arch" in \
      aarch64) frp_arch=arm64 ;; \
      armv7)   frp_arch=arm   ;; \
      armhf)   frp_arch=arm   ;; \
      x86_64)  frp_arch=amd64 ;; \
      x86)     frp_arch=386   ;; \
      *) echo "Unsupported arch: $arch" && exit 1 ;; \
    esac; \
    url="https://github.com/fatedier/frp/releases/download/v${FRPC_VERSION}/frp_${FRPC_VERSION}_linux_${frp_arch}.tar.gz"; \
    echo "Downloading $url"; \
    curl -fsSL "$url" -o /tmp/frp.tgz; \
    tar -xzf /tmp/frp.tgz -C /tmp; \
    mv /tmp/frp_${FRPC_VERSION}_linux_${frp_arch}/frpc /usr/local/bin/frpc; \
    chmod +x /usr/local/bin/frpc; \
    rm -rf /tmp/frp*

# Default command handled by s6-overlay via services.d
