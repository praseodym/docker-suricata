FROM rust:stretch AS builder

ARG VERSION=4.1.1
WORKDIR /src
RUN wget -q https://www.openinfosecfoundation.org/download/suricata-${VERSION}.tar.gz
RUN tar xf suricata-${VERSION}.tar.gz
WORKDIR /src/suricata-${VERSION}

RUN apt-get update && \
    apt-get -y install libpcre3 libpcre3-dbg libpcre3-dev \
    build-essential autoconf automake libtool libpcap-dev libnet1-dev \
    libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libcap-ng-dev libcap-ng0 \
    make libmagic-dev libjansson-dev libjansson4 pkg-config \
    python-yaml liblua5.1-0-dev libnss3-dev liblz4-dev

RUN ./configure --enable-rust --enable-lua
RUN make -j16
RUN make install DESTDIR=/target
RUN ldconfig /target/usr/local/lib
RUN make install-conf DESTDIR=/target
RUN make install-rules DESTDIR=/target && \
    mkdir -p /target/usr/local/var/lib/suricata/ && \
    cp -r /usr/local/var/lib/suricata/rules /target/usr/local/var/lib/suricata/

FROM debian:stretch
COPY --from=builder /target /
RUN apt-get update && \
    apt-get install -y libmagic1 libpcap0.8 libnet1 libjansson4 libyaml-0-2 liblua5.1-0 libnss3 && \
    rm -rf /var/lib/apt/lists/*
RUN suricata -V
