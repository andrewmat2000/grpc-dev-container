FROM debian:trixie-20240904-slim AS dependencies
ENV MY_INSTALL_DIR=/grpc
RUN apt update &&\
    apt install -y cmake build-essential autoconf libtool pkg-config wget git

FROM dependencies AS build
RUN mkdir -p $MY_INSTALL_DIR

WORKDIR /script
RUN wget -q -O cmake-linux.sh https://github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-x86_64.sh
RUN sh cmake-linux.sh -- --skip-license --prefix=$MY_INSTALL_DIR

WORKDIR /src
RUN git clone --recurse-submodules -b v1.66.0 --depth 1 --shallow-submodules https://github.com/grpc/grpc
RUN cd grpc &&\
    mkdir -p cmake/build &&\
    cd cmake/build &&\
    cmake -DgRPC_INSTALL=ON \
    -DgRPC_BUILD_TESTS=OFF \
    -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR \
    ../.. &&\
    make -j $(nproc) &&\
    make install

FROM dependencies AS run

COPY --from=build $MY_INSTALL_DIR/bin       /usr/local/bin
COPY --from=build $MY_INSTALL_DIR/doc       /usr/local/doc
COPY --from=build $MY_INSTALL_DIR/include   /usr/local/include
COPY --from=build $MY_INSTALL_DIR/lib       /usr/local/lib
COPY --from=build $MY_INSTALL_DIR/man       /usr/local/man
COPY --from=build $MY_INSTALL_DIR/share     /usr/local/share

ENV PATH="$PATH:$MY_INSTALL_DIR/bin"
