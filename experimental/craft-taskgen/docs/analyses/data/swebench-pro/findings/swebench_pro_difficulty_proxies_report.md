# SWE-bench Pro Difficulty Proxy Analysis

Enriched CSV: `docs/analyses/data/swebench-pro/findings/swebench_pro_difficulty_proxies_enriched.csv`

This joins the 263 selected runs to fields available directly in `swebench_pro.jsonl`.

## Available Proxy Fields

- `fail_to_pass`: true F2P test count.
- `pass_to_pass`: regression/P2P test count.
- `selected_test_files_to_run`: breadth of test files invoked.
- `patch` and `test_patch`: source/test diff size and file count.
- `requirements`, `interface`, `problem_statement`: instruction/metadata length and interface presence.
- `issue_specificity` and `issue_categories`: human/task labels that can approximate bug type and domain breadth.

## Alignment-Level Averages

| alignment_verdict | n | passed | pass_rate | avg_fail_to_pass_total | avg_pass_to_pass_total | avg_required_total | avg_selected_test_files_count | avg_patch_files | avg_patch_changed | avg_test_patch_files | avg_test_patch_changed | avg_requirements_words | avg_issue_categories_count |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| leaked | 70 | 37 | 52.9% | 38.8 | 78.5 | 117.3 | 1.8 | 3.6 | 176.0 | 3.7 | 148.8 | 224.9 | 2.5 |
| narrow_tests | 40 | 19 | 47.5% | 54.2 | 43.8 | 98.0 | 2.5 | 3.3 | 161.4 | 2.9 | 124.5 | 200.8 | 2.5 |
| ok | 152 | 95 | 62.5% | 9.1 | 57.0 | 66.1 | 1.5 | 3.5 | 130.1 | 2.1 | 87.4 | 197.9 | 2.5 |
| skipped | 1 | 0 | 0.0% | 2.0 | 55.0 | 57.0 | 1.0 | 1.0 | 62.0 | 2.0 | 14.0 | 275.0 | 2.0 |

## Scalar Correlations With Agent Success

Pearson correlation over the 263 selected runs. Negative means larger values are associated with lower pass rate.

| metric | corr_with_success | direction |
| --- | --- | --- |
| requirements_words | -0.271 | harder_when_larger |
| test_patch_files | -0.183 | harder_when_larger |
| patch_changed | -0.161 | harder_when_larger |
| test_patch_changed | -0.144 | harder_when_larger |
| fail_to_pass_total | -0.105 | harder_when_larger |
| interface_words | -0.103 | harder_when_larger |
| problem_statement_words | -0.097 | harder_when_larger |
| required_total | -0.035 | harder_when_larger |
| issue_specificity_count | -0.026 | harder_when_larger |
| requirements_bullet_count | 0.001 | easier_when_larger |
| selected_test_files_count | 0.021 | easier_when_larger |
| patch_files | 0.021 | easier_when_larger |
| issue_categories_count | 0.023 | easier_when_larger |
| pass_to_pass_total | 0.035 | easier_when_larger |

## By True F2P Count

| f2p_bucket | n | passed | pass_rate | avg_required_total | avg_f2p_total |
| --- | --- | --- | --- | --- | --- |
| 01_1-2 | 94 | 59 | 62.8% | 46.9 | 1.4 |
| 02_3-5 | 75 | 40 | 53.3% | 55.5 | 3.9 |
| 03_6-10 | 43 | 25 | 58.1% | 74.8 | 7.7 |
| 04_11-25 | 31 | 16 | 51.6% | 76.0 | 15.0 |
| 05_26+ | 20 | 11 | 55.0% | 404.4 | 252.4 |

## By P2P Count

| p2p_bucket | n | passed | pass_rate | avg_required_total | avg_f2p_total |
| --- | --- | --- | --- | --- | --- |
| 01_0-10 | 127 | 78 | 61.4% | 35.2 | 32.7 |
| 02_11-50 | 70 | 35 | 50.0% | 35.5 | 8.3 |
| 03_51-100 | 34 | 20 | 58.8% | 67.9 | 4.1 |
| 04_101+ | 32 | 18 | 56.2% | 405.2 | 43.8 |

## By Selected Test File Count

| selected_test_files_bucket | n | passed | pass_rate | avg_required_total | avg_f2p_total |
| --- | --- | --- | --- | --- | --- |
| 01_1 | 180 | 105 | 58.3% | 72.3 | 14.3 |
| 02_2 | 56 | 31 | 55.4% | 102.8 | 48.2 |
| 03_3-5 | 20 | 12 | 60.0% | 88.0 | 6.8 |
| 04_6+ | 7 | 3 | 42.9% | 242.1 | 122.9 |

## By Source Patch File Count

| patch_files_bucket | n | passed | pass_rate | avg_required_total | avg_f2p_total |
| --- | --- | --- | --- | --- | --- |
| 01_1 | 50 | 27 | 54.0% | 127.5 | 43.2 |
| 02_2-3 | 109 | 67 | 61.5% | 66.6 | 7.2 |
| 03_4-10 | 99 | 53 | 53.5% | 85.8 | 33.3 |
| 04_11+ | 5 | 4 | 80.0% | 21.0 | 4.0 |

## By Source Patch Changed Lines

| patch_changed_bucket | n | passed | pass_rate | avg_required_total | avg_f2p_total |
| --- | --- | --- | --- | --- | --- |
| 01_0-50 | 84 | 59 | 70.2% | 86.0 | 5.4 |
| 02_51-200 | 123 | 68 | 55.3% | 109.0 | 43.6 |
| 03_201-500 | 38 | 18 | 47.4% | 25.9 | 6.2 |
| 04_501+ | 18 | 6 | 33.3% | 34.2 | 11.9 |

## By Test Patch Changed Lines

| test_patch_changed_bucket | n | passed | pass_rate | avg_required_total | avg_f2p_total |
| --- | --- | --- | --- | --- | --- |
| 01_0-20 | 68 | 49 | 72.1% | 107.8 | 4.1 |
| 02_21-100 | 116 | 69 | 59.5% | 86.9 | 29.6 |
| 03_101-250 | 49 | 20 | 40.8% | 31.6 | 7.7 |
| 04_251+ | 30 | 13 | 43.3% | 109.1 | 72.4 |

## By Requirements Word Count

| requirements_words_bucket | n | passed | pass_rate | avg_required_total | avg_f2p_total |
| --- | --- | --- | --- | --- | --- |
| 01_0-100 | 38 | 26 | 68.4% | 60.1 | 2.3 |
| 02_101-250 | 150 | 95 | 63.3% | 82.5 | 19.7 |
| 03_251-500 | 73 | 30 | 41.1% | 102.4 | 43.8 |
| 04_501+ | 2 | 0 | 0.0% | 43.5 | 12.5 |

## Issue Specificity Labels

| issue_specificity | n | passed | pass_rate |
| --- | --- | --- | --- |
| code_quality_enh | 77 | 43 | 55.8% |
| core_feat | 74 | 43 | 58.1% |
| refactoring_enh | 57 | 36 | 63.2% |
| edge_case_bug | 46 | 27 | 58.7% |
| integration_feat | 37 | 21 | 56.8% |
| compatibility_bug | 33 | 21 | 63.6% |
| major_bug | 32 | 13 | 40.6% |
| data_bug | 30 | 14 | 46.7% |
| api_feat | 25 | 18 | 72.0% |
| minor_bug | 24 | 17 | 70.8% |
| ui_ux_feat | 24 | 16 | 66.7% |
| customization_feat | 18 | 12 | 66.7% |
| integration_bug | 18 | 5 | 27.8% |
| regression_bug | 13 | 5 | 38.5% |
| technical_debt_enh | 13 | 9 | 69.2% |
| performance_enh | 12 | 6 | 50.0% |
| ui_ux_bug | 10 | 9 | 90.0% |
| performance_feat | 9 | 4 | 44.4% |
| performance_bug | 8 | 5 | 62.5% |
| dev_ops_enh | 7 | 2 | 28.6% |

## Issue Category Labels

| issue_categories | n | passed | pass_rate |
| --- | --- | --- | --- |
| back_end_knowledge | 228 | 131 | 57.5% |
| api_knowledge | 78 | 49 | 62.8% |
| devops_knowledge | 67 | 33 | 49.3% |
| desktop_knowledge | 51 | 34 | 66.7% |
| infrastructure_knowledge | 46 | 21 | 45.7% |
| ui_ux_knowledge | 37 | 28 | 75.7% |
| web_knowledge | 31 | 21 | 67.7% |
| database_knowledge | 28 | 14 | 50.0% |
| performance_knowledge | 27 | 16 | 59.3% |
| networking_knowledge | 15 | 7 | 46.7% |
| security_knowledge | 14 | 7 | 50.0% |
| front_end_knowledge | 12 | 7 | 58.3% |
| full_stack_knowledge | 8 | 5 | 62.5% |
| authentication_authorization_knowledge | 4 | 1 | 25.0% |
| ds_knowledge | 3 | 2 | 66.7% |
| accessibility_knowledge | 1 | 0 | 0.0% |
| cloud_knowledge | 1 | 1 | 100.0% |
| ml_ai_knowledge | 1 | 0 | 0.0% |

## Initial Read

- In this selected 263-task slice, the clearest scalar proxy is requirements length: more requirements words correlate with lower pass rate (`corr=-0.271`), and the 251-500 word bucket passes at 41.1%.
- Patch/test-patch size also behaves like a difficulty proxy: source patches over 500 changed lines pass at 33.3%, and test patches over 100 changed lines pass around 41-43%.
- True F2P count is directionally useful but weaker than expected here (`corr=-0.105`) and not monotonic across buckets.
- P2P count and selected test-file count are not strong scalar proxies by themselves; they mix broad regression suites with relatively easy compatibility checks.
- Issue label counts and categories are better as stratification variables than scalar difficulty scores.
- Interface length has a small negative association with success (`corr=-0.103`), which is consistent with API-heavy tasks being brittle, but it is not strong enough alone.
