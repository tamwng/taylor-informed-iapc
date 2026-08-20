# Taylor-Informed Indirect Adaptive Predictive Control Using Jacobian-Frozen Affine Predictors

MATLAB implementation accompanying the manuscript **Taylor-Informed Indirect Adaptive Predictive Control Using Jacobian-Frozen Affine Predictors** by Tam W. Nguyen.

The repository runs a deterministic scalar nonlinear-control study, identifies reduced polynomial models online with recursive least squares (RLS), constructs Jacobian-frozen affine predictors, and compares Taylor degrees `D = [1 3 5 7]`.

## Reproduce the results

From the repository root, run:

```matlab
reproduce_results
```

This regenerates the tables, MAT file, and three publication figures in `results/`.

To reproduce in a temporary directory, compare the generated CSV files within an absolute tolerance of `1e-10`, and compare the decoded figure pixels exactly with the committed baseline:

```matlab
verify_reproduction
```

To run all automated checks:

```matlab
run_repository_tests
```

`main` remains a convenience script and calls `reproduce_results`.

The canonical inputs are the version-controlled MATLAB source files and the parameter values in `parameters.m`; the experiment uses no external data. The generated outputs are exactly:

- `results/summary_metrics.csv`
- `results/segment_metrics.csv`
- `results/simulation_results.mat`
- `results/state_tracking_D1_D5.png`
- `results/tracking_error_log.png`
- `results/per_amplitude_abs_error.png`

The accompanying manuscript is stored at `paper/Taylor_Informed_Indirect_Adaptive_Predictive_Control_Using_Jacobian_Frozen_Affine_Predictors.pdf`. It and `experiment_manifest.json`, `CITATION.cff`, `CITATION.md`, and `PAPER_HANDOFF.md` are committed documentation and metadata, not runtime inputs or automatically generated results.

## Requirements

- MATLAB R2025b or later
- Optimization Toolbox (`quadprog`)

The baseline was produced with MATLAB R2025b and independently reproduced with MATLAB R2026a Update 4. A complete four-degree run, including 300-dpi figure export, takes approximately 18 to 25 seconds on the verification machine.

No random numbers or external datasets are used.

## Scientific configuration

| Quantity | Value |
|---|---:|
| Plant parameters | `a = 0.5`, `b = 1.5` |
| Sampling period | `Ts = 0.05 s` |
| Plant propagation | RK4 under zero-order hold |
| Initial state | `x0 = 0` |
| State bound | `|x| <= 0.75` (soft) |
| Input bound | `|u| <= 1` (hard) |
| Taylor degrees | `[1 3 5 7]` |
| Retained coefficients | `[2 5 9 14]` |
| Prediction horizon | `N = 8` |
| State weights | `Q_i = 1`, `Q_N = 10` |
| Input-increment weight | `R = 5e-2` |
| State-slack weight | `S = 1e5` |
| RLS forgetting factor | `lambda = 1` |
| Initial covariance | `P0 = 1e5 I` |
| Initialization length | `Nid = 60` samples |
| Reference frequency | `0.10 Hz` |
| Reference amplitudes | `[0.25 0.55 0.80 0.90 0]` |
| Segment length | `300` samples |

The 0.80 and 0.90 reference amplitudes exceed the nominal state bound. The MPC therefore uses nonnegative state slack; the state bound is soft, whereas the input bound is hard.

## RK4 plant and reduced dictionary

The continuous-time plant is propagated with RK4. RLS is updated from the resulting one-step RK4 transitions.

The retained polynomial feature pattern is a deliberate forward-Euler/Taylor-structure-informed reduced model class. Joint-odd symmetry is exact for the sampled flow. The additional omission of odd-total-degree terms such as `x*u^2` is a model-reduction choice motivated by the forward-Euler Taylor structure; it is not a claim that every omitted term vanishes in the RK4 sampled flow.

`analytical_fe_jacobian.m` supplies an optional forward-Euler diagnostic. It does not propagate the plant or construct the MPC predictor.

## Timing and input indexing

At control instant `k`, the controller computes `u_(k+1)`. The plant transition from `k` to `k+1` uses the currently applied input `u_k`. The newly computed input is used on the subsequent transition.

## Metric definitions

- **RMSE, MAE, and maximum absolute error:** computed for stored samples with `k >= Nid`, including the final state sample at `K`.
- **Segment RMSE and MAE:** computed on each half-open 300-sample interval `[segmentStart, segmentStop)`.
- **Evaluated MAE:** for the amplitude-swept sine, the first complete period is discarded. At `0.10 Hz` and `Ts = 0.05 s`, this is 200 samples, leaving the final 100 samples of each segment.
- **Total input variation:** `sum(abs(diff(u)))` over stored samples with `k >= Nid`.
- **Maximum state/input violation:** maximum excess over the corresponding bound across all stored samples, including initialization.
- **Maximum predicted slack:** largest optimized state-slack value over all successful QPs.
- **QP failures:** count of nonpositive or missing `quadprog` exit flags for control instants `Nid,...,K-1`.

## Repository layout

```text
main.m                         Convenience entry point
reproduce_results.m            Canonical reproduction entry point
run_experiment.m               Degree sweep and artifact generation
verify_reproduction.m          Isolated full-run comparison
verify_results.m               CSV comparison with explicit tolerance
run_repository_tests.m         Automated test entry point
tests/test_repository.m        Unit and integration checks
parameters.m                   Canonical experiment configuration
simulate_case.m                One closed-loop degree case
solve_mpc_qp.m                 Jacobian-frozen MPC quadratic program
compute_metrics.m              Documented metrics
plot_results.m                 Deterministic publication figures
experiment_manifest.json       Machine-readable configuration and baseline
PAPER_HANDOFF.md               Paper-facing facts and result locations
paper/                          Audited accompanying manuscript PDF
results/                       Committed generated artifacts
```

## Citation

If this repository contributes to published or derived work, cite both the accompanying manuscript and the software. Verified citation text is provided in `CITATION.md` and `CITATION.cff`.

The immutable software release `v1.0.0` is tied to commit `895e99be7794a5084bbf02c9ed7c9fd8d82a9711`. Later commits on `main` may contain metadata-only updates; for reproducibility, cite the release and record the exact Git commit used.

## License

The code is released under the BSD 3-Clause License. The citation request is a scholarly attribution expectation and is not an additional license condition.
