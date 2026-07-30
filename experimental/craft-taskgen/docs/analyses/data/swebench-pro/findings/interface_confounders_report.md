# Interface Field Confounder Analysis

Enriched CSV: `docs/analyses/data/swebench-pro/findings/interface_confounders_enriched.csv`

Raw `interface` is non-empty for every task, so this report uses the semantic split:
`meaningful` vs `placeholder_no_new`.

## Headline

| interface_kind | n | passed | pass_rate | leaked_share | ok_share | avg_required_total | avg_swebench_f2p_total | avg_source_lines | avg_test_lines |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| meaningful | 145 | 84 | 57.9% | 25.5% | 61.4% | 78.7 | 26.3 | 198.5 | 126.1 |
| placeholder_no_new | 118 | 67 | 56.8% | 28.0% | 53.4% | 91.8 | 20.8 | 83.4 | 88.3 |

Requirements are not useful as a splitter in this state file: 263/263 are semantically meaningful and 0/263 are placeholder-like.

## By Alignment Verdict

| alignment_verdict | interface_kind | n | passed | pass_rate | avg_required_total | avg_swebench_f2p_total |
| --- | --- | --- | --- | --- | --- | --- |
| leaked | meaningful | 37 | 16 | 43.2% | 112.1 | 28.9 |
| leaked | placeholder_no_new | 33 | 21 | 63.6% | 123.2 | 49.9 |
| narrow_tests | meaningful | 18 | 10 | 55.6% | 138.0 | 114.8 |
| narrow_tests | placeholder_no_new | 22 | 9 | 40.9% | 65.4 | 4.6 |
| ok | meaningful | 89 | 58 | 65.2% | 53.0 | 7.6 |
| ok | placeholder_no_new | 63 | 37 | 58.7% | 84.5 | 11.1 |
| skipped | meaningful | 1 | 0 | 0.0% | 57.0 | 2.0 |

## By Required Test Count Bucket

| f2p_total_bucket | interface_kind | n | passed | pass_rate | avg_required_total | avg_swebench_f2p_total |
| --- | --- | --- | --- | --- | --- | --- |
| 01_1-5 | meaningful | 29 | 13 | 44.8% | 2.8 | 2.4 |
| 01_1-5 | placeholder_no_new | 13 | 10 | 76.9% | 2.5 | 1.7 |
| 02_6-20 | meaningful | 57 | 39 | 68.4% | 11.1 | 5.9 |
| 02_6-20 | placeholder_no_new | 29 | 16 | 55.2% | 11.2 | 4.1 |
| 03_21-100 | meaningful | 43 | 21 | 48.8% | 48.6 | 12.4 |
| 03_21-100 | placeholder_no_new | 52 | 31 | 59.6% | 47.2 | 5.9 |
| 04_101+ | meaningful | 16 | 11 | 68.8% | 537.7 | 180.2 |
| 04_101+ | placeholder_no_new | 24 | 10 | 41.7% | 334.0 | 83.3 |

## By Alignment Verdict And Required Test Bucket

| alignment_verdict | interface_kind | f2p_total_bucket | n | passed | pass_rate | avg_required_total | avg_swebench_f2p_total |
| --- | --- | --- | --- | --- | --- | --- | --- |
| leaked | meaningful | 01_1-5 | 5 | 1 | 20.0% | 3.4 | 2.8 |
| leaked | meaningful | 02_6-20 | 15 | 8 | 53.3% | 12.0 | 7.3 |
| leaked | meaningful | 03_21-100 | 11 | 3 | 27.3% | 44.9 | 10.4 |
| leaked | meaningful | 04_101+ | 6 | 4 | 66.7% | 575.8 | 138.8 |
| leaked | placeholder_no_new | 01_1-5 | 2 | 1 | 50.0% | 2.5 | 2.5 |
| leaked | placeholder_no_new | 02_6-20 | 7 | 4 | 57.1% | 10.1 | 4.4 |
| leaked | placeholder_no_new | 03_21-100 | 16 | 11 | 68.8% | 56.0 | 8.1 |
| leaked | placeholder_no_new | 04_101+ | 8 | 5 | 62.5% | 386.8 | 185.1 |
| narrow_tests | meaningful | 01_1-5 | 6 | 3 | 50.0% | 2.8 | 2.8 |
| narrow_tests | meaningful | 02_6-20 | 4 | 3 | 75.0% | 13.0 | 5.8 |
| narrow_tests | meaningful | 03_21-100 | 6 | 3 | 50.0% | 50.7 | 25.5 |
| narrow_tests | meaningful | 04_101+ | 2 | 1 | 50.0% | 1055.5 | 937.0 |
| narrow_tests | placeholder_no_new | 01_1-5 | 1 | 1 | 100.0% | 3.0 | 2.0 |
| narrow_tests | placeholder_no_new | 02_6-20 | 6 | 2 | 33.3% | 13.3 | 4.2 |
| narrow_tests | placeholder_no_new | 03_21-100 | 11 | 6 | 54.5% | 35.0 | 4.9 |
| narrow_tests | placeholder_no_new | 04_101+ | 4 | 0 | 0.0% | 242.5 | 5.2 |
| ok | meaningful | 01_1-5 | 18 | 9 | 50.0% | 2.7 | 2.2 |
| ok | meaningful | 02_6-20 | 38 | 28 | 73.7% | 10.5 | 5.3 |
| ok | meaningful | 03_21-100 | 25 | 15 | 60.0% | 49.3 | 10.5 |
| ok | meaningful | 04_101+ | 8 | 6 | 75.0% | 379.6 | 22.1 |
| ok | placeholder_no_new | 01_1-5 | 10 | 8 | 80.0% | 2.5 | 1.5 |
| ok | placeholder_no_new | 02_6-20 | 16 | 10 | 62.5% | 10.8 | 3.9 |
| ok | placeholder_no_new | 03_21-100 | 25 | 14 | 56.0% | 47.0 | 5.0 |
| ok | placeholder_no_new | 04_101+ | 12 | 5 | 41.7% | 329.2 | 41.4 |
| skipped | meaningful | 03_21-100 | 1 | 0 | 0.0% | 57.0 | 2.0 |

## By Repo

| repo | interface_kind | n | passed | pass_rate | avg_required_total | avg_swebench_f2p_total |
| --- | --- | --- | --- | --- | --- | --- |
| ansible | meaningful | 45 | 21 | 46.7% | 22.8 | 6.8 |
| ansible | placeholder_no_new | 51 | 27 | 52.9% | 37.0 | 4.2 |
| openlibrary | meaningful | 61 | 37 | 60.7% | 19.1 | 7.6 |
| openlibrary | placeholder_no_new | 28 | 16 | 57.1% | 36.0 | 5.4 |
| qutebrowser | meaningful | 39 | 26 | 66.7% | 236.3 | 78.1 |
| qutebrowser | placeholder_no_new | 39 | 24 | 61.5% | 203.4 | 53.4 |

## By Eval Verdict

| new_eval_verdict | interface_kind | n | passed | pass_rate | avg_required_total | avg_swebench_f2p_total |
| --- | --- | --- | --- | --- | --- | --- |
| accept | meaningful | 58 | 25 | 43.1% | 78.1 | 23.9 |
| accept | placeholder_no_new | 38 | 14 | 36.8% | 112.2 | 54.3 |
| reject | meaningful | 87 | 59 | 67.8% | 79.0 | 28.0 |
| reject | placeholder_no_new | 80 | 53 | 66.2% | 82.1 | 4.8 |

## Matched Cell Check

Matched cells use `(repo, eval verdict, alignment verdict, required test-count bucket)`. This asks whether meaningful-interface tasks still underperform after comparing only against placeholder-interface tasks in the same broad strata.

| metric | value |
| --- | --- |
| matched_meaningful_total | 124 |
| matched_meaningful_actual | 75 |
| matched_meaningful_actual_rate | 60.5% |
| expected_passes_at_placeholder_cell_rates | 64.2 |
| expected_rate_at_placeholder_cell_rates | 51.8% |

Matched cells:
| repo | eval | alignment | f2p_bucket | placeholder | meaningful |
| --- | --- | --- | --- | --- | --- |
| ansible | accept | leaked | 01_1-5 | 0/1 (0.0%) | 0/1 (0.0%) |
| ansible | accept | leaked | 03_21-100 | 0/3 (0.0%) | 1/4 (25.0%) |
| ansible | accept | narrow_tests | 03_21-100 | 0/1 (0.0%) | 1/2 (50.0%) |
| ansible | accept | ok | 02_6-20 | 1/2 (50.0%) | 1/4 (25.0%) |
| ansible | accept | ok | 03_21-100 | 0/1 (0.0%) | 0/3 (0.0%) |
| ansible | reject | leaked | 02_6-20 | 1/3 (33.3%) | 3/7 (42.9%) |
| ansible | reject | leaked | 03_21-100 | 6/6 (100.0%) | 1/1 (100.0%) |
| ansible | reject | ok | 01_1-5 | 4/5 (80.0%) | 5/9 (55.6%) |
| ansible | reject | ok | 02_6-20 | 2/4 (50.0%) | 7/8 (87.5%) |
| ansible | reject | ok | 03_21-100 | 7/10 (70.0%) | 2/2 (100.0%) |
| openlibrary | accept | leaked | 03_21-100 | 0/2 (0.0%) | 1/1 (100.0%) |
| openlibrary | accept | narrow_tests | 02_6-20 | 0/1 (0.0%) | 2/3 (66.7%) |
| openlibrary | accept | narrow_tests | 03_21-100 | 0/1 (0.0%) | 2/3 (66.7%) |
| openlibrary | accept | ok | 01_1-5 | 1/1 (100.0%) | 0/1 (0.0%) |
| openlibrary | accept | ok | 02_6-20 | 0/1 (0.0%) | 6/10 (60.0%) |
| openlibrary | accept | ok | 03_21-100 | 1/2 (50.0%) | 4/6 (66.7%) |
| openlibrary | reject | leaked | 01_1-5 | 1/1 (100.0%) | 1/2 (50.0%) |
| openlibrary | reject | ok | 01_1-5 | 3/4 (75.0%) | 3/6 (50.0%) |
| openlibrary | reject | ok | 02_6-20 | 4/5 (80.0%) | 11/13 (84.6%) |
| openlibrary | reject | ok | 03_21-100 | 4/6 (66.7%) | 3/5 (60.0%) |
| qutebrowser | accept | leaked | 03_21-100 | 2/2 (100.0%) | 0/2 (0.0%) |
| qutebrowser | accept | leaked | 04_101+ | 3/6 (50.0%) | 1/2 (50.0%) |
| qutebrowser | accept | narrow_tests | 04_101+ | 0/1 (0.0%) | 1/1 (100.0%) |
| qutebrowser | accept | ok | 03_21-100 | 1/1 (100.0%) | 1/4 (25.0%) |
| qutebrowser | reject | leaked | 02_6-20 | 2/2 (100.0%) | 1/1 (100.0%) |
| qutebrowser | reject | leaked | 03_21-100 | 3/3 (100.0%) | 0/2 (0.0%) |
| qutebrowser | reject | leaked | 04_101+ | 1/1 (100.0%) | 3/3 (100.0%) |
| qutebrowser | reject | narrow_tests | 02_6-20 | 1/1 (100.0%) | 1/1 (100.0%) |
| qutebrowser | reject | narrow_tests | 03_21-100 | 1/1 (100.0%) | 0/1 (0.0%) |
| qutebrowser | reject | narrow_tests | 04_101+ | 0/1 (0.0%) | 0/1 (0.0%) |
| qutebrowser | reject | ok | 02_6-20 | 3/4 (75.0%) | 2/2 (100.0%) |
| qutebrowser | reject | ok | 03_21-100 | 1/5 (20.0%) | 5/5 (100.0%) |
| qutebrowser | reject | ok | 04_101+ | 4/7 (57.1%) | 6/8 (75.0%) |

## Interpretation

- Raw pass rate barely changes by interface kind: meaningful is 57.9% and placeholder-no-new is 56.8%. So meaningful interface metadata is not an overall negative predictor by itself.
- The interesting interaction is with alignment verdict: leaked + meaningful interface is 43.2%, while leaked + placeholder-no-new is 63.6%; OK + meaningful is 65.2%. The leaked underperformance is concentrated in the meaningful-interface slice.
- Required test count is a plausible confounder inside that slice: leaked + meaningful averages 112 required tests, while OK + meaningful averages 53. But required count alone is not sufficient, since leaked + placeholder-no-new averages 123 required tests and still passes at 63.6%.
- The matched cell check is noisy because many strata are small, but it does not support a stable overall penalty for meaningful interfaces. Matched meaningful-interface tasks pass at 60.5%, versus 51.8% expected if they followed placeholder rates in the same cells.
- Requirements do not provide a usable confounder split here because every candidate has meaningful requirements text.
