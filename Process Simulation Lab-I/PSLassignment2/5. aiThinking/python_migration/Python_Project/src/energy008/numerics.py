"""Synthetic numerical primitives; not connected to the physical process flowsheet."""
from __future__ import annotations
import numpy as np
from scipy.optimize import root


def solve_synthetic_nonlinear(residual_function, initial_guess, tolerance: float = 1e-9,
                              max_evaluations: int = 200) -> dict:
    """Solve a caller-supplied test equation with SciPy; do not use as process validation."""
    x0 = np.asarray(initial_guess, dtype=float)
    if x0.ndim != 1 or not np.all(np.isfinite(x0)):
        raise ValueError("Initial guess must be a finite one-dimensional vector.")
    if tolerance <= 0 or max_evaluations < 1:
        raise ValueError("Tolerance and evaluation limit must be positive.")
    solved = root(residual_function, x0, method="hybr", options={"xtol": tolerance, "maxfev": max_evaluations})
    resid = np.asarray(residual_function(solved.x), dtype=float)
    norm = float(np.linalg.norm(resid, ord=2))
    accepted = bool(solved.success and np.isfinite(norm) and norm <= max(10 * tolerance, 1e-10))
    return {"status": "CONVERGED_SYNTHETIC_ONLY" if accepted else "FAILED",
            "solution": solved.x.tolist(), "residual_norm": norm,
            "nfev": int(solved.nfev), "message": str(solved.message),
            "applicability": "Synthetic numerical test only; not physical recycle/PFR evidence."}
