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

# Build super vectorizer
PSSA_PATH=$(abspath pssa/build)
export PATH=$LLVM_PATH/bin:$PATH

# Build and run PolyBench and TSVC
./run-poly.sh $PSSA_PATH $LLVM_PATH
./run-tsvc.sh $PSSA_PATH $LLVM_PATH

# Get polybench speedup (Figure 17)
#### Figure 17, top subfigure; i.e., without restrict
# Speedup of clang w/ vectorization vs scalar clang
python3 get-polybench-speedup.py pb.scalar.txt pb.clang.txt > pb-speedup.clang.txt
# Speedup of super vectorizer w/o versioning vs scalar clang
python3 get-polybench-speedup.py pb.scalar.txt pb.ours-nover.txt > pb-speedup.ours-nover.txt
# Speedup of super vectorizer w/ versioning vs scalar clang
python3 get-polybench-speedup.py pb.scalar.txt pb.ours.txt > pb-speedup.ours.txt
####
#### Figure 17, bottom subfigure; i.e., w/ restrict
# Speedup of clang w/ vectorization + restrict vs scalar clang
python3 get-polybench-speedup.py pb.scalar.txt pb.clang-restrict.txt > pb-speedup.clang-restrict.txt
# Speedup of super vectorizer w/o versioning + restrict vs scalar clang
python3 get-polybench-speedup.py pb.scalar.txt pb.ours-nover-restrict.txt > pb-speedup.ours-nover-restrict.txt
# Speedup of super vectorizer w/ versioning + restrict vs scalar clang
python3 get-polybench-speedup.py pb.scalar.txt pb.ours-restrict.txt > pb-speedup.ours-restrict.txt
####

# Get TSVC speedups
#### Figure 19
# Speedup of super vectorizer w/o versioning over clang's vectorizers
python3 compare-tsvc.py tsvc/results.clang.txt tsvc/results.ours-nover.txt > tsvc-speedup.ours-nover.txt
# Speedup of super vectorizer w/ versioning over clang's vectorizers
python3 compare-tsvc.py tsvc/results.clang.txt tsvc/results.ours.txt > tsvc-speedup.ours.txt
# Speedup of super vectorizer w/ versioning vs w/o versioning
python3 compare-tsvc.py tsvc/results.ours-nover.txt tsvc/results.ours.txt > tsvc-speedup.ver.txt
####
