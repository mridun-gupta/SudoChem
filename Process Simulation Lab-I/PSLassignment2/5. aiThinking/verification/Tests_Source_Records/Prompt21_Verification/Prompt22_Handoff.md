# ENERGY-008 Prompt 22 Handoff

**Date:** 02 November 2026  
**Source phase:** Prompt 21 independent verification  
**Design status:** Route C remains provisional; G3 design basis Rev 0.1-DRAFT.

## Verification disposition

- 27 assignment topics: 0 PASS, 2 FAIL, 6 BLOCKED, 6 NOT RUN, 13 SCREENING ONLY.
- 82 curated test-register records: 40 PASS, 2 FAIL, 14 BLOCKED, 19 NOT RUN, 7 SCREENING ONLY.
- Additional independent Python audit: 115 records, 80 PASS, 27 SCREENING ONLY, 2 FAIL, 1 BLOCKED, 5 NOT RUN.
- Static project/configuration check: PASS (100 checks; 55 hashed datasets).
- Independent arithmetic regression: PASS (50 checks).
- GUI source-contract check: PASS (80 checks).
- MATLAB/Octave runtime: NOT RUN. No MATLAB GUI launch, screenshots, actual solver output or GUI export examples exist.

A PASS in the independent Python audit applies only to the declared Python arithmetic/source/data assertion. Some PASS records assert that unsupported physical values correctly remain null/BLOCKED. They are not physical model validation.

## Permitted reference/screening outputs

The 50 t/day ideal Route C stoichiometric reference (1560.4568 kmol/day methanol-equivalent; 68,674.9225 kg/day CO₂; 9,437.0808 kg/day H₂; 84,336.1973 kg/day electrolyser water; 74,899.1165 kg/day O₂) may be cited only as ideal stoichiometric reference arithmetic. The standard-state identities R-01 = −131.82 kJ/mol and E-01 = +571.66 kJ/mol agree with values independently derived using NIST Chemistry WebBook formation enthalpies. The CO₂ pure ideal-gas Shomate duty and pure methanol latent duty are reference properties, not plant duties. HX area and pump power are illustrative with assumed data. The 25 t/day and DB-059 two-hour values are linear screens only.

## Do not use for final optimisation conclusions

- Route A is a common ideal downstream core only; it is not a complete industrial CO₂ route evaluation.
- Route B biomass syngas remains BLOCKED. The assignment requirement for two evaluated alternatives is FAIL.
- Sensitivity analysis remains FAIL: one throughput variable only, no six-variable/multivariable coverage.
- Physical recycle/purge, PR78 flash, methanol-water VLE, PFR kinetics, plant mass/energy/entropy/exergy closure, actual equipment/utility/environmental/economic results remain BLOCKED.
- Synthetic compressor, entropy/exergy, KPI, recycle and economics primitive checks are not plant results.
- Do not claim MATLAB/GUI runtime testing, actual output exports, screenshots or physical model validation.

## Required next steps

1. Execute `MATLAB/tests/run_startup_smoke_test.m` and the 31-check Prompt 19 MATLAB suite in the supported MATLAB release.
2. Launch `MATLAB/run_gui.m`; test Run/Reset, invalid inputs, missing data, blocked cases, tables, plots, detailed errors and repeated runs. Retain screenshots, logs, and actual exported files.
3. Independently validate the physical property and kinetic models against external data that were not used to fit the models.
4. Obtain required site/vendor/feed/product data and solve the physical process path including recycle, purge and utilities.
5. Evaluate Alt 2 and all alternatives on the same complete basis. Expand sensitivity to at least six justified parameters plus a multivariable method.
6. Complete mass/energy/entropy/exergy and dimensional checks with uncertainty, physical bounds, equipment margins and product-quality checks.
7. Only verified or explicitly screening outputs may feed any Prompt 22 optimisation discussion. Retain every unresolved status and source link.

## Evidence files

- `ENERGY008_Verification_Matrix.xlsx`
- `ENERGY008_Independent_Comparison.xlsx`
- `ENERGY008_Unit_Integration_Test_Report.md`
- `ENERGY008_Defect_and_Correction_Log.csv`
- `ENERGY008_Test_Logs/`
