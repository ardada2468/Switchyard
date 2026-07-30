# CRAFT vs. SWE-bench++ and the Scaled-SWE-bench Landscape

A technical comparison in support of the CRAFT benchmark paper. Written 2026-04-17.

## 0. TL;DR

CRAFT and SWE-bench++ both scale the SWE-bench recipe (harvest merged PRs, run tests in containers, keep the ones where fixes turn FAIL→PASS), and both use LLMs to keep up with scale. The difference is **where the LLMs sit in the pipeline**:

- **SWE-bench++ uses LLMs as quality gates** — an LLM-Judge validates semantic alignment, an LLM infers Docker dependencies, and a strong model sanity-checks contamination. The *task* (issue body, tests) comes from GitHub unchanged.
- **CRAFT uses LLMs as task authors** — Opus authors the instruction against an explicit rubric, GPT-5.4 audits instruction ↔ test alignment, two cross-family deep-dive judges classify post-execution failures, and an auto-regen loop tightens the instruction when deep dive flags scope issues. The GitHub PR is a raw material, not the shipped artifact.

The other distinctive CRAFT axis is:

1. **Skill-dimension stratification** (Tool Orchestration vs. Code Exploration tracks with their own rubrics). Every other benchmark stratifies by LoC, language, or developer-effort estimate.

Each of these choices directly answers a *published* SWE-bench critique. The paper should lead with that framing.

---

## 1. Disambiguating "SWE-bench++"

Three different artifacts share near-identical names. The paper's related-work section needs to keep these straight or reviewers will push back.

| Artifact | arXiv | Authors / Org | Year | Scale | Nature |
|---|---|---|---|---|---|
| **SWE-Bench++** | 2512.17419 | Wang et al., **Turing R&D** | Dec 2025 | 11,133 tasks, 3,971 repos, 11 languages | Scaled automated pipeline with LLM-in-the-loop QA |
| **SWE-bench+** | 2410.06992 | Aleithan et al. | Oct 2024 | Critique paper, no release | Manual audit exposing leakage and weak tests |
| **SWE-bench Verified** | OpenAI blog | OpenAI + 93 contractors | Aug 2024 | 500 hand-curated tasks | Human filter on original SWE-bench |

"The SWE-bench++ paper" in practice means the Turing 2512.17419 paper. "SWE-bench+" (single plus) is a separate critique paper and is extremely important for CRAFT's motivation — see §6.

Adjacent scaled variants to name-check:

- **Multi-SWE-bench** (ByteDance Seed, arXiv 2504.02605) — 1,632 instances, 7 languages, purely human QA
- **SWE-Gym** (arXiv 2412.21139) — 2,438 Python instances, training-oriented
- **R2E-Gym / AgentGym** (arXiv 2504.07164) — ~8.7K tasks, synthesizes tasks via LLM test generation + commit back-translation (closest prior art to CRAFT's authoring step, but for training not benchmarking)
- **SWE-Bench Pro** (Scale, arXiv 2509.16941) — 1,865 tasks across 41 repos including 276 proprietary; focuses on contamination resistance

---

## 2. CRAFT pipeline at a glance

Source → 10-stage pipeline → ~20–200 accepted "hard" tasks per run:

```
select → evaluate → build → alignment_judge → assemble → build_dockerfile →
docker_classify (F2P/P2P) → oracle → smoke_opus →
triage (dual deep dive → merge → auto-skip OR Build-regen) → accept
```

Key machinery (file references are in `src/craft_taskgen/`):

- `miner.py` — GitHub PR miner with structural scoring (test-patch mandatory, multi-file bonus, refactor penalty)
- `prefilters.py` — regex rejection of docs/CI/formatting/non-Python PRs before any LLM spend
- `steps.py` — all stage implementations
- `prompts.py` — direct-API prompts for evaluate, build, alignment, deep-dive, summary
- `llm_judge.py` — async litellm wrapper with manual-parse + jsonschema.validate
- `docker.py` — two-pass overlay/oracle F2P/P2P classification
- `runner.py` — Harbor smoke-test runner (Opus trial)
- `rubrics.py` — H-rules, V4 audit, alignment-categories, anti-leakage (module-level string constants inlined into prompts)

Expected per-run attrition (from `profiles/craft-tools-v4.toml` caps and README §Scale):
- ~5k–11k raw candidates (111 repos × ~50–100 PRs)
- ~750–3,300 after prefilters (~15–30%)
- ~110–990 PROMISING after `evaluate` (~15–30%)
- ~55–690 after alignment + assemble + oracle (~50–70%)
- **~20–200 ACCEPTED** after smoke + triage

End-to-end survival ≈ 0.3–4%. SWE-bench++ reports 8.1% (137k → 11.1k) end-to-end, but that excludes a skill-dimension rubric.

---

## 3. Stage-by-stage comparison

| Pipeline stage | CRAFT | SWE-bench++ (Turing) | SWE-bench Verified | Multi-SWE-bench |
|---|---|---|---|---|
| **Repo sourcing** | 111 Python repos, curated list (`references/repo_list.csv`) | >100 stars, >10k LoC, merged PR→issue link, edits tests → 3,971 repos | Inherits 12 orig. SWE-bench repos | >500 stars, ≥6 mo active, CI present |
| **Candidate scoring** | Structural heuristics: test-patch required, multi-file bonus, refactor penalty (`miner.py`) | "Programmatic sourcing", filter by PR-issue link | None; fixed set | Linked PRs, test-modifying |
| **Deterministic prefilter (before LLM)** | Regex reject: docs-only, CI-only, formatting-only, version bumps, non-Python (`prefilters.py`) | Not described beyond source filter | N/A | N/A |
| **LLM candidate evaluation** | **Opus per-candidate**: accept/reject verdict, instruction sketch (`prompts.py` EVALUATE_SCHEMA) | None at this stage | None | None |
| **Instruction authoring** | **Opus direct-API** rewrites the instruction per H-rules (outcome-oriented, 50–100 words, no diagnosis) | Uses issue body verbatim | Uses issue body verbatim | Uses issue body verbatim |
| **Build-time rubric audit** | **GPT-5.4 alignment judge** (cross-family from Opus) audits instruction ↔ test alignment per V4 three-layer audit; retention-biased 3× retry + 1 Build regen with leakage-evidence feedback | Stratified post-hoc by patch LoC and task type | Developer-effort buckets <15min / 15min–1hr / >1hr | Language + difficulty tier |
| **Docker environment** | Per-task Dockerfile generated by a claude-p agent with fs+Bash tools, merge_base_sha pinned, `git init` reset for clean gold | **Per-PR Dockerfile**, LLM-inferred deps, build-feedback loop with 5 retries, 3-time build stability check | Per-instance (post-2024 harness rewrite) | Per-PR Dockerfile, deps from CI workflows |
| **F2P/P2P classification** | Docker two-pass (overlay vs. oracle). Binary score via `score.py`. Auto-reject on regression or empty lists. | **Three-state diff**: Base / Before / After, deterministic regex + neural parsing for non-standard output | Original SWE-bench harness | Three-config run, require any→FAILED→PASSED transition |
| **Oracle gate** | Hard gate: solve.sh must resolve both F2P and P2P fully | Yes (3 golden-solution runs; discard flaky) | Yes | Yes |
| **Semantic alignment check** | Direct-API cross-family alignment judge (GPT-5.4) at build time | **LLM-Judge** at Layer 3 (precision 0.926–0.952 vs. human) | 3 human annotators per task | N/A |
| **Post-execution triage** | **Separated-concerns two-judge**: Opus per-test `skip`/`keep` verdict (deterministic auto-skip on `skip`, re-score trial); GPT-5.4 task-level fairness review (severity-gated one-shot Build regen only on `major` + verbatim instruction quote + named failing test). No merge — judges answer different questions. | No — QA layers are pass/fail gates | N/A | N/A |
| **Human verification** | None at construction time (intentional — automated throughput) | 82 pre-screened annotators on model-breaking instances, per Verified-style guidelines | 3 annotators × 1,699 samples | 68 expert annotators, dual + cross-review, 14-eng QA team |
| **Final size** | ~20–200 per run | 11,133 | 500 | 1,632 |

---

## 4. Where CRAFT is **similar** to SWE-bench++

These overlaps are good — they make CRAFT legible to SWE-bench reviewers. Don't over-differentiate:

1. **F2P/P2P contract**. Both define a resolved task as: every designated fail-to-pass test goes FAIL→PASS, every pass-to-pass test remains PASS. SWE-bench++ adds a third "Base" state to also support feature-addition tasks. CRAFT should consider whether it wants to adopt the Base/Before/After tri-state explicitly; currently CRAFT's overlay/oracle pairing is effectively the same two comparisons in a different frame.
2. **Per-PR containerization**. Both reject the original SWE-bench "one image per repo" simplification. CRAFT's `build_dockerfile` step and SWE-bench++'s per-PR template synthesis are the same idea.
3. **Determinism gate** (3+ runs on the gold solution). CRAFT does this via Opus smoke trials (`max_smoke_retries=2`, so 3 total). SWE-bench++ explicitly does 3 golden-solution runs. Confirm the CRAFT framing in the paper — 3 trials is the shared standard.
4. **Contamination-conscious filtering**. SWE-bench++ Layer 4 drops instances solved by SOTA models without the patch. CRAFT's `compare_and_accept` drops tasks both models pass perfectly (`both 1.0` → flat-easy). Different mechanisms, same intent.
5. **License / hygiene filters**. CRAFT Y1–Y5 and SWE-bench++'s sourcing filters both restrict to active, permissively licensed repos.

---

## 5. Where CRAFT is **distinctively different**

These are the paper's contribution arguments. In priority order:

### 5.1 LLM-authored instructions with an explicit hardness rubric

No prior scaled SWE-bench variant rewrites the instruction. SWE-bench++ uses an LLM-Judge to *check* the issue/test/patch alignment; CRAFT uses Claude Code to *write* the instruction to spec. The spec itself (H1–H7 in `.claude/skills/task-hardness-checker/`) encodes:

- **H1 outcome-oriented** — describe what "done" looks like, not how to get there
- **H2 no diagnosis** — state the symptom, don't reveal the bug location
- **H3 essential difficulty** — reasoning fails, not formatting compliance
- **H4 first-approach-fails** — naive attempt should hit an obstacle
- **H5 non-trivial sequence** — >3 tool calls, not one-step
- **H6 brevity** — 50–150 words (prevents issue-body leakage through sheer volume)
- **H7 tier discrimination** — measured empirically via the Opus/Haiku gate

This directly addresses the Aleithan et al. (2410.06992) finding that **32.67% of SWE-bench solved tasks had solution leakage in the issue body**. A 150-word outcome-oriented instruction cannot carry that kind of leakage.

### 5.2 Skill-dimension stratification (Tool Orchestration vs. Code Exploration)

SWE-bench++ stratifies by patch size. SWE-bench Verified stratifies by developer-effort estimate. CRAFT stratifies by **skill dimension**: Track 1 measures agent search/exploration ability; Track 2 measures tool orchestration given a known target. The hardness criteria differ per track (T2-H1 is Tool-Orchestration-specific: "post-exploration work must still be hard"). This is structurally different and lets a CRAFT paper make skill-specific claims ("model X is 40% better at Tool Orchestration but equivalent at Code Exploration") that no SWE-bench variant can make.

### 5.3 Dual-model discrimination as a construction-time filter

The dual-model gate was retired with Haiku smoke; what remains is a single-model test on `reward==1.0` trials:

- **Low trajectory exploration** — the deterministic `easiness_flag` (grep_read ≤ 5 on the full agent trajectory) fires when Opus solved the task with essentially no search work. That signal now triggers a Build regen with prescriptive-instruction feedback (rewrite at a higher level of abstraction); a second-pass easiness flag shelves the task as `NEEDS_FIX`.

This is a strong-solver post-execution gate rather than a strong-vs-weak calibration. SWE-bench++ Layer 4 is a strong-model-only contamination check; CRAFT's easiness regen targets the same failure mode (tasks trivially solvable by a strong model) but addresses it at construction time by making the instruction harder to recipe-follow.

### 5.4 Separated-concerns triage (Opus skip/keep + GPT-5.4 fairness review)

Post-execution triage asks two independent questions:

- **Opus DD** — per-test verdict: should this failing test be `skip`ped
  (excluded from scoring) or `keep`t (counted as a genuine capability
  gap)? Skip verdicts auto-append to `f2p_skip.txt` and trigger a
  re-score; reward=1.0 after skip accepts the task outright.
- **GPT-5.4 fairness review** — task-level severity verdict
  (`none`/`minor`/`major`) gated on concrete evidence. `major` requires
  both a verbatim instruction quote AND a named failing test that
  depends on unstated behavior; anything else sets
  `reviewer_concern_flag` as a soft signal without blocking acceptance.

This answers the Wang et al. (2503.15223) critique (**29.6% SWE-bench
patches behaviorally diverge; 11.0% outright incorrect**) via a
two-axis remediation: unfair tests get skipped (Opus), unfair
instructions get rewritten (GPT-5.4 → one-shot Build regen). Separated
concerns — no merge logic to reconcile competing signals, because the
two judges answer different questions.

### 5.5 Action-specific routing

Triage outcomes map deterministically to next-step actions:

- **Opus `skip` verdict → auto-append to `f2p_skip.txt` and re-score**
  the existing trial (no re-smoke, since LLM non-determinism won't
  help if only the scoring set changed)
- **Opus `keep` across all failures + reviewer not-major → accept** at
  current score (task is hard-but-fair)
- **Reviewer `major` + verbatim instruction quote + named failing test
  → one-shot Build regen** with evidence passed into the new Build
  prompt; then re-routes through alignment + smoke + triage
- **Reviewer `major` without both evidence fields → soft flag only**
  (reviewer_concern_flag, accompanies `easiness_flag` in dashboards)

Skip writes and regen are mutually exclusive in a given triage pass —
auto-skip runs first; if it brings reward to 1.0 the task accepts and
the reviewer's concern, if any, is preserved as soft signal only.

---

## 6. Published critiques and how CRAFT addresses them

This is the most important section for the related-work / motivation framing.

### 6.1 Aleithan et al., arXiv 2410.06992 — "SWE-bench+"

Quantitative findings on the original SWE-bench solved-instance set:
- **32.67% solution leakage** — answer literally present in the issue body or comments
- **31.08% weak tests** — unit tests don't actually validate patch correctness
- After filtering both, SWE-Agent+GPT-4 resolution rate dropped from **12.47% → 3.97%**
- **>94% of issues predate LLM knowledge cutoffs** → contamination exposure

**CRAFT's response**:
- Leakage: H1–H2 rubric + 50–150 word cap in LLM-rewritten instructions prevents wholesale issue-body carryover. Y2 hygiene gate checks no gold leakage in task files.
- Weak tests: V1–V6 verification rubric + Opus DD per-test `skip`/`keep` verdict (does the test exercise a reasonable interpretation of the instruction, or an unstated detail?) + GPT-5.4 fairness review at the task level.
- Contamination: dual-model flat-easy rejection catches tasks both models pass "too easily" — a proxy for memorization. Not a complete defense, but a construction-time check that no other pipeline runs.

### 6.2 Wang et al., arXiv 2503.15223 — "Are Solved Issues in SWE-bench Really Solved Correctly?"

Quantitative findings:
- Running the **full developer test suite** (not just PR-modified tests) fails 7.8% of "plausible" patches — a **4.5 pp drop** in real resolution rates
- PatchDiff differential testing: **29.6% of plausible patches behaviorally diverge** from the oracle
- **~11.0% are outright incorrect**

The core quote to cite: *"SWE-bench only uses the developer-written test files modified in the pull request (PR) for fixing the target issue, potentially leaving functionality covered by other test files untested."*

**CRAFT's response**:
- The reviewer's Q1 ("is this test testing the feature we asked for, or bundled refactoring?") and Q3 ("does instruction wording match test scope?") explicitly protect against the "bundled refactoring" failure mode.
- CRAFT does NOT currently run the full repo test suite as a safety net — adding this as a P2P expansion is a suggested pre-publication improvement (see §9).

### 6.3 "What's in a Benchmark?" arXiv 2602.04449

Broader methodological critique of SWE-bench as an APR evaluation. Useful for the framing paragraph: benchmarks measure what they measure. CRAFT's skill-dimension framing lets the paper sidestep this critique by being explicit about *which skill*.

---

## 7. Quantitative comparison points worth putting in the paper

| Metric | CRAFT (projected) | SWE-bench++ | SWE-bench Verified | Multi-SWE-bench |
|---|---|---|---|---|
| Final benchmark size | O(100s) hard tasks | 11,133 | 500 | 1,632 |
| Languages | Python (Track 2) + configurable | 11 | Python | 7 (no Python) |
| Repos | 111 curated | 3,971 | 12 | 214 |
| End-to-end candidate survival | ~0.3–4% | 8.1% | N/A (human filter) | ~4% (after human QA) |
| Human annotators involved in construction | 0 | 82 (last layer) | 93 | 68 |
| LLMs in construction | **Evaluate + Build + Hardness + Triage + Reviewer + Fix** | LLM-Judge (1 layer) + dependency inference | None | None |
| Models used | Claude Opus + Haiku (via NVIDIA gateway) | Multiple SOTA | GPT-4 (harness tests) | N/A |
| Pass@10 of Sonnet-class model | **TBD — this is a key paper number** | 36.20% (Sonnet 4.5) | N/A (different scale) | N/A |
| Construction cost | Mostly LLM tokens, zero human-annotation cost | 82 annotators × instance time + LLM cost | ~1,699 samples × 3 annotators × 1 hr | 68 annotators × instance time |
| Skill-dimension stratification | **Yes — Tool Orchestration, Code Exploration** | No | No | No |

Two numbers to **measure and report** before submission:
1. Opus pass@1 on CRAFT accepted vs. Haiku pass@1 on same (by construction CRAFT keeps Opus ≥ Haiku — the *gap* quantifies difficulty calibration)
2. Frontier model (Sonnet 4.6, GPT-5) pass@10 on the final CRAFT set. If this is in 20–40% range it looks like SWE-bench++; if it's lower, CRAFT is selecting for harder tasks.

---

## 8. Paper-framing recommendations

1. **Position CRAFT as "LLM-authored benchmark construction"** — the distinctive axis. SWE-bench++ is "LLM-assisted harvesting." CRAFT is "LLM-synthesized tasks with automated quality gates." This framing is clean and defensible.

2. **Lead motivation with the three critique papers** (Aleithan 2410.06992, Wang 2503.15223, 2602.04449). The order-of-magnitude numbers (32.67% leakage, 29.6% behavioral divergence) carry the argument that SWE-bench-style harvesting has a quality ceiling that only re-authoring can break.

3. **Related work taxonomy**: place CRAFT in a 2×2:
   - Axis 1: Human-curated (Verified, Multi-SWE-bench, SWE-Bench Pro) vs. Automated (SWE-bench, SWE-bench++, CRAFT, SWE-Gym)
   - Axis 2: Harvested tasks (everyone else) vs. **LLM-authored tasks (CRAFT)**
   - CRAFT is the only cell in the second column of the automated row. That is the whitespace.

4. **Include the "both pass = reject" result** as a concrete example. It is a memorable and easy-to-explain design choice. Do an ablation: how many tasks survive without the compare_and_accept gate? Quality drop measured how?

5. **Explicitly address contamination**. The flat-easy reject is a weak defense. Stronger: the instruction rewrite changes wording so even memorized issue text doesn't word-match. Show a concrete before/after of a known SWE-bench task rewritten by the CRAFT build stage — makes the contamination argument concrete.

6. **Avoid over-claiming**. CRAFT does not do full-test-suite regression (§6.2), does not have human-in-loop QA (Multi-SWE-bench does), and has smaller scale than SWE-bench++. Frame as "different quality/scale tradeoff" not "strictly better."

---

## 9. Gaps worth closing before publication

Things a skeptical reviewer will point at:

1. **No full-repo test-suite regression.** SWE-bench++ runs the whole test suite three times; CRAFT only runs the F2P/P2P lists. The Wang 2503.15223 critique lands on us here. Low-cost addition: after oracle check, run the full repo test suite and confirm no regressions. Add to the accept gate.

2. **Single evaluator agent per model tier.** CRAFT runs 3 Opus trials but all with the same agent (Claude Code). SWE-bench++ evaluates with "multiple SOTA." Running one alternate-family agent (e.g., Codex or a GPT-family Harbor agent) at construction time would strengthen the discrimination claim. Harbor already supports multiple agents.

3. **Skill-dimension claim needs evidence.** The H1–H7/T2-H1 split is stated, not empirically validated. Ideally: run the same 20 tasks through both tracks' rubrics and show they produce different bands. Or: post-hoc code which CRAFT tasks are genuinely Tool-Orchestration-hard vs. Exploration-hard by instrumenting agent trajectories.

4. **Contamination test is indirect.** The flat-easy gate is a proxy. Stronger: pick 50 CRAFT tasks, check whether the underlying PRs/issues pre-date model cutoffs, and report. Or: paraphrase-robustness test (does a model still solve the task when instructions are paraphrased?).

5. **Human spot-check**. Even 50 CRAFT tasks audited by one senior engineer, with pass/fail judgments on "is this a fair task?", would reduce reviewer friction enormously. Multi-SWE-bench's 68-annotator commitment is not required — a single-annotator audit with inter-tier agreement vs. the reviewer LLM is enough to show the LLM-Judge is calibrated.

6. **License / contamination provenance**. The run captures commit SHAs and profile, but not the GitHub issue body. Consider storing the full source issue/PR artifacts per task so downstream users can audit whether the CRAFT-rewritten instruction leaks issue content.

7. **Cross-track label validation**. CRAFT has Track 1 (search) and Track 2 (tools), but nothing in the pipeline currently enforces that a given task genuinely *requires* one skill and not the other. Could show this via ablation: mask the exploration signal (give the agent the file path) and measure pass-rate delta. If delta is small, the task is tool-orchestration-dominant.

---

## 10. Key sources

- **SWE-bench++ (Turing)**: https://arxiv.org/abs/2512.17419 — https://arxiv.org/html/2512.17419v1
- **SWE-bench+ critique**: https://arxiv.org/abs/2410.06992
- **"Really Solved Correctly?"**: https://arxiv.org/html/2503.15223v1
- **"What's in a Benchmark?"**: https://arxiv.org/abs/2602.04449
- **SWE-bench Verified**: https://www.swebench.com/verified.html
- **Original SWE-bench**: https://arxiv.org/abs/2310.06770 — https://github.com/SWE-bench/SWE-bench
- **SWE-Gym**: https://arxiv.org/abs/2412.21139
- **R2E-Gym / AgentGym**: https://arxiv.org/abs/2504.07164
- **Multi-SWE-bench**: https://arxiv.org/html/2504.02605v1 — https://github.com/multi-swe-bench/multi-swe-bench
- **SWE-Bench Pro**: https://arxiv.org/abs/2509.16941 — https://labs.scale.com/leaderboard/swe_bench_pro_public
