# Known Limitations and Acceptance Status

**Overall predictive-model acceptance: NOT PASSED.**

1. Candidate NRTL parameters are outside the demonstrated validity basis at the chosen condition; SRK `kij=0` is diagnostic only.
2. Global phase stability and liquid-root/stability selection are not implemented.
3. The flash optimizer may find a low residual local solution or boundary result; residuals and status are exposed and must be checked.
4. Modified-Rackett liquid molar volumes, acentric factors and the Souders-Brown K-factor require independent source verification before equipment design.
5. Experimental reference interpolation is only an independent software fixture, not a substitute for the primary model.
6. Energy balance is deliberately blocked until a validated consistent enthalpy formulation exists.
7. Utility consumption and CAPEX/OPEX are deliberately blocked because duty, utility conditions, cost correlation, cost index and annual operating basis are not approved.
8. PRSV-Wong-Sandler is not independently implemented because the exact parameters/conventions needed for a like-for-like model are not in the provided Phase 2 data. Literature-published comparisons are retained separately.
9. The GUI and MATLAB syntax cannot be runtime-tested in the current environment because MATLAB and GNU Octave were unavailable. A MATLAB-capable user must run `tests/run_tests.m` and GUI test steps.
10. MATLAB base functions used: JSON parsing, `fminsearch`, `roots`, tables, `uifigure` UI components, and plotting. GUI support requires a MATLAB release supporting programmatic `uifigure` and `uigridlayout`.
