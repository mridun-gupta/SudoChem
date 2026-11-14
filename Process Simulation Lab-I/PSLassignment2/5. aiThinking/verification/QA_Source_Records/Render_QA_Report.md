# ENERGY-008 Final Render and Engineering QA Report

**Report ID:** ENERGY008-REP-001  
**Revision:** 1.0  
**QA date:** 02 November 2026  
**Result set:** MODEL-0.1.0 / DATA-0.1.0 / report Rev 1.0  
**Status:** Render QA passed; engineering acceptance remains conditional on the open items below.

## 1. Final artefact checks

| Check | Result | Evidence / note |
|---|---|---|
| Word technical report | PASS | Editable DOCX; 121 rendered A4 pages; 5.2 MB; 149 Word tables; 26 embedded media objects |
| PDF review copy | PASS | Rendered from the final Word source; 121 pages; A4 (595.3 × 841.9 pt); not encrypted |
| Report structure | PASS | All original assignment topics 1–27 appear in exact numeric order; Appendix A–F follow the technical topics |
| Table of contents | PASS | 27 topic page references and six appendix references updated from the final rendered PDF; internal links retained |
| List of figures | PASS | 33 entries; each caption verified on its listed page; Figure 19 points to its second occurrence on page 36 |
| List of tables | PASS | 30 entries; each caption verified on its listed page; duplicate table numbering in list text removed |
| PDF navigation | PASS | 382 outline/bookmark entries and 133 PDF annotations/links detected |
| Bibliography | PASS | 74 source-register references; matching CSV reference list and BibTeX bibliography included |
| Presentation | PASS | Editable 16-slide PPTX; current report length shown as 121 pages |
| Slide overflow | PASS | `slides_test.py`: “Test passed. No overflow detected.” |
| PDF rendering | PASS | Rendered at 110 dpi; 121 pages created; PDF inspection found no encryption and A4 page sizes |
| Visual inspection | PASS | Cover, control page, executive summary, design basis, TOC, figure/table lists, nomenclature, technical sections, worked calculations, datasheet appendix, sensitivity figures, automation/safety appendix, limitations, and final references pages inspected |
| Source material handoff | PASS | Assignment, design/technical registers, source code, editable diagram sources, engineering notes, 28 detailed equipment datasheets and phase evidence ZIPs included |

## 2. Assignment topic coverage

All 27 assignment topics are present in the exact order and retain the original topic titles. The rendered page map is:

| Topic | Title | PDF page |
|---:|---|---:|
| 1 | Assignment Purpose | 8 |
| 2 | Core Problem Statement | 9 |
| 3 | Project-Specific Technical Scope | 9 |
| 4 | Engineering Inputs and Data | 10 |
| 5 | Governing Equations and Model Formulation | 11 |
| 6 | Numerical Algorithm | 12 |
| 7 | Material Balances | 14 |
| 8 | Energy Balance and Thermal Design | 15 |
| 9 | Entropy Balance | 16 |
| 10 | Exergy Balance | 17 |
| 11 | Detailed Equipment Selection and Design Calculations | 18 |
| 12 | PFD and P&ID-Level Definition | 18 |
| 13 | Industrial Process Automation and Control | 24 |
| 14 | PLC/DCS, HMI, Sequencing and Alarm Requirements | 25 |
| 15 | Utilities, Environment and Waste | 27 |
| 16 | CAPEX Screening | 28 |
| 17 | OPEX Screening | 29 |
| 18 | Sensitivity Analysis | 29 |
| 19 | Flowchart Requirements | 33 |
| 20 | MATLAB Modular Architecture | 36 |
| 21 | GUI Requirements | 37 |
| 22 | Variable Dictionary and Units | 37 |
| 23 | Verification and Validation | 38 |
| 24 | Python/Open-Source Migration Requirements | 39 |
| 25 | Technical Report Structure | 40 |
| 26 | Final Submission Package | 40 |
| 27 | Acceptance Checklist | 41 |

**Interpretation:** the structure and evidence discussion cover every topic, but the report does not claim that every engineering acceptance item is passed. The report identifies the outstanding items as BLOCKED, NOT RUN, SCREENING ONLY, FAIL or TBD where applicable.

## 3. Verification evidence: do not merge unlike test populations

| Evidence population | PASS | FAIL | BLOCKED | NOT RUN | SCREENING ONLY | Total |
|---|---:|---:|---:|---:|---:|---:|
| Prompt 21 curated verification register | 40 | 2 | 14 | 19 | 7 | 82 |
| Separate independent Python assertion audit | 80 | 2 | 1 | 5 | 27 | 115 |
| Prompt 23 Python pytest suite | 23 passed | 0 reported failures in the recorded run | N/A | N/A | N/A | 23 tests |

The curated Prompt 21 register and the separate 115-assertion Python audit are different populations and must not be combined. The Python migration README records 23 passing pytest tests and successful comparison against the frozen hand-calculation fixture. MATLAB-to-Python runtime parity remains NOT RUN. Thirty-one MATLAB source-defined checks remain NOT RUN because MATLAB/Octave runtime evidence was unavailable. GUI runtime and physical process-model integration were not demonstrated.

## 4. Preserved engineering blockers and interpretation limits

1. The design basis remains Rev 0.1-DRAFT; Gate 3 is not frozen and the site is not selected. Route C is a working academic reference, not an approved route selection.
2. Route A is a common downstream-core comparison only. Route B biomass gasification/syngas-to-methanol remains BLOCKED. The complete base-plus-two-alternative route comparison is not achieved.
3. The 55-row stream register does not contain solved physical flows/states/compositions. Physical recycle S-209, purge S-207 and separator phase split remain BLOCKED. The ideal stoichiometric block is not a complete plant mass balance.
4. The draft synthesis pressure is 70 bar(a), beyond the identified Graaf and Vanden Bussche/Froment kinetic data ranges (about 50–51 bar). Reactor kinetics at the draft point are not validated.
5. Complete high-pressure mixture EOS/binary interaction data, phase-stability verification and methanol-water VLE are unavailable. No high-pressure physical-property/flash/distillation solution is claimed.
6. Entropy generation, physical/chemical exergy, full plant entropy/exergy closure and a defensible exergy-destruction ranking remain BLOCKED.
7. Equipment calculations are screening/reference checks. No vendor datasheet, performance map, relief sizing, code verification or equipment guarantee is asserted. Several major equipment ratings remain blocked.
8. Heat integration is conceptual; no validated plant heat duties, stream composite curves or pinch target are claimed. HX-301 remains a candidate only.
9. Utility/environment registers are qualitative or bounded in selected examples. Full site utility consumption, wastewater/emission rates, carbon MRV and regulatory certification remain unresolved.
10. Full CAPEX/OPEX and levelised methanol cost are BLOCKED. The economic figure is electricity-only scenario screening and excludes the remaining cost components.
11. Prompt 22's 12 OAT studies and 1,000-point, eight-variable Latin Hypercube are screening proxies. LHS P05/P50/P95 values are conditional scenario quantiles under independent uniform input ranges, not confidence intervals, physical-solver predictions or a plant optimum.
12. The automation documents are conceptual design records. No PLC/DCS runtime test, HAZOP/LOPA/SIL/QRA, certified safety function or approved operating procedure is claimed.
13. No MATLAB GUI/runtime test is claimed. The migration is partial; Python tests do not establish MATLAB parity or physical plant validation.

## 5. Visual and file QA

The final Word file was rendered to PDF, and the PDF was independently rendered to page images. Representative pages covering the front matter, topic sections, diagrams, calculation trail, datasheets, sensitivity appendix, control/safety records and final references were reviewed. PDF metadata check: 121 pages, A4 page dimensions, no encryption, 382 outline entries and 133 annotations. The PPTX was rendered to a 16-slide montage and checked; automated overflow validation passed.

## 6. Release recommendation

**Release for academic review as a clearly qualified preliminary engineering submission.** Do not represent this package as a frozen plant design or as having passed all 27 engineering acceptance criteria. Resolve the design-basis gate, kinetic/property model gaps, missing process balances, Route B alternative, site/vendor data, MATLAB runtime and formal safety/regulatory studies before any stronger design or compliance claim.


## 7. Prompt 24 finalization addendum (02 November 2026)

A final front-cover declaration block was added to make the submission declaration and review state explicit. It identifies the prepared-by candidate, leaves the candidate signature field blank for signing, and marks faculty review as pending. The declaration expressly states that the work is a preliminary academic study and does not represent professional approval, vendor guarantee, statutory compliance or certified safety integrity. No engineering values, assumptions, model outputs, source references, figure/table captions, or design-basis statuses were changed.

The Word file was re-rendered after this addition. The render remained 121 A4 pages; pages 2–121 were pixel-identical to the pre-addendum Word render, so the static TOC page references and figure/table page maps remain unchanged. The updated PDF was separately rendered at 110 dpi (121 pages), and the cover, TOC page, representative calculation pages, final references page and all available page-contact sheets were inspected. The presentation was re-rendered as 16 slides and `slides_test.py` again reported: `Test passed. No overflow detected.`

**Updated artifact hashes:** see `Result_Version.json` and `Manifest.csv`. Engineering acceptance remains conditional on the BLOCKED, FAIL, NOT RUN and SCREENING ONLY items already listed in this report.


## 6. Prompt 24 local-session reconciliation

The canonical files have been reconciled against the current materialized library artefacts and the final handoff archive. The current Word, PDF and PowerPoint files are copied to the requested canonical names and their byte counts/SHA-256 hashes are recorded in `QA/Result_Version.json`.

| Additional check | Result | Evidence |
|---|---|---|
| DOCX source rendering | PASS | `render_docx.py` generated 121 page images; a full 121-page contact-sheet review was performed, followed by full-size checks of representative cover, contents, technical, calculation, datasheet, figure, safety, limitation and reference pages. |
| Word-to-PDF text/page reconciliation | PASS | A fresh PDF export from the canonical DOCX has 121 A4 pages; extracted text was compared page-by-page with the canonical review PDF: 0 differing pages. Both have identical page dimensions. File hashes differ because the PDF exports carry different serialization/metadata. |
| PDF metadata | PASS | 121 pages; A4 (595.3 × 841.9 pt); not encrypted; 382 outline/bookmark entries; 133 annotations/links. |
| Presentation rendering | PASS | All 16 slides rendered to PNG and visually inspected as a montage. |
| Presentation overflow | PASS | A fresh run of `slides_test.py` returned: “Test passed. No overflow detected.” |
| Report citations vs source list | PASS | All 74 source IDs (`SRC-001` through the source-register ID set) were found in the report; all 74 IDs exist in the CSV reference list; no missing or unknown citation IDs. |
| BibTeX completeness and syntax | PASS | The prior `.bib` file contained only 27 entries. It has been replaced with a complete 74-record BibTeX export, one entry per source-register ID. Biber 2.20 data-model validation completed with no warnings or errors. Undated online records retain an explicit note that the date fields represent retrieval date only. |
| Release metadata | PASS | `Result_Version.json` and `Manifest.csv` were recalculated against the current final package files. |

The 121-page document review identified several intentionally sparse figure-only pages and some datasheet continuation pages. These carry numbered figures or required equipment-datasheet content; they are not empty pages. No clipped tables, broken glyphs, or page-level overlaps were observed in the reviewed rendered pages. The report's formal serif typography, blue heading hierarchy, shaded identification table, page numbering, TOC, and internal navigation remain intact.

## 7. Prompt 25 handoff status

The deliverable package is assembled under `ENERGY008_Submission/` when zipped. It includes the editable report, review PDF, 16-slide presentation, 74-source CSV and BibTeX, source and property registers, figure/table registers, 28 preliminary equipment datasheets, source diagrams in editable and rendered formats, MATLAB/Python source and evidence, engineering notes, original assignment, result-version record, this QA report and the package manifest.

**Handoff decision:** Pass the package to Prompt 25 for repository integration and final audit. This is a document/package handoff, not engineering design acceptance. All blockers and qualification statuses in Sections 3–4 remain active.
