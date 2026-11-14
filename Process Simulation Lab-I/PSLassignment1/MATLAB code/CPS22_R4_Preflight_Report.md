# CPS-22 Expanded Literature Release — Static Preflight

## Current packaged-data checks

- Canonical runtime table: `data/CPS22_reference_vle_expanded.csv`.
- Current record count: 207 experimental ethanol–water VLE records at seven isobars: 100, 101, 300, 500, 700, 1500 and 2000 kPa.
- The 99-record source-specific 2021 table is preserved unchanged in `data/CPS22_reference_vle_2021.csv`.
- The 2026 ACS Omega Table 5 data are transcribed as 43 measurements at 101 kPa, 21 at 300 kPa, 22 at 500 kPa and 22 at 700 kPa.
- Pure-component saturation-pressure observations are in a separate CSV to prevent confusion with mixture VLE.
- `data/validation_reference_data.csv` is a byte-identical compatibility copy of the current canonical table.
- Property correlations, literature inventory, source register, GUI coverage labels, and MATLAB row/isobar checks were updated for this release.
- Static CSV consistency and archive integrity checks are run during packaging.

## Limitations and runtime status

MATLAB and GNU Octave are not installed in the build environment. MATLAB execution, GUI behavior and `.m` regression tests have **not** been run in this environment. The preflight is therefore a static/data/package check, not proof of runtime execution.

The candidate NRTL–SRK parameter set remains **NOT ACCEPTED for predictive use**. The existence of measured data at seven pressures does not validate predictions at unmeasured pressures. The software is an exploratory research tool until source-specific model fitting and validation are completed. REFPROP and ThermoData Engine are not bundled or claimed as downloaded.
