# Literature data expansion summary

- Original source-specific 2021 mixture-VLE table retained: 99 records at 100, 1500 and 2000 kPa.
- Added 108 directly tabulated experimental VLE observations from the 2026 ACS Omega paper: 43 at 101 kPa, 21 at 300 kPa, 22 at 500 kPa and 22 at 700 kPa.
- Canonical mixture VLE total: 207 numeric records at seven isobars: 100, 101, 300, 500, 700, 1500 and 2000 kPa.
- Pure component ethanol/water vapor-pressure observations are kept in a different CSV and must not be mistaken for mixture VLE.
- Additional literature levels are inventoried (including 33.3, 287.4, 344.7, 515, 689.5, 721.8, 1378.95 and 2068.43 kPa); where source values were only shown in curves or not accessible as raw records, they are not made into false numeric table rows.
- NIST ThermoML Voutsas et al. (2011) record identified: index reports 45 bubble-temperature and 45 vapor-composition points, but numeric rows remain a follow-on ingestion item.
- NIST WebBook Antoine coefficients are included as piecewise pure-component vapor-pressure correlations.
- Scientific caveat: the candidate NRTL–SRK parameters remain NOT ACCEPTED for predictive use. At nonmeasured pressures the GUI returns model evaluations, not validated results.
