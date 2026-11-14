# ENERGY-008 Prompt 20 GUI layer

## Source files

- `ENERGY008_App.m`: programmatic MATLAB `uifigure` application and eleven engineering tabs.
- `../run_gui.m`: project-root-aware launcher. Adds only the configured engine folder and this GUI folder.
- `../gui_run_engine.m`: run orchestration layer. Calls the Prompt 19 modules and manages unique run metadata/log/export directories.

## Layer boundary

GUI callbacks collect user input, validate UI-level ranges, call `gui_run_engine`, and render returned module results. They do not implement material-balance, thermodynamic, kinetic, equipment-sizing, utility, economics, or optimisation equations. Unit conversion is delegated to `unit_conversions.m`.

The app is an offline engineering/reference interface, not a live DCS, BPCS, PLC, SIS, ESD, FGS, SCADA or operating HMI. There is no field I/O or command interface. Prompt 14 candidate loop/alarm/cause-effect register counts are shown as candidate design inputs only; no setpoints, alarm limits, trips, bypasses, fail positions or control actions are invented.

The GUI's Streams tab shows the engine's stoichiometric component/ledger table. It does not claim to show the conceptual 55 physical PFD stream states. Missing stream states and unsupported physical models remain blocked/null.

## Runtime status

The source was built and statically inspected in an environment without MATLAB or GNU Octave. MATLAB parsing, release compatibility, component behavior, actual engine calls, plots, export operations, repeated runs and screenshots remain unverified until Prompt 21 executes the supplied procedure in a real MATLAB installation.
