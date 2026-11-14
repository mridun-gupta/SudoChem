# ENERGY-008 | Prompt 21 Independent Verification and Validation Report

**Document ID:** ENERGY008-VV-021  
**Revision:** 0.1 | 02 November 2026  
**Project basis:** Route C biogenic CO₂ + renewable electrolytic H₂, pressurised ALK reference  
**Design status:** G3 / design basis Rev 0.1-DRAFT; route selection remains provisional  
**Verification execution environment:** Python independent arithmetic and source/data audit. MATLAB and GNU Octave were not available on `PATH`.

> **Engineering status:** This report is an independent verification of available requirements, source files, data records and explicitly bounded calculations. It is not a physical process-model validation, safety validation, software runtime acceptance or plant design approval.

## 1. Executive result

The 27 assignment topics were reviewed against the requirements matrix, Prompt 17 hand calculations, Prompt 18–19 MATLAB project, Prompt 20 GUI source, HMI/control philosophy, source data and available output artifacts.

| Requirement status | Count | Interpretation |
|---|---:|---|
| PASS | 0 | No whole assignment topic is fully closed by the evidence available. |
| FAIL | 2 | Assignment acceptance minima are not met: alternative count and sensitivity breadth. |
| BLOCKED | 6 | Required physical inputs, property models, operating data or cost/environmental data are absent. |
| NOT RUN | 6 | Runtime, migration, full report/package or final acceptance evidence is absent. |
| SCREENING ONLY | 13 | Bounded reference calculations, source artifacts or conceptual deliverables exist, but do not establish a validated plant model. |

The curated Prompt 21 test register contains **82 records**: 40 PASS, 2 FAIL, 14 BLOCKED, 19 NOT RUN and 7 SCREENING ONLY. A separate, independently coded Python audit recorded **115 additional assertions**: 80 PASS, 27 SCREENING ONLY, 2 FAIL, 1 BLOCKED and 5 NOT RUN. These two populations are shown separately in the verification workbook.

The 80 Python PASS results mean only that their particular assertions passed at the stated layer. This includes source/configuration checks, independent arithmetic identities and fail-closed checks that confirm missing physical results remain null. It does **not** mean that the MATLAB engine or the physical process model passed. All MATLAB and MATLAB GUI runtime execution remains NOT RUN.

### 1.1 Principal findings

1. The 50 t/day Route C ideal stoichiometric reference is independently reproducible from the declared reaction network and rounded molecular weights. Its values are screening/reference quantities, not solved operating stream rates.
2. Route A can only be compared on the same ideal downstream CO₂/H₂ reaction core. Route-specific industrial CO₂ capture/conditioning, feed quality, cost, utilities and performance are not modelled.
3. Route B (biomass syngas) is correctly fail-closed and remains BLOCKED. It has no independent physical rates because the biomass assay, syngas yield/composition, tar/char handling, gas-cleanup performance and matched kinetics are absent.
4. The assignment requirement for a base case plus at least two evaluated alternatives is **FAIL**. A blocked route is not an evaluated alternative.
5. The sensitivity requirement is **FAIL**. The current plan contains only a 45/50/55 t/day throughput sweep, not six or more independent parameters and not a multivariable method.
6. Standard-state reaction thermochemistry is independently reproduced against NIST Chemistry WebBook formation enthalpies. This validates those arithmetic identities only, not reactor performance or process energy closure.
7. The MATLAB project configuration, source contracts, GUI source contracts, manifest hashes and copy-based relocated-path contract pass static checks. No MATLAB parser, engine, UI, GUI export or runtime log was produced.
8. Physical recycle/purge, PR78 mixture flash, methanol-water VLE, catalyst-matched PFR kinetics, plant mass/energy/entropy/exergy closures, actual compressor/pump/HX loads, utilities, environmental MRV and economics remain blocked.

## 2. Scope, evidence and review method

### 2.1 Evidence reviewed

- Original 27-topic assignment extraction and associated acceptance wording.
- ENERGY-008 requirements traceability matrix (topic rows R-01 through R-27, including required evidence and acceptance criteria).
- Prompt 17 hand-calculation workbook, report, JSON benchmark fixture and independent calculation checks.
- Prompt 18 project architecture, startup, root discovery, configuration and data-manifest source.
- Prompt 19 MATLAB calculation modules, data templates, 31 source-defined test functions, Python static checker and independent arithmetic audit.
- Prompt 20 programmatic MATLAB GUI, launcher, engine adapter, GUI source checker, user guide and Prompt 21 handoff.
- Prompt 14 HMI/control philosophy and current conceptual process basis.
- Available result directories and logs. Result directories do not contain actual MATLAB solver runs or GUI exports.
- External NIST Chemistry WebBook SRD 69 thermochemical data for selected standard-state identities.

### 2.2 Evidence hierarchy

| Evidence layer | What it establishes | What it does not establish |
|---|---|---|
| File/data presence and SHA-256 | Required files exist and match the data manifest. | MATLAB can parse or execute them. |
| Static source/configuration checks | Declared source contracts, interfaces, path rules and data paths are present and internally consistent. | Numerical correctness at runtime. |
| Independent Python arithmetic | Reproducibility of specified ideal/reference equations using separately written Python calculations. | That MATLAB uses the same equations correctly or that the physical plant behaves that way. |
| Synthetic primitive tests | Expected behaviour of small generic mathematical examples (for example, fixed-point convergence and entropy sign checks). | Process-specific kinetics, recycle convergence, energy/exergy closure or validated economics. |
| External reference comparison | Selected thermochemical identities agree with NIST data. | Independent validation of a plant, reactor, property package or fitted model. |
| MATLAB/GUI runtime | Would establish actual application behavior only if run in MATLAB with retained logs/screenshots. | Not available in this verification environment. |

### 2.3 Status definitions

- **PASS:** The stated assertion passed within its declared evidence layer. A PASS on a fail-closed assertion means the software/data contract correctly keeps a result blocked; it does not mean the blocked process quantity is validated.
- **FAIL:** An assignment requirement or acceptance assertion is demonstrably unmet.
- **BLOCKED:** The test or engineering result cannot be completed because necessary inputs, fitted parameters, vendor data or physical states are absent.
- **NOT RUN:** The test requires runtime, UI interaction, external integration or deliverables that have not been executed/created.
- **SCREENING ONLY:** A bounded ideal, assumed, synthetic or conceptual calculation/source artifact is available. It must not be promoted to a physical design result.

## 3. Assignment traceability disposition: all 27 topics

| ID | Assignment topic | Prompt 21 status | Independent finding / next evidence needed |
|---|---|---|---|
| R-01 | Assignment purpose | SCREENING ONLY | Scope and modular intent are documented; only bounded ideal/reference calculations are independently reproduced. |
| R-02 | Core problem statement | FAIL | Only Route A common-core comparator exists; Route B is blocked. Evaluate two distinct alternatives on one common basis. |
| R-03 | Project-specific technical scope | SCREENING ONLY | Conceptual boundary and case register exist. Dynamic disturbance response and complete route performance are not solved. |
| R-04 | Engineering inputs and data | BLOCKED | Physical feed assays, feed quality, full operating envelope, vendor performance, tariffs and site data remain open. |
| R-05 | Governing equations and model formulation | SCREENING ONLY | Reaction stoichiometry and selected reference equations are evidenced; full property/kinetic/phase-equilibrium formulation is not validated. |
| R-06 | Numerical algorithm | NOT RUN | MATLAB numerical engine and its unit/failure paths have not executed. The source-defined MATLAB suite is not runtime evidence. |
| R-07 | Material balances | SCREENING ONLY | Reaction and atom balances close for the ideal reference. The 55-stream physical flowsheet, recycle, purge and phase splits are not solved. |
| R-08 | Energy balance and thermal design | SCREENING ONLY | Standard-state reaction enthalpy and pure-component reference duties are reproduced. No plant energy closure or actual equipment duty exists. |
| R-09 | Entropy balance | BLOCKED | No physical stream states, heat-transfer boundaries or complete work/heat data for plant entropy closure. |
| R-10 | Exergy balance | BLOCKED | No approved dead state and no complete physical energy/entropy balance for exergy destruction. |
| R-11 | Detailed equipment selection and design calculations | SCREENING ONLY | Illustrative HX area and pump power/capacity equations are reproduced with assumptions. No vendor- or system-based datasheets/selection. |
| R-12 | PFD and P&ID-level definition | SCREENING ONLY | Conceptual PFD/tag/stream artifacts exist. PFD remains non-construction and is not a P&ID. |
| R-13 | Industrial process automation and control | SCREENING ONLY | Control philosophy/source requirements exist. No approved limits, validated control dynamics, SIS cause/effect or instrument design. |
| R-14 | PLC/DCS, HMI, sequencing and alarm requirements | SCREENING ONLY | GUI source provides 11 pages and read-only conceptual automation status. MATLAB UI runtime, field I/O and fault tests not run. |
| R-15 | Utilities, environment and waste | BLOCKED | Actual power/steam/cooling/water/waste data and environmental boundary/MRV evidence are absent. |
| R-16 | CAPEX screening | BLOCKED | Cost basis is a template; no quotations, installed factors or project location/class basis. |
| R-17 | OPEX screening | BLOCKED | No approved feedstock, utility tariffs, labour, catalyst, maintenance or waste-treatment costs. |
| R-18 | Sensitivity analysis | FAIL | Only one throughput axis at 45/50/55 t/day. Required six or more parameters and multivariable method are absent. |
| R-19 | Flowchart requirements | SCREENING ONLY | Process, solver and automation sequence diagrams exist as conceptual source artifacts; process logic is not validated by runtime. |
| R-20 | MATLAB modular architecture | SCREENING ONLY | 13 named modules and helper/data layers pass static/source checks. MATLAB compilation and execution not run. |
| R-21 | GUI requirements | SCREENING ONLY | All 11 tabs and engine delegation pass 80 source-contract checks. GUI launch, Run/Reset, plots, tables and exports not run. |
| R-22 | Variable dictionary and units | SCREENING ONLY | Dictionary and unit metadata exist; only selected dimensional identities were checked. Full model-wide dimensional audit is not complete. |
| R-23 | Verification and validation | NOT RUN | Independent arithmetic and static/source audit exist; MATLAB unit/integration suite, GUI execution and model validation not run. |
| R-24 | Python/open-source migration | NOT RUN | No module-by-module MATLAB-to-Python migration map or validated Python engine exists. |
| R-25 | Technical report structure | NOT RUN | The complete integrated ten-section final technical report is not available. |
| R-26 | Final submission package | NOT RUN | Current source/verification archives exist, but final complete report and all acceptance evidence are not assembled. |
| R-27 | Acceptance checklist | NOT RUN | Final nine-item assignment checklist cannot close while upstream FAIL/BLOCKED/NOT RUN items remain. |

## 4. Reproducible case coverage

The separate `ENERGY008_Independent_Comparison.xlsx` and `ENERGY008_Test_Logs/case_coverage.csv` record the following.

| Case | Declared type/status | Independent result | Limits |
|---|---|---|---|
| C-BIOCO2-REH2-ALK-REF-50TPD | Base, REFERENCE_ONLY | PASS / SCREENING ONLY for ideal stoichiometric material/atom arithmetic and selected reference duties. | No physical stream states, reactor model, recycle/flash, electrolyser performance, or plant utilities. |
| A-INDCO2-REH2-ALK-REF-50TPD | Alternative 1, REFERENCE_ONLY | PASS / SCREENING ONLY for common ideal downstream core identity. | Industrial CO₂ upstream conditioning/capture, impurities, compression, cost and route-specific utilities are not evaluated. |
| B-BIOMASS-SYNGAS-50TPD | Alternative 2, BLOCKED | PASS fail-closed assertion only; no process rates computed. | Biomass assay, syngas yield/composition, cleanup, char/tar handling and matched kinetics absent. |
| C-BIOCO2-REH2-ALK-TURNDOWN-25TPD | Turndown, SCREENING_ONLY | PASS / SCREENING ONLY for exact 0.5 linear stoichiometric scaling. | Not an ALK turndown map or dynamic/thermal/compressor operating case. |
| DB-059-POWER-SHORTFALL-50PCT-2H | Disturbance, SCREENING_ONLY | PASS / SCREENING ONLY for linear two-hour H₂ deficit of 393.211700929 kg/event. | No transient electrolyser response, H₂ storage, process inertia, ramp rates or control response. |

**Acceptance result:** three case records exist, but the assignment's base-plus-two-*evaluated*-alternatives requirement is not fulfilled. The alternative count remains FAIL because Alt 2 is blocked and Alt 1 is only a common-core identity comparison.

## 5. Independent numerical comparisons

### 5.1 Route C base stoichiometric reference

Declared product basis: 50,000 kg/day methanol component-equivalent, reaction R-01, plus electrolyser reaction E-01. Molecular weights are those specified in the Prompt 17 benchmark/reference data. Values below are independently recomputed Python outputs and match the Prompt 17 hand-calculation benchmark within stated tolerances.

| Quantity | Independent value | Units | Verification note |
|---|---:|---|---|
| Methanol component-equivalent | 1,560.456776908 | kmol/day | Product basis only; not measured product flow. |
| CO₂ theoretical consumption | 68,674.922523321 | kg/day | Ideal R-01 stoichiometry. |
| H₂ theoretical consumption | 9,437.080822298 | kg/day | Ideal R-01 + E-01 stoichiometry. |
| Reaction water generation | 28,112.065763890 | kg/day | R-01 reference amount. |
| Electrolyser water demand | 84,336.197291671 | kg/day | E-01 theoretical feed. |
| Net water consumption | 56,224.131527781 | kg/day | Electrolyser feed less reaction water; reference identity. |
| O₂ theoretical coproduct | 74,899.116469373 | kg/day | Ideal E-01 coproduct. |
| Rounded-MW integrated mass residual | −0.062418271060 | kg/day | Retained; not artificially forced to zero. |
| Normalized mass residual | 4.9975 × 10⁻⁵ | % | Residual normalized by declared net input/consumption scale, not relative error against a zero closure target. |

C, H and O atom residuals are each 0 kmol atoms per kmol reaction for R-01, R-02 and E-01 under the declared reaction vectors. These are stoichiometric checks, not 55-stream process-balance closure.

### 5.2 Standard-state thermochemistry and external reference

NIST Chemistry WebBook SRD 69 reports standard formation enthalpies used here of methanol(l) −239.5 kJ/mol, water(l) −285.83 kJ/mol and CO₂(g) −393.51 kJ/mol. Independently applying formation-enthalpy identities gives:

- R-01, CO₂(g) + 3 H₂(g) → CH₃OH(l) + H₂O(l): **−131.82 kJ/mol reaction**.
- E-01, 2 H₂O(l) → 2 H₂(g) + O₂(g): **+571.66 kJ/mol reaction**.
- Combined ideal stoichiometric identity per mol methanol: **+725.67 kJ/mol methanol**.

The independent Python result differs from the NIST-derived identity by less than 6 × 10⁻¹⁴ kJ/mol for R-01 and exactly 0 at stored precision for E-01. These are standard-state thermochemistry identities. They are not reactor heat removal, electrolyser electrical consumption, purchased electricity, plant energy closure or process utility duties. Sources: [NIST Methanol Chemistry WebBook](https://webbook.nist.gov/cgi/cbook.cgi?Name=methanol&cTC=on&cTG=on), [NIST Water Chemistry WebBook](https://webbook.nist.gov/cgi/cbook.cgi?Name=water&cTC=on&cTG=on), [NIST Carbon dioxide Chemistry WebBook](https://webbook.nist.gov/cgi/cbook.cgi?ID=C124389&Mask=25).

Reference rates at the stated ideal basis:

| Quantity | Independent value | Units | Limit |
|---|---:|---|---|
| R-01 standard enthalpy rate | −205.699412332 | GJ/day | Standard-state identity only. |
| E-01 thermoneutral enthalpy rate | +1,338.076081631 | GJ/day | Thermoneutral reaction enthalpy only; not purchased power. |
| Integrated net enthalpy identity rate | +1,132.376669299 | GJ/day | Sum of ideal stoichiometric reference reactions only. |

### 5.3 Property and equipment reference calculations

| Quantity | Independent value | Units | Independent comparison |
|---|---:|---|---|
| CO₂ Shomate pure ideal-gas sensible duty, 298.15→523.15 K | 168.854289886 | kW | NIST Shomate coefficient formula; difference to benchmark 2.56×10⁻¹³ kW. Validity-range and pure ideal-gas scope apply. |
| Pure methanol latent reference duty | 677.082782421 | kW | Matches Prompt 17 property reference; not a methanol-water separation duty. |
| Illustrative exchanger area | 56.284763295 | m² | Q/(U·F·LMTD), with explicit assumed U and temperature approach; screening only. |
| Illustrative water pump shaft power | 0.683743030 | kW | ρgQH/η with assumed density, head and efficiency; screening only. |
| Illustrative pump capacity with 10% margin | 3.877040163 | m³/h | Screening capacity only, not equipment selection. |

### 5.4 Deviation denominator rules

- Absolute deviation: `abs(independent − reference)`.
- Relative deviation: `absolute deviation / abs(reference) × 100%`, only when the reference is non-zero.
- When reference is zero, relative deviation is **N/A**; report the absolute residual.
- For closure, use a declared non-zero normalisation basis such as total net inlet/consumed mass. Do not divide by a zero residual target.
- For expected blocked/null results, compare status/nullness, not numerical deviation.

### 5.5 Synthetic primitive checks (not plant results)

The Python audit includes small mathematical contract checks only:

- A synthetic compressor isentropic work primitive returns a positive 2,724.49 W for its invented test state. This is **not** K-101/K-201/K-301 power.
- Synthetic entropy-generation sign cases identify zero, positive and negative sign inputs as expected. A synthetic exergy destruction identity `T₀·Sgen` returns a positive 2.9815 kW for a fabricated input. This is **not** process exergy analysis.
- Synthetic KPI identities return 20 kWh/t and 0.1 m³/t using fabricated numbers. These are not plant KPIs.
- A synthetic contraction mapping converges to approximately 2.0; a synthetic divergent map is identified as NOT_CONVERGED. This does not test physical recycle S-209 or purge S-207.
- A synthetic capital recovery factor/annualised CAPEX dimensional identity returns 0.1018522 1/year and 101.8522 INR/t for fabricated cost inputs. This is not ENERGY-008 CAPEX/OPEX.

These primitive checks are marked SCREENING ONLY in the raw audit log and must not be copied into plant operating or optimisation outputs.

## 6. Unit-test coverage and unexecuted MATLAB tests

The independent Python audit includes reaction atom conservation, base reaction stoichiometry, mass closure residuals, reaction enthalpy identities, ideal-gas CO₂ Shomate duty, methanol latent reference duty, exchanger area, pump flow/power, selected dimensional identities, synthetic compressor work, entropy/exergy sign primitives, synthetic KPI and economics identities, synthetic recycle convergence/non-convergence, and input-domain/failure-gate examples.

However, the Python calculations are not calls into MATLAB. The MATLAB test suite contains **31 source-defined checks**, but no MATLAB test report exists because neither MATLAB nor Octave is installed. Therefore all actual MATLAB unit tests, property functions, failure-path tests, recycle solver tests and equipment calculations in MATLAB remain NOT RUN.

| Requested test family | Independent evidence available | MATLAB test/runtime status | Disposition |
|---|---|---|---|
| Component and elemental balances | Atom balance by reaction and ideal component stoichiometry | NOT RUN | SCREENING ONLY |
| Reaction stoichiometry/feasibility | Independent reaction-matrix stoichiometry; no equilibrium/kinetic feasibility | NOT RUN | SCREENING ONLY |
| Property functions | Pure CO₂ Shomate formula and methanol latent reference | NOT RUN | SCREENING ONLY |
| Heat duties | Standard-state reaction enthalpy and pure-fluid reference duties | NOT RUN | SCREENING ONLY |
| Pump/compressor power | Pump equation; synthetic compressor primitive only | NOT RUN | SCREENING ONLY / BLOCKED for plant power |
| Entropy/exergy signs | Synthetic sign and T₀Sgen primitive checks | NOT RUN | SCREENING ONLY; physical balance BLOCKED |
| Equipment calculations | HX area and pump reference equation with assumptions | NOT RUN | SCREENING ONLY |
| KPI equations | Synthetic energy/water KPI dimensional identities | NOT RUN | SCREENING ONLY; actual KPIs BLOCKED |
| Recycle convergence | Synthetic scalar maps only | NOT RUN | SCREENING ONLY; physical recycle BLOCKED |
| Economics | Synthetic CRF/unit conversion identity only | NOT RUN | SCREENING ONLY; project economics BLOCKED |
| Invalid/edge inputs | Independent Python domain-policy checks | NOT RUN | SCREENING ONLY; MATLAB validation remains NOT RUN |

### 6.1 Input/failure conditions reviewed at the contract level

Negative flow, zero active flow, optional zero flow, NaN/infinite flow, invalid composition totals, negative or over-unity conversion, missing property, out-of-range CO₂ Shomate temperature, unavailable utility, synthetic overload and missing file were checked with independent Python/domain-policy assertions or source/data gate inspection. They do not execute MATLAB `input_validation.m`, `property_models.m`, utility/equipment modules, or the MATLAB loader. Treat them as screening assertions until rerun in MATLAB with retained output logs.

## 7. Integration test disposition

| Integration target | Evidence/result | Status | Reason |
|---|---|---|---|
| Complete process path from feeds through product/waste | No physical 55-stream states and no complete process solve. | BLOCKED | PR78, VLE, kinetics, recycle, streams, utilities and closures incomplete. |
| Recycle/purge loop integration | Synthetic fixed-point primitives only. | BLOCKED | Actual S-209/S-207 physical recycle is not configured with complete compositions, inerts, flash, purge criterion and compressor map. |
| Property/flash integration | Config/data records and property model source exist. | BLOCKED | PR78 kij matrix incomplete; no validated methanol-water VLE fit. |
| Utilities integration | Utility data templates exist. | BLOCKED | No site utility envelopes, vendor loads or actual compressor/steam/cooling/power demands. |
| Environmental KPI/MRV | Environmental input template exists. | BLOCKED | No measured boundaries, emissions factors/source data, certification protocol or validated process rates. |
| Economics integration | Cost input template and formulas exist. | BLOCKED | Prices, tariffs, installed costs, labour, maintenance and finance basis absent. |
| GUI Run/Reset, tables and plots | 80 static GUI source-contract assertions. | NOT RUN | No MATLAB UI execution. |
| GUI numerical export, stream table and datasheet export | No actual GUI export files/logs. | NOT RUN | MATLAB GUI runtime not available. |
| HMI sensor/actuator/comms faults and first-out | Requirements/source review only. | NOT RUN | No field I/O, PLC/DCS simulator or test harness. |
| Safety system/SIS/ESD/FGS independence | Conceptual read-only HMI boundaries only. | NOT RUN | No safety application, safety requirements specification or I/O integration. |

## 8. Project path, configuration and static-source verification

The first independent source review found and logged configuration defects:

- `project_config.json` did not declare the GUI folder while `run_gui.m` required `MATLAB/gui`.
- Data roots omitted `MATLAB/data` even though the GUI engine adapter needed versioned case/property/reaction/equipment/utility/cost/environmental/sensitivity records.
- Explicit paths consumed by `load_model_inputs.m` were missing from configuration.
- Startup smoke-test expectations were inconsistent with architecture: `main.m` is a startup preflight/diagnostic entry point, not the calculation orchestrator. `gui_run_engine.m` performs GUI calculation orchestration.
- The older static checker incorrectly expected calculation orchestration in `main.m`.

Corrections were applied to project configuration, the root/path validation policy, startup smoke-test expectations, static checker and README documentation. The corrected static evidence is:

| Check | Result | Meaning |
|---|---|---|
| Prompt 19 project/source/config/data-manifest checker | PASS, 100 checks; 55 hashed data files | Static integrity/source/data hash only. |
| Prompt 19 independent Python arithmetic audit | PASS, 50 checks | Python arithmetic regression only; not MATLAB. |
| Prompt 20 GUI source-contract checker | PASS, 80 checks | GUI code contract only; no UI launch or App Designer compatibility test. |
| Manifest SHA-256 check | PASS, 55/55 datasets | Data bytes match manifest. |
| Copy-based project relocation | PASS at filesystem/static contract layer | New extracted root, marker, config and manifest data paths resolve in copied tree. `START_HERE.m` was not executed in MATLAB. |
| No `pwd`, `genpath` or `pathdef` dependency in selected root/launcher/resolver sources | PASS at source scan | Does not prove MATLAB path behavior at runtime. |

Corrected logs are in `ENERGY008_Test_Logs/`. The original checker/launcher discrepancies and their corrections are recorded in `ENERGY008_Defect_and_Correction_Log.csv`.

## 9. Model physics gates and unresolved applicability

The following items must remain null/BLOCKED, not assumed or zero-filled:

- Physical S-209 recycle, S-207 purge fraction and V-301 flash split.
- Actual S-314 methanol product composition/specification.
- Catalyst-matched reactor kinetic conversion, reactor volume and catalyst mass.
- Complete plant material and energy closure.
- Plant entropy generation and exergy destruction.
- Actual K-101/K-201/K-301 compressor power.
- Actual HX-301 duty/area and vendor-equivalent equipment sizing.
- Physical electrolyser performance, BOP loads, dynamic response and hydrogen buffer sizing.
- Complete utility demand, environmental KPI/MRV, CAPEX and OPEX.

PR78 remains a candidate, but the active binary-interaction parameter matrix is incomplete. Modified SRK cross-check is not parameterised. Methanol-water Wilson/NRTL parameters are not fitted/validated. IAPWS-IF97 is selected for water/steam, but complete runtime implementation/evidence is absent. PFR structure is present but catalyst-specific kinetic constants/validity and geometry are absent. No plant product quality or compliance claim is supported.

## 10. Defect and correction record

The CSV ledger classifies each observed issue as corrected or open, includes the original finding, correction, evidence path and residual runtime dependency. Key unresolved acceptance failures remain R-02 (alternative evaluation) and R-18 (sensitivity breadth). Correcting configuration/source-contract defects does not resolve missing physical models or the assignment's failed acceptance minima.

## 11. Prompt 22 handoff: permitted and prohibited use

### 11.1 Permitted verified/reference outputs

Prompt 22 may use only these values with their explicit tags and scopes:

- The ideal 50 t/day Route C reaction stoichiometric reference rates and C/H/O atom balance identities as **SCREENING ONLY / REFERENCE ONLY**.
- The NIST standard-state reaction enthalpy identities for R-01 and E-01, as standard-state thermochemistry only.
- The pure ideal CO₂ Shomate heat duty and pure methanol latent reference duty within their documented correlation/pure-fluid scopes.
- The illustrative HX and water-pump equations only as **SCREENING ONLY**, with assumptions visible.
- The 25 t/day linear stoichiometric scaling and DB-059 two-hour linear H₂ deficit only as **SCREENING ONLY**.
- Static project/configuration/manifest and GUI source-contract evidence only as source-level evidence, not runtime claims.

### 11.2 Prohibited conclusions

Prompt 22 must not:

- Claim Route C is selected/approved or the G3 basis is frozen.
- Rank or recommend routes using Alt 1/Alt 2 because Alt 2 is blocked and Alt 1 is only a common-core comparison.
- Call 50 t/day a validated plant nameplate capacity.
- Use reference enthalpy rates as plant heater, reactor cooling or purchased electricity duties.
- Use synthetic compressor, entropy/exergy, KPI, recycle or economics primitive values as plant results.
- Claim product specification, reactor conversion, product yield, purge/recycle, utilities, environmental performance or profitability.
- Claim MATLAB engine tests, GUI launches, screenshots, run exports, path discovery in MATLAB or physical-model validation occurred.

### 11.3 Closure required before optimisation recommendations

1. Freeze a reviewed design basis and approve feed/product/utility quality and operating envelopes.
2. Provide complete physical stream states, validated property parameters, catalyst-matched kinetics, separator/flash data and recycle/purge control criteria.
3. Execute MATLAB unit, integration, GUI and failure-path tests on the target MATLAB release; retain raw test logs, screenshots and export examples.
4. Independently close plant mass, energy, entropy and exergy balances with dimensional consistency, physical bounds and uncertainty.
5. Evaluate at least two alternatives on the same complete basis; develop at least six justified sensitivity parameters and one multivariable method.
6. Obtain equipment vendor maps/datasheets, site utility data, project cost inputs and environmental/MRV boundary evidence.
7. Complete independent model verification/validation and close the assignment acceptance checklist before final optimisation conclusions.

## 12. Reproducibility files

- `ENERGY008_Verification_Matrix.xlsx` includes the 27-topic traceability matrix, original curated 82-record register, acceptance checklist, case/decision sheets and a separate `Prompt 21 Python Audit` sheet containing all 115 additional audit assertions.
- `ENERGY008_Independent_Comparison.xlsx` compares Route C reference arithmetic, Route A common-core reference, Route B blocked gate, turndown, DB-059 disturbance, external NIST standard-state data and equipment screening.
- `ENERGY008_Test_Logs/independent_test_results.csv` and `.json` contain the detailed run-level records.
- `ENERGY008_Test_Logs/independent_verification.log` summarizes the Python audit environment and status counts.
- `ENERGY008_Test_Logs/prompt19_static_check_corrected.log`, `prompt19_independent_arithmetic_check.log` and `gui_source_contract_check.log` retain corrected static check outputs.
- `ENERGY008_Defect_and_Correction_Log.csv` records original defects, corrective actions and residual limitations.
- `Prompt22_Handoff.md` is the short-form continuation brief.

**Final disposition:** ENERGY-008 has reproducible ideal/reference calculations and a materially improved, statically consistent MATLAB/GUI source package. The physical model remains unvalidated; assignment acceptance remains FAIL/BLOCKED/NOT RUN in the topics identified above. No result beyond the explicit reference/screening scope is suitable for design release or optimisation recommendation.
