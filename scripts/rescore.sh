#!/usr/bin/env bash
# Re-score Webcite's published ParseBench 2 outputs with the pinned harness and dataset.
# No API key and no paid calls: it downloads public files and runs the open scorer locally.
#
# usage: scripts/rescore.sh [work_dir] [eval_workers]
# needs: git, uv (https://docs.astral.sh/uv/), python3 (3.9+), about 2 GB of disk. uv provides Python 3.12 for the harness.
set -euo pipefail
HERE=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mkdir -p "${1:-$HERE/work}" && cd "${1:-$HERE/work}" && pwd)
WORKERS=${2:-2}
# shellcheck source=/dev/null
source "$HERE/pins.env"
PB=$WORK/ParseBench

echo "== 1. ParseBench at $PARSEBENCH_COMMIT with the Webcite adapter"
if [ ! -d "$PB/.git" ]; then
  git clone -q "$PARSEBENCH_REPO" "$PB"
fi
git -C "$PB" checkout -q "$PARSEBENCH_COMMIT"
if ! git -C "$PB" apply --check --reverse "$HERE/adapter/webcite-at-c21adae.patch" 2>/dev/null; then
  git -C "$PB" apply "$HERE/adapter/webcite-at-c21adae.patch"
fi
(cd "$PB" && uv sync -q --python 3.12)

echo "== 2. Dataset $DATASET_REPO@$DATASET_REVISION and outputs $RESULTS_REPO@$RESULTS_REVISION"
# Scoring needs only the ground truth (*.test.json and the .md expected-text sidecars), not the PDFs.
# Hugging Face limits anonymous file lookups per 5 minutes, so a rate-limited download waits and resumes.
export HF_HUB_DISABLE_PROGRESS_BARS=1
for attempt in 1 2 3 4 5 6; do
  if (cd "$PB" && uv run --python 3.12 python - "$WORK" <<PY
import sys
from huggingface_hub import snapshot_download
work = sys.argv[1]
snapshot_download("$DATASET_REPO", repo_type="dataset", revision="$DATASET_REVISION",
                  local_dir=f"{work}/data", allow_patterns=["*/*.test.json", "*/*.md", "README.md"])
snapshot_download("$RESULTS_REPO", repo_type="dataset", revision="$RESULTS_REVISION",
                  local_dir=f"{work}/results",
                  allow_patterns=["results/$RESULTS_PIPELINE/*", "tools/*"])
PY
  ); then break; fi
  [ "$attempt" = 6 ] && { echo "download failed after 6 attempts" >&2; exit 1; }
  echo "download interrupted (attempt $attempt); waiting 5 minutes, then resuming" >&2
  sleep 300
done
n=$(find "$WORK/data" -name '*.test.json' -not -path '*/.cache/*' | wc -l | tr -d ' ')
echo "ground-truth files: $n"

echo "== 3. Unpack the published outputs into the harness layout"
OUT=$WORK/output
rm -rf "$OUT"
python3 -I "$WORK/results/tools/explode.py" --benchmark parsebench-2 \
  "$WORK/results/results/$RESULTS_PIPELINE" "$OUT" > /dev/null
echo "failed documents listed by the submission:"
cat "$WORK/results/results/$RESULTS_PIPELINE/failed.json"; echo

echo "== 4. Score all 13 subsets with the unmodified scorer"
SUBSETS="text headings strikeout underline tables complex_table_headers financial_tables insurance_filing_tables dense_tables charts layout forms fillable_forms"
parts=""
for s in $SUBSETS; do parts="$parts,$s=$OUT/$s/$RESULTS_PIPELINE::$WORK/data/$s"; done
REPORT=$WORK/score
(cd "$PB" && uv run --python 3.12 parse-bench evaluation run "$OUT" "--next=${parts#,}" --next_only \
  --max_workers "$WORKERS" --report_dir "$REPORT" --export_html False --export_csv False \
  --export_markdown False --export_rule_csv False --force > "$WORK/evaluation.log" 2>&1)

echo "== 5. Compare with the published row"
python3 -I "$HERE/scripts/check.py" "$REPORT/_next_score.json" "$HERE/expected/webcite.json" "$TOLERANCE"
