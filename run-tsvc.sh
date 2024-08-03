#!/usr/bin/env bash

PSSA_PATH=$1
LLVM_PATH=$2
if ! (echo 'int main() {return 0;}' | $1/vegen-clang -x c - -o /dev/null) ||\
  ! (echo 'int main() {return 0;}' | $2/bin/clang -x c - -o /dev/null)
then
  echo "Usage: ./run-tsvc.sh <path to pssa's build directory> <path to llvm-15's build directory>"
  exit 1
fi

OUR_CLANG=$PSSA_PATH/vegen-clang
CLANG=$LLVM_PATH/bin/clang

git clone https://github.com/ychen306/tsvc
cd tsvc

# build with clang -O3
make clean
make CC=$CLANG vecflags='-fno-unroll-loops'
cp runvec tsvc.clang

# build with super vectorizer without versioning
make clean
make CC=$OUR_CLANG vecflags='-mllvm -unroll-loops'
cp runvec tsvc.ours-nover

# build with super vectorizr + versioning
make clean
make CC=$OUR_CLANG vecflags='-mllvm -unroll-loops -mllvm -do-versioning'
cp runvec tsvc.ours

# run the generated binaries
echo Running tsvc built with clang
./tsvc.clang > results.clang.txt
echo Running tsvc built with super-vectorizer
./tsvc.ours-nover > results.ours-nover.txt
echo Running tsvc built with super-vectorizer and versioning
./tsvc.ours > results.ours.txt
