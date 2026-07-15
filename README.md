# Taylor-Informed Indirect Adaptive Predictive Control Using Jacobian-Frozen Affine Predictors

MATLAB code for the numerical study in:

> **Taylor-Informed Indirect Adaptive Predictive Control Using Jacobian-Frozen Affine Predictors**  
> Tam W. Nguyen, 2026.  
> Paper/arXiv: `[URL or arXiv identifier]`

The code simulates the scalar nonlinear plant, identifies structured Taylor coefficients online using RLS, constructs Jacobian-frozen affine predictors, solves the MPC problem, and compares Taylor degrees.

## Quick start

Run

```matlab
main
```
from the repository root.

Outputs are written to `results/` when `p.output.save = true` in `parameters.m`.

## Requirements

- MATLAB
- Optimization Toolbox (`quadprog`)

Tested MATLAB version: `2025b`.

## Repository layout

The repository uses a flat structure for simplicity.

```text
.
├── main.m                         # Runs all Taylor-degree cases and exports results
├── parameters.m                   # Plant, RLS, MPC, reference, plotting, and output settings
├── plant_dynamics.m               # Continuous-time nonlinear plant
├── plant_step.m                   # Euler/RK4 sampled plant propagation
├── structured_exponents.m         # Structured Taylor monomial exponents
├── taylor_features.m              # Taylor-feature evaluation
├── rls_update.m                   # Recursive least-squares update
├── frozen_surrogate.m             # Jacobian-frozen affine predictor construction
├── analytical_fe_jacobian.m       # Analytical forward-Euler Jacobian reference
├── initialization_input.m         # Multilevel initialization input
├── reference_signal.m             # Step, sine, amplitude-swept sine, or multisine reference
├── mpc_reference_horizon.m        # Reference preview over the MPC horizon
├── solve_mpc_qp.m                 # MPC quadratic program
├── simulate_case.m                # Closed-loop simulation for one Taylor degree
├── compute_metrics.m              # Summary and per-segment metrics
├── plot_results.m                 # State, input, tracking-error, and bar plots
├── results/                       # Generated figures and tables; not required as input
├── README.md
├── LICENSE
└── CITATION.cff
```

## Typical workflow

1. Edit `parameters.m`.
2. Choose Taylor degrees with:

```matlab
p.model.degrees = [1 3 5 7];
```

3. Choose the reference campaign, for example:

```matlab
p.reference.type = 'amp_sine';
p.reference.ampLevels = [0.25 0.55 0.80 0.90 0.00];
p.reference.preview = true;
```

4. Run:

```matlab
main
```

5. Inspect the generated figures and tables in `results/`.

## Citation

If you use this repository, cite both the paper and the software release.

### Paper

The manuscript accompanying this repository is available in:
```
paper/Taylor_Informed_Adaptive_Predictive_Control_v1.pdf
```

The latest version is also available on arXiv:

```bibtex
@article{nguyen2026taylorinformedadaptivepredictivecontrol,
  author  = {Nguyen, Tam W.},
  title   = {Taylor-Informed Indirect Adaptive Predictive Control Using Jacobian-Frozen Affine Predictors},
  journal = {arXiv preprint arXiv:XXXX.XXXXX},
  year    = {2026},
  url     = {https://arxiv.org/abs/XXXX.XXXXX}
}
```

### Software

```bibtex
@software{nguyen2026taylorinformedmpccode,
  author    = {Nguyen, Tam W.},
  title     = {Taylor-Informed Indirect Adaptive Predictive Control Using Jacobian-Frozen Affine Predictors: MATLAB Code},
  year      = {2026},
  version   = {v1.0.0},
  publisher = {GitHub},
  url       = {https://github.com/tamwng/taylor-informed-iapc}
}
```

## License

This project is released under the BSD 3-Clause License. See `LICENSE`.
