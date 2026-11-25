# Webcite on ParseBench 2: reproduction

Webcite scored **91.74 overall** on [ParseBench 2](https://github.com/run-llama/ParseBench) in its own full run, the highest overall score against the leaderboard entries as of 20 November 2026 (run-llama/ParseBench commit `1908f9a`).

Webcite's leaderboard row is proposed in the open pull request [run-llama/ParseBench#309](https://github.com/run-llama/ParseBench/pull/309). The per-document outputs are public, so anyone can re-score them.

This repository holds what a third party needs to check the number:

- **Re-score** (free, no key, no API calls): download Webcite's published per-document outputs and score them with the pinned ParseBench scorer and dataset. Expected result: 91.74 within the benchmark's ±0.5 point tolerance.
- **Rerun** (your own key): send ParseBench 2 documents through Webcite's public API with the pipeline as submitted, and score them.
- **Open-source parsers** (separate, in [`open-source-parsers/`](open-source-parsers/)): Docling, MarkItDown and Unstructured run locally through the same harness, with raw outputs and exact commands, so their numbers can be checked too.

## Pinned versions

| What | Pin |
|---|---|
| ParseBench harness and scorer | [`c21adae`](https://github.com/run-llama/ParseBench/commit/c21adae59f7f2ef3e8690387a0413a2e4d274486) (release parse-bench 2.1.2) |
| ParseBench-2 dataset | `llamaindex/ParseBench-2` revision [`f0757ac9`](https://huggingface.co/datasets/llamaindex/ParseBench-2/tree/f0757ac998ef9eb9c3c346ef170fee175b6a7d75) |
| Webcite's published outputs | `llamaindex/ParseBench-2-results` [discussion 14](https://huggingface.co/datasets/llamaindex/ParseBench-2-results/discussions/14), revision `906642365c8dbf0895ac7f866a3685910d6891c4`, folder `results/webcite/` |
| Webcite provider adapter | [`adapter/webcite-at-c21adae.patch`](adapter/webcite-at-c21adae.patch): commit `543ca580` of the pull request branch, whose parent is `c21adae` |

All pins are in [`pins.env`](pins.env).

## Re-score the published outputs

Needs `git`, [`uv`](https://docs.astral.sh/uv/), `python3` and about 2 GB of disk. No API key.

```bash
git clone https://github.com/strategyconnect/webcite-parsebench.git
cd webcite-parsebench
scripts/rescore.sh            # work files go to ./work
```

The script:

1. clones ParseBench at `c21adae` and applies the Webcite adapter patch (scoring code and ground-truth loader unchanged);
2. downloads the dataset's ground truth (`*.test.json` and the `.md` expected-text files) at revision `f0757ac9`, and Webcite's outputs at the pinned revision;
3. unpacks the outputs with the results repository's own `tools/explode.py`;
4. scores all 13 subsets with `parse-bench evaluation run --next ... --next_only`;
5. compares the six dimensions and the overall score with [`expected/webcite.json`](expected/webcite.json) and prints PASS or FAIL at ±0.5 points, the tolerance ParseBench's leaderboard check uses.

Hugging Face limits anonymous file downloads per five minutes; if the download is rate limited the script waits and resumes.

### Result on a clean machine

On 25 November 2026 a fresh clone of this repository was run with an empty home directory, cache and Python install (`env -i`, uv 0.9.28, system Python 3.9.6, git 2.50.1). Output of step 5:

```
dimension           expected  re-score    diff
text                   91.43     91.23   -0.20
formatting             92.69     92.53   -0.16
tables                 95.21     95.21   +0.00
charts                 93.05     93.05   +0.00
visual_grounding       87.69     87.69   +0.00
forms                  90.38     90.38   +0.00
overall                91.74     91.68   -0.06
mean of the six re-scored dimensions: 91.6817
tolerance: +/-0.5 points -> PASS
```

Text and formatting come out 0.20 and 0.16 points below the published row, inside the tolerance; the overall score is 91.68 against 91.74.

## The expected numbers

| Dimension | Score |
|---|---:|
| Text | 91.43 |
| Formatting | 92.69 |
| Tables | 95.21 |
| Charts | 93.05 |
| Visual grounding | 87.69 |
| Forms | 90.38 |
| **Overall** | **91.74** |

Overall is the unweighted mean of the six dimensions (`parse_bench/evaluation/next_score.py`):

(91.43 + 92.69 + 95.21 + 93.05 + 87.69 + 90.38) / 6 = 550.45 / 6 = 91.7417, shown as 91.74.

Each dimension is a weighted mean over subsets; the weights are in the same file.

## The failed document

The run covers **4,316 of 4,317 documents**. `dense_tables/dense_table_155` returned an error from the API on every attempt, so it has no output. It is listed in [`failed.json`](failed.json) and, as the benchmark requires, scored as zero. It is included in every number above.

## Later re-scores

ParseBench and its dataset changed after the run. On 24 November 2026 the pull request was re-scored against ParseBench `52aba2a` and dataset revision `2e954075`, giving 91.80 overall; the repository's check of the published outputs at `52aba2a` gave 91.82. This repository pins the earlier versions because they are the ones behind the 91.74 figure. Reads vary by about half a point per dimension between runs, so an independent rerun will not match to the second decimal.

## Rerun inference with your own key

This uses credits on your Webcite account. Create a key in the Webcite dashboard, then:

```bash
WEBCITE_API_KEY=... scripts/rerun-subset.sh headings          # one subset
WEBCITE_API_KEY=... scripts/rerun-subset.sh charts,tables       # several
```

It checks out the pull request branch at `7233614d` (the pipeline as submitted: upload each document unchanged, then extract with `mode: "standard"`), downloads ParseBench-2, runs the chosen subsets and scores them. The full run used `--max_concurrent 8`; the script uses 4.

Scoring a subset on its own gives only the dimensions that subset feeds; the overall score needs all 13.

## Contents

```
pins.env                          every version the re-score depends on
adapter/webcite-at-c21adae.patch  the Webcite provider as first submitted (applies to c21adae)
adapter/pr309-head-at-52aba2a.patch  the provider at the head of PR 309 (adds the mode option)
adapter/webcite.py                the provider file at the head of PR 309, for reading
expected/webcite.json             the published row
failed.json                       the one document with no output
scripts/rescore.sh                re-score, no key
scripts/check.py                  compare a score file with the published row
scripts/rerun-subset.sh           rerun inference with your own key
open-source-parsers/              local runs of open-source parsers on ParseBench 2
CHANGELOG.md                      every run and re-score
```

## Licence

MIT for the files in this repository. The adapter patches modify ParseBench, which is Apache-2.0. ParseBench-2 is published by LlamaIndex under Apache-2.0.

Questions or corrections: open an issue, or write to support@webcite.co.
