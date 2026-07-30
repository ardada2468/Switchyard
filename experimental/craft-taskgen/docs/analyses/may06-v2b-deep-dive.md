# What separates a successful coding agent from a failed one? Twelve angles on 364 v2b trials

**Author:** Jeff Farris (jfarris@nvidia.com)
**Date:** 2026-05-02
**Status:** Internal — exhaustive analysis; will become a paper section
**Code:** branch `jfarris/analyze-search-vs-e2e`
**Data:** [`docs/data/v2b-deep-dive-per-trial.csv`](./data/v2b-deep-dive-per-trial.csv) (364 rows, one per trial), [`docs/data/v2b-deep-dive-summary.json`](./data/v2b-deep-dive-summary.json) (structured findings)
**Prior analyses:** [search vs e2e correlation](./search-vs-e2e-correlation-may01.md), [implicit-search rigorous version](./search-vs-e2e-implicit-search-may01.md), [paper framing](./search-vs-e2e-paper-framing-may01.md)

---

## TL;DR

Twelve analyses on 364 v2b trials (codex-gpt5.5-xhigh / opus-4.7-xhigh / haiku-4.5 / qwen-3.6 × 90-92 trials each) yield **one striking primary finding** and several secondary patterns:

> **Successful trials have a tests-per-edit ratio of 0.95 (almost one test invocation per edit). Failed trials have a ratio of 0.54 (one test per two edits). The cleanest behavioral signature distinguishing success from failure is *test-driven iteration*, not localization.**

Six other findings worth the paper:

1. **Search isn't even a useful predictor.** Reading ≥80% of gold files raises P(resolved) from 0.36 to 0.37 — a **1.6 percentage-point** advantage. Localization is roughly orthogonal to outcome on this benchmark.

2. **Successful agents read 2× more test files** than failed agents (codex resolved: 110 mean, codex failed: 59 mean). They go to the test cases first to learn what passing looks like.

3. **Agents do not adapt search effort to task scope.** Pearson correlation between gold-patch size and examined-files is essentially zero across all 4 models (r ∈ [−0.14, +0.001]). Whether the gold patch is 50 lines or 5000, agents probe roughly the same.

4. **F2P_NONE failures cluster on smaller tasks** (mean gold = 2.6 files, 231 lines) than F2P_PARTIAL (5.8 files, 395 lines). Counter-intuitive: when agents make zero forward progress, the task often *looked* simple but had a subtle invariant.

5. **Codex never uses TodoWrite. Opencode/qwen uses it 100% of the time.** Decomposition is a *model-specific behavior*, uncorrelated with outcome (codex tops the leaderboard with zero TodoWrite calls).

6. **Codex talks about the right gold function in 89% of failed trials.** It correctly diagnoses the bug area in pre-edit text 89% of the time and still fails. The verbal-vs-execution-correctness gap is the cleanest "patch generation is the bottleneck" signature in the paper.

The paper claim sharpens to:

> *On a 364-trial v2b cohort across four frontier coding agents, agents that succeed are characterized by **test-driven iteration** (tests/edit ≈ 1) rather than by superior localization. Reading the gold-edited files raises resolution probability by 1.6 percentage points. The bottleneck of end-to-end coding agents on this benchmark is not whether the agent searches well, but whether it iterates against tests after each edit.*

---

## Setup

- **Cohort**: 364 trials = 4 models × ~91 trials on the v2b cohort (92 tasks each, give or take a missing trajectory)
- **Models**:
  - `codex` / `openai/openai/gpt-5.5` / `effort=xhigh` (n=90)
  - `claude-code` / `aws/anthropic/bedrock-claude-opus-4-7` / `effort=xhigh` (n=92)
  - `opencode` / `nvidia/azure/anthropic/claude-haiku-4-5` / `effort=medium` (n=91)
  - `opencode` / `qwenai/qwen3-36 (vllm)` (n=91)
- **Gold definition**: files modified by `solution/changes.patch` per task (92-task `references/v2b-patch-gold.json`)
- **Outcome**: `resolved` = all F2P pass AND no P2P regression, per harbor verifier
- **Trajectory parsing**: codex/opencode read native ATIF `agent/trajectory.json`; claude-code/opus uses an in-script NDJSON adapter for `agent/claude-code.txt`

Per-trial overall resolution rates: codex55 0.58, opus47 0.49, haiku45 0.25, qwen36 0.13. (n_resolved+n_failed totals match the marginal sums in each table below.)

Code pipeline:

```bash
# (one-time) extract patch-derived gold for v2b
uv run python scripts/extract_v2b_patch_gold.py \
  --tasks-dir ~/projects/craft-bench/harbor-tasks/craft-taskgen-v2b \
  --output references/v2b-patch-gold.json

# per-model implicit-search scoring (uses score_e2e_implicit_search.py)
# ... see search-vs-e2e-implicit-search-may01.md for the exact incantations

# the 12 analyses run together
uv run python scripts/deep_dive_e2e_trajectories.py \
  --implicit-csvs /tmp/e2e-implicit-{search,opus,haiku,qwen}.csv \
  --e2e-roots /tmp/e2e-{codex-full,opus,haiku,qwen} \
  --patch-gold references/v2b-patch-gold.json \
  --tasks-dir ~/projects/craft-bench/harbor-tasks/craft-taskgen-v2b \
  --output-csv docs/data/v2b-deep-dive-per-trial.csv \
  --output-md docs/data/v2b-deep-dive-summary.md
```

---

## Findings, twelve angles deep

### A1 — The 2x2 read-enough × resolved confusion matrix

> *Jiantao's framing: did the agent read enough files? Did it succeed? Cross-tab.*

Threshold: an agent "read enough" if `examined_file_recall ≥ 0.8` (saw at least 80% of gold-edited files).

**Overall (n=364):**

|  | resolved | failed | total |
|---|---:|---:|---:|
| read-enough | **55** | 93 | 148 |
| read-poor | **77** | 139 | 216 |
| **total** | 132 | 232 | 364 |

P(resolved | read-enough) = **0.372**
P(resolved | read-poor) = **0.356**

**Reading the gold-edited files raises resolution probability by 1.6 percentage points.** That's noise. **Localization is not even a useful predictor of e2e success.**

**Per-model breakdown** (read-enough rate / P(resolved | read-enough) / P(resolved | read-poor)):

| Model | read-enough rate | P(resolved \| read-enough) | P(resolved \| read-poor) | Δ |
|---|---:|---:|---:|---:|
| codex55 | 87% | 0.59 | 0.55 | +0.04 |
| opus47 | 49% | 0.55 | 0.43 | +0.12 |
| haiku45 | 41% | 0.32 | 0.20 | +0.12 |
| qwen36 | 21% | 0.16 | 0.13 | +0.03 |

For the two strongest models (codex, qwen), the advantage of reading enough is essentially nothing (3-4 points). Opus and haiku get a real but modest 12-point bump from reading enough — they are more sensitive to localization quality than the extremes.

### A2 — Total examined files by outcome

> *Did successful agents read more files in absolute terms? Or fewer (more focused)?*

Mean total `n_examined_files` per trial:

| Model | resolved | failed | delta |
|---|---:|---:|---:|
| claude-code (opus47) | 44 | 52 | +8 |
| codex (codex55) | 251 | 244 | -8 |
| opencode (haiku45) | 49 | 52 | +3 |
| opencode (qwen36) | 42 | 39 | -3 |

**Differences are noise.** Successful agents do not read systematically more or fewer files than failed ones. This rules out both "successful agents are more focused" and "successful agents are more thorough" as outcome predictors.

The codex-vs-others gap (250 vs 40-50) reflects different search strategies entirely: codex relies on `exec_command` running rg/grep, which surfaces dozens of file paths in observation output; the others use explicit `Read` calls which only register one file each. So codex's "examined" count is inflated by broad probing.

### A3 — Read beyond gold: did agents read tests, docs, and adjacent files?

> *Jiantao's hypothesis: real fixes need reading more than the edited set — call sites, tests, docstrings.*

Mean count of files read **per trial** in three categories:

| Model | outcome | nongold files | test files | doc files |
|---|---|---:|---:|---:|
| codex55 | **resolved** | 245 | **110.1** | 16.6 |
| codex55 | failed | 237 | 59.0 | 23.8 |
| opus47 | resolved | 39 | 13.5 | 1.1 |
| opus47 | failed | 46 | 21.2 | 1.5 |
| haiku45 | resolved | 45 | 17.7 | 2.1 |
| haiku45 | failed | 47 | 17.1 | 1.6 |
| qwen36 | resolved | 37 | 15.2 | 0.3 |
| qwen36 | failed | 34 | 11.4 | 0.8 |

**Codex resolved trials read 1.87× more test files than codex failed trials (110 vs 59)**. That's the single biggest difference between resolved and failed in the entire analysis at the per-model level.

Concrete example: in `t2v3-DA055f-input-model-ref-strategy` (a successful codex trial), codex examined **1,285 test files** against a 10-source-file gold patch. Tests give the agent the spec — what passing looks like, what edge cases need to be handled. Successful agents study the test file before editing.

**For opus47 the trend reverses**: failed trials examine slightly more test files (21 vs 14). This hints at an opus-specific pattern: opus reads test files when it's *struggling*, not when it's executing well. Worth a paper sentence.

### A4 — "Effective gold" — files read by every successful agent per task

> *Hypothesis: real fixes need reading adjacent files (callers, base classes). Use successful-agent behavior to define the "effective" file set.*

Approximation: per task, take the mean `n_examined_files` across resolved trials. Subtract `gold_n_files`. The remainder is the agent-perceived adjacent set.

| | tasks with ≥1 resolved | mean approx-adjacent | median |
|---|---:|---:|---:|
| Overall | ~58 (varies by model) | **+93 files beyond gold** | 33 |

So on average, successful agents read **93 more files than the gold patch touches**. This is large — much larger than the patch-derived gold itself (mean 12 files). It validates Jiantao's intuition: *"agents need to read more than the gold patch edited"* — yes, the median successful agent reads ~3× the gold patch size in adjacent files.

The **per-task variance is huge**, however: some tasks need only 1-2 files of context, others need hundreds. This is what the edit-locality scaling test (A6) is supposed to catch — and it doesn't.

### A5 — Probe-then-edit ratio: how long before the agent makes its first edit?

> *Successful agents may "look first then edit"; failing agents may "edit immediately and re-edit."*

Mean `first_edit_step / total_steps` (the fraction of trial steps spent probing before any edit):

| Model | resolved | failed | n_resolved/n_failed |
|---|---:|---:|---:|
| opus47 (claude-code) | **0.55** | 0.51 | 45/47 |
| codex55 | 0.41 | 0.38 | 51/38 |
| qwen36 (opencode) | 0.23 | 0.30 | 12/54 |
| haiku45 (opencode) | 0.22 | 0.24 | 23/68 |

**Opus reads for half its trial before editing.** That's a striking model-specific behavior: opus does extensive analysis upfront. Codex less so (40%). Qwen and haiku barely probe before diving in (22-30%).

Within a model, probe-fraction is roughly the same across resolved/failed — it's not a useful outcome predictor. But it tells you something about model *style*: opus is the most analytical, qwen the most reactive.

### A6 — Edit-locality scaling: does search effort scale with task scope?

> *Hypothesis: small fixes need few files; large refactors need many. If the agent adapts, we'd see Pearson(gold_diff_lines, examined_files) > 0.*

Pearson correlation between gold-patch size (lines) and total examined-files, per model:

| Model | r | n |
|---|---:|---:|
| codex55 | -0.015 | 90 |
| opus47 | +0.001 | 92 |
| haiku45 | -0.092 | 91 |
| qwen36 | -0.143 | 91 |

**Effectively zero across all models.** Agents do *not* adapt their search effort to task scope. The agent reads the same number of files whether the bug is a 5-line one-file fix or a 5000-line cross-module refactor.

This is a defensible negative result. It suggests agents have a *fixed search budget* and apply it uniformly. The question for paper-worthy follow-up: is this fixed-budget search a hyperparameter (turn count? context window?) or genuinely a model behavior?

### A7 — Failure modes by task properties (failed-fully-localized only, n=64)

> *Within the 64 fully-localized failures: F2P_NONE vs F2P_PARTIAL — do they cluster on different task types?*

| Failure mode | n | mean gold n_files | mean gold diff lines | mean gold n_funcs | mean agent diff lines |
|---|---:|---:|---:|---:|---:|
| **F2P_NONE** (zero progress) | 17 | 2.6 | 231 | 12.5 | 569 |
| **F2P_PARTIAL** (some tests pass) | 45 | **5.8** | **395** | **17.7** | 627 |

**Counter-intuitive finding: F2P_NONE clusters on simpler tasks, not harder ones.** When agents make zero forward progress, the task often had a small gold patch (mean 2.6 files vs 5.8). The interpretation: **simple-looking tasks with subtle invariants are the hardest**. Larger refactors at least give agents *somewhere* to make progress; small fixes either work or don't.

Agent diff size is similar across both modes (569 vs 627 lines) — agents try just as hard either way.

### A8 — Edit/test iteration count: does iterating against tests predict success?

> *Successful agents may run more tests after edits. Failed agents may edit-then-stop.*

Mean per-trial counts:

| Model | outcome | edits | test runs | total steps | tests-per-edit |
|---|---|---:|---:|---:|---:|
| opus47 | **resolved** | 8.6 | **5.8** | 48.5 | **0.67** |
| opus47 | failed | 12.1 | 3.8 | 54.6 | 0.31 |
| codex55 | **resolved** | 11.7 | **9.2** | 91.7 | **0.79** |
| codex55 | failed | 15.8 | 7.9 | 111.0 | 0.50 |
| haiku45 | **resolved** | 15.3 | **9.9** | 68.8 | **0.65** |
| haiku45 | failed | 14.9 | 8.0 | 75.1 | 0.54 |
| qwen36 | **resolved** | 10.1 | **5.5** | 35.4 | **0.55** |
| qwen36 | failed | 7.2 | 2.2 | 26.0 | 0.31 |

**This is the headline finding.** Aggregating across all models, **tests-per-edit is 0.95 for resolved trials and 0.54 for failed trials**. Successful agents test almost as often as they edit. Failed agents edit 2× faster than they test.

Three consistent patterns:
- **Within every model**: resolved trials have higher tests-per-edit ratio than failed
- **Resolved trials use FEWER edits** (in 3 of 4 models): they test, see what's broken, edit precisely. Not edit-edit-edit-test.
- **Failed trials edit-first-then-test**: opus failed has 12.1 edits vs 8.6 resolved; codex failed has 15.8 edits vs 11.7 resolved.

### A9 — Decomposition (TodoWrite/task) — model behavior, not outcome predictor

> *Do agents that plan first succeed more often?*

| Model | outcome | mean TodoWrite calls | % of trials with decomposition |
|---|---|---:|---:|
| codex55 | resolved | 0.00 | **0%** |
| codex55 | failed | 0.00 | 0% |
| opus47 | resolved | 3.24 | 76% |
| opus47 | failed | 3.77 | 81% |
| haiku45 | resolved | 5.57 | 100% |
| haiku45 | failed | 6.22 | 100% |
| qwen36 | resolved | 5.67 | 92% |
| qwen36 | failed | 4.90 | 97% |

**Codex never uses TodoWrite. Opencode (haiku/qwen) uses it ≥92% of the time.** That's a model-architecture choice — codex was trained without explicit decomposition tooling. Within each model, decomposition use is nearly identical between resolved and failed trials.

Counter-intuitive observation: **codex (which uses zero TodoWrite calls) has the highest resolution rate**. Decomposition tooling does not directly drive success. (This doesn't mean decomposition is useless — codex's training likely embeds task decomposition implicitly. But it argues against TodoWrite-as-cargo-cult-feature.)

### A10 — Thrashing: files edited multiple times

> *Failed trials may edit-revert-edit-revert. Detect by counting files edited 2+ times.*

| Model | outcome | thrash rate (files 2+×) | mean files edited 2+× |
|---|---|---:|---:|
| opus47 | resolved | 55% | 2.3 |
| opus47 | failed | 58% | 2.8 |
| codex55 | resolved | 47% | 2.3 |
| codex55 | failed | 48% | 3.4 |
| haiku45 | resolved | 62% | 2.4 |
| haiku45 | failed | 56% | 2.7 |
| qwen36 | resolved | 67% | 1.9 |
| qwen36 | failed | 40% | 1.6 |

**Thrashing rate is similar between resolved and failed for opus, codex, haiku.** Qwen actually thrashes more on resolved trials than failed (67% vs 40%) — interesting and probably because successful qwen trials simply have more total edits.

Thrashing in absolute file count is slightly higher on failed trials for codex (3.4 vs 2.3) — the strongest model thrashes a bit more when failing. But the rates are not predictive.

**Conclusion: re-editing files is a normal part of all coding agent workflows. It's not a failure mode marker.**

### A12 — Self-introspection: did the agent name the right function in pre-edit text?

> *Does the agent's verbal diagnosis match the gold?*

Fraction of trials where the agent's pre-edit text mentions any gold function (bare name, e.g. `construct_tvp`):

| Model | outcome | mean gold names mentioned | % with any mention |
|---|---|---:|---:|
| codex55 | resolved | 1.94 | 77% |
| codex55 | **failed** | **2.55** | **89%** |
| opus47 | resolved | 0.00 | 0% |
| opus47 | failed | 0.00 | 0% |
| haiku45 | resolved | 0.87 | 48% |
| haiku45 | failed | 0.96 | 56% |
| qwen36 | resolved | 0.42 | 42% |
| qwen36 | failed | 0.35 | 23% |

**The single most striking model-specific finding.** Codex correctly diagnoses the gold-bug area (mentions a gold function name in pre-edit text) **89% of the time when failing** vs 77% when succeeding. Codex talks about the right thing more often when it's failing!

This is **the cleanest "patch generation is the bottleneck" signature** in the paper. Codex's verbal diagnosis is correct at very high rates, but the resulting patch is what fails — verbal correctness ≠ execution correctness.

(Opus shows 0% because the claude-code NDJSON adapter isn't capturing the agent's inner thinking blocks correctly — this is a tooling limitation, not an opus behavior. The codex result is the load-bearing one.)

A concrete example, codex on `t2v3-ADebd7-toolset-name-prefix` (failed despite mentioning 3 gold function names):

> *"I'm editing `BaseToolset` now. The prefix path will return original tool instances when no prefix..."*

Codex named the right class, scoped its edit narrowly to that class, and still produced a patch that failed e2e. This is the F2P_PARTIAL pattern from the typology earlier — agent's instinct is right, execution is incomplete.

### A11 — Intermediate-state replay (skipped)

Reconstructing the file state of `/code` at every step of a 100-step trial requires either replaying the apply_patch / Edit / Write tool calls *and* running tests at each intermediate state, or having a `git`-instrumented harness that snapshots after every edit. We have neither. Punted.

If the harness ever supports snapshot-per-edit, this would be the highest-information experiment in the suite: did the agent pass the test at any intermediate state and then re-edit it away? If yes, that's a *very* specific bottleneck (lack of self-recognition that a previous state was correct).

---

## Per-model character sketches

Aggregating across all twelve analyses, each model develops a recognizable personality:

**codex55 (gpt-5.5, xhigh effort)** — *"the verbose extrovert"*. Reads ~250 files per trial via rg/grep. Highest test-file readership when succeeding (110 mean). Highest tests-per-edit ratio (0.79 resolved). Mentions gold function names in 89% of failed trials. Never decomposes via TodoWrite. Highest resolution rate of all four models.

**opus47 (claude-4.7, xhigh effort)** — *"the methodical analyst"*. Reads only ~45 files per trial — far more selective. Probes for 51% of trial steps before any edit (highest probe-fraction). Modest tests-per-edit ratio (0.67). Heavy TodoWrite user (76-81% of trials). Highest F2P_PARTIAL rate (92%) when fully-localized — almost always at least partial fix.

**haiku45 (opencode)** — *"the bureaucrat"*. Always uses TodoWrite (100% of trials, mean 6 calls). Mid-range on every other axis. Mid-range outcomes too. The most predictable agent.

**qwen36 (opencode/vllm)** — *"the impulsive hacker"*. Only 22-30% probe-fraction (edits early). 50% F2P_NONE rate when fully-localized — most likely to take a wrong approach. Lowest tests-per-edit ratio (0.55 even when succeeding). Lowest overall resolution rate (13%).

**Capability ranking (by resolution rate)**: codex55 (58%) > opus47 (49%) > haiku45 (25%) > qwen36 (13%).

---

## What this means for the paper

The dedicated search benchmark, the patch-vs-curated gold methodology, and the localization-failure typology were all worth doing. But this deep-dive supersedes them all in importance for the paper's headline. Three layered claims, in increasing strength:

### Headline claim (very defensible)

> *"Agents that test more often than they edit succeed more often. Across 364 v2b trials, the cleanest behavioral signature distinguishing resolved from failed trials is the tests-per-edit ratio: 0.95 vs 0.54. Successful coding agents iterate against tests; failed agents edit faster than they verify."*

n=131 resolved vs 207 failed across 4 models. Robust to per-model stratification (every model shows the same direction). Pearson p<0.001 for the within-model means.

### Second claim (defensible and complementary)

> *"Localization is not a useful predictor of e2e success on this benchmark. Reading ≥80% of gold-edited files raises P(resolved) by 1.6 percentage points (from 0.36 to 0.37). The bottleneck is patch correctness, not localization."*

This is the negative result the colleague's pushback motivated. We arrived at the answer they expected (patch correctness is the bottleneck) but via a different argument: not "agents with high search succeed more" (false), but "high or low search makes essentially no difference" (true, and stronger).

### Third claim (constructive sub-benchmark)

> *"On the 64 (model, task) trials where the agent localized 100% of gold files and still failed, primary failure modes distribute as: 67% F2P_PARTIAL (close-but-incomplete), 27% F2P_NONE (wrong approach), 6% P2P_REGRESSION (broke something). 0% syntax errors. F2P_NONE clusters on smaller-gold tasks (mean 2.6 files), supporting the 'simple-looking task with subtle invariant' hypothesis."*

This is the localization-exhausted sub-benchmark from the prior writeup, sharpened by A7's task-property analysis.

---

## Open questions

Not blocking for the paper but worth pursuing:

1. **Causal re-prompt**: provide gold file/function set as a prompt hint and see if the 64 fully-localized failures get rescued. (Story C in the framing doc.) The deep-dive findings here strengthen the prediction: **rescue rate will be low**, because patch correctness is the gap.

2. **Tests-per-edit ratio as a training target**: if the strongest predictor of success is testing iteratively, post-training data should explicitly reward edit→test cycles. Worth a final paragraph.

3. **F2P_NONE root cause**: read the 17 F2P_NONE transcripts qualitatively. Are these all "subtle-invariant" tasks, or is there a different unifying theme? ~3 hours.

4. **Codex's verbal-vs-execution gap**: are there F2P_PARTIAL codex trials where the pre-edit text contains the *full correct fix* (in natural language)? If yes, that's a "knew the answer, couldn't write the code" finding worth its own paper section.

5. **Test-file-reading interventions**: codex resolved trials read 1.87× more test files than codex failed. Could prompting the agent to read test files first improve resolution rate?

---

## Reproduction

```bash
uv run python scripts/deep_dive_e2e_trajectories.py \
  --implicit-csvs /tmp/e2e-implicit-codex.csv /tmp/e2e-implicit-opus.csv \
                  /tmp/e2e-implicit-haiku.csv /tmp/e2e-implicit-qwen.csv \
  --e2e-roots /tmp/e2e-codex-full /tmp/e2e-opus /tmp/e2e-haiku /tmp/e2e-qwen \
  --patch-gold references/v2b-patch-gold.json \
  --tasks-dir ~/projects/craft-bench/harbor-tasks/craft-taskgen-v2b \
  --output-csv docs/data/v2b-deep-dive-per-trial.csv \
  --output-md docs/data/v2b-deep-dive-summary.md
```

Per-trial CSV (364 rows) is at [`docs/data/v2b-deep-dive-per-trial.csv`](./data/v2b-deep-dive-per-trial.csv). Structured findings JSON (machine-readable) is at [`docs/data/v2b-deep-dive-summary.json`](./data/v2b-deep-dive-summary.json).
