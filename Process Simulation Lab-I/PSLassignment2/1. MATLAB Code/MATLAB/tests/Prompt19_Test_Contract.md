# Prompt 19 Test Contract

## Test layers

1. **Static project/data integrity** (`tests/check_project_static.py`, Python): verifies project files, version/config gates, explicit manifest file existence, SHA-256, formats, workbook sheets, CSV columns and JSON/XML syntax. It does not parse/execute MATLAB.
2. **Independent arithmetic reproduction** (`tests/check_prompt19_regression.py`, Python): computes stoichiometric material flows, C/H/O closure, retained mass residual, reference thermochemistry, HX/pump examples, throughput scaling and DB-059 arithmetic from Prompt 17 input data. It does not call MATLAB.
3. **MATLAB module tests** (`MATLAB/run_prompt19_tests.m` (wrapper) and `MATLAB/tests/execute_prompt19_test_suite.m` (suite)): tests module outputs, status propagation, input/property gates, 18 fixture cases, explicit synthetic fixed-point/RK4 utilities, independently gated environmental KPIs, and synthetic input-only environmental/economic formulas. The suite currently defines 31 direct checks, including nonzero R-02 stoichiometric closure, equivalent reaction-column scaling, a versioned sensitivity-plan execution path, and source-propagated thermochemistry uncertainty. MATLAB runtime remains `NOT RUN` in the current build environment.
4. **MATLAB startup smoke test** (`MATLAB/tests/run_startup_smoke_test.m`): checks root discovery and controlled path setup from a temporary unrelated working directory. Runtime remains `NOT RUN` in the current build environment.
5. **Prompt 21 verification and validation**: independent physical model validation, property regression, conservation/energy/exergy closure, sensitivity, convergence and defect correction. Not part of Prompt 19 and not claimed complete.

## Prompt 17 fixture IDs

`TC-01` to `TC-12` are numeric reference calculations. `TC-13` to `TC-18` are explicit reject/blocker conditions. The expected values/tolerances reside only in `data/reference/ENERGY008_Benchmark_Fixture.json`; calculations are performed by the MATLAB modules or the independent Python audit. Expected outputs are not copied into run results as if they were calculated.

## Synthetic test data

The MATLAB unit-test harness supplies explicitly labelled synthetic test-only data for generic numerical utilities, environmental KPI formula mechanics and economics formula mechanics. These values are created inside a test request, are not persisted into project case files, and do not alter the null default project templates. They are not actual project utility or cost inputs and must never be used as process results.

## Acceptance/status rules

- Any numeric reference comparison outside its fixture tolerance is a test failure.
- Missing process data must retain a null value and a `BLOCKED` reason.
- Invalid physical inputs, invalid dimensions, negative physical rates and negative entropy generation are failures, not clipping instructions.
- A successful generic solver test does not prove process recycle/PFR convergence.
- No Prompt 19 test result is a physical flowsheet validation claim.
