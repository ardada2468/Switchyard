# Did the e2e agent actually read the necessary files? Rigorous analysis

**Author:** Jeff Farris (jfarris@nvidia.com)
**Date:** 2026-05-01 (revised after methodological audit)
**Status:** Draft — codex / opus / haiku / qwen on v2b
**Code:** branch `jfarris/analyze-search-vs-e2e`
**Prior writeup:** [Search vs E2E correlation analysis](./search-vs-e2e-correlation-may01.md)
**Sequel:** [Paper framing — what's actually defensible](./search-vs-e2e-paper-framing-may01.md)
**Data:** `docs/data/v2b-localized-failure-typology.jsonl`, `docs/data/v2b-localized-failure-summary.csv`

---

## TL;DR

A colleague asked: when the e2e agent fails, did it actually read the necessary files? The natural prior is "no — failed trials probably failed to localize." We tested this directly across all four frontier coding agents on v2b.

**Three findings, in order of strength:**

1. **The aggregate "failed-trials-localized-better" pattern is a Simpson's-paradox artifact**, not a real result. After stratifying by task difficulty, resolved trials have *slightly higher* implicit-search recall than failed trials in every difficulty bin (delta ≈ −5 to −6 points). The aggregate inversion is driven by failed trials concentrating on hard tasks, which legitimately demand more probing.

2. **But the cleanest evidence still favors "patch is the bottleneck"**: 64 (model, task) pairs across 4 agents had `exam_file_recall = 1.0` *and* failed e2e. By construction, localization isn't the gap on those trials. Three of those pairs even had every model commit to 100% of gold files; all still failed.

3. **A rigorous failure-mode classifier on those 64 pairs** finds three dominant patterns:
   - **F2P_PARTIAL (67% of cases)**: agent flipped some F2P tests but not all — patch was on the right track but incomplete
   - **F2P_NONE (27%)**: agent made zero forward progress — wrong approach entirely
   - **P2P_REGRESSION (6%)**: agent broke a previously-passing test — over-eager fix
   - 0% syntax/import errors — the patches all applied and ran

   Per-model differences are real: codex's failures are mostly partial-fixes (closest to right), qwen's are mostly wrong-approach (taking left turns). Opus has zero F2P_NONE in this population — when opus localizes, it always at least partially fixes.

The right paper framing is **not** "search isn't the bottleneck" (overclaim) but rather **"on a localization-exhausted sub-benchmark of 64 trials, patch generation produces a typology of failure modes dominated by partial-correctness rather than radical mislocalization."**

---

## Setup

### Data

- **e2e baselines** (one tarball per model, v2b cohort with 92 tasks):
  - `v2b-baseline-codex-gpt-5.5-xhigh-20260429.tar.gz` (codex, 90 trials)
  - `v2-baseline-claude-opus-4-7-20260427.tar.gz` (opus47 — 92 v2b-overlapping trials)
  - `v2-baseline-opencode-haiku-4-5-20260427.tar.gz` (haiku45 — 91)
  - `v2-baseline-qwen3.6-vllm-20260428.tar.gz` (qwen36 — 91)
  - Total: **364 trials × 4 models** on v2b

- **Patch-derived gold** (`references/v2b-patch-gold.json`, 92 v2b tasks): files modified by `solution/changes.patch`, with functions located via AST-walk over the pre-patch source. Mean 12 files / 19 functions per task.

### Method

`scripts/score_e2e_implicit_search.py` walks each trial's transcript and extracts:

- **examined_*** — files/functions the agent referenced via Read, bash commands, observation output, agent text. Broad signal.
- **committed_*** — files/functions the agent edited via apply_patch / Edit / Write / NotebookEdit. Strict.

Function-name matching uses bare-name + file-co-location: a gold function counts as examined only when its bare name appears in the trajectory AND the gold's containing file is also examined.

Three transcript formats supported:
- **codex** (ATIF): `exec_command` + `apply_patch` DSL (`*** Update File: <path>`)
- **opencode** (ATIF): `bash` / `read` / `edit` / `write` + `task` (subagent — opaque)
- **claude-code** (NDJSON adapter): `Bash` / `Read` / `Edit` / `Write` / `MultiEdit`

---

## Phase 1: aggregate result (and why it's misleading)

```
                resolved        failed          delta (failed-resolved)
codex55  exam_file_recall   0.823 (n=52)  0.787 (n=38)   −0.04   (resolved higher)
opus47   exam_file_recall   0.588 (n=45)  0.674 (n=47)   +0.09   (failed higher)
qwen36   exam_file_recall   0.555 (n=12)  0.645 (n=79)   +0.09   (failed higher)
haiku45  exam_file_recall   0.567 (n=23)  0.630 (n=68)   +0.06   (failed higher)
```

Reading naively: three of four models' failed trials examined more of the gold area than their resolved trials. That looks like the *opposite* of "search is the bottleneck."

**This is a Simpson's paradox.** Failed and resolved trials don't share task-difficulty. Failed trials concentrate on hard tasks; hard tasks legitimately require more probing.

### Difficulty-stratified view

Tasks binned by cohort-wide e2e resolution rate (across all models):
- **easy** = ≥75% of trials resolved (n=21 tasks)
- **medium** = 25-75% resolved (n=39 tasks)
- **hard** = <25% resolved (n=32 tasks)

| Difficulty | resolved mean | failed mean | delta (failed−resolved) | n_resolved | n_failed |
|---|---:|---:|---:|---:|---:|
| easy | 0.614 | 0.561 | **−0.054** | 70 | 14 |
| medium | 0.741 | 0.678 | **−0.063** | 62 | 93 |
| hard | (no resolveds by definition) | 0.660 | — | 0 | 125 |

**Within difficulty bins, resolved trials have higher recall than failed trials.** The deltas are small (5-6 percentage points) but consistently in the colleague-predicted direction.

So: **the colleague's hypothesis was directionally correct.** Resolved trials *do* localize slightly better. The aggregate inversion was an artifact of pooling across difficulty.

That said: the deltas are small (5-6 points), and the absolute recall on failed trials is high (0.56-0.68). Even on failed trials at any difficulty, agents see the majority of the gold area. So the corrected story is:

> *"Resolved trials localize a bit better than failed trials when controlling for difficulty, but the gap is small. On a substantial fraction of failed trials, agents localized the gold area completely and still failed."*

That last sentence is the bridge to phase 2.

---

## Phase 2: the localization-exhausted sub-benchmark

### Population

Define a (model, task) pair as **fully-localized** when `exam_file_recall = 1.0`: the agent's trajectory mentioned every gold-edited file in some Read / bash / observation. Restrict further to trials where `e2e_resolved = 0`.

|  | n |
|---|---:|
| Total fully-localized failures across 4 models | **64 (model, task) pairs** |
| Distinct tasks with at least one fully-localized failure | 31 |
| Strict subset: also `comm_file_recall = 1.0` (committed to every gold file) | 31 pairs |
| Distinct tasks where every model fully-localized AND every model failed | 10 |
| Cross-model pairs where every model committed to all gold files and failed | 3 |

Per-model counts:

| Model | Fully-localized failures | % of model's failures |
|---|---:|---:|
| codex55 | 19 | 50% (of 38) |
| qwen36 | 20 | 25% (of 79) |
| haiku45 | 13 | 19% (of 68) |
| opus47 | 12 | 26% (of 47) |

These 64 pairs are the cleanest qualitative dataset for the paper. **Localization isn't the gap on these by construction.** Whatever happened, it happened after.

### Auto-classification of failure modes

`scripts/classify_localized_failures.py` reads each trial's `verifier/reward.json`, `verifier/test-stdout.txt`, and trajectory, then applies rule-based flags to characterize the failure. Output is at `docs/data/v2b-localized-failure-typology.jsonl` (per-trial structured records) and `docs/data/v2b-localized-failure-summary.csv` (aggregate distribution).

#### Primary failure-class distribution (n=64)

Primary class assigned by precedence: PATCH_APPLY_FAILED > TYPE_OR_IMPORT_ERROR > P2P_REGRESSION > F2P_NONE > F2P_PARTIAL.

| Primary class | n | % |
|---|---:|---:|
| **F2P_PARTIAL** (some F2P tests pass, not all) | 43 | **67%** |
| **F2P_NONE** (zero F2P tests pass) | 17 | 27% |
| **P2P_REGRESSION** (broke a previously-passing test) | 4 | 6% |
| PATCH_APPLY_FAILED | 0 | — |
| TYPE_OR_IMPORT_ERROR | 0 | — |

**Zero syntax-level failures.** Every patch applied, every test ran. The failures are all about *what the patch does*, not whether it could be applied.

#### Multi-label flag distribution

Tracking secondary characteristics of each failure (each trial can carry multiple flags):

| Flag | n | % | Interpretation |
|---|---:|---:|---|
| F2P_PARTIAL | 45 | 70% | Agent's edit moved some F2P tests but not all |
| F2P_NONE | 17 | 27% | Agent's edit moved zero F2P tests |
| COMMITTED_BROADER | 34 | 53% | Agent edited files NOT in the gold patch |
| COMMITTED_NARROWER | 33 | 52% | Agent saw all gold files but edited fewer than gold |
| AGENT_DIFF_HUGE | 20 | 31% | Agent's diff is >3× the gold patch (over-engineering) |
| AGENT_DIFF_TINY | 8 | 13% | Agent's diff is <30% the gold patch (insufficient) |
| P2P_REGRESSION | 4 | 6% | At least one P2P test broke |

**The most striking pattern is the COMMITTED_BROADER + COMMITTED_NARROWER overlap**: more than half the trials show *both* — the agent didn't edit some of the gold files AND edited unrelated files instead. Triage failures, not blindness.

The diff-size signals are also telling: 31% of fully-localized failures involve an agent diff more than 3× the gold patch — agents over-engineering when they don't get it right on the first attempt.

#### Per-model breakdown

| Model | n | F2P_PARTIAL | F2P_NONE | P2P_REGRESSION | dominant |
|---|---:|---:|---:|---:|---|
| codex (gpt-5.5/xhigh) | 19 | 15 (79%) | 1 | 3 | **partial fixes** |
| opus47 (xhigh) | 12 | 11 (92%) | 1 | 0 | **partial fixes (highest rate)** |
| haiku45 (medium) | 13 | 8 (62%) | 5 | 0 | mostly partial, some no-progress |
| qwen36 (vllm) | 20 | 9 (45%) | 10 (50%) | 1 | **wrong approach** |

The model rank order on "ability to at least partially fix when fully localized":

1. **opus47** (92%) — when opus localizes, it almost always makes some progress
2. **codex55** (79%)
3. **haiku45** (62%)
4. **qwen36** (45%) — half the time qwen takes a wrong approach despite seeing the right files

This rank order matches the e2e resolution-rate ranking (codex/opus tied for top, then haiku, then qwen) and the dedicated-search ranking. Even on the constrained sub-benchmark of fully-localized failures, **the same capability gradient shows up**.

---

## Worked examples

### F2P_PARTIAL: codex on `t2v3-AUb452-regex-character-class-support`

The benchmark: regex character-class fix in `automata`. Codex examined every gold file, committed to 1 of 1 gold files, plus one extra. F2P went from 0/10 to 1/10. Diff ratio: 1.87× the gold patch.

**Read:** the agent had the right localization, made an edit that fixes one specific case, but missed the broader pattern (the gold patch generalizes to all character-class types; agent fixed only one). Classic "fixed one symptom of the bug" failure.

### F2P_NONE: opencode/qwen on `t2v3-ADd1f1-eval-service-integration`

ADK Python eval service. Qwen examined every gold file, committed to all 4 gold files, made a diff 2.7× the gold patch — and zero F2P tests now pass. Same task: codex got 0/4 too with diff ratio 0.94.

**Read:** the issue isn't size of diff or which files. The agent's *idea of what to do* is wrong. This is a candidate for re-prompting with the gold structure: if it still fails, the gap is genuinely about understanding the test contract.

### P2P_REGRESSION: codex on `t2v3-PY99e9-cypher-multi-optional-with-chain`

Pygraphistry cypher feature. Codex examined every gold file, made a diff 2.4× the gold patch. F2P went 25/25 (success!) — but it broke 1 P2P test. By the verifier's strict "resolved = all F2P pass AND no P2P regression" rule, this counts as a failure even though the F2P side is perfect.

**Read:** this is the most interesting subcategory. The agent **did the thing** but introduced a side effect. Common pattern: agent over-eagerly refactors a shared helper and breaks an unrelated caller. Worth digging into for the paper because it's the cleanest "patch correctness" failure: the localization is exact, the F2P is perfect, only the P2P side is broken.

---

## What this changes vs the earlier writeups

| Claim | Initial writeup | Followup v1 (codex) | Earlier v2 (4 models) | This rigorous version |
|---|---|---|---|---|
| Per-task search ↔ e2e correlation is null | ✓ supported | (not addressed) | ✓ supported | ✓ supported |
| Failed-trial recall is HIGHER than resolved | (not measured) | ≈ tied for codex | ✓ for 3/4 models | **artifact: disappears under difficulty stratification** |
| Search is NEVER the bottleneck | overclaimed | for codex | for 4 models | **partially: small but real recall gap within difficulty bins** |
| Patch generation has identifiable failure modes | (not addressed) | (not addressed) | (not addressed) | ✓ **F2P_PARTIAL dominates (67%)** |
| Failure modes vary by model | (not addressed) | (not addressed) | (not addressed) | ✓ **opus 92% partial-fix rate; qwen 50% no-progress rate** |

---

## Limitations

- **n is small per model on failed trials.** Per-model counts of failed trials range from 38 (codex) to 79 (qwen). Per-trial recall numbers have wide CIs.
- **opencode subagent invisibility.** When opencode/qwen or opencode/haiku delegates to a `task` subagent, we can't see the subagent's internal tool calls. We only capture the prompt text. This biases their implicit-search measurement *downward* — actual recall is at least as high as we observe. The story doesn't change but the magnitude could.
- **Examined-files precision is very low** (~3-5%) because broad probing surfaces hundreds of files. Recall is the meaningful signal here, not F1.
- **Function precision via co-location is artificially 100%** by construction (we only count function-name matches when the containing file is also examined). This filters out generic-name false positives but means precision isn't directly comparable to dedicated-search F1.
- **v2 vs v2b cohort.** Three of four tarballs are over the v2 cohort, of which only ~91 tasks are in v2b. The 113 non-v2b trials per tarball are excluded.
- **Rule-based classification has gaps.** The auto-classifier flags structural failure modes (F2P-pass count, P2P regressions, diff size) but doesn't characterize *semantic* failure modes (wrong invariant, wrong exception type, wrong default value, etc.). For a paper section, the 64 trials should also get human review for a finer taxonomy. Estimated effort: ~1.5 person-days at 9 min/trial.

---

## Open follow-ups

Documented in detail in [the paper-framing doc](./search-vs-e2e-paper-framing-may01.md). Highest-leverage next steps:

1. **Causal re-prompt experiment** (Story C in the framing doc): run the 31 strict-cases with the gold file/function set provided as a localization hint. If agents now succeed, localization was the gap. If they still fail at the same rate, patch correctness is conclusively the dominant capability gap. Estimated: 2 days, depends on harbor capacity.

2. **Human-reviewed semantic typology** on the 64 fully-localized failures. Two reviewers, 9 min/trial, 20-trial overlap for inter-annotator agreement. Likely produces sub-classes within F2P_PARTIAL and F2P_NONE that are paper-worthy.

3. **Curated-gold sensitivity audit**: rescore the 49-task v2b∩search overlap against the search-curated gold (which has alts) and see whether the headline numbers change qualitatively. The patch-derived gold is conservative; if the asymmetry holds under curated gold too, the conclusion is more robust.

---

## Reproduction

```bash
# 1. Patch-derived gold (one-time, ~5 min including network)
uv run python scripts/extract_v2b_patch_gold.py \
  --tasks-dir ~/projects/craft-bench/harbor-tasks/craft-taskgen-v2b \
  --output references/v2b-patch-gold.json

# 2. Per-model implicit-search scoring
for label in codex opus haiku qwen; do
  case $label in
    codex)  src=/tmp/e2e-codex-full/jobs/v2b-codex-gpt55-xhigh ;;
    opus)   src=/tmp/e2e-opus/jobs/v2-opus47-claude ;;
    haiku)  src=/tmp/e2e-haiku/jobs/v2-haiku-opencode ;;
    qwen)   src=/tmp/e2e-qwen/jobs/v2-qwen36-opencode ;;
  esac
  uv run python scripts/score_e2e_implicit_search.py \
    --e2e-roots $src \
    --patch-gold references/v2b-patch-gold.json \
    --output /tmp/e2e-implicit-${label}.csv
done

# 3. Failure-mode classification on the 64 fully-localized failures
uv run python scripts/classify_localized_failures.py \
  --implicit-csvs /tmp/e2e-implicit-codex.csv /tmp/e2e-implicit-opus.csv \
                  /tmp/e2e-implicit-haiku.csv /tmp/e2e-implicit-qwen.csv \
  --e2e-roots /tmp/e2e-codex-full /tmp/e2e-opus /tmp/e2e-haiku /tmp/e2e-qwen \
  --tasks-dir ~/projects/craft-bench/harbor-tasks/craft-taskgen-v2b \
  --output-jsonl docs/data/v2b-localized-failure-typology.jsonl \
  --output-summary docs/data/v2b-localized-failure-summary.csv
```
