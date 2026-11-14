# ENERGY-008 Assignment Extraction and Requirements Baseline

**Project ID:** ENERGY-008  
**Assignment title:** Green methanol synthesis — Utility integration and energy KPIs  
**Governing source:** `PSLassignment2.pdf`, 5 pages, Topics 1–27  
**Supporting workflow source:** `Universal_Engineering_Master_Prompt(1).txt`  
**Baseline status:** Requirements extracted; technical design, route selection and calculations intentionally not started.

## 1. Source hierarchy and interpretation rules

1. `PSLassignment2.pdf` is the governing source for assignment requirements. Its 27 numbered topics and nine-item Topic 27 acceptance checklist are reproduced below in source order.
2. `Universal_Engineering_Master_Prompt(1).txt` is used as a workflow and engineering-integrity guide: staged prompts, explicit handoffs, evidence, provenance, reproducibility, limitations and approval points. It does not replace or rewrite assignment wording.
3. Assignment-stated requirements are distinguished from proposed engineering best practices. Any recommendation not present in the assignment is labelled as a recommendation, not an assignment obligation.
4. No CPS-01 or CPS-22 engineering data, thermodynamic models, process values or design assumptions are carried into ENERGY-008. The only inherited context is the preference for staged execution and the CPS-01 report's visual/structural reference.
5. This remains a preliminary academic design exercise, not a certified plant design. The assignment itself says not to assign SIL or claim certified safety integrity without formal risk assessment.

## 2. Assignment identity and purpose

The assignment is **ENERGY ASSIGNMENT 008**, Sector: Energy and Renewable Industrial Systems. The project is titled **Green methanol synthesis — Utility integration and energy KPIs**. It is framed for an Indian manufacturing/process-industry context and calls for traceable data and clearly labelled assumptions.

**Purpose (Topic 1):** Develop a modular engineering model linking product quality, throughput, equipment sizing, utilities, economics and industrial automation; demonstrate reproducible calculations and evaluate feasible operating conditions.

**Core problem (Topic 2):** Convert a defined feed/design basis into product and waste flow rates, operating conditions, equipment dimensions/duties, utility requirements, preliminary cost estimates and a control philosophy. Compare a base case with at least two alternatives and recommend an operating window.

## 3. Mandatory minimums and explicit coverage commitments

| ID | Minimum / commitment | Source classification | Objective evidence |
|---|---|---|---|
| MIN-01 | Base case plus at least two alternatives | Assignment-stated minimum (Topic 2) | Case definition register; side-by-side comparison; operating-window recommendation |
| MIN-02 | Steady state, start-up, shutdown, turndown and at least one disturbance case | Assignment-stated minimum (Topic 3; Topic 14; Topic 23) | Operating-case register; time/state sequence; disturbance input and response/test evidence |
| MIN-03 | Every major feed, product, recycle, purge, wastewater, off-gas and solid-waste stream | Assignment-stated minimum (Topic 7) | Stream register/table with flow, composition, phase, temperature, pressure and quality attributes |
| MIN-04 | Overall/component mass balance; energy; entropy; exergy | Assignment-stated minimum (Topics 5, 7, 8, 9, 10; Acceptance 3) | Calculation records, closure/residual tables, declared conventions and reference environment |
| MIN-05 | One detailed datasheet for each major item, with specified fields and calculation trail | Assignment-stated minimum (Topic 11; Acceptance 4) | Major equipment list; calculation trail; datasheet package covering tag/service through code/standard to verify |
| MIN-06 | PFD plus P&ID-level sketch for critical equipment | Assignment-stated minimum (Topic 12; Final Package) | PFD with feed conditioning/core/separation/recycle/product/waste/utilities; P&ID sketch showing listed details |
| MIN-07 | PLC/DCS/SCADA-compatible control philosophy and loop register with specified fields | Assignment-stated minimum (Topic 13) | Loop register including ID, PV, sensor, MV, final element, controller, SP/range, alarms, interlocks, failure position and operator action |
| MIN-08 | Modes, state/step sequence, HMI overview/faceplates/trends/alarms/interlocks/reports/operator guidance | Assignment-stated minimum (Topic 14; Topic 21) | Mode matrix; state/sequence diagram; HMI prototype/screens; transition, permissive, timeout, abort/restart definitions |
| MIN-09 | Alarm register and interlock/cause-and-effect documentation; safe responses | Assignment-stated minimum (Topics 11, 13, 14; Final Package) | Alarm register with tag, priority, limit, deadband, delay, cause, consequence, action; interlock matrix and failure position/response |
| MIN-10 | At least six variables; one-at-a-time and at least one multivariable method | Assignment-stated minimum (Topic 18; Acceptance 7) | Variable/range justification; OAT outputs; multivariable-method description/results; constraint checks |
| MIN-11 | Three types: process flowchart, numerical solver/calculation flowchart, automation state/sequence diagram | Assignment-stated minimum (Topic 19) | Three distinct diagrams with inputs, calculations, decisions, convergence, alarms/interlocks, exceptions and outputs as applicable |
| MIN-12 | All 13 named .m modules | Assignment-stated minimum (Topic 20) | input_validation.m; property_models.m; material_balance.m; energy_balance.m; entropy_exergy.m; equipment_sizing.m; utilities_model.m; control_logic.m; economics.m; sensitivity_optimisation.m; validation_checks.m; reporting_plots.m; main.m |
| MIN-13 | MATLAB App Designer or equivalent; ten named tabs; unit-aware inputs, validation, plots, datasheet export, assumed-data warnings | Assignment-stated minimum (Topic 21) | Prototype and evidence of design basis, streams, operating conditions, equipment, balances, utilities, economics, automation, sensitivity and reports tabs |
| MIN-14 | Unit and regression tests for at least three cases with reproducible inputs | Assignment-stated minimum (Topic 23; Acceptance 8) | Three or more case input sets, test scripts/logs, verification matrix |
| MIN-15 | GUI-independent model; MATLAB-to-Python module mapping using listed ecosystem; preserve units/tests/outputs and state limitations | Assignment-stated minimum (Topic 24; Acceptance 8; Final Package) | Migration note and/or Python implementation, dependency/licence/data limitations, parity results |
| MIN-16 | Editable Word/PDF report with referenced data and calculation trail; equations as editable Word Equation objects | Assignment-stated minimum (Topic 25; Topic 26; Acceptance 2) | DOCX and PDF; reference/citation trail; editable equations; defined nomenclature |
| MIN-17 | MATLAB source, input data, README and reproducible run instructions | Assignment-stated minimum (Topic 26) | Source tree, input files, README with environment/run instructions, example run |
| MIN-18 | GUI prototype, example input, result tables and plots | Assignment-stated minimum (Topic 26) | GUI files, example input, result tables, plot files |
| MIN-19 | PFD, P&ID-level sketch, equipment datasheets, loop register, alarm/interlock matrix and sequence diagram | Assignment-stated minimum (Topic 26) | Drawing files and controlled register/datasheet files |
| MIN-20 | Balance tables, utility summary, cost model and sensitivity results | Assignment-stated minimum (Topic 26) | Mass/energy/entropy/exergy tables; utility model; CAPEX/OPEX model; sensitivity outputs |
| MIN-21 | Verification matrix, test cases, limitations statement and Python migration note | Assignment-stated minimum (Topic 26) | Test/verification matrix, reproducible inputs and logs, limitations statement, Python migration note |
| MIN-22 | Short presentation summarising key results and recommendations | Assignment-stated minimum (Topic 26) | Editable presentation/PDF deck with key results and recommendations |
| MIN-23 | Project ZIP containing the final submission package | Project-level handoff expectation (not a PDF assignment clause) (Universal Engineering Master Prompt and user handoff instruction; not stated in PDF Topic 26) | ZIP archive, file manifest and extraction/integrity check |

**Important classification:** the ZIP archive is tracked as a project-level handoff expectation from the universal workflow prompt and the current handoff instruction. It is not listed as a bullet in Topic 26 of the PDF. The PDF does require the editable Word/PDF report and the supporting artifacts mapped in MIN-16 through MIN-22.

## 4. Topic-by-topic extraction (all 27 numbered topics)

### Topic 1. Assignment Purpose (1)

**Assignment wording:** Develop a modular engineering model for green methanol synthesis — utility integration and energy kpis, linking product quality, throughput, equipment sizing, utilities, economics and industrial automation. Demonstrate reproducible calculations and evaluate feasible operating conditions.

**Requirement interpretation:** Develop a modular engineering model for green methanol synthesis focused on utility integration and energy KPIs, linking product quality, throughput, equipment sizing, utilities, economics and industrial automation, with reproducible calculations and evaluation of feasible operating conditions.

**Required evidence:** Project objective statement; scope-to-module map showing the links among quality, throughput, equipment, utilities, economics and automation; reproducibility plan and defined operating-window evaluation outputs.

**Expected location:** Report: Executive Summary; Design Basis; Model Architecture. Repository: README and module map. Traceability workbook.

**Dependencies:** R-02, R-03, R-04

**Acceptance criterion:** The project objective and model coverage are explicitly stated; every named domain is represented by a planned deliverable; reproducible inputs and outputs are identified.

**Status:** Extracted; engineering evidence pending

**Proposed best practice (not a separate assignment requirement):** Add a project charter, document owner, revision history and a one-page scope diagram. These are useful controls, not separate assignment clauses.

### Topic 2. Core Problem Statement (1)

**Assignment wording:** Convert a defined feed/design basis into product and waste flow rates, operating conditions, equipment dimensions/duties, utility requirements, preliminary cost estimates and a control philosophy for green methanol synthesis — utility integration and energy kpis. Compare a base case with at least two alternatives and recommend an operating window.

**Requirement interpretation:** Convert a defined feed/design basis into product and waste flow rates, operating conditions, equipment dimensions and duties, utility requirements, preliminary cost estimates and a control philosophy. Compare one base case with at least two alternatives and recommend an operating window.

**Required evidence:** Approved design-basis sheet; named base case and at least two distinct alternatives; comparison table covering comparable outputs; documented operating-window recommendation with constraints and evidence.

**Expected location:** Report: Executive Summary; Design Basis; Scenario Comparison; Recommendations. Inputs: case-definition file. Results: comparison tables and plots.

**Dependencies:** R-03, R-04, R-05, R-06, R-18

**Acceptance criterion:** One base case and at least two alternatives are evaluated on a consistent basis; each required output is reported; the recommended operating window is traceable to the comparison.

**Status:** Extracted; case definitions and engineering evidence pending

**Proposed best practice (not a separate assignment requirement):** Define a common comparison basis, KPI weighting, uncertainty bands and a decision table before ranking alternatives. The exact decision method is not specified by the assignment.

### Topic 3. Project-Specific Technical Scope (1)

**Assignment wording:** Define process boundaries from feed receipt/conditioning to product, recycle, waste and utilities. Include steady state, start-up/shutdown, turndown and at least one disturbance case. Address quality, yield, environmental impacts and process hazards relevant to green methanol synthesis — utility integration and energy kpis.

**Requirement interpretation:** Define boundaries from feed receipt and conditioning through product, recycle, waste and utilities. Cover steady state, start-up, shutdown, turndown and at least one disturbance. Address product quality, yield, environmental impacts and process hazards.

**Required evidence:** Battery-limit/process-boundary statement; process block diagram; operating-case register; disturbance-case definition; quality/yield KPI list; environmental and hazard screening records.

**Expected location:** Report: Process Description; Design Basis; Operating Cases; Environmental Considerations; Safety Screening. Drawings: BFD/PFD. Registers: case register and hazard/issues register.

**Dependencies:** R-02, R-04, R-12, R-14, R-15

**Acceptance criterion:** Boundary includes feed receipt/conditioning, product, recycle, waste and utilities; steady state, start-up, shutdown, turndown and at least one disturbance are all represented; quality, yield, environmental and hazard topics are addressed.

**Status:** Extracted; boundary and case evidence pending

**Proposed best practice (not a separate assignment requirement):** Add a formal battery-limit table, interface register and cause/consequence narrative for each selected disturbance. These strengthen auditability but are not separately worded requirements.

### Topic 4. Engineering Inputs and Data (1)

**Assignment wording:** Design throughput, operating hours, feed composition, density, viscosity, heat capacity, moisture/solids and relevant phase/property data. Target product specification, yield/recovery, purity, moisture, particle size, conversion, sterility or energy performance as applicable. Operating and design temperature/pressure, residence time, allowable pressure drop, cycle time, turndown and downtime. Steam, cooling, electricity, fuel, water, compressed air, solvent/catalyst and waste-treatment tariffs, as relevant. Materials compatibility, corrosion/fouling assumptions, utility limits, equipment availability and uncertainty ranges. For missing site/vendor data, create an illustrative design basis, mark assumptions and test their impact; do not present assumed values as industrial facts.

**Requirement interpretation:** Establish design throughput and operating hours; feed composition and relevant physical properties; target product specification and performance; operating/design temperatures and pressures, residence time, pressure drop, cycle time, turndown and downtime; relevant utility and waste-treatment tariffs; materials compatibility, corrosion/fouling assumptions, utility limits, equipment availability and uncertainty ranges. Missing site/vendor data may be represented by an illustrative design basis only when clearly marked as assumptions and impact-tested.

**Required evidence:** Input register with value or OPEN status, units, source/provenance, operating conditions, uncertainty, assumption flag and approval; design-basis register; property-data manifest; utility/tariff source register; missing-data impact plan.

**Expected location:** Report: Design Basis; Data Provenance; Assumptions and Limitations. Repository: inputs/ and data_manifest.csv. Workbook: Open Decisions and approved design-basis register.

**Dependencies:** R-02, R-03, R-05, R-11, R-15, R-16, R-17

**Acceptance criterion:** Every input needed by the selected process is either source-supported or explicitly identified as an approved assumption; units, ranges, uncertainty and provenance are recorded; assumptions are not presented as industrial facts.

**Status:** Extracted; all material inputs unresolved

**Proposed best practice (not a separate assignment requirement):** Use a controlled input schema with source type, version, validity range, uncertainty and approval metadata; maintain separate measured, literature, vendor and assumed-data classes.

### Topic 5. Governing Equations and Model Formulation (1-2)

**Assignment wording:** Implement project-specific equations for reaction kinetics, phase equilibrium, separation, filtration, drying, membrane flux, crystallisation, electrochemical conversion, hydraulics or other relevant phenomena. State assumptions, units and validity limits. Minimum balance/design equations: ṁ_in = ṁ_product + ṁ_recycle + ṁ_waste + dM/dt (overall mass balance; also write component balances for key species); Q̇ = ṁ Cp (T_out − T_in); Q̇ = U A ΔT_lm (sensible heat duty and preliminary exchanger area; include latent/reaction heat when applicable); P_shaft = ρ g Q̇_v H / η_p (pump power estimate; include motor efficiency and service factor); Ṡ_gen = ΣṠ_out − ΣṠ_in − Σ(Q̇_p/T_p) ≥ 0 (entropy balance using a declared sign convention); Ė_D = T₀ Ṡ_gen; Ex_in + Ex_fuel = Ex_product + Ex_waste + Ė_D (exergy destruction/balance relative to a defined environment); A = Q̇/(U ΔT_lm); V_working = Q̇_v τ (preliminary heat-transfer area and vessel volume).

**Requirement interpretation:** Implement process-specific governing equations and state assumptions, units and validity limits. Retain the assignment's minimum balance/design equations: overall and component mass balances; sensible heat and preliminary exchanger area; pump shaft power with motor efficiency/service factor; entropy generation balance with sign convention; exergy destruction and balance relative to an environment; preliminary heat-transfer area and working vessel volume.

**Required evidence:** Equation register with editable Word equations, symbol definitions, units, assumptions and validity ranges; derivation/substitution trail for every implemented equation; model-selection justification; dimensional checks; source references for correlations and property models.

**Expected location:** Report: Equations, Assumptions and Numerical Method; Appendices: Equation Register and Calculation Trail. Source: model modules. Workbook/CSV: variable dictionary.

**Dependencies:** R-03, R-04, R-06, R-07, R-08, R-09, R-10, R-11

**Acceptance criterion:** All applicable equations are stated with defined symbols, units, sign conventions, assumptions and validity limits; every equation used in calculations has a traceable derivation or source; assignment minimum equations are addressed or applicability is explicitly justified.

**Status:** Extracted; equation selection and calculation evidence pending

**Proposed best practice (not a separate assignment requirement):** Add an equation-to-code function map, unit-test identifier and uncertainty propagation note for each model equation. The assignment does not explicitly require this exact mapping.

### Topic 6. Numerical Algorithm (2)

**Assignment wording:** Validate inputs, units, bounds and composition totals. Calculate feed/component flows and solve material balances in process-flow order. Iterate recycle loops to a stated residual tolerance; log convergence. Calculate energy, entropy and exergy balances and balance closure. Size main and auxiliary equipment for normal, turndown and upset cases. Estimate utilities, economics and KPIs; run sensitivity and optimisation. Export stream tables, equipment datasheets, plots, control logic and test results.

**Requirement interpretation:** Validate inputs, units, bounds and composition totals; calculate component flows and solve balances in process-flow order; iterate recycle loops to a stated residual tolerance and log convergence; calculate and close energy, entropy and exergy balances; size equipment for normal, turndown and upset cases; estimate utilities, economics and KPIs; run sensitivity/optimisation; export required engineering evidence.

**Required evidence:** Numerical method/solver flowchart; algorithm description; input validation report; recycle residual/convergence log; closure report; normal/turndown/upset calculation records; exported results manifest.

**Expected location:** Report: Numerical Method; Repository: solver modules, run log and validation outputs; Flowcharts: numerical solver/calculation flowchart.

**Dependencies:** R-04, R-05, R-07, R-08, R-09, R-10, R-11, R-18, R-19

**Acceptance criterion:** The workflow follows process-flow order; validation, recycle residual tolerance and convergence logs exist; all three balance families (energy, entropy, exergy) plus material are closed/reported; sizing covers normal, turndown and upset cases; outputs are exportable.

**Status:** Extracted; algorithm and evidence pending

**Proposed best practice (not a separate assignment requirement):** Specify numerical tolerances by residual type, convergence safeguards, scaling, solver fallback behaviour and deterministic run configuration before implementation.

### Topic 7. Material Balances (2)

**Assignment wording:** Tabulate every major feed, product, recycle, purge, wastewater, off-gas and solid-waste stream with flow, composition, phase, temperature, pressure and quality attributes. Report overall/component closure and explain discrepancies. ε_p = 100(Σṁ_in − Σṁ_out − dM/dt)/max(Σṁ_in, ε).

**Requirement interpretation:** Tabulate every major feed, product, recycle, purge, wastewater, off-gas and solid-waste stream, including flow, composition, phase, temperature, pressure and quality attributes. Report overall and component closure and explain discrepancies.

**Required evidence:** Complete stream register; stream table with all stated fields; overall and key-component balance calculations; closure/residual table using the assignment's stated closure expression; discrepancy explanation.

**Expected location:** Report: Process Description and Stream Table; Material Balance Chapter; Appendices: Stream Register and Closure Calculations. Repository: stream input/output files.

**Dependencies:** R-03, R-04, R-05, R-06

**Acceptance criterion:** Every major stream category applicable to the selected route is included; required attributes are present; overall and component closure is quantified; discrepancies are explained and not concealed.

**Status:** Extracted; no streams or balances created in this phase

**Proposed best practice (not a separate assignment requirement):** Add unique stream IDs, source/destination equipment, phase basis, wet/dry basis and a version-controlled stream data dictionary. The exact extra fields are recommended, not explicit assignment wording.

### Topic 8. Energy Balance and Thermal Design (2)

**Assignment wording:** Calculate sensible/latent heat, reaction or electrical work, losses, heat recovery and utility consumption. Create a duty table for heaters, coolers, condensers, reboilers, dryers, reactors/stacks and other selected equipment. ΣĤ_in + Q̇ − Ẇ = ΣĤ_out + dE_cv/dt.

**Requirement interpretation:** Calculate sensible and latent heat, reaction/electrical work, losses, heat recovery and utility consumption. Provide a duty table for heaters, coolers, condensers, reboilers, dryers, reactors/stacks and other selected equipment. Retain the stated control-volume enthalpy balance.

**Required evidence:** Energy balance per selected control volume; heat/work terms and sign convention; heat-duty table; utility consumption summary; heat-recovery assessment; energy closure/residual evidence.

**Expected location:** Report: Energy Balance and Thermal Design; Equipment Datasheets; Utilities Summary; Appendices: Worked Duty Calculations.

**Dependencies:** R-04, R-05, R-06, R-07, R-11, R-15

**Acceptance criterion:** All relevant sensible/latent/reaction/electrical/work/loss/recovery terms are addressed; each selected heater/cooler/other duty is tabulated; energy closure is reported with sign convention and assumptions.

**Status:** Extracted; energy calculations pending

**Proposed best practice (not a separate assignment requirement):** Provide an energy Sankey or heat-integration summary and separate purchased, recovered and internally generated energy. These are useful presentation enhancements, not explicit mandatory formats.

### Topic 9. Entropy Balance (2)

**Assignment wording:** Estimate entropy flow changes for major streams when properties are available. Identify irreversibility from finite-temperature heat transfer, pressure drop, mixing, reaction and separation. State approximations where property data are unavailable.

**Requirement interpretation:** Estimate entropy flow changes for major streams where properties are available. Identify irreversibility from finite-temperature heat transfer, pressure drop, mixing, reaction and separation. State approximations where properties are unavailable.

**Required evidence:** Entropy flow table for major streams where supported; control-volume entropy balance; declared sign convention; list/ranking of relevant irreversibility mechanisms; property-data gaps and approximations.

**Expected location:** Report: Entropy Balance; Appendices: Entropy Calculation Tables and Property Assumptions.

**Dependencies:** R-04, R-05, R-06, R-07, R-08

**Acceptance criterion:** Entropy flow changes are estimated where properties permit; the named irreversibility mechanisms are assessed for relevance; missing properties and approximations are explicitly stated.

**Status:** Extracted; entropy method and results pending

**Proposed best practice (not a separate assignment requirement):** Report entropy-generation contributions by equipment or mechanism and include a consistency check against the second law. This is an extension to make the ranking auditable.

### Topic 10. Exergy Balance (2)

**Assignment wording:** Define dead-state T₀ and reference environment; estimate physical and, where justified, chemical/electrical exergy. Rank major exergy destruction sources and propose two improvement measures.

**Requirement interpretation:** Define dead-state temperature T₀ and reference environment; estimate physical exergy and chemical/electrical exergy where justified; rank major exergy destruction sources and propose two improvement measures.

**Required evidence:** Declared dead-state and reference-environment record; exergy accounting method; physical and justified chemical/electrical exergy calculations; destruction ranking; two documented improvement measures.

**Expected location:** Report: Exergy Balance; Appendices: Exergy Reference Basis and Calculation Tables; Recommendations.

**Dependencies:** R-04, R-05, R-06, R-08, R-09

**Acceptance criterion:** T₀ and reference environment are declared; included exergy forms are justified; major destruction sources are ranked; two improvement measures are proposed and linked to the ranking.

**Status:** Extracted; exergy reference basis and results pending

**Proposed best practice (not a separate assignment requirement):** Separate physical, chemical and electrical exergy contributions in the register and state reference-state property conventions. This level of decomposition is recommended beyond the minimum.

### Topic 11. Detailed Equipment Selection and Design Calculations (2-3)

**Assignment wording:** Select major equipment and auxiliaries with justified materials of construction, design/normal/minimum/maximum capacity, operating/design pressure and temperature, fouling/corrosion allowance, cleaning access and turndown. Main vessel/reactor/line: size capacity from throughput and residence time; calculate heat duty, working volume, mixing/drive power, diameter/head/pressure drop as applicable. Ancillaries: size pump/compressor, filters, heat exchangers, storage, ventilation and waste-treatment equipment; calculate utility and power requirements. Control package: feed/ratio, temperature, pressure, level, quality and throughput loops with alarms, interlocks and defined safe-state responses. For each major item submit a datasheet: tag/service, capacity, phase, normal/design P/T, material, calculated duty/area/volume/diameter/head/power, assumptions/margin, connections, instrumentation, utilities, relief/safeguards, footprint, cleaning/maintenance access and code/standard to verify. Show equations, substituted values, intermediate results, selected preliminary size, normal/upset checks and uncertainty.

**Requirement interpretation:** Select major equipment and auxiliaries with justified materials of construction, normal/design/minimum/maximum capacity, operating/design pressure and temperature, fouling/corrosion allowance, cleaning access and turndown. Size main vessel/reactor/line and ancillaries as applicable. Submit a detailed datasheet for each major item, with the specified design, instrumentation, utility, safeguard, footprint, maintenance and code/standard fields; show calculation trail, preliminary size, normal/upset checks and uncertainty.

**Required evidence:** Equipment list and selection rationale; design calculation package; one complete datasheet per major equipment item with all listed fields; calculation trail showing equation, substitutions, intermediate values, selected preliminary size, normal/upset checks and uncertainty; materials and code/standard verification register.

**Expected location:** Report: Equipment Selection and Design Calculations; Appendix: Equipment Datasheets; Repository: datasheets/ and equipment-sizing modules; PFD/P&ID references.

**Dependencies:** R-04, R-05, R-06, R-07, R-08, R-09, R-10, R-12, R-13

**Acceptance criterion:** Every major and selected auxiliary item is justified and sized; every major item has a complete datasheet with the source-listed fields; intermediate calculations and uncertainty are visible; normal/upset checks are present.

**Status:** Extracted; no equipment selection or sizing performed

**Proposed best practice (not a separate assignment requirement):** Maintain an equipment register linking each tag to stream IDs, drawing references, datasheet revision and calculation file. This improves traceability but is not a separately stated assignment artifact.

### Topic 12. PFD and P&ID-Level Definition (3)

**Assignment wording:** Draw a PFD with feed conditioning, core process, separation, recycle, product, waste and utilities. Add a P&ID-level sketch for critical equipment with isolation/control/check valves, drains/vents, relief devices, sample points, bypasses, instrument tags and safe maintenance boundaries.

**Requirement interpretation:** Create a PFD showing feed conditioning, core process, separation, recycle, product, waste and utilities. Add a P&ID-level sketch for critical equipment showing the specified valves, drains/vents, relief devices, sample points, bypasses, instrument tags and safe maintenance boundaries.

**Required evidence:** PFD with process sections, stream IDs and utility ties; P&ID-level sketch for critical equipment with every specified fitting/instrument/safeguard category; drawing legends and revision details.

**Expected location:** Report: Process Description; Drawings folder: PFD and P&ID-level sketch; Appendix: Drawing Legend and Equipment/Instrument Tag Cross-Reference.

**Dependencies:** R-03, R-07, R-11, R-13, R-14, R-15

**Acceptance criterion:** PFD contains all stated process sections; P&ID-level sketch covers critical equipment and the listed valves, drains/vents, relief, sampling, bypass, instrument tags and maintenance boundaries.

**Status:** Extracted; route-dependent drawings pending

**Proposed best practice (not a separate assignment requirement):** Use consistent tag numbering, line numbering, drawing revision blocks and a legend based on a recognized drafting convention. The assignment does not name a specific drafting standard.

### Topic 13. Industrial Process Automation and Control (3)

**Assignment wording:** Design a PLC/DCS/SCADA-compatible control philosophy for the named process. Provide a loop register with loop ID, PV, sensor, MV, final element, controller, set point/range, alarm limits, interlocks, failure position and operator action. Include process-specific measurements such as pH, conductivity, moisture, turbidity, DO, composition, current, vibration, gas detection or differential pressure where relevant. Example loop rows: FIC-101, TIC-101, PIC-101, LIC-101 and ESD/SIS with their respective sensors, actuators, objectives, alarms/interlocks and failure responses.

**Requirement interpretation:** Provide a PLC/DCS/SCADA-compatible control philosophy and loop register containing loop ID, PV, sensor, MV, final element, controller, set point/range, alarm limits, interlocks, failure position and operator action. Include applicable process-specific measurements. Preserve the supplied example loop table as an illustrative source pattern.

**Required evidence:** Control philosophy; complete loop register with every required field; I/O and instrument list; mapping from selected PFD/P&ID tags; process measurement justification; safe-state response entries; source example rows considered and adapted only where route-relevant.

**Expected location:** Report: Automation Philosophy; Registers: Control Loop Register and Instrument/I/O List; Drawings: P&ID-level sketch; Appendix: Control Narrative.

**Dependencies:** R-03, R-11, R-12, R-14

**Acceptance criterion:** PLC/DCS/SCADA-compatible philosophy is documented; every loop has the required fields; process-specific measurements are selected where relevant; alarms, interlocks, failure positions and operator actions are stated; example table structure is traceably addressed.

**Status:** Extracted; loop register pending route and equipment selection

**Proposed best practice (not a separate assignment requirement):** Add controller mode, control strategy, signal range, instrument range, calibration/maintenance notes and alarm rationalisation rationale if useful. These additions are not explicit mandatory fields.

### Topic 14. PLC/DCS, HMI, Sequencing and Alarm Requirements (3)

**Assignment wording:** Define manual, maintenance, automatic, start-up, normal, cleaning/regeneration, shutdown and emergency modes as applicable. Create a state/step sequence with permissives, transitions, timeouts, abort and restart conditions. Specify HMI overview, equipment faceplates, trends, alarms, active interlocks, batch/shift report and operator guidance. Create alarm register with tag, priority, limit, deadband, delay, cause, consequence and action; avoid alarm flooding. Simulate utility loss, sensor/actuator failure, communications loss and off-spec operation; define safe responses. Record time-stamped process values, set points, alarms, overrides, lot identity and KPIs with access controls. Distinguish basic process control from independent safety functions. Do not assign SIL or claim certified safety integrity without formal risk assessment.

**Requirement interpretation:** Define applicable operating modes; create state/step sequencing with permissives, transitions, timeouts, abort and restart conditions; specify HMI overview, faceplates, trends, alarms, interlocks, reports and operator guidance; create an alarm register with priority/limit/deadband/delay/cause/consequence/action; simulate utility loss, sensor/actuator failure, communications loss and off-spec operation; record time-stamped values, set points, alarms, overrides, lot identity and KPIs with access controls. Distinguish basic control from independent safety functions and do not claim SIL without formal risk assessment.

**Required evidence:** Mode matrix; state/step sequence diagram and transition/permissive table; HMI screen mock-up/prototype; alarm register; cause-and-effect/interlock matrix; failure/disturbance test records; time-stamped historian/log schema and access-control statement; BPCS vs independent safety function boundary statement.

**Expected location:** Report: Automation Philosophy; Drawings: State/Sequence Diagram and Cause-and-Effect Matrix; GUI/HMI prototype; Registers: Alarm and Interlock Register; Test Evidence: automation scenarios.

**Dependencies:** R-03, R-11, R-12, R-13, R-19, R-21, R-23

**Acceptance criterion:** All applicable modes and required sequencing/HMI functions are documented; the alarm register contains every listed field; utility-loss, sensor/actuator-failure, communications-loss and off-spec cases are simulated with defined safe responses; required time-stamped records and access controls are specified; BPCS and independent safety functions are distinguished; no unsupported SIL claim appears.

**Status:** Extracted; control scenarios and evidence pending

**Proposed best practice (not a separate assignment requirement):** Add alarm priority philosophy, response-time assumptions, operator workload review, cybersecurity roles and event retention policy. These are enhancements unless later required by a chosen standard or site.

### Topic 15. Utilities, Environment and Waste (3)

**Assignment wording:** Quantify steam/hot water, cooling/refrigeration, electricity, fuel, compressed air, water, inert gas, solvents and treatment utilities as applicable. Quantify wastewater, off-gas, emissions, rejected product and solid residues; evaluate reuse/recovery and identify relevant Indian regulatory/standards checks.

**Requirement interpretation:** Quantify applicable steam/hot water, cooling/refrigeration, electricity, fuel, compressed air, water, inert gas, solvents and treatment utilities. Quantify wastewater, off-gas, emissions, rejected product and solid residues; evaluate reuse/recovery and identify relevant Indian regulatory/standards checks.

**Required evidence:** Utility demand/supply summary by service; waste/emission stream register; reuse/recovery options; boundary definition; list of relevant Indian regulatory/standards checks with applicability status and sources.

**Expected location:** Report: Utilities, Environmental Considerations and Safety Screening; Registers: Utility Balance and Waste/Emission Register; Appendices: Regulatory Applicability Check.

**Dependencies:** R-03, R-04, R-07, R-08, R-12, R-16, R-17

**Acceptance criterion:** Applicable utilities and waste/emission categories are quantified; reuse/recovery is evaluated; relevant Indian requirements are identified and applicability is checked rather than presumed.

**Status:** Extracted; utilities and environmental boundary unresolved

**Proposed best practice (not a separate assignment requirement):** Add a water balance, emissions inventory by source, boundary/interface table and compliance obligation register after site and boundary decisions are approved.

### Topic 16. CAPEX Screening (4)

**Assignment wording:** Estimate major equipment, installation, piping, instrumentation/control, electrical, civil/structural, engineering, commissioning and contingency. State currency, estimate year, location factor, source, exclusions and uncertainty; costs are screening estimates, not quotations. CAPEX = Σ C_equipment,i F_install,i + C_piping + C_I&C + C_civil + C_engineering + C_contingency.

**Requirement interpretation:** Screen major equipment, installation, piping, instrumentation/control, electrical, civil/structural, engineering, commissioning and contingency costs. State currency, estimate year, location factor, source, exclusions and uncertainty; clearly label as screening estimates, not quotations.

**Required evidence:** CAPEX estimate workbook/model; equipment cost basis and installation factors; cost source register; currency, estimate year and location factor; exclusions and uncertainty/range statement; commissioning and contingency allowance record.

**Expected location:** Report: CAPEX/OPEX; Repository: economics model and source register; Workbook: cost estimate and assumptions.

**Dependencies:** R-04, R-11, R-15, R-17

**Acceptance criterion:** All stated cost categories are addressed; currency, cost year, location factor, sources, exclusions and uncertainty are stated; outputs are screening estimates and not represented as quotations.

**Status:** Extracted; site/cost basis unresolved and no costs estimated

**Proposed best practice (not a separate assignment requirement):** State estimate class/maturity and estimate accuracy range using an identified methodology. The assignment asks for uncertainty but does not prescribe a cost-estimate classification.

### Topic 17. OPEX Screening (4)

**Assignment wording:** Estimate feedstock, utilities, labour, consumables/catalyst/solvent, maintenance, waste treatment, quality testing, packaging and downtime costs. Separate fixed and variable costs and justify by-product credits. OPEX_annual = C_feed + C_utilities + C_labour + C_consumables + C_maintenance + C_waste − C_byproduct.

**Requirement interpretation:** Estimate feedstock, utilities, labour, consumables/catalyst/solvent, maintenance, waste treatment, quality testing, packaging and downtime costs. Separate fixed and variable costs and justify by-product credits.

**Required evidence:** Annual OPEX workbook/model; fixed/variable classification; cost input register with source and units; by-product credit justification; annualisation basis and sensitivity linkage.

**Expected location:** Report: CAPEX/OPEX; Repository: economics module and cost inputs; Workbook: OPEX breakdown and assumptions.

**Dependencies:** R-04, R-07, R-08, R-11, R-15, R-16

**Acceptance criterion:** All listed cost categories are estimated or transparently marked not applicable; fixed/variable costs are separated; by-product credits are justified; annual basis and assumptions are explicit.

**Status:** Extracted; cost inputs and process basis unresolved

**Proposed best practice (not a separate assignment requirement):** Add working-capital, depreciation, taxes, financing and cash-flow metrics only if a later approved economic scope requires them; they are not in the assignment's stated OPEX equation.

### Topic 18. Sensitivity Analysis (4)

**Assignment wording:** Vary at least six parameters over justified ranges: throughput, feed composition, temperature, pressure, residence time, recovery/yield, utility prices, downtime, efficiency or control set points. Use one-at-a-time analysis and at least one multivariable method. Enforce quality, equipment and safety constraints.

**Requirement interpretation:** Vary at least six parameters over justified ranges. Use one-at-a-time analysis and at least one multivariable method. Enforce quality, equipment and safety constraints.

**Required evidence:** Sensitivity-variable register (minimum six) with source/justification for ranges; one-at-a-time plots/tables; one multivariable method with method description and outputs; feasibility/constraint checks for every case.

**Expected location:** Report: Sensitivity and Optimisation; Repository: sensitivity_optimisation.m and result data; Plots: sensitivity charts and multivariable results.

**Dependencies:** R-02, R-04, R-06, R-16, R-17, R-23

**Acceptance criterion:** At least six variables are varied over justified ranges; one-at-a-time analysis and at least one multivariable method are completed; quality, equipment and safety constraints are enforced and reported.

**Status:** Extracted; variables/ranges await approved design basis

**Proposed best practice (not a separate assignment requirement):** Add global sensitivity ranking and uncertainty propagation if data and schedule permit. These are proposed extensions, not a replacement for the stated OAT plus multivariable minimum.

### Topic 19. Flowchart Requirements (4)

**Assignment wording:** Submit process flowchart, numerical solver/calculation flowchart and automation state/sequence diagram. Show inputs, calculations, decision branches, convergence checks, alarms/interlocks, exception handling and outputs.

**Requirement interpretation:** Submit three flowchart types: process flowchart, numerical solver/calculation flowchart and automation state/sequence diagram. Show inputs, calculations, decision branches, convergence checks, alarms/interlocks, exception handling and outputs.

**Required evidence:** Three separately identifiable diagrams; flowchart annotations covering inputs, calculations, decisions, convergence, alarms/interlocks, exception handling and outputs as applicable.

**Expected location:** Report: Process Description, Numerical Method and Automation Philosophy; Drawings/Appendices: Process Flowchart, Solver Flowchart and Automation State/Sequence Diagram.

**Dependencies:** R-03, R-06, R-12, R-13, R-14

**Acceptance criterion:** All three requested flowchart types are present and contain the applicable decision, convergence, alarm/interlock, exception and input/output information.

**Status:** Extracted; diagrams pending route/model/control decisions

**Proposed best practice (not a separate assignment requirement):** Use consistent symbols, legends, revision IDs and traceable references to equipment tags and software functions. Exact diagramming software is not specified.

### Topic 20. MATLAB Modular Architecture (4)

**Assignment wording:** Provide input_validation.m, property_models.m, material_balance.m, energy_balance.m, entropy_exergy.m, equipment_sizing.m, utilities_model.m, control_logic.m, economics.m, sensitivity_optimisation.m, validation_checks.m, reporting_plots.m and main.m. Separate data, model, solver, GUI and reporting; document units, inputs/outputs and errors.

**Requirement interpretation:** Provide the 13 named MATLAB modules and separate data, model, solver, GUI and reporting layers. Document units, inputs/outputs and errors.

**Required evidence:** Repository tree; all 13 named module files; architecture diagram; function interfaces; unit/input/output/error documentation; separation of computational engine from GUI/reporting.

**Expected location:** Repository: MATLAB source tree; Report: Software/Model Architecture; README and module API documentation.

**Dependencies:** R-05, R-06, R-19, R-21, R-23

**Acceptance criterion:** All 13 named module files are present and implement their assigned responsibilities; layers are separated; units, inputs, outputs and error behaviour are documented.

**Status:** Extracted; no MATLAB code written in this phase

**Proposed best practice (not a separate assignment requirement):** Add START_HERE.m, project-root discovery, configuration manifests, tests entrypoint, logging and path-safe startup as required by the Universal Engineering Master Prompt. These are master-prompt execution controls, not listed in assignment Topic 20.

### Topic 21. GUI Requirements (4)

**Assignment wording:** Create a MATLAB App Designer or equivalent prototype with tabs for design basis, streams, operating conditions, equipment, balances, utilities, economics, automation, sensitivity and reports. Include unit-aware inputs, validation, plots, datasheet export and warnings for assumed data.

**Requirement interpretation:** Create a MATLAB App Designer or equivalent prototype with tabs for design basis, streams, operating conditions, equipment, balances, utilities, economics, automation, sensitivity and reports. Include unit-aware inputs, validation, plots, datasheet export and warnings for assumed data.

**Required evidence:** Runnable or honestly status-labelled GUI prototype; tab map; unit-aware inputs; input validation; plots; datasheet export demonstration; visible assumed-data warning; example input and result screenshots/files.

**Expected location:** Repository: GUI/App Designer files; Report: GUI/HMI and User Interface; Final Package: GUI prototype, example input, result tables and plots.

**Dependencies:** R-04, R-20, R-23

**Acceptance criterion:** All ten listed tabs are implemented in the MATLAB App Designer or equivalent prototype; required input, validation, plotting, export and assumed-data warning behaviours are demonstrated.

**Status:** Extracted; GUI not implemented in this phase

**Proposed best practice (not a separate assignment requirement):** Add role-specific access, session persistence and accessibility checks only if relevant to the chosen prototype; not explicit assignment requirements.

### Topic 22. Variable Dictionary and Units (4)

**Assignment wording:** Symbol/tag | Meaning | SI unit | Notes: ṁ, ṁᵢ | Mass/component flow | kg·s⁻¹ or kg·h⁻¹ | Balance results; Q̇ | Heat rate | W or kW | Energy balance; T, P | Temperature, pressure | K/°C; Pa/bar(a) | State points; ρ, μ, Cₚ | Density, viscosity, heat capacity | kg·m⁻³; Pa·s; J·kg⁻¹·K⁻¹ | Property source; A,V,D,H | Area, volume, diameter, head | m²,m³,m,m | Equipment sizing; η, φ, α, β, γ | Efficiency/model factors | Defined per model | Retain and define symbols; Ṡ, Eẋ | Entropy/exergy rates | W·K⁻¹; W | Reference environment; PV, MV, SP | Process variable, manipulated variable, setpoint | Tag-dependent | Control register.

**Requirement interpretation:** Maintain the assignment's symbol/tag dictionary, meanings, SI units and notes: mass/component flow; heat rate; temperature/pressure; density/viscosity/heat capacity; area/volume/diameter/head; efficiency/model factors; entropy/exergy rates; and PV/MV/SP.

**Required evidence:** Complete variable dictionary preserving all listed symbols, meanings, units and notes; model-specific additions clearly marked; consistent notation across equations, code, plots, GUI and report.

**Expected location:** Report: Nomenclature/Variable Dictionary; Repository: variable metadata/configuration and code documentation; GUI labels and plots.

**Dependencies:** R-05, R-06, R-07, R-08, R-09, R-10, R-13, R-20, R-21

**Acceptance criterion:** Every assignment-listed symbol group is retained and defined with the stated unit/notes; symbols used elsewhere are also defined; no unexplained symbol or inconsistent unit label remains.

**Status:** Extracted; dictionary formalisation pending

**Proposed best practice (not a separate assignment requirement):** Add a canonical machine-readable symbol/unit registry and automated dimensional checks. The assignment requires a dictionary, not a particular machine-readable schema.

### Topic 23. Verification and Validation (4-5)

**Assignment wording:** Unit and regression tests for at least three cases; keep reproducible inputs. Check mass/energy closure, dimensions, physical plausibility and solver convergence. Compare with hand calculation, textbook example, published data or vendor information where available. Test limiting cases and expected trends; quantify uncertain-input impact. Test automation logic with disturbances, failed sensors/actuators and start-up/shutdown scenarios. Maintain a verification matrix: requirement, test, expected/actual result and pass/fail.

**Requirement interpretation:** Perform unit and regression tests for at least three cases with reproducible inputs; check balance closure, dimensions, physical plausibility and solver convergence; compare with hand calculation, textbook example, published data or vendor information where available; test limiting cases/trends and uncertain-input impact; test automation logic under disturbances, failed sensors/actuators and start-up/shutdown; maintain a verification matrix with requirement, test, expected/actual result and pass/fail.

**Required evidence:** At least three reproducible test cases with input files; unit/regression test results; closure/dimensional/plausibility/convergence checks; independent benchmark comparison where available; limiting-case/trend tests; uncertainty impact; automation scenario tests; verification matrix with expected/actual/pass-fail.

**Expected location:** Report: Validation and Limitations; Repository: tests/, test inputs and test logs; Final Package: verification matrix and test cases.

**Dependencies:** R-05, R-06, R-07, R-08, R-09, R-10, R-13, R-14, R-20, R-21

**Acceptance criterion:** At least three reproducible unit/regression test cases are executed with retained inputs and expected/actual/pass-fail records. Closure, dimensions, physical plausibility, solver convergence, available benchmark comparisons, limiting trends, uncertainty impact and automation scenarios are reported. Any unexecuted test is labelled NOT RUN and cannot be counted as a passed case.

**Status:** Extracted; no tests run in this phase

**Proposed best practice (not a separate assignment requirement):** Add CI automation, coverage metrics, seeded stochastic tests and release tagging if supported by the selected environment. These are enhancements, not explicit assignment minimums.

### Topic 24. Python/Open-Source Migration Requirements (5)

**Assignment wording:** Keep model code independent of the GUI. Map MATLAB modules to Python using NumPy, SciPy, pandas and Matplotlib; consider CoolProp, Cantera, BioSTEAM or DWSIM where suitable and accessible. State licence/data limitations and preserve units, tests and outputs.

**Requirement interpretation:** Keep model code independent of the GUI. Map MATLAB modules to Python using NumPy, SciPy, pandas and Matplotlib; consider CoolProp, Cantera, BioSTEAM or DWSIM where suitable and accessible. State licence/data limitations and preserve units, tests and outputs.

**Required evidence:** MATLAB-to-Python module mapping; Python implementation or migration note as scoped by the project; dependency/licence/data limitation register; unit and test parity records; comparison of outputs and units.

**Expected location:** Report: Python/Open-Source Migration; Repository: python/ and migration notes; Final Package: Python migration note.

**Dependencies:** R-20, R-21, R-22, R-23

**Acceptance criterion:** Core model remains GUI-independent; named Python ecosystem mapping is addressed; suitable tools are evaluated without assuming availability; licensing/data limits are recorded; units, tests and outputs are preserved or gaps are stated.

**Status:** Extracted; migration not started

**Proposed best practice (not a separate assignment requirement):** Pin package versions and produce environment/lock files plus a module-by-module parity checklist. The assignment does not prescribe a dependency-lock format.

### Topic 25. Technical Report Structure (5)

**Assignment wording:** Executive summary and design basis. Literature/standards review and data provenance. Process description, PFD and stream table. Equations, assumptions and numerical method. Equipment design calculations and datasheets. Material/energy/entropy/exergy balances. Automation philosophy, loop register, sequence and alarm matrix. Utilities, environmental considerations and safety screening. CAPEX/OPEX, sensitivity and optimisation. Validation, limitations and recommendations.

**Requirement interpretation:** The technical report must cover the ten listed sections: executive summary/design basis; literature/standards and provenance; process description/PFD/stream table; equations/assumptions/numerical method; equipment calculations/datasheets; material/energy/entropy/exergy balances; automation/loop/sequence/alarm matrix; utilities/environment/safety; CAPEX/OPEX/sensitivity/optimisation; validation/limitations/recommendations.

**Required evidence:** Final report table of contents mapped to all ten required content groups; completed sections with cross-referenced figures, tables, datasheets and evidence; references and data provenance.

**Expected location:** Editable Word report and PDF; final report body and appendices.

**Dependencies:** R-01 through R-24

**Acceptance criterion:** All ten listed content groups appear in the report and are supported by completed calculations, drawings, registers or explicit limitations as applicable.

**Status:** Structure extracted; report not drafted

**Proposed best practice (not a separate assignment requirement):** Use a revision-controlled design-report structure with document control, abbreviations, appendices and cross-reference numbering. These are presentation controls, not extra technical requirements.

### Topic 26. Final Submission Package (5)

**Assignment wording:** Editable Word/PDF report with referenced data and calculation trail. MATLAB source, input data, README and reproducible run instructions. GUI prototype, example input, result tables and plots. PFD, P&ID-level sketch, equipment datasheets, loop register, alarm/interlock matrix and sequence diagram. Balance tables, utility summary, cost model and sensitivity results. Verification matrix, test cases, limitations statement and Python migration note. Short presentation summarising key results and recommendations.

**Requirement interpretation:** Submit an editable Word/PDF report with referenced data and calculation trail; MATLAB source, input data, README and reproducible run instructions; GUI prototype, example input, result tables and plots; PFD, P&ID-level sketch, equipment datasheets, loop register, alarm/interlock matrix and sequence diagram; balance tables, utility summary, cost model and sensitivity results; verification matrix, test cases, limitations statement and Python migration note; and a short presentation.

**Required evidence:** Submission manifest listing every required item, file path, format, revision and completion status; actual report, source, data, README, GUI, drawings, datasheets, registers, balance/cost/sensitivity outputs, verification evidence, limitations/migration note and presentation.

**Expected location:** Final project root and submission package; report, source tree, inputs, GUI, drawings, registers, outputs, tests and presentation folders.

**Dependencies:** R-20, R-21, R-23, R-24, R-25, plus all upstream engineering topics

**Acceptance criterion:** Every listed package item exists in its required editable or usable form, is traceable to the report and appears in the submission manifest; missing/incomplete items are explicitly disclosed.

**Status:** Package requirements extracted; package not assembled

**Proposed best practice (not a separate assignment requirement):** Add a ZIP manifest, checksums and clean-extraction/reproduction test. ZIP is a project/master-prompt handoff expectation, not named in assignment Topic 26 itself.

### Topic 27. Acceptance Checklist (5)

**Assignment wording:** Process boundary, design basis and assumptions are explicit. Equations are editable Word Equation objects and symbols are defined. Material, energy, entropy and exergy balances and closure are reported. Detailed equipment sizing, calculation trail and datasheets are complete. Sensors, actuators, control loops, HMI, alarms, interlocks and failure responses are documented. Utilities, waste and screening CAPEX/OPEX are quantified. At least six sensitivity variables and multiple scenarios are analysed. MATLAB architecture, GUI, validation and Python migration are addressed. No unsupported claim of regulatory compliance, vendor endorsement or certified safety design is made.

**Requirement interpretation:** The final project must pass all nine assignment acceptance items: explicit boundary/design basis/assumptions; editable Word Equation objects and defined symbols; reported material/energy/entropy/exergy balances and closure; detailed equipment sizing/calculation trail/datasheets; complete control instrumentation/HMI/alarm/interlock/failure documentation; quantified utilities/waste/CAPEX/OPEX; at least six sensitivity variables and multiple scenarios; MATLAB architecture/GUI/validation/Python migration; and no unsupported compliance/vendor/safety certification claim.

**Required evidence:** Nine-item final compliance checklist with evidence reference, review result and closure status; each item linked to detailed requirements and final package files.

**Expected location:** Final Compliance Matrix; Report: Validation, Limitations and Recommendations; Submission Manifest.

**Dependencies:** R-01 through R-26

**Acceptance criterion:** All nine checklist statements are individually checked against objective evidence; no checklist item is marked PASS without an evidence reference; unsupported compliance/vendor/certification claims are absent.

**Status:** Acceptance criteria extracted; final evidence pending

**Proposed best practice (not a separate assignment requirement):** Require independent reviewer sign-off and a change-control record for all PASS/FAIL decisions. These are good governance practices, not extra wording in the assignment checklist.

## 5. Topic 27 acceptance checklist, mapped to evidence

| ID | Assignment wording | Required objective evidence | Expected location | Linked requirements | Pass criterion |
|---|---|---|---|---|---|
| AC-01 | Process boundary, design basis and assumptions are explicit. | Boundary drawing/narrative; approved design-basis sheet; assumptions register; open issues closed or approved as assumptions. | Report: Design Basis; process boundary/PFD; input and assumptions registers. | R-03, R-04 | Boundary includes all specified interfaces; every design-basis input has a value/source or approved open assumption. |
| AC-02 | Equations are editable Word Equation objects and symbols are defined. | Editable Word Equation objects; nomenclature/variable dictionary; equation register and symbol-use check. | Editable DOCX report; Nomenclature; equation appendices. | R-05, R-22, R-25 | Equations remain editable Word Equation objects and every used symbol is defined. |
| AC-03 | Material, energy, entropy and exergy balances and closure are reported. | Overall/component stream balances; energy balance; entropy balance; exergy balance; closure and residual tables. | Report: Balance Chapters; stream and balance tables; calculation appendices. | R-05 through R-10 | All four balance areas are reported; mass/energy closure and entropy/exergy accounting are traceable. |
| AC-04 | Detailed equipment sizing, calculation trail and datasheets are complete. | Equipment selection list; detailed design calculations; datasheet for every major item; normal/upset checks; uncertainty. | Report: Equipment Design; datasheets/; source sizing outputs. | R-11 | Each major item has a completed datasheet and calculation trail with all assignment-listed fields. |
| AC-05 | Sensors, actuators, control loops, HMI, alarms, interlocks and failure responses are documented. | I/O list; loop register; HMI evidence; state sequence; alarm register; cause-and-effect/interlock matrix; failure response records. | Report: Automation; GUI/HMI; registers/; P&ID-level sketch; test evidence. | R-12, R-13, R-14, R-21, R-23 | All listed automation components are documented with required fields, actions and safe-state responses. |
| AC-06 | Utilities, waste and screening CAPEX/OPEX are quantified. | Utility balance and service list; waste/off-gas/emissions register; CAPEX and OPEX screening models with sources/assumptions. | Report: Utilities/Environment; CAPEX/OPEX; calculation workbooks and source register. | R-04, R-15, R-16, R-17 | Applicable utility and waste streams and both cost screenings are quantified; assumptions and cost basis stated. |
| AC-07 | At least six sensitivity variables and multiple scenarios are analysed. | Six-or-more variable register; OAT runs; multivariable analysis; base case plus at least two alternatives; feasibility screening. | Report: Scenarios; Sensitivity/Optimisation; plots/ and case files. | R-02, R-18 | At least six sensitivity variables, multiple scenarios and one multivariable method are supported by results and constraint checks. |
| AC-08 | MATLAB architecture, GUI, validation and Python migration are addressed. | Thirteen MATLAB modules; GUI prototype; reproducible test suite for at least three cases; migration mapping/note; test logs. | MATLAB source; GUI; tests/; Python migration note; README. | R-20, R-21, R-23, R-24 | The named architecture, GUI, verification minimum and migration requirements are evidenced; unrun tests are not reported as passed. |
| AC-09 | No unsupported claim of regulatory compliance, vendor endorsement or certified safety design is made. | Final claims review; citations for regulatory/vendor statements; explicit preliminary academic-design limitation; no unsupported SIL/certification statement. | Report: Limitations/Conclusions; final audit/compliance review. | R-03, R-11, R-14, R-15, R-16, R-25 | No unsubstantiated compliance, vendor endorsement, certified safety design or SIL claim appears. |

## 6. Governing equations and source notation

The following equations are copied from Topic 5, Topic 7, Topic 8 and Topics 16–17 for traceability. This phase does not substitute values, solve them or select models.

### Topic 5: minimum balance/design equations

- Overall mass balance: `ṁ_in = ṁ_product + ṁ_recycle + ṁ_waste + dM/dt`; the assignment additionally requires component balances for key species.
- Sensible heat duty: `Q̇ = ṁ Cp (T_out − T_in)`.
- Preliminary exchanger area relation: `Q̇ = U A ΔT_lm`.
- Pump shaft power: `P_shaft = ρ g Q̇_v H / η_p`; include motor efficiency and service factor.
- Entropy generation: `Ṡ_gen = ΣṠ_out − ΣṠ_in − Σ(Q̇_p/T_p) ≥ 0`, using a declared sign convention.
- Exergy destruction/balance: `Ė_D = T₀ Ṡ_gen`; `Ex_in + Ex_fuel = Ex_product + Ex_waste + Ė_D`.
- Preliminary heat-transfer area and working volume: `A = Q̇/(U ΔT_lm)`; `V_working = Q̇_v τ`.

### Topic 7: mass closure

`ε_p = 100(Σṁ_in − Σṁ_out − dM/dt) / max(Σṁ_in, ε)`

### Topic 8: control-volume energy balance

`ΣĤ_in + Q̇ − Ẇ = ΣĤ_out + dE_cv/dt`

### Topics 16–17: screening cost equations

- `CAPEX = Σ C_equipment,i F_install,i + C_piping + C_I&C + C_civil + C_engineering + C_contingency`
- `OPEX_annual = C_feed + C_utilities + C_labour + C_consumables + C_maintenance + C_waste − C_byproduct`

**Notation note:** The assignment's mass-closure equation uses `ε` in the denominator guard `max(Σṁ_in, ε)` but Topic 22 does not separately define this guard parameter. Its numerical meaning and value must be clarified in the later equation/solver basis; no value is assigned here.

## 7. Source tables and diagram content captured

### Topic 13 example loop table (PDF page 3)

| Example loop | PV / sensor | MV / actuator | Objective | Alarm/interlock | Failure response |
|---|---|---|---|---|---|
| FIC-101 | Flow transmitter | Valve/VFD pump | Maintain throughput/ratio | Low-low flow | Hold/close feed safely |
| TIC-101 | RTD/thermocouple | Heating/cooling valve | Control temperature | High-high T/loss cooling | Cut heat; safe response |
| PIC-101 | Pressure transmitter | Back-pressure valve/compressor | Control pressure | High-high P | Isolate/relieve per design |
| LIC-101 | Level transmitter | Outlet valve/pump | Control inventory/interface | High-high/low-low level | Prevent carryover/overflow/dry-run |
| ESD/SIS | Independent sensors as required | Safety-rated final element | Reach defined safe state | Cause-and-effect matrix | Trip/isolate/purge as engineered |

These are assignment examples, not a mandate to use every exact tag or actuator in the final route. The later control design must retain the loop-register fields and adapt process-specific measurements to the selected route.

### Topic 22 variable dictionary (PDF page 4)

| Symbol/tag | Meaning | SI unit | Notes |
|---|---|---|---|
| ṁ, ṁᵢ | Mass/component flow | kg·s⁻¹ or kg·h⁻¹ | Balance results |
| Q̇ | Heat rate | W or kW | Energy balance |
| T, P | Temperature, pressure | K/°C; Pa/bar(a) | State points |
| ρ, μ, Cₚ | Density, viscosity, heat capacity | kg·m⁻³; Pa·s; J·kg⁻¹·K⁻¹ | Property source |
| A, V, D, H | Area, volume, diameter, head | m², m³, m, m | Equipment sizing |
| η, φ, α, β, γ | Efficiency/model factors | Defined per model | Retain and define symbols |
| Ṡ, Eẋ | Entropy/exergy rates | W·K⁻¹; W | Reference environment |
| PV, MV, SP | Process variable, manipulated variable, setpoint | Tag-dependent | Control register |

## 8. Unspecified information and open decisions

No process route, capacity, feed source/composition, product grade, site location, operating-hours basis, equipment design envelope, utility supply/tariffs, emissions boundary, cost year or environmental reference basis is prescribed. The full register is supplied as `ENERGY008_Open_Decisions.csv` and repeated in the workbook's Open Decisions sheet. It contains 24 unresolved decision/input items and one fixed academic-design constraint that must be carried forward.

| Decision ID | Open input | Classification | Required resolution point |
|---|---|---|---|
| D-01 | Production route / process topology | Blocking before design-basis freeze; route choice is a user approval gate | After Gate 1 requirements approval; before Gate 3 design-basis freeze |
| D-02 | Production capacity / design throughput | Must resolve or approve explicitly before design-basis freeze | Before Gate 3; before material/equipment sizing calculations |
| D-03 | Feed source(s), including carbon and hydrogen supply | Candidate supply options needed for route selection; selected supply basis required before design-basis freeze | Before route approval and Gate 3 |
| D-04 | Feed composition and feed physical properties | Must resolve or approve explicit assumptions before material/property calculations | After D-01/D-03 route/source selection; before Gate 3 freeze and R-05-R-11 calculations |
| D-05 | Product grade and product specification | Must resolve before design-basis freeze and product/separation calculations | Before Gate 3; before R-07, R-11, R-18 |
| D-06 | Plant location / site context | Must resolve for site-specific claims/costs; may be bounded for generic screening | Before site utility/regulatory/cost analysis; before Gate 3 if location-specific basis is required |
| D-07 | Operating hours, annual uptime and downtime | Can be an explicit assumption after approval; required before annualisation | Before annual utility/OPEX and annual production calculations; Gate 3 freeze |
| D-08 | Operating and design envelope | Must be defined before calculation/design-basis freeze | After D-01; before Gate 3 and R-05-R-11 |
| D-09 | Equipment design criteria and materials basis | Must be established before equipment sizing; some details can be explicit engineering assumptions | Before R-11 calculations and Gate 4/5 design development |
| D-10 | Utility types, battery-limit conditions and availability | Must resolve or approve before utility integration/sizing | Before R-08, R-11, R-15 and OPEX |
| D-11 | Site utility tariffs and feed/consumable prices | Required before cost outputs; can remain an explicitly sourced screening assumption | Before R-16/R-17 and economic sensitivity |
| D-12 | Waste-treatment tariffs and disposal costs | Required before waste OPEX; can remain sourced screening assumption | After route/waste stream definition; before R-15/R-17 |
| D-13 | Emissions boundary and green-methanol accounting boundary | Must be defined before environmental KPI or green-status claims | Before R-15, environmental comparison, recommendation and report conclusions |
| D-14 | Environmental reference basis and emission factors | Must be selected before environmental impact calculation | Before R-15 environmental quantification and R-02 alternative comparisons |
| D-15 | CAPEX/OPEX currency, cost year and estimate basis | Must be declared before cost estimate is issued | Before R-16/R-17; Gate 3 or economics sub-gate |
| D-16 | Exergy dead state and reference environment | Must be declared before exergy calculation; may remain explicit assumption | Before R-10 calculation and final exergy comparison |
| D-17 | Reaction kinetics, thermodynamic/property and separation model data | Must be selected after route approval and before predictive calculations | Before R-05/R-06 implementation and design calculations |
| D-18 | Catalyst/solvent/consumables basis | After route selection; before R-07/R-11/R-14/R-17 | Before material/equipment/economic calculations for applicable items |
| D-19 | Disturbance, upset and safe-state scenarios | Must be defined before control sequence and upset calculations | Before R-06 upset sizing, R-13/R-14 control, R-23 tests |
| D-20 | Definition of the two alternative cases and comparison criteria | Must be approved before scenario comparison; route alternatives before route selection gate | Before Gate 2 route decision and R-02/R-18 execution |
| D-21 | KPI definitions and operating-window criteria | Must be agreed before optimisation and recommendation | Before R-02 recommendation and R-18 sensitivity/optimisation |
| D-22 | Indian regulatory and standards applicability | Must be assessed after site/route definition; before claims in final report | Before R-15 and final compliance statements |
| D-23 | Vendor data and equipment availability | Can be carried as an explicit data gap for academic screening | Before final sizing/cost estimates and R-23 benchmarks |
| D-24 | Software/tool availability and licensing | Can remain open until software architecture gate; must be resolved before claiming runnable deliverables | Before R-20/R-21/R-23/R-24 implementation and tests |
| D-25 | Boundary between academic screening and certified engineering | Fixed constraint, not an open technical choice | All phases; final claims review before submission |

### Decisions that must be made or approved before calculations

- Production route and process topology, including the candidate carbon and hydrogen feed-supply basis.
- Capacity/design throughput, feed composition and product specification, either supplied by the user or explicitly approved as an illustrative academic basis.
- Process boundary and emissions/environmental reference basis before environmental KPI or green-status claims.
- Operating/design envelope and property/kinetic/separation models before predictive calculations.
- Equipment criteria, utility supply conditions and the exergy reference environment before their respective design/balance calculations.
- The alternative-case definition and KPI/comparison criteria before the operating-window recommendation.

### Inputs that may remain explicit assumptions, if approved

- Operating hours, annual uptime and downtime for an illustrative annualisation basis.
- Generic Indian site context when no plant location is supplied, with all site-specific claims and tariffs left unresolved.
- Utility battery-limit conditions and tariffs used only as sourced, dated screening proxies.
- Equipment margins, preliminary materials assumptions and vendor-dependent details, provided their basis, uncertainty and code-verification limits are visible.
- CAPEX currency/year convention and exergy dead-state reference state, provided they are explicitly declared, sourced/justified and approved before calculation.
- A process-relevant disturbance magnitude/duration, provided it is explicitly framed as an academic scenario and not an actual plant operating instruction.

## 9. Staged execution and approval logic

The detailed stage-gate register is in `ENERGY008_Phase_Gates.md`. The critical hold points are:

1. **Gate 1: requirements approval.** User reviews this baseline, the 27-topic matrix, acceptance checklist and open decisions.
2. **Gate 2: production-route approval.** Only after Gate 1 approval, a separate phase compares route candidates and alternatives. The user selects/approves the route.
3. **Gate 3: design-basis freeze.** Only after route approval, calculation-critical inputs are sourced or explicitly approved as assumptions and the user approves the frozen design basis.

No route selection, design-basis freeze, material/energy/entropy/exergy calculation, equipment sizing, MATLAB implementation, full literature review or final report has been undertaken in this phase.

## 10. File handoff to Prompt 2

- `ENERGY008_Requirements_Traceability.xlsx`: controlled matrix, acceptance checklist, minimums/package list, open decisions and gates.
- `ENERGY008_Assignment_Extraction.md`: source-ordered extraction and equations/tables.
- `ENERGY008_Open_Decisions.csv`: editable issue/dependency register.
- `ENERGY008_Phase_Gates.md`: stage-gate sequence and approval controls.

**Handoff status:** Await user review and approval of the requirements baseline. Prompt 2 must receive the approved baseline and must not freeze the design basis until the user approves the production route.

## 11. Source completeness check

| Source area | Captured |
|---|---|
| PDF page 1: title, purpose, core problem, scope, inputs, equations and numerical algorithm | Yes |
| PDF page 2: material/energy/entropy/exergy and equipment scope | Yes |
| PDF page 3: equipment details, PFD/P&ID, loop example table, HMI/sequence/alarm, utilities/environment/waste | Yes |
| PDF page 4: CAPEX/OPEX, sensitivity, flowcharts, MATLAB modules, GUI tabs and variable dictionary | Yes |
| PDF page 5: verification, Python migration, report structure, final package and acceptance checklist | Yes |
| Universal Engineering Master Prompt: staged prompt workflow, source integrity, evidence, MATLAB architecture, verification, report and packaging guidance | Yes |

**Visual inspection note:** PDF page 3 was checked for the example loop table and section 14/15 content; page 4 was checked for the variable dictionary and MATLAB/GUI content; page 5 was checked for the remaining verification bullets, Python migration, report/package structure and acceptance checklist. Pages 1 and 2 were reviewed from their extracted page text and equations.