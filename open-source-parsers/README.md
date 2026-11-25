# Open-source parsers on ParseBench 2

Local runs of open-source document parsers through ParseBench's own harness, with raw outputs and exact commands, so that anyone can check the numbers. Webcite publishes this and makes one of the products compared. Webcite's rows come from its published outputs, scored with the same harness, dataset and command as the local runs.

## Full runs (all 4,317 documents)

| System | Source | Documents with output | Overall | Text | Formatting | Tables | Charts | Visual grounding | Forms |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Webcite | published outputs | 4,316 | 91.85 | 91.63 | 92.70 | 95.24 | 93.33 | 87.80 | 90.38 |
| MarkItDown | local run | 4,316 | 32.17 | 53.96 | 56.91 | 11.66 | 0.41 | 0.00 | 70.06 |
| Unstructured (fast strategy) | local run | 4,296 | 30.52 | 54.78 | 56.84 | 0.10 | 0.00 | 0.00 | 71.39 |

A document without output scores zero, as the benchmark requires. MarkItDown failed on `dense_tables/dense_table_168` (RecursionError); Unstructured's `fast` strategy rejected the 21 layout documents that are images; Webcite's run has no output for `dense_tables/dense_table_155`.

Webcite's 91.85 here differs from its published 91.74 because this table uses the newer harness (`63e926f`) and dataset revision (`92a52df6`); the [reproduction](../README.md) pins the versions behind 91.74.

## Subset runs (305 documents)

Docling took about 11 seconds a document on this machine (CPU only), about 13 hours for the full set, so it ran on a seeded subset. The subset table also scores MarkItDown, Unstructured, Webcite and five commercial parsers' published outputs on the same 305 documents. **These are subset scores, not leaderboard scores, and not estimates of full-run scores.**

| System | Source | Overall | Text | Formatting | Tables | Charts | Visual grounding | Forms |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| Webcite | published outputs | 92.41 | 89.33 | 93.72 | 97.88 | 92.89 | 89.57 | 91.11 |
| LlamaParse (Agentic Plus) | published outputs | 91.72 | 90.02 | 93.40 | 95.18 | 93.88 | 88.39 | 89.43 |
| Reducto (r-1) | published outputs | 87.21 | 81.47 | 92.89 | 95.25 | 77.89 | 90.22 | 85.53 |
| Extend (Parse 2) | published outputs | 85.84 | 81.07 | 87.57 | 89.16 | 86.50 | 82.36 | 88.36 |
| Datalab (Accurate) | published outputs | 84.63 | 89.95 | 92.97 | 93.51 | 67.49 | 81.24 | 82.63 |
| PaddleOCR-VL 1.6 | published outputs | 72.56 | 71.74 | 81.70 | 78.60 | 58.92 | 71.93 | 72.45 |
| Docling | local run | 59.52 | 60.99 | 76.45 | 66.21 | 0.00 | 80.01 | 73.45 |
| MarkItDown | local run | 32.93 | 53.69 | 58.09 | 16.06 | 0.76 | 0.00 | 68.99 |
| Unstructured (fast strategy) | local run | 30.39 | 53.50 | 59.04 | 0.00 | 0.00 | 0.00 | 69.78 |

Webcite has the highest subset overall score, but not every dimension: LlamaParse (Agentic Plus) and Datalab (Accurate) score higher on text, LlamaParse on charts, and Reducto (r-1) on visual grounding. Docling's charts score is zero because it returns charts as images, not as data.

## What was run

| Parser | Version and settings | Licence |
|---|---|---|
| Docling | docling-serve 1.39.0 (docling-slim 2.152.0, docling-core 2.108.0), default settings, automatic OCR (RapidOCR on torch), harness pipeline `docling_serve` | MIT |
| MarkItDown | markitdown 0.1.9 with the `pdf` extra, harness pipeline `markitdown` | MIT |
| Unstructured | unstructured 0.22.18 behind a local unstructured-api 0.1.16, strategy `fast`, harness pipeline `unstructured_fast` | Apache-2.0 |

Not run:

- **Marker.** Its code is Apache-2.0, but its model weights use a modified AI Pubs Open RAIL-M licence ([MODEL_LICENSE](https://github.com/datalab-to/marker/blob/master/MODEL_LICENSE)) whose Attachment A, clause 2(c), forbids use by anyone who "provides or otherwise makes available any product or service that competes with any product or service offered by or made available by Licensor". Webcite sells a document parsing API, so it did not run Marker. Datalab's hosted API has its own leaderboard rows.
- **Docling on the full set**: see above.
- **Unstructured `hi_res`**: it needs Tesseract, which this machine does not have. `fast` reads a PDF's embedded text with no OCR or layout model, so it is not Unstructured's most accurate mode.

None of these parsers had a ParseBench 2 leaderboard row on 25 November 2026 (`leaderboard-v2.csv` at run-llama/ParseBench `63e926f`).

## The subset

[`subset.json`](subset.json) lists the 305 documents, drawn by [`scripts/make_subset.py`](scripts/make_subset.py) with `random.Random(20261125)`. Each of the 13 subsets gets documents in proportion to its weight in the overall score, at least 6; within a subset the draw is uniform over the sorted case ids. No system's scores were used to choose documents.

| Subset | In the subset | In the benchmark |
|---|---:|---:|
| text | 88 | 507 |
| headings | 6 | 100 |
| strikeout | 6 | 128 |
| underline | 6 | 125 |
| tables | 25 | 500 |
| complex_table_headers | 6 | 149 |
| financial_tables | 6 | 319 |
| insurance_filing_tables | 6 | 412 |
| dense_tables | 6 | 373 |
| charts | 50 | 568 |
| layout | 50 | 535 |
| forms | 44 | 500 |
| fillable_forms | 6 | 100 |

The harness evaluates `text/text_simple__1colmit` twice (89 text results for 88 documents). This applies to every system equally.

## Versions

- Harness and scorer: run-llama/ParseBench `63e926f` (main on 25 November 2026), unmodified.
- Dataset: `llamaindex/ParseBench-2` revision `92a52df63fa75aa8bd05cce2214d7fe0a2bcb738`.
- Published outputs: `llamaindex/ParseBench-2-results` main at `497e243f`, and discussion 14 (revision `906642365c`) for Webcite, unpacked with that repository's `tools/explode.py`. The harness at `63e926f` has no Webcite layout adapter, so Webcite's visual grounding is scored through the harness's fallback.
- Machine: Apple Silicon Mac, CPU only, one document at a time. Runs on 25 November 2026.

## Reproduce

```bash
git clone https://github.com/run-llama/ParseBench.git && (cd ParseBench && git checkout 63e926f && uv sync \
  && uv pip install "llama-cloud>=1.4.1" "docling-core>=2.71.0" httpx "markitdown[pdf]" "unstructured-client>=0.26.0")
# Full dataset at the pinned revision
ParseBench/.venv/bin/python -c "from huggingface_hub import snapshot_download as s; s('llamaindex/ParseBench-2', repo_type='dataset', revision='92a52df63fa75aa8bd05cce2214d7fe0a2bcb738', local_dir='pb2')"
# Subset
ParseBench/.venv/bin/python open-source-parsers/scripts/make_subset.py pb2-subset
python3 open-source-parsers/scripts/link_cases.py open-source-parsers/subset.json pb2-subset subset305

# MarkItDown, full set (wall-clock cap in seconds as the last argument)
open-source-parsers/scripts/run_parser.sh ParseBench markitdown "$PWD/pb2" "$PWD/runs/markitdown" 10800

# Unstructured fast: start a local unstructured-api (https://github.com/Unstructured-IO/unstructured-api) on port 5012, then
UNSTRUCTURED_API_KEY=local-no-key UNSTRUCTURED_API_URL=http://127.0.0.1:5012 \
  open-source-parsers/scripts/run_parser.sh ParseBench unstructured_fast "$PWD/pb2" "$PWD/runs/unstructured_fast" 14400

# Docling: start docling-serve 1.39.0 on port 5011 (docling-serve run --port 5011), then run the subset
DOCLING_SERVE_ENDPOINT_URL=http://127.0.0.1:5011 \
  open-source-parsers/scripts/run_parser.sh ParseBench docling_serve "$PWD/subset305" "$PWD/runs/docling_serve" 7200

# Score a local run on the subset, and score published outputs on the subset
open-source-parsers/scripts/score_run.sh ParseBench runs/markitdown markitdown subset305 scores/markitdown
open-source-parsers/scripts/score_on_subset.sh ParseBench <results/pipeline folder> <ParseBench-2-results>/tools/explode.py subset305 scores
```

`run_parser.sh` writes the full-run score to `<output>/parsebench-2/_score/<pipeline>/_next_score.json`.

## Files

- `results/comparison.json`: both tables with versions, dates and the subset definition, for citing.
- `results/full/<pipeline>.json`, `results/subset/<pipeline>.json`: the harness's score files.
- `outputs/<pipeline>.tar.gz`: every per-document result the harness wrote for the local runs, and its error lists.

## Licences

ParseBench code and the ParseBench-2 dataset are Apache-2.0; the dataset card says the documents come from public online channels. The outputs here derive from those documents and are shared under the same licence. Nothing in the ParseBench repository or dataset card restricts running or publishing benchmark results.
