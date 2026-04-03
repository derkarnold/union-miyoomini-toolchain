#FROM debian/eol:buster-slim
#FROM docker.io/library/ubuntu24.04
FROM ubuntu:24.04
ENV DEBIAN_FRONTEND noninteractive

ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y update && apt-get -y install \
	bc \
	build-essential \
	bzip2 \
	bzr \
	cmake \
	cmake-curses-gui \
	cpio \
	git \
	libncurses5-dev \
	make \
	rsync \
	scons \
	tree \
	unzip \
	wget \
	zip \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/workspace
WORKDIR /root

COPY support .
RUN ./setup-toolchain.sh

ENV TOOLCHAIN_DIR=/opt/miyoomini-toolchain
ENV CROSS_TRIPLE=arm-linux-gnueabihf
ENV CROSS_ROOT=${TOOLCHAIN_DIR}/usr
ENV SYSROOT=${CROSS_ROOT}/${CROSS_TRIPLE}/sysroot

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
ENV PKG_CONFIG_PATH=${SYSROOT}/usr/lib/pkgconfig:${SYSROOT}/usr/share/pkgconfig

# stuff and extra libs
RUN ./build-libzip.sh
#RUN ./build-bluez.sh
RUN ./build-libsamplerate.sh
RUN ./build-lz4.sh

VOLUME /root/workspace
WORKDIR /root/workspace

CMD ["/bin/bash"]
