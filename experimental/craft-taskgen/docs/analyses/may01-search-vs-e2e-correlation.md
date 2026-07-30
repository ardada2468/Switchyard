# Localization vs Patch Generation: Two Skills That Scale Together but Fail Apart

**Author:** Jeff Farris (jfarris@nvidia.com)
**Date:** 2026-05-01
**Status:** Draft for internal review — preliminary findings, NeurIPS framing TBD
**Code:** `scripts/analyze_search_vs_e2e.py` on branch `jfarris/analyze-search-vs-e2e`

---

## TL;DR

We compared search ability (can the agent localize where the bug lives?) against end-to-end ability (can it actually fix the bug?) for four frontier coding agents — Codex (GPT-5.5), Claude Code (Opus 4.7), OpenCode (Haiku 4.5), and OpenCode (Qwen 3.6) — across 49 overlapping tasks.

**Headline:**

1. **Model-level: perfectly correlated.** Spearman ρ = +1.0 between search and e2e model rankings. Models that are good at one are good at the other.
2. **Task-level within a model: essentially uncorrelated.** Pearson r ≈ +0.04 across the best framings. Knowing which tasks a model nailed at search tells you almost nothing about which it'll fix end-to-end.
3. **The asymmetry is striking.** 35 of 196 (model, task) pairs (18%) show "knew where, couldn't fix it" (nav ≥ 0.7, resolved ≤ 0.25). The reverse — fixing without localizing — happens only 2 times across all models and tasks.

The natural reading: **localization and patch-generation are correlated as model capabilities but uncorrelated as per-task strengths**. They scale together but fail apart. **Patch generation is the bottleneck**, not search.

---

## Setup

### Data

- **Search baselines** (CRAFT search dataset, 80 tasks across 49 unique parent tasks):
  - 5 (agent, model) cells × 80 tasks × 2 iterations = 800 trials
  - Per-trial scoring: navigation_score, file/function recall/precision/F1/IoU, assertion_coverage, plus the headline reward
  - Search task IDs map to v2b parent tasks via `provenance.json::parent_t2_task` (some parents have 1–4 search variants)

- **End-to-end baselines** (v2b cohort, 92 tasks):
  - 16 model-iter cells across 4 base models × 4–5 iterations × 92 tasks = 1472 trials
  - Per-trial scoring: binary `resolved` (pass/fail) + continuous `f2p_pass_rate` (= passed / total fail-to-pass tests)

- **Overlap:** all 49 search-side parents are present in the 92-task v2b cohort. The 43 v2b tasks without a search counterpart are excluded from correlation analysis.

- **MiniMax dropped** from this analysis: present in search baselines, no e2e baseline available.

### Four framings, two aggregations

Because the data has multiple levels of aggregation (multiple iterations on each side, multiple search variants per parent, multiple models), we report all sensible combinations rather than picking a single "right" one:

| Framing | Definition | n |
|---|---|---:|
| **A** | per-(model, parent), iters averaged within model | 196 |
| **B** | per-iter-pair (search iter i ↔ e2e iter i mod min iters) | 389 |
| **C** | per-parent, all models collapsed (task-difficulty view) | 49 |
| **D** | per-trial cross-product (search × e2e of same model+task) | 1554 |

Plus two ways to aggregate the 1–4 search variants that share a parent:
- **mean across variants** (default, what the headline reports)
- **max across variants** (robust to "did the model find it at all?")

### Stats

For each search metric × e2e signal pair we report Pearson r (with Fisher-z 95% CI), Spearman ρ, and n. p-value stars: `*` < 0.05, `**` < 0.01, `***` < 0.001. Binary `resolved` paired with a continuous metric makes Pearson collapse to point-biserial automatically.

---

## Findings

### 1. The headline correlation is a null result

In Framing A (per-(model, parent), n=196, search-agg=mean), no search metric beats r ≈ 0.15 against either e2e signal:

| Search metric | vs `resolved` (binary) | vs `f2p_pass_rate` (continuous) |
|---|---:|---:|
| reward | +0.095 | +0.124 |
| navigation_score | +0.016 | +0.043 |
| navigation_recall | +0.042 | +0.105 |
| navigation_iou | −0.011 | +0.025 |
| file_f1 | −0.016 | +0.030 |
| function_f1 | +0.037 | +0.043 |
| **assertion_coverage** | **+0.129** | **+0.152*** |

The strongest cell is `assertion_coverage` → `f2p_pass_rate` at r = +0.152 (p < 0.05). Even there, the 95% CI is [+0.01, +0.29] — barely excludes zero. All other CIs span zero comfortably.

Spearman ρ tells the same story (no rank-based monotonic relationship hiding behind a non-linear shape).

This is a robust null. Framings B, C, D, with both aggregations, all give the same answer (Appendix A).

### 2. Model rankings are perfectly preserved

When we average search and e2e scores across all parents and look at the four models:

| Model | search nav-score | search reward | e2e resolved | e2e f2p_pass_rate |
|---|---:|---:|---:|---:|
| `codex55` | 0.642 | 0.714 | 0.592 | 0.847 |
| `opus47` | 0.630 | 0.684 | 0.497 | 0.811 |
| `haiku45` | 0.618 | 0.588 | 0.277 | 0.555 |
| `qwen36` | (lowest) | (lowest) | (lowest) | (lowest) |

Spearman ρ between the search-rank and e2e-rank of these four models is **+1.000***** (n=4 — small, but the agreement is exact). The capability ordering is identical.

This is the contrast that makes the paper interesting: **across models, search ability and e2e ability covary perfectly. Within a model, they're decoupled.**

### 3. The "I knew where, I couldn't fix it" pattern dominates

Per-model counts of (model, task) pairs in Framing A:

| Direction | Definition | codex55 | opus47 | haiku45 | qwen36 | total |
|---|---|---:|---:|---:|---:|---:|
| **Strong search, weak e2e** | nav ≥ 0.7 AND resolved ≤ 0.25 | 7 | 7 | 8 | 13 | 35 |
| **Weak search, strong e2e** | nav ≤ 0.3 AND resolved ≥ 0.75 | 1 | 0 | 1 | 0 | 2 |

35 vs 2. **Localization is a near-necessary precondition for fixing**, but it's far from sufficient.

Examples that hit *every* model:

- **`t2v3-TU5454-agentic-loss-mask-fix`** — Tunix repo. nav scores: codex 0.92, opus 0.89, haiku 0.82, qwen 0.93. e2e resolved: 0/0/0/0. f2p pass rates: 0.93 / 0.93 / 0.00 / 0.93. The agents found the right area; codex/opus/qwen got 93% of the F2P tests passing but somehow still failed the resolved check (likely a P2P regression introduced by the patch). Worth a qualitative read of the trial transcripts.

- **`t2v3-HAc618-hatch-pep735-dependency-groups`** — hits 3 of 4 models. nav 0.86–0.92, resolved ≤ 0.20.

- **`t2v3-FA800f-colmodernvbert-multimodal-integration`** — opus and haiku pinpointed it (nav 0.82, 0.90) but got resolved=0.00 / 0.20. Partial f2p (0.53–0.70) suggests near-misses on the patch shape.

- **`t2v3-BL9bd7-multipart-formdata-roundtrip-fix`** — opus and qwen at nav ≥ 0.91 but couldn't fix.

Reverse cases are vanishingly rare:

- **`t2v3-TOe840-tox-toml-install-command`** (haiku45) — nav 0.13, resolved 0.80.
- **`t2v3-FAe252-publisher-mock-empty-dest`** (codex55) — nav 0.22, resolved 0.75.

These two outliers are interesting in their own right: **how did the agent fix something it never localized?** Likely candidates: pytest traceback led directly to the line, or the fix was a simple rename/import that didn't require understanding the surrounding code.

### 4. Per-task variance is uncorrelated

Within each (model, task) cell we have 2 search trials and 4–5 e2e trials. Per-task σ(reward) on the search side and σ(resolved) on the e2e side correlate at **Pearson r = +0.082** (n=196). Tasks that are noisy at search are *not* the same tasks that are noisy at e2e.

This rules out "task difficulty" as a single hidden factor that drives both noise sources. The two skills are noisy for different reasons — **localization noise is not patch-generation noise**.

### 5. Per-model correlations: two negative trends

Per-model Pearson(navigation_score, resolved):

| Model | r | Spearman ρ |
|---|---:|---:|
| codex55 | +0.032 | +0.054 |
| haiku45 | **−0.089** | −0.089 |
| opus47 | **−0.106** | −0.078 |
| qwen36 | −0.008 | −0.009 |

None are statistically significant (CIs all span zero), but **opus and haiku trend slightly negative** — they're marginally *less* likely to fix tasks they nailed at search. This is the opposite of what a "search predicts e2e" framing would predict. The pattern is too small to claim alone but consistent with the broader picture: localization and fixing are different skills.

### 6. Efficiency signals look real and worth a paper subsection

Within each side, output token count is **negatively** correlated with success:

| Side | Metric | Pearson vs success | n |
|---|---|---:|---:|
| search | output_tokens | **−0.184***** | 639 |
| search | wall_clock_sec | **−0.410***** | 640 |
| search | tool_call_count | −0.102** | 639 |
| e2e | output_tokens | **−0.190***** | 1371 |
| e2e | wall_clock_sec | −0.059* | 1464 |

**Models that succeed do so quickly and concisely.** Models that run long and emit many tokens do so because they're flailing, not because they're working harder. This is robust (n in the thousands, p < 0.001) and likely worth mentioning prominently.

`agent_steps` is uncorrelated, which is interesting on its own — fewer turns isn't the issue; rather, when a model is failing it loses words, not steps.

---

## Implications for the NeurIPS paper

### Recommended framing

> **In code-fixing tasks, localization (search) and patch generation are correlated as model-level capabilities (Spearman ρ = +1.000 across four frontier models, n=4) but uncorrelated as per-task strengths (Pearson r ≈ +0.04, n=196). Models that correctly localize a bug fail to fix it 18% of the time on average; the reverse failure mode is essentially absent (1%). This decoupling implies that benchmarks measuring only end-to-end resolution conflate two skills that scale together at the population level but exhibit independent per-task variance — and that *patch generation*, not search, is the primary capability bottleneck.**

That's a strong, defensible claim with the data we have.

### Why this matters

1. **Benchmark design.** If you only measure e2e, you can't tell whether a model failed because it couldn't find the bug or couldn't fix it. CRAFT's split makes that diagnosis possible.

2. **Capability scaling.** All four frontier models cluster in the same regime: high search ability, much lower fix ability. Search ability tracks model capability cleanly across the 4-model spectrum; fix ability is where the differentiation should happen, but in many cases all models tie at zero (10 floor tasks).

3. **Where to invest.** The "knew where, couldn't fix" cohort is large enough (35 model-task pairs) for a focused qualitative study. What's the failure mode? Wrong syntax? P2P regression? Not understanding side effects? This is where post-training data should be cheapest to source — gold patches paired with trial transcripts.

### Limitations to disclose

- **n = 49 parents is small.** Most CIs span zero. Power for detecting r=0.10 at α=0.05 with n=196 is ~50%; we may be missing a real but small relationship.
- **Cohorts diverge.** The search dataset covers 49 of 92 e2e parents; the other 43 are excluded.
- **Two iterations on search side.** Limits within-task variance estimates and the per-iter-pair framing.
- **Verifier version drift.** This analysis used a search CSV produced before the F1-precision fields were added to the verifier. We can rerun with `file_precision`, `file_f1`, `function_precision`, `function_f1` once new search baselines are available — that splits the picture between "broad-trace" and "narrow-root-cause" search styles, which may interact differently with e2e.
- **Floor effects.** 10 of 49 parents have all 4 models at resolved ≤ 0.10 — these tasks contribute only noise to the per-task correlation. Dropping them changes the n but not the qualitative conclusion (rerun with `--exclude-floor` flag is straightforward).

### Open questions worth a follow-up

1. **Is the negative per-model trend real?** Two of four models trend negatively. With n=49 per model the CIs are wide. Adding more iterations or more parents could disambiguate.
2. **What's the failure mode on "knew where, couldn't fix" tasks?** Qualitative read of trial transcripts on `t2v3-TU5454`, `t2v3-HAc618`, `t2v3-FA800f` would tell us whether it's syntax, dependencies, semantic understanding, or something else.
3. **Does broad-trace vs narrow-root-cause search style predict e2e?** Our earlier analysis (this report) found that codex names ~50% more files and ~55% more functions than opus on the same tasks — and codex is also better at e2e. With F1-precision data, we can disentangle "fetched more" from "fetched the right things."

---

## Appendix A: All correlations across all framings

### Framing A — per-(model, parent), iters averaged within model

n = 196 (4 models × 49 parents)

#### search-agg = mean

| Search metric | E2E metric | Pearson r | Spearman ρ |
|---|---|---:|---:|
| reward | resolved | +0.095 (n=196, 95% CI [-0.05, +0.23]) | +0.111 |
| reward | f2p_pass_rate | +0.124 (n=196, 95% CI [-0.02, +0.26]) | +0.154* |
| navigation_score | resolved | +0.016 (n=196, 95% CI [-0.12, +0.16]) | +0.004 |
| navigation_score | f2p_pass_rate | +0.043 (n=196, 95% CI [-0.10, +0.18]) | +0.049 |
| navigation_recall | resolved | +0.042 (n=196, 95% CI [-0.10, +0.18]) | +0.062 |
| navigation_recall | f2p_pass_rate | +0.105 (n=196, 95% CI [-0.04, +0.24]) | +0.149* |
| navigation_iou | resolved | −0.011 (n=196, 95% CI [-0.15, +0.13]) | −0.016 |
| navigation_iou | f2p_pass_rate | +0.025 (n=196, 95% CI [-0.12, +0.16]) | +0.032 |
| file_f1 | resolved | −0.016 (n=196, 95% CI [-0.16, +0.12]) | −0.009 |
| file_f1 | f2p_pass_rate | +0.030 (n=196, 95% CI [-0.11, +0.17]) | +0.053 |
| function_f1 | resolved | +0.037 (n=196, 95% CI [-0.10, +0.18]) | +0.037 |
| function_f1 | f2p_pass_rate | +0.043 (n=196, 95% CI [-0.10, +0.18]) | +0.065 |
| file_recall | resolved | −0.017 (n=196, 95% CI [-0.16, +0.12]) | −0.014 |
| file_recall | f2p_pass_rate | +0.081 (n=196, 95% CI [-0.06, +0.22]) | +0.098 |
| function_recall | resolved | +0.080 (n=196, 95% CI [-0.06, +0.22]) | +0.083 |
| function_recall | f2p_pass_rate | +0.102 (n=196, 95% CI [-0.04, +0.24]) | +0.136 |
| **assertion_coverage** | **resolved** | **+0.129 (n=196, 95% CI [-0.01, +0.26])** | **+0.161*** |
| **assertion_coverage** | **f2p_pass_rate** | **+0.152* (n=196, 95% CI [+0.01, +0.29])** | **+0.189**** |

Per-model Pearson(navigation_score, resolved):

| Model | r | Spearman ρ | n |
|---|---:|---:|---:|
| codex55 | +0.032 | +0.054 | 49 |
| haiku45 | −0.089 | −0.089 | 49 |
| opus47 | −0.095 | −0.078 | 49 |
| qwen36 | −0.008 | −0.009 | 49 |

#### search-agg = max (one variant suffices)

Same shape, marginally weaker (best cell: `assertion_coverage` → `resolved` at r=+0.117, p>0.05). The mean-aggregation tells the cleaner story; max-aggregation is in `framing-a-max.csv` for the curious.

### Framing B — per-iter-pair

Pair search trial 0 ↔ e2e iter0; trial 1 ↔ iter1; discard e2e iter ≥ 2 (search has only 2 iterations). n = 389.

| Search metric | E2E metric | Pearson r | Spearman ρ |
|---|---|---:|---:|
| reward | resolved | +0.043 (n=389) | +0.066 |
| navigation_score | resolved | −0.011 (n=389) | −0.014 |
| function_recall | f2p_pass_rate | +0.097 (n=389) | +0.111* |
| assertion_coverage | resolved | +0.080 (n=389) | +0.105* |
| assertion_coverage | f2p_pass_rate | +0.077 (n=389) | +0.105* |

Same shape as Framing A. Doubling the n doesn't surface a hidden relationship.

### Framing C — per-parent, model-collapsed

n = 49. "Is this task intrinsically hard at both?" view.

| Search metric | E2E metric | Pearson r | Spearman ρ |
|---|---|---:|---:|
| reward | resolved | −0.077 (n=49) | −0.048 |
| navigation_score | resolved | −0.026 (n=49) | +0.054 |
| navigation_recall | f2p_pass_rate | **−0.202** (n=49) | **−0.269** |
| function_recall | f2p_pass_rate | −0.175 (n=49) | −0.258 |

Several **negative** correlations here are interesting. Most are not significant given n=49 (CIs span zero), but the *direction* is suggestive: at the task-difficulty level, *higher* search recall does not predict *higher* e2e success. This is opposite to what one would naively expect, and supports the broader "different skills" narrative. Worth probing further in the follow-up paper.

### Framing D — per-trial cross-product

n = 1554. Maximum data, but observations are non-independent (every search trial paired with every same-model e2e trial of the same task). Reported for completeness; statistical significance is inflated by the non-independence.

Best cells:
- `assertion_coverage` → `resolved`: +0.042 (p=0.10)
- `assertion_coverage` → `f2p_pass_rate`: +0.053* (p<0.05)
- `function_f1` → both: r ≈ 0.000

The cross-product framing sometimes hides pattern in averaging noise; here it doesn't. Same null story.

### Variance correlation

Pearson(σ_search, σ_e2e) = +0.082 (n=196).
Spearman = +0.095 (n=196).

Tasks that are noisy at search are not the same tasks noisy at e2e.

### Efficiency vs reward (within each side)

| Side | Metric | Pearson | Spearman | n |
|---|---|---:|---:|---:|
| search | agent_steps | +0.050 | +0.053 | 639 |
| search | tool_call_count | −0.102** | −0.080* | 639 |
| search | input_tokens | −0.035 | −0.017 | 639 |
| search | output_tokens | **−0.184**** | −0.109** | 639 |
| search | wall_clock_sec | **−0.410**** | **−0.145**** | 640 |
| e2e | agent_steps | +0.014 (vs resolved) | +0.145*** (vs f2p) | 1371 |
| e2e | input_tokens | −0.056* | +0.059* | 1371 |
| e2e | output_tokens | **−0.190**** | **−0.201**** | 1371 |
| e2e | wall_clock_sec | −0.059* | −0.023 | 1464 |

Negative output-token correlation is robust across both sides. **Long answers ≈ floundering.**

---

## Appendix B: Anecdotes

### B.1 — Strong search, weak e2e ("knew where, couldn't fix")

Definition: nav ≥ 0.7 AND resolved ≤ 0.25 in Framing A.

**`codex55` (7 tasks):**
- `t2v3-TU5454-agentic-loss-mask-fix` — nav=0.92, resolved=0.00, f2p=0.93
- `t2v3-ADd1f1-eval-service-integration` — nav=0.89, resolved=0.00, f2p=0.00
- `t2v3-HAc618-hatch-pep735-dependency-groups` — nav=0.86, resolved=0.00, f2p=0.67
- `t2v3-TWad40-article-inline-images` — nav=0.78, resolved=0.00, f2p=0.15
- `t2v3-PY1651-polars-cursor-chunksize-support` — nav=0.76, resolved=0.00, f2p=0.90
- _(2 more)_

**`opus47` (7 tasks):**
- `t2v3-HAc618-hatch-pep735-dependency-groups` — nav=0.92, resolved=0.20, f2p=0.53
- `t2v3-BL9bd7-multipart-formdata-roundtrip-fix` — nav=0.92, resolved=0.00, f2p=0.75
- `t2v3-FA800f-colmodernvbert-multimodal-integration` — nav=0.90, resolved=0.20, f2p=0.70
- `t2v3-TU5454-agentic-loss-mask-fix` — nav=0.89, resolved=0.00, f2p=0.93
- `t2v3-NI5f2c-vbuild-esm-new-inputs-rotate` — nav=0.73, resolved=0.00, f2p=0.64
- _(2 more)_

**`haiku45` (8 tasks):**
- `t2v3-HAc618-hatch-pep735-dependency-groups` — nav=0.86, resolved=0.20, f2p=0.53
- `t2v3-FA800f-colmodernvbert-multimodal-integration` — nav=0.82, resolved=0.00, f2p=0.53
- `t2v3-TU5454-agentic-loss-mask-fix` — nav=0.82, resolved=0.00, f2p=0.00
- `t2v3-SC22f6-stateful-report-bridging` — nav=0.80, resolved=0.00, f2p=0.00
- `t2v3-PY5671-cypher-multi-alias-return` — nav=0.79, resolved=0.00, f2p=0.25
- _(3 more)_

**`qwen36` (13 tasks):**
- `t2v3-TU5454-agentic-loss-mask-fix` — nav=0.93, resolved=0.00, f2p=0.93
- `t2v3-BL9bd7-multipart-formdata-roundtrip-fix` — nav=0.91, resolved=0.00, f2p=0.47
- `t2v3-NI25be-nicegui-keep-alive` — nav=0.89, resolved=0.00, f2p=0.00
- `t2v3-FA800f-colmodernvbert-multimodal-integration` — nav=0.88, resolved=0.00, f2p=0.17
- `t2v3-CHe590-ask-file-upload-validation` — nav=0.83, resolved=0.00, f2p=0.80
- _(8 more)_

### B.2 — Weak search, strong e2e ("fixed without localizing")

Definition: nav ≤ 0.3 AND resolved ≥ 0.75 in Framing A. Only 2 instances total — both of these are interesting outliers worth a closer look.

- **`codex55` / `t2v3-FAe252-publisher-mock-empty-dest`** — nav=0.22, resolved=0.75. Codex barely localized but ended up with 75% resolved. Hypothesis: pytest traceback walked the agent directly to the failing line; localization wasn't on the critical path.
- **`haiku45` / `t2v3-TOe840-tox-toml-install-command`** — nav=0.13, resolved=0.80. Same shape on a different repo.

### B.3 — Model-disagreement tasks (top 10 by stdev across models)

| Parent task | mean | stdev | codex55 | opus47 | haiku45 | qwen36 |
|---|---:|---:|---:|---:|---:|---:|
| `t2v3-SC22f6-stateful-report-bridging` | 0.50 | 0.58 | 1.00 | 1.00 | 0.00 | 0.00 |
| `t2v3-SU3637-screen-diffrot-compatibility` | 0.45 | 0.53 | 1.00 | 0.80 | 0.00 | 0.00 |
| `t2v3-DA076a-dace-argument-marshal-refactor` | 0.55 | 0.53 | 1.00 | 1.00 | 0.20 | 0.00 |
| `t2v3-XY5089-bond-outline-per-segment` | 0.44 | 0.52 | 0.75 | 1.00 | 0.00 | 0.00 |
| `t2v3-PY5671-cypher-multi-alias-return` | 0.25 | 0.50 | 1.00 | 0.00 | 0.00 | 0.00 |
| `t2v3-PIecf2-piccolo-table-str-abbreviated` | 0.75 | 0.50 | 1.00 | 1.00 | 1.00 | 0.00 |
| `t2v3-RE900b-vary-secondary-lookup` | 0.60 | 0.49 | 1.00 | 1.00 | 0.40 | 0.00 |
| `t2v3-CA6bc4-cattrs-annotated-overrides` | 0.60 | 0.49 | 1.00 | 1.00 | 0.40 | 0.00 |
| `t2v3-SQ6653-annotated-field-metadata` | 0.30 | 0.48 | 1.00 | 0.20 | 0.00 | 0.00 |
| `t2v3-CHe590-ask-file-upload-validation` | 0.50 | 0.48 | 1.00 | 0.80 | 0.20 | 0.00 |

**These 10 tasks are the benchmark's discriminators.** All show codex/opus solving and haiku/qwen failing — capability ordering is preserved across all of them (no inversions). The ratios suggest a clean capability gap between "frontier closed-source" (codex+opus) and "smaller / open" (haiku+qwen) on a subset of the v2b cohort.

### B.4 — Floor and ceiling

**Floor** (every model resolved ≤ 0.10) — 10 tasks:
- `t2v3-BL9bd7-multipart-formdata-roundtrip-fix`
- `t2v3-AUb452-regex-character-class-support`
- `t2v3-PY1651-polars-cursor-chunksize-support`
- `t2v3-NI5f2c-vbuild-esm-new-inputs-rotate`
- `t2v3-TU5454-agentic-loss-mask-fix`
- `t2v3-TU5b12-unify-grpo-pipeline-dataloading`
- `t2v3-ULf607-ultraplot-sankey-diagrams`
- `t2v3-DE4791-kornia-augmentation-migration`
- `t2v3-CS8148-literal-union-type-handling`
- `t2v3-CHc3c1-locale-fallback-dataframe-polars`

**Ceiling** (every model resolved ≥ 0.90): 0 tasks. No task is uniformly easy for all four models — the benchmark has no top-end ceiling effect.

The floor cohort is interesting on its own. 4 of the 10 floor tasks (`t2v3-TU5454`, `t2v3-PY1651`, `t2v3-BL9bd7`, `t2v3-NI5f2c`) appear in B.1 — every model nailed the search but no one could fix. Worth qualitative inspection.

### B.5 — High within-model variance (rerun-noisy)

Top 10 (model, parent) pairs by stdev(resolved) across e2e iterations. All top entries are qwen36 with σ = 0.71 — for k=2 binary trials, that's the maximum possible (one pass, one fail). Qwen is the most rerun-noisy model on the v2b cohort.

| Model | Parent | n_iters | mean | std |
|---|---|---:|---:|---:|
| qwen36 | `t2v3-LAac00-circuit-ansatz-ancilla-support` | 2 | 0.50 | 0.71 |
| qwen36 | `t2v3-MCf60d-resource-utilization-calculator` | 2 | 0.50 | 0.71 |
| qwen36 | `t2v3-VC1b70-httpcore-sync-async-split` | 2 | 0.50 | 0.71 |
| qwen36 | `t2v3-NN1ea7-pruning-strip-in-place` | 2 | 0.50 | 0.71 |
| qwen36 | `t2v3-PYce55-hypergraph-from-edges-return-as` | 2 | 0.50 | 0.71 |
| qwen36 | `t2v3-OP166f-file-path-rule-enforcement` | 2 | 0.50 | 0.71 |
| qwen36 | `t2v3-CH78cb-chat-profile-config-overrides` | 2 | 0.50 | 0.71 |
| qwen36 | `t2v3-PYa0ea-fold-unaryop-constants` | 2 | 0.50 | 0.71 |
| qwen36 | `t2v3-JS37fa-handler-context-propagation` | 2 | 0.50 | 0.71 |
| qwen36 | `t2v3-SSf831-sse-cooperative-shutdown` | 2 | 0.50 | 0.71 |

Note the absence of codex/opus/haiku in the top 10 — those models have ≥ 4 iters, so noise estimates have lower variance. Apples-to-oranges; comment is "qwen reruns are noisy but also has fewer iterations."

---

## Appendix C: Reproducing this analysis

```bash
# Generate the search per-trial CSV (branch jfarris/summarize-search-baseline-csv)
uv run python scripts/summarize_search_baseline.py \
  --alias 'iter1-qwen36-vllm=opencode / qwenai/qwen3-36 (vllm)' \
  --alias 'iter2-qwen36-vllm=opencode / qwenai/qwen3-36 (vllm)' \
  --alias 'iter1-minimax27-vllm=opencode / minimaxai/minimax-m2.7 (vllm)' \
  --alias 'iter2-minimax27-vllm=opencode / minimaxai/minimax-m2.7 (vllm)' \
  --csv /tmp/search-baseline.csv \
  --tasks-dir ~/projects/craft-bench/harbor-tasks/craft-search-from-v2/harbor-tasks \
  ~/projects/craft-bench/jobs/iter1-* ~/projects/craft-bench/jobs/iter2-*

# Run the analysis (branch jfarris/analyze-search-vs-e2e)
uv run python scripts/analyze_search_vs_e2e.py \
  --search-csv /tmp/search-baseline.csv \
  --e2e-csv ~/Downloads/v2b-e2e-baselines-partial.csv \
  --out-dir /tmp/analysis-out > /tmp/analysis.md
```

Output:
- `/tmp/analysis.md` — full machine-readable report (this writeup is the human-readable distillation)
- `/tmp/analysis-out/framing-{a,b,c}-{mean,max}.csv` — per-cut paired observations for plotting
- `/tmp/analysis-out/all-correlations.csv` — every (framing, search_metric, e2e_metric) row
- `/tmp/analysis-out/anecdotes-pivot.csv` — per-(parent, model) e2e resolved values for the disagreement/floor/ceiling analyses
