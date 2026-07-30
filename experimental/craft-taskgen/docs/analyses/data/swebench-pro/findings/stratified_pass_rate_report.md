# Stratified Pass-Rate Report

Rows analyzed: 263

## Key Observations

- Overall, `leaked` trails `ok` by 9.6 percentage points (37/70 vs 95/152).
- The gap is highly confounded by eval verdict, repo mix, and F2P test-count bucket.
- In matched cells with the same repo, eval verdict, and F2P bucket, leaked tasks pass at 54.4% versus an expected 53.5% if they followed the OK-cell rates.
- That matched comparison suggests the raw leaked-vs-ok gap is mostly compositional in this run.
- The worst leaked failures are concentrated in Ansible zero-pass cases; see the zero-pass deep dive.

## Overall By Alignment

| alignment_verdict | passed | n | pass_rate |
| --- | --- | --- | --- |
| leaked | 37 | 70 | 52.9% |
| narrow_tests | 19 | 40 | 47.5% |
| ok | 95 | 152 | 62.5% |
| skipped | 0 | 1 | 0.0% |

## Alignment x Eval Verdict

| alignment_verdict | new_eval_verdict | passed | n | pass_rate |
| --- | --- | --- | --- | --- |
| leaked | accept | 11 | 31 | 35.5% |
| leaked | reject | 26 | 39 | 66.7% |
| narrow_tests | accept | 9 | 21 | 42.9% |
| narrow_tests | reject | 10 | 19 | 52.6% |
| ok | accept | 19 | 43 | 44.2% |
| ok | reject | 76 | 109 | 69.7% |
| skipped | accept | 0 | 1 | 0.0% |

## Alignment x Repo

| alignment_verdict | repo | passed | n | pass_rate |
| --- | --- | --- | --- | --- |
| leaked | ansible | 14 | 31 | 45.2% |
| leaked | openlibrary | 5 | 12 | 41.7% |
| leaked | qutebrowser | 18 | 27 | 66.7% |
| narrow_tests | ansible | 5 | 15 | 33.3% |
| narrow_tests | openlibrary | 8 | 15 | 53.3% |
| narrow_tests | qutebrowser | 6 | 10 | 60.0% |
| ok | ansible | 29 | 50 | 58.0% |
| ok | openlibrary | 40 | 61 | 65.6% |
| ok | qutebrowser | 26 | 41 | 63.4% |
| skipped | openlibrary | 0 | 1 | 0.0% |

## Alignment x F2P Total Bucket

| alignment_verdict | f2p_total_bucket | passed | n | pass_rate |
| --- | --- | --- | --- | --- |
| leaked | 01_1-5 | 2 | 7 | 28.6% |
| leaked | 02_6-20 | 12 | 22 | 54.5% |
| leaked | 03_21-100 | 14 | 27 | 51.9% |
| leaked | 04_101+ | 9 | 14 | 64.3% |
| narrow_tests | 01_1-5 | 4 | 7 | 57.1% |
| narrow_tests | 02_6-20 | 5 | 10 | 50.0% |
| narrow_tests | 03_21-100 | 9 | 17 | 52.9% |
| narrow_tests | 04_101+ | 1 | 6 | 16.7% |
| ok | 01_1-5 | 17 | 28 | 60.7% |
| ok | 02_6-20 | 38 | 54 | 70.4% |
| ok | 03_21-100 | 29 | 50 | 58.0% |
| ok | 04_101+ | 11 | 20 | 55.0% |
| skipped | 03_21-100 | 0 | 1 | 0.0% |

## Failure Shape By Alignment

| alignment_verdict | f2p_result_bucket | passed | n | pass_rate |
| --- | --- | --- | --- | --- |
| leaked | all_passed | 37 | 37 | 100.0% |
| leaked | near_miss | 0 | 20 | 0.0% |
| leaked | partial | 0 | 9 | 0.0% |
| leaked | zero_passed | 0 | 4 | 0.0% |
| narrow_tests | all_passed | 19 | 19 | 100.0% |
| narrow_tests | near_miss | 0 | 10 | 0.0% |
| narrow_tests | partial | 0 | 9 | 0.0% |
| narrow_tests | zero_passed | 0 | 2 | 0.0% |
| ok | all_passed | 95 | 95 | 100.0% |
| ok | near_miss | 0 | 37 | 0.0% |
| ok | partial | 0 | 13 | 0.0% |
| ok | zero_passed | 0 | 7 | 0.0% |
| skipped | near_miss | 0 | 1 | 0.0% |

## Matched OK vs Leaked

Matched cells use the same `repo`, `new_eval_verdict`, and `f2p_total_bucket`.

| matched_leaked | matched_leaked_rate | expected_leaked_passes_at_ok_rate | expected_leaked_rate_at_ok_rate |
| --- | --- | --- | --- |
| 37/68 | 54.4% | 36.4 | 53.5% |

### Matched Cells

| repo | new_eval_verdict | f2p_total_bucket | ok | ok_rate | leaked | leaked_rate | gap_pp |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ansible | accept | 01_1-5 | 0/1 | 0.0% | 0/2 | 0.0% | 0.0 |
| ansible | accept | 02_6-20 | 2/6 | 33.3% | 1/2 | 50.0% | 16.7 |
| ansible | accept | 03_21-100 | 0/4 | 0.0% | 1/7 | 14.3% | 14.3 |
| ansible | reject | 01_1-5 | 9/14 | 64.3% | 0/1 | 0.0% | -64.3 |
| ansible | reject | 02_6-20 | 9/12 | 75.0% | 4/10 | 40.0% | -35.0 |
| ansible | reject | 03_21-100 | 9/12 | 75.0% | 7/7 | 100.0% | 25.0 |
| ansible | reject | 04_101+ | 0/1 | 0.0% | 1/1 | 100.0% | 100.0 |
| openlibrary | accept | 02_6-20 | 6/11 | 54.5% | 0/2 | 0.0% | -54.5 |
| openlibrary | accept | 03_21-100 | 5/8 | 62.5% | 1/3 | 33.3% | -29.2 |
| openlibrary | reject | 01_1-5 | 6/10 | 60.0% | 2/3 | 66.7% | 6.7 |
| openlibrary | reject | 02_6-20 | 15/18 | 83.3% | 2/3 | 66.7% | -16.7 |
| openlibrary | reject | 03_21-100 | 7/11 | 63.6% | 0/1 | 0.0% | -63.6 |
| qutebrowser | accept | 02_6-20 | 1/1 | 100.0% | 2/2 | 100.0% | 0.0 |
| qutebrowser | accept | 03_21-100 | 2/5 | 40.0% | 2/4 | 50.0% | 10.0 |
| qutebrowser | accept | 04_101+ | 1/3 | 33.3% | 4/8 | 50.0% | 16.7 |
| qutebrowser | reject | 02_6-20 | 5/6 | 83.3% | 3/3 | 100.0% | 16.7 |
| qutebrowser | reject | 03_21-100 | 6/10 | 60.0% | 3/5 | 60.0% | 0.0 |
| qutebrowser | reject | 04_101+ | 10/15 | 66.7% | 4/4 | 100.0% | 33.3 |

## Full Stratification: Alignment x Eval x Repo x F2P Bucket

| alignment_verdict | new_eval_verdict | repo | f2p_total_bucket | passed | n | pass_rate |
| --- | --- | --- | --- | --- | --- | --- |
| leaked | accept | ansible | 01_1-5 | 0 | 2 | 0.0% |
| leaked | accept | ansible | 02_6-20 | 1 | 2 | 50.0% |
| leaked | accept | ansible | 03_21-100 | 1 | 7 | 14.3% |
| leaked | accept | ansible | 04_101+ | 0 | 1 | 0.0% |
| leaked | accept | openlibrary | 02_6-20 | 0 | 2 | 0.0% |
| leaked | accept | openlibrary | 03_21-100 | 1 | 3 | 33.3% |
| leaked | accept | qutebrowser | 02_6-20 | 2 | 2 | 100.0% |
| leaked | accept | qutebrowser | 03_21-100 | 2 | 4 | 50.0% |
| leaked | accept | qutebrowser | 04_101+ | 4 | 8 | 50.0% |
| leaked | reject | ansible | 01_1-5 | 0 | 1 | 0.0% |
| leaked | reject | ansible | 02_6-20 | 4 | 10 | 40.0% |
| leaked | reject | ansible | 03_21-100 | 7 | 7 | 100.0% |
| leaked | reject | ansible | 04_101+ | 1 | 1 | 100.0% |
| leaked | reject | openlibrary | 01_1-5 | 2 | 3 | 66.7% |
| leaked | reject | openlibrary | 02_6-20 | 2 | 3 | 66.7% |
| leaked | reject | openlibrary | 03_21-100 | 0 | 1 | 0.0% |
| leaked | reject | qutebrowser | 01_1-5 | 0 | 1 | 0.0% |
| leaked | reject | qutebrowser | 02_6-20 | 3 | 3 | 100.0% |
| leaked | reject | qutebrowser | 03_21-100 | 3 | 5 | 60.0% |
| leaked | reject | qutebrowser | 04_101+ | 4 | 4 | 100.0% |
| narrow_tests | accept | ansible | 01_1-5 | 1 | 1 | 100.0% |
| narrow_tests | accept | ansible | 02_6-20 | 1 | 3 | 33.3% |
| narrow_tests | accept | ansible | 03_21-100 | 1 | 3 | 33.3% |
| narrow_tests | accept | ansible | 04_101+ | 0 | 1 | 0.0% |
| narrow_tests | accept | openlibrary | 01_1-5 | 0 | 2 | 0.0% |
| narrow_tests | accept | openlibrary | 02_6-20 | 2 | 4 | 50.0% |
| narrow_tests | accept | openlibrary | 03_21-100 | 2 | 4 | 50.0% |
| narrow_tests | accept | qutebrowser | 03_21-100 | 1 | 1 | 100.0% |
| narrow_tests | accept | qutebrowser | 04_101+ | 1 | 2 | 50.0% |
| narrow_tests | reject | ansible | 01_1-5 | 0 | 1 | 0.0% |
| narrow_tests | reject | ansible | 02_6-20 | 0 | 1 | 0.0% |
| narrow_tests | reject | ansible | 03_21-100 | 2 | 5 | 40.0% |
| narrow_tests | reject | openlibrary | 01_1-5 | 2 | 2 | 100.0% |
| narrow_tests | reject | openlibrary | 03_21-100 | 2 | 2 | 100.0% |
| narrow_tests | reject | openlibrary | 04_101+ | 0 | 1 | 0.0% |
| narrow_tests | reject | qutebrowser | 01_1-5 | 1 | 1 | 100.0% |
| narrow_tests | reject | qutebrowser | 02_6-20 | 2 | 2 | 100.0% |
| narrow_tests | reject | qutebrowser | 03_21-100 | 1 | 2 | 50.0% |
| narrow_tests | reject | qutebrowser | 04_101+ | 0 | 2 | 0.0% |
| ok | accept | ansible | 01_1-5 | 0 | 1 | 0.0% |
| ok | accept | ansible | 02_6-20 | 2 | 6 | 33.3% |
| ok | accept | ansible | 03_21-100 | 0 | 4 | 0.0% |
| ok | accept | openlibrary | 01_1-5 | 1 | 2 | 50.0% |
| ok | accept | openlibrary | 02_6-20 | 6 | 11 | 54.5% |
| ok | accept | openlibrary | 03_21-100 | 5 | 8 | 62.5% |
| ok | accept | openlibrary | 04_101+ | 0 | 1 | 0.0% |
| ok | accept | qutebrowser | 01_1-5 | 1 | 1 | 100.0% |
| ok | accept | qutebrowser | 02_6-20 | 1 | 1 | 100.0% |
| ok | accept | qutebrowser | 03_21-100 | 2 | 5 | 40.0% |
| ok | accept | qutebrowser | 04_101+ | 1 | 3 | 33.3% |
| ok | reject | ansible | 01_1-5 | 9 | 14 | 64.3% |
| ok | reject | ansible | 02_6-20 | 9 | 12 | 75.0% |
| ok | reject | ansible | 03_21-100 | 9 | 12 | 75.0% |
| ok | reject | ansible | 04_101+ | 0 | 1 | 0.0% |
| ok | reject | openlibrary | 01_1-5 | 6 | 10 | 60.0% |
| ok | reject | openlibrary | 02_6-20 | 15 | 18 | 83.3% |
| ok | reject | openlibrary | 03_21-100 | 7 | 11 | 63.6% |
| ok | reject | qutebrowser | 02_6-20 | 5 | 6 | 83.3% |
| ok | reject | qutebrowser | 03_21-100 | 6 | 10 | 60.0% |
| ok | reject | qutebrowser | 04_101+ | 10 | 15 | 66.7% |
| skipped | accept | openlibrary | 03_21-100 | 0 | 1 | 0.0% |

## Zero-Pass Leaked Failures

| task_id | repo | passed_total | title |
| --- | --- | --- | --- |
| ansible-d72025be | ansible | 0/5 | RMB state fixes |
| ansible-1a4644ff | ansible | 0/11 | "## Title:\npsrp connection plugin accepts undocumented extras, causing ambiguou |
| ansible-5640093f | ansible | 0/4 | "## Title\n\n`module_defaults` of the underlying module are not applied when inv |
| ansible-c616e54a | ansible | 0/6 | "# Title\n\n`module_common` fails to resolve `module_utils` from collections (re |
