# SWE-bench Pro Suitability: Narrow Tests and Trivial Tasks

This memo focuses on two task-suitability modes in our 263 evaluated SWE-bench Pro tasks.

- Mode 1: `narrow_tests` verdicts, which challenge verifier robustness and implementation flexibility.
- Mode 2: `reject` verdicts for trivial/mechanical tasks, which challenge the claim that tasks are consistently challenging and industrially relevant.

Paper claims targeted: SWE-bench Pro says it emphasizes `challenging, diverse, and industrially relevant tasks`, and that its human workflow recovers unit tests as `robust verifiers` while maintaining `implementation flexibility`.

The case studies below are selected from raw run evidence, not just verdict labels. For each example I inspected the task text/test patch in `swebench_pro.jsonl`, the agent trajectory, and the verifier outputs under `docs/analyses/data/swebench-pro/runs/combined_non_error`.

Case index: `docs/analyses/data/swebench-pro/findings/swebench_pro_two_mode_cases.csv`

## Headline Counts

- Narrow-test tasks: 40/263 (15.2%); agent passed 19/40 (47.5%).
- Rejected tasks: 167/263 (63.5%); agent passed 112/167 (67.1%).
- Accepted tasks: 96/263 (36.5%); agent passed 39/96 (40.6%).

Rejected tasks passing more often than accepted tasks is not proof by itself, but it is consistent with the evaluator's triviality judgments.

## Aggregate Tables

### Pass Rate By Evaluation Verdict

| new_eval_verdict | n | passed | pass_rate |
| --- | --- | --- | --- |
| accept | 96 | 39 | 40.6% |
| reject | 167 | 112 | 67.1% |

### Pass Rate By Alignment Verdict

| alignment_verdict | n | passed | pass_rate |
| --- | --- | --- | --- |
| leaked | 70 | 37 | 52.9% |
| narrow_tests | 40 | 19 | 47.5% |
| ok | 152 | 95 | 62.5% |
| skipped | 1 | 0 | 0.0% |

### Reject Patterns

| reject_pattern | n | passed | pass_rate |
| --- | --- | --- | --- |
| BT1_trivial_core_logic | 129 | 86 | 66.7% |
| AL1_mechanical_or_constructed | 31 | 22 | 71.0% |
| SA1_obvious_strategy | 4 | 2 | 50.0% |
| other_reject_reason | 1 | 0 | 0.0% |
| hard_filter:no_meaningful_tests | 1 | 1 | 100.0% |
| hard_filter:no_behavioral_tests | 1 | 1 | 100.0% |

### Narrow-Test Cause Buckets

| narrow_cause | n | passed | pass_rate |
| --- | --- | --- | --- |
| exact format/string + fixture/design choice + unstated behavior | 6 | 3 | 50.0% |
| private/internal API + fixture/design choice + unstated behavior | 6 | 2 | 33.3% |
| private/internal API + exact format/string | 5 | 1 | 20.0% |
| exact format/string | 5 | 2 | 40.0% |
| private/internal API + exact format/string + unstated behavior | 4 | 3 | 75.0% |
| private/internal API + exact format/string + fixture/design choice + unstated behavior | 3 | 1 | 33.3% |
| private/internal API + exact format/string + fixture/design choice | 3 | 2 | 66.7% |
| other narrow-test issue | 2 | 1 | 50.0% |
| fixture/design choice + unstated behavior | 1 | 1 | 100.0% |
| unstated behavior | 1 | 0 | 0.0% |
| private/internal API + fixture/design choice | 1 | 1 | 100.0% |
| exact format/string + fixture/design choice | 1 | 0 | 0.0% |
| exact format/string + unstated behavior | 1 | 1 | 100.0% |
| private/internal API + unstated behavior | 1 | 1 | 100.0% |

## Mode 1: Narrow Tests Causing Unfair Failures

`narrow_tests` means the reference tests require behavior or implementation choices that the instruction does not specify. This directly pressures the paper's verifier-quality claim because a semantically valid alternative could fail hidden tests.

These examples are deliberately not generic label summaries. They tie the task contract to what the agent actually did and the exact hidden-test failure.

### `qutebrowser-fec187c2` (qutebrowser)

- Result: agent failed; required tests 242/243; true F2P tests 1.
- Heuristics: source diff 40 lines; test diff 1 lines; top-level agent turns 112; edit calls 2; bash calls 72.
- Category: unstated search-engine alias/base-url contract.
- Raw artifacts: `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_qutebrowser__qutebrowse__Bji3fyb/agent/trajectory.json`, `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_qutebrowser__qutebrowse__Bji3fyb/verifier/output.json`, `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_qutebrowser__qutebrowse__Bji3fyb/verifier/test-stdout.txt`.
- Task contract: The task is framed as search URL parameter encoding: encode spaces and special characters, handle hyphens/spaces, and work across host domains. It says no new public interfaces are introduced.
- Agent trajectory evidence: The agent inspected `qutebrowser/utils/urlutils.py`, repeatedly ran search-related urlutils tests, and concluded the implementation already used `urllib.parse.quote(term, safe='')`, which encodes slashes, spaces, and `!`. The final trajectory says all 23 search URL tests pass and makes no source edit for this task.
- Verifier evidence: The verifier passed 242/243 required tests and failed exactly one F2P test: `tests/unit/utils/test_urlutils.py::test_get_search_url[test path-search-www.qutebrowser.org-q=path-search-True]`. The test patch adds only one parameter row: `('test path-search', 'www.qutebrowser.org', 'q=path-search')`.
- Why this challenges the claim: The failing test is not about percent-encoding; it relies on qutebrowser's search-engine alias parsing and base URL behavior for the token `test`. A solution that correctly fixes the stated encoding bug can still fail this hidden row, which undercuts the claim that recovered tests preserve implementation flexibility.

### `ansible-0fd88717` (ansible)

- Result: agent failed; required tests 26/30; true F2P tests 4.
- Heuristics: source diff 108 lines; test diff 17 lines; top-level agent turns 37; edit calls 7; bash calls 5.
- Category: private helper return-shape contract.
- Raw artifacts: `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_ansible__ansible-0fd887__2ts3KZw/agent/trajectory.json`, `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_ansible__ansible-0fd887__2ts3KZw/verifier/output.json`, `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_ansible__ansible-0fd887__2ts3KZw/verifier/test-stdout.txt`.
- Task contract: The task asks the password lookup plugin to parse password, salt, and ident values, reuse stored ident values, avoid duplicate writes, validate ident conflicts, and provide clear errors. The benchmark task says no new interfaces are introduced.
- Agent trajectory evidence: The agent first changed `_parse_content()` to return `(password, salt, ident)`, then deliberately backed that out to preserve the old helper shape and added a separate `_parse_ident()` helper. It updated `run()` to use stored ident values, validate conflicts, avoid rewrites, and handle duplicated `ident=` fragments. Its repro script verified parsing and idempotence, and the final trajectory reports the implementation correct.
- Verifier evidence: The verifier passed 26/30 required tests but failed all four new `TestParseContent` rows. The test patch directly unpacks `_parse_content(content)` into three values for empty, plain-password, salt-only, and salt+ident files.
- Why this challenges the claim: The hidden tests reject a reasonable internal design that keeps `_parse_content()` backward-compatible and adds `_parse_ident()`. The test suite is checking a private helper tuple shape, not just the user-visible lookup behavior.

### `ansible-bec27fb4` (ansible)

- Result: agent failed; required tests 17/20, with 17/17 P2P passed and 0/3 true F2P passed.
- Heuristics: source diff 467 lines; test diff 499 lines; top-level agent turns 177; edit calls 16; bash calls 73.
- Category: private role-doc helpers + exact no-color formatting.
- Raw artifacts: `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_ansible__ansible-bec27f__HPrBL4m/agent/trajectory.json`, `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_ansible__ansible-bec27f__HPrBL4m/verifier/output.json`, `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_ansible__ansible-bec27f__HPrBL4m/verifier/test-stdout.txt`.
- Task contract: The task asks for readable `ansible-doc` output, TTY/no-color fallbacks, role summaries, graceful error handling, FQCN accuracy, URL formatting, and stable diagnostic wording. It does not introduce public interfaces.
- Agent trajectory evidence: The agent made broad source changes in `lib/ansible/cli/doc.py` and `lib/ansible/utils/plugin_docs.py`: styled headers, role listing/doc fallbacks, comma-separated doc-fragment support, no mid-word wrapping, loader fallback behavior, and warning handling. It ran unit tests plus ansible-doc integration checks and ended with a trajectory summary claiming unit tests, playbook integration tests, and fixture comparisons all passed.
- Verifier evidence: The verifier passed 17/20 required tests, but those 17 were all P2P/regression tests. It failed all three true F2P tests: the italic `tty_ify` no-color marker case, `test_rolemixin__build_summary`, and `test_rolemixin__build_summary_empty_argspec`. The test patch calls private helpers directly and changes `RoleMixin._build_summary(role_name, collection_name, argspec)` to require a `meta` argument plus an exact `description: 'UNDOCUMENTED'` field.
- Why this challenges the claim: These failures are about exact helper signatures and no-color marker strings, not the broad user-visible doc behavior. The verifier constrains implementation details that the task text does not name.

Detailed read:

- What the task asks: improve visual formatting and structure of `ansible-doc` output. The problem statement describes flat, hard-to-scan output where required options, nested suboptions, links, and section headers are not visually distinguished. It also asks role summaries/docs to tolerate missing or malformed metadata/argspec, doc fragments to support comma-separated strings, and plugin names to use resolved FQCNs where available.
- Requirements: produce concise readable default terminal output; render visual hierarchy in ANSI terminals while keeping stable no-color substitutions; keep consistent section order; clearly mark required options; wrap nested options/return values without mid-word breaks; group role listing entries; include role summary metadata when available; gracefully warn/continue on missing or invalid role metadata; normalize comma-separated doc fragments; and preserve stable output semantics. The interface field says no new interfaces are introduced.
- What the agent did: the trajectory shows a broad attempt to solve the CLI-output task, not a targeted hidden-test patch. It added styled headers across doc sections, changed role listing/doc handling to skip bad roles with warnings, split comma-separated documentation fragments, improved wrapping, added role summary fallbacks, and adjusted loader fallback behavior. It also ran local unit/integration-style checks and reported that its available tests and fixture comparisons passed.
- What was tested: the verifier ran 20 required tests: 17 P2P/regression tests and three true F2P tests. The agent passed all 17 P2P tests and failed all three F2P tests: ``test_ttyify[I(italic)-`italic`]``, `test_rolemixin__build_summary`, and `test_rolemixin__build_summary_empty_argspec`.
- Why the agent failed: the hidden/gold tests required exact private-helper behavior. They directly call `_build_summary(role_name, collection_name, meta, argspec)` and expect a returned summary containing top-level `description: 'UNDOCUMENTED'` and exact `entry_points` shape. The agent only partially handled missing descriptions and did not infer the private helper signature/return-shape contract. Separately, it missed the exact no-color italic substitution from `I(italic)` to backtick-wrapped `italic`.
- Fairness read: the failing expectations are directionally related to the requirements, especially stable no-color output and missing role metadata placeholders. The suitability issue is the specificity: a reasonable implementation can substantially improve `ansible-doc` behavior and pass most verifier checks while failing because it did not infer an unstated private API signature and exact string token.

## Mode 2: Rejected Tasks That Look Too Trivial

Our evaluator rejects tasks when the core work is mechanical, obvious, or too thinly verified. These examples challenge the broad claim that the benchmark is consistently composed of challenging industrial tasks.

For this pass I used additional heuristics to search for examples: only successful rejected tasks with `alignment_verdict=ok`, at least one true F2P test, small source/test diffs, and short top-level agent trajectories. That avoids relying only on the evaluator label.

### Candidate Search: Shortest Total Diff

| task_id | repo | source_diff | test_diff | total_diff | agent_turns | edit_calls | bash_calls | required | reject_pattern |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| qutebrowser-fea33d60 | qutebrowser | 22 | 3 | 25 | 28 | 3 | 4 | 20/20 | AL1_mechanical_or_constructed |
| qutebrowser-0833b5f6 | qutebrowser | 30 | 2 | 32 | 10 | 1 | 1 | 10/10 | BT1_trivial_core_logic |
| ansible-12734fa2 | ansible | 26 | 12 | 38 | 28 | 6 | 3 | 5/5 | BT1_trivial_core_logic |
| ansible-5c225dc0 | ansible | 38 | 4 | 42 | 25 | 7 | 2 | 8/8 | AL1_mechanical_or_constructed |
| ansible-0ea40e09 | ansible | 32 | 11 | 43 | 13 | 1 | 2 | 16/16 | BT1_trivial_core_logic |
| qutebrowser-8d05f028 | qutebrowser | 31 | 12 | 43 | 57 | 7 | 21 | 163/163 | BT1_trivial_core_logic |
| qutebrowser-96b99780 | qutebrowser | 24 | 23 | 47 | 23 | 1 | 4 | 178/178 | AL1_mechanical_or_constructed |
| qutebrowser-996487c4 | qutebrowser | 43 | 5 | 48 | 38 | 2 | 7 | 1015/1015 | AL1_mechanical_or_constructed |
| openlibrary-b4f7c185 | openlibrary | 41 | 8 | 49 | 46 | 7 | 3 | 33/33 | BT1_trivial_core_logic |
| openlibrary-6afdb09d | openlibrary | 30 | 22 | 52 | 25 | 4 | 6 | 6/6 | AL1_mechanical_or_constructed |
| ansible-106909db | ansible | 26 | 26 | 52 | 32 | 4 | 4 | 6/6 | BT1_trivial_core_logic |
| qutebrowser-50efac08 | qutebrowser | 38 | 14 | 52 | 44 | 5 | 11 | 37/37 | BT1_trivial_core_logic |

### Candidate Search: Fewest Agent Turns

| task_id | repo | source_diff | test_diff | total_diff | agent_turns | edit_calls | bash_calls | required | reject_pattern |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| qutebrowser-0833b5f6 | qutebrowser | 30 | 2 | 32 | 10 | 1 | 1 | 10/10 | BT1_trivial_core_logic |
| ansible-e0c91af4 | ansible | 78 | 4 | 82 | 10 | 2 | 1 | 4/4 | BT1_trivial_core_logic |
| ansible-0ea40e09 | ansible | 32 | 11 | 43 | 13 | 1 | 2 | 16/16 | BT1_trivial_core_logic |
| openlibrary-4a5d2a7d | openlibrary | 92 | 31 | 123 | 15 | 2 | 2 | 9/9 | BT1_trivial_core_logic |
| ansible-185d4103 | ansible | 70 | 14 | 84 | 19 | 1 | 2 | 29/29 | BT1_trivial_core_logic |
| openlibrary-72321288 | openlibrary | 51 | 14 | 65 | 21 | 1 | 3 | 1/1 | BT1_trivial_core_logic |
| openlibrary-0d13e6b4 | openlibrary | 75 | 24 | 99 | 21 | 2 | 4 | 10/10 | AL1_mechanical_or_constructed |
| openlibrary-de6ae105 | openlibrary | 90 | 56 | 146 | 21 | 1 | 1 | 2/2 | BT1_trivial_core_logic |
| openlibrary-c506c1b0 | openlibrary | 288 | 22 | 310 | 21 | 4 | 4 | 6/6 | BT1_trivial_core_logic |
| openlibrary-e010b2a1 | openlibrary | 120 | 1 | 121 | 22 | 3 | 3 | 2/2 | BT1_trivial_core_logic |
| openlibrary-92db3454 | openlibrary | 703 | 21 | 724 | 22 | 2 | 5 | 3/3 | hard_filter:no_behavioral_tests |
| qutebrowser-96b99780 | qutebrowser | 24 | 23 | 47 | 23 | 1 | 4 | 178/178 | AL1_mechanical_or_constructed |

### Selected Examples

These selected examples cover the shortest-total-diff and fewest-agent-turn rankings while still having clean raw trajectories.

### `qutebrowser-0833b5f6` (qutebrowser)

- Result: agent passed; required tests 10/10; true F2P tests 1.
- Heuristics: source diff 30 lines; test diff 2 lines; top-level agent turns 10; edit calls 1; bash calls 1.
- Category: BT1 one-line signal migration.
- Raw artifacts: `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_qutebrowser__qutebrowse__QT4ByAB/agent/trajectory.json`, `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_qutebrowser__qutebrowse__QT4ByAB/verifier/output.json`, `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_qutebrowser__qutebrowse__QT4ByAB/verifier/test-stdout.txt`.
- Task contract: In WebKit `NetworkReply`, replace the deprecated initial error signal emission with the modern `errorOccurred` signal.
- Agent trajectory evidence: The agent grepped for network reply code, read `qutebrowser/browser/webkit/network/networkreply.py`, and in the sixth agent step stated: change `self.error.emit(error)` to `self.errorOccurred.emit(error)`. It then made that one edit and ran the WebKit network reply tests.
- Verifier evidence: The verifier passed 10/10 required tests. The test patch is a one-line expectation update from `reply.error` to `reply.errorOccurred`.
- Why this challenges the claim: This is the kind of deprecation rename a model can solve by grep plus one local edit. It is a weak example of a challenging industrial task.

### `ansible-0ea40e09` (ansible)

- Result: agent passed; required tests 16/16; true F2P tests 1.
- Heuristics: source diff 32 lines; test diff 11 lines; top-level agent turns 13; edit calls 1; bash calls 2.
- Category: BT1 standard Python dunder methods.
- Raw artifacts: `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_ansible__ansible-0ea40e__8Ldvj4f/agent/trajectory.json`, `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_ansible__ansible-0ea40e__8Ldvj4f/verifier/output.json`, `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_ansible__ansible-0ea40e__8Ldvj4f/verifier/test-stdout.txt`.
- Task contract: `VarsWithSources` must interoperate with mappings for `|`, reverse `|`, and `|=`, and `combine_vars` must work in the replace path when one operand is `VarsWithSources`.
- Agent trajectory evidence: The agent immediately identified the missing `__or__`, `__ror__`, and `__ior__` methods in `lib/ansible/vars/manager.py`, wrote a short reproduction script showing `dict | VarsWithSources` fails, added the three dunder methods, and reran the reproduction.
- Verifier evidence: The verifier passed 16/16 required tests. The test patch adds `VarsWithSources()` rows to existing `combine_vars` parameterized cases.
- Why this challenges the claim: The task reduces to implementing standard Python mapping union methods. The trajectory is short and direct, with no broad system design or ambiguous debugging.

### `qutebrowser-fea33d60` (qutebrowser)

- Result: agent passed; required tests 20/20; true F2P tests 14.
- Heuristics: source diff 22 lines; test diff 3 lines; top-level agent turns 28; edit calls 3; bash calls 4.
- Category: AL1 parameter passthrough.
- Raw artifacts: `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_qutebrowser__qutebrowse__QytJTfz/agent/trajectory.json`, `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_qutebrowser__qutebrowse__QytJTfz/verifier/output.json`, `docs/analyses/data/swebench-pro/runs/combined_non_error/instance_qutebrowser__qutebrowse__QytJTfz/verifier/test-stdout.txt`.
- Task contract: For the MIME suffix workaround, call `version_check("6.2.3", compiled=False)` and `version_check("6.7.0", compiled=False)` so the decision uses only the runtime Qt version.
- Agent trajectory evidence: The trajectory identifies the key change immediately: add `compiled=False` to both `version_check` calls in `qutebrowser/browser/webengine/webview.py`. The agent also clarifies the existing docstring and adjusts a local mock signature for its own test run.
- Verifier evidence: The verifier passed 20/20 required tests. The F2P test patch asserts the mocked `version()` function is called with `compiled is False`.
- Why this challenges the claim: The tested behavior is a direct parameter passthrough named verbatim in the task. It is mechanical, localized, and has little room for meaningful strategy divergence.

## Interpretation

- The narrow-test mode is a verifier suitability concern: it does not require the task to be easy or hard; it means the verifier may reject reasonable implementations because the tests encode unstated specifics.
- The trivial-reject mode is a task-selection concern: many rejected tasks fall into `BT1` or `AL1`, and in our run rejected tasks pass substantially more often than accepted tasks.
- These results do not invalidate the full dataset. They show that a meaningful subset of the evaluated public tasks may not satisfy the paper's stated suitability criteria.

## Limitations

- Scope is the 263 tasks in our evaluated run, not all SWE-bench Pro tasks.
- `accept`/`reject` and alignment verdicts are model-based pipeline judgments, so case evidence matters more than labels alone.
- Pass rate depends on the agent/scaffold; use it as supporting evidence for triviality, not as the only criterion.
- Older columns named `agent_f2p_tests_*` in some CSVs are verifier required-test counts, not true F2P counts.
