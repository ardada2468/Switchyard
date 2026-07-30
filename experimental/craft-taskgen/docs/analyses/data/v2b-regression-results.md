# E2E resolution: multivariate logistic regression

Logistic regression of `e2e_resolved ∈ {0,1}` on behavioral predictors. Continuous features standardized to SD=1 so coefficients are comparable. Model dummies in the pooled regression (`codex55` is the reference category). L2 regularization with λ=0.01.

## How to read this

- `β` is the change in log-odds of resolution per 1 SD increase (for continuous) or per category change (for dummies). e.g. β=+0.3 means +1 SD raises log-odds by 0.3, or odds-ratio = exp(0.3) ≈ 1.35.
- The pooled model is the headline. Per-model regressions diagnose heterogeneity.
- The first-half regression controls for 'success ends the trial early': it uses only   signals from the first half of each trial.
- Stars: *** p<0.001, ** p<0.01, * p<0.05.
- McFadden pseudo-R² is interpretable as 'fraction of null deviance explained'. Values   above ~0.2 indicate strong fit for binary outcomes.

## Pooled regression with model fixed effects

### Pooled (all 4 models, n=346)

_n = 346, n_resolved = 132 (38.2%); in-sample accuracy at 0.5 = 0.720; McFadden pseudo-R² = 0.161_

| Feature | β | SE | z | p | 95% CI |
|---|---:|---:|---:|---:|---:|
| `(intercept)` | +0.796* | 0.338 | +2.35 | 0.0185 | [+0.133, +1.458] |
| `tests_per_edit (sd)` | +0.128 | 0.211 | +0.61 | 0.5434 | [-0.286, +0.542] |
| `tests_per_step (sd)` | +0.439* | 0.203 | +2.16 | 0.0308 | [+0.041, +0.838] |
| `exam_file_recall (sd)` | -0.248 | 0.231 | -1.08 | 0.2814 | [-0.700, +0.204] |
| `comm_file_recall (sd)` | -0.124 | 0.221 | -0.56 | 0.5738 | [-0.557, +0.308] |
| `log_n_examined_files (sd)` | +0.010 | 0.194 | +0.05 | 0.9586 | [-0.371, +0.391] |
| `frac_test_files (sd)` | +0.052 | 0.132 | +0.39 | 0.6966 | [-0.207, +0.310] |
| `agent_diff_ratio (sd)` | -0.073 | 0.196 | -0.37 | 0.7103 | [-0.456, +0.311] |
| `probe_fraction (sd)` | -0.172 | 0.218 | -0.79 | 0.4289 | [-0.598, +0.254] |
| `thrash_rate (sd)` | +0.101 | 0.141 | +0.71 | 0.4760 | [-0.176, +0.378] |
| `pre_edit_mention_rate (sd)` | -0.107 | 0.141 | -0.76 | 0.4491 | [-0.384, +0.170] |
| `log_n_steps (sd)` | -0.269 | 0.218 | -1.24 | 0.2167 | [-0.695, +0.158] |
| `log_gold_diff_lines (sd)` | -0.372* | 0.178 | -2.09 | 0.0370 | [-0.721, -0.022] |
| `is_opus47` | -0.876 | 0.483 | -1.81 | 0.0700 | [-1.823, +0.071] |
| `is_haiku45` | -2.179*** | 0.505 | -4.31 | 0.0000 | [-3.169, -1.188] |
| `is_qwen36` | -2.815*** | 0.588 | -4.79 | 0.0000 | [-3.968, -1.662] |

## Per-model regressions

### codex55

_n = 90, n_resolved = 52 (57.8%); in-sample accuracy at 0.5 = 0.689; McFadden pseudo-R² = 0.167_

| Feature | β | SE | z | p | 95% CI |
|---|---:|---:|---:|---:|---:|
| `(intercept)` | +0.558 | 0.290 | +1.93 | 0.0542 | [-0.010, +1.126] |
| `tests_per_edit (sd)` | +0.889 | 0.952 | +0.93 | 0.3503 | [-0.976, +2.754] |
| `tests_per_step (sd)` | +0.374 | 0.731 | +0.51 | 0.6092 | [-1.059, +1.807] |
| `exam_file_recall (sd)` | +0.362 | 0.416 | +0.87 | 0.3836 | [-0.453, +1.177] |
| `comm_file_recall (sd)` | -0.332 | 0.387 | -0.86 | 0.3910 | [-1.091, +0.427] |
| `log_n_examined_files (sd)` | -0.059 | 0.273 | -0.21 | 0.8302 | [-0.595, +0.477] |
| `frac_test_files (sd)` | +0.199 | 0.267 | +0.75 | 0.4551 | [-0.323, +0.721] |
| `agent_diff_ratio (sd)` | -0.153 | 0.377 | -0.41 | 0.6849 | [-0.891, +0.585] |
| `probe_fraction (sd)` | +0.219 | 0.391 | +0.56 | 0.5764 | [-0.548, +0.985] |
| `thrash_rate (sd)` | +0.311 | 0.279 | +1.11 | 0.2654 | [-0.236, +0.859] |
| `pre_edit_mention_rate (sd)` | -0.361 | 0.280 | -1.29 | 0.1975 | [-0.911, +0.188] |
| `log_n_steps (sd)` | -0.361 | 0.325 | -1.11 | 0.2667 | [-0.998, +0.276] |
| `log_gold_diff_lines (sd)` | -0.297 | 0.402 | -0.74 | 0.4594 | [-1.085, +0.491] |

### opus47

_n = 92, n_resolved = 45 (48.9%); in-sample accuracy at 0.5 = 0.717; McFadden pseudo-R² = 0.250_

| Feature | β | SE | z | p | 95% CI |
|---|---:|---:|---:|---:|---:|
| `(intercept)` | -0.037 | 0.255 | -0.14 | 0.8850 | [-0.537, +0.463] |
| `tests_per_edit (sd)` | -0.856 | 0.446 | -1.92 | 0.0547 | [-1.729, +0.017] |
| `tests_per_step (sd)` | +1.711*** | 0.511 | +3.35 | 0.0008 | [+0.710, +2.713] |
| `exam_file_recall (sd)` | -0.995 | 0.590 | -1.69 | 0.0917 | [-2.151, +0.161] |
| `comm_file_recall (sd)` | +0.044 | 0.546 | +0.08 | 0.9361 | [-1.026, +1.114] |
| `log_n_examined_files (sd)` | +0.340 | 0.341 | +1.00 | 0.3181 | [-0.328, +1.009] |
| `frac_test_files (sd)` | -0.434 | 0.300 | -1.45 | 0.1480 | [-1.022, +0.154] |
| `agent_diff_ratio (sd)` | -0.224 | 0.377 | -0.59 | 0.5519 | [-0.964, +0.515] |
| `probe_fraction (sd)` | +0.392 | 0.299 | +1.31 | 0.1897 | [-0.194, +0.978] |
| `thrash_rate (sd)` | -0.195 | 0.278 | -0.70 | 0.4838 | [-0.739, +0.350] |
| `pre_edit_mention_rate (sd)` | +0.000 | 10.000 | +0.00 | 1.0000 | [-19.600, +19.600] |
| `log_n_steps (sd)` | -0.105 | 0.318 | -0.33 | 0.7404 | [-0.729, +0.518] |
| `log_gold_diff_lines (sd)` | -0.849* | 0.401 | -2.12 | 0.0342 | [-1.634, -0.063] |

### haiku45

_n = 91, n_resolved = 23 (25.3%); in-sample accuracy at 0.5 = 0.747; McFadden pseudo-R² = 0.111_

| Feature | β | SE | z | p | 95% CI |
|---|---:|---:|---:|---:|---:|
| `(intercept)` | -1.233*** | 0.273 | -4.51 | 0.0000 | [-1.769, -0.697] |
| `tests_per_edit (sd)` | -0.204 | 0.434 | -0.47 | 0.6389 | [-1.054, +0.647] |
| `tests_per_step (sd)` | +0.395 | 0.479 | +0.82 | 0.4100 | [-0.545, +1.334] |
| `exam_file_recall (sd)` | -0.080 | 0.468 | -0.17 | 0.8639 | [-0.998, +0.838] |
| `comm_file_recall (sd)` | -0.128 | 0.476 | -0.27 | 0.7880 | [-1.061, +0.805] |
| `log_n_examined_files (sd)` | -0.116 | 0.303 | -0.38 | 0.7011 | [-0.710, +0.477] |
| `frac_test_files (sd)` | +0.284 | 0.284 | +1.00 | 0.3176 | [-0.273, +0.841] |
| `agent_diff_ratio (sd)` | +0.400 | 0.452 | +0.89 | 0.3759 | [-0.485, +1.285] |
| `probe_fraction (sd)` | -0.345 | 0.342 | -1.01 | 0.3133 | [-1.014, +0.325] |
| `thrash_rate (sd)` | +0.139 | 0.283 | +0.49 | 0.6229 | [-0.416, +0.695] |
| `pre_edit_mention_rate (sd)` | +0.544 | 0.293 | +1.86 | 0.0635 | [-0.031, +1.118] |
| `log_n_steps (sd)` | -0.368 | 0.352 | -1.04 | 0.2968 | [-1.059, +0.323] |
| `log_gold_diff_lines (sd)` | +0.319 | 0.433 | +0.74 | 0.4610 | [-0.529, +1.167] |

### qwen36

_n = 73, n_resolved = 12 (16.4%); in-sample accuracy at 0.5 = 0.863; McFadden pseudo-R² = 0.256_

| Feature | β | SE | z | p | 95% CI |
|---|---:|---:|---:|---:|---:|
| `(intercept)` | -2.770*** | 0.750 | -3.69 | 0.0002 | [-4.240, -1.300] |
| `tests_per_edit (sd)` | -0.931 | 0.989 | -0.94 | 0.3463 | [-2.870, +1.007] |
| `tests_per_step (sd)` | +1.219 | 0.839 | +1.45 | 0.1459 | [-0.424, +2.863] |
| `exam_file_recall (sd)` | -1.001 | 0.788 | -1.27 | 0.2042 | [-2.546, +0.544] |
| `comm_file_recall (sd)` | +0.259 | 0.815 | +0.32 | 0.7502 | [-1.338, +1.857] |
| `log_n_examined_files (sd)` | +0.288 | 0.434 | +0.66 | 0.5067 | [-0.563, +1.139] |
| `frac_test_files (sd)` | +0.129 | 0.372 | +0.35 | 0.7288 | [-0.599, +0.857] |
| `agent_diff_ratio (sd)` | -0.207 | 0.553 | -0.37 | 0.7085 | [-1.291, +0.878] |
| `probe_fraction (sd)` | -2.848 | 1.675 | -1.70 | 0.0890 | [-6.131, +0.434] |
| `thrash_rate (sd)` | +0.029 | 0.605 | +0.05 | 0.9613 | [-1.156, +1.215] |
| `pre_edit_mention_rate (sd)` | +0.196 | 0.377 | +0.52 | 0.6021 | [-0.542, +0.935] |
| `log_n_steps (sd)` | -1.666 | 0.949 | -1.76 | 0.0791 | [-3.525, +0.194] |
| `log_gold_diff_lines (sd)` | -0.943 | 0.559 | -1.69 | 0.0919 | [-2.039, +0.154] |

## First-half-only regression (reverse-causality control)

Same predictors, but using only signals from steps before the median step of each trial. Controls for 'successful trials end early' confounding.

### First-half only (n=282)

_n = 282, n_resolved = 106 (37.6%); in-sample accuracy at 0.5 = 0.695; McFadden pseudo-R² = 0.146_

| Feature | β | SE | z | p | 95% CI |
|---|---:|---:|---:|---:|---:|
| `(intercept)` | +0.718 | 0.375 | +1.92 | 0.0552 | [-0.016, +1.453] |
| `tests_per_edit (sd)` | -0.214 | 0.201 | -1.07 | 0.2856 | [-0.607, +0.179] |
| `tests_per_step (sd)` | +0.495* | 0.212 | +2.34 | 0.0193 | [+0.080, +0.910] |
| `exam_file_recall (sd)` | -0.260 | 0.236 | -1.10 | 0.2715 | [-0.723, +0.203] |
| `comm_file_recall (sd)` | -0.149 | 0.229 | -0.65 | 0.5158 | [-0.597, +0.300] |
| `log_n_examined_files (sd)` | -0.130 | 0.208 | -0.63 | 0.5306 | [-0.538, +0.277] |
| `frac_test_files (sd)` | +0.092 | 0.145 | +0.64 | 0.5243 | [-0.192, +0.377] |
| `agent_diff_ratio (sd)` | -0.093 | 0.202 | -0.46 | 0.6467 | [-0.489, +0.303] |
| `probe_fraction (sd)` | +0.073 | 0.241 | +0.30 | 0.7627 | [-0.400, +0.546] |
| `thrash_rate (sd)` | +0.184 | 0.171 | +1.07 | 0.2839 | [-0.152, +0.520] |
| `pre_edit_mention_rate (sd)` | -0.106 | 0.154 | -0.69 | 0.4919 | [-0.409, +0.196] |
| `log_n_steps (sd)` | -0.131 | 0.217 | -0.60 | 0.5472 | [-0.555, +0.294] |
| `log_gold_diff_lines (sd)` | -0.419* | 0.188 | -2.23 | 0.0256 | [-0.787, -0.051] |
| `is_opus47` | -0.840 | 0.525 | -1.60 | 0.1093 | [-1.869, +0.188] |
| `is_haiku45` | -1.999*** | 0.531 | -3.76 | 0.0002 | [-3.041, -0.957] |
| `is_qwen36` | -2.496*** | 0.694 | -3.59 | 0.0003 | [-3.857, -1.135] |

