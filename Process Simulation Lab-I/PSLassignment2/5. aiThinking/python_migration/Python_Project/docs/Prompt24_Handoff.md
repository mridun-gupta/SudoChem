# Prompt 24 handoff | ENERGY-008 staged Python migration

## Handoff status

- Python package `energy008-python` 0.1.0 exists under `Python/`.
- CPython 3.13.5 runtime executed successfully on Linux x86_64.
- Final Python test suite: **23 passed in 1.84 s** after editable package installation; final transcript is `test_logs/pytest_final.log`.
- Six actual CLI run directories exist: four controlled case definitions plus two installed-console-entry-point smoke runs. Each contains traceable JSON/log output; reference cases also contain CSV ledgers and PNG plots.
- Base Route C and Route A common-core cases are SCREENING_ONLY; Route B is BLOCKED; Route C 25 t/day is SCREENING_ONLY.
- Python-vs-frozen-Prompt-17-hand-fixture comparison: PASS within the fixture's original absolute tolerances for 18 numeric parity rows. This is independent hand-fixture comparison, not MATLAB runtime parity.
- MATLAB-to-Python runtime parity: NOT RUN. No MATLAB/Octave runtime result evidence was available.
- Migration classification: PARTIAL / staged. This is not a full physical process-model migration.

## Delivered interfaces and source

Core package `src/energy008/` includes:

- `config.py`, `validation.py`, `status.py`: configuration, validation, result/status contract.
- `kpis.py`, `economics.py`: ideal material KPIs and a capital-recovery-factor identity; full project economics remain blocked.
- `units.py`: named unit conversions.
- `reactions.py`, `balances.py`: reaction matrix/extents and ideal component/element reference ledger.
- `properties.py`: CO2 Shomate and pure methanol latent reference functions; unsupported property methods fail closed.
- `energy.py`: standard reaction enthalpy identities and reference rates.
- `equipment.py`: Prompt 17 screening HX/pump arithmetic and datasheet status ledger.
- `blocked_models.py`: explicit blocked interfaces for entropy/exergy, physical utilities, economics, environmental KPIs, PFR and physical recycle/purge.
- `sensitivity.py`, `numerics.py`: throughput reference study and generic synthetic-only LHS/nonlinear solver primitives.
- `engine.py`, `exports.py`, `cli.py`: GUI-independent orchestration and traceable run export.

No Python GUI is included. A future UI is an extension only; it must call the GUI-independent `engine.run_case()` API and must not duplicate equations in callbacks.

## Key engineering boundaries

- Route C is provisional and G3 Rev 0.1-DRAFT; 50 t/day is an ideal stoichiometric component-equivalent, not approved capacity.
- R-01/R-02/E-01 remain the only independent reaction vectors; R-02 extent zero is an explicit reference assumption, not evidence of zero RWGS in a reactor.
- PR78 mixture, methanol-water VLE, catalyst-matched PFR, S-209/S-207 physical recycle/purge, plant energy/exergy, OEM utilities, full economics and environmental MRV remain BLOCKED.
- Missing values remain None/null. The generic SciPy nonlinear solver is a synthetic test primitive only.
- No CoolProp, Cantera, BioSTEAM, DWSIM, REFPROP or external property databases are included in runtime dependencies or distributed.

## Executed run IDs

| Run ID | Case | Result status |
|---|---|---|
| `20261102T044214Z_e2e24c8e` | Route C, 50 t/day ideal reference | SCREENING_ONLY |
| `20261102T044216Z_e06f39f8` | Route A, 50 t/day shared ideal core only | SCREENING_ONLY |
| `20261102T044218Z_d837f600` | Route B, biomass syngas alternative | BLOCKED |
| `20261102T044220Z_b2651e98` | Route C, 25 t/day turndown screen | SCREENING_ONLY |
| `20261102T044801Z_1c9ea2b6` | Installed CLI Route C base smoke run | SCREENING_ONLY |
| `20261102T045018Z_bd0fd1f9` | Installed CLI Route C turndown smoke run | SCREENING_ONLY |

## Prompt 24 required actions

1. Install using `requirements.lock` on the exact supported runtime or create a separately resolved lock for another platform; run `python -m pytest -q`.
2. Execute the MATLAB Prompt 19 suite in a recorded target MATLAB release/toolbox environment and export the same base/alternative/turndown case outputs.
3. Create a machine-readable MATLAB/Python output comparison. For nonzero expected values report absolute and relative deviation; for zero targets report absolute deviation only.
4. Review every MATLAB/Python equation and unit pair independently before accepting parity. Shared input fixtures do not make the implementations independent.
5. Keep the Python interfaces for PR78, VLE, reactor kinetics, recycle, exergy, site utilities, economics and MRV blocked until original source parameters and independent validation datasets exist.
6. Only after the above, plan a second-stage physical-model migration and any optional property-package adapter.

## Source and package traceability

See `docs/MATLAB_to_Python_Mapping.xlsx`, `docs/MATLAB_to_Python_Migration.md`, `docs/Unit_and_Data_Contract.md`, `docs/Library_Assessment.md`, `docs/Python_Test_and_Parity_Report.md`, `data/source_manifest.json`, `test_logs/` and `results/`.
