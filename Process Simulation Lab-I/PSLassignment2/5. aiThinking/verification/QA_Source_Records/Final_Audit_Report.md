# ENERGY-008 Final Repository Integration and Audit Report

**Project:** ENERGY ASSIGNMENT 008 | Green methanol synthesis, utility integration and energy KPIs  
**Report ID:** `ENERGY008-REP-001` Rev 1.0  
**Result version:** `ENERGY008-REPORT-1.0`  
**Model/data baseline:** `ENERGY008-MODEL-0.1.0` / `ENERGY008-DATA-0.1.0`  
**Design basis:** Rev 0.1-DRAFT; Gate 3 not frozen  
**Audit cutoff:** 03 November 2026

## Prompt 26 addendum (03 November 2026)

The current PDF in this repository is 123 A4 pages. Prompt 26 appended the two-page real-world case-study appendix (Kassø, Piteå and Skive) after the earlier 121-page Prompt 24 render-QA baseline. The historical `QA/Render_QA_Report.md` retains its original 121-page findings and is not represented as a fresh 123-page visual inspection. Current file-level checks confirm 123 pages, A4 geometry, 133 link annotations and 133 internal PDF links. The report DOCX/PDF and presentation remain the existing Prompt 26 artifacts; no engineering input or calculation was reverse-engineered from the case-study figures.

The MATLAB Design Basis GUI has been amended to show the case-study applicability and limits alongside the provisional route status. Python regression tests (23/23) and the three repository static checks were rerun after this update. MATLAB runtime, GUI launch, export behavior and MATLAB/Python parity remain NOT RUN and are explicitly left for the user.

## 1. Audit conclusion

**Repository integration and file-level reproducibility checks are complete. The engineering assignment is not fully accepted.** The clean repository contains the canonical Prompt 23 MATLAB/Python project, controlled data and registers, calculations, actual screening/run outputs, the Prompt 24 editable report/PDF and presentation, diagrams, datasheets, automation/environment/safety records and archived phase evidence. All 27 assignment topics are mapped to evidence and a status. The status count is **12 PASS, 2 FAIL, 11 BLOCKED and 2 NOT RUN**. Topic 2 fails because the base case plus two independently evaluated alternatives requirement is not met; Topic 27 fails because several acceptance requirements remain blocked or unrun.

No result in this audit upgrades the physical process to validated, industrial-ready, safe, compliant or certified. The work remains a preliminary academic engineering study. The full issue list is in `QA/ENERGY008_Open_Issues.md`.

## 2. Canonical source selection and repository contents

The active `MATLAB/` and `Python/` code trees are the integrated Prompt 23 source snapshot copied into the canonical repository locations; the original Prompt 23 handoff ZIP is retained under `Archive/Phase_Evidence/`. The latest Prompt 22 sensitivity and uncertainty records are carried forward, including the correction to the earlier Prompt 21 throughput-only sensitivity defect. The Prompt 24 report, PDF, slide deck, registers, diagrams and bibliography are retained as the authoritative final-report artifacts.

Older Prompt 19 and Prompt 20 source-tree ZIPs are retained as immutable phase evidence under `Archive/Phase_Evidence/`; they are not duplicated as competing active code trees. Prompt 21 verification and Prompt 22/23 evidence archives are also retained. The original `PSLassignment2.pdf` is included unchanged. The CPS-01 document was used only to understand visual structure and is excluded from the submission repository. No CPS-01/CPS-22 calculations, engineering values, equations or conclusions are reused.

### Exact top-level contents

```text
ENERGY-008_Submission/
├── README.md, .energy008-root, project runtime support files
├── MATLAB/                  canonical integrated MATLAB engine, START_HERE, GUI, tests
├── Python/                  partial GUI-independent Python migration, tests, lock, results
├── data/                    raw, processed, reference, schema-controlled data and manifest
├── Configuration/           configuration index
├── Calculations/            manual calculations, method notes, independent checks
├── Results/                 sensitivity, uncertainty, alternatives and screen outputs
├── outputs/                 integrated project output location
├── tests/                   root static integrity and regression checks
├── Tests/                   Prompt 21 and Python unit-test evidence
├── Logs/ and logs/          test/sensitivity logs and runtime log locations
├── Report/                  editable DOCX, review PDF, figure/table registers
├── Presentation/            editable 16-slide PPTX
├── Original_Assignment/     governing PSLassignment2.pdf
├── PFD_PID/                 editable PFD/P&ID-level sources and rendered references
├── Flowcharts/ and flowcharts/ editable/rendered workflow diagrams and source logic
├── Diagrams/                heat-network and supporting engineering figures
├── Equipment_Datasheets/    28 preliminary equipment datasheets
├── Control_Sequence/        controls, loops, alarms, interlocks, modes, start/stop
├── Environment_Safety/      environmental, waste, HAZID and safety screening
├── Registers/               core and additional engineering registers
├── Sources/                 74-source bibliography, BibTeX and engineering notes
├── documentation/           integrated project documentation
├── Archive/Phase_Evidence/  immutable Prompt 19–23 source/evidence ZIPs
└── QA/                      result identity, audits, static logs, compliance workbook
```

## 3. Assignment topic compliance map

| Status | Count |
|---|---:|
| PASS | 12 |
| FAIL | 2 |
| BLOCKED | 11 |
| NOT RUN | 2 |

### Topics 1–27, in original assignment order

| Topic | Original assignment heading | Status | Evidence assessment |
|---:|---|---|
| 1 | Assignment Purpose | **PASS** | Purpose and scope are explicitly carried into the report and requirements baseline. The result remains a preliminary academic study, not a validated plant model. Evidence: `Report/ENERGY008_Technical_Report.pdf; Sources/Engineering_Notes/ENERGY008_Assignment_Extraction.md; Registers/Additional/ENERGY008_Requirements_Traceability.xlsx` |
| 2 | Core Problem Statement | **FAIL** | Only Route A is compared on a common ideal downstream CO2/H2 reaction core. Route B is BLOCKED, so the required base case plus two independently evaluated alternatives is not met. No validated operating window or plant optimum is recommended. Evidence: `Sources/Engineering_Notes/ENERGY008_Route_Decision_Report.md; Results/Sensitivity_Optimisation/ENERGY008_Alternative_Comparison.xlsx; Python/results/` |
| 3 | Project-Specific Technical Scope | **PASS** | Process boundary, modes and disturbance responses are documented. Dynamic plant responses and actual control-system simulations have not been executed. Evidence: `Sources/Engineering_Notes/ENERGY008_Process_Description.md; Control_Sequence/ENERGY008_StartStop_Sequence.md; Registers/Core/ENERGY008_Disturbance_Response_Matrix.xlsx; Registers/Additional/ENERGY008_Operating_Mode_Matrix.xlsx` |
| 4 | Engineering Inputs and Data | **PASS** | Design basis Rev 0.1-DRAFT; Gate 3 is not frozen. Unknowns and assumptions are explicitly labelled and retained as open items. Evidence: `Registers/Core/ENERGY008_Design_Basis.xlsx; data/raw/; data/data_manifest.json; Registers/Additional/ENERGY008_Data_Gap_Register.csv; Report/ENERGY008_Technical_Report.pdf` |
| 5 | Governing Equations and Model Formulation | **BLOCKED** | Reference equations and bounded calculations exist, but PR78 mixture EOS/kij, methanol-water VLE, catalyst-matched kinetics and other physical models are incomplete or blocked. Some equations are screening/reference identities only. Evidence: `Registers/Additional/ENERGY008_Governing_Equations_Register.xlsx; Sources/Engineering_Notes/ENERGY008_Model_Assumptions_and_Validity.md; Calculations/ENERGY008_Numerical_Methods.md; Python/src/energy008/` |
| 6 | Numerical Algorithm | **BLOCKED** | Startup/configuration and staged Python reference/screening orchestration exist. Physical recycle convergence, complete process-flow solving, physical closure and full exports are blocked. Generic solver tests are synthetic-only. Evidence: `MATLAB/; Python/src/energy008/; Tests/; Registers/Additional/ENERGY008_Convergence_and_Failure_Standards.xlsx` |
| 7 | Material Balances | **BLOCKED** | Ideal stoichiometric CO2/H2/component and elemental reference ledger is reproducible. The 55 conceptual streams do not have full physical flow, composition, phase, T/P and quality states; physical recycle/purge and plant closure remain blocked. Evidence: `Calculations/ENERGY008_Hand_Calculation_Report.md; Registers/Core/ENERGY008_Stream_Register.xlsx; Python/results/; Report/ENERGY008_Technical_Report.pdf` |
| 8 | Energy Balance and Thermal Design | **BLOCKED** | Selected pure-component/reference thermochemical identities and HX/pump screens exist. A physical plant energy closure, validated heat integration and complete utility duties are not available. Evidence: `Registers/Additional/ENERGY008_Energy_Balance.xlsx; Registers/Additional/ENERGY008_Equipment_Duty_Register.xlsx; Sources/Engineering_Notes/ENERGY008_Heat_Integration_Report.md; Report/ENERGY008_Technical_Report.pdf` |
| 9 | Entropy Balance | **BLOCKED** | Physical stream-state properties and entropy-generation closure are missing. Module remains explicitly BLOCKED; no plant entropy balance is claimed. Evidence: `MATLAB/entropy_exergy.m; Python/src/energy008/blocked_models.py; Registers/Additional/ENERGY008_Energy_Balance.xlsx; Report/ENERGY008_Technical_Report.pdf` |
| 10 | Exergy Balance | **BLOCKED** | A screening/reference exergy ranking is retained where available, but plant exergy inputs, dead-state closure and exergy destruction balance are not solved. Evidence: `MATLAB/entropy_exergy.m; Python/src/energy008/blocked_models.py; Diagrams/Rendered_References/ENERGY008_Exergy_Destruction_Ranking.png; Report/ENERGY008_Technical_Report.pdf` |
| 11 | Detailed Equipment Selection and Design Calculations | **BLOCKED** | 28 preliminary datasheet records are included. Only bounded pump/HX and reference sizing arithmetic is supported; detailed equipment ratings, vendor confirmation, full physical sizing and pressure-relief design remain unresolved. Evidence: `Equipment_Datasheets/Prompt11_Detailed_Datasheets/; Registers/Core/ENERGY008_Equipment_Register.xlsx; Registers/Additional/ENERGY008_Equipment_Sizing_Calculations.xlsx; Report/ENERGY008_Technical_Report.pdf` |
| 12 | PFD and P&ID-Level Definition | **PASS** | Editable PFD and P&ID-level conceptual sketches are included. They are preliminary engineering drawings, not IFC documents or construction-ready drawings. Evidence: `PFD_PID/ENERGY008_PFD.drawio; PFD_PID/ENERGY008_PID_Level_Sketch.drawio; PFD_PID/Rendered/; Flowcharts/` |
| 13 | Industrial Process Automation and Control | **PASS** | Conceptual control loops, alarms, interlocks and failure responses are documented. They are not implemented as a live PLC/DCS/SIS application and are not a certified safety function. Evidence: `Control_Sequence/ENERGY008_Control_Philosophy.md; Control_Sequence/ENERGY008_Control_Loop_Register.xlsx; Control_Sequence/ENERGY008_Alarm_Register.xlsx; Control_Sequence/ENERGY008_Interlock_CauseEffect_Matrix.xlsx` |
| 14 | PLC/DCS, HMI, Sequencing and Alarm Requirements | **NOT RUN** | Source and documents exist, but MATLAB GUI runtime, HMI behavior, utility-loss/sensor/actuator/communications failure injection and process-state simulations were not run. Evidence: `MATLAB/gui/ENERGY008_App.m; MATLAB/run_gui.m; Control_Sequence/; Registers/Additional/ENERGY008_Operating_Mode_Matrix.xlsx; Tests/Prompt21_Verification/` |
| 15 | Utilities, Environment and Waste | **BLOCKED** | Some stoichiometric and scenario utility/water/emissions proxies exist. Complete site utility, water, wastewater, off-gas and source-specific emissions/MRV balances remain blocked. Evidence: `Registers/Additional/ENERGY008_Utility_Summary.xlsx; Registers/Additional/ENERGY008_Water_Balance.xlsx; Environment_Safety/; Sources/Engineering_Notes/ENERGY008_Environmental_and_Indian_Compliance_Screen.md` |
| 16 | CAPEX Screening | **BLOCKED** | No complete, defensible plant CAPEX estimate is available because detailed equipment scope, vendor quotations, installed factors, cost basis and site/location factors are unresolved. Evidence: `MATLAB/economics.m; Python/src/energy008/economics.py; Registers/Additional/ENERGY008_Equipment_Duty_Register.xlsx; Report/ENERGY008_Technical_Report.pdf` |
| 17 | OPEX Screening | **BLOCKED** | Electricity-only unit-cost proxies are calculated in Prompt 22; complete feedstock, utility, labour, maintenance, catalyst, waste and annual OPEX are not established. Evidence: `MATLAB/economics.m; Python/src/energy008/economics.py; Registers/Additional/ENERGY008_Utility_Summary.xlsx; Report/ENERGY008_Technical_Report.pdf` |
| 18 | Sensitivity Analysis | **PASS** | Prompt 22 has 12 independent OAT studies and a deterministic 1,000-sample, 8-dimension LHS with 11 sampled non-dominated points. Outputs are SCREENING ONLY conditional proxies; physical limits/constraints and a plant optimum remain blocked. Evidence: `Results/Sensitivity_Optimisation/ENERGY008_Sensitivity_Plan.xlsx; Results/Sensitivity_Optimisation/ENERGY008_Sensitivity_Results.xlsx; Results/Sensitivity_Optimisation/ENERGY008_Uncertainty_Analysis.xlsx; Results/Sensitivity_Optimisation/Reproducibility/; Results/Sensitivity_Optimisation/Test_Logs/` |
| 19 | Flowchart Requirements | **PASS** | All three flowchart categories have editable source or retained source-record versions and rendered references. Evidence: `Flowcharts/ENERGY008_TopLevel_Flowchart.dot; Flowcharts/ENERGY008_Solver_Flowchart.svg; Flowcharts/ENERGY008_Automation_State_Sequence.dot; Flowcharts/Rendered/` |
| 20 | MATLAB Modular Architecture | **PASS** | Latest integrated Prompt 23 MATLAB source and modular architecture are present. Static/source checks passed in previous phase; MATLAB execution is not implied and remains NOT RUN. Evidence: `MATLAB/START_HERE.m; MATLAB/main.m; MATLAB/*.m; MATLAB/+energy008/; MATLAB/docs/Software_Architecture.md; tests/` |
| 21 | GUI Requirements | **NOT RUN** | GUI source and source-contract checks are present; actual MATLAB GUI launch, interactive behavior, exports and screenshots are NOT RUN. Evidence: `MATLAB/gui/ENERGY008_App.m; MATLAB/run_gui.m; MATLAB/gui/README.md; MATLAB/docs/GUI_User_Guide.md; Tests/Prompt21_Verification/ENERGY008_Test_Logs/gui_source_contract_check.log` |
| 22 | Variable Dictionary and Units | **PASS** | Variable dictionary and unit/data contract are included; unit conversion functions and boundary conventions exist in code. Evidence: `Registers/Additional/ENERGY008_Stream_and_Reaction_Data_Dictionary.xlsx; Report/ENERGY008_Technical_Report.pdf; MATLAB/docs/Model_Implementation.md; Python/docs/Unit_and_Data_Contract.md` |
| 23 | Verification and Validation | **BLOCKED** | 23 Python tests and bounded hand-fixture/static assertions pass. Physical process-model validation, MATLAB runtime tests, GUI/automation fault tests and MATLAB/Python runtime parity remain NOT RUN or BLOCKED. Evidence: `Tests/Prompt21_Verification/ENERGY008_Unit_Integration_Test_Report.md; Tests/Prompt21_Verification/ENERGY008_Verification_Matrix.xlsx; Python/test_logs/pytest_final.log; QA/Fresh_Extraction_Test/run_log.txt` |
| 24 | Python/Open-Source Migration Requirements | **PASS** | Partial/staged migration is installed and tested on CPython 3.13.5 with 23 passes and 18 numeric hand-fixture parity rows. MATLAB-to-Python runtime parity is NOT RUN; physical modules remain explicitly blocked. Evidence: `Python/pyproject.toml; Python/requirements.lock; Python/src/energy008/; Python/docs/MATLAB_to_Python_Mapping.xlsx; Python/docs/Python_Test_and_Parity_Report.md; Python/results/` |
| 25 | Technical Report Structure | **PASS** | 121-page A4 editable report and matching PDF review copy are present; all 27 topic headings are in source order. Render QA and page reconciliation passed. Evidence: `Report/ENERGY008_Technical_Report.docx; Report/ENERGY008_Technical_Report.pdf; Report/Figure_Register.csv; Report/Table_Register.csv; Sources/Bibliography/` |
| 26 | Final Submission Package | **PASS** | Repository integration includes primary deliverables and source evidence. Prompt 25 ZIP/manifest integrity is audited in the final QA report. Evidence: `README.md; MATLAB/; Python/; data/; Registers/; Report/; Presentation/; PFD_PID/; Flowcharts/; Equipment_Datasheets/; Control_Sequence/; Environment_Safety/; Archive/` |
| 27 | Acceptance Checklist | **FAIL** | The checklist is not fully met: alternative count fails; physical material/energy/entropy/exergy closure, detailed design/economics and complete validation remain blocked/not run. Documentation/packaging does not upgrade these statuses. Evidence: `QA/Final_Compliance_Matrix.xlsx (Acceptance Checklist sheet); QA/Final_Audit_Report.md` |

## 4. Topic 27 acceptance checklist

| Status | Count |
|---|---:|
| PASS | 5 |
| FAIL | 0 |
| BLOCKED | 4 |
| NOT RUN | 0 |

| ID | Acceptance criterion | Status | Basis |
|---|---|---|
| A-01 | Process boundary, design basis and assumptions are explicit. | **PASS** | Boundary and assumptions are explicit; design basis remains Rev 0.1-DRAFT and Gate 3 is not frozen. Evidence: `Report/ENERGY008_Technical_Report.pdf; Registers/Core/ENERGY008_Design_Basis.xlsx; Registers/Additional/ENERGY008_Data_Gap_Register.csv` |
| A-02 | Equations are editable Word Equation objects and symbols are defined. | **PASS** | OOXML inspection counted 35 Word Office Math (m:oMath) nodes. This confirms embedded Word math objects, not correctness/validation of every physical model equation. Evidence: `Report/ENERGY008_Technical_Report.docx; Registers/Additional/ENERGY008_Governing_Equations_Register.xlsx; Registers/Additional/ENERGY008_Stream_and_Reaction_Data_Dictionary.xlsx` |
| A-03 | Material, energy, entropy and exergy balances and closure are reported. | **BLOCKED** | Only an ideal stoichiometric reference ledger/limited thermochemical checks are closed. Physical material streams and plant energy/entropy/exergy balances are not closed. Evidence: `Calculations/ENERGY008_Hand_Calculation_Report.md; Registers/Additional/ENERGY008_Energy_Balance.xlsx; Python/src/energy008/blocked_models.py` |
| A-04 | Detailed equipment sizing, calculation trail and datasheets are complete. | **BLOCKED** | 28 preliminary datasheets and selected worked screening calculations are present; full sizing, ratings, vendor confirmation, relief design and uncertainty/normal-upset rating remain incomplete. Evidence: `Equipment_Datasheets/; Registers/Additional/ENERGY008_Equipment_Sizing_Calculations.xlsx; Report/ENERGY008_Technical_Report.pdf` |
| A-05 | Sensors, actuators, control loops, HMI, alarms, interlocks and failure responses are documented. | **PASS** | Design documentation exists. HMI runtime, disturbance/fault simulation and safety-system execution are NOT RUN; no SIL or certified safety claim is made. Evidence: `Control_Sequence/; Registers/Core/ENERGY008_Control_Loop_Register.xlsx; Registers/Core/ENERGY008_Alarm_Register.xlsx; Registers/Additional/ENERGY008_Interlock_CauseEffect_Matrix.xlsx` |
| A-06 | Utilities, waste and screening CAPEX/OPEX are quantified. | **BLOCKED** | Some electricity, water and emissions scenario proxies are quantified. Complete site utilities/waste and defensible CAPEX/OPEX estimates are not available. Evidence: `Registers/Additional/ENERGY008_Utility_Summary.xlsx; Registers/Additional/ENERGY008_Emissions_and_Waste_Register.xlsx; MATLAB/economics.m; Python/src/energy008/economics.py` |
| A-07 | At least six sensitivity variables and multiple scenarios are analysed. | **PASS** | 12 OAT studies plus an 8-dimension, 1,000-sample LHS pass screening checks. Outputs are conditional assumptions/proxies, not physical process optimization or a validated operating window. Evidence: `Results/Sensitivity_Optimisation/ENERGY008_Sensitivity_Results.xlsx; Results/Sensitivity_Optimisation/ENERGY008_Uncertainty_Analysis.xlsx; Results/Sensitivity_Optimisation/Test_Logs/screening_checks.csv` |
| A-08 | MATLAB architecture, GUI, validation and Python migration are addressed. | **BLOCKED** | Architecture and GUI source exist; Python migration is partially tested. MATLAB startup/unit tests/GUI launch, full physical validation and MATLAB-Python runtime parity are NOT RUN or BLOCKED. Evidence: `MATLAB/; Python/; Tests/; QA/Fresh_Extraction_Test/run_log.txt` |
| A-09 | No unsupported regulatory-compliance, vendor-endorsement or certified-safety claim is made. | **PASS** | The package explicitly disclaims plant certification, vendor guarantees, statutory submission and certified safety integrity; current compliance needs further verification. Evidence: `Report/ENERGY008_Technical_Report.pdf; Sources/Engineering_Notes/ENERGY008_Environmental_and_Indian_Compliance_Screen.md; Environment_Safety/ENERGY008_Safety_Study_Limitations.md` |

## 5. Software, source and runtime tests

### Python fresh-extraction test

- Fresh extraction directory: `QA/Fresh_Extraction_Test/` test log recorded in `QA/Fresh_Extraction_Test/run_log.txt`.
- Runtime: CPython 3.13.5 on Linux x86_64. Locked dependencies matched the test environment: NumPy 2.3.5, SciPy 1.17.0, pandas 2.2.3, Matplotlib 3.10.8, pytest 9.0.2 and setuptools 82.0.1.
- Editable install was performed using the tested local environment (`python -m pip install -e . --no-deps --no-build-isolation`) after dependency versions were confirmed present; this did not perform a network lockfile resolution.
- `python -m pytest -q`: **23 passed**.
- Default Route C CLI, Route A common-core comparator, Route B fail-closed/blocked case and Route C 25 t/day turndown CLI were executed. Route C, Route A and turndown outputs are **SCREENING_ONLY**; Route B remains **BLOCKED**. They are not physical plant simulations or measured operating cases.
- Prompt 22 screening checks: 12 independent OAT studies and 8-dimensional, 1,000-sample LHS screen; the project test log reports the screening controls passed. The screen is not a physical process optimisation.

### Static / independent checks

- `python tests/check_project_static.py`: **PASS, 100 checks**, including 55 hashed data snapshots.
- `python tests/check_gui_static.py`: **PASS, 80 source-contract checks**. The script explicitly does not parse MATLAB or launch the GUI.
- `python tests/check_prompt19_regression.py`: **PASS, 50 independent Python arithmetic fixture checks**. This is not MATLAB execution or physical-model validation.
- The logs are retained under `QA/Prompt25_Static_Test_Logs/`. The three static-check scripts reside at root `tests/` so their project-root discovery uses the correct repository root.

### MATLAB / Octave boundary

Neither MATLAB nor GNU Octave is installed in the audit environment. Therefore `MATLAB/START_HERE.m`, the 31-test MATLAB suite, MATLAB GUI/HMI runtime, MATLAB engine calculations, exports and MATLAB/Python runtime parity were **NOT RUN**. Do not infer runtime success from source-contract checks. Execute the commands in the repository README on a supported licensed MATLAB installation and retain the full output.

## 6. Report, presentation, bibliography and drawings

- Technical report: 121-page A4 DOCX and matching PDF review copy; 27 assignment topic headings retained in order; 35 OOXML Word Office Math objects counted; figure and table registers enumerate 33 figures and 30 tables.
- Report PDF: 123 pages; page-text comparison between DOCX-rendered output and the review PDF recorded zero differing pages. A4 page geometry and internal PDF link targets were checked.
- DOCX navigation: 103 bookmarks and 133 internal hyperlink anchors; all anchors resolve to existing bookmarks. PDF navigation: 133 internal GOTO links checked with no invalid destinations.
- Presentation: 16 editable slides; a fresh render and slide overflow check passed.
- Bibliography: report citation IDs reconcile with 74 records in the reference list; BibTeX was corrected to 74 entries and passed Biber data-model validation.
- Diagrams include editable PFD/P&ID-level sources, process/solver/automation flowcharts and heat-network assets. They are conceptual academic design drawings, not approved construction or operating drawings.
- Datasheet register: 28 preliminary equipment datasheets. They do not represent vendor-confirmed or final equipment ratings.

## 7. Engineering result status and material limitations

### Reproducible stoichiometric reference only

The report uses an ideal stoichiometric reference at 50,000 kg/day methanol component-equivalent: minimum CO₂ 68.6749 t/day, H₂ 9.43708 t/day, stoichiometric electrolyser DI water 84.3362 t/day and theoretical O₂ 74.8991 t/day. These figures are theoretical component-ledger values, not actual plant flowrates, guaranteed yields, saleable oxygen or a closed plant mass balance.

### Blocked or screening-only engineering elements

- Physical process model: high-pressure PR78 mixture EOS/kij and phase stability, methanol-water VLE, catalyst-specific kinetics/PFR sizing and validated reactor performance remain blocked. The draft synthesis pressure is 70 bar(a), outside the cited experimental kinetic data range (reported up to approximately 50–51 bar); extrapolation is not claimed valid.
- Physical process streams and recycle: recycle/purge/compressor and physical material-balance convergence are not closed.
- Energy/entropy/exergy: selected reference heat/equipment identities are available, but the complete plant energy, entropy and exergy balances are not closed.
- Equipment: 28 preliminary datasheets and selected calculation trails exist; final design conditions, vendor curves/guarantees, full mechanical details and relief design remain open.
- Utilities/economics: some conditional electricity/water/emissions proxies exist, but site utility envelopes, complete water/energy demand, full CAPEX and full OPEX are blocked.
- Environment/safety: emissions MRV, chain of custody, lifecycle boundary, formal HAZOP/LOPA/SIL/QRA, materials/code reviews and regulatory confirmation remain outstanding.
- Route selection: Route C is a working reference. Route A has only a common ideal downstream core comparison. Route B is blocked by missing biomass assay, gasifier/syngas, cleanup, yield, catalyst and route-cost evidence. Therefore the assignment’s base case plus two independently evaluated alternatives requirement is **not met**.
- Sensitivity: Prompt 22 supersedes the earlier Prompt 21 throughput-only perturbation defect with 12 OAT studies and an 8-factor, 1,000-sample LHS screen. It does not establish a physical operating window or global plant optimum.

## 8. Archive, path and checksum audit

- Eight retained phase-evidence ZIP archives were each checked using `unzip -t`; all returned no compressed-data errors. Per-archive output is stored in `QA/Prompt25_Static_Test_Logs/phase_archive_integrity.txt`.
- Local Markdown link audit: 100 Markdown files and 28 local relative links checked; no broken targets. DOCX internal links: 103 bookmarks and 133 anchors all resolve. PDF: 123 pages and 133 internal GOTO links with no invalid target. The checker is `QA/Build_Scripts/check_energy008_links.py` and the output is `QA/Prompt25_Static_Test_Logs/link_audit.json`.
- The finalized repository contains 489 files including the manifest. The manifest contains 488 hash rows and is generated from the finalized repository tree; it includes every repository file except itself. Each row records relative path, byte size, SHA-256, purpose, source/version and verification status. The manifest does not recursively hash itself. The enclosing release ZIP is separately checksummed in `ENERGY-008_Submission.zip.sha256`.
- The release ZIP is tested with `unzip -t` and extracted to a fresh smoke-test directory; every manifest path, byte size and SHA-256 is rechecked against the extracted copy.

## 9. Final disposition

**Repository integration: complete. File/source reproducibility checks: passed at the explicitly stated level. Engineering acceptance: not achieved.** The package is suitable to hand to Prompt 25 reviewers for review of the repository, evidence traceability and outstanding issues, but it must not be represented as a fully accepted or validated physical-process design.

Before any upgraded design conclusion, close the gate-3 design basis and the route count; establish valid kinetics and thermodynamics; close physical balances; finish equipment/utility/cost and environmental/safety work; run MATLAB and HMI tests; execute Python/MATLAB parity; and obtain competent review and academic sign-off.

## 10. Reproduction commands

Python on CPython 3.13.x:

```bash
cd Python
python3.13 -m venv .venv
. .venv/bin/activate
python -m pip install -r requirements.lock
python -m pip install -e . --no-deps --no-build-isolation
python -m pytest -q
python -m energy008.cli
```

MATLAB (not run in this audit environment):

```matlab
run('MATLAB/START_HERE.m')
run(fullfile(ENERGY008_PROJECT_ROOT, 'MATLAB', 'tests', 'run_startup_smoke_test.m'))
run_prompt19_tests(ENERGY008_PROJECT_ROOT)
app = run_gui;
```

## 11. Handoff outputs

- `ENERGY-008_Submission.zip` – clean repository archive.
- `ENERGY-008_Submission_Manifest.csv` – file-level SHA-256/provenance manifest (self-excluded).
- `ENERGY-008_Final_Compliance_Matrix.xlsx` – assignment Topics 1–27, Topic 27 criteria, software/runtime tests, issue register and evidence map.
- `ENERGY-008_Open_Issues.md` – 18-item open issue register.
- `ENERGY-008_Final_Audit_Report.md` – this report.

## 12. Prompt 26 update — real-world case studies

The report now includes a 2-page appendix (final PDF: 123 pages) and the repository includes `Sources/Engineering_Notes/ENERGY008_Real_World_Case_Studies.md`. Evidence includes:
- Kassø, Denmark: commercial e-methanol, reported 42 kt/y, renewable electrolysis and biogenic CO2, with fuel and chemical/materials offtake.
- Piteå, Sweden: black-liquor gasification syngas demonstration for methanol/DME; sulphur/tar cleanup and catalyst protection are explicit requirements.
- Skive, Denmark: commercial biomass gasification CHP, used only as an upstream analogue.

Six new references (SRC-075–SRC-080) were added to the source CSV and BibTeX. Route B remains blocked because the cases do not supply a site-specific biomass assay, gasifier yield/composition, full cleanup balance, methanol catalyst kinetics, route-specific utilities or economics. MATLAB GUI execution and process-model validation remain for the user.

**End of audit report.**

---

## Rev 0.2 supplemental calculation-book release (03 November 2026)

A separate 57-page detailed calculation companion has been added at `Report/ENERGY008_Detailed_Calculation_Book_Rev0.2.docx` and `.pdf`. The editable 19-sheet calculation register, 75-record calculation index, design-basis/property/stream exports, OAT metric export and LHS samples are under `thinking/calculations/`. The Rev 1.0 main report and original assignment sequence are preserved.

Rerun checks for this revision: project static checks PASS (100), GUI source-contract checks PASS (80), independent arithmetic fixture checks PASS (50), and Python test suite PASS (23) using `PYTHONPATH=src python -m pytest -q` from `Python/`. The new calculation DOCX/PDF rendered to 57 A4 pages and was visually inspected. MATLAB/Octave startup, MATLAB tests, actual GUI runtime, HMI behavior and MATLAB-Python runtime parity remain NOT RUN. Full process-model, vendor, site, economic, MRV and formal process-safety limitations remain as recorded in `ENERGY008_Open_Issues.md` and `Rev0.2_Calculation_Book_Audit.md`.
