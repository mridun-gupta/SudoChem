# ENERGY-008 staged MATLAB-to-Python migration

**Python package:** `energy008-python` 0.1.0  
**Model data:** `ENERGY008-MODEL-0.1.0`, `ENERGY008-RXN-0.1.0`, `ENERGY008-DATA-0.1.0`  
**Project design status:** Route C provisional working basis; G3 not frozen  
**Migration status:** Partial/staged. This is not a full physical process-model migration.

## What is implemented

The Python package reproduces the source-supported Prompt 19 calculation boundary using NumPy, SciPy, pandas and Matplotlib:

- package-relative JSON loading, explicit case selection and fail-closed input validation;
- explicit unit-boundary conversion helpers;
- matrix-driven R-01/R-02/E-01 reaction extents from the versioned reaction register;
- reaction-block component and C/H/O elemental ledgers in SI internally and fixture units at export;
- NIST Shomate pure ideal-gas CO2 sensible-enthalpy reference and the versioned pure-methanol latent-heat reference, each with validity checks;
- standard-state reaction enthalpy identities and source-propagated uncertainty;
- Prompt 17 illustrative HX area and W-201 pump power arithmetic;
- reference material KPIs and throughput sensitivity at the controlled 45/50/55 t/day reference points;
- generic SciPy Latin-Hypercube sampling and a synthetic-only nonlinear solver primitive;
- run metadata, JSON/CSV/PNG exports and module statuses.

The `ModelResult` contract preserves `CALCULATED`, `REFERENCE_ONLY`, `SCREENING_ONLY`, `BLOCKED`, `FAILED` and `NOT_RUN` states. Missing plant data remain `None`/JSON `null`, not zero.

## Explicitly incomplete / blocked

The following modules are present as clear gates, not as working physical models:

- PR78 mixture fugacity/flash: complete active binary `kij` data and independent validation are missing.
- Methanol-water VLE/distillation: fitted and independently validated Wilson/NRTL parameters and approved pressure are missing.
- R-301 kinetics/PFR: catalyst-matched rate law, parameters, validity range, geometry and thermal boundary are missing.
- S-209 recycle / S-207 purge: physical stream compositions/inerts, flash and purge criterion are missing. The generic nonlinear solver is synthetic-test-only.
- plant energy, entropy and exergy closures: physical stream states, boundaries and dead-state environment are missing.
- actual ALK electricity, rectifier/BOP, compressors, cooling/steam and site utilities: OEM maps and site data are missing.
- environmental KPIs / MRV: measured source-specific data, chain-of-custody and an approved method are missing.
- CAPEX/OPEX/LCOM: dated vendor quotations, tariffs, cost indices, factors, financing and production assumptions are missing.
- 55-stream flowsheet, full equipment rating and dynamic BPCS/SIS: not implemented or connected.

Therefore a run can produce screening outputs while reporting multiple downstream `BLOCKED` module statuses. No validated operating window or plant optimum follows from those outputs.

## Clean installation (tested stack)

The development container used Python **3.13.5** with these exact dependency versions:

- NumPy 2.3.5
- SciPy 1.17.0
- pandas 2.2.3
- Matplotlib 3.10.8
- pytest 9.0.2 (test extra)

The package declares Python `>=3.13,<3.14`; CPython 3.13.5 is the only interpreter actually executed for this release. The shipped `requirements.lock` is a pinned resolution for the tested Linux/Python 3.13 environment; binary wheels for other operating systems may resolve differently. Re-resolve and re-run the suite on each target interpreter/OS before qualification.

### Linux / macOS

```bash
cd ENERGY008_MATLAB/Python
python3.13 -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.lock
python -m pip install -e . --no-deps --no-build-isolation
python -m pytest -q
python -m energy008.cli
```

### Windows PowerShell

```powershell
cd ENERGY008_MATLAB\Python
py -3.13 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.lock
python -m pip install -e . --no-deps --no-build-isolation
python -m pytest -q
python -m energy008.cli
```

### Select a controlled case

```bash
python -m energy008.cli --case-id A-INDCO2-REH2-ALK-REF-50TPD
python -m energy008.cli --case-id B-BIOMASS-SYNGAS-50TPD
python -m energy008.cli --case-id C-BIOCO2-REH2-ALK-TURNDOWN-25TPD
```

Each command creates a new uniquely named folder in `results/` with `results.json`, run log, CSV ledgers and a PNG plot when a material ledger exists. The Route B command returns its explicit blocked state. Existing output folders are never overwritten.

## Exact data and unit conventions

- Package data are copied from the Prompt 19 controlled project and Prompt 17 frozen hand fixture. See `data/source_manifest.json` for original source paths and SHA-256 fingerprints.
- No external property databases are bundled.
- Internal material-balance basis: mol/s, kg/s, kg/mol; data records carry kg/day and kg/kmol; boundary conversion is explicit.
- Energy calculation: kJ/mol times mol/s produces kW; GJ/day uses 86,400 s/day / 1,000,000 kJ/GJ.
- Pressure convention remains absolute; temperatures are kelvin.
- No library default, missing property parameter or unknown case value is silently zero-filled.

## Tests and parity

The final test suite completed with **23 passed** after editable installation on CPython 3.13.5. It checks explicit unit conversions, the exact three-reaction matrix, unrounded Python outputs against the frozen Prompt 17 fixture using its absolute tolerances (including the nonzero rounded-MW mass residual), and relocated-package data discovery. They also exercise Route A shared-core comparison, blocked Route B, 25 t/day turndown scaling, invalid inputs, property validity bounds, missing EOS/VLE status, blocked recycle, synthetic solver behavior, package-relative data discovery and result exports.

The results under `results/` are outputs from actual Python executions in the build environment, including Route C base, Route A common-core, blocked Route B, Route C turndown and an installed CLI smoke run. They are not MATLAB runtime results. MATLAB and GNU Octave were unavailable in this migration build environment; MATLAB/Python parity remains `NOT RUN` until the MATLAB test suite is executed and output files are compared. The parity assertions in this release compare Python against the independent Prompt 17 fixture, not the same MATLAB function run twice.

## Python UI

No Python GUI is included. The core is UI-independent. A future UI may call `energy008.engine.run_case()` and render the returned module statuses without embedding equations.

## Further documentation

- `docs/MATLAB_to_Python_Migration.md` — staged migration decisions and acceptance gates.
- `docs/Library_Assessment.md` — CoolProp, Cantera, BioSTEAM and DWSIM evaluation.
- `docs/Unit_and_Data_Contract.md` — API and unit conventions.
- `docs/Python_Test_and_Parity_Report.md` — actual execution evidence.
- `docs/Prompt24_Handoff.md` — remaining work for the next phase.
- `docs/MATLAB_to_Python_Mapping.xlsx` — detailed module mapping.
- `licenses/THIRD_PARTY_NOTICES.md` — software/data provenance and dependency licence notes.
