# ENERGY-008 Prompt 22 Handoff to Prompt 23

**Date:** 02 November 2026  
**Source:** Prompt 22 sensitivity, uncertainty and proxy optimisation screen  
**Design status:** Route C provisional; G3 design basis Rev 0.1-DRAFT  
**Model status:** Physical process model remains unvalidated; MATLAB/Octave runtime not executed.

## Prompt 22 completion status

- 12 independent OAT sensitivity studies completed at SCREENING ONLY level.
- 36 OAT parameter points and 156 output-metric records.
- 1,000 deterministic Latin Hypercube samples across 8 independent scenario dimensions.
- 11 sampled non-dominated points for electricity-only cost vs electricity-related emissions proxy.
- Conditional P05/P50/P95 scenario intervals, Spearman rank associations and explicit uncertainty blockers documented.
- Alternative C/A compared only on an ideal common downstream core; Alternative B remains BLOCKED.
- No validated operating window or physical process optimum recommended.

## Permitted reference and screening results

At 50 t/day ideal stoichiometric reference, 55 kWh/kg H2, ₹5/kWh, electricity CI 0.40 kg CO2e/kWh, 300 operating days/year and total water intensity 50 L/kg H2:
- Electrolyser intensity: 10.3808 kWh/kg MeOH.
- Electrolyser electric load: 21.6266 MW.
- Electricity-only cost contribution: ₹51.9039/kg MeOH.
- Electricity-related emissions: 4.1523 kg CO2e/kg MeOH.
- Total water scenario: 471.854 m3/on-stream day.
- Annual electrolysis electricity: 155.712 GWh/year.

All are SCREENING ONLY except the underlying ideal stoichiometric component flows, which remain reference arithmetic only. The 50 t/day case is not an approved nameplate or demonstrated process throughput.

## Uncertainty outputs

LHS conditional P05/P50/P95:
- Specific electricity: 9.440 / 10.179 / 11.037 kWh/kg MeOH.
- Electricity-only variable cost contribution: ₹33.14 / ₹55.96 / ₹79.78 per kg MeOH.
- Electricity-related emissions: 0.878 / 4.329 / 7.833 kg CO2e/kg MeOH.
- Electrolyser load: 18.679 / 21.217 / 23.930 MW.
- Annual methanol: 13,936 / 15,934 / 17,960 t/y.
- Annual electricity: 139.332 / 162.257 / 187.285 GWh/y.
- Total water: 315.604 / 491.296 / 684.572 m3/on-stream day.

The LHS inputs are assumed independent uniform ranges. These quantiles are not empirical confidence intervals or predictions.

## What Prompt 23 may use

1. Use stoichiometric reference flows as theoretical lower bounds only.
2. Use the 12 OAT studies and LHS as explicitly labelled screening sensitivity evidence.
3. Use the 11-point frontier only as a proxy cost/emissions trade-off illustration.
4. Keep the Route A common core separate from upstream source/capture performance.
5. Keep Route B numeric fields null/BLOCKED.
6. Do not report full CAPEX, OPEX, levelised methanol cost, full energy/exergy efficiency, emissions compliance, route ranking, validated product purity or safe operating limits.
7. Do not turn 7 MPa(a)/250 °C draft anchors into operating limits.
8. State that no validated operating window or selected optimum can be recommended until the physical process model and engineering constraints are closed.

## Mandatory data/model gates still open

- G3 route/design-basis approval and site selection.
- Actual source gas assays, carbon origin, impurities and supply continuity.
- Electrolyser OEM performance map, BOP and compression boundary.
- Catalyst-matched validated kinetics; PFR model and reactor heat removal.
- PR78 binary interaction parameters and property/phase validation.
- Methanol-water VLE, flash, physical recycle/purge and compressor duty.
- Plant-wide mass, energy, entropy and exergy closure.
- Equipment vendor limits, utility capacity, renewable availability and water-source availability.
- CAPEX/OPEX quotations, cost indices and financial assumptions.
- MATLAB runtime, GUI regression and independent runtime validation.
- Full route-specific evaluation of Alternative 1 and Alternative 2.

## Files delivered

- `ENERGY008_Sensitivity_Plan.xlsx`
- `ENERGY008_Sensitivity_Results.xlsx`
- `ENERGY008_Uncertainty_Analysis.xlsx`
- `ENERGY008_Alternative_Comparison.xlsx`
- `ENERGY008_Operating_Window_and_Recommendation.md`
- `Plots/` (13 labelled PNG plots)
- `Prompt22_Calculation_Method.py`
- `Reproducibility/` (LHS sample and statistics CSV/JSON)
- `Test_Logs/` (screening validation logs)
