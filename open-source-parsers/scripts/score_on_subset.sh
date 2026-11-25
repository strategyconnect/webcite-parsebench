#!/usr/bin/env bash
# Score one system's published outputs (results/<pipeline> folder from llamaindex/ParseBench-2-results)
# on the subset only, with the same harness used for the open-source parser runs.
# usage: score_on_subset.sh <parsebench_checkout> <results/<pipeline> dir> <explode.py> <subset_input_dir> <out_dir>
set -euo pipefail
abs() { (cd "$1" && pwd); }
PB=$(abs "$1"); RES=$(abs "$2"); EXPLODE=$(abs "$(dirname "$3")")/$(basename "$3"); IN=$(abs "$4"); mkdir -p "$5"; OUT=$(abs "$5")
P=$(basename "$RES")
rm -rf "$OUT/$P"; mkdir -p "$OUT/$P"
python3 -I "$EXPLODE" --benchmark parsebench-2 "$RES" "$OUT/$P/exploded" > /dev/null
parts=""
for s in $(ls "$IN"); do parts="$parts,$s=$OUT/$P/exploded/$s/$P::$IN/$s"; done
cd "$PB"
.venv/bin/parse-bench evaluation run "$OUT/$P/exploded" "--next=${parts#,}" --next_only --max_workers 2 \
  --report_dir "$OUT/$P/score" --export_html False --export_csv False --export_markdown False \
  --export_rule_csv False --force > "$OUT/$P/evaluation.log" 2>&1
rm -rf "$OUT/$P/exploded"
python3 -c "import json,sys;d=json.load(open(sys.argv[1]));print(sys.argv[2], round(100*d['next_score'],2))" \
  "$OUT/$P/score/_next_score.json" "$P"
