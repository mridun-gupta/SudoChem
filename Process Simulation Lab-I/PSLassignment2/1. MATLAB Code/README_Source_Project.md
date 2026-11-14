# ENERGY-008 Submission Repository

**Project:** Green methanol synthesis — utility integration and energy KPIs  
**Report:** ENERGY008-REP-001, Rev 1.0  
**Result version:** ENERGY008-REPORT-1.0  
**Model/data baseline:** ENERGY008-MODEL-0.1.0 / ENERGY008-DATA-0.1.0  
**Design basis:** Rev 0.1-DRAFT; Gate 3 not frozen  
**Evidence cutoff:** 03 November 2026

> This is a preliminary academic engineering package. It is not a frozen plant design, issued-for-construction package, validated physical process model, statutory compliance submission, operating procedure, vendor guarantee or certified safety design. Preserve all BLOCKED, FAIL, NOT RUN and SCREENING ONLY states.

## Start here

1. Read this file, `QA/Final_Audit_Report.md` and `QA/Prompt26_Implementation_and_User_Handoff.md`.
2. Review `QA/ENERGY008_Open_Issues.md` and `QA/Final_Compliance_Matrix.xlsx` for unresolved requirements.
3. Review the governing brief at `Original_Assignment/PSLassignment2.pdf`. Its numbered Topics 1–27 are the requirement order.
4. Read `Report/ENERGY008_Technical_Report.pdf` or edit `Report/ENERGY008_Technical_Report.docx`.
5. Review the slide deck at `Presentation/ENERGY008_Short_Presentation.pptx`.
6. Use `Registers/` and `data/` for the controlled design and data registers.
7. Run the staged Python source as documented below. MATLAB checks remain NOT RUN in this environment because neither MATLAB nor GNU Octave is installed.

## Repository map

| Path | Purpose |
|---|---|
| `MATLAB/` | Canonical latest MATLAB engine, START_HERE, project config, GUI, tests and model modules |
| `Python/` | Partial GUI-independent Python migration, tests, lock file and actual run results |
| `Configuration/` | Index to runtime configuration locations; no configuration has been relocated |
| `data/` | Original raw, processed, reference and schema-controlled data |
| `Calculations/` | Hand calculation report, numerical methods, independent checks and calculation scripts |
| `Results/` and `outputs/` (integrated project output location) | Actual Python execution output and Prompt 22 sensitivity/screening outputs |
| `Tests/` (phase evidence) and `tests/` (root static integrity checks) | Independent verification records, unit-test source and static checks |
| `Logs/` (execution evidence) and `logs/` (project runtime location) | Retained Python and sensitivity execution logs |
| `Report/` | Editable Word report, PDF review copy, figure and table registers |
| `Presentation/` | Editable 16-slide presentation |
| `PFD_PID/` | Editable PFD/P&ID-level diagrams and rendered references |
| `Flowcharts/` and `flowcharts/` (integrated source workflow records) | Process, solver and automation sequence diagrams (editable + rendered) |
| `Diagrams/` | Heat-integration network source and additional rendered figure references |
| `Equipment_Datasheets/` | 28 preliminary equipment datasheet records |
| `Control_Sequence/` | Control philosophy, loop/alarm/interlock and start/stop records |
| `Environment_Safety/` | Environmental, waste, HAZID, material and standards screening records |
| `Registers/` | Core and additional controlled registers |
| `Sources/` | 74-source list, BibTeX and literature/route provenance records |
| `Archive/Phase_Evidence/` | Immutable Prompt 19–23 evidence packages |
| `QA/` | Result version, canonical file selection, render QA, final compliance matrix, open issues, audit and Prompt 26 handoff |
| `thinking/` | Calculation exports and working-record index for prompts, reports, results and sources; canonical active folders remain in place |
| `ENERGY-008_Submission_Manifest.csv` | Per-file SHA-256/size/provenance manifest; self-excluded by stated method |

## Python clean run (CPython 3.13.x)

The pinned lock describes the tested CPython 3.13.5 Linux environment. For Linux/macOS:

```bash
cd Python
python3.13 -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.lock
python -m pip install -e . --no-deps --no-build-isolation
python -m pytest -q
python -m energy008.cli
```

Windows PowerShell:

```powershell
cd Python
py -3.13 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
python -m pip install -r requirements.lock
python -m pip install -e . --no-deps --no-build-isolation
python -m pytest -q
python -m energy008.cli
```

Each CLI execution creates a unique result folder. Do not overwrite or delete prior run folders. To run specific controlled cases, see `Python/README.md`. The package run is a reference/screening model; downstream physical modules remain fail-closed when required plant data or validated property/kinetic models are absent.

## MATLAB startup and tests

Extract the **entire** repository so `.energy008-root` is at the project root and `MATLAB/project_config.json` remains under `MATLAB/`. In MATLAB, open and run `MATLAB/START_HERE.m`. Then run from the MATLAB Command Window:

```matlab
run(fullfile(ENERGY008_PROJECT_ROOT, 'MATLAB', 'tests', 'run_startup_smoke_test.m'))
run_prompt19_tests(ENERGY008_PROJECT_ROOT)
app = run_gui;
```

`START_HERE.m` resolves its project root by locating `.energy008-root` and `MATLAB/project_config.json` above its own path, not by relying on the current working directory. These commands are provided for later execution; MATLAB and GNU Octave were unavailable in the Prompt 25 audit environment, so startup, MATLAB tests and GUI runtime are NOT RUN. No MATLAB/Python runtime parity is claimed.


## Repository static checks

From the repository root, run:

```bash
python tests/check_project_static.py
python tests/check_gui_static.py
python tests/check_prompt19_regression.py
```

These checks verify project/data integrity and source contracts. They do not replace MATLAB runtime tests, physical process validation or a GUI launch.

## Reproducibility and integrity

- Use `ENERGY-008_Submission_Manifest.csv` to verify relative file paths, sizes and SHA-256 hashes.
- The manifest does not include its own hash row; it is generated after all project files are finalized. The enclosing ZIP is separately checksummed.
- `Archive/Phase_Evidence/` contains immutable phase ZIP handoffs; do not treat those historical snapshots as the active code tree.
- No external property database or licensed data package is included. See `Python/licenses/THIRD_PARTY_NOTICES.md` and `Sources/` for notices and provenance.

## Real-world case studies added in Prompt 26

`Sources/Engineering_Notes/ENERGY008_Real_World_Case_Studies.md` and the report appendix document Kassø (commercial e-methanol), Piteå (black-liquor syngas-to-methanol/DME demonstration), and Skive (biomass gasification CHP analogue). The GUI Design Basis tab now surfaces the corresponding engineering lessons: Kassø is an architecture precedent for Route C; Piteå defines Route B gas-cleanup and catalyst-protection scope; Skive is an upstream gasification/energy-integration analogue only. These are application references, not design data. Route B remains blocked pending feedstock, gasifier, cleanup and catalyst inputs.

## Known engineering boundary

Route C is a working reference, not a frozen selection. The ideal stoichiometric 50 t/day component-equivalent basis is not actual plant throughput or a plant-wide mass balance. Route A comparison is limited to the common ideal downstream core; Route B remains blocked, so the assignment's base case plus two independently evaluated alternatives is not met. Prompt 22 completes 12 OAT screening studies and an 8-dimensional, 1,000-sample LHS screen; those conditional screens do not establish a physical process operating window or plant optimum. Physical recycle/purge, high-pressure PR78 mixture VLE, methanol-water VLE, catalyst-matched kinetics, full energy/entropy/exergy closure, site utilities, complete economics, emissions MRV, and formal process safety studies remain blocked or screening-only.

## Detailed calculation companion (Rev 0.2)

The original 27-topic report remains `Report/ENERGY008_Technical_Report.docx` / `.pdf` (Rev 1.0). A supplemental 57-page calculation volume has been added:

- `Report/ENERGY008_Detailed_Calculation_Book_Rev0.2.docx` - editable detailed calculation book.
- `Report/ENERGY008_Detailed_Calculation_Book_Rev0.2.pdf` - rendered review copy.
- `thinking/calculations/ENERGY008_Detailed_Calculation_Register_Rev0.2.xlsx` - structured 19-sheet calculation/data workbook.
- `thinking/calculations/ENERGY008_Calculation_Index_Rev0.2.csv` - calculation, equipment and sensitivity ID index.
- `thinking/calculations/` - 271 property records, 71 design-basis records, 55 stream records, 156 OAT metric rows and 1,000 LHS sample exports.

The calculation volume follows the uploaded CPS-22 calculation-card approach while retaining ENERGY-008's own basis, equations and status. It contains the canonical HC-001 to HC-018 sequence, new CAL-xxx derived calculations, 28 EQ equipment calculation/status cards, OAT/LHS scope, real-world case-study applications and blocked calculation gates. It is a supplemental calculation record, not a replacement for the main report.

The `thinking/` tree is an index and working-record layer. Active MATLAB/Python project paths and canonical root folders have been retained to avoid breaking startup, tests, existing references or historical evidence.
