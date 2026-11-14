# ENERGY-008 Prompt 26/27 Implementation and User Handoff

**Updated:** 03 November 2026  
**Canonical project:** `ENERGY-008_Submission/`  
**Basis:** Prompt 26 case-study integration and targeted release corrections. This update does not change the approved engineering basis or claim physical model validation.

## Real-world case-study application

- **Kassø, Denmark:** commercial e-methanol precedent integrating renewable electricity/electrolysis, biogenic CO2, synthesis, purification, storage/offtake and certification interfaces. Used only as Route C architecture evidence. No capacity, purity, energy intensity or equipment value is transferred into the ENERGY-008 design basis.
- **Piteå, Sweden:** black-liquor gasification syngas-to-methanol/DME demonstration. Used to define Route B front-end requirements: feed assay, gas composition/yield, particulate/tar/sulphur cleanup, syngas ratio adjustment and catalyst protection. It is not treated as a commercial agricultural-residue methanol plant.
- **Skive, Denmark:** biomass gasification CHP analogue. Used only for upstream gasification, reforming and energy-integration context. It is not treated as methanol synthesis evidence.

The full source note is `Sources/Engineering_Notes/ENERGY008_Real_World_Case_Studies.md`; the report includes a corresponding appendix. The MATLAB GUI Design Basis tab now displays these case-study applications and limitations.

## Corrections applied

1. Updated README and open-issues evidence cutoff to 03 November 2026.
2. Replaced the repository compliance workbook with the Prompt 26 workbook.
3. Updated the audit report to distinguish the historical 121-page Prompt 24 render-QA baseline from the current 123-page Prompt 26 PDF. The historical render-QA record remains preserved as a historical record, not rewritten as a new visual inspection.
4. Updated the presentation's report-length metric from 121 to 123 pages.
5. Added concise case-study application notes to the MATLAB GUI Design Basis tab.
6. Updated the manifest-generation metadata for the current 123-page report and retained the manifest self-exclusion rule.
7. Re-ran the Python regression suite, repository static checks and local-link/document/PDF link audit.

## Re-executed checks

| Check | Result | Scope |
|---|---:|---|
| Python unit/regression suite | PASS, 23/23 | CPython 3.13; `Python/tests` only |
| Project static integrity | PASS, 100 checks | 55 hashed datasets and project/data contracts |
| GUI static source contract | PASS, 80 checks | Static source inspection only; no MATLAB parser/runtime |
| Independent arithmetic regression | PASS, 50 checks | Frozen reference fixtures only |
| Markdown/local link audit | PASS | 102 Markdown files; 28 local links |
| DOCX internal-link audit | PASS | 103 bookmarks; 133 internal anchors; no external file links |
| PDF link/page audit | PASS | 123 pages; 133 internal links; no out-of-range targets |
| MATLAB startup, unit suite and GUI launch | NOT RUN | Requires user's installed MATLAB runtime |
| MATLAB/Python runtime parity | NOT RUN | Requires MATLAB outputs from the user's machine |

## User execution sequence

1. Extract the complete ZIP. Keep `.energy008-root`, `data/` and `MATLAB/` in the same repository root.
2. In MATLAB, open and run `MATLAB/START_HERE.m`.
3. In the MATLAB Command Window, run:

```matlab
run(fullfile(ENERGY008_PROJECT_ROOT, 'MATLAB', 'tests', 'run_startup_smoke_test.m'))
run_prompt19_tests(ENERGY008_PROJECT_ROOT)
app = run_gui;
```

4. In the GUI, inspect the Design Basis, Streams, Operating Conditions, Process Model, Balances, Equipment, Utilities, Economics, Automation, Sensitivity and Reports tabs. Run the registered cases one at a time, then test reset and export behavior.
5. Retain MATLAB release/version, operating system, startup output, test output, run IDs, exported files, screenshots and any error stack traces. Do not relabel blocked physical modules as passed.

## Remaining engineering limitations

Route B remains blocked. Gate 3 and route selection are not frozen. Catalyst-specific kinetics at the draft pressure, high-pressure PR78 mixture parameters/phase stability, methanol-water VLE, physical recycle/purge, full stream states and plant-wide mass/energy/entropy/exergy closure, vendor ratings, site utility/water data, complete CAPEX/OPEX, emissions MRV and formal HAZOP/LOPA/SIL/QRA remain open. The GUI is an engineering reference interface, not a live DCS/PLC/SIS/FGS or operating HMI.
