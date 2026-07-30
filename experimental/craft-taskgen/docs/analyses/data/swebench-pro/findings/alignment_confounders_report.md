# Alignment-Judge Confounder Analysis

This report asks whether SWE-bench Pro metadata/diff/test-size fields are associated with alignment verdicts.

## What The Aligner Sees

- For normal generated tasks, the alignment prompt sees only `instruction.md`, reference test bodies, and PR diff.
- For this imported SWE-bench run, `swebench_alignment.py` can append `source_metadata.requirements` and `source_metadata.interface` to the problem statement. The stored leakage evidence confirms that happened for at least these labels, because leaked reasons quote `File: ...`, `Function: ...`, and explicit method signatures from metadata.
- The aligner does not see agent trajectories or pass/fail outcomes.

## Verdict Mix

| verdict | n | share |
| --- | --- | --- |
| leaked | 70 | 26.6% |
| narrow_tests | 40 | 15.2% |
| ok | 152 | 57.8% |
| skipped | 1 | 0.4% |

## Correlation With `leaked` Verdict

| metric | corr_with_leaked |
| --- | --- |
| test_patch_changed | 0.150 |
| problem_statement_words | 0.142 |
| test_patch_files | 0.142 |
| requirements_words | 0.106 |
| requirements_bullet_count | 0.091 |
| required_total | 0.087 |
| patch_changed | 0.083 |
| fail_to_pass_total | 0.068 |
| pass_to_pass_total | 0.061 |
| interface_words | 0.033 |
| patch_files | 0.030 |
| issue_specificity_count | 0.018 |
| issue_categories_count | 0.014 |
| selected_test_files_count | 0.005 |

## Correlation With `narrow_tests` Verdict

| metric | corr_with_narrow_tests |
| --- | --- |
| selected_test_files_count | 0.107 |
| fail_to_pass_total | 0.097 |
| problem_statement_words | 0.092 |
| interface_words | -0.084 |
| test_patch_changed | 0.041 |
| pass_to_pass_total | -0.040 |
| issue_categories_count | 0.033 |
| patch_files | -0.030 |
| patch_changed | 0.029 |
| issue_specificity_count | -0.028 |
| required_total | 0.025 |
| requirements_bullet_count | -0.025 |
| test_patch_files | 0.023 |
| requirements_words | -0.020 |

## Bucketed Verdict Mix


### requirements_words_bucket

| requirements_words_bucket | n | leaked | narrow_tests | ok |
| --- | --- | --- | --- | --- |
| 01_0-100 | 38 | 4/38 (10.5%) | 3/38 (7.9%) | 31/38 (81.6%) |
| 02_101-250 | 150 | 40/150 (26.7%) | 26/150 (17.3%) | 84/150 (56.0%) |
| 03_251-500 | 73 | 26/73 (35.6%) | 11/73 (15.1%) | 35/73 (47.9%) |
| 04_501+ | 2 | 0/2 (0.0%) | 0/2 (0.0%) | 2/2 (100.0%) |

### test_patch_changed_bucket

| test_patch_changed_bucket | n | leaked | narrow_tests | ok |
| --- | --- | --- | --- | --- |
| 01_0-20 | 68 | 10/68 (14.7%) | 13/68 (19.1%) | 44/68 (64.7%) |
| 02_21-100 | 116 | 29/116 (25.0%) | 14/116 (12.1%) | 73/116 (62.9%) |
| 03_101-250 | 49 | 19/49 (38.8%) | 8/49 (16.3%) | 22/49 (44.9%) |
| 04_251+ | 30 | 12/30 (40.0%) | 5/30 (16.7%) | 13/30 (43.3%) |

### patch_changed_bucket

| patch_changed_bucket | n | leaked | narrow_tests | ok |
| --- | --- | --- | --- | --- |
| 01_0-50 | 84 | 20/84 (23.8%) | 9/84 (10.7%) | 55/84 (65.5%) |
| 02_51-200 | 123 | 33/123 (26.8%) | 22/123 (17.9%) | 67/123 (54.5%) |
| 03_201-500 | 38 | 10/38 (26.3%) | 6/38 (15.8%) | 22/38 (57.9%) |
| 04_501+ | 18 | 7/18 (38.9%) | 3/18 (16.7%) | 8/18 (44.4%) |

### f2p_bucket

| f2p_bucket | n | leaked | narrow_tests | ok |
| --- | --- | --- | --- | --- |
| 01_1-2 | 94 | 17/94 (18.1%) | 13/94 (13.8%) | 63/94 (67.0%) |
| 02_3-5 | 75 | 23/75 (30.7%) | 13/75 (17.3%) | 39/75 (52.0%) |
| 03_6-10 | 43 | 10/43 (23.3%) | 6/43 (14.0%) | 27/43 (62.8%) |
| 04_11-25 | 31 | 12/31 (38.7%) | 5/31 (16.1%) | 14/31 (45.2%) |
| 05_26+ | 20 | 8/20 (40.0%) | 3/20 (15.0%) | 9/20 (45.0%) |

### selected_test_files_bucket

| selected_test_files_bucket | n | leaked | narrow_tests | ok |
| --- | --- | --- | --- | --- |
| 01_1 | 180 | 45/180 (25.0%) | 30/180 (16.7%) | 104/180 (57.8%) |
| 02_2 | 56 | 16/56 (28.6%) | 8/56 (14.3%) | 32/56 (57.1%) |
| 03_3-5 | 20 | 7/20 (35.0%) | 0/20 (0.0%) | 13/20 (65.0%) |
| 04_6+ | 7 | 2/7 (28.6%) | 2/7 (28.6%) | 3/7 (42.9%) |

### patch_files_bucket

| patch_files_bucket | n | leaked | narrow_tests | ok |
| --- | --- | --- | --- | --- |
| 01_1 | 50 | 13/50 (26.0%) | 8/50 (16.0%) | 28/50 (56.0%) |
| 02_2-3 | 109 | 24/109 (22.0%) | 19/109 (17.4%) | 66/109 (60.6%) |
| 03_4-10 | 99 | 33/99 (33.3%) | 13/99 (13.1%) | 53/99 (53.5%) |
| 04_11+ | 5 | 0/5 (0.0%) | 0/5 (0.0%) | 5/5 (100.0%) |

## Read

- The aligner is directly sensitive to metadata content when `requirements`/`interface` are included, because those strings become part of the `<instruction>` block it audits for leakage.
- The strongest associations with `leaked` are larger test patches, longer problem statements, longer requirements, and larger true F2P/required-test sets. These are weak-to-moderate correlations, not determinative labels.
- Requirements length has a clear bucket effect: leaked share rises from 10.5% in `0-100` words to 35.6% in `251-500` words.
- Test patch size has a similar effect: leaked share rises from 14.7% in `0-20` changed test lines to about 40% above 100 changed test lines.
- Meaningful interface presence itself is not the main driver: earlier interface analysis found leaked share 25.5% for meaningful interface vs 28.0% for placeholder.
- Mechanism: big/long metadata tends to enumerate APIs, files, private helpers, and exact behaviors. The prompt is explicitly looking for those as leakage, so the aligner can be confounded by metadata verbosity and API extraction style.
