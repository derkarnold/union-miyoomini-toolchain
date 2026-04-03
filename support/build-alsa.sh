git clone --depth 1 --branch v1.2.15.3 https://github.com/alsa-project/alsa-lib /tmp/alsa && \
    cd /tmp/alsa && \
    autoreconf --install && \
    mkdir build && cd build && \
    ../configure  \
        --host=$CROSS_TRIPLE \
        --prefix=$SYSROOT/usr \
        --with-sysroot=$SYSROOT && \
    make -j$(nproc) && make install && \
    cd /tmp && rm -rf /tmp/alsa
