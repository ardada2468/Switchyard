# What's actually defensible from the search-vs-e2e analysis

**Author:** Jeff Farris (jfarris@nvidia.com)
**Date:** 2026-05-01
**Status:** Internal — strategic framing, not yet a paper section
**Code:** branch `jfarris/analyze-search-vs-e2e`
**Inputs:** [correlation analysis](./search-vs-e2e-correlation-may01.md), [implicit-search analysis](./search-vs-e2e-implicit-search-may01.md)

---

## Why this doc exists

After running two phases of analysis (per-task correlation across 4 framings, then implicit-search extraction across 4 e2e agents), I (Jeff) went back to first principles to ask: is the headline claim — *"patch generation is the bottleneck, not localization"* — actually defensible? This doc captures that audit and lays out a rigorous path forward.

---

## TL;DR

**The implicit-search asymmetry is real but smaller than the v2 followup advertised, and partially confounded by three methodological choices.** The aggregate "failed-trials-localized-better" numbers are not a clean argument on their own. **The cleanest evidence — the 31+ (model, task) pairs where an agent localized 100% of gold files, committed to 100% of gold files, AND still failed — is solid** and makes the patch-generation-is-the-bottleneck claim defensible *on a defined sub-population*, not as a blanket statement.

Three honest concerns about the headline aggregate result:

1. **Patch-derived gold may be too narrow** — search agents score 3× higher against curated gold than against patch-gold; if curated gold is the better proxy, our recall metric is inflated.
2. **Examined-files recall is a weak signal** — agents read 250 files per trial against a 12-file gold; near-random reading achieves nontrivial recall.
3. **Failed and resolved trials don't share task difficulty** — failed trials cluster on harder tasks, which legitimately demand more probing.

Each can be addressed; doing so produces a tighter, more publishable claim.

---

## Honest audit of the four-model headline

The v2 followup's headline:

> *"Across four frontier coding agents on the v2b cohort, failed e2e trials examined the gold file area at least as well as resolved trials. The colleague's hypothesis is falsified across all four models."*

That sentence relies on the **`exam_file_recall`** numbers being a fair measurement of localization. They have three issues, in increasing severity.

### Issue 1: Examined-files recall is inflated by broad probing

Mean `n_examined_files` per trial is ≈250, against a gold of mean ≈12 files. Precision is ≈0.04. Codex's failed-trial `exam_file_recall` of 0.79 *sounds* high but is achievable by reading half the repo. The metric is dominated by repo-size, not by agent behavior.

Concretely: in a 2000-file repo, examining 250 random files gives an expected file-recall of ≈0.13 on a 12-file gold (250/2000) — but real repos have many small files and a few core files. The agent's natural reading bias toward main modules concentrates probing where the gold lives, so achieved recall is much higher than uniform-random would predict. We don't have a clean baseline for "how high should random probing get?"

The cleaner signal is **`comm_file_recall`** — files the agent edited via Edit/Write or `apply_patch`. Agents commit to 5-8 files per trial against a 12-file gold; precision is meaningful (≈0.5-0.6), and recall isn't gameable by broad reading.

Looking at committed-files recall:

| Model | resolved | failed | Δ (resolved − failed) |
|---|---:|---:|---:|
| codex55 | 0.554 | 0.593 | **−0.04** (failed slightly higher) |
| opus47 | 0.470 | 0.558 | **−0.09** (failed higher) |
| qwen36 | 0.440 | 0.315 | **+0.13** (resolved higher — supports "search bottleneck" for qwen) |
| haiku45 | 0.448 | 0.487 | **−0.04** (failed slightly higher) |

The story is muddier than examined-recall suggested. **qwen actually shows the colleague-predicted pattern on committed files** (failed trials committed to fewer gold files). Three of four models still trend opposite — but the sizes are smaller (≤0.09 vs ≤0.13 for examined) and qwen flips entirely.

### Issue 2: Patch-derived gold may be too narrow

Dedicated-search agents score mean `nav` of **0.54 against curated gold** (the `gold_answer.json` shipped with each search task) but **0.18 against patch-derived gold** (only the literal files edited by `solution/changes.patch`). 3× gap.

Two interpretations:

- **(a) Curated gold is over-broad.** It includes "alts" — related-but-not-essential code paths added during gold review. Agents get credit for naming files in the bug's neighborhood without touching the actual fix-site. Patch-gold is the conservative truth.
- **(b) Patch-gold is too narrow.** A well-motivated answer to "where's the bug?" is broader than "what was edited" — it includes the call sites, the abstract base classes, the failing tests, the regression test. Patch-gold under-counts legitimate localization.

Both are partially true. The honest position is that **the truth lies between curated and patch gold**, and our implicit-search recall against patch-gold is on the conservative side. Higher recall there is a stronger signal, but lower recall doesn't yet mean "didn't localize."

The way to get cleaner signal: **report against both golds** for the v2b∩search overlap (49 tasks). If implicit-search recall against curated gold is dramatically higher and the failed-vs-resolved gap inverts, methodology is doing the work. If recall is lower but the gap holds, the finding is robust.

We have not yet run this sanity check.

### Issue 3: Task difficulty confound

Failed and resolved trials are not a random partition of the cohort. Failed trials concentrate on hard tasks, which often demand more probing. So "failed trials examined more files" can mean:

- *(intended interpretation)* Agents thrash when they can't fix, examining more in desperation
- *(confound)* Hard tasks have bigger relevant-code footprints, so any trial — passing or failing — needs to probe more

Without conditioning on task difficulty, we can't distinguish these.

The fix: bin tasks by **cohort-wide resolution rate** (across all 16 e2e iters in the original v2b CSV: easy = >75%, medium = 25-75%, hard = <25%). Within each bin, recompute `exam_file_recall` for resolved vs failed. If the asymmetry holds within bins, it's about the trial outcome. If it disappears, it was task-difficulty.

We have not yet run this.

---

## What's still solid: the localized-but-failed cohort

Even after walking back the aggregate claims, **one population is defensible without any of the above caveats**: trials where the agent localized perfectly *and* still failed. By construction, localization is at ceiling — no room for issues 1, 2, or 3 to muddy the signal.

Population sizing (from the four CSVs):

|  | Definition | n |
|---|---|---:|
| Per-model fully-localized failures | (agent, task) pair: `exam_file_recall = 1.0` AND `e2e_resolved = 0` | **64 pairs** |
| ... distinct tasks involved | | 31 tasks |
| Per-model fully-localized **and committed** failures | adds `comm_file_recall = 1.0` | **31 pairs** |
| ... distinct tasks involved | | 12 tasks |
| Cross-model fully-localized failures | every model that scored this task had `exam_file_recall ≥ 0.83` AND failed | 10 tasks |

Per-model breakdown of fully-localized failures:

- **codex55:** 19 of 38 failed trials (50%) — the agent saw every gold file but the patch didn't pass
- **qwen36:** 20 of 79 failed trials (25%)
- **haiku45:** 13 of 68 failed trials (19%)
- **opus47:** 12 of 47 failed trials (26%)

**These 64 pairs are the cleanest qualitative dataset for the paper.** They're the cases where neither "didn't search" nor "search-gold-mismatch" can explain the failure. Whatever happened, it happened *after* localization.

---

## Three story options for the paper

In order of strength.

### Story A — "Gold-set design materially affects search-benchmark numbers"

Methodology contribution. Show the 3× gap between curated and patch-derived gold for the same agent submissions; argue that future search benchmarks should report both, since the answer to "did the agent localize the bug?" depends substantially on which definition of "the bug area" you adopt.

- **Defensible:** yes, the data shows it.
- **Strong enough alone:** marginal. Methodology papers without an empirical hook tend to land at workshops, not the main track.
- **Effort:** ~half a day to format and produce the figure.

### Story B — "A typology of patch-generation failures, on a localization-exhausted sub-benchmark"

The 64 (model, task) pairs of fully-localized failures form a sub-benchmark where localization is ruled out by construction. Read the trial transcripts, classify the actual failure modes, report rates with examples. The 31 strict-cases (file recall AND commit recall both 1.0) are the headline; the 64 broader cases are the full empirical base.

- **Defensible:** yes — the construction makes the claim airtight on this subset.
- **Strong enough alone:** yes, if the typology is non-trivial. This is *constructive* — produces a sub-benchmark and a failure-mode taxonomy others can use.
- **Effort:** ~3-5 person-days for transcript review of 64 trials + classification + writeup.

### Story C — "Causal test via re-prompt with provided gold localization"

Take the 31 fully-localized-AND-committed failures. Re-run each agent on each task with the gold file/function set inserted into the prompt as a localization hint. If agents now succeed, localization wasn't the bottleneck and Story B's classification is the right framing. If they still fail at the same rate, patch-correctness is conclusively the bottleneck.

- **Defensible:** yes, if we run it carefully.
- **Strong enough alone:** strongest of the three. Causal evidence beats correlational.
- **Effort:** 1-2 days to template the prompts, run via harbor against the same v2b setup, score. Existing harness handles it.
- **Risk:** could backfire — if agents ace the re-prompted version, the "patch is the bottleneck" framing flips. Either result is publishable but the headline changes.

---

## Recommended path forward

Run all three, in order:

1. **Story A as one paper section** (1 day): clean the curated-vs-patch gold comparison, report it. Methodological contribution.

2. **Story B as the empirical core** (3-5 days): rigorous failure-mode classification on the 64 fully-localized-failures cohort. Below is the protocol.

3. **Story C as the causal closer** (2 days): run the re-prompt experiment on the 31 strict-cases. If results align with Story B's classification, the paper is much stronger.

Plus three methodological strengthening items first:

4. **Rescore implicit search against curated gold** for v2b∩search overlap — confirms or refutes Issue 2 of the audit. (2 hours)
5. **Replace examined-files-recall with committed-files-recall** in the headline summary — addresses Issue 1. (already in our CSVs; just need to redo the summary table)
6. **Stratify by task-difficulty bin** — addresses Issue 3. (1 hour: pivot the existing CSVs by cohort-wide e2e resolution rate)

If those three sanity checks survive, the rigorous paper claim is:

> *"On a sub-benchmark of 31 (model, task) pairs where a frontier agent committed to 100% of the gold-edited files in an end-to-end coding task, all 31 still failed verification. Failure modes cluster into [N] categories: [list]. A controlled re-prompt experiment with provided localization improves resolution rate from 0% to X%, identifying patch-correctness as the dominant capability gap."*

That's a real paper.

---

## Protocol for Story B (rigorous failure-mode typology)

### Population

64 (model, task) pairs across 4 agents on v2b, defined as: `exam_file_recall = 1.0` AND `e2e_resolved = 0`.

Stratification:
- 31 of these also have `comm_file_recall = 1.0` (the agent committed to every gold file)
- 33 have `comm_file_recall < 1.0` (agent saw all the right files but committed narrower than gold)

The 31 strict cases get full transcript review. The 33 broader cases get a lighter-weight review (just commit-recall + verifier output).

### Per-trial classification protocol

For each of the 64 trials, the reviewer reads:
- `agent/trajectory.json` or `agent/claude-code.txt`
- `verifier/test-stdout.txt`
- `verifier/reward.json` (failed F2P tests, P2P regressions)
- `solution/changes.patch` (gold) — diff against the agent's edits

And records:

1. **Failure category** (pick most-applicable; multi-label allowed):
   - `P2P_REGRESSION` — agent's edits broke a P2P test that was passing in pre-patch state
   - `F2P_PARTIAL` — agent's edits flipped some F2P tests but not all
   - `F2P_NONE` — agent's edits didn't move any F2P test
   - `SYNTAX_ERROR` — patch failed to apply or compile
   - `TYPE_ERROR` — runtime type mismatch (mypy or duck-typing)
   - `WRONG_LOCATION` — agent edited a file the gold doesn't touch (gold-recall ≥ 1 doesn't preclude extra edits elsewhere)
   - `OFF_BY_ONE` — semantic logic error in an otherwise-right edit (wrong default, missing branch)
   - `INCOMPLETE_REFACTOR` — agent edited some but not all sites that need to change for the fix to compose
   - `INVARIANT_MISUNDERSTANDING` — agent's edit assumes a contract that doesn't hold (e.g. ordering, idempotence, thread-safety)

2. **Brief diagnosis** (1-3 sentences): why specifically did this fail?

3. **Was the gold patch significantly different?** (yes/no/qualitative)

4. **Could the failure mode be inferred from the verifier output alone?** (proxy for "is this discoverable by the agent itself?")

### Output

Per-trial JSON record:
```json
{
  "task_id": "t2v3-...",
  "model": "codex55",
  "categories": ["P2P_REGRESSION", "F2P_PARTIAL"],
  "diagnosis": "Agent's edit fixes the F2P test for missing dict key but introduces a None-check that breaks two P2P tests in the same module.",
  "gold_diverges": true,
  "self_discoverable": true,
  "exam_file_recall": 1.0,
  "comm_file_recall": 1.0
}
```

Aggregated into `data/v2b-localized-failure-typology.json` (or similar — checked into the repo).

### Reporting

Once classified, the paper section includes:
- Distribution of failure categories (bar chart)
- Per-model breakdown (which models specialize in which failure modes?)
- Worked examples — 2-3 trials per category, with diff + verifier output + diagnosis
- Self-discoverability rate — what fraction of failures could the agent have caught from its own test output?

### Cost estimate

Per-trial review at 8-10 minutes (reading transcript, diff, verifier output, classifying, brief diagnosis):
- 64 trials × 9 min = ~10 hours = 1.5 days of focused work
- Or split across 2 reviewers for inter-annotator agreement (recommended for paper rigor)

If we double-code 20 of the 64 trials with two reviewers and report Cohen's κ, the methodology section is strengthened.

---

## Concrete next steps

In strict order:

1. **Strengthen the methodology audit** (combined ~3-4 hours):
   - Add curated-vs-patch-gold comparison to `search-vs-e2e-implicit-search-may01.md`
   - Replace headline tables with `comm_file_recall` (committed) instead of `exam_file_recall` (examined)
   - Add task-difficulty stratification (easy/medium/hard cohorts)

2. **Build the failure-mode classifier dataset** (1-2 days):
   - List the 64 (model, task) pairs with full metadata
   - Materialize the relevant trial dirs, transcripts, diffs in a single review-friendly directory
   - Per-trial template ready for human classification

3. **Run the qualitative classification** (1.5 days, ideally 2 reviewers):
   - 64 trials × ~9 minutes
   - Inter-annotator agreement on a 20-trial subset

4. **Run the re-prompt experiment** (Story C — 2 days):
   - Template prompts that include the gold file list
   - Run via harbor against v2b for the 31 strict-cases × 4 models = 124 trials
   - Compare resolution rate

5. **Write the paper section** (2 days):
   - Story A as methodology
   - Story B as core empirical finding
   - Story C as causal evidence

Total: roughly **2 weeks of focused work** to a defensible paper section. Worth it if the failure-mode taxonomy turns out non-trivial. If the typology collapses to "everyone makes P2P regressions," we have a weaker but still real result.

---

## What this doc is *not*

- It is not a writeup yet. The two prior writeups (correlation + implicit-search) are what we share with colleagues today. This doc is internal strategy.
- It is not a commitment to all three stories. We can stop after step 1 (methodology cleanup) and re-evaluate. We should stop and re-evaluate after step 3 (classification). The paper-section goes up only after we've seen the typology distribution.
- It does not change the conclusion of [implicit-search-may01.md](./search-vs-e2e-implicit-search-may01.md) about the colleague's pushback being addressed at the *qualitative* level (the 64 fully-localized-failures cohort is not zero, and it is not explicable by "didn't search"). It does walk back the aggregate "X% of failures are localized" framing until the methodology audit is complete.
