# SWE-Bench-Pro instruction spot-check

A small offline harness that runs SWE-Pro PRs through our `evaluate → build → alignment` loop and renders a side-by-side comparison of our pipeline's instruction vs. SWE-Pro's three-part task definition (`problem_statement` / `requirements` / `interface`).

Complements other in-flight SWE-Pro work in this repo: this harness runs build with the diff alone (input = code change) and asks how the resulting natural-language instruction differs from SWE-Pro's curated one.

## How to run

```bash
# 1. Provision repos. SWE-Pro spans 11 repos; only the names you sample need
#    to be cloned under repos/<short-name> (drop the owner/ prefix).
ls repos/qutebrowser >/dev/null || git clone https://github.com/qutebrowser/qutebrowser.git repos/qutebrowser

# 2. Ingest. Pulls SWE-Pro records, applies patch + test_patch onto base_commit
#    in repos/<repo> as a synthetic commit, emits the CSV calibrate-alignment.py
#    consumes. Skips PRs whose patches don't apply cleanly.
uv run python scripts/swepro/ingest.py \
    --repos qutebrowser \
    --limit-per-repo 10 \
    --output swepro_input.csv

# 3. Calibrate. Runs evaluate → build → alignment with N=3 candidates per row,
#    matching the production orchestrator. Eval can reject; alignment can fail
#    after up to MAX_BUILD_REGENS_PER_CANDIDATE rebuild attempts. Expect ~40%
#    of rows to reach alignment-ok on a 10-row qutebrowser sample.
uv run python scripts/calibrate-alignment.py \
    --input swepro_input.csv \
    --output swepro_calib.csv \
    --mode full --n 3 --sample 0 --concurrency 3

# 4. Render. Joins calib output with SWE-Pro's three task fields, drops rows
#    where our pipeline didn't produce an instruction, emits HTML + CSV + MD.
uv run python scripts/swepro/render.py \
    --calib swepro_calib.csv \
    --output-html swepro_comparison.html \
    --output-csv swepro_comparison.csv \
    --output-md swepro_comparison.md
```

The HTML is self-contained (inlined CSS, server-side markdown) and works offline. Pass `--include-rejected` to render eval-rejected rows too.

## Publishing on GitLab Pages (internal NVIDIA share)

Personal-namespace projects on `gitlab-master.nvidia.com` get **0 runners** assigned — the `pages` job will sit `pending` indefinitely. Two requirements for it to actually deploy:

1. Project must live in a group namespace with runners attached (e.g. `aire/scratch`, which has 20 runners including a Shared Pages Runner).
2. `.gitlab-ci.yml` must specify a runner tag the group's runners advertise — `nemollm-common-aws` works for AWS-style non-GPU jobs.

Minimal `.gitlab-ci.yml`:

```yaml
stages:
  - deploy

pages:
  stage: deploy
  image: alpine:latest
  tags:
    - nemollm-common-aws
  script:
    - mkdir -p public
    - cp index.html public/index.html
  artifacts:
    paths:
      - public
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

Drop `swepro_comparison.html` in as `index.html`, push to `main`, wait for the pipeline. The published URL is at `projects/<id>/pages` via the API or in the project's *Deploy → Pages* UI.

## Open questions / lines to explore on resume

- **Drop the `subject` leakage.** `ingest.py` derives `subject` from the first 200 chars of `problem_statement`, and our evaluate step uses it as a "PR title" hint. Build itself never sees `subject`, but cleaner experiments would either pass the commit message's first line instead, or pass empty.
- **Add a "refine-existing-instruction" mode.** Run a second pass where SWE-Pro's `problem_statement` is fed as `instruction_sketch` (i.e. `--skip-eval` plus subject-injected) so build refines a real seed rather than writing from scratch. Tells us whether build adds value when given a good starting point.
- **Why 6 of 10 eval-rejected on the qutebrowser sample?** Unknown if those are true rejects (correctly out-of-scope PRs) or false rejects. Worth eyeballing the reasons — `swepro_calib.csv` has `new_eval_reason` per row.
- **Cross-language coverage.** SWE-Pro's other 10 repos are mostly Go/JS/TS. Tells us whether our build prompt holds outside Python. Cheapest lift: `git clone` one of {`ansible`, `flipt-io/flipt`, `navidrome/navidrome`} and rerun ingest with `--repos <name>`.
- **`--max-rebuilds 3`.** Probably not worth it on this cohort — our 6 dropouts were at eval, not alignment, so a higher regen budget wouldn't reach them.

## Outputs in this thread

- Live page (internal NVIDIA only, GitLab SSO): http://swepro-craft-comparison-1a0846.gitlab-master-pages.nvidia.com/
- Source repo: https://gitlab-master.nvidia.com/aire/scratch/swepro-craft-comparison
