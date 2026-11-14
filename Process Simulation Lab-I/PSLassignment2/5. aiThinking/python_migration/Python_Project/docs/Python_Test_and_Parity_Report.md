# ENERGY-008 Python migration | runtime test and parity report

**Package:** `energy008-python` 0.1.0  
**Execution date:** 2026-11-02 (UTC run metadata is retained in each export)  
**Runtime tested:** CPython 3.13.5, Linux x86_64, glibc 2.41  
**MATLAB runtime:** NOT RUN (MATLAB and GNU Octave were not available)  
**Migration classification:** PARTIAL / reference and screening scope only

## 1. Executed verification summary

The following commands were executed from this directory with `PYTHONPATH=src`:

```bash
python -m pytest -q
python -m energy008.cli --results-dir results
python -m energy008.cli --case-id A-INDCO2-REH2-ALK-REF-50TPD --results-dir results
python -m energy008.cli --case-id B-BIOMASS-SYNGAS-50TPD --results-dir results
python -m energy008.cli --case-id C-BIOCO2-REH2-ALK-TURNDOWN-25TPD --results-dir results
```

**Observed final test result:** `23 passed in 1.84s` after editable installation. Earlier source-tree and editable-package runs also passed (20 tests before the relocation/unit/reaction tests were added). Final transcript: `test_logs/pytest_final.log`. Editable installation built and installed `energy008-python-0.1.0`; the `energy008` console entry point completed an additional turndown smoke run.

## 2. Actual case executions

| Case | Actual run ID | Overall status | Interpretation |
|---|---|---|---|
| Route C, ideal 50 t/day component-equivalent | `20261102T044214Z_e2e24c8e` | SCREENING_ONLY | Stoichiometric reaction-block reference; property/energy/equipment examples are screening-only; plant models remain blocked. |
| Route A, 50 t/day | `20261102T044216Z_e06f39f8` | SCREENING_ONLY | Same ideal common downstream reaction core only. Industrial CO2 capture, purification and route-specific utilities were not modelled. |
| Route B, biomass syngas, 50 t/day | `20261102T044218Z_d837f600` | BLOCKED | Correct fail-closed result; no biomass feed, gasification yields or cleanup performance invented. |
| Route C, 25 t/day turndown | `20261102T044220Z_b2651e98` | SCREENING_ONLY | Linear ideal stoichiometric scaling only; not a validated electrolyser/reactor turndown point. |
| Installed CLI smoke, Route C 50 t/day | `20261102T044801Z_1c9ea2b6` | SCREENING_ONLY | Run after successful editable package installation; confirms console entry point and package-relative data discovery. |
| Installed CLI smoke, Route C 25 t/day | `20261102T045018Z_bd0fd1f9` | SCREENING_ONLY | Final installed console-entry-point smoke run for the turndown case. |

Each run folder under `results/` contains `results.json`, `run.log`; reference/screening runs also contain CSV ledgers and a PNG stoichiometric ledger plot. Six run directories represent four unique controlled case IDs plus two installed-entry-point smoke runs. The JSON includes run ID, timestamp, case ID, model version, data version, package version, Python/platform metadata, assumptions and per-module statuses.

## 3. Frozen Prompt 17 fixture parity

Unrounded Python outputs were compared with `data/ENERGY008_Benchmark_Fixture.json` using the absolute tolerances stored in that fixture. The Python tests do not compare a function against itself; the expected values come from the separate Prompt 17 hand-calculation package.

| Metric | Fixture expected | Python actual | Absolute deviation | Relative deviation |
|---|---:|---:|---:|---:|
| Methanol | 1,560.4567769077364 kmol/day | 1,560.4567769077366 | 2.27e-13 | 1.46e-16 |
| CO2 | 1,560.4567769077364 kmol/day | 1,560.4567769077366 | 2.27e-13 | 1.46e-16 |
| H2 | 4,681.370330723209 kmol/day | 4,681.370330723210 | 9.09e-13 | 1.94e-16 |
| CO2 mass | 68,674.92252332103 kg/day | 68,674.92252332103 | 0 | 0 |
| H2 mass | 9,437.080822298303 kg/day | 9,437.080822298305 | 1.82e-12 | 1.93e-16 |
| Electrolyser water | 84,336.19729167121 kg/day | 84,336.19729167124 | 2.91e-11 | 3.45e-16 |
| O2 coproduct | 74,899.11646937291 kg/day | 74,899.11646937292 | 1.46e-11 | 1.94e-16 |
| Rounded-MW mass residual | -0.06241827107442077 kg/day | -0.06241827106379105 | 1.06e-11 | 1.70e-10 |
| CO2 sensible duty | 168.8542898861549 kW | 168.8542898861549 | 0 | 0 |
| MeOH latent reference duty | 677.0827824210255 kW | 677.0827824210255 | 0 | 0 |
| Illustrative HX area | 56.28476329538497 m2 | 56.28476329538497 | 0 | 0 |
| W-201 pump shaft power | 0.6837430300680949 kW | 0.683743030068095 | 1.11e-16 | 1.62e-16 |

All 18 numerical parity rows in `docs/MATLAB_to_Python_Mapping.xlsx` passed their frozen absolute tolerance. For zero elemental residual targets, relative deviation is deliberately reported as N/A and only the absolute tolerance is evaluated. The small, nonzero rounded-MW mass residual is retained rather than forced to zero.

## 4. Additional status and edge-case tests

The final suite verifies:

- Alternative 1 Route A has matching ideal common-core stoichiometric flow values, but no industrial capture plant calculation.
- Alternative 2 Route B returns BLOCKED for input and material balance.
- 25 t/day Route C turndown scales the ideal reference component flows by 0.5 and retains SCREENING_ONLY status.
- Negative, zero, NaN and infinite throughput are rejected.
- Negative R-02 extent is rejected.
- Missing data folder raises `ENERGY008:DataMissing`.
- CO2 Shomate and methanol latent correlations fail outside their encoded validity ranges.
- PR78, methanol-water VLE, physical recycle, PFR reactor, project economics and plant entropy/exergy remain BLOCKED.
- Negative entropy generation is retained and diagnosed as FAILED, not clipped to zero.
- Capital-recovery-factor identity and zero-rate limit are checked.
- Latin-hypercube samples are deterministic for a fixed seed and remain within bounds.
- A synthetic nonlinear solver test is labelled `CONVERGED_SYNTHETIC_ONLY` and not physical evidence.
- Data discovery is independent of the current working directory and remains correct after copying/extracting the `src/` and `data/` trees into a different directory.
- Explicit day/second and kmol/day-to-mol/second conversions, density-required kg/h-to-m3/s conversion, and the exact three-vector reaction matrix (no independent CO hydrogenation vector).
- Result exports include traceability metadata and do not overwrite existing output directories.

## 5. Environment caveat

The shared build image had a pre-existing, unrelated `moviepy 2.2.1` package requiring `Pillow<12`, while the tested Matplotlib environment contains `Pillow 12.3.0`. `moviepy` is not listed in `requirements.lock`, is not imported by this project and is not part of the application environment. The project installation instructions deliberately use a fresh virtual environment. `test_logs/pip_check.log` preserves the global environment warning; no claim is made that the shared image as a whole is dependency-conflict-free.

## 6. MATLAB parity status

**MATLAB-to-Python runtime parity is NOT RUN.** The prior project has MATLAB source and 31 MATLAB test functions prepared, but there is no MATLAB or GNU Octave execution transcript or MATLAB-generated result file in this migration build. A Python-vs-hand-fixture pass is not a MATLAB-vs-Python pass. Prompt 24 must run the MATLAB test suite in the target MATLAB release, export the same case outputs, and compare those results to this Python release.

## 7. Physical model scope not migrated

The following remain BLOCKED or incomplete, not silently replaced by a library default:

- PR78 high-pressure mixture implementation: active binary interaction data/mixing-rule specification and independent validation are incomplete.
- Methanol-water Wilson/NRTL VLE/distillation: fitted and validated parameter set absent.
- R-301 PFR: catalyst-matched kinetics, parameter units/range, catalyst geometry and thermal boundary absent.
- Physical recycle S-209 and purge S-207: physical stream states, inerts, separator flash and purge criterion absent.
- Plant energy, entropy and exergy closure: physical states, heat/work boundaries and dead-state environment absent.
- ALK OEM performance, compressor/pump duty, utilities, dynamic controls and equipment rating: vendor/site data absent.
- Project CAPEX/OPEX/LCOM, environmental MRV and certified emissions intensity: approved cost and environmental boundaries/data absent.

No physical conversion, reactor size, compressor power, distillation duty, plant efficiency, LCOM or operating window is produced by this migration release.

## 8. Reproducibility files

- `requirements.lock`: exact pinned dependencies for the tested CPython 3.13.5 Linux environment; it is not a cross-platform hash lock.
- `data/source_manifest.json`: SHA-256 for the 13 copied JSON inputs and corresponding controlled source files; final check is recorded in `test_logs/source_manifest_verification.log`.
- `test_logs/pytest_runtime.log`: real pytest execution transcript from source-tree `PYTHONPATH=src` execution.
- `test_logs/pytest_final.log`: final 23-test run after editable installation.
- `test_logs/run_installed_cli_final.log`: real execution of the installed `energy008` console entry point for the turndown case.
- `test_logs/pip_check.log`: environment-wide dependency check; contains the unrelated shared-image `moviepy`/Pillow conflict described above.
- `test_logs/runtime_environment.json`: interpreter/platform and dependency versions used.
- `test_logs/run_*.log`: actual CLI run transcripts.
- `results/<run_id>/`: actual JSON/CSV/PNG outputs from four unique case definitions and two installed CLI smoke runs.
