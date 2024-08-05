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

./build-pssa.sh $LLVM_PATH $2

PSSA_PATH=$(abspath pssa/build)
export PATH=$PSSA_PATH:$PATH

./run-poly.sh $PSSA_PATH $LLVM_PATH
./run-tsvc.sh $PSSA_PATH $LLVM_PATH
