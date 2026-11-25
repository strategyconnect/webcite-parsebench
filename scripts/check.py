#!/usr/bin/env python3
"""Compare a ParseBench _next_score.json with expected/webcite.json.

usage: check.py <_next_score.json> <expected.json> [tolerance]
Prints each dimension, the mean of the six, and PASS or FAIL against the tolerance (points).
Standard library only.
"""

import json
import sys

KEYS = [("text", "text"), ("formatting", "formatting"), ("tables", "tables"),
        ("charts", "charts"), ("visual_grounding", "layout"), ("forms", "forms")]


def main() -> int:
    score = json.load(open(sys.argv[1]))
    expected = json.load(open(sys.argv[2]))
    tol = float(sys.argv[3]) if len(sys.argv) > 3 else 0.5
    dims = score["dimensions"]
    rows, ok = [], True
    for name, key in KEYS:
        got = round(100 * dims[key]["score"], 2)
        want = expected["dimensions"][name]
        diff = got - want
        ok &= abs(diff) <= tol
        rows.append((name, want, got, diff))
    mean6 = sum(r[2] for r in rows) / 6
    overall = round(100 * score["next_score"], 2)
    diff = overall - expected["overall"]
    ok &= abs(diff) <= tol
    print(f"{'dimension':<18}{'expected':>10}{'re-score':>10}{'diff':>8}")
    for name, want, got, d in rows:
        print(f"{name:<18}{want:>10.2f}{got:>10.2f}{d:>+8.2f}")
    print(f"{'overall':<18}{expected['overall']:>10.2f}{overall:>10.2f}{diff:>+8.2f}")
    print(f"mean of the six re-scored dimensions: {mean6:.4f}")
    print(f"tolerance: +/-{tol} points -> {'PASS' if ok else 'FAIL'}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
