# Prompt 20 GUI handoff to Prompt 21

**Project:** ENERGY-008  
**GUI source:** `MATLAB/gui/ENERGY008_App.m`  
**Launcher:** `MATLAB/run_gui.m`  
**Engine orchestration:** `MATLAB/gui_run_engine.m`  
**User guide / test procedure:** `MATLAB/docs/GUI_User_Guide.md`

## Delivered

- Programmatic MATLAB UI with tabs for Design Basis, Streams, Operating Conditions, Process Model, Balances, Equipment, Utilities & Environment, Economics, Automation & Control, Sensitivity & Optimisation, and Reports.
- Unit-aware throughput entry (`kg/day` or `t/day`) and operating-hours entry (`h/day`); controlled conversion delegates to `unit_conversions.m`.
- Case selection from versioned case records. Blocked Route B remains explicitly blocked.
- Run/Calculate, Reset defaults, input validation messages, calculation status, warnings/errors and export current run.
- Engine orchestration delegates to Prompt 19 public modules and contains no duplicated process equations.
- Per-run metadata, logs, visible module diagnostics/warnings/errors, numerical table exports, equipment screening export, energy reference export and available plots.
- Unique run IDs and non-overwrite checks for output directories/files.
- Read-only automation/control tab reflecting Prompt 14 boundaries; no live DCS / PLC / SIS / FGS link or field command.
- Conditional Prompt 17 fixture regression. It is run only for the exact Route C 50 t/day base fixture. Other cases are marked `NOT_RUN` rather than compared against an inapplicable fixture.

## Engineering boundaries retained

- The 55 PFD streams are not solved. The GUI's stream table is the stoichiometric component/ledger reference only.
- S-209 recycle, S-207 purge, PR78 flash, methanol-water VLE, R-301 physical kinetics, physical equipment sizing, actual utilities, plant entropy/exergy closure, MRV and CAPEX/OPEX remain blocked where their input gates are unresolved.
- HMI setpoints, alarms, trips, delays, voting, valve fail positions and controller states are not invented.
- No GUI interaction can control or reset a physical process or independent protection layer.
- A reference fixture pass is not physical-process validation.

## Static verification performed in this build environment

- File/structure/source-contract checks are performed by `tests/check_gui_static.py`; Prompt 19 regression/static checks remain available under `tests/`.
- Python syntax checks are not MATLAB syntax checks. The MATLAB class, callbacks, UI component compatibility, module runtime calls, plotting, `uialert`, workbook export, file permissions and repeated-run behaviour remain unexecuted.
- Neither MATLAB nor GNU Octave is available in the build environment. No claim is made that the GUI has been launched or runtime-tested.
- No actual MATLAB GUI screenshots or MATLAB-generated example exports are included. This avoids representing synthetic or hand-entered values as current solver results.

## Required Prompt 21 actions

1. Execute the procedure in `GUI_User_Guide.md` using the target MATLAB release; capture release/JVM/OS details.
2. Run the exact Route C base reference; verify the Prompt 17 fixture gate and all GUI module statuses.
3. Test Route A, Route C turndown, blocked Route B, invalid/empty inputs, missing data/hash mismatch, failed exports and repeated runs.
4. Inspect every export and confirm run ID, case ID, timestamp, MATLAB version, model/data/design-basis versions, assumptions, provenance and warnings persist.
5. Independently verify the physical process model against independent sources, stream data, property/kinetic models, residuals, uncertainty and validation criteria. Keep GUI verification separate from process-model V&V.
6. Do not upgrade the status to validated, approved for operation, FAT/SAT complete or safe for operation without the relevant independent evidence and approvals.
