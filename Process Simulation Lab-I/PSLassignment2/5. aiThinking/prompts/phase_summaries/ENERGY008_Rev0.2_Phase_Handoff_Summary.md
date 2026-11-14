# ENERGY-008 Rev 0.2 - Phase Handoff Summary

## Governing baseline

- Assignment: `Original_Assignment/PSLassignment2.pdf`, Topics 1-27.
- Main report: `Report/ENERGY008_Technical_Report.docx` and `.pdf`, Rev 1.0.
- Calculation companion: `Report/ENERGY008_Detailed_Calculation_Book_Rev0.2.docx` and `.pdf`.
- Calculation/data workbook: `thinking/calculations/ENERGY008_Detailed_Calculation_Register_Rev0.2.xlsx`.
- Design basis: Rev 0.1-DRAFT; Gate 3 not frozen.

## Phase outputs

1. Assignment extraction and traceability baseline are retained in `Sources/Engineering_Notes/ENERGY008_Assignment_Extraction.md` and `Registers/`.
2. Route selection and design-basis inputs are carried in `Registers/Core/ENERGY008_Design_Basis.xlsx` and `Sources/Engineering_Notes/ENERGY008_Route_Decision_Report.md`.
3. Chemistry, process, streams and hand calculations are retained in `Calculations/`, the reaction/property registers, and the 55-stream register.
4. Equipment, heat integration, utilities, automation, safety and environmental records are retained in their canonical root directories.
5. Sensitivity/uncertainty screening includes 12 OAT studies and 1,000 deterministic LHS samples; it remains a screening proxy.
6. MATLAB engine and GUI source are retained in `MATLAB/`; actual MATLAB/Octave GUI runtime remains NOT RUN in the audited environment.
7. Python migration, tests and CLI outputs are retained in `Python/` and `Logs/`; the recorded 23-test run does not prove plant-model validity or MATLAB parity.
8. Real-world case-study records for Kassø, Piteå and Skive are retained in `Sources/Engineering_Notes/ENERGY008_Real_World_Case_Studies.md`.
9. Rev 0.2 expands the calculation trail without changing the original Rev 1.0 main report or freezing unresolved design decisions.
10. The final ZIP and manifest are regenerated only after the complete repository content is frozen.

## Outstanding gates

See `QA/ENERGY008_Open_Issues.md`. Principal P1 items are route/G3 approval, catalyst kinetics, PR78 mixture EOS, methanol-water VLE, recycle/purge, plant-wide balances, equipment/vendor data, utilities/water, economics, MRV and formal process safety. MATLAB runtime, GUI and live MATLAB-Python parity are NOT RUN.
