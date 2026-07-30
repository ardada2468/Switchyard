# Repo Dependency Map for the Tools Pipeline, and What SWE-Bench JSONL Can Replace

  ## Summary

  Map every place the current tools pipeline depends on a local repo clone or real git SHAs, then classify each dependency
  as one of:

  - already satisfiable from swebench_pro.jsonl
  - satisfiable from JSONL with small adapter changes
  - not satisfiable from JSONL alone without redesigning the step

  The immediate conclusion is:

  - select does not fundamentally need the repo
  - evaluate does not fundamentally need the repo, but the current prompt is repo/git-driven
  - build can likely be made dataset-native
  - assemble artifacts and later verification steps are where the current pipeline most strongly assumes real git commits
    and a real checkout

  So if the goal is “how would we go about removing repo dependency?”, the clean way is to treat this as a step-by-step
  replacement plan, not as one monolithic rewrite.

  ## Current Repo Dependencies by Step

  ### 0. Import / Mine

  #### GitHub miner path

  Current repo dependency:

  - yes
  - the miner uses:
      - GitHub PR metadata
      - local repo clone
      - git merge-base / diff stats
  - implemented in src/craft_taskgen/miner.py:1

  Can SWE-bench JSONL replace it?

  - yes, for front-half candidate generation
  - this is already partially done by the SWE-bench importer

  What JSONL already has:

  - repo
  - base_commit
  - patch
  - test_patch
  - problem_statement
  - requirements
  - fail_to_pass
  - pass_to_pass

  What it does not have:

  - real fix commit SHA
  - merge-base from git history
  - author/date/title in miner form

  Status:

  - already mostly replaced for candidate-file generation

  ### 1. Select

  Current repo dependency:

  - very weak, mostly incidental
  - select_candidates(...) in src/craft_taskgen/steps.py:282 only:
      - loads candidate JSON
      - applies score/prefilters
      - warns if repos/<repo>/ does not exist

  What it fundamentally needs:

  - candidate metadata only

  Can JSONL replace it?

  - yes, already satisfied by the importer output

  Conclusion:

  - select does not fundamentally need the repo

  ### 2. Evaluate

  Current repo dependency:

  - yes, by prompt design
  - evaluate_candidate_prompt(...) in src/craft_taskgen/prompts.py:276 explicitly says:
      - git -C repos/{repo} show {sha} --stat
      - git -C repos/{repo} show {sha}

  What it fundamentally needs:

  - enough code/test/diff context for the LLM to decide whether the candidate is a good task seed

  What JSONL already has that could replace repo access:

  - patch
  - test_patch
  - problem_statement
  - requirements
  - interface
  - repo_language
  - issue_specificity
  - issue_categories
  - selected_test_files_to_run

  Conclusion:

  - evaluate does not fundamentally need the repo
  - current implementation needs the repo only because the prompt is git-centric

  ### 3. Build Task Instruction

  Current repo dependency:

  - yes, by prompt design
  - build_task_prompt(...) in src/craft_taskgen/prompts.py:345 instructs:
      - git -C repos/{repo} show {merge_base_sha} {sha}

  What it fundamentally needs:

  - task/problem description
  - code/test diff context
  - enough public API details to write a good instruction.md

  What JSONL already has:

  - problem_statement
  - requirements
  - interface
  - patch
  - test_patch
  - fail_to_pass
  - pass_to_pass

  Conclusion:

  - build can probably be made dataset-native
  - repo dependency here is also prompt-driven, not fundamental

  ### 4. Hardness Check

  Current repo dependency:

  - no direct repo dependency
  - it reads task files already created in the task directory
  - implemented through instruction.md review and diagnostics

  What it fundamentally needs:

  - generated task files only

  Conclusion:

  - hardness does not need repo access once the task files exist

  ### 5. Assemble Artifacts

  This is where the current pipeline becomes strongly git-dependent.

  #### 5a. Generate solution patch / solve.sh

  Current repo dependency:

  - yes, hard dependency
  - _generate_solve_sh(...) in src/craft_taskgen/steps.py:468 runs:
      - git diff --name-only ...
      - git diff merge_base_sha commit_sha

  What it fundamentally needs:

  - the source patch to apply as the oracle solution

  What JSONL already has:

  - patch

  Conclusion:

  - this can be replaced directly from JSONL
  - the current repo dependency is an implementation choice, not a fundamental requirement

  #### 5b. Discover changed test files

  Current repo dependency:

  - yes
  - _find_commit_test_files(...) in src/craft_taskgen/steps.py:1406 runs:
      - git diff merge_base_sha commit_sha --name-only --diff-filter=AM

  What it fundamentally needs:

  - the list of changed test file paths

  What JSONL already has:

  - test_patch, which already contains the changed test file paths

  Conclusion:

  - this can be replaced directly from JSONL

  #### 5c. Extract post-merge test files

  Current repo dependency:

  - yes, hard dependency in current code
  - _extract_postmerge_tests(...) in src/craft_taskgen/steps.py:1443 runs:
      - git show {commit_sha}:{rel_path}

  What it fundamentally needs:

  - the final post-change contents of changed test files

  What JSONL already has:

  - test_patch, which contains the post-change content in diff form

  Conclusion:

  - this is replacable from JSONL, but requires rebuilding file contents from unified diff instead of reading them from
    git
  - that is a real implementation change, but not a conceptual blocker

  ### 6. Build Dockerfile

  Current repo dependency:

  - yes, by prompt design
  - build_dockerfile_prompt(...) in src/craft_taskgen/prompts.py:414 instructs the model to:
      - inspect files at merge base
      - run git -C repos/{repo} remote get-url origin
      - clone the repo at merge_base_sha

  What it fundamentally needs:

  - a way to recreate the pre-change environment under /code
  - dependency/install information
  - a base code tree to run tests against

  What JSONL already has:

  - repo
  - base_commit
  - dockerhub_tag as a strong environment hint

  What JSONL does not have:

  - full dependency manifests
  - repo contents at base_commit
  - remote URL as a guaranteed explicit field

  Conclusion:

  - this step still needs repo contents in some form, unless you switch to a different environment sourcing model
  - JSONL alone is not enough to recreate the base repo tree

  ### 7. F2P / P2P Classification

  Current repo dependency:

  - indirect but strong
  - classification runs inside the generated environment against:
      - pre-merge code checkout
      - overlaid postmerge tests
      - solution patch

  What it fundamentally needs:

  - base repo tree at pre-change state
  - test file contents after change
  - oracle patch for source changes

  What JSONL already has:

  - base_commit
  - patch
  - test_patch
  - fail_to_pass
  - pass_to_pass
  - selected_test_files_to_run

  What JSONL does not have:

  - base repo contents themselves

  Conclusion:

  - JSONL has the delta, but not the full base tree
  - you still need either:
      - the repo checkout at base_commit, or
      - some alternative packaged base environment

  ### 8. Oracle Check

  Current repo dependency:

  - indirect
  - depends on the environment assembled above

  What it fundamentally needs:

  - runnable pre-change codebase
  - source patch
  - tests and scoring harness

  What JSONL already has:

  - source/test deltas and test lists

  What it does not have:

  - the full base code tree

  Conclusion:

  - same as classification: JSONL has enough to describe the delta, not enough to reconstruct the whole working repo

  ### 9. Smoke / Triage / Compare

  Current repo dependency:

  - no direct git dependency once the task package is built
  - these steps operate on task artifacts and runtime logs

  What they fundamentally need:

  - a fully runnable benchmark task package

  Conclusion:

  - they do not care where the task package came from
  - they only depend on earlier steps successfully producing it

  ## Consolidated Dependency Table

  ### Steps that do not fundamentally need the repo

  - select
  - evaluate
  - build
  - hardness
  - smoke/triage/compare after task assembly is complete

  ### Steps where JSONL already contains the needed delta

  - solution patch generation
  - changed test file path discovery
  - postmerge test content reconstruction

  ### Steps that still need base repo contents, not just deltas

  - Dockerfile/environment construction
  - F2P/P2P classification
  - oracle check

  ## What SWE-Bench JSONL Already Gives Us

  From the sampled dataset, the JSONL gives:

  - repository identity:
      - repo
  - pre-change reference:
      - base_commit
  - source delta:
      - patch
  - test delta:
      - test_patch
  - task/issue description:
      - problem_statement
      - requirements
      - interface
  - test expectations:
      - fail_to_pass
      - pass_to_pass
      - selected_test_files_to_run
  - environment hint:
      - dockerhub_tag
  - metadata:
      - issue_specificity
      - issue_categories
      - repo_language
      - before_repo_set_cmd

  This is enough to make the front half and much of artifact assembly dataset-native.

  ## What JSONL Does Not Give Us

  The missing piece is not mostly “diff metadata”; it is the full pre-change repository state.

  JSONL does not directly provide:

  - the full checkout contents at base_commit
  - dependency manifests in extracted structured form
  - a guaranteed canonical clone URL
  - a ready-made post-change test file tree
  - a ready-made post-change source tree

  That means any step that needs to execute code still needs:

  - the repo clone, or
  - a prebuilt base environment/image, or
  - a new task format that bundles the base tree another way

  ## Recommended Way to Go About It

  ### Phase 1: Remove repo dependency from evaluate

  Make evaluate dataset-native first.

  Reason:

  - lowest-risk, highest-leverage change
  - JSONL already has everything the evaluator needs
  - immediately removes the first meaningful repo dependency

  Implementation direction:

  - store patch, test_patch, problem_statement, requirements, interface, and related dataset fields in candidate_data
  - add a new evaluation prompt variant for imported SWE-bench candidates
  - have step_evaluate(...) branch:
      - GitHub-mined candidate -> existing prompt
      - SWE-bench-imported candidate -> dataset-native prompt

  ### Phase 2: Remove repo dependency from build

  Use the same candidate metadata to build instruction.md.

  Implementation direction:

  - add a dataset-native build_task_prompt(...) variant
  - use:
      - problem_statement
      - requirements
      - interface
      - patch
      - test_patch
      - evaluator output

  ### Phase 3: Replace git-based artifact assembly with patch-native assembly

  This is the real mechanical change.

  Implementation direction:

  - solution/changes.patch should come from row["patch"]
  - changed test paths should come from test_patch
  - tests/postmerge_tests/ should be reconstructed by applying/parsing test_patch into full file contents

  ### Phase 4: Decide how to source the base repo tree

  This is the actual hard boundary.

  Options:

  1. Keep requiring local repo clones for build/classify/oracle only
      - easiest path
      - removes repo dependency from early LLM stages
  2. Build tasks from prebuilt images keyed by dockerhub_tag
      - more dataset-native
      - requires a different environment contract
  3. Create a new packaging flow that materializes the base tree from an external source
      - largest redesign

  Recommended default:

  - keep repo clones for environment/classification/oracle for now
  - remove repo dependency only from evaluate and build first

  ## Important Public Interface / Type Changes

  If this plan is implemented, the importer and task state should preserve and expose the following dataset metadata
  consistently inside candidate_data:

  - source_metadata.patch
  - source_metadata.test_patch
  - source_metadata.problem_statement
  - source_metadata.requirements
  - source_metadata.interface
  - source_metadata.fail_to_pass
  - source_metadata.pass_to_pass
  - source_metadata.selected_test_files_to_run
  - source_metadata.dockerhub_tag

  No new user-facing CLI is required for the mapping exercise itself, but later implementation will likely need:

  - prompt branching based on candidate source
  - possibly a source_dataset check inside pipeline steps

  ## Test Cases and Scenarios for the Eventual Implementation

  ### Evaluate dataset-native

  - imported SWE-bench candidate evaluates without repo clone present
  - GitHub-mined candidate still uses existing prompt path
  - prompt includes patch/test context from JSONL

  ### Build dataset-native

  - imported candidate produces instruction.md using dataset metadata only
  - no git commands are required for the build prompt path

  ### Patch-native assembly

  - solution/changes.patch exactly matches row["patch"]
  - tests/postmerge_tests/ reconstructed from test_patch has correct paths and contents
  - changed test path discovery comes from test_patch, not git diff

  ### Repo-still-required later

  - Docker/classify/oracle still fail clearly if no base repo/environment is available
  - error message explains that early stages are dataset-native but execution stages still require base code

  ## Assumptions and Defaults

  Chosen defaults:

  - the immediate useful goal is to remove repo dependency from evaluate and build, not the entire pipeline at once
  - the SWE-bench patch / test_patch split should remain authoritative
  - the current base repo/environment dependency for execution stages remains in place until separately redesigned

  Key assumption:

  - swebench_pro.jsonl provides enough semantic information for candidate evaluation and instruction drafting, but not
    enough to recreate a runnable pre-change codebase without some external source of the base tree