import sys
from collections import defaultdict

def median(xs):
    n = len(xs)
    xs.sort()
    mid = n // 2
    if n % 2 == 0:
        return sum(xs[mid-1:mid])//2
    return xs[mid]

def parse(fname):
    with open(fname) as f:
        timings = defaultdict(list)
        for line in f:
            bench, elapsed = line.split(",")
            timings[bench].append(float(elapsed))
        return timings


ref, test = sys.argv[1:]
ref_cycles = parse(ref)
test_cycles = parse(test)
product = 1
for bench in ref_cycles:
    speedup = median(ref_cycles[bench]) / median(test_cycles[bench])
    product *= speedup
    print(bench, speedup)
print("geomean", product ** (1 / len(ref_cycles)))
