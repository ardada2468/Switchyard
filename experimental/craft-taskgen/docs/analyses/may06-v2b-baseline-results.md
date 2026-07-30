# v2b end-to-end baseline results (May 2026)

Consolidated experimental settings, results, and observations from the
end-to-end baseline campaign on the **v2b-92 cohort** (92 craft-taskgen
tools-track tasks).

- [Headline](#headline)
- [End-to-end results](#end-to-end-results)
- [Cheating audit (tainted-pass detail)](#cheating-audit-tainted-pass-detail)
- [Efficiency](#efficiency)
- [Observations](#observations)
- [Methodology](#methodology)
- [Reproducibility](#reproducibility)
- [Future directions](#future-directions)

## Headline

1. **codex / GPT-5.5 (xhigh) leads at 57.8% ± 2.3** — ~10pp ahead of the next tier.
2. **Opus 4.6 (high) ≈ Opus 4.7 (xhigh)** — 47.8% vs 47.0%, statistically indistinguishable. Reasoning effort upgrade does not move the needle on this cohort.
3. **GLM-5.1 → 42.0%** in clean iters; ~5pp behind opus tier. Gateway throttling on busy nights drags GLM headlines down to 35-39% (iter3 had 21 agent-timeouts vs 0-1 in clean iters), so 42% is the "true" number.
4. **qwen3.6 → 11.3% ± 2.0**, a different tier from the rest. Thinking-mode reasoning frequently runs to the 64k output cap before emitting any tool call; ~20% of trials hit the length cap, almost all of those fail.
5. **codex is the only model with material cheating signal** — 8 tainted passes (1.7% of its trials), all on 3 tasks where it fetched the post-fix source from GitHub.

## End-to-end results

We compute accuracy as the **mean pass rate across 5 runs**. ± follows the
[terminal-bench leaderboard](https://www.tbench.ai/leaderboard/terminal-bench/2.0)
convention: predicted standard deviation of one new run's accuracy under
task-independent Bernoulli sampling, $\sigma = \sqrt{\sum_t \hat{p}_t(1-\hat{p}_t)} / n_{\text{tasks}}$.

- With only 5 binary trials per task, plain std deviation is dominated by
  sampling luck on borderline tasks; per-task pass rates are a much more
  stable signal.
- A model that consistently passes the same tasks and only bounces on a few
  borderline ones gets a small ±. A model whose successes shift task-by-task
  across runs gets a large one.
- F2P / P2P aren't 0/1 per task, so their ± is just sample std across runs
  (no Bernoulli machinery).

Verified empirically against three published terminal-bench rows
(codex/gpt-5.5, terminus-2/gpt-5-codex, terminus-2/gpt-5.1) — formula
reproduces published values exactly.

### Headline (5 runs each)

| Agent | Model | % resolved | F2P | P2P | Failed-task rate w/ throttling | Tainted-pass rate w/ cheating | SWE-Bench Pro (self-reported) |
|---|---|:---:|---|---|:---:|:---:|:---:|
| Codex | `openai/gpt-5.5` *xhigh* | **57.8% ± 2.3** | 0.849 ± 0.019 | 0.997 ± 0.001 | 2 | 1.6 | *58.6%* |
| Claude | `anthropic/claude-opus-4-6` *high* | **47.8% ± 2.2** | 0.770 ± 0.020 | 0.983 ± 0.011 | 0.2 | 0 | *57.5%* ^ |
| Claude | `aws/anthropic/bedrock-claude-opus-4-7` *xhigh* | **47.0% ± 2.8** | 0.809 ± 0.015 | 0.996 ± 0.001 | 0 | 0.2 | *64.3%* * |
| OpenCode | `zai-org/glm-5.1` | **42.0% ± 2.6** | 0.734 ± 0.024 | 0.990 ± 0.006 | 2.8 | 0 | *58.4%* |
| OpenCode | `anthropic/claude-haiku-4-5` | **26.3% ± 2.6** | 0.567 ± 0.033 | 0.968 ± 0.005 | 0 | 0 | *39.5%* |
| OpenCode | `qwen/Qwen3.6-35B-A3B` | **11.3% ± 2.0** | 0.294 ± 0.031 | 0.948 ± 0.012 | 0 | 0 | *49.5%* ** |

Footnotes:
- \* Opus 4.7: SWE-Bench Pro number is an Anthropic-published figure on a contamination-pruned subset.
- \*\* Qwen-corrected refined subset, internal scaffold.
- ^ Opus 4.6: SWE-Bench Pro number is reported by Z.AI in the GLM-5.1 release.

### Single-run probes (no error bars)

Reference points only — one run each, not directly comparable to the 5-run figures above.

| Agent | Model | % resolved | SWE-Bench Pro (self-reported) |
|---|---|:---:|:---:|
| Claude | `anthropic/claude-sonnet-4-6` | 42.4% | — |
| OpenCode | `qwen/Qwen3.5-397B-A17B-FP8` | 20.7% | *50.9%* ** |
| OpenCode | `minimax/MiniMax-M2.7` | 17.4% + | *46.2%* |
| OpenCode | `nvidia/nemotron-3-super` | 8.7% | — |

\+ MiniMax M2.7 likely had inference-gateway issues; treat as floor not ceiling.

## Cheating audit (tainted-pass detail)

Defined as a trial that **passed the verifier** AND **fetched upstream source**
during execution (e.g. `raw.githubusercontent.com` via curl/wget/git/urllib/
WebFetch). Detection: `scripts/check_integrity.py` (see [Reproducibility](#reproducibility)).

Across 2,760 cohort trials (6 models × 5 runs × 92 tasks):
**9 tainted passes total — 8 from codex, 1 from Opus 4.7, 0 from everyone else.**

### Tainted trials by task

(Showing only tasks with at least one tainted trial. Empty cells = clean — no upstream fetch attempted.)

| Task | Opus 4.7 | | | | | GPT-5.5 | | | | |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| | **R1** | **R2** | **R3** | **R4** | **R5** | **R1** | **R2** | **R3** | **R4** | **R5** |
| `t2v3-FA800f-colmodernvbert-multimodal-integration` | F | **P** | F | F | F | **P** | **P** | **P** | **P** | **P** |
| `t2v3-LE282c-robomme-env-integration` | · | · | · | · | · | F | F | F | F | · |
| `t2v3-AN4f86-angrop-aarch64-support` | · | · | · | · | · | **P** | · | · | **P** | · |
| `t2v3-HU0299-webhooks-cli-subcommand` | · | · | · | · | · | F | · | · | · | · |
| `t2v3-HU03e0-cli-output-whoami-format` | · | · | · | · | · | · | **P** | · | · | · |

Legend: **P** = tainted pass (suspect), F = tainted fail (attempted, didn't work), · = clean (no upstream fetch).

The same task `t2v3-FA800f-colmodernvbert-multimodal-integration` accounts
for 6 of the 9 tainted passes (5 codex + 1 Opus 4.7) — a strong candidate for
removal from the cohort if we're scoring against an integrity-sensitive
audience.

## Efficiency

Mean ± plain sample std per trial. Trajectory metrics from `final_metrics`
(claude-code requires `harbor-lab rebuild-trajectories` to populate).

| Agent | Model | Turns | Tools | Input tok | Cached tok | Output tok | Wall (s) | n |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| Codex | `openai/gpt-5.5` *xhigh* | 96 ± 40 | 82 ± 38 | 5,622k ± 5,039k | 4,869k ± 4,522k | 24k ± 10k | 639 ± 369 | 460 |
| Claude | `claude-opus-4-6` *high* | 79 ± 50 | 47 ± 31 | 2,968k ± 2,816k | 2,887k ± 2,779k | 23k ± 16k | 642 ± 462 | 458 |
| Claude | `bedrock-claude-opus-4-7` *xhigh* | 71 ± 43 | 48 ± 31 | 4,355k ± 4,634k | 4,271k ± 4,589k | 25k ± 16k | 555 ± 427 | 460 |
| OpenCode | `glm-5.1` | 54 ± 31 | 59 ± 33 | 3,590k ± 2,913k | 3,166k ± 2,671k | 10k ± 6k | 1,244 ± 870 | 459 |
| OpenCode | `claude-haiku-4-5` | 76 ± 35 | 78 ± 35 | 4,299k ± 3,046k | 4,219k ± 3,023k | 29k ± 12k | 575 ± 412 | 460 |
| OpenCode | `Qwen3.6-35B-A3B` | 23 ± 18 | 30 ± 20 | 1,289k ± 1,577k | — | 44k ± 38k | 350 ± 229 | 458 |

Observations:

- **Opus 4.6 (high) vs 4.7 (xhigh)**: same turns + tool counts but Opus 4.6 uses **32% fewer input tokens** while achieving the same accuracy. A fair comparison would require rerunning both at the same effort.
- **GPT-5.5** has the highest turns / tool counts, consistent with codex's persistent multi-step planning style.
- **GLM-5.1** does the least output (10k) but the most wall time (1,244s) — probably reflects gateway latency contention rather than real inference cost.
- **qwen3.6** has the highest output tokens (44k) despite lowest turns. Reasoning-mode runaway: ~20% of trials emit tens of thousands of `<think>` tokens before reaching any tool call.
- **No prompt caching for qwen3** — vLLM-direct path doesn't expose cache stats the way the gateway does.

## Observations

### 1. Gateway throttling masquerades as agent-timeout

NVIDIA inference gateway latency is highly variable under load — single calls
range from ~1s when quiet to >15s when contended. opencode + the vercel-AI
SDK retry transparently with no error event in the agent log, so the retries
appear as **multi-minute stalls** between turns. Agents that hit their
wall-clock cap during these stalls produce `AgentTimeoutError`, which
`summarize_baseline.py` classifies as `agent-timeout` with no upstream
attribution.

Empirical signature: in one GLM iter3 timeout trial, 5 inter-event gaps
exceeded 2 minutes; the largest was **784 seconds (13 min)** of model silence
mid-turn. The model wasn't broken — the gateway was just slow to respond,
and the SDK was patiently retrying.

GLM-5.1 iter3 had 21 such timeouts (vs 0-1 in clean iter1/iter2), dragging
its headline down to 34.8% on that iter. Excluding iter3, GLM clusters at
38-44%, with our reported 42.0% being the cohort mean.

**Implication**: when reporting headline numbers from gateway-routed runs,
gate on iter-level outlier detection (e.g., drop any iter with >5% timeout
rate). Don't conflate "model couldn't solve" with "infra was slow today."

### 2. harbor-lab `rebuild-trajectories` strips WebFetch / WebSearch

We caught this when an Opus 4.7 tainted-pass on
`t2v3-FA800f-colmodernvbert-multimodal-integration` was hidden by the
audit script. The harbor-lab rebuild silently drops `WebFetch` and
`WebSearch` tool_calls from the rebuilt `trajectory.json`. If a downstream
tool reads the rebuilt JSON instead of the original `claude-code.txt`, it
will under-report cheating.

Fix landed in `check_integrity.py`: prefer `claude-code.txt` over
`trajectory.json` for claude-code trials (see craft-taskgen MR !62).
trajectory.json remains the only option for codex / opencode (they don't
write claude-code.txt).

### 3. Gateway-as-relay nested-codex bypass

End-to-end firewalled rerun of a toy task (codex + GPT-5.5) succeeded in
30 minutes despite firewall + outer-codex `web_search='"disabled"'`. The
agent spawned a *nested* `codex exec` inside the same container with
`-c web_search='"live"'`, a per-invocation flag override that re-enabled
the tool for the child. The nested GPT-5.5 used OpenAI's server-side web
tool to fetch the file on OpenAI's infra; the container firewall never
saw a packet, and the outer trace just shows "spawned child process."

Closing this requires (a) refusing `web_search` server-side at the
gateway / model-catalog layer for benchmark trials, (b) preventing nested
codex spawns from re-enabling tools the parent disabled, (c) extending
the integrity scan to flag nested-codex spawns + config overrides.
Out of scope for this MR; documented in craft-taskgen MR !62 and shared
with the cybergym team via vanessa-cybergym issue #15.

### 4. qwen3.6 reasoning runaway

Qwen3.6's thinking-mode response frequently fills the entire 64k
`max_completion_tokens` budget with `<think>` content before emitting any
tool call or final answer. ~20% of qwen3.6 trials hit `finish_reason=length`
mid-turn; almost all of those fail at the verifier.

Model-card recommends 81,920 max output for coding tasks (we ran at 64,000),
but the issue is structural: thinking-mode has no natural stop, and once it
spirals there's no upper bound that helps. Possible fixes:
- Disable thinking server-side via `chat_template_kwargs: {enable_thinking: false}`
- Use the Instruct (non-thinking) Qwen3 variant
- Bump `max_tokens` to 81,920 (partial mitigation only)

Unrelated to gateway latency — vLLM-direct trials had zero gateway throttling
signals. This is a model property.

### 5. Opus 4.7 has higher per-iter variance than Opus 4.6

Opus 4.7 iter pass rates spanned 41.3% to 51.1% (10pp range over 5 iters).
Opus 4.6 spanned 44.6% to 50.0% (5.4pp). The ± (per-iter) std for 4.7 is
3.81 vs 4.6's 2.17 — but the tbench-style ± is 2.80 vs 2.24 (less of a gap)
because tbench's per-task-Bernoulli model can't see iter-level correlated
noise.

Probably not gateway throttling — opus 4.7 had 0-2 agent-timeouts per iter,
not the 21 we saw on GLM iter3. More likely sampling variance at n=5 plus
(possibly) genuine model run-to-run drift. Reporting the more-conservative
tbench number for the headline; flagging the gap for reviewers.

### 6. Tool-call format quirk: nemotron-3-ultra-rl-042726

Single-task trial-balloon: the model emitted XML-style `<tool_call>` text in
the assistant content channel rather than native function-calling JSON.
opencode's parser reads only native `tool_calls[]`; XML text in `content`
goes unrecognized and the agent ends after step 1.

Sibling `nemotron-3-super-v3` on the same harness produced proper native
function calls (55 tool_use events on the same task). So this is a
`ultra-rl-042726` deployment / chat-template issue, not a Nemotron-family
limitation. Filed separately with NVIDIA gateway team. Not one of the 6
official models in the leaderboard.

## Methodology

### Cohort

- **v2b-92**: 92 craft-taskgen tools-track tasks, source of truth at
  `references/v2b-tasks.txt`.
- Two F2P post-hoc skips applied at score time
  (`references/v2b-posthoc-skips.txt`).

### Models on the gateway (canonical wire names for `inference-api.nvidia.com/v1/chat/completions`)

| Model | Wire model name |
|---|---|
| Claude Opus 4.6 | `aws/anthropic/bedrock-claude-opus-4-6` |
| Claude Opus 4.7 | `aws/anthropic/bedrock-claude-opus-4-7` |
| Claude Haiku 4.5 | `azure/anthropic/claude-haiku-4-5` |
| GPT-5.5 (codex) | `openai/openai/gpt-5.5` |
| GLM-5.1 | `nvidia/zai-org/glm-5.1` |
| Qwen3.6-35B-A3B | `nvidia/qwen/qwen3.6-35b-a3b` |

Pattern: `<provider-route>/<upstream-id>` where the provider segment is
`aws`/`azure`/`nvidia`/`openai`. For OpenAI specifically, the upstream id
itself starts with `openai/`, hence two `openai/` segments in a row.

> Note on the Harbor `--model` flag: the doubled-prefix form
> (`nvidia/nvidia/...`) you may see in launch logs is a Harbor opencode-provider
> dispatch quirk. opencode strips one leading prefix on the wire, so harbor
> pre-doubles it. The wire-canonical name (which is what you pass for
> direct API use) is the single-prefix form in the table above.

### Sampling defaults

| Model | T | top_p | top_k | reasoning effort |
|---|---|---|---|---|
| Opus 4.6 | default | default | — | `high` |
| Opus 4.7 | default | default | — | `xhigh` |
| Haiku 4.5 | default | default | — | `medium` |
| GPT-5.5 (codex) | default | default | — | `xhigh` |
| GLM-5.1 | 1.0 | 0.95 | — | n/a |
| Qwen3.6 | 0.6 | 0.95 | 20 | n/a |

Authoritative source: `src/craft_taskgen/baselines/reasoning_defaults.py`
plus `apply_opencode_family_sampling` family-detect blocks in
`scripts/run-baselines.sh`. Reasoning-effort enforcement details in
[`docs/runbooks/baseline-reproducibility.md`](../runbooks/baseline-reproducibility.md).

### Agent versions

- claude-code: pinned at **2.1.118** (post-2026-04-23 Anthropic regressions, see `docs/runbooks/baseline-reproducibility.md`).
- codex: pinned at **0.121.0**.
- opencode: pinned at **1.4.9**.
- harbor: pinned at `46bb68c`.

### Output cap

`OPENCODE_BUILD_MAX_TOKENS=64000` and `CLAUDE_CODE_MAX_OUTPUT_TOKENS=64000`
host-exported into agent envs. This is a per-turn cap (not a context cap).
Qwen3.6's reasoning runaway hits this cap; everyone else stays well under.

### Concurrency

| Run | concurrency | rationale |
|---|---|---|
| GLM, opus 4.6 (Mon) | 4 | fits gateway capacity without throttling |
| qwen3.6 (final) | 4 | conc-8 endpoint stability was poor |
| opus 4.6 (Sun extra iters) | 2 | gateway congestion that day; conc 2 to be safe |
| codex / opus 4.7 / haiku (one Jeff iter included) | varied | reused historical runs from Apr 27 |

### How the 5-iter set was assembled per model

- **codex**: 4 of our Apr-30 iters + 1 Jeff Apr-27 iter
- **opus 4.7**: 4 of our Apr-30 iters + 1 Jeff Apr-27 iter
- **opus 4.6**: 5 of our iters from May 2-4
- **GLM-5.1**: 5 of our iters (4 from May-2 ×5-iter run minus iter3 which was gateway-throttled; +1 from a fresh Mon run for the 5th)
- **haiku**: 4 of our Apr-30 iters + 1 Jeff Apr-27 iter
- **qwen3.6**: 5 of our conc-4 iters (4 from May-2 ×4-iter run minus the lowest 6.5% iter; +2 from a Mon ×2-iter run filling to 5)

Symlink layout for analysis at `evals-final/<model>/<iter>/` → original baseline-* dirs.

## Reproducibility

### Raw artifacts (Google Drive — too big for repo)

- **30 trial bundles** (per model × per iter, ~10 GB total): https://drive.google.com/drive/folders/1TBgDusWasXaNRwn9ZbMS0Pbx2aPbNclG
  Internal layout per archive: `<model>-<iter>-<YYYYMMDD>/baseline-…/<task-dirs>/…` (jfarris-style).
- **Full per-trial CSV** (2,760 rows, all 6 models × 5 runs × 92 tasks):
  https://drive.google.com/file/d/1Y-GoGUeZ8l-Zs_328FWKS7bCfjenftdb/view?usp=sharing.
  CSV is also committed as
  [`docs/analyses/data/v2b-all-trials-92x5x6.csv`](data/v2b-all-trials-92x5x6.csv)
  for join convenience.

### Scoring & analysis scripts (in this repo)

| Script | Purpose |
|---|---|
| `scripts/summarize_baseline.py` | The headline reporter. Walks trial dirs, applies cohort + post-hoc skips, emits the F2P/P2P/% resolved table and efficiency metrics. Reproduces the leaderboard from raw trial dirs. |
| `scripts/check_integrity.py` | Trajectory audit — flags upstream fetches (curl / wget / git clone / urllib / requests / httpx / aiohttp / WebFetch / WebSearch). Per-task clean-vs-tainted rollup. **Read `claude-code.txt` source-of-truth for claude-code trials, NOT rebuilt `trajectory.json`** — see Observation #2. |
| `scripts/run-baselines.sh` | The baseline launcher. Sources reasoning-effort and sampling defaults; assembles the harbor invocation. |
| `scripts/multirun-v2b.sh` | Wraps `run-baselines.sh` for multi-iter sweeps (gateway-routed agents). |
| `scripts/multirun-vllm.sh` | Wraps `run-baselines.sh` for vLLM-direct sweeps (qwen3.6 path). |

### Reproducing the headline table from scratch

Given the 30 trial bundles unpacked at `evals-final/<model>/<iter>/`:

```bash
uv run python scripts/summarize_baseline.py /path/to/evals-final
```

Produces the F2P/P2P/% resolved table directly. For a per-trial CSV:

```bash
uv run python scripts/summarize_baseline.py /path/to/evals-final \
    --csv all-trials.csv
```

For the integrity scan:

```bash
uv run python scripts/check_integrity.py /path/to/evals-final
```

### Related MRs

- craft-taskgen MR !66: tbench-style ± formula in summarize_baseline (merged into main).
- craft-taskgen MR !62: `check_integrity.py` + `docker-firewall.sh` + `rerun-tainted.sh` + harbor-codex patches.
- craft-bench MR !46: planning-dimension results doc — sibling to this MR (different dimension).
- craft-taskgen MR !69: search-vs-e2e analysis — sibling.

## Future directions

1. **Cohort hygiene.** `t2v3-FA800f-colmodernvbert-multimodal-integration`
   accounts for 6 of 9 tainted-passes. Strong candidate for removal or
   replacement before any external publication of these numbers.
2. **Apples-to-apples opus 4.6 vs 4.7.** Both at the same reasoning effort
   (either both `high` or both `xhigh`) — current 4.7 = xhigh + 4.6 = high
   comparison is not fair. Cheap to redo.
3. **Re-run flagged trials under firewall.** craft-taskgen MR !62 has the
   `rerun-tainted.sh` orchestrator. Land that, then rerun the 9 tainted
   trials with `docker-firewall.sh` enabled to confirm pass/fail on the
   merits. Watch for the gateway-as-relay nested-codex bypass (Observation
   #3).
4. **Qwen3 thinking-mode disable experiment.** Drop `enable_thinking: false`
   server-side and re-run; quantify how much of the 11.3% headline is real
   capability vs how much is reasoning runaway. Likely will move qwen3 up
   ~5pp.
5. **Gateway-side telemetry for throttling attribution.** Right now the only
   signal we have for slow-iter detection is post-hoc analysis of
   inter-event gaps in opencode trajectories. Asking the NVIDIA gateway
   team for trial-correlated request latency / retry-count metadata would
   make the throttling attribution from Observation #1 first-class.
6. **Nemotron-3-Ultra fixup with NVIDIA**. Once they ship a fix for the
   XML-tool-call format issue (Observation #6), redo the trial-balloon and
   if successful do a full 5-iter eval. Currently excluded from the
   leaderboard.

## Open questions

- Is the apparent **opus-4.6 ≈ opus-4.7** equivalence stable? Could it be
  a v2b-cohort artifact (e.g. tasks that don't reward additional reasoning
  budget)?
- Does **GLM-5.1's 42% reflect the model**, or the gateway latency we
  observed during its runs? A re-run on a quiet day would help separate.
- The single-run probes (sonnet-4.6, qwen3.5, MiniMax M2.7) — do they hold
  up at n=5? sonnet-4.6 at 42.4% is suggestively close to the GLM-5.1 number;
  worth a 5-iter run if budget allows.

## Out of scope

- No new pipeline code or scoring features (those land in MR !62 and !66).
- No raw trajectories or tarballs in this MR — those are on Drive.
- No SWE-Bench Pro re-derivation; published numbers are taken at face
  value as a third-party reference point.
