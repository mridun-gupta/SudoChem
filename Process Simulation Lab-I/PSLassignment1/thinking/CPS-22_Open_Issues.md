# CPS-22 Open Issues and Final Acceptance Gates

## Critical scientific issues
1. **NRTL-SRK fugacity equality fails.** Corrected component-specific Poynting factors give ethanol ln(fV/fL) = -0.019121 and water = -0.118863 at the experimental interpolated reference point; max absolute residual 0.118863 versus 1e-6. Do not claim an accepted predictive flash.
2. **NRTL parameter validity.** The candidate source parameter set was not demonstrated valid at 445.125 K and 1.5 MPa. A regression that hits the SRK kij bound and has poor 2 MPa holdout performance is rejected.
3. **Liquid molar volumes.** Component-specific Rackett estimates used for Poynting/density are low-confidence at this state. Replace with validated compressed-liquid volume data or a suitable EOS/volume model.
4. **Phase stability.** Tangent-plane-distance or another rigorous phase-stability method is not implemented/verified.

## Engineering issues
5. **Energy balance.** Current duty is a scenario made from assumed ethanol Cp and approximate pure-fluid latent heats. It is not a closed process energy balance.
6. **Utilities/OPEX.** Steam enthalpy drop, hours per year and tariff are assumptions. OPEX is scenario only.
7. **CAPEX.** A verified vessel cost correlation with pressure/material/fabrication factors and dated cost index basis is unavailable, so numerical CAPEX is blocked.
8. **Separator design.** Souders–Brown is a preliminary hydraulic screen; final internals, entrainment, demister, nozzle design, relief, mechanical design and relevant code review remain out of scope.
9. **Sensitivity.** Five study families are recorded, but they are not all validated NRTL-SRK predictive model sweeps. Data-driven and equation-diagnostic studies must be labelled as such.

## Software verification issues
10. MATLAB and GNU Octave were unavailable when this package was created. All MATLAB tests and GUI operations remain NOT RUN/BLOCKED until execution is evidenced.
11. The reference interpolation is preserved separately from the production flash solver. Do not replace a model failure with a hard-coded empirical phase split in the production path.
12. Native editable Word Equation Editor objects were not generated/verified; equations appear as typed mathematical text.

## Close-out steps
- Freeze sourced high-pressure binary parameters and conventions.
- Implement stability checks; run model calibration against training data, then hold out at least one independent pressure/data subset.
- Update all dependent calculations after parameter acceptance.
- Execute all MATLAB tests, GUI run/reset/error/export paths, and independent recomputation in MATLAB.
- Recompute enthalpies/utilities/costs from a justified physical basis and document uncertainty.
- Update compliance matrix to reflect actual evidence; do not change statuses until retests pass.
