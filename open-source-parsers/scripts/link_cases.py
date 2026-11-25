#!/usr/bin/env python3
"""Make an input folder holding only the chosen cases (symlinks), in the harness's subset layout.
usage: link_cases.py <subset.json> <data_dir> <out_dir> [--first N]   (--first: N cases, seeded, for timing)"""
import json, random, sys
from pathlib import Path
spec = json.load(open(sys.argv[1])); data, out = Path(sys.argv[2]), Path(sys.argv[3])
cases = [c for v in spec["cases"].values() for c in v]
if "--first" in sys.argv:
    cases = sorted(random.Random(spec["seed"]).sample(cases, int(sys.argv[sys.argv.index("--first") + 1])))
for cid in cases:
    stem = cid.split("/", 1)[1]
    for f in data.glob(cid.replace("[", "[[]") + ".*"):
        if f.name not in {stem + ext for ext in (".pdf", ".test.json", ".md", ".jpg", ".png")}:
            continue
        dst = out / f.relative_to(data); dst.parent.mkdir(parents=True, exist_ok=True)
        if not dst.exists(): dst.symlink_to(f.resolve())
print(len(cases), "cases ->", out)
