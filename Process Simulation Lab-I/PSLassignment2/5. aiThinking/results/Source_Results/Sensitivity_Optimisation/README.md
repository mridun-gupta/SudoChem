# ENERGY-008 Prompt 22 Deliverables

This folder contains the sensitivity/optimisation screening package.

## Main workbooks and report
- `ENERGY008_Sensitivity_Plan.xlsx`: 12 OAT studies, ranges, fixed inputs, constraints, method, blocked variables and sources.
- `ENERGY008_Sensitivity_Results.xlsx`: 156 OAT result records, 1,000 LHS rows, proxy Pareto points, formula audit and plot register.
- `ENERGY008_Uncertainty_Analysis.xlsx`: input distributions, conditional intervals, Spearman rankings and unquantified blockers.
- `ENERGY008_Alternative_Comparison.xlsx`: common product/boundary comparison for Route C, Route A and blocked Route B.
- `ENERGY008_Operating_Window_and_Recommendation.md`: technical report and no-operating-window recommendation.
- `ENERGY008_Prompt22_Handoff.md`: Prompt 23 handoff.

## Plots
`Plots/` contains 13 labelled sensitivity and multivariable screening plots. Every chart is marked SCREENING ONLY or EXPLORATORY ONLY.

## Reproducibility
- `Prompt22_Calculation_Method.py` reproduces the baseline, LHS sample, conditional output intervals, rank associations and sampled Pareto screen.
- `Reproducibility/` contains the generated numerical CSV/JSON data.
- `Test_Logs/` contains the independent arithmetic, LHS-strata and spreadsheet formula scan records.

## Engineering status
No MATLAB or GNU Octave runtime was available. No physical process solver, validated process model, full CAPEX/OPEX, levelised methanol cost or feasible operating window has been produced. Numeric outputs are limited to ideal stoichiometric or explicitly assumed screening calculations.
