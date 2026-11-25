# Changelog

Every Webcite run and re-score of ParseBench 2 recorded in this repository.

## 2026-11-25

- Repository published. Re-score of the published outputs (discussion 14, revision `906642365c`) with ParseBench `c21adae` plus the adapter, dataset `f0757ac9`: 91.68 overall against the published 91.74 (text 91.23 against 91.43, formatting 92.53 against 92.69, the other four dimensions identical). Within the ±0.5 point tolerance.
- Open-source parser runs added under `open-source-parsers/` (see its README).

## 2026-11-24

- Pull request 309 re-scored with ParseBench `52aba2a` and dataset `2e954075`: 91.80 overall. The repository's automated check of the published outputs at `52aba2a` (base branch, without the Webcite adapter): 91.82, "Result: pass".

## 2026-11-19 to 2026-11-20

- `Webcite (Lite)` (pipeline `webcite_lite`, mode "lite") run on 4,312 of 4,317 documents: 88.75 overall. Outputs: [discussion 18](https://huggingface.co/datasets/llamaindex/ParseBench-2-results/discussions/18).

## 2026-11-18

- Full run of the `webcite` pipeline (mode "standard") on 4,316 of 4,317 documents; `dense_tables/dense_table_155` failed and scores zero. Published row: 91.74 overall (ParseBench `c21adae`, dataset `f0757ac9`). Outputs: [discussion 14](https://huggingface.co/datasets/llamaindex/ParseBench-2-results/discussions/14).
