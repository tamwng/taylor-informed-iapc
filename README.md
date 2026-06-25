# Taylor-informed adaptive predictive control: MATLAB implementation

Run `main.m`.

## Requirements

- MATLAB
- Optimization Toolbox (`quadprog`)

## Paper-to-code map

- `plant_dynamics.m`: continuous-time plant in equation (50).
- `plant_step.m`: RK4 with zero-order-hold input from Table II; forward Euler from equation (52) is available by changing `p.plant.integrator`.
- `structured_exponents.m` and `taylor_features.m`: structured regressors in equation (57), giving 2, 5, 9, and 14 coefficients for `D = 1, 3, 5, 7`.
- `rls_update.m`: equations (21)-(23), specialized to the scalar case.
- `frozen_surrogate.m`: equations (59)-(62).
- `solve_mpc_qp.m`: equation (48), using the explicit decision vector `[x_1,...,x_N,u_1,...,u_{N-1},epsilon_1,...,epsilon_N]`.
- `reference_signal.m`: equation (68).
- `parameters.m`: Table II.

The timing follows the paper's PCAC convention: at instant `k`, `x_k` and the currently applied `u_k` are known, and the QP computes `u_{k+1}`. The transition under `u_k` then updates RLS for the next control instant.

## Explicit choices where the paper does not give a unique value

1. The initialization values are cycled in the deterministic order `[0, 0.1, -0.1, 0.2, -0.2]`. Table II specifies the set of levels but not their order. Change `p.id.levels` to use another fixed cycle.
2. The QP uses the natural preview convention `r_{i|k} = r_{k+i}`. Set `p.reference.preview = false` to hold the current command over the horizon.
3. The run includes one dwell of `K_r` samples at the final zero command. Equation (68) defines the final command but does not state a stopping time.

## Outputs

`main.m` prints and saves:

- aggregate RMSE, MAE, steady-state bias, steady-state absolute error, total input variation, constraint violations, predicted slack, and QP failures;
- per-command metrics;
- state, input, logarithmic tracking-error, and Jacobian-comparison plots;
- `simulation_results.mat`, `summary_metrics.csv`, and `segment_metrics.csv` in `results/`.
