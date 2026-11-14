# CPS-22 Wide-Range GUI and Expanded Literature Data

## Start
1. Extract the ZIP into a clean folder.
2. Open `START_HERE.m` in MATLAB and press Run.
3. Enter temperature in K or °C, pressure with its unit, ethanol feed mole fraction, and feed flow.
4. Click **Calculate at T and P**.

## Numeric experimental VLE included
- `data/CPS22_reference_vle_expanded.csv`: **207 experimental ethanol–water T–x–y records** at 100, 101, 300, 500, 700, 1500 and 2000 kPa.
- `data/CPS22_reference_vle_2021.csv`: original 99-point data file from the 2021 high-pressure study.
- `data/CPS22_pure_component_vapor_pressure_experimental.csv`: pure-component measurements, separate from mixture VLE.
- `data/CPS22_property_database.csv`: NIST Chemistry WebBook SRD 69 Antoine segments.
- `data/CPS22_experimental_coverage.csv`: point count and measured temperature/composition bounds by isobar.
- `data/CPS22_literature_pressure_inventory.csv`: source-tracked inventory of additional literature curves/data, clearly distinguishing numeric records actually bundled from records still to retrieve.

## Important scientific boundary
The GUI accepts continuous pressure and temperature values, but only seven measured isobars currently have tabulated mixture-VLE points. There is no raw numeric measured curve at every pressure; in particular, 1000 kPa remains model-only in this release. The NRTL–SRK candidate parameters are **not accepted for predictive use**. Do not use calculated outputs for industrial design until model fitting, source-specific residual analysis, and validation are completed.

The 2026 paper contains directly tabulated VLE data at 101, 300, 500 and 700 kPa. Older literature curves at other pressures are listed in the inventory but not invented from figures. NIST ThermoML identifies another low-pressure VLE dataset; numeric records have not yet been imported into this release.

## Test status
CSV consistency and archive integrity are checked programmatically. MATLAB/Octave was not available during build, so run `CPS22_Launcher('tests')` in MATLAB after extraction; runtime status is not claimed before that step.
