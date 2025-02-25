FROM debian:bookworm AS builder
WORKDIR /git

RUN set -ex && \
    apt-get update && \
    apt-get -y install git autoconf make automake gcc g++ libssl-dev patch sed libtool linux-headers-generic && \
    git clone --recursive https://github.com/RIPE-NCC/ripe-atlas-software-probe.git /git && \
    cd /git && \
    autoreconf -iv && \
    ./configure --prefix=/app --disable-chown --disable-setcap-install --disable-systemd && \
    make install

FROM debian:trixie-slim AS image
WORKDIR /app
RUN set -ex && \
    apt-get update && \
    apt-get install --no-install-recommends -y iproute2 net-tools tini openssh-client libcap2-bin && \
    adduser --disabled-password --gecos "" ripe-atlas && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*
COPY --from=builder /app /app
RUN setcap cap_net_raw=ep /app/libexec/ripe-atlas/measurement/busybox
VOLUME ["/app/etc/ripe-atlas", "/app/var/run/ripe-atlas/status"]
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/entrypoint.sh"]
