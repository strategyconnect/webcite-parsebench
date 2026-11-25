#!/usr/bin/env bash
# Re-score a local run (output of run_parser.sh) on the subset with the benchmark's scorer.
# usage: score_run.sh <parsebench_checkout> <run_output_dir> <pipeline> <subset_input_dir> <report_dir>
set -euo pipefail
abs() { (cd "$1" && pwd); }
PB=$(abs "$1"); RUN=$(abs "$2"); P=$3; IN=$(abs "$4"); mkdir -p "$5"; REP=$(abs "$5")
parts=""
for s in $(ls "$IN"); do parts="$parts,$s=$RUN/parsebench-2/$s/$P::$IN/$s"; done
cd "$PB"
.venv/bin/parse-bench evaluation run "$RUN/parsebench-2" "--next=${parts#,}" --next_only --max_workers 2 \
  --report_dir "$REP" --export_html False --export_csv False --export_markdown False \
  --export_rule_csv False --force > "$REP/evaluation.log" 2>&1
python3 -c "import json,sys;d=json.load(open(sys.argv[1]));print(sys.argv[2], d['next_score'] and round(100*d['next_score'],2), d.get('missing_dimensions'))" "$REP/_next_score.json" "$P"
