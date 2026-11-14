# ENERGY-008 Model Implementation

**Document:** ENERGY008-MODEL-IMPL-001  
**Revision:** 0.3.0-PROMPT19  
**Model:** ENERGY008-MODEL-0.1.0  
**Data:** ENERGY008-DATA-0.1.0  
**Reaction network:** ENERGY008-RXN-0.1.0  
**Fixture:** ENERGY008-HAND-BASE-C-01  
**Status:** Executable reference calculation engine with explicit plant-level blockers. Not validated; Prompt 21 remains required.

## 1. Calculation boundary

The implemented reference engine calculates the ideal stoichiometric Route C reaction blocks and the shared CO2-hydrogenation stoichiometric core for Route A. It also runs Route C turndown flow scaling and DB-059 power-shortfall arithmetic as screening examples. Route B remains blocked until biomass ultimate/proximate analysis, source syngas composition, gasification yields and a suitable reaction model are supplied. The 50,000 kg/day case is an illustrative component-equivalent benchmark, not an approved plant capacity or solved product stream.

The physical plant model remains **BLOCKED**: 55 process stream flows/compositions/T/P/enthalpies, real-gas mixture properties, PFR kinetics, flash/VLE, physical recycle/purge, utility/vendor data, site environmental measurements and project cost inputs are not complete.

## 2. Implemented calculation interfaces

All engine modules use `(modelInput, request, options)` and return a ModuleResult with `status`, `value`, `units`, `input_versions`, `residuals`, `warnings`, `errors`, `failure_codes`, `provenance` and `diagnostics`. Unknown quantities stay null/empty or a clearly documented missing numeric field with an explicit BLOCKED status. No error is silently converted to a plausible number.

| Module | Implemented calculation or gate | Current status boundary |
|---|---|---|
| `input_validation` | Validates case schema, units/declared basis, positive throughput, identities, unique IDs, source/provenance, stoichiometric dimensions/rank and C/H/O closure | CALCULATED or FAILED |
| `property_models` | Loads data-driven MWs; evaluates source-backed CO2 Shomate and methanol latent reference; blocks PR78, MeOH-water VLE and physical stream-property requests | CALCULATED/SCREENING_ONLY/BLOCKED |
| `material_balance` | Converts kg/day case input to kg/s, computes reaction extents/species rates directly from the versioned stoichiometric matrix in mol/s with kg/mol molecular weights, derives electrolyser H2 closure from that matrix, then exports fixture comparisons as kmol/day and kg/day; checks integrated mass/element closure and ideal KPIs | REFERENCE_ONLY or SCREENING_ONLY; S-209/S-207 BLOCKED |
| `reactor_calculation` | Enforces catalyst/kinetic/geometry gate before R-301 PFR | BLOCKED |
| `recycle_solver` | Damped bounded fixed-point solver with iterate/residual history only for `SYNTHETIC_UNIT_TEST`; physical S-209 closure is blocked | CALCULATED for synthetic test only; physical BLOCKED |
| `pfr_integrator` | RK4 step-doubling refinement for an explicitly supplied generic ODE, tested on a synthetic decay equation | Numerical primitive only; no ENERGY-008 kinetics |
| `energy_balance` | Calculates standard-state R-01/E-01/net enthalpy identities and source-propagated enthalpy uncertainty using mol/s and kW; blocks nonzero R-02 energy until its state-consistent thermochemistry is provided | SCREENING_ONLY; plant balance and reactor duty BLOCKED |
| `entropy_exergy` | Rejects negative supplied entropy generation; leaves physical entropy/exergy closures blocked | BLOCKED except diagnostic tests |
| `equipment_sizing` | Calculates Prompt 17 illustrative `A=Q/(U F ΔTLM)` and `Pshaft=ρgQvH/η`; loads 28-item equipment datasheet status register | SCREENING_ONLY; other equipment sizes BLOCKED |
| `utilities_model` | Theoretical electrolyser DI-water and O2 stoichiometry; loads 10 utility interfaces | BLOCKED for actual electricity, cooling, steam and emissions |
| `control_logic` | Calculates DB-059 linear H2 deficit arithmetic only | SCREENING_ONLY; dynamic/control simulation BLOCKED |
| `environmental_kpis` | Validates measurement units, measurement period, provenance and a field-level source map; converts kWh/day, kg/day and m3/day into W, kg/s and m3/s before calculating GHG, net-water and waste intensities | BLOCKED with current null template; synthetic source-complete test path included |
| `economics` | When populated, escalates dated INR equipment quotes with supplied indices/location/installation/contingency factors; computes annual utility/chemical/labour/maintenance/waste OPEX, CRF annualised CAPEX, LCOM and source-propagated RSS uncertainty | BLOCKED with current null template; synthetic source-complete test path included |
| `sensitivity_optimisation` | Loads the versioned 45/50/55 t/day sensitivity plan, validates each derived case, and recalculates it through the matrix-driven material-balance module; optimiser waits for validated plant model/objective/constraints | SCREENING_ONLY; optimisation BLOCKED |
| `scenario_runner` | Validates and evaluates base C, common-core A, blocked B, C turndown and DB-059 status | REFERENCE_ONLY/SCREENING_ONLY/BLOCKED |
| `validation_checks` | Runs all 12 numerical Prompt 17 tolerances and executes six semantic rejection/blocker tests | PASS only when all 18 tests actually pass |
| `reporting_plots` | Exports run-specific CSV/JSON, diagnostics, status tables and optional XLSX/PNG | No overwrite; output root MATLAB/results/run_id |

## 3. Equations, units and reference basis

**The calculation engine uses SI units internally.** Case throughput arrives as kg/day from JSON and is converted immediately to kg/s; reaction extents and species rates are solved in mol/s using kg/mol molecular weights. The energy module uses kJ/mol × mol/s = kW. Pressure, when supplied to property models, is Pa absolute; temperature is K. Internal equipment hydraulic flows use m3/s, geometry m, and density kg/m3. Fixture-facing values such as kg/day, kmol/day, GJ/day and m3/h are derived only at reporting/export boundaries by named conversion functions. Pressure is never stored as gauge pressure in an absolute-pressure field.

Independent reaction set, products positive/reactants negative:

- R-01: `CO2 + 3 H2 -> CH3OH(l) + H2O(l)`
- R-02: `CO2 + H2 -> CO + H2O(g)`
- E-01: `2 H2O(l) -> 2 H2(g) + O2(g)`

`Fout = Fin + N*xi`; elemental closure is `A*N = 0`. The independent rank is 3. CO hydrogenation is not introduced as an independent fourth reaction. The ideal fixture uses `xi_R02=0` as a reference-block assumption only, not an assertion about actual reactor RWGS.

Standard-state reaction enthalpies use 298.15 K and 0.1 MPa(a). R-01 and E-01 rates are calculated in kW from kJ/mol times mol/s, then converted to GJ/day for fixture comparison. R-02 is blocked in the energy module when its extent is nonzero because source-supported gas-state thermochemistry is not supplied. R-01/E-01/net enthalpy-rate uncertainty is propagated from the source uncertainty records; it excludes throughput and model-form uncertainty and is not a statistical confidence interval.

CO2 sensible heating uses NIST Shomate coefficients only in the declared 298–1200 K interval. Methanol latent heat uses its source correlation only in the declared 298–477 K interval. These are pure-fluid screening references, not high-pressure mixture enthalpy, reactor cooling or methanol-water distillation duties.

Equipment equations use explicit Prompt 17 screening assumptions: `A=Q/(U F ΔTLM)` and `Pshaft=ρgQvH/ηp`. They do not constitute an HX-301 or W-201 rated datasheet.

## 4. Scenario and sensitivity status

| Case | Meaning | Status |
|---|---|---|
| `C-BIOCO2-REH2-ALK-REF-50TPD` | Ideal Route C hand-check | REFERENCE_ONLY |
| `A-INDCO2-REH2-ALK-REF-50TPD` | Shared downstream CO2-hydrogenation stoichiometric core; source conditioning excluded | REFERENCE_ONLY |
| `B-BIOMASS-SYNGAS-50TPD` | Biomass and syngas model unavailable | BLOCKED |
| `C-BIOCO2-REH2-ALK-TURNDOWN-25TPD` | Linear stoichiometric scaling only | SCREENING_ONLY |
| `DB-059-POWER-SHORTFALL-50PCT-2H` | Linear hydrogen-deficit arithmetic only | SCREENING_ONLY |

## 5. Environmental and cost input contracts

The versioned `sensitivity_plan_v0.1.0.json` stores 45/50/55 t/day points and units/provenance. Each point is converted to the case import basis, schema-validated, and calculated through `material_balance()` using the loaded reaction network; the default plan cannot be changed silently in MATLAB code. This is a linear stoichiometric screening range, not an approved capacity envelope or probabilistic uncertainty distribution.

The environmental input template requires measured electricity, a source-specific emission factor, direct non-biogenic GHG, saleable methanol, water withdrawal/discharge, solid waste, renewable electricity fraction, chain-of-custody evidence and the MRV method version. Every quantity must have an exact unit declaration, individual source ID, provenance class and measurement period. Supported import units are the template's explicit register units only; values are converted to SI rates before intensity ratios are calculated. Missing fields remain `BLOCKED`; unit mismatch or negative/infeasible measurements return `FAILED`. The 0.44 kg CO2e/kg MeOH ceiling is stored as a reference limit from DB-057, not a certification result.

The cost template's `screening_cost_model` input contains dated quote items and annual cost drivers. Each quote requires its INR value, quote year, escalation indices, location and installation factors, contingency, uncertainty fraction and source ID. Annual costs require source-mapped electricity/water/steam consumption and tariff, chemical/labour cost, maintenance fraction, waste quantity/tariff, saleable methanol, discount rate and plant life. Escalation is the supplied reference-year index divided by quote-year index. Installed CAPEX is the escalated bare quote multiplied by location, installation and contingency factors. OPEX is itemised; LCOM uses the capital recovery factor. Uncertainty is the root-sum-square of supplied independent fractional inputs and is explicitly not a statistical confidence interval. Results are `SCREENING_ONLY`, never an audited estimate.

## 6. Physical calculation blockers

- PR78 mixture EOS: complete active `kij` matrix and independent VLE/PVT/phase stability validation missing. No missing pair is set to zero.
- Methanol-water VLE/distillation: pressure, source x-y-T/P data, regressed Wilson/NRTL parameters and independent fit validation missing.
- R-301 PFR: catalyst identity, exact source rate expression/parameters, validity range, reactor geometry and heat-transfer boundary missing.
- S-209 recycle/S-207 purge: full stream assay, flash, inert balance, purge criterion and recycle compressor map missing.
- Plant energy, entropy/exergy: accepted stream enthalpy/entropy, utility/work boundaries and dead-state environment missing.
- Actual ALK electricity, compressor power, cooling and steam: vendor maps and site utility conditions missing.
- Environmental certification/MRV: metered renewable power, source-origin/chain-of-custody, grid factor, water/waste measurements and current method approval missing.
- CAPEX/OPEX/LCOM: dated quotations, site tariffs, cost basis, escalation, finance inputs and production basis not approved.

## 6. Exports and verification

Every run writes to a unique `MATLAB/results/<run_id>/` directory. The engine exports computed component flows, element closure, reaction species flows, scenario statuses, fixture test results, equipment/utility registers, environmental KPI statuses, module statuses and module diagnostics as CSV/JSON. Optional XLSX/PNG failures are warnings and do not invalidate required CSV/JSON outputs. Existing result files are never overwritten.

The independent Python fixture audit is not MATLAB execution. MATLAB runtime remains `NOT RUN` in this build environment because MATLAB and GNU Octave are not installed or available. No MATLAB release or add-on toolbox availability is claimed verified. Prompt 21 must independently verify equations, source properties, physical model validity, residuals, uncertainty and regression behaviour before any model-validation statement.

## 7. Runtime dependency note

No add-on toolbox is currently declared as a verified Prompt 19 dependency. The build uses core MATLAB features for JSON, tables, numeric calculations and file I/O. SHA-256 integrity verification uses Java `MessageDigest` and requires a JVM-enabled MATLAB session. Workbook sheet inspection uses `sheetnames` or an `xlsfinfo` fallback. The exact target MATLAB release and availability of these features remain unverified until the MATLAB runtime suite is executed.
