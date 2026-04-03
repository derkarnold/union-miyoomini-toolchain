#FROM debian/eol:buster-slim
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND noninteractive

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y update && apt-get -y install \
    make \
    #    build-essential \
    cmake \
    ninja-build \
    autotools-dev \
    autoconf \
    automake \
    autopoint \
    libtool \
    po4a \
    m4 \
    pkg-config \
    unzip \
    wget \
    git \
    python3 \
    ca-certificates \
    gettext \
    vim \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/workspace
WORKDIR /root

COPY support .
RUN ./setup-toolchain.sh

ENV TOOLCHAIN_DIR=/opt/miyoomini-toolchain
ENV CROSS_TRIPLE=arm-linux-gnueabihf
ENV CROSS_ROOT=${TOOLCHAIN_DIR}/usr
ENV SYSROOT=${CROSS_ROOT}/${CROSS_TRIPLE}/libc

ENV AS=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-as \
    AR=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ar \
    CC=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-gcc \
    CXX=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-g++ \
    RANLIB=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-ranlib \
    STRIP=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-strip

ENV PATH=${CROSS_ROOT}/bin:${PATH}:${SYSROOT}/bin
ENV CROSS_COMPILE=${CROSS_ROOT}/bin/${CROSS_TRIPLE}-
ENV PREFIX=${SYSROOT}/usr
ENV CMAKE_TOOLCHAIN_FILE=/root/toolchain-arm.cmake
ENV UNION_PLATFORM=miyoomini
ENV PKG_CONFIG_SYSROOT_DIR=${SYSROOT}
ENV PKG_CONFIG_PATH=${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig:${SYSROOT}/usr/lib/arm-linux-gnueabihf/pkgconfig

# stuff and extra libs
RUN ./build-libzip.sh
RUN ./build-alsa.sh
RUN ./build-libsamplerate.sh
RUN ./build-lz4.sh

VOLUME /root/workspace
WORKDIR /root/workspace

CMD ["/bin/bash"]
