#!/usr/bin/env bash
# Run one ParseBench pipeline over an input folder with the benchmark's own CLI, one document at a time,
# stopped after a wall-clock cap (seconds). The CLI skips documents that already have a result, so a
# stopped run resumes. Score: <output_dir>/parsebench-2/_score/<pipeline>/_next_score.json
# usage: run_parser.sh <parsebench_checkout> <pipeline> <input_dir> <output_dir> <cap_seconds>
set -euo pipefail
PB=$1; PIPE=$2; IN=$3; OUT=$4; CAP=$5
mkdir -p "$OUT"
start=$(date +%s)
cd "$PB"
perl -e 'alarm shift; exec @ARGV' "$CAP" .venv/bin/parse-bench run "$PIPE" --dataset parsebench-2 \
  --input_dir "$IN" --output_dir "$OUT" --max_concurrent 1 --open_report False || echo "run ended with $? (a cap stop is 142)"
echo "wall_seconds=$(( $(date +%s) - start ))"
echo "results=$(find "$OUT" -name '*.result.json' | wc -l | tr -d ' ')"
