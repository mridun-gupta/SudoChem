# Prompt 19 Handoff: MATLAB Implementation Contract

Prompt 18 delivers the project tree, root marker, `START_HERE.m`, configuration, data manifest, schema contracts, source snapshots, API module files and documentation. Startup resolves the project root without `pwd`, adds only `MATLAB/` to the path, locates required declared data, verifies SHA-256 and writes run logs. MATLAB runtime test status is NOT RUN because MATLAB and GNU Octave were unavailable in the build environment.

## Required Prompt 19 implementation order

1. **Verify target MATLAB release/toolboxes first.** Establish the actual release and JVM availability. Run `MATLAB/tests/run_startup_smoke_test.m` from a copied/extracted path while current folder is unrelated. Record exact release and results. Select solver/toolbox dependencies only after reviewing the numerical algorithms.
2. **Implement parsers and `input_validation.m`.** Read manifest-declared CSV/JSON/XLSX sources only. Check sheet names, exact headers, units, IDs, duplicates, ranges, component references, complete compositions, source metadata and schema IDs. Keep raw snapshots immutable.
3. **Implement `property_models.m`.** Add source-specific pure component models and strict range gates. Keep mixture EOS/BIP, MeOH-water VLE, process-state transport and KOH electrolyte properties BLOCKED until sourced and validated.
4. **Implement reaction/material model.** Reproduce the Prompt 17 18-case fixture and stoichiometric/element closure before enabling process recycle. Keep the physical PFR blocked until catalyst-matched kinetics are available; do not promote the ideal reference block to plant prediction.
5. **Implement energy and entropy/exergy.** Preserve thermochemical reference states; do not call standard reaction enthalpy an equipment duty. Keep plant closure blocked until stream enthalpy/entropy states and utility conditions exist.
6. **Implement equipment and utilities.** Size only from accepted state points and actual vendor/code data. Do not create compressor power, HX-301 rating, electrolyser maps, recycle or buffer values from illustrative hand examples.
7. **Implement control, economics and sensitivity.** Use Prompt 15 state/event definitions. Keep the conceptual control model distinct from PLC/SIS certification. Economics remains blocked pending site tariffs, grid factors, quotes and approved financial inputs.
8. **Implement `validation_checks.m` and reporting.** A solver convergence flag is necessary but insufficient. Store residuals, tolerances, provenance, source hashes, warnings, errors and failure codes. Preserve unrounded values and separate presentation rounding.

## Frozen references to preserve

- `data/raw/ENERGY008_Numerical_Methods.md` and `ENERGY008_Convergence_and_Failure_Standards.xlsx` (Prompt 16).
- `data/raw/ENERGY008_Hand_Calculation_Report.md` and all raw design/property/reaction/stream/schema workbooks (earlier phases and Prompt 17).
- `data/reference/ENERGY008_Benchmark_Fixture.json` (Prompt 17 independent reference).
- `data/schemas/ENERGY008_Benchmark_Fixture_Schema.json` and `ENERGY008_Data_Schema_Contract.json`.

## Mandatory non-negotiable limits

- Route C remains a working route; route gate approval is not evidenced and G3 is not frozen.
- 50 t/day is only an illustrative ideal stoichiometric component-equivalent reference.
- Null does not mean zero.
- Physical S-209 recycle/S-207 purge, PFR kinetics, EOS/flash, MeOH-water VLE, distillation, plant energy, plant entropy/exergy, compressor maps and actual equipment ratings stay BLOCKED until inputs are validated.
- No hidden defaults, arbitrary `kij=0`, generic kinetic coefficients, forced balance streams, fabricated vendor data, or silent extrapolation.
- Do not overwrite the raw dataset or previous run outputs.


## Prompt 19 mandatory data-ingestion gate

Implement `input_validation.m` before enabling any other module. It must load the current project manifest, parse only its declared formats, and validate every consumed dataset against its `schema_id` and source version. At minimum: required sheets/headers/columns; unit labels and bases; missing-value/null semantics; duplicate primary IDs; numeric/physical and model validity ranges; component/reaction/stream/equipment/utility/scenario/KPI foreign keys; C/H/O element balance and independent reaction rank; composition basis and sum-to-one only when complete; all source/provenance/approval metadata; and schema/version/hash consistency. Do not treat the prior Prompt 5 manifest as an instruction to search historical data outside the current allow-listed project roots.

The source-only `START_HERE.m` smoke test is distinct from semantic process-data validation. Passing startup must not enable `calculation_engine_enabled` or imply any process model is executable.


Prompt 15 start/stop sequence, mode matrix, disturbance-response matrix, automation-state diagram and editable PID sketch are archived under `data/raw/prompt15_control/`; treat them as conceptual controls inputs, not certified operating procedures or SIS logic.

The Prompt 16 top-level, solver and automation flowcharts are archived under `data/raw/prompt16_algorithms/`. Prompt 17's `ENERGY008_Manual_Calculation_Workbook.xlsx` and `ENERGY008_Independent_Checks.csv` are archived under `data/raw/prompt17_manual_calculations/`. Preserve their hashes and IDs during implementation; do not treat the ideal reference fixture as a solved plant case.
