# Calculation Working Package - Rev 0.2

## Primary calculation volume

- `../../Report/ENERGY008_Detailed_Calculation_Book_Rev0.2.docx` - editable 57-page calculation book.
- `../../Report/ENERGY008_Detailed_Calculation_Book_Rev0.2.pdf` - rendered review copy.
- `ENERGY008_Detailed_Calculation_Register_Rev0.2.xlsx` - structured 19-sheet calculation/data workbook.

## Controlled data exports

- `ENERGY008_Design_Basis_Register_Rev0.2.csv` - 71 design-basis records.
- `ENERGY008_Property_Register_Rev0.2.csv` - 271 property records.
- `ENERGY008_Stream_Register_Rev0.2.csv` - 55 PFD stream records.
- `ENERGY008_OAT_Results_Rev0.2.csv` - 156 OAT metric rows from 12 studies.
- `ENERGY008_LHS_Samples_Rev0.2.csv` - 1,000 deterministic samples over 8 dimensions.

## Original hand-calculation source

`../../Calculations/ENERGY008_Hand_Calculation_Report.md` and `../../Calculations/prompt17_manual_calculations/` remain the original source records. HC-001 to HC-018 in the detailed calculation book follow the hand-calculation workbook / frozen fixture as the canonical identifier sequence. Newly derived records use CAL-xxx identifiers; equipment status cards use EQ-001 to EQ-028.

## Status rule

A verified arithmetic check does not validate a physical process model. Screening, blocked and not-run results remain explicitly classified. Null stream/property values are not interpreted as zero.
