#!/usr/bin/env bash
set -e

if ! (echo 'int main() {return 0;}' | $1/bin/clang -x c - -o /dev/null)
then
    echo "Usage: ./run-tsvc.sh <path to llvm-15's build directory> [optionally, number of cores to use]"
    exit 1
fi

abspath() {
    cd "$(dirname "$1")"
    printf "%s/%s\n" "$(pwd)" "$(basename "$1")"
    cd "$OLDPWD"
}

LLVM_PATH=$(abspath $1)

JOBS=$2
if ! [[ $2 =~ ^[0-9]+$ ]]
then
    JOBS=4
fi

echo "Compiling with $JOBS cores"

# Build OR Tools
curl -L https://github.com/google/or-tools/archive/refs/tags/v9.7.tar.gz -o or-tools.tar.gz
tar -xvf or-tools.tar.gz
OR_TOOLS_BUILD_PATH="$(abspath or-tools-9.7)/install_make"
cd or-tools-9.7
echo Building or-tools at $OR_TOOLS_BUILD_PATH
make cpp JOBS=$JOBS
cd -

# Build super vectorizer
git clone https://github.com/ychen306/pssa
cd pssa
git checkout micro57-ae
mkdir build
echo Building super-vectorizer at $(abspath build)$
cd build
cmake -DCMAKE_BUILD_TYPE=Release\
  -DCMAKE_PREFIX_PATH="$LLVM_PATH;$OR_TOOLS_BUILD_PATH"\
  -DCMAKE_CXX_FLAGS="-fpermissive"\
  ../
make -j$JOBS
cd ../
