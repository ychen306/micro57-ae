#!/usr/bin/env bash
set -e

curl -L https://github.com/llvm/llvm-project/archive/refs/tags/llvmorg-15.0.6.tar.gz -o llvm.tar.gz

JOBS=$1
if ! [[ $1 =~ ^[0-9]+$ ]]
then
    JOBS=4
fi

echo Building using $JOBS cores

tar -xvf llvm.tar.gz
mv llvm-project-llvmorg-15.0.6/ llvm-15
cd llvm-15
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release\
  -DLLVM_ENABLE_ASSERTIONS=On\
  -DLLVM_TARGETS_TO_BUILD=X86\
  -DLLVM_ENABLE_PROJECTS='clang'\
  -DLLVM_ENABLE_TERMINFO=OFF\
  ../llvm
make -j$JOBS
