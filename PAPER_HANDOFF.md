# Paper handoff

## Canonical experiment

- Prediction horizon: `N = 8`.
- Continuous-time plant propagated under ZOH with one RK4 step per sample.
- RLS fitted to the resulting one-step RK4 transitions.
- Degrees: `D = [1 3 5 7]`; retained coefficient counts: `[2 5 9 14]`.
- Dictionary: forward-Euler/Taylor-structure-informed reduced model class.
- Exact structural statement: the sampled flow has joint-odd symmetry.
- Additional monomial omission is a deliberate model reduction, not an exact RK4 vanishing claim.
- Controller computes `u_(k+1)` while the transition from `k` to `k+1` uses `u_k`.
- State constraint `|x| <= 0.75` is soft; input constraint `|u| <= 1` is hard.
- Reference amplitudes 0.80 and 0.90 exceed the nominal state bound.
- Evaluated per-amplitude MAE discards the first 200 samples of every 300-sample segment.

## Parameter values

- Plant: `dx/dt = 0.5 sin(x) cos(x) + 1.5 cos(x)^2 sin(u)` with `Ts = 0.05 s` and `x0 = 0`.
- MPC weights: `Q = [1 1 1 1 1 1 1 10]`, `R = 0.05`, and state-slack weight `S = 100000`.
- RLS: forgetting factor `lambda = 1`, initial covariance `P0 = 100000 I`, and initialization length `Nid = 60` samples.
- Reference: amplitude-swept `0.10 Hz` sine with amplitudes `[0.25 0.55 0.80 0.90 0]`, each held for 300 samples.
- Simulation: final stored sampling index `K = 1560`.

## Metric definitions

- RMSE, MAE, and maximum absolute error use stored samples `k >= Nid`, including the final state sample at `K`.
- Segment RMSE and MAE use each half-open interval `[segmentStart, segmentStop)` of 300 samples.
- Evaluated bias and evaluated MAE use the final 100 samples of every amplitude segment after discarding samples 1--200 of that segment.
- Total input variation is `sum(abs(diff(u)))` over stored input samples with `k >= Nid`.
- Segment input variation is `sum(abs(diff(u)))` within the applicable half-open segment.
- Maximum state and input violations are the maximum bound excesses over all stored samples, including initialization.
- Maximum predicted slack is the largest optimized soft-state-constraint slack over successful QPs.
- QP failures count nonpositive or missing `quadprog` exit flags for control instants `Nid,...,K-1`.

## Main results

| D | RMSE | MAE | Maximum state violation | Total input variation |
|---:|---:|---:|---:|---:|
| 1 | 0.0319949750 | 0.0141755192 | 0.00737301818 | 12.4053662 |
| 3 | 0.0309216326 | 0.00971360806 | 0.000350170064 | 11.7491269 |
| 5 | 0.0309001826 | 0.00957612476 | 0.000256233266 | 11.8642537 |
| 7 | 0.0308912703 | 0.00958865191 | 0.000352157309 | 11.8111462 |

All cases have zero QP failures and zero input-bound violations.

## Paper artifacts

- `results/state_tracking_D1_D5.png`
- `results/tracking_error_log.png` — genuinely logarithmic y-axis
- `results/per_amplitude_abs_error.png`
- `results/summary_metrics.csv`
- `results/segment_metrics.csv`

## Exact citation text

Manuscript: Tam W. Nguyen, “Taylor-Informed Indirect Adaptive Predictive Control Using Jacobian-Frozen Affine Predictors,” manuscript prepared for the 2027 American Control Conference, 2026.

Software: Tam W. Nguyen, *Taylor-Informed Indirect Adaptive Predictive Control Using Jacobian-Frozen Affine Predictors: MATLAB Code*, version 1.0.0, GitHub, 2026, https://github.com/tamwng/taylor-informed-iapc/releases/tag/v1.0.0.

## External identifiers and release

- Manuscript DOI: not assigned.
- Manuscript arXiv identifier: not assigned.
- Immutable software release/tag: `v1.0.0`.
- Release commit: `895e99be7794a5084bbf02c9ed7c9fd8d82a9711`.
