# Prompt 19 Build and Verification Report

**Build:** ENERGY-008 MATLAB reference calculation engine, revision 0.3.0-PROMPT19  
**Implementation stage:** Prompt 19  
**MATLAB runtime:** **NOT RUN** (MATLAB and GNU Octave unavailable in the build environment)  
**Physical flowsheet validation:** Not performed; Prompt 21 remains required.

## Completed

- Implemented calculation and validation modules under `MATLAB/` using the Prompt 18 common API contract.
- Added structured statuses, diagnostics, errors/failure codes, source provenance, version metadata and residual fields.
- Implemented ideal stoichiometric Route C reference and Route A shared reaction-core comparator.
- Retained Route B biomass-syngas as blocked, Route C turndown as linear reference scaling and DB-059 as power-shortfall arithmetic only.
- Implemented bounded pure-component property references, reaction enthalpy identities, exchanger/pump screening equations, SI/internal-unit conversion helpers, throughput sensitivity, datasheet/utility register exports and fail-closed environmental/economics modules.
- Added generic numerical primitives with history/refinement outputs. They are synthetic-test-only and do not enable process recycle or kinetics.
- Added run-specific CSV/JSON reporting, optional XLSX/PNG exports, logging and no-overwrite controls.
- Kept physical recycle, PFR kinetics, EOS flash, MeOH-water VLE/distillation, plant energy/entropy/exergy, actual utilities, certification MRV and plant economics blocked.

## Verification executed in the build environment

The following checks were actually executed using Python and file-level inspection, not MATLAB:

| Check | Result |
|---|---|
| Independent arithmetic recomputation from Prompt 17 fixture | PASS, 50 checks |
| Project tree / 55 manifest hashes / format and schema checks | PASS, 98 static checks |
| MATLAB runtime tests | NOT RUN |
| MATLAB startup smoke test | NOT RUN |
| Prompt 21 physical-model validation | NOT RUN / not in Prompt 19 scope |

The independent arithmetic audit reconstructs the fixture results from the versioned stoichiometric matrix, source property correlations and Prompt 17 screening assumptions. It includes separate matrix-driven nonzero R-02 and equivalent reaction-basis checks and a 45/50/55 t/day throughput sensitivity audit. It also exercises nonzero R-02 and algebraically equivalent reaction-column scaling to demonstrate why the calculation layer must read coefficients from the reaction register. The frozen molecular-weight mass residual is retained rather than balanced away. The reference test status does not imply that the 55-stream physical flowsheet is calculated.

The MATLAB unit-test suite contains 31 direct module/integration checks, including SI import/export conversions, matrix-driven stoichiometry with an R-02 nonzero unit case and equivalent reaction-basis scaling, versioned 45/50/55 t/day sensitivity recalculation, source-propagated enthalpy uncertainty, Route A/B/C status, DB-059 screening, physical recycle/environmental blockers, per-KPI environmental provenance gates and synthetic numerical primitives. These MATLAB test functions are prepared but not executed in this build environment.

## Important project state

- Route C is still a provisional working configuration; user route-gate approval is not evidenced.
- Gate 3 remains not frozen.
- 50 t/day is an illustrative ideal stoichiometric reference, not approved nameplate capacity.
- Unknown flow, composition, temperature, pressure, enthalpy, kij, kinetics, vendor performance, tariffs and cost values are not zero-filled.
- `MATLAB/results/` contains no generated run results because MATLAB was unavailable and no fake runtime output is created.

## Runtime instructions

After extracting the project, use MATLAB:

```matlab
run('MATLAB/START_HERE.m')
run(fullfile(ENERGY008_PROJECT_ROOT, 'MATLAB', 'tests', 'run_startup_smoke_test.m'));
tests = run_prompt19_tests(ENERGY008_PROJECT_ROOT);
R = ENERGY008_RUN; % START_HERE runs main after verifying the project manifest.
```

Record the exact MATLAB release, JVM availability and runtime test result before making a compatibility claim. SHA-256 verification requires an enabled JVM. No release minimum or add-on toolbox availability is verified by this build.
