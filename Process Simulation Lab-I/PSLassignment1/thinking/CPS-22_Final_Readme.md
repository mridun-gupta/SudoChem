# CPS-22 Industrial Submission Package

## Contents
- `report/CPS-22_Industrial_Technical_Report.docx` and `.pdf`: detailed report covering required sections 8–21, manual calculations, source/property cards, full 99-point reference dataset, sensitivities, tests and limitations.
- `presentation/CPS-22_Short_Presentation.pptx`: 15-slide technical summary.
- `MATLAB/`: project source tree, GUI, configuration, datasets, flowcharts, tests, validation fixtures and migration notes.
- `data/`: 99 experimental VLE points, NIST/property register and source register.
- `manual_calculations/`: 60-row calculation register including equations, substitutions, units, outputs and caveats. `validation/CPS-22_Independent_Recalculation.py` independently recomputes the empirical interpolation, NRTL/SRK fugacity diagnostic and balance closures.
- `validation/`: base-case outputs, independent recalculation script/results, fugacity residuals, balance, model-fit diagnostic, literature comparison, sensitivity records and scenario-only energy/cost tables.
- `results/plots/`: 13 plots referenced by the report and presentation.
- `flowcharts/`: top-level and nonlinear solver diagrams.
- `CPS-22_Final_Compliance_Matrix.csv`: all 38 original requirements with PASS/FAIL/BLOCKED/NOT RUN and evidence.
- `CPS-22_Open_Issues.md`: outstanding scientific and software limitations.
- `CPS-22_Submission_Manifest.csv`: file inventory, byte sizes and status notes.

## Main numerical finding
The empirical ethanol–water reference tie-line at 1.5 MPa is interpolated at T = 445.125329 K, x_ethanol = 0.388480, y_ethanol = 0.548240 and beta = 0.698046 for an assumed 100 kmol/h feed with z_ethanol = 0.5. The lever-rule phase flows and material balance close algebraically. The corrected component-specific Poynting diagnostic produces max |ln(fV/fL)| = 0.118863, far above the 1e-6 acceptance criterion. Therefore these empirical phase-split values are a reference fixture, not a validated NRTL–SRK prediction.

## MATLAB execution
MATLAB/Octave was not available during package creation. Source and tests are included but must be executed in a MATLAB-capable environment.

1. Extract `MATLAB/CPS-22_Industrial_MATLAB.zip` or use the `MATLAB/` folder directly.
2. Open MATLAB with the `MATLAB` folder as the current folder.
3. Run `main_industrial`.
4. Run tests via `addpath(genpath('src')); addpath('tests'); run_tests; test_failure_handling; test_industrial_properties; test_configuration_integrity; test_gamma_phi_input_validation`.
5. Run GUI via `run_gui`.

Successful runtime, GUI behavior and test status must be confirmed by MATLAB logs; no such execution is claimed here.

## Main sources
- Susial Badajoz et al. (2021), J. Chem. Eng. Data 66, 928–946, DOI: 10.1021/acs.jced.0c00686.
- NIST Chemistry WebBook SRD 69, ethanol: https://webbook.nist.gov/cgi/cbook.cgi?ID=C64175&Mask=1E9F
- NIST Chemistry WebBook SRD 69, water: https://webbook.nist.gov/cgi/cbook.cgi?ID=C7732185&Plot=&Type=ANTOINE
- NIST-JANAF Thermochemical Tables, Chase (1998), NIST SRD 69 water liquid Cp record.
- Renon & Prausnitz (1968), DOI: 10.1002/aic.690140124.
- Soave (1972), DOI: 10.1016/0009-2509(72)80096-4.
- IAPWS-IF97 official release: https://www.iapws.org/relguide/IF97-Rev.html

## Disposition
The package is suitable for technical review and continued development. It is not a validated industrial design or fully accepted simulation. See compliance matrix and open issue register before submission.
