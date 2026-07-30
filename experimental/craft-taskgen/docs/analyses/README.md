# Analyses

Frozen-in-time research writeups. These document what we found at a specific point — they are **not** runbooks and may go stale fast. Each filename is date-prefixed (`{mmm}{dd}-{topic}.md`) so chronological order matches `ls`.

| Date | File | Topic | Status |
|---|---|---|---|
| 2026-06-08 | [`jun08-judge-model-calibration.md`](jun08-judge-model-calibration.md) | Why triage judges stay Opus 4.6 + GPT-5.4 (GPT-5.5 re-flags 20–25/85 fair tasks) | Live — backs MR !87 judge revert |
| 2026-05-06 | [`may06-swebench-pro-suitability.md`](may06-swebench-pro-suitability.md) | SWE-bench Pro suitability audit: narrow tests and trivial rejected tasks | Paper-facing evidence |
| 2026-05-06 | [`may06-swebench-pro-jsonl-repo-dependencies.md`](may06-swebench-pro-jsonl-repo-dependencies.md) | Dependency map for running CRAFT-style SWE-bench Pro analysis from JSONL | Design/implementation notes |
| 2026-05-06 | [`may06-swebench-pro-handoff.md`](may06-swebench-pro-handoff.md) | Paused-work handoff for reproducing the SWE-bench Pro analysis | Handoff |
| 2026-05-06 | [`may06-v2b-baseline-results.md`](may06-v2b-baseline-results.md) | Consolidated v2b end-to-end baseline numbers (5 agent+model configs × 92 tasks) | Live evidence for the paper's headline tables |
| 2026-05-06 | [`may06-v2b-deep-dive.md`](may06-v2b-deep-dive.md) | 12-angle behavioral deep dive across 364 v2b trials | Descriptive; superseded as headline by may02-regression |
| 2026-05-02 | [`may02-v2b-regression-rigorous.md`](may02-v2b-regression-rigorous.md) | Multivariate logistic regression evidence package; co-author conversation surface | Live |
| 2026-05-01 | [`may01-search-vs-e2e-correlation.md`](may01-search-vs-e2e-correlation.md) | Search ↔ e2e correlation across 4 framings × 2 aggregations | Live |
| 2026-05-01 | [`may01-search-vs-e2e-implicit.md`](may01-search-vs-e2e-implicit.md) | Did the e2e agent actually read the necessary files? | Live |
| 2026-05-01 | [`may01-search-vs-e2e-paper-framing.md`](may01-search-vs-e2e-paper-framing.md) | What's defensible from the search-vs-e2e analysis for the paper | Live |
| 2026-04-25 | [`apr25-swepro-spotcheck.md`](apr25-swepro-spotcheck.md) | SWE-Bench-Pro instruction comparison via offline harness | Live |
| 2026-04-17 | [`apr17-craft-vs-swebench-plus-plus.md`](apr17-craft-vs-swebench-plus-plus.md) | Technical comparison vs scaled-SWE-bench landscape | Background for the paper's related-work section |
| 2026-04-15 | [`apr15-pr-first-mining-design.md`](apr15-pr-first-mining-design.md) | PR-first mining design (`base_sha` + `sha` from GitHub PRs) | Design doc behind current `craft-taskgen-mine` behavior |

## Backing data

Run-level CSVs/JSONs land in [`data/`](data/). Filenames carry the analysis prefix where unambiguous (e.g. `v2b-all-trials-92x5x6.csv`). The SWE-bench Pro audit keeps its generated tables, supporting reports, paper PDF, and ignored local run dumps under [`data/swebench-pro/`](data/swebench-pro/).
