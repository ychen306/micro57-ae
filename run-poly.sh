#!/usr/bin/env bash
set -e

# Set this to how many times you want to repeat the runs
REPS=3

PSSA_PATH=$1
LLVM_PATH=$2
if ! (echo 'int main() {return 0;}' | $1/vegen-clang -x c - -o /dev/null) ||\
  ! (echo 'int main() {return 0;}' | $2/bin/clang -x c - -o /dev/null)
then
  echo "Usage: ./run-poly.sh <path to pssa's build directory> <path to llvm-15's build directory>"
  exit 1
fi

OUR_CLANG=$PSSA_PATH/vegen-clang
CLANG=$LLVM_PATH/bin/clang

curl -L https://sourceforge.net/projects/polybench/files/polybench-c-4.2.tar.gz/download -o polybench.tar.gz
tar -xvf polybench.tar.gz

perl polybench-c-4.2/utilities/makefile-gen.pl polybench-c-4.2
rm -f polybench-c-4.2/config.mk

# Build with clang w/o vectorization
cp -r polybench-c-4.2 pb-scalar
echo 'CFLAGS=-O3 -ffast-math -march=native -DPOLYBENCH_TIME -fno-vectorize -fno-slp-vectorize'\
    >> pb-scalar/config.mk
echo "CC=$CLANG" >> pb-scalar/config.mk

# Build with clang *with* vectorization
cp -r polybench-c-4.2 pb-clang
echo 'CFLAGS=-O3 -ffast-math -march=native -DPOLYBENCH_TIME' >> pb-clang/config.mk
echo "CC=$CLANG" >> pb-clang/config.mk

# Build with super vectorizer *with versioning*
cp -r polybench-c-4.2 pb-ours
echo 'CFLAGS=-O3 -ffast-math -march=native -DPOLYBENCH_TIME -mllvm -unroll-loops -mllvm -do-versioning'\
    >> pb-ours/config.mk
echo "CC=$OUR_CLANG" >> pb-ours/config.mk

# Build with super vectorizer *without versioning*
cp -r polybench-c-4.2 pb-ours-nover
echo 'CFLAGS=-O3 -ffast-math -march=native -DPOLYBENCH_TIME -mllvm -unroll-loops'\
    >> pb-ours-nover/config.mk
echo "CC=$OUR_CLANG" >> pb-ours-nover/config.mk

# Build with clang (with vectorization) and restrict
cp -r polybench-c-4.2 pb-clang-restrict
echo 'CFLAGS=-O3 -ffast-math -march=native -DPOLYBENCH_TIME -DPOLYBENCH_USE_RESTRICT'\
    >> pb-clang-restrict/config.mk
echo "CC=$CLANG" >> pb-clang-restrict/config.mk

# Build with super vectorizer with versioning and restrict
cp -r polybench-c-4.2 pb-ours-restrict
echo 'CFLAGS=-O3 -ffast-math -march=native -DPOLYBENCH_TIME -DPOLYBENCH_USE_RESTRICT -mllvm -unroll-loops -mllvm -do-versioning'\
    >> pb-ours-restrict/config.mk
echo "CC=$OUR_CLANG" >> pb-ours-restrict/config.mk

# Build with super vectorizer without versioning and restrict
cp -r polybench-c-4.2 pb-ours-nover-restrict
echo 'CFLAGS=-O3 -ffast-math -march=native -DPOLYBENCH_TIME -DPOLYBENCH_USE_RESTRICT -mllvm -unroll-loops'\
    >> pb-ours-nover-restrict/config.mk
echo "CC=$OUR_CLANG" >> pb-ours-nover-restrict/config.mk

python3 run-polybench.py $REPS pb-scalar pb.scalar.txt
python3 run-polybench.py $REPS pb-clang pb.clang.txt
python3 run-polybench.py $REPS pb-ours pb.ours.txt
python3 run-polybench.py $REPS pb-ours-nover pb.ours-nover.txt

python3 run-polybench.py $REPS pb-clang-restrict pb.clang-restrict.txt
python3 run-polybench.py $REPS pb-ours-restrict pb.ours-restrict.txt
python3 run-polybench.py $REPS pb-ours-nover-restrict pb.ours-nover-restrict.txt
