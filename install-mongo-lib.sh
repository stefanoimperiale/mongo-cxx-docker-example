#!/bin/bash
set -o errexit
set -o xtrace

CWD=$(pwd)
DRIVERS_DIR=${DRIVERS_DIR:-$CWD/drivers}
MONGO_C_VERSION=${MONGO_C_VERSION:-1.17.1}
MONGO_CXX_VERSION=${MONGO_CXX_VERSION:-r3.6.0}

MONGO_C_DRIVER_DIR=mongo-c-driver
MONGO_CXX_DRIVER_DIR=mongo-cxx-driver

if [ ! -d "$DRIVERS_DIR"/"$MONGO_C_DRIVER_DIR" ] || [ ! -d "$DRIVERS_DIR"/"$MONGO_CXX_DRIVER_DIR" ]; then

  #sudo apt-get install -y build-essential git cmake wget
  rm -rf "$CWD"/cmake-build && rm -rf $"DRIVERS_DIR"
  mkdir "$CWD"/cmake-build && cd "$CWD"/cmake-build

  wget https://github.com/mongodb/mongo-c-driver/releases/download/"$MONGO_C_VERSION"/mongo-c-driver-"$MONGO_C_VERSION".tar.gz &&
    tar xzf mongo-c-driver-"$MONGO_C_VERSION".tar.gz

  cd mongo-c-driver-"$MONGO_C_VERSION" &&
    mkdir cmake-build &&
    cd cmake-build &&
    cmake -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF -DENABLE_SSL=OFF .. -DCMAKE_INSTALL_PREFIX="$DRIVERS_DIR"/"$MONGO_C_DRIVER_DIR" &&
    cmake --build . &&
    cmake --build . --target install

  cd "$CWD"/cmake-build

  wget https://github.com/mongodb/mongo-cxx-driver/releases/download/r3.6.0/mongo-cxx-driver-"$MONGO_CXX_VERSION".tar.gz &&
    tar -xzf mongo-cxx-driver-"$MONGO_CXX_VERSION".tar.gz

  cd mongo-cxx-driver-"$MONGO_CXX_VERSION"/build &&
    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$DRIVERS_DIR"/"$MONGO_CXX_DRIVER_DIR" \
      -DCMAKE_PREFIX_PATH="$DRIVERS_DIR"/"$MONGO_C_DRIVER_DIR"  -DENABLE_TESTS:BOOL=OFF \
      -DBUILD_SHARED_LIBS_WITH_STATIC_MONGOC=ON                \
        -DENABLE_EXAMPLES:BOOL=OFF &&
    cmake --build . &&
    cmake --build . --target install

  rm -rf "$CWD"/cmake-build
fi
