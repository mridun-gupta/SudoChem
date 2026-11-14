# ENERGY-008 Rev 0.2 - Detailed Calculation Book and Package Audit

**Audit date:** 03 November 2026  
**Parent technical report:** `ENERGY008-REP-001`, Rev 1.0  
**Supplemental calculation volume:** `ENERGY008-MAN-002`, Rev 0.2  
**Design basis:** Rev 0.1-DRAFT; Gate 3 not frozen  
**Evidence cutoff:** 03 November 2026

## 1. Scope of this revision

Rev 0.2 adds a calculation companion volume and a structured calculation register without replacing the existing 27-topic main report or changing the active MATLAB/Python source layout.

New deliverables:

- `Report/ENERGY008_Detailed_Calculation_Book_Rev0.2.docx`
- `Report/ENERGY008_Detailed_Calculation_Book_Rev0.2.pdf`
- `thinking/calculations/ENERGY008_Detailed_Calculation_Register_Rev0.2.xlsx`
- `thinking/calculations/ENERGY008_Calculation_Index_Rev0.2.csv`
- Five source-data exports for design basis, property records, streams, OAT outputs and LHS samples.
- `thinking/` index structure for calculations, prompts, reports, results and sources.

The calculation book is 57 A4 pages and contains:

- Canonical HC-001 to HC-018 hand-calculation cards.
- Supplemental CAL-001 to CAL-016 calculations.
- EQ-001 to EQ-028 equipment-tag calculation status cards.
- Twelve OAT study definitions and the 1,000-sample LHS description.
- Real-world case-study application notes for Kassø, Piteå and Skive.
- Thermodynamic, physical-model, equipment, utility, economic, environmental, safety and runtime hold points.

## 2. Source and data inventory used

| Record family | Count / scope | Evidence location |
|---|---:|---|
| Design-basis entries | 71 | `thinking/calculations/ENERGY008_Design_Basis_Register_Rev0.2.csv` |
| Property entries | 271 | `thinking/calculations/ENERGY008_Property_Register_Rev0.2.csv` |
| PFD stream entries | 55 | `thinking/calculations/ENERGY008_Stream_Register_Rev0.2.csv` |
| Source records | 74 | `Registers/Core/ENERGY008_Source_Register.xlsx` |
| OAT output metrics | 156 rows, 12 studies | `thinking/calculations/ENERGY008_OAT_Results_Rev0.2.csv` |
| LHS population | 1,000 samples, 8 dimensions | `thinking/calculations/ENERGY008_LHS_Samples_Rev0.2.csv` |
| Equipment datasheets | 28 | `Equipment_Datasheets/Prompt11_Detailed_Datasheets/` |

The original hand calculation report and workbook remain the canonical source for the HC identifier sequence. New derived calculations use CAL identifiers, and equipment status cards use EQ identifiers. This avoids silently reconciling older report-card labels where they differ from the workbook/fixture identifiers.

## 3. Independent numerical reconstruction scope

The calculation volume reconstructs the ideal stoichiometric reference around 50 t/day methanol component-equivalent, including CO2/H2 requirements, electrolyser water and oxygen, reaction water, elemental and rounded-molecular-weight mass closure, annual output, capacity ladder, conditioned dry-gas purity equivalents, Route B clean-CO reactor stoichiometry, standard-state reaction enthalpies, CO2 sensible heat, pure methanol latent heat, illustrative exchanger area, W-201 pump hydraulics, ELY-201 Faraday and electricity scenarios, K-201 ideal-gas compression, TK-401 inventory, electricity-only cost/emissions, and threshold arithmetic.

All values are labelled by evidence class. Stoichiometric calculations are not reported as physical plant stream flows. Standard-state reaction enthalpy is not treated as a plant energy balance or equipment heat duty. Equipment arithmetic is screening-only where vendor or site data are absent.

## 4. Document and spreadsheet verification

| Check | Result | Evidence / interpretation |
|---|---|---|
| DOCX generation | PASS | Editable Word calculation volume created. |
| DOCX render | PASS | Rendered to 57 page PNGs; contact sheets and selected full-page views inspected. |
| PDF conversion | PASS | PDF is 57 pages, A4 (595.3 x 841.9 pt), not encrypted. |
| PDF render | PASS | Independently rendered 57 PDF pages; contact sheet inspected. |
| Accessibility audit | 0 high / 69 medium | Medium findings are primarily table-header flags on one-cell callout layout tables; no high-severity finding was reported. |
| Calculation workbook | PASS in workbook QA | 19 sheets, key formula outputs inspected, formula-error scan returned zero errors in the workbook build verification. |
| Calculation index | PASS | 75 IDs/records across HC, CAL, EQ, OAT and LHS groups. |

## 5. Software and project checks rerun for this revision

| Check | Result | Scope limitation |
|---|---|---|
| `python tests/check_project_static.py` | PASS: 100 checks | Static project/data integrity only. |
| `python tests/check_gui_static.py` | PASS: 80 checks | GUI source-contract inspection; no GUI launch. |
| `python tests/check_prompt19_regression.py` | PASS: 50 checks | Independent fixture arithmetic; not model validation. |
| `PYTHONPATH=src python -m pytest -q` in `Python/` | PASS: 23 tests | CPython 3.13.5 environment; bounded software tests only. |
| MATLAB / GNU Octave startup | NOT RUN | Runtime not installed/available in this build environment. |
| MATLAB unit/integration suite | NOT RUN | Requires a supported licensed MATLAB runtime. |
| MATLAB GUI / HMI execution | NOT RUN | No runtime interaction, screenshots, fault injection or GUI export evidence. |
| MATLAB-Python runtime parity | NOT RUN | No live MATLAB result fixture exists. |

## 6. Package-tree organization

The added `thinking/` tree mirrors the requested CPS-088 working structure. Existing canonical folders remain in their original locations because MATLAB project configuration, tests, reports and historical evidence refer to them. The new `thinking/` folders contain organized calculation exports and index/readme files pointing to canonical source locations. No active runtime directory was relocated.

## 7. Engineering limitations carried forward

The following remain BLOCKED or NOT RUN and must not be promoted to calculated/validated physical results:

- G3 design-basis freeze and final site/source selection.
- Full independent evaluation of Route B and route ranking.
- Catalyst-matched R-301 kinetics and reactor sizing.
- PR78 mixture binary parameters, phase stability and V-301 flash validation.
- Methanol-water VLE, column MESH and T-401 sizing.
- Physical recycle/purge and K-301 compressor calculation.
- Complete physical 55-stream mass balance and plant energy, entropy and exergy closure.
- Vendor-confirmed equipment ratings and pressure/mechanical design.
- Site utility and water balance.
- Complete CAPEX/OPEX/LCOM.
- Carbon-origin documentation, lifecycle GHG boundary and MRV.
- Formal HAZOP/LOPA/SIL/QRA, relief design and statutory review.
- MATLAB runtime, GUI execution and MATLAB-Python parity.

The three real-world cases are contextual evidence only: Kassø for commercial Route C architecture; Piteå for syngas cleanup/catalyst-protection demonstration; Skive for upstream biomass gasification/CHP analogy. None is used as a direct ENERGY-008 equipment or performance guarantee.

## 8. Release disposition

The Rev 0.2 calculation companion and repository organization are suitable for the next user-side MATLAB GUI launch and engineering review, subject to all stated design and model hold points. The package is not a frozen plant design, validated physical process simulator, vendor rating, operating procedure, statutory submission, or certified safety design.
