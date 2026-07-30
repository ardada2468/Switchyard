# OK vs Leaked Controlled Pass Rate

This compares `ok` and `leaked` tasks after controlling for coarse difficulty proxies from `swebench_pro.jsonl`.

Method: coarsened exact matching/direct standardization. For each control set, keep only cells containing both `ok` and `leaked` tasks. `ok_rate_on_leaked_mix` answers: if leaked tasks had the OK pass rate in the same cells, what pass rate would we expect?

## Raw

| ok | leaked | raw_ok_minus_leaked |
| --- | --- | --- |
| 95/152 (62.5%) | 37/70 (52.9%) | 9.6 pp |

## Controlled Summaries

| spec | matched_cells | matched_ok | matched_leaked | matched_raw_gap | ok_rate_on_leaked_mix | leaked_shortfall_vs_cell_ok | matched_ok_n | matched_leaked_n |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Repo | 3 | 95/152 (62.5%) | 37/70 (52.9%) | 9.6 pp | 61.4% | 8.5 pp | 152 | 70 |
| Repo + Eval | 6 | 95/152 (62.5%) | 37/70 (52.9%) | 9.6 pp | 55.6% | 2.7 pp | 152 | 70 |
| Repo + Eval + True F2P | 22 | 85/137 (62.0%) | 34/66 (51.5%) | 10.5 pp | 47.8% | -3.7 pp | 137 | 66 |
| Repo + Eval + Required | 18 | 93/148 (62.8%) | 37/68 (54.4%) | 8.4 pp | 53.5% | -0.9 pp | 148 | 68 |
| Repo + Eval + Metadata Size | 28 | 38/64 (59.4%) | 29/47 (61.7%) | -2.3 pp | 49.4% | -12.3 pp | 64 | 47 |
| Repo + Eval + True F2P + Metadata Size | 22 | 20/31 (64.5%) | 20/30 (66.7%) | -2.2 pp | 57.8% | -8.9 pp | 31 | 30 |
| Repo + Eval + True F2P + P2P + Metadata Size | 14 | 9/17 (52.9%) | 11/16 (68.8%) | -15.8 pp | 40.6% | -28.1 pp | 17 | 16 |
| Repo + Eval + Full Coarsened | 7 | 5/8 (62.5%) | 6/9 (66.7%) | -4.2 pp | 44.4% | -22.2 pp | 8 | 9 |

## Largest Matched Cells

Using `repo + eval + true F2P + requirements length + test patch size + source patch size`.

| cell | ok | leaked | cell_n |
| --- | --- | --- | --- |
| qutebrowser / accept / 05_26+ / 03_251-500 / 04_251+ / 02_51-200 | 0/1 (0.0%) | 2/4 (50.0%) | 5 |
| qutebrowser / reject / 02_3-5 / 02_101-250 / 01_0-20 / 01_0-50 | 2/3 (66.7%) | 2/2 (100.0%) | 5 |
| openlibrary / reject / 01_1-2 / 01_0-100 / 01_0-20 / 02_51-200 | 3/3 (100.0%) | 1/1 (100.0%) | 4 |
| ansible / reject / 02_3-5 / 02_101-250 / 02_21-100 / 02_51-200 | 2/2 (100.0%) | 2/2 (100.0%) | 4 |
| qutebrowser / reject / 03_6-10 / 02_101-250 / 02_21-100 / 01_0-50 | 0/2 (0.0%) | 2/2 (100.0%) | 4 |
| ansible / reject / 01_1-2 / 02_101-250 / 02_21-100 / 02_51-200 | 2/2 (100.0%) | 1/1 (100.0%) | 3 |
| qutebrowser / accept / 03_6-10 / 02_101-250 / 02_21-100 / 02_51-200 | 1/2 (50.0%) | 1/1 (100.0%) | 3 |
| ansible / reject / 02_3-5 / 02_101-250 / 02_21-100 / 01_0-50 | 1/2 (50.0%) | 0/1 (0.0%) | 3 |
| qutebrowser / reject / 01_1-2 / 02_101-250 / 01_0-20 / 01_0-50 | 1/1 (100.0%) | 2/2 (100.0%) | 3 |
| qutebrowser / accept / 04_11-25 / 02_101-250 / 02_21-100 / 02_51-200 | 1/1 (100.0%) | 1/2 (50.0%) | 3 |
| ansible / reject / 03_6-10 / 02_101-250 / 02_21-100 / 03_201-500 | 1/1 (100.0%) | 1/1 (100.0%) | 2 |
| ansible / accept / 02_3-5 / 02_101-250 / 03_101-250 / 02_51-200 | 0/1 (0.0%) | 0/1 (0.0%) | 2 |
| ansible / accept / 02_3-5 / 03_251-500 / 02_21-100 / 02_51-200 | 0/1 (0.0%) | 0/1 (0.0%) | 2 |
| openlibrary / accept / 01_1-2 / 02_101-250 / 02_21-100 / 02_51-200 | 0/1 (0.0%) | 1/1 (100.0%) | 2 |
| openlibrary / accept / 04_11-25 / 03_251-500 / 03_101-250 / 03_201-500 | 0/1 (0.0%) | 0/1 (0.0%) | 2 |
| openlibrary / reject / 01_1-2 / 01_0-100 / 02_21-100 / 02_51-200 | 0/1 (0.0%) | 1/1 (100.0%) | 2 |
| ansible / reject / 03_6-10 / 03_251-500 / 02_21-100 / 02_51-200 | 1/1 (100.0%) | 1/1 (100.0%) | 2 |
| ansible / reject / 01_1-2 / 02_101-250 / 01_0-20 / 03_201-500 | 1/1 (100.0%) | 0/1 (0.0%) | 2 |
| openlibrary / reject / 01_1-2 / 02_101-250 / 01_0-20 / 03_201-500 | 1/1 (100.0%) | 0/1 (0.0%) | 2 |
| openlibrary / reject / 01_1-2 / 02_101-250 / 02_21-100 / 04_501+ | 1/1 (100.0%) | 1/1 (100.0%) | 2 |
| openlibrary / reject / 03_6-10 / 02_101-250 / 02_21-100 / 01_0-50 | 1/1 (100.0%) | 1/1 (100.0%) | 2 |
| qutebrowser / reject / 01_1-2 / 02_101-250 / 02_21-100 / 01_0-50 | 1/1 (100.0%) | 0/1 (0.0%) | 2 |

## Read

- Raw gap: OK is 62.5% and leaked is 52.9%, a 9.6 point OK advantage.
- Controlling only for repo + eval verdict reduces the gap materially; leaked has a 2.8 point shortfall versus same-cell OK rates.
- Adding true F2P buckets removes the same-cell shortfall: leaked is 3.7 points above the OK same-cell expectation in the matched subset.
- Using verifier required-test buckets also removes the same-cell shortfall: leaked is 0.9 points above the OK same-cell expectation.
- Controlling for metadata/diff-size buckets gets sparse, but the residual does not grow; in those matched subsets leaked is above same-cell OK expectation.
- The full coarsened spec keeps only a small subset of leaked tasks, so treat it as diagnostic rather than definitive.
- Practical interpretation: the raw OK-vs-leaked gap is mostly explained by composition across repo/eval/difficulty proxies. There is not strong evidence that leaked tasks underperform OK tasks within matched cells.
