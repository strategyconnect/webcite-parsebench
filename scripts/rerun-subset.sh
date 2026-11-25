#!/usr/bin/env bash
# Rerun Webcite inference on ParseBench 2 subsets with YOUR OWN Webcite API key, then score them.
# This uses credits on your Webcite account.
#
# usage: WEBCITE_API_KEY=... scripts/rerun-subset.sh <subset[,subset...]> [work_dir]
# example: WEBCITE_API_KEY=... scripts/rerun-subset.sh headings
set -euo pipefail
: "${WEBCITE_API_KEY:?set WEBCITE_API_KEY to your own key from the Webcite dashboard}"
HERE=$(cd "$(dirname "$0")/.." && pwd)
GROUP=$1
WORK=$(mkdir -p "${2:-$HERE/work-rerun}" && cd "${2:-$HERE/work-rerun}" && pwd)
# The pipeline as submitted: head of the pull request branch (run-llama/ParseBench#309).
PR_REPO=https://github.com/Devstrategyconnect/ParseBench.git
PR_COMMIT=7233614de9f518c78ca50b1656be5880f662032e
PB=$WORK/ParseBench
[ -d "$PB/.git" ] || git clone -q "$PR_REPO" "$PB"
git -C "$PB" fetch -q origin "$PR_COMMIT" 2>/dev/null || git -C "$PB" fetch -q origin add-webcite
git -C "$PB" checkout -q "$PR_COMMIT"
cd "$PB"
uv sync -q
printf 'WEBCITE_API_KEY=%s\n' "$WEBCITE_API_KEY" > .env
chmod 600 .env
# Downloads ParseBench-2 (documents included) on first use, runs inference on the chosen subsets, scores.
uv run parse-bench run webcite --dataset parsebench-2 --group "$GROUP" --max_concurrent 4 --open_report False
echo "Scores: $PB/output/parsebench-2/_score/webcite/_next_score.json"
echo "Only the subsets you ran are scored; dimensions that need other subsets are reported missing."
