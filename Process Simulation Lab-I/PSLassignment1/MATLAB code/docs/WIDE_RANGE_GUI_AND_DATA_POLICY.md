# CPS-22 wide-range experimental data and GUI policy

## Runtime data bundled

The canonical file `data/CPS22_reference_vle_expanded.csv` contains **207 tabulated experimental ethanol–water VLE observations** from two papers. Pressure is recorded as the paper's stated value; the 100 and 101 kPa series are separate source datasets and are not merged.

| Pressure (kPa) | Points | Source | Temperature span (K) |
|---:|---:|---|---:|
| 100 | 26 | Susial Badajoz et al. (2021), Table 6 | 351.4–372.3 |
| 101 | 43 | Susial Badajoz et al. (2026), Table 5 | 351.3–370.6 |
| 300 | 21 | Susial Badajoz et al. (2026), Table 5 | 382.1–399.0 |
| 500 | 22 | Susial Badajoz et al. (2026), Table 5 | 398.6–423.5 |
| 700 | 22 | Susial Badajoz et al. (2026), Table 5 | 410.2–435.6 |
| 1500 | 32 | Susial Badajoz et al. (2021), Table 6 | 440.7–468.9 |
| 2000 | 41 | Susial Badajoz et al. (2021), Table 6 | 453.8–484.0 |

The original source-specific 2021 data remain in `data/CPS22_reference_vle_2021.csv`. Provenance, source table, tabulated pressure, composition, transcription precision, and uncertainty notes are retained in the expanded CSV. The GUI plots all seven ingested isobars.

## Other compiled tables and literature inventory

- `data/CPS22_pure_component_vapor_pressure_experimental.csv` includes pure ethanol/water vapor-pressure observations from the 2021 and 2026 papers. This is a separate validation dataset; it is **not** mixture VLE.
- `data/CPS22_property_database.csv` provides segmented NIST Chemistry WebBook SRD 69 Antoine coefficients and their applicable temperature segments. NIST correlations have their own ranges and are not a universal replacement for mixture VLE data.
- `data/CPS22_experimental_coverage.csv` summarizes the measured T and composition span by isobar.
- `data/CPS22_literature_pressure_inventory.csv` inventories further reported pressure levels from comparisons and NIST ThermoML. Legacy comparison curves at 33.3, 287.4, 344.7/344.74, 515, 689.48/689.5, 721.8, 1378.95 and 2068.43 kPa are explicitly marked as not numerically ingested when raw tables were not available. No values have been invented or silently digitized from curves.
- NIST ThermoML lists Voutsas et al. (2011) as a low-pressure dataset with 45 bubble-temperature points and 45 vapor-composition points. Its records are tracked in the inventory but are not yet included in the canonical numeric file.

## What the GUI can and cannot claim

The GUI accepts continuous numeric pressure and temperature inputs, but this means a model evaluation can be attempted, **not** that experimental measurements or validated predictions exist at every pressure. The current measured mixture-VLE coverage is seven discrete isobars at 100, 101, 300, 500, 700, 1500 and 2000 kPa. The gap between 700 and 1500 kPa remains substantial. A result at 1000 kPa is therefore model-only in this release.

Temperature inputs can be entered in K or °C; the GUI converts temperature units and still rejects states outside its configured property-correlation/model limits. The pure-component Antoine correlation ranges do not guarantee that a mixture flash calculation is valid.

## Model validity

The candidate NRTL–SRK interaction parameters are still **NOT ACCEPTED for predictive use**. Data expansion is a necessary benchmark improvement, not proof of model validity. Before industrial use, refit/validate the mixture model against source-specific points at each pressure, check residuals and azeotrope behaviour, and document the pressure/temperature domain. REFPROP or ThermoData Engine access may add independent validation, but neither is bundled or represented as downloaded in this package.

## Source links

1. Susial Badajoz et al. (2021), *High-Pressure Phase Equilibria in an Ethanol/Water Binary System: Experimental Data and Modeling*, J. Chem. Eng. Data 66, 928–946, DOI `10.1021/acs.jced.0c00686`: https://doi.org/10.1021/acs.jced.0c00686
2. Susial Badajoz et al. (2026), *A Novel Equipment for VLE Studies: Ethanol and Water System at Moderate Pressures and Data Verification with a Direct Point-to-Point Test*, ACS Omega, DOI `10.1021/acsomega.6c04827`: https://doi.org/10.1021/acsomega.6c04827
3. Voutsas et al. (2011), NIST ThermoML record: https://trc.nist.gov/ThermoML/10.1016/j.fluid.2011.06.009.html
4. NIST Chemistry WebBook SRD 69 Antoine data: ethanol https://webbook.nist.gov/cgi/cbook.cgi?ID=C64175&Type=ANTOINE and water https://webbook.nist.gov/cgi/cbook.cgi?ID=C7732185&Type=ANTOINE

## Verification status

Programmatic checks cover row counts, source attribution, pressure levels, composition bounds/closure, pure-component duplicate elimination, and ZIP integrity. MATLAB/Octave is unavailable in the build environment, so runtime execution of the MATLAB tests has **not** been confirmed. Run `CPS22_Launcher('tests')` in MATLAB after extraction. Software/data-path checks do not establish predictive model validity.
