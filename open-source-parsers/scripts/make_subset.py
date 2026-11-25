#!/usr/bin/env python3
"""Draw the seeded, stratified ParseBench 2 subset used for the open-source parser runs and download it.

Allocation: each of the 13 subsets gets documents in proportion to its weight in the Overall score
(parse_bench.evaluation.next_score), at least 6, about 300 in total. Within a subset, documents are drawn
uniformly at random from the sorted case ids with random.Random(SEED). No system's scores are used.

usage: make_subset.py <data_dir> [subset.json]
Run with the ParseBench virtualenv's python (it needs huggingface_hub).
"""

import json
import random
import sys
from pathlib import Path

from huggingface_hub import HfApi, snapshot_download

REPO, REVISION, SEED, TOTAL, MINIMUM = (
    "llamaindex/ParseBench-2", "92a52df63fa75aa8bd05cce2214d7fe0a2bcb738", 20261125, 300, 6)
# Weight of each subset in Overall: sum of its slot weights in next_score.py, divided by six dimensions.
WEIGHT = {"text": 1.75, "headings": 0.125, "strikeout": 0.0625, "underline": 0.0625, "tables": 0.5,
          "complex_table_headers": 0.125, "financial_tables": 0.125, "insurance_filing_tables": 0.125,
          "dense_tables": 0.125, "charts": 1.0, "layout": 1.0, "forms": 0.875, "fillable_forms": 0.125}
SKIPPED = {"text/text_sparse__anex"}  # never scored by the harness


def main():
    data_dir = Path(sys.argv[1])
    out = Path(sys.argv[2]) if len(sys.argv) > 2 else Path(__file__).resolve().parent.parent / "subset.json"
    files = HfApi().list_repo_files(REPO, repo_type="dataset", revision=REVISION)
    cases = {}
    for f in files:
        if f.endswith(".test.json") and f.count("/") == 1:
            cid = f[: -len(".test.json")]
            if cid not in SKIPPED:
                cases.setdefault(cid.split("/")[0], []).append(cid)
    rng = random.Random(SEED)
    chosen = {}
    for subset in WEIGHT:
        n = max(MINIMUM, round(TOTAL * WEIGHT[subset] / 6))
        chosen[subset] = sorted(rng.sample(sorted(cases[subset]), n))
    stems = {c for v in chosen.values() for c in v}
    patterns = [f for f in files if f.rsplit(".", 1)[0].replace(".test", "") in stems]
    snapshot_download(REPO, repo_type="dataset", revision=REVISION, local_dir=str(data_dir),
                      allow_patterns=patterns)
    summary = {"dataset": REPO, "revision": REVISION, "seed": SEED, "design": __doc__.split("\n\n")[1],
               "population": {s: len(cases[s]) for s in WEIGHT}, "sample": {s: len(v) for s, v in chosen.items()},
               "total": len(stems), "cases": chosen}
    out.write_text(json.dumps(summary, indent=1) + "\n")
    print(f"{len(stems)} documents, {len(patterns)} files -> {data_dir}; definition -> {out}")


if __name__ == "__main__":
    main()
