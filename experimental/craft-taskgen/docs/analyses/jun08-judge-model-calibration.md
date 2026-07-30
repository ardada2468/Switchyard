# Judge-model calibration: why we kept Opus 4.6 + GPT-5.4 for triage (Jun 8 2026)

**TL;DR.** MR !87 moves the *smoke agent* from claude-code+Opus-4.6 to **codex+GPT-5.5** (a second agent option for the pipeline). A follow-on commit also bumped the *judge* models (evaluate/build/deep-dive = Opus 4.6→4.8, alignment/fairness = GPT-5.4→5.5). Validation showed the **judge bump alone re-flags ~20–25 of the 85 previously-fair v2b tasks as `major`**, so we **reverted the judge bump** (commit reverts `d0e2d15`) and kept only the smoke-agent change. The judges stay **Opus 4.6 + GPT-5.4**.

## Method

`scripts/triage-replay.py` replays the two triage judges (Opus per-test deep-dive skip/keep + GPT cross-family fairness severity) over existing harbor trajectories — no Docker, no re-smoke. It mirrors `steps.py::_run_triage_one` exactly, including the `f2p_skip.txt` filter (deep-dive verdicts on already-excluded tests are dropped, as in production). Inputs: the May 2026 e2e eval trajectories (codex+GPT-5.5 on craft-taskgen-v2; Opus-4.6 on v2b), 84–85 of the canonical 85-task set.

## Result: a clean 2×2 (fairness `major` count)

| fairness model | input = Opus-4.6 trial (build-time) | input = codex trial |
|---|---|---|
| **GPT-5.4** (build-time judge) | **2** | **2** |
| **GPT-5.5** (bumped judge) | **20** | **25** |

The fairness model is the entire story: **GPT-5.4 flags ~2 regardless of input; GPT-5.5 flags 20–25 regardless of input.** The input trajectory (the agent being judged) barely moves it. This reproduces the original "92/85 passed fairness" baseline under GPT-5.4 and isolates the shift to the model. GPT-5.5 fairness is also only ~78% run-to-run stable (6 of ~25 `major` flips on re-run of identical trials).

## Deep dive (Opus): stable, not the problem

A first pass *looked* like Opus-4.8 was over-flagging (16 tasks with skip verdicts). That was a harness bug — it counted re-nominations of tests already in `f2p_skip.txt`. With the production skip-filter applied, only **3 tasks** get any *new* skip, and the **reverted Opus-4.6 deep-dive proposes 0 new skips on codex trials** (130 `keep`). The deep-dive is consistent across model versions; it re-confirms known-unfair tests rather than inventing new ones.

## Final-config check (the one that matters)

Production now feeds **codex** trajectories to the judges (not Opus-4.6). Reverted judges (GPT-5.4 + Opus-4.6) on the codex smoke trials: **2 fairness-`major`, 0 new deep-dive skips → 82/84 clean.** The judges are robust to the new codex input.

## "Valid discoveries" vs "false alarms" (with GPT-5.5, for reference)

Of the 19/80 tasks never solved by *any* of 7 models × 5 iters, GPT-5.5 `major` was only weakly enriched (36% vs 29% on solved tasks). GPT-5.5 also flagged `major` on ≥10 tasks that strong models (Opus-4.6/4.7, GPT-5.5) solve ≥60% of the time — clear false alarms. So GPT-5.5 `major` is not a reliable discovery signal on its own; it would need threshold/prompt recalibration before use.

## Decision

- **Revert judge models to Opus 4.6 + GPT-5.4** (this is what the thresholds/prompts are tuned for).
- **Keep the smoke-agent change** (codex + GPT-5.5) — orthogonal and validated.
- **Calibration rule** (now in CLAUDE.md): changing any judge model or prompt requires re-running `triage-replay.py` to recalibrate `MAX_TRIAGE_REGENS` / severity-gating before trusting verdicts.
