# MATLAB-to-Python migration plan and implementation status

## Migration principles

1. Preserve the versioned reaction network, property records, benchmark fixture, field names, units, reference states and status meanings.
2. Re-implement equations from the engineering register and independently verify them against the Prompt 17 hand calculation fixture. Do not mechanically transliterate MATLAB syntax.
3. Retain MATLAB and Python outputs in separate folders. A Python/fixture parity pass does not constitute MATLAB runtime parity.
4. Keep calculation modules independent of GUI and export code.
5. Unknown inputs remain null. A method is `BLOCKED` if the required parameter set or validation evidence is absent.
6. Keep numerical method version, package versions, source-data hashes, scenario, assumption class and run ID in exports.

## Stage plan

| Stage | Modules | Migration status | Acceptance gate |
|---|---|---|---|
| 0 | package root, config, data manifest, schema/status | Implemented for bundled JSON subset | Extract to arbitrary directory, validate schema IDs, verify source hashes |
| 1 | unit conversions, reaction register | Implemented | exact unit conversions; matrix dimension and identity tests |
| 2 | component/element material ledger | Implemented for Route A/C ideal reaction-block reference | fixture molar/mass/element parity; R-02 remains reference assumption; no physical recycle |
| 3 | pure component properties | Implemented: CO2 Shomate, MeOH latent correlation | frozen fixture tolerance and validity-range tests |
| 4 | standard enthalpy and equipment examples | Implemented at reference/screening level | fixture enthalpy/duty/HX/pump parity |
| 5 | entropy/exergy, plant utilities, economics, environmental KPIs | Interfaces and blocked-state records only | unblock only after source data and independent model validation |
| 6 | reactor PFR, PR EOS, VLE, physical recycle/purge | Not ported; blocked interfaces retained | exact source kinetic/EOS/VLE data and independent validation required |
| 7 | throughput sensitivity and numerical primitives | Partial | 45/50/55 linear reference points; generic SciPy DOE/solver are synthetic only |
| 8 | reporting/export | Implemented | JSON/CSV/PNG run export with IDs and versions |
| 9 | Python GUI | Not implemented | optional later layer; no equations in UI callbacks |
| 10 | Tests, case CLI runs and parity report | 23 Python tests pass; 4 unique controlled case definitions + 2 installed CLI smoke runs executed; Python/hand-fixture parity pass | MATLAB/Python parity still NOT RUN; target MATLAB run evidence required |

## Formula preservation

### Reaction extents

For target methanol component-equivalent rate `m_dot_MeOH` and matrix coefficient `nu_MeOH,R01`:

- convert target from kg/day to kg/s;
- divide by methanol molecular weight (kg/mol) to obtain mol/s;
- calculate `xi_R01 = n_dot_MeOH / nu_MeOH,R01`;
- import declared R-02 reference extent in kmol/day and convert to mol/s;
- close electrolyser hydrogen using the loaded stoichiometric matrix: `xi_E01 = -(nu_H2,R01 xi_R01 + nu_H2,R02 xi_R02) / nu_H2,E01`.

Reaction coefficients are loaded from the JSON register; they are not duplicated as new constants in the code. The calculation is a reaction-block reference, not a kinetic conversion prediction.

### Component/element ledger

For species vector `n_dot = N xi_dot`, calculate gross production/consumption from positive and negative reaction contributions, then report integrated component ledgers. The C/H/O atom residual is `A n_dot`, with `A` loaded from the property/reaction contract. The frozen mass residual of approximately −0.062418 kg/day is retained because the versioned molecular weights are rounded; it is not forced to zero.

### Pure-fluid and reaction-enthalpy references

- CO2 Shomate: compute the H increment at T2 minus T1, in kJ/mol; `Q[kW] = n_dot_CO2[mol/s] * delta_h[kJ/mol]`.
- Methanol latent correlation: use the exact versioned `A exp(-alpha Tr)(1-Tr)^beta` form within its stated temperature interval.
- Standard reaction enthalpy: `rate[kW] = extent[mol/s] * delta_h[kJ/mol]`; `GJ/day = kW * 86400 / 1e6`.

No correlation is used outside its declared interval. These duties must not be re-labelled as reactor cooling, process heating or column duties.

## Parity protocol

1. Use the same frozen `ENERGY008_Benchmark_Fixture.json` numeric expectations and absolute tolerances.
2. Compare unrounded numbers; display precision is not an acceptance criterion.
3. For a zero expected residual, use an absolute tolerance only. Never divide by zero to calculate relative error.
4. For non-zero expected values, relative deviation may be reported as `abs(actual-expected)/abs(expected)` alongside the absolute deviation.
5. Do not call a Python function twice and describe that as independent validation. Fixture values originate in Prompt 17 hand calculations; additionally preserve independent checks CSV as an external comparison record.
6. MATLAB-to-Python result comparison remains `NOT RUN` until MATLAB outputs exist from the same case/data version and the target release/toolboxes are recorded.

## Future physical-model migration gates

Before implementation, freeze the corresponding source records, units and validity ranges:

- PR78: every active binary `kij`, mixing rule, critical constants/acentric factors, phase-stability tests and independent VLE/PVT checks.
- Methanol-water: source x-y-T/P dataset, fitted Wilson/NRTL parameters, regressed parameter covariance, pressure and independent validation points.
- PFR: source paper's exact kinetic equation, catalyst identity, adsorption/activation terms, parameter units, valid T/P/composition ranges, catalyst mass/geometry and thermal boundary.
- Recycle: validated separator flash, full inerts/impurities, purge criterion, pressure drops and compressor curves.
- Utilities: OEM ALK polarization map and BOP, rectifier efficiency, minimum-load/ramp constraints, compressor/pump maps, utility headers/site conditions.
- Energy/exergy: solved physical stream states, heat/work boundary definitions, chemical/physical exergy method and dead-state environment.
- Economics: dated vendor quotes, escalation, location/install factors, contingencies, finance assumptions and approved product capacity/availability.

Only after those gates can the Python project progress from reference/screening migration to physical process model migration.
