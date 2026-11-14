# CPS-22 Phase 2 Handoff

**Phase:** 2 of 5  
**Date:** 26 October 2026  
**Status:** Partial calculations delivered; formal Phase 2 acceptance gate remains **OPEN / NOT PASSED** because the NRTL–SRK fit failed and energy/economic results are unsupported.

## Decisions preserved from Phase 1

- Mixture: ethanol (1) + water (2).
- Target model: liquid NRTL activity coefficients + vapour SRK fugacity coefficients (hybrid gamma-phi).
- Proposed baseline process: one feed heater plus a single equilibrium flash separator; no reaction, recycle, pressure drop or shaft work for the first case.
- Feed: 100 kmol/h and z_ethanol=0.5 are assumptions, not experimental inputs.
- Pressure: 1.5 MPa was selected to match the published experimental isobar.
- Internal unit system: SI.
- Alternative model: literature PRSV-Wong-Sandler comparison at the azeotrope.

## Results suitable for passing to Phase 3

The experimental Table 6 dataset is included as structured CSV with 99 values across 100, 1500 and 2000 kPa. At 1.5 MPa and z_ethanol=0.5, empirical interpolation gives bubble T=443.3875 K, dew T=446.8632 K and selected midpoint T0=445.125329 K. Interpolated tie-line x_ethanol=0.38848026, y_ethanol=0.54824013, beta=0.69804600; L=30.19540 kmol/h and V=69.80460 kmol/h at 100 kmol/h feed. Total and component lever-rule balances close algebraically.

These values are accepted only as a **reference-data interpolation fixture**. They are not an accepted NRTL–SRK flash prediction.

## Model acceptance finding

The published Aspen/VLE-IG NRTL parameter candidate does not reproduce the high-pressure table adequately when extrapolated to around 445 K. A least-squares fit to 1500 kPa data drove the SRK kij parameter to an imposed diagnostic guardrail (not a literature-validated physical bound); RMS log-fugacity residual remained 0.04086 on training and 0.14344 on the 2000 kPa held-pressure data. The result is not accepted. The default model solver also returned a library success flag with non-negligible thermodynamic/material residuals and was rejected. Do not freeze this fit as a parameter source.

## Engineering outputs

- Reference-based mass balance: populated and closed algebraically.
- EOS intermediate properties / Poynting factors: calculated with explicit screening-only flags.
- Preliminary gas/liquid loads and separator screen: populated with provisional K=0.11 m/s and modified-Rackett volumes; not mechanical design.
- Energy balance / process duty: blocked; use a consistent enthalpy package before reporting Q.
- Utility consumption: blocked pending duty and utility state definitions.
- Numeric CAPEX/OPEX: not computed; no frozen cost correlation, index, pressure/material factors or verified equipment design.
- Five sensitivity studies: Table 6 interpolation (T, P, z, F) plus SRK k_ij residual diagnostic. The k_ij study is not a validated process sensitivity.
- Alternative-model comparison: reported experimental vs PRSV and PRSV-Wong-Sandler azeotropic values at 1.5 MPa, as published by the reference paper. This is a limited literature benchmark, not a new EOS implementation.

## Files Phase 3 must receive

1. `CPS-22_Core_Calculations.md`
2. `CPS-22_Equation_and_Method_Details.md`
3. `CPS-22_Base_Case_Inputs.csv`
4. `CPS-22_Base_Case_Results.csv`
5. `CPS-22_Intermediate_Thermodynamic_Results.csv`
6. `CPS-22_Material_Energy_Balance.csv`
7. `CPS-22_Equipment_Design_Results.csv`
8. `CPS-22_Utility_Economics_Results.csv`
9. `CPS-22_Sensitivity_Results.csv`
10. `CPS-22_Validation_Reference_Data.csv`
11. `CPS-22_Model_Comparison.csv`
12. `CPS-22_Calculation_Diagnostics.md`
13. `CPS-22_Phase2_Source_Register.csv`
14. `CPS-22_Phase2_Reproduction.py`
15. `plots/P2_Fig1_Experimental_Txy.png`
16. `plots/P2_Fig2_Temperature_Sensitivity.png`
17. `plots/P2_Fig3_Composition_Sensitivity.png`
18. `plots/P2_Fig4_Flow_Sensitivity.png`
19. `plots/P2_Fig5_Kij_Diagnostic.png`
20. `plots/P2_Fig6_Pressure_Sensitivity.png`

## Phase 3 entry instructions

- First implement unit tests for NRTL, SRK, Antoine, Poynting, composition normalization, and root selection.
- Keep the exact experimental CSV separate from model parameter sources.
- Reproduce the empirical interpolation and component-flow fixture independently from the target model.
- Resolve parameter conventions and fit on a declared calibration subset; do not report a successful model solely because a solver returns an exit flag.
- Hold the 2000 kPa data out during fitting and report pointwise residuals with source uncertainty.
- Add a second independent high-pressure source if possible.
- Implement the enthalpy package and validate its reference-state alignment before calculating heat duty.
- Keep equipment/utility/economic results flagged as preliminary/blocked until correlations and property data are frozen.

## Phase 2 result summary

The experimental basis, reference interpolation, material-balance fixture, property-model equations, diagnostic regression, preliminary separator screen, five sensitivity records, alternative-model literature comparison, and diagnostics are packaged. The target NRTL–SRK model is **not validated**. Phase 3 may proceed with software scaffolding and tests, but must resolve the documented thermodynamic parameter/model failure before accepting production simulation outputs.
