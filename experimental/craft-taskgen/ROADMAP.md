# Roadmap

## Near-term

**harbor-trial-deep-dive skill dependency on harbor-lab.**
The `harbor-trial-deep-dive` skill currently requires `harbor-lab` to be installed.
Need to decide: release a subset of harbor-lab alongside craft-taskgen, or pull
the relevant parts directly into craft-taskgen so the skill works standalone.

**Agentic benchmark eval integration.** @Jiantao
Integrate Jiantao's agentic benchmark evaluation checklists
(gitlab-master.nvidia.com/llm_evaluation_analsysis/agentic-benchmark-eval)
as a pipeline step. Use the checklists to validate task quality dimensions
(instruction clarity, verifier coverage, difficulty calibration) that the
current pipeline doesn't explicitly check. Could run after hardness check
as a second quality gate, or as a parallel validation alongside Docker
build. Need to align with Jiantao on which checklist items map to
automated checks vs human review.

**Dedupe across existing accepted tasks.**
Before running new candidates, check for overlap with tasks already in the
craft-bench accepted set. Embedding-based similarity or repo+file overlap
heuristic to avoid building duplicate tasks that test the same code paths.

## Medium-term

**Eval step overhaul — reduce noise, improve yield.**
The eval step has high noise in both directions. False alarms: 42 of 89
built tasks were estimated hard but turned out trivially easy. False
negatives: re-running accepted tasks through eval shows some get REJECT on
a second pass. The eval killed 173 of 277 candidates (62%) in the weekend
run, but we don't know how many rejects would have been accepted. Each
false alarm burns a build + 2 hardness checks (~3 LLM calls).

Approach: (1) Measure: take 20-30 eval-rejected candidates, push through
the full pipeline skipping eval, see how many would have been accepted.
This quantifies the cost of the gate. (2) Fix: add a cheap heuristic
pre-screen before the LLM eval — repo tree analysis (test file count,
integration tests, CI presence), commit stats (lines changed, files
touched), and correlation with accepted-task characteristics. Our
prefilters.py currently does string matching on commit subjects; a richer
feature vector could cut LLM costs while improving yield. (3) Improve the
LLM eval itself — structured rubric instead of open-ended judgment,
possibly two-call ensemble to reduce variance.

**DockerOnlyRunner.**
Run build → validate → hardness without Harbor. Lets people use the pipeline
for task creation and validation without the full agent smoke-testing
infrastructure.

**Git history added to Docker**
The current F2P/P2P classifier extracts postmerge test files from local git repos
(repos/{repo}/) at classification time. The more realistic approach is to bundle
the repo at parent_sha into the Docker image (environment/repo.bundle) with a
companion environment/restore_git.sh that inflates it inside the container. This
gives the agent access to the full commit history up to the task's basis commit, lets
classification run entirely inside Docker without requiring local repo access, and
enables the overlay step to use git show to retrieve postmerge test files from
within the container. The merge commit and anything after it must NOT be included in
the bundle to prevent the agent from reading the solution.

**Propagate reproducibility guarantees into core pipeline.**
MR !20 introduced pinned deps (`requirements.lock`) and a per-task `manifest.json` into the adapter layer. The core pipeline doesn't yet have these guarantees, but it would be valuable to add.

**Store tests and solution as patches (SWE-bench style).** @Ryan
Currently tests are stored as Python files (preserving repo directory structure)
and the oracle solution is applied by dynamically checking out the post-merge
commit. Ryan proposed moving to SWE-bench's approach: store both tests and
solution as raw text patches with diff markers. This removes reliance on network
access for oracle runs and gives more flexibility and simplification in how we
package tasks. Not high priority for v1, but a candidate v2 direction once the
current pipeline stabilizes.