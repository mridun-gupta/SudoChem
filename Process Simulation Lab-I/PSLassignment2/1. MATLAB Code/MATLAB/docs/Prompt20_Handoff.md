# Prompt 20 Handoff — Prompt 19 Calculation Engine

The Prompt 19 calculation engine is implemented under `MATLAB/` and uses common `(modelInput, request, options)` function contracts. The default C base reference reproduces Prompt 17's ideal stoichiometric benchmark when executed in MATLAB. Route A is a same-core stoichiometric comparator only; Route B is BLOCKED; Route C turndown and DB-059 are screening-only.

The engine returns structured status, values, units, input versions, residuals, warnings, errors, failure codes, provenance and diagnostics. It exports only calculated run results to a unique `MATLAB/results/<run_id>/` folder. Existing runs are preserved.

**GUI callbacks** must call engine module interfaces; they must not contain process equations, hidden global process inputs, file discovery or numerical solver loops. The UI should show `REFERENCE_ONLY`, `SCREENING_ONLY`, `BLOCKED`, `FAILED` and `NOT_RUN` distinctly and must not display a blocked quantity as zero. Keep the GUI as a presentation/input layer separate from the engine.

Prompt 20 may show case definitions, material reference flows, stoichiometric closure, reference enthalpy checks, equipment screening examples, utility/datasheet status tables, scenario status and diagnostic/blocker detail. It may not present the model as a validated physical flowsheet.

**Physical flowsheet validated:** false. PR78 flash, methanol-water VLE, R-301 kinetic PFR, S-209 recycle/S-207 purge, plant energy/entropy/exergy, actual utilities, environmental certification/MRV and economics remain blocked. MATLAB runtime is `NOT RUN`; the target MATLAB release/toolbox availability must be checked by executing the included tests. Prompt 21 remains the independent verification/validation gate.
