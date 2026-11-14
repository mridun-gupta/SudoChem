# CPS-22 R4 | NRTL-SRK High-Pressure Separation

## Important: use a clean extraction
This release is deliberately self-contained and uses one canonical reference-data file. Do not merge it into a previous CPS-22 directory.

1. Close every MATLAB session.
2. Extract `CPS22_Industrial_MATLAB_R4.zip` into a new folder.
3. In MATLAB, open the extracted `CPS-22_Industrial_MATLAB_R4/START_HERE.m` file and press **Run**.
4. Check the startup message: it must say `CPS-22 R4 project activated` and `CSV schema check: PASS` with 207 rows and isobars 100, 101, 300, 500, 700, 1500, 2000 kPa.
5. Run tests from the launcher menu, or run `CPS22_Launcher('tests')` after starting from the R4 folder.

Do not first run `main` from an older `CPS-22_Industrial_MATLAB - Copy` folder. A legacy folder can still contain the old `main.m` and malformed CSV. The launcher changes Current Folder to the release root, prioritises this release's code, clears cached modules, and checks which file MATLAB resolves.

## Entry points
- `START_HERE.m`: recommended one-click entry point.
- `CPS22_Launcher.m`: `standard`, `industrial`, `gui`, `tests`, or `diagnose` modes.
- `main.m`: standard calculation workflow.
- `main_industrial.m`: detailed calculation-register workflow.
- `run_gui.m`: GUI entry point.

## Fixed folder structure
- `data/default_case.json`: default engineering input/model configuration.
- `data/CPS22_reference_vle_expanded.csv`: canonical multi-source experimental VLE data with 18 explicit headers and 207 measurements; the source-specific 2021 data remain in `CPS22_reference_vle_2021.csv`.
- `data/validation_reference_data.csv`: compatibility copy of the same canonical data; not selected by R4 code.
- `src/`: calculation engine and file/data utilities.
- `gui/`: GUI.
- `tests/`: tests and data-reader regression tests.
- `validation/`: independent reference files and diagnostics.
- `results/`: generated tables, MAT data, diagnostics and plots.

## Path policy
No absolute machine-specific path is stored in the JSON. Paths are assembled from the location of `mfilename('fullpath')`. The reference data path is pinned in `cps22_load_config.m` to the versioned canonical CSV. R4 does not recursively search sibling folders or use a legacy CSV as a fallback.

## CSV handling
`cps22_read_reference_data.m` parses actual CSV lines and quoted fields itself; it does not depend on `readtable` for the canonical VLE data. It verifies pressure unit, temperature, compositions, finite values, and binary closure. A malformed/unnamed file fails early with the exact selected path and corrective instruction instead of being treated as `Var1...VarN`.

## Scientific status
The experimental interpolation is a reference fixture, not an NRTL-SRK prediction. The candidate NRTL/SRK parameterisation is not accepted for predictive use. Energy, utilities and economics remain blocked pending approved enthalpy and design/cost inputs. Passing software tests does not establish thermodynamic model validity.

## MATLAB compatibility
Designed for MATLAB R2020a or newer, using JSON decoding, strings, tables and UI components. No Optimization Toolbox is required for the candidate model's documented `fminsearch` path.
