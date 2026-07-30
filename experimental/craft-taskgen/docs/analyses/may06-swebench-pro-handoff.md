# SWE-bench Pro Deep Dive Handoff

Last updated: 2026-05-06.

This directory captures the paused SWE-bench Pro analysis. The goal was to use CRAFT's problem-selection and alignment pipeline as an audit layer over the public SWE-bench Pro subset, then connect the results back to CRAFT's claims about task difficulty and verifier fairness.

## Current State

The current analysis is based on 263 SWE-bench Pro tasks and one Claude Opus 4.6 Harbor run:

- Pipeline labels/verdicts: `harbor-tasks/craft-tools-v3a/runs/new_pipeline_0427/state.json`
- SWE-bench Pro task metadata/test patches: `swebench_pro.jsonl`
- Agent aggregate result: `tmp/swebench-results/combined_non_error/result.json`
- Raw agent/verifier trajectories: `docs/analyses/data/swebench-pro/runs/combined_non_error`
- Working CRAFT analysis CSV: `docs/analyses/data/swebench-pro/swebench-pro-craft-analysis.csv`

The main paper-facing artifact is:

- `docs/analyses/may06-swebench-pro-suitability.md`

The report currently focuses on two suitability modes:

1. `narrow_tests`: unit tests enforce behavior, private helpers, exact strings, or design choices not faithfully specified by the task text.
2. rejected/trivial tasks: CRAFT rejects tasks as too mechanical or too easy, challenging SWE-bench Pro's difficulty claim.

## Layout

- `scripts/swepro/analysis/`: reproducible analysis scripts.
- `docs/analyses/data/swebench-pro/findings/`: generated CSVs and Markdown reports.
- `docs/analyses/data/swebench-pro/runs/combined_non_error/`: copied Harbor job directory with one subdirectory per task, including `agent/trajectory.json`, agent logs, and verifier outputs.
- `tmp/swebench-results/combined_non_error/`: original Harbor result directory for this run.
- `docs/analyses/data/swebench-pro/swebenchpro_paper.pdf`: local copy of the SWE-bench Pro paper used for claim framing.

Important source-code references outside this analysis bundle:

- `scripts/agent_pass_rate_matrix.py`: prints pass rates by CRAFT stage/alignment verdict.
- `src/craft_taskgen/prompts.py`: contains the alignment judge prompt.
- `src/craft_taskgen/rubrics.py`: contains rubric labels like `BT1`, `AL1`, and `SA1`.

## Current Findings Snapshot

From the regenerated two-mode report:

- Narrow-test tasks: 40/263, agent passed 19/40.
- Rejected tasks: 167/263, agent passed 112/167.
- Accepted tasks: 96/263, agent passed 39/96.
- Alignment split: `leaked` 37/70, `narrow_tests` 19/40, `ok` 95/152, `skipped` 0/1.

Interpretation:

- Rejected tasks pass substantially more often than accepted tasks in this run. That is not proof by itself, but it supports the CRAFT triviality judgments.
- The raw `ok` vs `leaked` gap is mostly compositional. `docs/analyses/data/swebench-pro/findings/ok_vs_leaked_controlled_report.md` shows that controlling for repo/eval verdict/F2P or required-test buckets largely removes the apparent leaked underperformance.
- The strongest paper-facing result is not "leaked tasks are worse." It is that CRAFT identifies task-suitability issues even in a human-verified benchmark: trivial tasks and narrow/overconstrained verifiers.

## Main Case Studies

The current report manually deep dives six cases.

Mode 1, narrow tests:

- `qutebrowser-fec187c2`: task says URL encoding, but the failing F2P test relies on search-engine alias/base-url behavior.
- `ansible-0fd88717`: hidden tests require a private helper return-shape change even though the agent preserved backward compatibility with a separate helper.
- `ansible-bec27fb4`: broad `ansible-doc` formatting task, but all three true F2P failures are private-helper/exact-format expectations. Important correction: it passed 17/17 P2P tests and 0/3 true F2P tests.

Mode 2, too trivial/mechanical:

- `qutebrowser-0833b5f6`: one-line signal migration from `error` to `errorOccurred`.
- `ansible-0ea40e09`: standard Python mapping union dunder methods for `VarsWithSources`.
- `qutebrowser-fea33d60`: direct `compiled=False` parameter passthrough named in the task.

The case index is:

- `docs/analyses/data/swebench-pro/findings/swebench_pro_two_mode_cases.csv`

## End-to-End Regeneration

Run these from the repo root. The scripts have defaults wired to the current paths.

Optional matrix check:

```bash
uv run python scripts/agent_pass_rate_matrix.py tmp/swebench-results/combined_non_error/result.json harbor-tasks/craft-tools-v3a/runs/new_pipeline_0427/state.json
```

Full SWE-bench Pro analysis pipeline:

```bash
uv run python scripts/swepro/analysis/add_agent_success_to_csv.py
uv run python scripts/swepro/analysis/build_stratified_outcomes.py
uv run python scripts/swepro/analysis/export_leaked_failures.py
uv run python scripts/swepro/analysis/add_f2p_test_stats_to_leaked_failures.py
uv run python scripts/swepro/analysis/summarize_openlibrary_leaked_failures.py
uv run python scripts/swepro/analysis/summarize_zero_f2p_leaked_failures.py
uv run python scripts/swepro/analysis/analyze_swebench_pro_difficulty_proxies.py
uv run python scripts/swepro/analysis/analyze_interface_confounders.py
uv run python scripts/swepro/analysis/analyze_alignment_confounders.py
uv run python scripts/swepro/analysis/analyze_ok_vs_leaked_controlled.py
uv run python scripts/swepro/analysis/build_two_mode_suitability_report.py
```

Validation:

```bash
uv run ruff check scripts/swepro/analysis
uv run pytest tests/test_agent_pass_rate_matrix.py tests/test_alignment_majority.py tests/test_evaluate_majority.py tests/test_swebench_alignment.py tests/test_update_alignment_csv.py
```

I reran `uv run python scripts/swepro/analysis/build_two_mode_suitability_report.py` and `uv run ruff check scripts/swepro/analysis/build_two_mode_suitability_report.py` after the latest report-script change.

## Script Outputs

- `add_agent_success_to_csv.py`
  - Mutates `docs/analyses/data/swebench-pro/swebench-pro-craft-analysis.csv`.
  - Adds/updates `agent_success` from Harbor `reward_stats`.

- `build_stratified_outcomes.py`
  - Writes `docs/analyses/data/swebench-pro/findings/task_outcomes_enriched.csv`.
  - Writes `docs/analyses/data/swebench-pro/findings/stratified_pass_rate_report.md`.
  - This is the central joined table for labels, agent success, required-test counts, run dirs, and trajectory metrics.

- `export_leaked_failures.py`
  - Writes `docs/analyses/data/swebench-pro/findings/leaked_agent_failures.csv`.
  - Filters leaked tasks where the agent failed.

- `add_f2p_test_stats_to_leaked_failures.py`
  - Updates `docs/analyses/data/swebench-pro/findings/leaked_agent_failures.csv`.
  - Caveat: the columns named `agent_f2p_tests_passed` and `agent_f2p_tests_total` are verifier required-test counts, not true SWE-bench F2P counts.

- `summarize_openlibrary_leaked_failures.py`
  - Writes `docs/analyses/data/swebench-pro/findings/openlibrary_leaked_failures_raw.md`.

- `summarize_zero_f2p_leaked_failures.py`
  - Writes `docs/analyses/data/swebench-pro/findings/zero_f2p_leaked_failures_raw.md`.

- `analyze_swebench_pro_difficulty_proxies.py`
  - Writes `docs/analyses/data/swebench-pro/findings/swebench_pro_difficulty_proxies_enriched.csv`.
  - Writes `docs/analyses/data/swebench-pro/findings/swebench_pro_difficulty_proxies_report.md`.
  - Pulls true `fail_to_pass`/`pass_to_pass`, patch sizes, requirement lengths, and related proxies from `swebench_pro.jsonl`.

- `analyze_interface_confounders.py`
  - Writes `docs/analyses/data/swebench-pro/findings/interface_confounders_enriched.csv`.
  - Writes `docs/analyses/data/swebench-pro/findings/interface_confounders_report.md`.

- `analyze_alignment_confounders.py`
  - Writes `docs/analyses/data/swebench-pro/findings/alignment_confounders_report.md`.

- `analyze_ok_vs_leaked_controlled.py`
  - Writes `docs/analyses/data/swebench-pro/findings/ok_vs_leaked_controlled_report.md`.

- `build_two_mode_suitability_report.py`
  - Writes `docs/analyses/may06-swebench-pro-suitability.md`.
  - Writes `docs/analyses/data/swebench-pro/findings/swebench_pro_two_mode_cases.csv`.
  - The selected case studies are hardcoded in `CASE_ORDER` and `CASE_DETAILS`; update those if adding/replacing examples.

## How To Manually Inspect A Task

1. Find the task in `docs/analyses/data/swebench-pro/findings/task_outcomes_enriched.csv` or `docs/analyses/data/swebench-pro/findings/swebench_pro_two_mode_cases.csv`.
2. Open the SWE-bench metadata in `swebench_pro.jsonl`:
   - `problem_statement`
   - `requirements`
   - `interface`
   - `fail_to_pass`
   - `pass_to_pass`
   - `test_patch`
3. Open the run directory under `docs/analyses/data/swebench-pro/runs/combined_non_error/<trial_name>/`.
4. Check:
   - `agent/trajectory.json`
   - `agent/claude-code.txt`
   - `verifier/output.json`
   - `verifier/test-stdout.txt`
   - `verifier/run-script-stdout.txt`
5. Compare the task text against the actual failing F2P tests. Do not rely on the CSV verdict alone.

## Important Gotchas

- `required_passed/required_total` is the verifier required-suite count. It can include both true F2P and P2P/regression tests.
- True F2P totals come from `swebench_pro.jsonl` and are surfaced as `true_f2p_total` in the enriched outputs.
- `ansible-bec27fb4` is the canonical example of the distinction: `17/20` required tests passed, but that means `17/17` P2P and `0/3` true F2P.
- `docs/analyses/data/swebench-pro/swebench-pro-craft-analysis.csv` has a filename with spaces and is used directly by script defaults.
- Some CSVs have repeated column names inherited from the sheet export. Scripts intentionally choose populated columns in a few places; avoid renaming columns unless you update the scripts.
- `docs/analyses/data/swebench-pro/runs/combined_non_error` is required for trajectory-backed reports. `rg --files` may not show it if ignored by git, but the directory exists in the current workspace.
- Currently there is only one result job directory: `combined_non_error`. If adding ablations, keep separate directories such as `tmp/swebench-results/<ablation_name>` and `docs/analyses/data/swebench-pro/runs/<ablation_name>` rather than overwriting this one.

## Paper Framing To Reuse

Useful abstract-level wording:

> Although SWE-bench Pro introduces human-augmented problem statements and verification workflows to improve task complexity and reduce ambiguity, our analysis shows that task-suitability issues can remain. We apply CRAFT's problem-selection pipeline to the public subset of SWE-bench Pro and identify tasks rejected for either insufficient difficulty or verifier misalignment, where the unit tests enforce behavior not faithfully specified by the problem description. Manual inspection of representative examples, including problem statements, test patches, and agent trajectories, confirms both categories. This demonstrates that CRAFT complements human verification by providing an additional auditing layer for filtering trivial tasks and detecting potential false-negative verifiers in software engineering benchmarks.

Shorter takeaways:

- CRAFT reframes benchmark quality as task suitability, not just agent pass rate.
- Rejected/trivial tasks are often easier than accepted ones, supporting the pipeline's difficulty judgments.
- Verifier quality is separate from task difficulty: narrow tests can produce false negatives by encoding unstated private APIs, exact strings, or design choices.

## Where To Pick Up

1. Use `docs/analyses/may06-swebench-pro-suitability.md` as the current paper-facing evidence base.
2. Decide whether the final paper section should include all six examples or only 2-3 total examples per mode.
3. If adding examples, update `CASE_ORDER` and `CASE_DETAILS` in `scripts/swepro/analysis/build_two_mode_suitability_report.py`, rerun the generator, then inspect the resulting report.
4. For any new model runs or ablations, put outputs in separate job directories and rerun the pipeline with explicit `--runs-dir`, `--manifest`, `--results`, and output paths.
5. Before committing, rerun `ruff` and the relevant unit tests listed above.
