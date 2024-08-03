import sys
import functools


def parse(fname):
    with open(fname) as f:
        next(f)
        next(f)
        for line in f:
            bench, seconds, _ = line.strip().split()
            yield bench, float(seconds)


ref_f, test_f = sys.argv[1:]

results = [
    (bench, ref / test) for (bench, ref), (_, test) in zip(parse(ref_f), parse(test_f))
]
results.sort(key=lambda args: args[1])

sorted_bench = [bench for bench, speedup in results]
sorted_speedup = [speedup for bench, speedup in results]

for bench, speedup in results:
    print(bench, speedup)
print(
    "Geomean speedup:",
    functools.reduce(lambda a, b: a * b, sorted_speedup, 1)
    ** (1 / len(sorted_speedup)),
)
