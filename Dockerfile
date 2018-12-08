FROM rust:stretch AS builder

ARG VERSION=4.1.0
WORKDIR /src
RUN wget -q https://www.openinfosecfoundation.org/download/suricata-${VERSION}.tar.gz
RUN tar xf suricata-${VERSION}.tar.gz
WORKDIR /src/suricata-${VERSION}

RUN apt-get update && \
    apt-get -y install libpcre3 libpcre3-dbg libpcre3-dev \
    build-essential autoconf automake libtool libpcap-dev libnet1-dev \
    libyaml-0-2 libyaml-dev zlib1g zlib1g-dev libcap-ng-dev libcap-ng0 \
    make libmagic-dev libjansson-dev libjansson4 pkg-config python-yaml

RUN ./configure --enable-rust --prefix=/target
RUN make -j16
RUN make install-full

FROM debian:stretch
COPY --from=builder /target /usr/local
RUN apt-get update && \
    apt-get install -y libmagic1 libpcap0.8 libnet1	libjansson4	libyaml-0-2 && \
    rm -rf /var/lib/apt/lists/*
RUN suricata -V
