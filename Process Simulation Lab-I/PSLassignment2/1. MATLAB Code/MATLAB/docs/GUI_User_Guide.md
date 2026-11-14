# ENERGY-008 Engineering Model GUI User Guide

**Deliverable:** `MATLAB/gui/ENERGY008_App.m`  
**Launcher:** `MATLAB/run_gui.m`  
**Engine integration:** `MATLAB/gui_run_engine.m`  
**Status:** Prompt 20 source implementation; MATLAB runtime execution not performed in the build environment.

## 1. Purpose and operating boundary

The GUI exposes the Prompt 19 calculation modules through a tabbed engineering interface. It is an offline engineering and reference-calculation tool. It is **not** a live DCS, BPCS, PLC, SIS, ESD, FGS, SCADA or operating HMI. It has no field I/O, no package communication, and no start, stop, reset, bypass or setpoint command path.

The interface follows the Prompt 14 HMI design principles where applicable: state before action, explicit data quality and status, separation of basic process control from independent protection, alarm/interlock visibility, and no silent substitution of missing data. Since there are no live signals, the application reports live process state as unavailable rather than emulating it.

The current project remains Route C provisional, G3 Rev 0.1-DRAFT. The 50 t/day Route C case is an ideal stoichiometric reference and not an approved plant nameplate capacity. Physical stream conditions, process limits, alarm thresholds and trip thresholds remain TBD / BLOCKED.

## 2. MATLAB compatibility and prerequisites

The app is implemented programmatically using MATLAB UI components (`uifigure`, `uigridlayout`, `uitabgroup`, `uitab`, `uitable`, `uiaxes`, `uidropdown`, `uieditfield`, `uitextarea`, `uibutton` and `uialert`). No App Designer-generated `.mlapp` file or additional toolbox is required by the source design.

Use a MATLAB release that supports these UI components and the Prompt 19 runtime features, including `jsondecode`, `jsonencode`, tables, `writetable`, and workbook sheet inspection (`sheetnames` or `xlsfinfo`). The minimum supported release has **not** been confirmed by an actual runtime test. SHA-256 verification requires an enabled JVM. Record the MATLAB release, OS and JVM availability when executing the test procedure.

Extract the complete project folder without changing its internal directory structure. Do not copy only the `MATLAB` folder: the engine also uses the project-level `data`, `outputs`, `logs`, and `.energy008-root` files.

## 3. Launch

1. Open MATLAB.
2. In MATLAB's Current Folder panel, navigate into the extracted project's `MATLAB` subfolder so `run_gui.m` is on the current folder path.
3. Run:

   ```matlab
   app = run_gui;
   ```

4. The launcher resolves the project root from its own file location and the `.energy008-root` marker. It does not use `pwd` or `genpath`. It adds only the configured engine directory and `MATLAB/gui` directory to the MATLAB path.
5. Keep the returned `app` variable in the workspace while using the interface. Closing the application window releases the GUI object.

If launch fails during project-data loading, inspect the exact MATLAB error. Do not bypass the manifest, schema, allowed-root or SHA-256 checks.

## 4. Tabs and data displayed

| Tab | Function | Key scope limitation |
|---|---|---|
| Design Basis | Select a registered case; enter throughput and operating hours; review design basis and provenance | Throughput is a user-selected reference/scenario basis, not an approved capacity |
| Streams | Display the calculated stoichiometric component/ledger table | Not the 55-stream physical PFD stream table; physical states remain null / blocked |
| Operating Conditions | Display known screening references and physical-state status | No temperature, pressure, controller setpoint, alarm limit or trip limit is assigned |
| Process Model | Display availability of property, reaction, kinetic, flash, recycle and dynamic models | PR78, methanol-water VLE, reactor kinetics, physical recycle and dynamic control remain blocked |
| Balances | Display component-ledger mass closure, C/H/O closure, reference enthalpy calculations and entropy/exergy blockers | No plant-wide energy, entropy or exergy closure is asserted |
| Equipment | Display equipment register and the two explicitly illustrative Prompt 17 checks | HX-A01 and W-201 calculations are screening examples, not actual package datasheets or ratings |
| Utilities & Environment | Display utility register, theoretical water/O2 references and environmental KPI status | Electricity, cooling, steam, emissions and certification remain blocked without measured/site/vendor inputs |
| Economics | Display CAPEX/OPEX/LCOM calculation status and blockers | No generic cost correlation, tariff or cost estimate is invented |
| Automation & Control | Display DB-059 disturbance arithmetic and Prompt 14 candidate register counts | No live control, alarm, trip, permissive, bypass or first-out data are connected |
| Sensitivity & Optimisation | Display the versioned 45/50/55 t/day throughput sensitivity table and plot | Linear stoichiometric reference scaling only; nonlinear optimisation and capacity feasibility are blocked |
| Reports | Display run metadata, export files and run traceability | Exports contain only outputs created by modules that actually completed |

## 5. Inputs and unit handling

The case dropdown reads the controlled case records loaded by the Prompt 19 input loader. The registered cases include the Route A common-core comparator, the explicitly blocked Route B biomass/syngas alternative, the Route C 50 t/day ideal reference, and the Route C 25 t/day turndown screening case.

The throughput field accepts either `kg/day` or `t/day`. Changing the unit dropdown converts the displayed value using `unit_conversions.m`. The engine receives the value in `kg/day`. The operating-hours field is in `h/day` and must be greater than zero and no greater than 24.

The selected throughput and operating hours are recorded as GUI-selected inputs. A changed throughput scales the selected stoichiometric reference basis only; it does not create a new physical plant design. The GUI does not provide editable physical process temperature or pressure fields because the selected case currently carries those values as null / BLOCKED.

## 6. Calculation behaviour

The Run / Calculate button invokes `gui_run_engine.m`. This orchestration function calls the existing calculation modules; it does not contain process balance, thermodynamic, kinetic, equipment-sizing or cost equations. The main callbacks perform input checks and display results only.

For the Route C 50 t/day base reference, the frozen Prompt 17 regression fixture can be executed by `validation_checks.m`. The fixture is not run for Route A, Route C 25 t/day or user-modified throughput values because those inputs are outside the fixture's exact basis. The GUI marks this fixture validation as `NOT_RUN` for those cases; it does not show a false pass or compare them against the wrong reference values.

Route B remains `BLOCKED`. A blocked case is displayed as blocked, not as a successful design and not as a zero-flow result.

The normal result status for an executable reference case is `COMPLETED_WITH_BLOCKED_PHYSICAL_CALCULATIONS`. This is a warning state, not a fully successful physical process design. It means only the available reference/screening calculations ran; the physical flowsheet is not validated and Prompt 21 remains mandatory.

## 7. Provenance and uncertainty labels

The GUI distinguishes these classes:

- **SOURCED:** values imported from the versioned property, reaction, equipment or utility records with source identifiers.
- **CALCULATED:** quantities calculated by the engine from declared inputs and versioned methods.
- **FITTED:** no fitted kinetic or VLE parameter set is currently active.
- **ASSUMED:** user-selected reference basis and explicit screening assumptions.
- **ESTIMATED:** no plant estimate is currently enabled.

The energy tab shows source-propagated thermochemical uncertainty where it is available. This uncertainty does not include throughput uncertainty, model-form uncertainty, phase-equilibrium uncertainty, plant-state uncertainty or covariance. Equipment-screening assumptions are identified as assumptions. No absent uncertainty is represented as zero.

## 8. Export behaviour

After an engine run, the project creates a unique run ID and non-overwriting output locations:

- `outputs/<run_id>/`: GUI run metadata and copied run logs.
- `logs/<run_id>.json` and `logs/<run_id>.log`: project run log records.
- `MATLAB/results/<run_id>/`: numerical result exports, table exports, module diagnostics, run summary and available plots.

Depending on which modules completed, the report directory may include:

- `material_reference_flows.csv`
- `element_closure.csv`
- `reaction_species_balance.csv`
- `equipment_datasheet_register.csv`
- `equipment_screening_examples.csv`
- `energy_reference_summary.csv`
- `utility_register.csv`
- `environmental_kpis.csv`
- `throughput_sensitivity.csv`
- `scenario_status.csv`
- `fixture_test_results.csv` (only when the fixture test actually ran)
- `module_status.csv`
- `reference_engine_results.xlsx` (optional, if workbook export is supported)
- `reference_mass_flows.png` (optional, if figure export is supported)
- `run_summary.json`, `module_diagnostics.json`, and `gui_run_metadata.json`

The Reports tab shows run metadata plus module statuses, warnings and detailed errors. The Export run button copies the current report directory and GUI logs/metadata to a user-selected destination. It refuses to overwrite an existing run-ID folder. The component/ledger CSV is not a solved 55-stream plant stream table.

## 9. Error and failure interpretation

- `INPUT INVALID`: the user-entered throughput or operating hours failed GUI validation. No calculation is started.
- `RUN_FAILED`: project preflight, input validation, an engine module or export operation failed. Review the exact identifier/message in the status panel and run logs.
- `BLOCKED_SELECTED_CASE`: the selected route/case has no supported material model. No downstream process results are fabricated.
- `COMPLETED_WITH_BLOCKED_PHYSICAL_CALCULATIONS`: supported reference/screening modules completed, but plant-level physical models remain blocked.
- Module-level `BLOCKED`, `FAILED`, `NOT_RUN`, `REFERENCE_ONLY` and `SCREENING_ONLY` statuses are retained and displayed in the exports.

A missing input is not replaced with zero. A status message is not a control-system indication. The GUI has no live process connection and cannot acknowledge alarms or reset protection systems.

## 10. Test procedure for Prompt 21

Run these checks in a disposable copy of the complete project. Preserve all run IDs and output folders as evidence.

### A. Startup and layout

1. Record MATLAB release, operating system, JVM availability and display resolution.
2. Launch with `app = run_gui;` from a different current folder as well as from the project folder.
3. Confirm that startup resolves the project from `run_gui.m`, not from the current folder.
4. Confirm all eleven tabs are visible and scroll/layout behaviour is acceptable at a normal desktop resolution (target test resolutions: 1366x768 and 1920x1080).
5. Confirm no fields imply a live PV/SP/OP or live trip state.

### B. Valid reference runs

1. Select the Route C 50 t/day ideal reference and run with 50,000 kg/day, 24 h/day.
2. Verify input, property, material, energy, equipment, utility, control, scenario, sensitivity, validation and report module statuses.
3. Confirm the status banner remains a warning/completion-with-blockers state, not a green validated-design state.
4. Confirm the Prompt 17 fixture is executed only for this exact basis and its 18 checks are retained in the exported fixture test table.
5. Select Route A and the Route C 25 t/day screening case. Verify the fixture is `NOT_RUN` and results are labelled common-core reference or turndown screening as appropriate.

### C. Empty and invalid inputs

For each test, verify the GUI rejects the input before invoking the calculation engine and does not retain old results as current:

- Empty / nonnumeric throughput edit value, where the MATLAB UI component permits entry of an empty value.
- Throughput equal to zero.
- Negative throughput.
- NaN or Inf throughput, where accepted by the edit field.
- Operating hours equal to zero.
- Negative operating hours.
- Operating hours greater than 24.

Also test both unit directions (`kg/day` to `t/day` and back) and confirm the physical basis is unchanged after conversion.

### D. Missing-data and failure states

In a disposable project copy only:

1. Launch the GUI successfully first. Then, in the disposable project copy, remove or rename one required case file and press Run / Calculate. Confirm the preflight returns `RUN_FAILED` with a file/input error rather than silently selecting another file.
2. Modify a manifest-governed data file without updating its expected SHA-256 and confirm hash mismatch stops calculation.
3. Remove write permission from a temporary output location and confirm export failure is captured in the run log.
4. Select Route B and confirm its result is `BLOCKED_SELECTED_CASE`, with no material-flow table populated with zero values.
5. Confirm failed calculation modules do not produce green pass indicators or stale previous-run tables.

### E. Repeated runs and traceability

1. Run the same case twice.
2. Confirm different unique run IDs and separate output/log directories.
3. Confirm no existing run file is overwritten.
4. Check `gui_run_metadata.json`, `run_summary.json`, `module_diagnostics.json`, project logs and exports for case ID, selected input basis, timestamp, MATLAB release, model version, data version, design-basis version, assumptions and module statuses.
5. Export a run to a new directory; then repeat to the same destination and confirm the overwrite guard rejects the second export.

### F. Runtime evidence capture

Save screenshots from the actual MATLAB application after (i) initial startup, (ii) the completed Route C reference run, (iii) the Route B blocked state, and (iv) the reports tab. Record the MATLAB release and include the exact run directories and logs.

**No MATLAB runtime test, GUI screenshot or MATLAB-generated export example has been produced in the current build environment.** The checks above are the execution procedure, not claimed test results.

## 11. Prompt 21 handoff

Prompt 21 should independently verify the physical process model and separately run the GUI verification procedure above. Do not interpret UI availability, a reference fixture pass, a static source check or a successful CSV export as physical-model validation, HMI FAT/SAT, SIS proof testing or operational readiness.
