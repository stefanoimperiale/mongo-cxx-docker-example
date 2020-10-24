#!/bin/bash
usage() {
  echo "Usage: $0 [-u <CONNECTION URL>]" 1>&2
  exit 1
}

while getopts ":u:" arg; do
  case "${arg}" in
  u)
    echo "${OPTARG}"
    CONNECTION_URI=${OPTARG}
    ;;
  *)
    usage
    ;;
  esac
done

set -o errexit
set -o pipefail
set -o xtrace

BUILD_TYPE=${BUILD_TYPE:-Release}
CXX_STANDARD=${CXX_STANDARD:-20}
CMAKE=${CMAKE:-cmake}
BOOST_DIR=${BOOST_DIR:-c:/local/boost_1_60_0}

rm -rf build && mkdir build
cd build

echo "CONNECTION URL ${CONNECTION_URI}"

if [ -z "$MSVC" ]; then
  if [[ -z ${CONNECTION_URI} ]]; then
    "$CMAKE" -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" -DCMAKE_CXX_STANDARD="${CXX_STANDARD}" ..
  else
    "$CMAKE" -DCONNECTION_URI="${CONNECTION_URI}" -DCMAKE_BUILD_TYPE="${BUILD_TYPE}" -DCMAKE_CXX_STANDARD="${CXX_STANDARD}" ..
  fi
  make testMongo VERBOSE=1
else
  if [ "$CXX_STANDARD" = "17" ]; then
    "$CMAKE" -G "Visual Studio 15 2017 Win64" -DCMAKE_CXX_STANDARD="${CXX_STANDARD}" ..
  else
    # Boost is needed for pre-17 Windows polyfill.
    "$CMAKE" -G "Visual Studio 14 2015 Win64" -DCMAKE_CXX_STANDARD="${CXX_STANDARD}" -DBOOST_ROOT="${BOOST_DIR}" ..
  fi

  if [[ -z ${CONNECTION_URI} ]]; then
    "$CMAKE" --build . --target run --config "${BUILD_TYPE}"
  else
    "$CMAKE" -DCONNECTION_URI="${CONNECTION_URI}" --build . --target run --config "${BUILD_TYPE}"
  fi
fi
