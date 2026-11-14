# CPS-22 Calculation Diagnostics

## Acceptance gate

**Overall Phase 2 status: NOT PASSED for the full NRTL–SRK model.** Reference-data interpolation and material-balance arithmetic ran. The target-model parameter/model gate failed and energy/economics are blocked pending property-method resolution.

## Reproduced reference-data checks

- Experimental Table 6 rows transcribed in CSV: 99 total (100 kPa: 26; 1500 kPa: 32; 2000 kPa: 41).
- Pressure blocks in the 2021 paper are experimental T-x-y measurements, not simulated values.
- Selected base conditions: T=445.125329 K, P=1500000 Pa, F=100 kmol/h, z_ethanol=0.5.
- Reference interpolation: x_ethanol=0.38848026, y_ethanol=0.54824013, beta=0.69804600.
- Total, ethanol and water balance residuals from the lever rule are zero to arithmetic precision. This is expected and is not independent property-model evidence.

## NRTL–SRK numerical diagnostic

### Candidate parameter set

The literature-reproduced Aspen VLE-IG NRTL set is not validated at selected T. Diagnostic residual RMS at measured points with k_ij=0:
- 1500 kPa: 0.137155 log-fugacity units; max absolute residual 0.476169.
- 2000 kPa: 0.155743 log-fugacity units; max absolute residual 0.531223.

### Parameter-fit attempt

- Fit used the 1500 kPa Table 6 experimental rows; alpha=0.3 fixed; parameters a12,b12,a21,b21 and k_ij varied.
- Fitted parameters (diagnostic only): a12=15.1153; b12=-6697.59 K; a21=-4.15412; b21=2377.48 K; k_ij=0.2 (upper constraint ±0.2 reached).
- Training RMS=0.040858; training max absolute residual=0.162855.
- Held pressure (2000 kPa) RMS=0.143435; max=0.359748.
- Because k_ij reached a bound and the residual remains material, the parameters are not accepted. This fit should not be frozen as the Phase 3 parameter set.
- Initial default flash solver: `solver_exit_flag=true` but max log-fugacity residual=0.061201, scaled material-balance residual=0.007109; reject result. This explicitly demonstrates that a library exit flag alone is not an acceptance test.
- Fitted-trial flash has near-zero internal residuals but inherits a failed parameter regression, so it is not an accepted engineering output.

## Property-data and correlation warnings

1. Ethanol and water Antoine correlations used are within their cited temperature intervals at T0. They need range checks at every sensitivity point.
2. Acentric factors used for SRK are provisional values to freeze against a primary property source in Phase 3.
3. Saturated-liquid molar volumes from modified Rackett are approximations, used only to estimate the Poynting correction and separator loads.
4. SRK is a non-associating cubic EOS and may not predict highly associating ethanol-water vapour/liquid behaviour adequately without careful interaction-parameter fitting. The data residual confirms the need for independent verification rather than assuming suitability.
5. The 2021 source uses PRSV and PC-SAFT model results, not NRTL-SRK; its measurements are valid reference data but it does not validate the target combination.
6. 1500 kPa parameter fit and 2000 kPa holdout come from the same publication, so a second independent source should be sought for acceptance.

## Blockers to a complete Phase 2 acceptance

- Source-verifiable high-temperature NRTL parameterization or defensible regression with an identified objective function and residual weights.
- Convention-matched SRK binary interaction parameter, fitted and tested without hitting an artificial bound.
- Independent validation dataset at high pressure, if accessible.
- Consistent mixture enthalpy method (ideal gas, SRK residual, liquid reference, NRTL excess enthalpy) and enthalpy reference alignment.
- Pressure/service-specific vessel K-factor and liquid density correlation.
- Source-backed cost correlation, index, equipment/material/pressure factors and annual operating assumptions.
- Re-run sensitivity response outputs after the target model passes validation.

## Corrective action

Phase 3 must not hard-code the empirical tie-line as a target-model answer. Implement the target thermodynamic functions with explicit diagnostics, then resolve the parameter/model failure before releasing a production flash result. Reference interpolation and balance calculations in this package are valid regression fixtures for interpolation/flow-balance code only.
