FROM ubuntu:24.04 AS cross-grpc

ENV GNU_HOST=arm-linux-gnueabihf

RUN apt-get update && \
    apt-get --no-install-recommends install -y autoconf \
    automake \
    build-essential \
    cmake \
    gcc-$GNU_HOST \
    g++-$GNU_HOST \
    git \
    gnupg \
    libssl-dev \
    libtool \
    pkg-config \
    software-properties-common \
    wget && \
  rm -rf /var/lib/apt/lists/*

ENV C_COMPILER_ARM_LINUX=$GNU_HOST-gcc
ENV CXX_COMPILER_ARM_LINUX=$GNU_HOST-g++

ENV CROSS_TOOLCHAIN=/usr/$GNU_HOST
ENV CROSS_STAGING_PREFIX=$CROSS_TOOLCHAIN/stage
ENV CMAKE_CROSS_TOOLCHAIN=/arm.toolchain.cmake

# https://cmake.org/cmake/help/v3.13/manual/cmake-toolchains.7.html#cross-compiling-for-linux
RUN echo "set(CMAKE_SYSTEM_NAME Linux)" >> $CMAKE_CROSS_TOOLCHAIN && \
    echo "set(CMAKE_SYSTEM_PROCESSOR arm)" >> $CMAKE_CROSS_TOOLCHAIN && \
    echo "set(CMAKE_STAGING_PREFIX $CROSS_STAGING_PREFIX)" >> $CMAKE_CROSS_TOOLCHAIN && \
    echo "set(CMAKE_SYSROOT ${CROSS_TOOLCHAIN}/sysroot)" >> $CMAKE_CROSS_TOOLCHAIN && \
    echo "set(CMAKE_C_COMPILER /usr/bin/$C_COMPILER_ARM_LINUX)" >> $CMAKE_CROSS_TOOLCHAIN && \
    echo "set(CMAKE_CXX_COMPILER /usr/bin/$CXX_COMPILER_ARM_LINUX)" >> $CMAKE_CROSS_TOOLCHAIN && \
    echo "set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)" >> $CMAKE_CROSS_TOOLCHAIN && \
    echo "set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)" >> $CMAKE_CROSS_TOOLCHAIN && \
    echo "set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)" >> $CMAKE_CROSS_TOOLCHAIN && \
    echo "set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)" >> $CMAKE_CROSS_TOOLCHAIN

ENV GRPC_VERSION=v1.68.0

# https://github.com/grpc/grpc/blob/master/test/distrib/cpp/run_distrib_test_raspberry_pi.sh

ENV GRPC_DIR=/grpc
ENV GRPC_BUILD_DIR=$GRPC_DIR/cmake/build

RUN git clone --depth 1 --branch $GRPC_VERSION --recursive --shallow-submodules https://github.com/grpc/grpc.git
RUN mkdir -p $GRPC_BUILD_DIR

WORKDIR $GRPC_BUILD_DIR 
RUN cmake \
      -DCMAKE_BUILD_TYPE=Release \
      -DgRPC_INSTALL=ON \
      -DgRPC_BUILD_TESTS=OFF \
      -DgRPC_SSL_PROVIDER=package \
      ../..
  
RUN make -j$(nproc) install