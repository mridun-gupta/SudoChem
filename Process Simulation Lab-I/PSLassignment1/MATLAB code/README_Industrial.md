# CPS-22 Industrial Rerun MATLAB Package

## Purpose
This project implements traceable NIST Antoine vapor-pressure calculations, the candidate NRTL equation, classical SRK vapor fugacity diagnostics, interpolation of published ethanol-water VLE data, a manual-calculation CSV export and screening calculations. It does **not** constitute a validated industrial process simulator: the candidate NRTL parameter set and SRK binary interaction parameter fail acceptance at the high-pressure reference tie-line; no tangent-plane phase-stability test is supplied; and the enthalpy/economic basis is not accepted.

## Run
From MATLAB, set current folder to this directory and run:
```matlab
main_industrial
```
Output appears in `results/industrial/`. Tests (MATLAB Unit Test Framework) can be invoked with:
```matlab
addpath(genpath(pwd)); runtests('tests')
```

## Default case
F = 100 kmol/h, z = [0.5,0.5], P = 1.5 MPa, T = 445.125328947 K; component order ethanol then water. T is interpolated from Table 6 data, not prescribed by the experiment as a process condition.

## Data provenance
`data/validation_reference_data.csv` includes the 99 tabulated measurements transcribed from Susial Badajoz et al. (2021), DOI 10.1021/acs.jced.0c00686. NIST SRD 69 Antoine and selected heat capacity/latent heat data, CoolProp critical constants, and literature candidate NRTL parameters are recorded in `data/CPS-22_NIST_and_Property_Register.csv`. Every data item has a status and limitations.

## Critical interpretation
The base two-phase split is an empirical interpolation and lever-rule fixture. NRTL-SRK fugacity residuals at that tie-line fail the prescribed 1e-6 criterion. Do not use outputs for guaranteed design, procurement, operation, or safety decisions. Energy duty is a scenario screen using assumed ethanol liquid Cp and a Watson estimate for water latent heat. Use validated enthalpy, current code/industry standards, vendor separator data, IAPWS-IF97 steam properties and a documented cost basis before industrial use.

MATLAB was not available in the build environment. Static source was prepared; runtime tests remain to be executed in MATLAB.
