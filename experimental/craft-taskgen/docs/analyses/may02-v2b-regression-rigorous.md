# Evidence package: what the trajectory data tells us (and doesn't)

**Author:** Jeff Farris (jfarris@nvidia.com)
**Date:** 2026-05-02
**Status:** Internal — evidence-package for co-author conversation about the search track and broader trajectory analysis.
**Code:** branch `jfarris/analyze-search-vs-e2e`
**Data:** [`docs/data/v2b-deep-dive-per-trial.csv`](./data/v2b-deep-dive-per-trial.csv) (n=364), [`docs/data/v2b-first-half-per-trial.csv`](./data/v2b-first-half-per-trial.csv) (n=364), [`docs/data/v2b-regression-results.{md,json}`](./data/)
**Prior writeups:** [deep-dive (descriptive)](./v2b-deep-dive-summary.md), [paper framing](./search-vs-e2e-paper-framing-may01.md)

---

## TLDR — what the data says

Across 364 end-to-end coding trials over four frontier agents (codex55, opus47, haiku45, qwen36), we ran a multivariate logistic regression of trial resolution on 12 trajectory-derived behavioral features, plus length/complexity controls and model fixed effects.

1. **Model identity carries most of the predictive content.** 5-fold CV-AUC is 0.693 from model identity alone, 0.706 with all 12 behavioral features added — behavior contributes +0.013 AUC over model identity. Holding behavior constant, fitted odds ratios vs codex55 are ~17× lower for qwen36, ~9× for haiku45, ~2.4× for opus47.

2. **Localization recall is not correlated with end-to-end success in this dataset.** Single-feature correlation r ≈ 0 for both "did the agent read the right files?" (r = −0.004) and "did the agent edit the right files?" (r = −0.003). Separately, the dedicated search benchmark scores agents at mean nav 0.54 against curated gold vs 0.18 against patch-derived gold — a 3× gap depending on which gold definition is used.

3. **Of the 12 behavioral features, only `tests_per_step` is significant under joint control.** β = +0.439, p = 0.031 (1 SD raises odds ~1.55×); the other 11 are not significant. The v1 deep-dive's "tests-per-edit ratio" univariate signal (r = +0.207) is p = 0.54 under joint control with length included.

The 12 features cover search recall, edit volume, thrashing, test density, decomposition, self-introspection, and probe-fraction.

---

## How we did this analysis (and why)

### The question

We have 364 end-to-end coding trials across four frontier agents (codex55, opus47, haiku45, qwen36). For each trial we know the outcome (`resolved ∈ {0,1}`, ~38% resolved overall) and a rich trajectory log of what the agent did — every file read, every bash command, every edit, every test invocation. The descriptive analysis ([v1 deep-dive](./v2b-deep-dive-summary.md)) found a striking pattern: successful trials had a tests-per-edit ratio of 0.95 vs 0.54 in failed trials. That looked like a clean behavioral signature of success. The question this analysis answers: **does that pattern survive when we control for the obvious confounds, or does it dissolve into something else?**

### Why descriptive analysis wasn't enough

The v1 finding has three immediate problems that any reviewer would press on:

1. **Reverse causality.** When an agent succeeds, the verifier passes and the trial ends. So successful trials have *fewer total edits* almost by construction (you stop editing when you're done). Failed trials keep editing because nothing has worked yet. A higher tests-per-edit ratio in resolved trials could just mean "denominator is smaller because the trial ended early," not "successful agents test more aggressively."

2. **Multicollinearity.** `tests_per_edit`, `tests_per_step`, `n_test_invocations`, `n_steps`, `n_edit_calls` are mathematically related — knowing any three pins the others. A univariate correlation between `tests_per_edit` and success could be reflecting any of those underlying signals. We need to fit them jointly to see which one carries the predictive content.

3. **Heterogeneity across models.** Codex's tool architecture surfaces ~250 file paths per trial through `exec_command` (it runs rg/grep/sed). Claude-code's `Read` tool registers one file per call; mean ~45 files per trial. Pooling four models with different transcript shapes risks attributing model-architecture differences to "behavior" — when really we're just measuring how the same underlying activity gets logged.

### The design

To address all three, we ran a **multivariate logistic regression** with three carefully chosen design choices:

**1. Twelve behavioral features + two controls + three model fixed effects.**

The behavioral features cover four conceptual buckets — *what the agent searched* (4 features), *how it edited* (2 features), *how it allocated time* (3 features), *whether it verbalized the right diagnosis* (1 feature) — plus controls for trial length and task complexity, plus dummy variables for which model ran the trial. Standardized to mean=0, SD=1 so coefficients are directly comparable across features.

The model fixed effects are critical. Without them, "codex examines 250 files and codex succeeds 58% of the time" looks like "examining files predicts success." With them, that effect is absorbed into the codex dummy, and we're left with the within-model behavioral signal — which is what the question is actually asking about.

**2. Logistic regression with mild regularization.**

Logistic because the outcome (`resolved` ∈ {0,1}) is binary. We add a small L2 penalty (λ = 0.01) on the weights so the optimizer doesn't blow up if any feature is degenerate. Implementation is the standard Newton-step solver, ~30 lines, no external stats dependency required. See `scripts/regress_e2e_resolution.py`.

**3. Three regression variants, run in sequence.**

  - **Pooled** — single regression, n = 346 (after dropping degenerate trials with no edits and no tests), all 4 models pooled with model FE absorbing capability differences. This is the headline.
  - **Per-model** — refit on each model's trials separately (n = 73–92 per model). Diagnoses heterogeneity: does the same predictor work for every model, or only for some?
  - **First-half-only** — rebuild every feature using only the first half of each trial's steps. This is the reverse-causality control. If "successful trials end early so they have proportionally more tests" is the whole story, restricting to the first half should kill the test-density signal. If the signal survives, it's not just a length artifact.

### Validation: held-out predictive accuracy via cross-validation

In-sample fit metrics overfit when you have 12 features and only 346 trials. To check that the regression generalizes, we use **5-fold cross-validation**: fit on 80% of trials, predict on the held-out 20%, repeat across all 5 folds, and average the predictive accuracy.

The accuracy metric is **AUC** (area under the ROC curve), which captures "if you pick a random resolved trial and a random failed trial, what's the probability the model assigns higher score to the resolved one?". AUC = 0.5 is random guessing; 1.0 is a perfect classifier. Conventional reading: 0.7 is "fair", 0.8 is "good", 0.9+ is "excellent."

We run this for five nested feature combinations (just model identity; just behavior; behavior + controls; full model; controls alone). The differences across these specifications tell us how much predictive power each feature group adds.

### What we couldn't do (limitations)

- **No within-task variance**: each (model, task) appears once in our data. Including multiple trials per (model, task) would let us partition variance into task-level + model-level + within-task-rerun-noise. We don't have that here.
- **No causal manipulation**: the regression establishes correlation under controls. Strict causation requires intervention — e.g. force higher test-running density via prompt engineering and see if resolution rates rise. The first-half-only check is *suggestive* of causation but not conclusive.
- **n = 346 is small** for a 15-variable regression. Per-model n=73–92 is borderline (rule-of-thumb is 10–20 cases per parameter; we're at 6–8). Per-model results should be read as suggestive, not conclusive.
- **Multiple-testing concerns**: we ran 12 candidate predictors × 4 per-model regressions = 48 hypothesis tests total. With that many tries, finding one or two "significant" results at p < 0.05 by chance alone is expected. To call a single per-model result truly significant we'd want p < 0.001 (a strict correction for testing 48 hypotheses). Only opus47's `tests_per_step` (p = 0.0008) clears that bar.

The rest of this document walks through the 12 features, the pooled regression's coefficients, the first-half robustness check, and the cross-validated predictive-accuracy breakdown that supports the TL;DR claim.

---

## What we tested: the 12 behavioral features (in plain English)

Each feature is computed per-trial. The right column shows the Pearson correlation between that feature and `resolved ∈ {0,1}` — looking at one feature in isolation. r = 0 means no relationship; r > 0 means the feature tends to be higher in resolved trials; r < 0 the opposite. (This is just the simplest "does this feature alone predict success" check, before we put everything in a regression together.)

### Search behavior — what files did the agent look at?

| Feature | What it measures | Mean | Resolved mean | Failed mean | Univariate r |
|---|---|---:|---:|---:|---:|
| `exam_file_recall` | fraction of gold files agent **read or referenced** | 0.68 | 0.674 | 0.676 | **−0.004** |
| `comm_file_recall` | fraction of gold files agent **edited** | 0.50 | 0.497 | 0.499 | **−0.003** |
| `n_examined_files` | total files examined (any source) | 99 | 126 | 83 | +0.128 |
| `frac_test_files` | fraction of examined files that match `test_*.py` / `tests/` | 30% | 32.9% | 28.8% | +0.096 |

**Reading is the headline null result.** Both `exam_file_recall` and `comm_file_recall` have univariate correlations of ~0 with success. **Knowing whether the agent read the right files tells you nothing about whether it succeeded.** The "which files" question is dead as a predictor.

`n_examined_files` looks promising in the single-feature view (r = +0.128) but this is mostly because codex (which has the highest success rate) probes ~250 files via rg/grep while opus/haiku/qwen probe ~45. Once we control for which model is running, the effect vanishes (joint regression coefficient ≈ 0).

`frac_test_files` is a small positive: successful agents proportionally read 4 percentage points more test files (33% vs 29%). Modest, doesn't survive joint control either.

### Editing behavior — what did the agent do once it started editing?

| Feature | What it measures | Mean | Resolved mean | Failed mean | Univariate r |
|---|---|---:|---:|---:|---:|
| `agent_diff_ratio` | agent's edit volume / gold patch size (clipped at 10×) | 2.1× | 2.04× | 2.21× | −0.037 |
| `thrash_rate` | fraction of edited files that get edited 2+ times | 0.54 | 0.542 | 0.537 | +0.008 |

**Editing patterns don't separate success from failure.** Agents typically over-engineer (edit 2× more lines than the gold patch) and re-edit half their files. Both are equally true on resolved and failed trials. **Thrashing is not a failure marker.** Over-engineering is not a failure marker.

### Time-allocation behavior — when did the agent do what?

| Feature | What it measures | Mean | Resolved mean | Failed mean | Univariate r |
|---|---|---:|---:|---:|---:|
| `probe_fraction` | fraction of trial steps **before the first edit** | 0.38 | 0.41 | 0.36 | +0.118 |
| `tests_per_edit` | test invocations per edit | 0.73 | 0.99 | 0.56 | **+0.207** |
| `tests_per_step` | test invocations per total step (density) | 0.097 | 0.117 | 0.084 | **+0.194** |

**`tests_per_edit` is the strongest univariate predictor of all 12 features** (r = +0.207). The descriptive analysis ran with this. But — the regression shows it doesn't survive joint control. Successful trials run nearly 1 test per edit (0.99); failed trials run 1 test per 2 edits (0.56). Why does it collapse?

Because `tests_per_edit` is mathematically related to `tests_per_step` and `n_steps`. Once those two are also in the model, `tests_per_edit` adds nothing new. The signal is the *density* of testing, not the *ratio* to editing.

`probe_fraction` is positive in the single-feature view (+5 percentage points more probing in successes) but **flips sign in the joint regression** (coefficient = −0.17, not significant). Translation: most of the apparent "probing helps" effect was just "opus probes 51% of its trial vs qwen 22%; opus succeeds more than qwen." Once we control for which model ran the trial, the within-model effect of probing more is essentially zero.

### Self-introspection — did the agent verbally diagnose the bug?

| Feature | What it measures | Mean | Resolved mean | Failed mean | Univariate r |
|---|---|---:|---:|---:|---:|
| `pre_edit_mention_rate` | fraction of gold function names mentioned in agent's text **before first edit** | 0.086 | 0.099 | 0.078 | +0.061 |

Weak descriptive signal (+2 pp gap). Doesn't survive regression. **Caveat**: claude-code/opus contributes 0% mentions because the NDJSON adapter can't capture the agent's `<thinking>` blocks. The metric is biased per-model and would need refinement to be reliable.

### Controls — features included to prevent confounding

| Feature | What it measures | Mean | Resolved | Failed | Univariate r |
|---|---|---:|---:|---:|---:|
| `n_steps` | total trial step count | 66 | 68 | 65 | +0.039 |
| `gold_diff_lines` | size of the gold patch (lines added+removed) | 782 | 490 | 962 | **−0.115** |

`gold_diff_lines` confirms what we'd expect: harder tasks (bigger gold patches) are less likely to resolve. The mean failed task has a 2× larger gold patch than the mean resolved task. This is a control — we want it in the regression to absorb task-difficulty confounding.

`n_steps` is essentially uncorrelated with outcome. Failed trials are NOT systematically longer than resolved trials in aggregate (codex/opus/haiku have failed > resolved, but qwen reverses; the directions cancel).

---

## The regression: what survives joint control

Logistic regression on n=346 trials with all 12 behavioral features + 2 task/length controls + 3 model-identity dummies (codex55 is the reference baseline). Continuous features are standardized (mean = 0, SD = 1) so coefficients are comparable across features.

**How to read the coefficient column:** the value is the change in log-odds of resolution per 1 SD increase in the feature. To turn that into an "odds multiplier," exponentiate it: a coefficient of +0.44 means odds multiply by exp(0.44) ≈ 1.55, i.e. the feature increasing by 1 SD raises the odds of success by ≈ 55%. A coefficient of −2.82 means odds multiply by exp(−2.82) ≈ 0.06 — i.e. 17× less likely.

**Sorted by absolute coefficient size:**

| Predictor | Coefficient | SE | p | What it means |
|---|---:|---:|---:|---|
| `is_qwen36` | **−2.815** | 0.59 | <0.001 | Holding behavior constant, qwen36 is **~17× less likely to resolve a trial than codex55** is. |
| `is_haiku45` | **−2.179** | 0.51 | <0.001 | Haiku45 is **~9× less likely than codex55**. |
| `is_opus47` | −0.876 | 0.48 | 0.070 | Opus47 is **~2.4× less likely than codex55** (marginal significance). |
| **`tests_per_step`** | **+0.439** | 0.20 | **0.031** | **+1 SD in test-running density raises odds of success by ≈ 1.55×.** Only behavioral feature that survives joint control. |
| `log_gold_diff_lines` | **−0.372** | 0.18 | **0.037** | Harder tasks (bigger gold patches) resolve less often. Expected control. |
| `log_n_steps` | −0.269 | 0.22 | 0.22 | not significant |
| `exam_file_recall` | −0.248 | 0.23 | 0.28 | not significant |
| `probe_fraction` | −0.172 | 0.22 | 0.43 | not significant (sign-flipped from the single-feature view) |
| `tests_per_edit` | +0.128 | 0.21 | 0.54 | **not significant** — the v1 "tests-per-edit" headline collapses here |
| `comm_file_recall` | −0.124 | 0.22 | 0.57 | not significant |
| `pre_edit_mention_rate` | −0.107 | 0.14 | 0.45 | not significant |
| `thrash_rate` | +0.101 | 0.14 | 0.48 | not significant |
| `agent_diff_ratio` | −0.073 | 0.20 | 0.71 | not significant |
| `frac_test_files` | +0.052 | 0.13 | 0.70 | not significant |
| `log_n_examined_files` | +0.010 | 0.19 | 0.96 | not significant |

After model identity, task complexity, and trial length are controlled, **only `tests_per_step` is significant at p < 0.05** among the 12 behavioral predictors. The model dummies are an order of magnitude larger in effect than any behavioral signal.

### What survives the first-half-only robustness check

To address "successful trials end early so they have proportionally more tests," we rebuilt every feature using only the first half of each trial's steps:

| Predictor | First-half coefficient | First-half p | Pooled coefficient | Survives? |
|---|---:|---:|---:|:-:|
| `tests_per_step` | **+0.495** | **0.019** | +0.439 (p=0.031) | ✓ |
| `log_gold_diff_lines` | **−0.419** | **0.026** | −0.372 (p=0.037) | ✓ (control) |
| All other behavioral features | not significant | — | not significant | — |

`tests_per_step` survives — slightly larger coefficient under first-half restriction. **Test-running density predicts success even when measured before the trial ends.** This is consistent with a forward-causal interpretation, though strict causation requires an intervention (e.g. controlled re-prompting that forces higher test density).

---

## Single-feature view vs joint regression: what changed and why

This table compares each feature's correlation with success when looked at alone (single-feature view) versus its coefficient in the full regression with everything else held constant. Sorted by single-feature correlation strength:

| Feature | Single-feature correlation | Joint regression coefficient | Outcome | Why it changed |
|---|---:|---:|---|---|
| `tests_per_edit` | **+0.207** | +0.128 (n.s.) | **collapsed** | redundant with `tests_per_step` + `n_steps`, both also in the regression |
| `tests_per_step` | +0.194 | **+0.439** (p=0.031) | **strengthened** | joint control isolated this from the redundant `tests_per_edit` |
| `n_examined_files` | +0.128 | +0.010 (n.s.) | absorbed by model identity | codex examines 250 files & succeeds 58%; the codex dummy absorbs both |
| `probe_fraction` | +0.118 | −0.172 (n.s.) | **sign flipped** | opus probes 51% & succeeds 49%; absorbed by the `is_opus47` dummy |
| `gold_diff_lines` | −0.115 | −0.372 (p=0.037) | strengthened | clean task-complexity effect once other length signals are controlled |
| `frac_test_files` | +0.096 | +0.052 (n.s.) | shrunk | mostly a length artifact |
| `pre_edit_mention_rate` | +0.061 | −0.107 (n.s.) | shrunk + flipped | confounded with model identity (claude-code captures 0% by tooling) |
| `n_steps` | +0.039 | −0.269 (n.s.) | flipped | confounded with other length-correlated features |
| `agent_diff_ratio` | −0.037 | −0.073 (n.s.) | unchanged | always weak |
| `thrash_rate` | +0.008 | +0.101 (n.s.) | always null | re-editing is normal across both outcomes |
| `exam_file_recall` | **−0.004** | −0.248 (n.s.) | always null | **localization doesn't predict success** |
| `comm_file_recall` | **−0.003** | −0.124 (n.s.) | always null | **even committed-localization doesn't predict success** |

**Three patterns** are worth pulling out:

1. **The two strongest single-feature signals (`tests_per_edit`, `tests_per_step`) are redundant with each other.** When both are in the regression, only the cleaner one (`tests_per_step`) survives. **The v1 "tests-per-edit ratio" headline was the wrong cut on the same underlying signal.**

2. **Three features sign-flip when we add the model dummies.** `probe_fraction` (+0.118 → −0.172), `n_steps` (+0.039 → −0.269), `pre_edit_mention_rate` (+0.061 → −0.107). All three are correlated with which model ran the trial (opus probes more *and* succeeds more, codex's transcripts have more text, etc.). The single-feature view was just picking up "opus is opus, codex is codex" — once we control for which model is running, the within-model effect of these behaviors is zero or even mildly negative. This is Simpson's paradox in action: a positive aggregate correlation that flips when you stratify by the underlying group.

3. **Localization recall has zero correlation with success even in the single-feature view.** `exam_file_recall` (r = −0.004) and `comm_file_recall` (r = −0.003). No regression machinery needed — looking only at "did the agent read the right files?" alone, you can't predict whether it succeeded. This is the cleanest single-number falsification of "search predicts e2e success" in the entire analysis.

---

## How much do behavioral signals add to predictive accuracy?

We compute 5-fold cross-validated AUC for each combination of feature groups. The pattern across rows tells us which features actually carry predictive content for held-out trials.

| Specification | CV-AUC | What it tells us |
|---|---:|---|
| **Full model** (model identity + 12 behavior features + 2 controls) | **0.706 ± 0.045** | Everything we can measure |
| **Model identity only** (just 4 model dummies, no behavior) | **0.693 ± 0.047** | Just knowing which model ran the trial |
| Behavior + length/complexity controls (no model dummies) | 0.631 ± 0.053 | All 12 behavioral signals + size controls |
| Behavior alone (no model dummies, no controls) | 0.635 ± 0.058 | All 12 behavioral signals only |
| Controls alone (just trial-length + task-complexity) | 0.569 ± 0.057 | Just trial length and gold-patch size |

**Knowing only the model identifier gives AUC = 0.693.** Adding 12 behavioral signals on top raises AUC by just 0.013 to 0.706. Behavior is a marginal contributor on top of capability.

For reference, AUC = 0.5 is random guessing, 0.7 is "fair", 0.8 is "good", 0.9+ is "excellent." We're sitting at the boundary between fair and good even with everything thrown in. **There's a lot of unpredictable variance in end-to-end coding outcomes** — which itself is a finding. Either the relevant features are unmeasured (specific bug-class semantics, gold-test invariants), or there's substantial noise in the verifier itself.

---

## Per-model regressions

Per-model regressions, fit on each model's trials separately (no model dummies, since we're conditioning on the model identity). With only 73-92 trials per model and 12 features, these are at the edge of statistical power — rule of thumb is 10-20 trials per feature for stable estimates; we're at 6-8. Treat per-model results as suggestive rather than conclusive.

`Model fit (% variance explained)` is a measure of how much of the within-model variation in resolution the regression captures, where 0 = "no better than guessing the average" and 1 = "perfect predictions."

| Model | n | n_resolved | Model fit (% variance explained) | Significant features (p < 0.05) |
|---|---:|---:|---:|---|
| **opus47** | 92 | 45 (49%) | **25%** | `tests_per_step` (coefficient = **+1.71**, p = 0.0008); `log_gold_diff_lines` (coefficient = −0.85, p = 0.034) |
| codex55 | 90 | 52 (58%) | 17% | _none significant_ |
| qwen36 | 73 | 12 (16%) | 26% | _none significant; near-significant trends on `probe_fraction` (p=0.09) and `log_n_steps` (p=0.08)_ |
| haiku45 | 91 | 23 (25%) | 11% | _none significant_ |

**Only opus47 has a clean within-model behavioral signal.** Its `tests_per_step` coefficient of +1.71 means 1 SD increase in test-density raises odds of success by exp(1.71) ≈ 5.5×. After correcting for the 48 hypothesis tests we ran (12 features × 4 per-model regressions), opus's `tests_per_step` (p = 0.0008) is the only result strong enough to call truly significant.

For codex, haiku, and qwen individually, no behavioral feature reaches p < 0.05 — likely a power problem given n ≈ 80 trials and 12 features per model.

---

## What the data does NOT support

Claims that look intuitive but are NOT defensible from this regression:

1. ❌ **"Tests-per-edit ratio is the cleanest behavioral signature."** True in single-feature view (r = +0.207); collapses to non-significant in the joint regression (p = 0.54). The ratio captures the same variance as `tests_per_step` but less cleanly.
2. ❌ **"Successful agents read more test files."** Codex resolved trials read 1.87× more test files in absolute count, but `frac_test_files` is non-significant in the regression (p = 0.70). The absolute count was partly a length effect.
3. ❌ **"Localization predicts e2e success."** Both `exam_file_recall` and `comm_file_recall` have single-feature r ≈ 0. Joint regression: p > 0.28.
4. ❌ **"Decomposition (TodoWrite / task delegation) helps."** Codex never uses TodoWrite and has the highest success rate. The behavior is a model-architecture choice, not a within-model success-correlated behavior.
5. ❌ **"Self-introspection (verbalizing the right function names before editing) predicts success."** Not significant (p = 0.45). Plus the measurement is biased per-model (claude-code transcripts capture 0% mentions due to NDJSON-adapter limitations on `<thinking>` blocks).
6. ❌ **"Over-engineering causes failure"** (the AGENT_DIFF_HUGE flag from the v1 typology). Single-feature r = −0.04; joint coefficient = −0.07 (p = 0.71). Diff size is uncorrelated with outcome once controls are in.
7. ❌ **"Thrashing (re-editing files multiple times) is a failure marker."** Both single-feature and joint regression show no relationship — re-editing is normal across both outcomes.

---

## What the data DOES support

The narrow set of defensible claims:

1. ✓ **Model identity is the dominant predictor of end-to-end task resolution.** Held-out predictive accuracy (AUC) = 0.69 from model identity alone, vs 0.71 with all behavioral signals added. Capability >> behavior.

2. ✓ **Test-running density is a modest but robust within-model lever.** In the pooled regression: 1 SD increase in test-density raises odds of success by ≈ 1.55× (p = 0.031). The same effect holds when we restrict to first-half-of-trial signals only (effect even slightly larger; p = 0.019), so it isn't just "successful trials end early."

3. ✓ **The test-density effect is concentrated in opus47** (per-model coefficient = +1.71, the only result that survives correction for testing 48 hypotheses). Other models show trends in the same direction but don't reach significance individually — likely a sample-size issue.

4. ✓ **Task complexity (gold patch size) negatively predicts resolution** (coefficient = −0.37, p = 0.037). Expected — bigger fixes are harder.

5. ✓ **Localization recall is uncorrelated with resolution** — single-feature correlation r ≈ 0 for both "did the agent read the right files?" and "did the agent edit the right files?". **The clean falsification of "search predicts e2e success."**

---

## What this means for the paper

### Preferred framing

> *"On a 364-trial end-to-end coding cohort across four frontier agents, behavioral signals extracted from agent trajectories add only ~1 percentage point of held-out predictive accuracy over what knowing the model identity alone provides (0.706 AUC vs 0.693). The single robust within-model behavioral lever — test-running density — explains roughly 5% of within-model variance and is concentrated in opus47. The dominant determinant of end-to-end coding success is **capability**, not **behavior**: training-time differences between models swamp the differences in how individual agents probe, edit, or test."*

This is a real, defensible, NeurIPS-worthy finding because it's *negative in a useful way*: it argues against agent-design / prompting interventions ("make the agent test more!") as a primary lever for closing the capability gap. The cleanest follow-up: **what training-time differences between models cause the gap?**

### Open questions worth running

1. **Causal test of test-density**: can we *force* test-running via prompt engineering and see if resolution rates rise? If yes, `tests_per_step` is causal; if no, it's an indicator. This is the cleanest follow-up.
2. **Within-task variance**: our 364 trials are 92 tasks × 4 models with 1 trial each. Including multiple trials per (task, model) would let us partition variance into task-level + model-level + within-task-rerun-noise.
3. **What training-time differences cause the model gap?** The regression can't answer this — it's a within-cohort behavioral analysis. But the result motivates the question.

### Honest caveats

- **n = 364 is small** for a 15-feature regression. Per-model n = 73-92 is borderline (rule-of-thumb is 10-20 trials per feature for stable coefficients; we're at 6-8). A reviewer would push for replication on a larger cohort.
- **AUC of 0.706 is mediocre.** "We identified the signature of success" is overclaim; "we identified one modest lever amid a lot of unexplained variance" is honest.
- **We tested a lot of hypotheses.** 12 features × 4 per-model regressions = 48 tests. With that many, finding 1-2 spuriously "significant" results at p < 0.05 is expected. Only opus's `tests_per_step` (p = 0.0008) is strong enough to survive a strict correction for that.
- **Causation requires intervention.** The first-half robustness check is suggestive but not conclusive — strict causation needs a controlled experiment (e.g. force higher test-running and see if success rate rises).

---

## Reproduction

```bash
# 1. Build per-trial features (reuses earlier deep-dive output)
uv run python scripts/deep_dive_e2e_trajectories.py [...]

# 2. Build first-half-only signals
uv run python scripts/build_first_half_per_trial.py \
  --input-csv docs/data/v2b-deep-dive-per-trial.csv \
  --e2e-roots /tmp/e2e-codex-full /tmp/e2e-opus /tmp/e2e-haiku /tmp/e2e-qwen \
  --patch-gold references/v2b-patch-gold.json \
  --output-csv docs/data/v2b-first-half-per-trial.csv

# 3. Run regression suite
uv run python scripts/regress_e2e_resolution.py \
  --per-trial-csv docs/data/v2b-deep-dive-per-trial.csv \
  --first-half-csv docs/data/v2b-first-half-per-trial.csv \
  --output-md docs/data/v2b-regression-results.md
```

Full coefficient tables in [`docs/data/v2b-regression-results.md`](./data/v2b-regression-results.md). Structured JSON in [`docs/data/v2b-regression-results.json`](./data/v2b-regression-results.json).
