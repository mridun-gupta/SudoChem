# ENERGY-008 — Problem-Specific Engineering Prompt Sequence

**Project:** Green methanol synthesis — Utility integration and energy KPIs  
**Assignment ID:** ENERGY-008  
**Sector:** Energy and Renewable Industrial Systems  
**Context:** Indian manufacturing / process-industry design  
**Primary implementation platform:** MATLAB  
**Future migration:** Python and open-source scientific-computing ecosystem  
**Prompt sequence:** 25 manually executed phases

---

## 1. Problem Brief

The uploaded assignment asks for a modular, reproducible preliminary engineering model for green methanol synthesis that connects process definition, product quality, throughput, equipment sizing, utilities, economics, environmental/waste performance, and industrial automation. It requires comparison of a base case with at least two alternatives and a recommended operating window. The process boundary must extend from feed receipt and conditioning through product, recycle, waste, and utilities. Steady-state, start-up/shutdown, turndown, and at least one disturbance case must be addressed.

The assignment does **not** prescribe a green-methanol production route, plant capacity, feed source, feed composition, product specification, site, utility tariffs, or operating/design conditions. The prompt sequence therefore requires the execution AI to screen and justify the process route before freezing a design basis. Candidate routes may include CO₂ hydrogenation using renewable electrolytic hydrogen (e-methanol) and biomass/biogenic syngas routes, but no route is to be assumed without comparison and evidence.

The required work includes project-specific governing equations; total/component mass balances; sensible, latent and reaction heat; heat-exchanger duties and areas; pump power; entropy and exergy balances; detailed equipment selection and datasheets; PFD and P&ID-level definition; PLC/DCS/SCADA control philosophy; HMI, operating sequence, alarms/interlocks and failure responses; utilities, emissions, waste and current Indian regulatory/standards checks; CAPEX/OPEX; at least six sensitivity variables and one multivariable method; process, solver and automation flowcharts; modular MATLAB code; a MATLAB GUI; verification against at least three cases; Python migration; a detailed report; and a final auditable ZIP package.

### Known constraints and unresolved inputs

- The assignment is a **preliminary academic design exercise**, not a certified plant design.
- Use traceable sources and explicitly label all assumed or illustrative data.
- Main system, process route, feed, capacity, location, product grade, utility conditions and economics must be established in early phases.
- The project is in an Indian manufacturing/process-industry context; use current, applicable Indian standards and regulatory sources only after verifying applicability and edition.
- MATLAB is the required primary platform. The future Python path should consider NumPy, SciPy, pandas and Matplotlib, and assess CoolProp, Cantera, BioSTEAM or DWSIM only where technically suitable and licence/access conditions permit.
- Prior CPS-22 NRTL–SRK work is a separate project and must not supply methanol process values, model parameters or results. The earlier CPS-01 report is a **format reference only**: use its professional cover, document control, executive summary, table of contents, nomenclature, section hierarchy, appendices, page navigation and sign-off style if that reference file is available. Do not copy its hydrocarbon calculations or technical content.
- The user's previous report preference was for substantial, meaningful engineering depth (around 150 pages or more where genuinely justified). Do not pad the report; page count must arise from calculations, datasheets, drawings, control documents, source evidence, test records and interpretation.

## 2. Prompt Roadmap

| Prompt | Purpose | Depends on |
|---|---|---|
| 1 | Assignment, source and requirements audit | Uploaded assignment and this prompt sequence |
| 2 | Green-methanol route and technology selection | Prompt 1 |
| 3 | Process boundary, design basis and scenarios | Prompts 1–2 |
| 4 | Literature, database, standards and Indian-context research | Prompts 1–3 |
| 5 | Property/data extraction, validation and provenance | Prompt 4 |
| 6 | Reaction, thermodynamic, kinetic and process-model selection | Prompts 2–5 |
| 7 | Process description, PFD and stream architecture | Prompts 2–6 |
| 8 | Steady-state material balances and recycle/purge convergence | Prompts 3–7 |
| 9 | Energy balance, thermal duties and heat integration | Prompts 5–8 |
| 10 | Entropy and exergy balances | Prompts 6–9 |
| 11 | Equipment selection, detailed sizing and datasheets | Prompts 7–10 |
| 12 | Utilities, water, emissions, environment and waste | Prompts 8–11 |
| 13 | Process safety, safeguards and materials screening | Prompts 2–12 |
| 14 | PLC/DCS/SCADA control philosophy, loop register and HMI | Prompts 7, 11–13 |
| 15 | Start-up/shutdown, operating modes, sequences and disturbances | Prompts 13–14 |
| 16 | Numerical workflow, solver strategy and three flowcharts | Prompts 6–10, 14–15 |
| 17 | Independent manual calculations and benchmark case | Prompts 3–12, 16 |
| 18 | MATLAB project architecture, robust startup and file discovery | Prompts 1–17 |
| 19 | MATLAB implementation of engineering modules | Prompts 5–18 |
| 20 | MATLAB GUI, plots, datasheets and exports | Prompts 14–19 |
| 21 | Verification, validation, regression and defect correction | Prompts 4–20 |
| 22 | Sensitivity, uncertainty, alternatives and optimisation | Prompts 3–21 |
| 23 | Python/open-source migration and parity checks | Prompts 18–22 |
| 24 | Final technical report and presentation | Prompts 1–23 and the CPS-01 format reference |
| 25 | Repository integration, final audit and ZIP handoff | Prompts 1–24 |

---

# 3. Copy-ready prompts

## PROMPT 1 — ENERGY-008 Assignment Audit and Requirements Traceability

**Objective**  
Convert the uploaded ENERGY-008 assignment into a complete, auditable requirements baseline. Do not begin process design or calculations in this phase.

**Context and inputs**  
Use `PSLassignment2.pdf` as the governing assignment. Also read `Universal_Engineering_Master_Prompt(1).txt`. Use the conversation context only for the user's preference for staged execution and the CPS-01 report's visual/structural format. Do not carry over CPS-22 or CPS-01 engineering data.

**Instructions**
1. Read every page of `PSLassignment2.pdf`, including all text, equations, example loop table, variable dictionary, report requirements, final submission package and acceptance checklist.
2. Extract and preserve the assignment's 27 numbered topics and exact meaning. Build a requirements traceability matrix with ID, original requirement, required evidence, expected file/report location, dependency, acceptance criterion, and status.
3. Identify mandatory minimums explicitly: base case plus at least two alternatives; steady state plus start-up/shutdown/turndown and at least one disturbance; all major feed/product/recycle/purge/waste streams; energy, entropy and exergy; detailed equipment datasheets; PFD and P&ID-level sketch; control loop register; HMI and sequencing; alarm/interlock matrix; at least six sensitivity variables and one multivariable method; three required flowchart types; MATLAB modules and GUI; at least three verification/regression cases; Python migration; and final editable report/PDF, source, GUI, input files, plots, drawings, datasheets, registers, presentation and ZIP.
4. Separate assignment-stated requirements from proposed engineering best practices. Include an “assignment wording” column so no additional practice silently becomes a formal assignment requirement.
5. Identify unspecified information: production capacity, process route, feed source/composition, product grade, location, operating hours, equipment design basis, utilities, emissions boundary, site tariffs, cost year and environmental reference basis.
6. Prepare an issue/dependency register. Flag decisions that must be made before calculations and decisions that can remain explicit assumptions.
7. Establish the stage-gate sequence and approval points. The user should approve requirements and route selection before the design basis is frozen.

**Constraints and prohibitions**
- Do not invent a plant, capacity, route, feed, product specification or site tariff.
- Do not solve balances, select arbitrary values, conduct the full literature review, write MATLAB code or prepare the final report yet.
- Do not omit any of the assignment's 27 topics.

**Expected deliverables**
- `01_Requirements/ENERGY008_Requirements_Traceability.xlsx`
- `01_Requirements/ENERGY008_Assignment_Extraction.md`
- `01_Requirements/ENERGY008_Open_Decisions.csv`
- `01_Requirements/ENERGY008_Phase_Gates.md`

**Acceptance criteria**
Every numbered assignment topic and final acceptance item is mapped to objective evidence. Every unresolved input is listed, with a proposed method of resolution and downstream dependencies.

**Handoff**
Pass the complete matrix and open-decision register to Prompt 2. Stop for user review before selecting the production route.

---

## PROMPT 2 — Green Methanol Production Route and Technology Selection

**Objective**  
Select and justify the process route for ENERGY-008 before choosing a plant capacity or calculating equipment. The assignment calls the product “green methanol” but does not state the synthesis route.

**Context and inputs**  
Use the approved requirements matrix from Prompt 1. Candidate routes may include (a) CO₂ hydrogenation with renewable electrolytic hydrogen, (b) biomass/biogenic feed gasification and syngas conditioning followed by methanol synthesis, and (c) a suitably evidenced hybrid/biogenic-CO₂ plus renewable-H₂ route. Treat these as candidates, not predetermined choices.

**Instructions**
1. Define what makes methanol “green” for each route: renewable hydrogen/electricity, biogenic or captured carbon source, carbon accounting boundary, and applicable certification or chain-of-custody assumptions.
2. Research route maturity, chemistry, feed requirements, product quality, conversion/selectivity, recycle needs, operating pressure/temperature ranges, catalyst requirements, heat release, water and electricity requirements, by-products, waste and emissions.
3. Compare routes for an Indian manufacturing/process-industry context. Evaluate likely feedstock availability, renewable-electricity profile, water constraints, CO₂/biogenic carbon source, infrastructure, site integration, scale suitability, technology readiness, safety complexity and cost-data availability.
4. Consider green-H₂ production options (e.g., alkaline, PEM or other justified electrolysis) as part of the route where required. Compare energy demand, operating flexibility, water use, oxygen by-product, pressure, purity and vendor-data availability.
5. Make a weighted decision matrix with transparent weights, scoring definitions, evidence strength and uncertainty. Run a weight-sensitivity check so the selected route is not an artefact of arbitrary weighting.
6. Choose one base route and at least two meaningful alternatives for subsequent comparison. Alternatives may be different process routes or materially different process configurations, hydrogen/electricity strategies, heat-integration options or operating cases. Explain why each is genuinely comparable.
7. Define which route-specific unit operations are included: feed preparation, CO₂ capture/purification or biomass preparation/gasification, hydrogen production/conditioning, compression, synthesis reactor, cooling/condensation, gas-liquid separation, recycle/purge, crude methanol purification, storage, water treatment, off-gas and utility systems as applicable.
8. State why the selected process is a reasonable academic design basis, not a certified plant recommendation.

**Constraints and prohibitions**
- Do not assume CO₂ hydrogenation is the route simply because it is common for e-methanol.
- Do not combine incompatible route assumptions into a fictional flowsheet.
- Do not call fossil-derived hydrogen or fossil carbon “green” without a defensible emissions accounting basis.
- Do not invent commercial performance or cost data. Distinguish vendor claims, demonstration results and peer-reviewed data.

**Expected deliverables**
- `02_Route_Selection/ENERGY008_Route_Comparison.xlsx`
- `02_Route_Selection/ENERGY008_Route_Decision_Report.md`
- `02_Route_Selection/ENERGY008_Base_and_Alternative_Cases.csv`
- A route-selection gate decision for user approval.

**Acceptance criteria**
The selected route is supported by traceable evidence and a transparent comparison. Base plus two alternatives are defined sufficiently for a common comparison framework.

**Handoff**
Pass the selected route, alternative definitions, route boundary and unresolved route risks to Prompt 3. Obtain user approval before freezing the design basis.

---

## PROMPT 3 — Process Boundary, Design Basis and Operating Scenarios

**Objective**  
Create the controlled engineering design basis for the selected green-methanol route, with every value identified as sourced, calculated, estimated or assumed.

**Context and inputs**  
Use the approved route decision from Prompt 2 and the requirements matrix from Prompt 1. The assignment gives no numerical plant capacity or site-specific operating conditions.

**Instructions**
1. Define battery limits from feed receipt/conditioning to methanol product dispatch, including hydrogen/carbon feed supply, recycle, purge, off-gas, wastewater, solid waste, oxygen by-product where relevant, utilities and emissions.
2. Select an illustrative academic design throughput only after researching comparable projects and documenting the rationale. Include operating hours/year, capacity factor, availability, design margin and turndown. Do not imply it is a real Indian plant.
3. Specify feed source, composition, contaminants, moisture, pressure, temperature, flow and required conditioning. Define product grade, purity, water/impurity limits and test basis using an authoritative specification or clearly stated academic target.
4. Set normal, minimum, maximum, design, turndown, start-up, shutdown and upset conditions. Include at least one quantified disturbance case, such as renewable-power drop, CO₂ feed interruption, cooling-water loss or product/off-gas composition excursion. Choose only disturbances relevant to the selected route.
5. Define overall carbon boundary and renewable-energy boundary. Record whether upstream CO₂ capture, renewable electricity, hydrogen production, water treatment and product transport are included in KPIs.
6. Create a scenario matrix: base case, Alternative 1 and Alternative 2, each with comparable product capacity/quality, boundary and reporting basis. State exactly what differs.
7. Create an assumption register with value, units, source or rationale, uncertainty/range, sensitivity priority and approval status.
8. Define a project unit convention: SI internally; clear presentation units for kg/h, t/day, t/y, kmol/h, MPa/bar(a), °C/K, kW/MW, kWh/t methanol, GJ/t and INR or USD with reference year.
9. Define target KPIs and draft equations: methanol production rate, purity, carbon conversion/utilisation, methanol yield/selectivity, H₂ consumption, specific electricity and heat, total specific energy, renewable-energy share, water consumption, CO₂e intensity, availability, capacity factor, exergy efficiency and levelised methanol cost where data allow.

**Constraints and prohibitions**
- Never present assumed capacity, operating conditions, purity or tariffs as industrial facts.
- Do not choose KPI boundaries after seeing results to make performance look favourable.
- Keep base and alternative cases comparable.

**Expected deliverables**
- `03_Design_Basis/ENERGY008_Design_Basis.xlsx`
- `03_Design_Basis/ENERGY008_Assumptions_Register.csv`
- `03_Design_Basis/ENERGY008_Operating_Envelope.csv`
- `03_Design_Basis/ENERGY008_Scenario_Definitions.xlsx`
- `03_Design_Basis/ENERGY008_KPI_Definitions.xlsx`

**Acceptance criteria**
Every numerical input has a source or explicit assumption tag, unit, validity/range and uncertainty. The process boundary and alternatives are unambiguous.

**Handoff**
Freeze a versioned design basis after user approval. Pass it unchanged to Prompts 4–25 unless a documented change is approved.

---

## PROMPT 4 — Literature, Databases, Standards and Indian-Context Research

**Objective**  
Build a high-quality, traceable source base for green methanol synthesis, renewable hydrogen, process equipment, energy integration, controls, environmental performance and India-specific compliance screening.

**Context and inputs**  
Use the selected route and approved design basis. Research must cover the actual selected route and alternatives, not generic methanol content alone.

**Instructions**
1. Prioritise peer-reviewed experimental papers, review papers, industrial demonstration/project publications, official standards, government sources, technical databases and manufacturer documentation with clearly marked source type.
2. Research reaction equilibrium and kinetics, catalyst composition/performance/deactivation, reactor type, operating conditions, gas purification, recycle, product separation/distillation, heat recovery, electrolyser performance (if applicable), CO₂ capture and compression, water use, oxygen handling and emissions.
3. Retrieve primary thermophysical/thermochemical data for all relevant components and mixtures from authoritative sources such as NIST Chemistry WebBook, NIST thermochemical data, NIST REFPROP if licensed, CoolProp documentation/data where appropriate, DIPPR if licensed, JANAF, IAPWS and peer-reviewed property papers. Check actual access and licence constraints.
4. Research current green-methanol/renewable-hydrogen guidance and carbon-intensity accounting methods. Define whether the project uses a well-to-gate, cradle-to-gate or plant-gate boundary.
5. Identify Indian context sources for renewable electricity, green hydrogen, methanol/product requirements, boiler/pressure equipment, hazardous storage, gas systems, environmental consents, water discharge, air emissions and workplace safety. Check the current applicable legal instrument, issuing authority, edition, applicability and effective status. Examples to investigate include MNRE, BEE, CEA, CPCB, MoEFCC, BIS, PESO and relevant state authorities; do not assume every regulator applies.
6. Research process equipment and design correlations for reactors, pressure vessels, compressors, pumps, heat exchangers, separators, storage, water treatment, vents and relief systems. Record the limits and uncertainty of generic correlations.
7. Research CAPEX/OPEX estimation methods and current cost indices. Distinguish Indian cost evidence from converted overseas benchmarks. Record currency, year, location, capacity basis and exclusions.
8. For each source record author/organisation, year, exact title, journal/standard/database, DOI/URL, retrieval date, data type, conditions, units, uncertainty, applicability and intended use in this project.
9. Provide a source-quality score and a contradiction/gap log. Where a database requires paid access or a manufacturer quote, identify it as unavailable and define an honest proxy strategy.

**Constraints and prohibitions**
- Browse and cite actual sources in the execution phase. Never fabricate papers, DOIs, standards, database retrievals or vendor quotations.
- Do not treat marketing claims as independent validation.
- Do not reproduce restricted proprietary datasets or violate database licensing.
- Do not use old regulations without checking whether they remain current and applicable.

**Expected deliverables**
- `04_Research/ENERGY008_Literature_Review.md`
- `04_Research/ENERGY008_Source_Register.xlsx`
- `04_Research/ENERGY008_Standards_Regulatory_Register.xlsx`
- `04_Research/ENERGY008_Data_Gap_Register.csv`
- `04_Research/ENERGY008_Bibliography.bib` or equivalent reference manager export.

**Acceptance criteria**
Every key process choice and parameter is supported by a traceable source or explicitly identified as an assumption. Current Indian regulatory statements have date, authority and applicability evidence.

**Handoff**
Pass the verified source register and data gaps to Prompt 5. Do not begin detailed model calculations until the property-data basis is reviewed.

---

## PROMPT 5 — Property and Data Engineering, Provenance and Quality Control

**Objective**  
Build the controlled data layer for the selected green-methanol process and prepare reproducible inputs for the calculation model.

**Context and inputs**  
Use Prompts 1–4, especially the approved design basis, route, source register and data-gap register.

**Instructions**
1. Inventory all supplied and downloaded files. Separate raw source data, processed datasets, engineering assumptions, fitted parameters, model outputs and test fixtures.
2. Create a property table for every component and mixture required by the selected route. Include molecular weight, critical constants, acentric factor, vapour-pressure data, heat capacity, enthalpy/formation data, density, viscosity, thermal conductivity, heat of vaporisation, heat of reaction, phase-equilibrium data and other properties actually required by the equipment models.
3. Record property value, units, temperature/pressure/composition range, source, correlation equation, coefficients, uncertainty, reference state, conversion, licence/access restrictions and status.
4. Build consistent conversion scripts and unit checks. Preserve source precision; never overwrite original source files.
5. If extracting tabular data from papers, retain the original table/figure identifier, page, digitisation/interpolation method, precision and uncertainty. Manually verify representative rows against the source image or PDF page.
6. Establish a versioned data schema for streams, components, reactions, equipment, utilities, cost inputs, KPIs, control loops and scenarios.
7. Validate missing values, duplicate records, composition sums, stoichiometric consistency, dimensional plausibility, balance consistency and correlation validity ranges.
8. Build a reproducible data manifest with filename, source, file hash, licensing note, transformations, script version and intended model use.
9. Where required data are not obtainable, create an open issue and an uncertainty range or explicitly blocked calculation. Do not fill data gaps with unreferenced constants.

**Constraints and prohibitions**
- Distinguish measured, evaluated, correlated, vendor-specified, calculated, assumed and fitted values.
- Never silently replace missing binary/property data with zero.
- Do not claim access to proprietary sources or paid databases unless actually accessed under licence.

**Expected deliverables**
- `05_Data/raw/` and `05_Data/processed/`
- `05_Data/ENERGY008_Property_Register.xlsx`
- `05_Data/ENERGY008_Stream_and_Reaction_Data_Dictionary.xlsx`
- `05_Data/ENERGY008_Data_Quality_Report.md`
- `05_Data/ENERGY008_Data_Manifest.csv`
- Reproducible extraction/conversion scripts.

**Acceptance criteria**
All model inputs are traceable, machine-readable, unit-consistent, range-checked and version-controlled. No fabricated or silently substituted property values remain.

**Handoff**
Pass validated data tables and open data issues to Prompt 6. Freeze a data version for the first hand-calculation baseline.

---

## PROMPT 6 — Green Methanol Reaction, Thermodynamic and Process Model Formulation

**Objective**  
Select and document the governing physics and constitutive models for the chosen methanol route.

**Context and inputs**  
Use the selected route, design basis, literature and validated property register from Prompts 2–5. The actual model must follow the chosen route; do not force an e-methanol model onto a biomass-syngas route or vice versa.

**Instructions**
1. State all independent reactions and stoichiometry relevant to the selected route. For CO₂ hydrogenation, examine at least CO₂ + 3H₂ ⇌ CH₃OH + H₂O and the reverse-water-gas-shift reaction CO₂ + H₂ ⇌ CO + H₂O; include CO hydrogenation only if justified by the selected syngas formulation. For biomass gasification, define gasification, reforming, water-gas shift and methanol synthesis reactions appropriate to the selected feed and model.
2. Develop atom/element balances for C, H, O and relevant trace elements. Verify stoichiometric matrix rank and independent reactions.
3. Select the appropriate reactor representation (equilibrium, kinetic packed-bed, pseudo-homogeneous, CSTR, plug-flow, staged or other) using literature and available data. Explain whether a simplified equilibrium model is adequate for the academic scope.
4. Select thermodynamic property methods for gas and liquid phases and mixtures. Assess EOS choices for high-pressure synthesis gas and activity/EOS methods for methanol-water-containing liquid mixtures. Justify each model at the operating range; document binary parameters and mixing rules.
5. Formulate reaction equilibrium constants and/or kinetic rate laws, adsorption terms, catalyst effects, heat release, pressure drop, catalyst deactivation and transport limitations only to the extent supported by traceable data.
6. Define the hydrogen production model if electrolysis is included: electrical consumption, efficiency convention, stack/auxiliary power, water demand, outlet pressure/purity, thermal needs, degradation and oxygen coproduct treatment.
7. Define gas purification/compression/heat-exchanger/separation/distillation models required by the selected process.
8. Specify all state variables, algebraic equations, differential equations if dynamic cases are included, initial/boundary conditions and constitutive data.
9. Distinguish rigorous thermodynamic/kinetic models from empirical performance correlations and design assumptions. Document applicability and uncertainty.
10. Identify alternative model formulations and define validation tests before choosing the final calculation route.

**Constraints and prohibitions**
- Do not invent reaction kinetics, catalyst productivity, equilibrium constants, activity parameters or electrolyser efficiency.
- Do not double-count heat of reaction or include reaction equilibrium and conversion correlations inconsistently.
- Do not claim detailed reactor design from a simple stoichiometric conversion model.

**Expected deliverables**
- `06_Model/ENERGY008_Reaction_Network.xlsx`
- `06_Model/ENERGY008_Governing_Equations_Register.xlsx`
- `06_Model/ENERGY008_Property_Method_Selection.md`
- `06_Model/ENERGY008_Model_Assumptions_and_Validity.md`
- `06_Model/ENERGY008_Model_Architecture_Diagram.png`

**Acceptance criteria**
The reaction network, thermodynamic/property models and kinetic/equilibrium approach are physically consistent, source-supported and dimensionally defined.

**Handoff**
Pass the approved reaction network, model equations and property-method selections to Prompt 7. Any model choice lacking data must remain visibly provisional.

---

## PROMPT 7 — Process Description, PFD and Stream Architecture

**Objective**  
Translate the selected route into a complete process configuration and a traceable process flow diagram.

**Context and inputs**  
Use the approved design basis and model formulation from Prompts 2–6.

**Instructions**
1. Describe each unit operation from feed receipt to final methanol product, including conditioning, impurity removal, compression, electrolysis or gasification where applicable, synthesis, cooling, condensation, gas/liquid separation, recycle, purge, product purification, storage, water handling, off-gas, vent/flare or treatment and utilities.
2. Define all battery-limit streams and inter-unit streams. Give each stream a unique ID and define phase, flow, composition, T, P, enthalpy state, contaminants and design case.
3. Draw a PFD in an editable diagram format and export a readable PDF/PNG. Include equipment tags, stream arrows, major conditions, recycle/purge paths, heat integration, utility connections and waste streams.
4. Identify heat recovery opportunities and all process-to-process energy links, but do not assume an exchanger duty until the energy balance is established.
5. Define mass and energy balance control volumes and process boundary. Clearly identify where electricity, steam, cooling water, fuel, air, oxygen, water, catalysts and chemicals cross the boundary.
6. Create a stream table template that covers feed, product, recycle, purge, wastewater, off-gas, condensate, oxygen by-product and solid waste as applicable.
7. Identify missing process units or interfaces that could alter the material/energy/KPI boundary.
8. Check PFD consistency against the chosen route and ensure all streams appear in the stream list.

**Constraints and prohibitions**
- Do not add equipment solely for visual completeness; justify it by process need.
- Do not omit purge or off-gas from recycle systems.
- Do not show mass/energy recovery without accounting for it in the model.

**Expected deliverables**
- `07_Process/ENERGY008_Process_Description.md`
- `07_Process/ENERGY008_PFD.drawio` or editable equivalent
- `07_Process/ENERGY008_PFD.pdf` and `.png`
- `07_Process/ENERGY008_Stream_Register.xlsx`
- `07_Process/ENERGY008_Battery_Limit_Register.xlsx`

**Acceptance criteria**
The PFD, stream table, process description and model control volumes agree. All material, utility, recycle and waste interfaces are represented.

**Handoff**
Pass the PFD, tagged equipment list and stream register to Prompt 8.

---

## PROMPT 8 — Steady-State Material Balances, Recycle and Purge Convergence

**Objective**  
Calculate a complete, auditable steady-state material balance for the base case and alternatives.

**Context and inputs**  
Use the frozen design basis, reaction network, property/data register, PFD and stream register from Prompts 3–7.

**Instructions**
1. Calculate feed/component molar and mass flow rates on one declared basis. Apply stoichiometric and reaction-conversion/selectivity assumptions only from the approved model/data.
2. Solve each reactor or conversion block using the selected equilibrium/kinetic method. Calculate unreacted feed, products, water, by-products, trace impurities and catalyst-related streams where relevant.
3. Calculate condenser, separator and product purification streams. Include methanol/water split, dissolved gases, light ends, purge, recycle and wastewater where supported by the model.
4. Iterate recycle loops using a documented tear-stream or simultaneous-equation approach. Define convergence variables, scaled residuals, tolerance, maximum iterations, initialisation and failure messages.
5. Provide overall, component and elemental balances (C/H/O at minimum where relevant). Include accumulation for transient cases; at steady state, explicitly set accumulation to zero only where justified.
6. Tabulate each major feed, product, recycle, purge, wastewater, off-gas and solid-waste stream with flow, composition, phase, T, P and quality attributes as requested by the assignment.
7. Calculate carbon conversion, carbon utilisation, methanol yield, selectivity, hydrogen utilisation, recycle ratio and product recovery using definitions that match the process boundary.
8. Report absolute and relative closure errors using the assignment’s closure expression and a clearly declared denominator/epsilon. Explain any non-zero discrepancy.
9. Repeat for base and two alternatives using a comparable production and quality basis.

**Constraints and prohibitions**
- Do not close balances by inserting an unexplained balancing stream.
- Distinguish independent data from quantities derived by the balance equations.
- Do not treat a convergence flag as proof of physical correctness.

**Expected deliverables**
- `08_Balances/ENERGY008_BaseCase_Stream_Table.xlsx`
- `08_Balances/ENERGY008_Component_and_Element_Balances.xlsx`
- `08_Balances/ENERGY008_Recycle_Convergence_Log.csv`
- `08_Balances/ENERGY008_AlternativeCase_Balances.xlsx`
- Reproducible calculation scripts/notebooks.

**Acceptance criteria**
Every stream has a consistent basis and state. Total/component/elemental closures meet declared tolerances or are explained and flagged. Recycle convergence is evidenced for every reported case.

**Handoff**
Pass the verified stream and reaction heat basis to Prompt 9.

---

## PROMPT 9 — Energy Balance, Thermal Design and Heat Integration

**Objective**  
Complete the process energy balance and thermal duty model, then identify practical heat-recovery opportunities and quantify utility requirements.

**Context and inputs**  
Use the material balance, reaction data, property methods and process flowsheet from Prompts 5–8.

**Instructions**
1. Set one enthalpy datum and sign convention for heat and shaft work. Include feed/product sensible enthalpy, phase change, heat of reaction, electrical work where relevant, compression/pumping work and heat loss assumptions.
2. Calculate reaction heat with the selected reaction thermodynamic basis and extent. Avoid double counting formation enthalpy and separately added heat-of-reaction terms.
3. Calculate duties for synthesis reactor cooling/heat recovery, feed preheating, interstage cooling, gas coolers, condensers, reboilers, distillation, dryers, water treatment and electrolyser thermal management as applicable.
4. Use temperature-dependent Cp integration where data support it. For phase changes, use valid latent-heat/enthalpy methods. Include pressure effects or real-fluid enthalpy where needed.
5. Prepare a duty table with unit/tag, hot/cold streams, inlet/outlet T/P, mass flow, phase, duty, utility type, approach temperature and status.
6. Use Q̇ = ṁCpΔT for valid sensible-heat approximations and Q̇ = UAΔT_LM for preliminary exchanger area, with stated U source, correction factors, fouling allowance and pinch/approach assumptions.
7. Screen heat integration using composite curves, pinch analysis or a justified network method. Identify feasible process-process heat recovery while preserving process operability and start-up flexibility.
8. Calculate heating/cooling utility consumption, compressor and pump power and any refrigeration/fuel needs using explicit efficiencies and utility states.
9. Calculate an overall energy balance and closure. Separate electrical, thermal and chemical energy inputs and outputs. Report specific energy in kWh/t methanol and GJ/t methanol.
10. Compare base case with both alternatives and quantify recovery improvement and utility penalty.

**Constraints and prohibitions**
- Do not mix HHV and LHV bases.
- Do not use constant Cp outside its range without sensitivity justification.
- Do not count a recovered heat duty twice.
- If enthalpy data are insufficient, show the gap and mark the affected calculation blocked or screening-only.

**Expected deliverables**
- `09_Energy/ENERGY008_Energy_Balance.xlsx`
- `09_Energy/ENERGY008_Equipment_Duty_Register.xlsx`
- `09_Energy/ENERGY008_Heat_Integration_Report.md`
- `09_Energy/ENERGY008_Composite_Curves.png` and heat network drawing
- `09_Energy/ENERGY008_Energy_KPI_Table.xlsx`

**Acceptance criteria**
Duty tables, stream enthalpies, energy closure and utilities use consistent boundaries and units. Heat recovery is physically feasible and not double-counted.

**Handoff**
Pass energy and utility flows to Prompt 10 for entropy/exergy assessment and to Prompts 11–12 for sizing and utility summaries.

---

## PROMPT 10 — Entropy and Exergy Balances

**Objective**  
Quantify process entropy generation, exergy destruction and exergy efficiency using a defined reference environment.

**Context and inputs**  
Use the approved material/energy results and property basis from Prompts 5–9.

**Instructions**
1. Define the environmental dead state T₀ and P₀ appropriate to the Indian site scenario, with source and justification. Define environmental chemical composition/reference if chemical exergy is calculated.
2. Apply steady-state and, where applicable, transient entropy balances with a consistent sign convention. Include stream entropy, heat transfer at boundary temperature and work terms.
3. Estimate entropy flow for major feeds/products, recycle/purge, water/steam, cooling streams, hydrogen/CO₂ and methanol using available properties. Document missing entropy data and approximations.
4. Identify entropy generation from reaction, finite-temperature heat transfer, mixing, throttling, compression, pressure drop, separation and heat rejection as far as the model permits.
5. Calculate physical exergy from enthalpy/entropy departures relative to the dead state. Include chemical exergy only where traceable reference data and consistent chemical-environment conventions are available.
6. Calculate exergy of electricity and fuel inputs. For renewable hydrogen and captured/biogenic carbon, describe the chosen chemical-exergy/accounting convention and avoid mixing life-cycle emissions with thermodynamic exergy.
7. Apply Ė_D = T₀Ṡ_gen and close the overall exergy balance. Report uncertainty where reference properties or compositions are approximate.
8. Rank the largest exergy destruction terms by unit operation and identify at least two technically credible improvement measures. Quantify their estimated potential only when modelled.

**Constraints and prohibitions**
- Do not label energy efficiency and exergy efficiency as the same quantity.
- Do not assign chemical exergy values without sources and a declared reference environment.
- Do not claim a fully closed exergy balance if any major stream or work input is omitted.

**Expected deliverables**
- `10_Exergy/ENERGY008_Entropy_Balance.xlsx`
- `10_Exergy/ENERGY008_Exergy_Balance.xlsx`
- `10_Exergy/ENERGY008_Exergy_Destruction_Ranking.png`
- `10_Exergy/ENERGY008_Improvement_Opportunities.md`

**Acceptance criteria**
Dead state, property methods, sign conventions, included streams and exclusions are explicit. Entropy/exergy closure and unit checks are reproducible.

**Handoff**
Pass energy/exergy loads and improvement opportunities to Prompt 11 for equipment design.

---

## PROMPT 11 — Detailed Equipment Selection, Sizing and Engineering Datasheets

**Objective**  
Select and preliminarily size the major equipment and auxiliaries using the approved flowsheet, stream loads and duty basis.

**Context and inputs**  
Use Prompts 3–10. Design normal, minimum, maximum, turndown and upset conditions. Use vendor data only when actually sourced.

**Instructions**
1. Prepare an equipment register with tags and service. Include reactor(s), gas/electrolyser package where applicable, compressors, pumps, heat exchangers, coolers/condensers, gas-liquid separators, distillation columns, storage, filters, water treatment and waste/vent systems as relevant.
2. For each equipment item define duty, capacity, phase, composition, normal/design/minimum/maximum throughput, operating/design pressure and temperature, materials basis, corrosion/fouling allowance, cleaning, turndown and margin.
3. Reactor: justify type and catalyst; calculate required volume/weight, residence time/space velocity, heat-transfer duty, pressure drop, mixing or drive power and preliminary diameter/length. Use kinetics or equilibrium limits and clearly identify simplified assumptions.
4. Electrolyser (if applicable): size stack capacity from H₂ flow and specific energy, include auxiliaries, turndown, ramping, redundancy, water treatment, cooling and oxygen handling.
5. Compressors/pumps: calculate flow, pressure rise/head, power using the required equations; include efficiency, motor efficiency, service factor, stages/intercooling and design margin.
6. Heat exchangers: calculate duty, LMTD, corrected area, U, pressure drop and fouling factors. State whether the calculation is preliminary or rating-level.
7. Separators/columns: calculate vapour/liquid loads, residence/holdup, diameter, height/stages/packing or tray basis, pressure drop and product specification checks as supported.
8. Storage and ancillary equipment: calculate working volume, operating inventory, design capacity, venting/blanketing and transfer requirements.
9. Provide a datasheet for each major item with tag/service, capacity, phase, conditions, materials, calculated duty/area/volume/diameter/head/power, assumptions/margin, connections, instrumentation, utilities, relief/safeguards, footprint, cleaning/maintenance access and code/standard to verify.
10. Perform a preliminary feasibility check at normal, turndown and upset cases. State what requires vendor confirmation, CFD, detailed mechanical design or code calculation.

**Constraints and prohibitions**
- Do not claim pressure-vessel, boiler, piping, electrical or machinery-code compliance based on preliminary equations.
- Do not use Souders–Brown or generic correlations outside their stated range.
- Do not claim vendor endorsement or quote without actual vendor evidence.

**Expected deliverables**
- `11_Equipment/ENERGY008_Equipment_Register.xlsx`
- `11_Equipment/Datasheets/` (one editable datasheet per major tag)
- `11_Equipment/ENERGY008_Equipment_Sizing_Calculations.xlsx`
- `11_Equipment/ENERGY008_Equipment_Feasibility_Report.md`

**Acceptance criteria**
Every major process item has a traceable sizing method, substituted calculation, design assumptions, operating-case check and datasheet. Preliminary versus detailed/mechanical scope is explicit.

**Handoff**
Pass equipment capacities, duties, utilities and materials questions to Prompts 12–13.

---

## PROMPT 12 — Utilities, Water, Environment, Emissions and Waste

**Objective**  
Quantify utility demand, water balance, environmental outputs and waste/recovery opportunities for base and alternative cases.

**Context and inputs**  
Use Prompts 3–11, including all equipment duties and energy/exergy balances.

**Instructions**
1. Prepare a utility balance for steam/hot water, cooling water, chilled water/refrigeration, electricity, fuel, compressed air, instrument air, nitrogen/inert gas, process water, boiler/feed water, demineralised water, electrolyser water and wastewater treatment as applicable.
2. For each utility report duty or power, supply/return conditions, pressure, temperature, consumption, efficiency, operating hours, annual use, cost input source and uncertainty.
3. Separate process electricity, electrolyser electricity, compression, pumps, cooling, controls and auxiliaries. Report gross and net specific energy per tonne of on-spec methanol.
4. Close the water balance, including electrolysis water, reaction water, cooling make-up, boiler make-up, cleaning, blowdown, wastewater, product water and treatment losses.
5. Quantify CO₂ feed and utilisation, carbon in product, purge/off-gas, direct process emissions, fuel combustion, power-related indirect emissions and other relevant greenhouse gas streams. Define the emissions boundary and electricity emission factor source.
6. Quantify liquid waste, off-gas, rejected product, catalyst/adsorbent waste, purge, solid residues and wastewater. Identify recovery, recycle, treatment or disposal options.
7. Check current Indian environmental requirements and relevant regulatory/standards sources for air, water, hazardous waste, pressure equipment and storage, documenting applicability and approval authority. Distinguish legal obligations from good practice.
8. Build a utility summary and environmental KPI table for all three cases.

**Constraints and prohibitions**
- Do not assume zero emissions for renewable electricity or captured CO₂ without stating the accounting method.
- Do not count internally recycled water or heat as an external utility saving more than once.
- Do not present generic emission factors as site-specific measurements.

**Expected deliverables**
- `12_Utilities/ENERGY008_Utility_Summary.xlsx`
- `12_Utilities/ENERGY008_Water_Balance.xlsx`
- `12_Utilities/ENERGY008_Emissions_and_Waste_Register.xlsx`
- `12_Utilities/ENERGY008_Environmental_and_Indian_Compliance_Screen.md`

**Acceptance criteria**
Utility, water, emissions and waste quantities reconcile with process streams and duties. Boundaries and factors are traceable.

**Handoff**
Pass hazardous inventories, utilities and environmental loads to Prompt 13.

---

## PROMPT 13 — Process Safety, Materials Compatibility and Safeguard Screening

**Objective**  
Identify key hazards and define preliminary safeguards, materials questions and safe-state principles without claiming a certified safety study.

**Context and inputs**  
Use the selected route, PFD, equipment register, operating envelope, utility data and Indian standards register from Prompts 2–12.

**Instructions**
1. Identify process-specific hazards: hydrogen flammability/leakage, oxygen enrichment, CO toxicity where present, CO₂ asphyxiation, methanol toxicity/flammability, high pressure, high-temperature synthesis, catalyst hazards, hot surfaces, rotating equipment, electrical/electrolyser hazards, vacuum/overpressure, loss of cooling, water ingress and storage/transfer risks.
2. Review process inventories, operating conditions, ignition sources, hazardous areas, ventilation, detection, isolation, relief, purge/inerting and emergency access.
3. Create a preliminary HAZID or What-If table with deviation, causes, consequences, existing/proposed safeguards, action, owner and status. Identify nodes requiring a formal HAZOP.
4. Prepare a preliminary materials compatibility/corrosion/fouling register for hydrogen service, CO₂/wet CO₂, methanol/water, synthesis gas, oxygen and other process chemicals. Use relevant standards and materials data; do not specify final metallurgy without engineering validation.
5. Identify relief and vent system design cases: blocked outlet, fire exposure, control failure, runaway/abnormal heat input, thermal expansion, utility loss, compressor discharge blockage and other credible cases. Define these as required studies, not fully sized relief devices unless data and methods support it.
6. Establish safe-state concepts and preliminary cause/effect requirements for gas detection, high pressure/temperature, low cooling flow, compressor trips, high/low levels, off-spec product and loss of power/instrument air.
7. Check applicable Indian rules and standards from current official sources. Record edition, applicability and items requiring a licensed/certified engineer.
8. State that formal HAZOP, LOPA, SIL assessment, QRA, hazardous-area classification and detailed relief design require competent specialist review.

**Constraints and prohibitions**
- Do not assign a SIL number without formal risk assessment.
- Do not claim regulatory approval, certified safety integrity or code compliance.
- Do not treat a preliminary HAZID as a completed HAZOP.

**Expected deliverables**
- `13_Safety/ENERGY008_HAZID_WhatIf.xlsx`
- `13_Safety/ENERGY008_Safeguard_and_CauseEffect_Register.xlsx`
- `13_Safety/ENERGY008_Materials_Compatibility_Register.xlsx`
- `13_Safety/ENERGY008_Safety_Study_Limitations.md`

**Acceptance criteria**
Major hazards, safeguards, open actions and specialist design requirements are traceable to PFD/equipment/controls.

**Handoff**
Pass preliminary safeguards and process limits to Prompts 14–15.

---

## PROMPT 14 — PLC/DCS/SCADA Control Philosophy, Loop Register and HMI Design

**Objective**  
Create a process-specific industrial automation and control package for the selected green-methanol process.

**Context and inputs**  
Use the PFD, equipment design, safety register and operating envelope from Prompts 7–13. The assignment explicitly requests PLC/DCS/SCADA compatibility and a loop register.

**Instructions**
1. Define control-system architecture and responsibilities: basic process control system, PLC package controls, DCS supervision, SCADA/HMI, data historian, alarms, interlocks and independent safety functions where required.
2. Develop a control philosophy for feed/ratio, gas composition, reactor temperature, pressure, recycle, compressor anti-surge, separator level, product quality, distillation, cooling, electrolysis power/hydrogen production, water, vent/purge and throughput as applicable.
3. Create a detailed loop register with loop ID, controlled variable/PV, sensor, measurement range, manipulated variable/MV, final element, controller, setpoint/range, control objective, normal mode, alarm limits, interlocks, failure position and operator action.
4. Include the example loop families FIC, TIC, PIC, LIC and ESD/SIS where relevant; revise tag numbers for the actual PFD and avoid copying inappropriate examples unchanged.
5. Design the HMI overview, equipment faceplates, trend pages, alarm summary, active interlocks, stream/KPI dashboard, utility status and operator guidance.
6. Define measurements relevant to the selected process: flow, pressure, temperature, level, H₂/CO₂/CO/methanol composition, moisture, differential pressure, vibration, gas detection, conductivity/water quality and power where relevant.
7. Create an alarm register with tag, priority, limit, deadband, delay, cause, consequence and operator action. Rationalise alarms and avoid alarm flooding.
8. Prepare an interlock/cause-and-effect matrix with initiating condition, voting where justified, final element, action, reset/permissive and safe-state response.
9. Separate ordinary control from safety instrumented functions. Define interface and testing needs without assigning SIL absent formal assessment.
10. Provide controller diagrams or logic narratives and identify signals needing redundancy or independent protection.

**Constraints and prohibitions**
- Do not claim that a diagram is a validated PLC application or executable DCS logic.
- Do not invent setpoints or alarm limits without process/safety basis.
- Do not imply SIL certification.

**Expected deliverables**
- `14_Automation/ENERGY008_Control_Philosophy.md`
- `14_Automation/ENERGY008_Control_Loop_Register.xlsx`
- `14_Automation/ENERGY008_Alarm_Register.xlsx`
- `14_Automation/ENERGY008_Interlock_CauseEffect_Matrix.xlsx`
- `14_Automation/ENERGY008_HMI_Design_Specification.pdf`

**Acceptance criteria**
Every critical process variable and equipment protection function is mapped to a measurement, controller/final element, alarm/interlock and operator response, or recorded as an open design action.

**Handoff**
Pass control modes and interlock matrix to Prompt 15 and the P&ID development record.

---

## PROMPT 15 — P&ID-Level Definition, Operating Modes and Disturbance Sequences

**Objective**  
Convert the PFD/control philosophy into a P&ID-level sketch and executable-style operating sequence descriptions.

**Context and inputs**  
Use the approved PFD, equipment register, control-loop register, alarm/interlock matrix and safety register from Prompts 7–14.

**Instructions**
1. Draw a P&ID-level sketch for critical equipment and packages. Show isolation/control/check valves, drains, vents, relief devices, sample points, bypasses, instrument tags, utility tie-ins, purge/flush connections and safe maintenance boundaries.
2. Define operating modes: off, maintenance, manual, automatic, start-up, normal, turndown, cleaning/regeneration, controlled shutdown, emergency shutdown and restart, as applicable.
3. Build a state/step sequence with prerequisites, permissives, transition conditions, timers, abort conditions, failure branches, operator prompts and reset/restart rules.
4. Create start-up sequence from utility availability, inerting/purging, leak test, feed admission, catalyst/reactor warm-up, pressure build-up, recycle establishment, product introduction and quality stabilisation as applicable. Use process-specific safe steps and do not invent operating procedures beyond the design basis.
5. Create normal shutdown and emergency shutdown narratives. Include isolation, depressurisation, purge, cool-down and hazardous inventory handling only as supported by the safety basis.
6. Model at least one disturbance case in detail and include other relevant cases: renewable power variability, loss of feed, cooling failure, compressor trip, sensor failure, valve failure, instrument-air/power loss, communication loss and off-spec product.
7. For each case document detection, automatic response, operator action, time scale, expected process impact, recovery condition and whether process simulation or qualitative logic testing supports the response.
8. Prepare a sequence/state diagram and automation-flowchart input for Prompt 16.

**Constraints and prohibitions**
- Do not create a real operating procedure or bypass safety review.
- Do not specify hazardous depressurisation or venting instructions without process safety review.
- Clearly label conceptual P&ID elements that require instrumentation and piping engineering validation.

**Expected deliverables**
- `15_PID_Sequence/ENERGY008_PID_Level_Sketch.pdf` and editable source
- `15_PID_Sequence/ENERGY008_Operating_Mode_Matrix.xlsx`
- `15_PID_Sequence/ENERGY008_StartStop_Sequence.md`
- `15_PID_Sequence/ENERGY008_Disturbance_Response_Matrix.xlsx`
- `15_PID_Sequence/ENERGY008_Automation_State_Diagram.png`

**Acceptance criteria**
The P&ID sketch, control register, cause/effect matrix and sequences are internally consistent and cover the required modes and at least one quantified disturbance.

**Handoff**
Pass sequence logic, calculation workflow and control-state logic to Prompt 16.

---

## PROMPT 16 — Numerical Workflow, Solver Design and Required Flowcharts

**Objective**  
Define robust numerical solution procedures and create the three flowcharts required by ENERGY-008.

**Context and inputs**  
Use model equations, PFD, balances, energy/exergy methods, control sequences and disturbance matrix from Prompts 6–15.

**Instructions**
1. Identify model variables and classify the system as algebraic, nonlinear, recycle-coupled, dynamic or hybrid as appropriate. State which calculations are sequential and which are iterated.
2. Define material-balance and recycle iteration method, reactor model solver, equilibrium/kinetic calculation, heat-integration calculation, property evaluation, optimisation and KPI aggregation.
3. Specify initial estimates, variable bounds, scaling, residual definitions, tolerances, maximum iterations, continuation/homotopy if required, failure handling and numerical diagnostics.
4. Define how the program treats missing property data, nonphysical states, negative flow, non-convergent recycle, invalid reaction extent, negative entropy generation (diagnostic), energy imbalance and infeasible equipment sizing.
5. For dynamic or control sequences, identify state variables, time step/integration method, event handling, controller sample period, actuator limits and disturbance injection method. Do not simulate detailed control dynamics unless model complexity/data support it.
6. Produce a **top-level process flowchart**: inputs → validation → properties/model → reaction/process solver → stream balances → energy/entropy/exergy → equipment → utilities/environment → economics → controls/sensitivity/KPIs → outputs.
7. Produce a **detailed principal nonlinear solver/calculation flowchart** showing initialisation, residual evaluation, convergence checks, bounds, recycle iteration, failure/recovery and export.
8. Produce an **automation state/sequence diagram** showing permissives, operating states, alarms, interlocks, trips, safe states and reset/restart paths.
9. Ensure diagrams match the actual intended code modules and sequence definitions.

**Constraints and prohibitions**
- Do not use solver success flags as the sole acceptance test.
- Do not hide non-convergence or silently substitute default values.
- Avoid overengineering dynamic models beyond available data.

**Expected deliverables**
- `16_Algorithms/ENERGY008_Numerical_Methods.md`
- `16_Algorithms/ENERGY008_TopLevel_Flowchart.png` plus editable source
- `16_Algorithms/ENERGY008_Solver_Flowchart.png` plus editable source
- `16_Algorithms/ENERGY008_Automation_State_Sequence.png` plus editable source
- `16_Algorithms/ENERGY008_Convergence_and_Failure_Standards.xlsx`

**Acceptance criteria**
Every numerical process loop, convergence condition, exception and output has an explicit place in the flowcharts and algorithm description.

**Handoff**
Pass the frozen algorithm and test fixture definitions to Prompt 17.

---

## PROMPT 17 — Independent Manual Calculations and Benchmark Fixture

**Objective**  
Create a transparent hand-calculation package before MATLAB implementation so the software can be checked against independent arithmetic.

**Context and inputs**  
Use the approved design basis, data version, stream architecture, reaction network, energy methods and solver plan from Prompts 3–16.

**Instructions**
1. Choose a representative base-case calculation point and clearly list every input, unit, source/assumption status and significant figure.
2. Independently calculate feed/component mass and molar flows; reaction extents; reactant consumption; products and by-products; carbon/hydrogen/oxygen balances; conversion/selectivity/yield; recycle/purge; product flow and composition.
3. Hand-calculate at least one key reactor quantity using the selected model (e.g. equilibrium/stoichiometric benchmark or rate/volume calculation), explaining why the calculation is an independent check rather than a copy of a solver output.
4. Work through at least one sensible heat duty, one reaction/latent duty where applicable, one exchanger area estimate using Q̇ = UAΔT_LM, and one pump/compressor power estimate using the assignment relation P_shaft = ρgQ̇_vH/η_p where applicable.
5. Perform a clear material, energy and (where supported) entropy/exergy closure check. State why any balance is a screening value or blocked.
6. Manually reconstruct one major equipment size and one KPI. Provide units at every step and show conversions.
7. Calculate uncertainty bounds for at least one input-sensitive result.
8. Create a calculation register with ID, purpose, inputs, equations, substituted values, result, units, independent check, source and status.
9. Freeze the hand-calculation fixture and expected tolerances for later MATLAB and Python regression tests.

**Constraints and prohibitions**
- Do not copy code-generated results and label them manual.
- Do not use values with no source or assumption label.
- Do not force material/energy closure by adjusting a result without justification.

**Expected deliverables**
- `17_Manual_Calculations/ENERGY008_Manual_Calculation_Workbook.xlsx`
- `17_Manual_Calculations/ENERGY008_Hand_Calculation_Report.md`
- `17_Manual_Calculations/ENERGY008_Benchmark_Fixture.json`
- `17_Manual_Calculations/ENERGY008_Independent_Checks.csv`

**Acceptance criteria**
A technically competent reviewer can reproduce key calculations by hand. Expected outputs and tolerances are frozen before coding.

**Handoff**
Pass the benchmark fixture, equations, data schema and test cases to Prompt 18.

---

## PROMPT 18 — MATLAB Architecture, START_HERE, Robust Paths and Data Discovery

**Objective**  
Design the maintainable MATLAB project structure and reproducible startup mechanism before implementing the process calculations.

**Context and inputs**  
Use all approved phase outputs, especially Prompts 1, 5–7, 16 and 17. MATLAB is the primary platform. The assignment specifically requests the module names listed below.

**Instructions**
1. Design a project tree with `START_HERE.m`, `main.m`, `input_validation.m`, `property_models.m`, `material_balance.m`, `energy_balance.m`, `entropy_exergy.m`, `equipment_sizing.m`, `utilities_model.m`, `control_logic.m`, `economics.m`, `sensitivity_optimisation.m`, `validation_checks.m` and `reporting_plots.m`, plus folders for GUI, data, tests, outputs, logs, flowcharts and documentation.
2. Keep the calculation engine independent of GUI callbacks. Define consistent function signatures and structured inputs/outputs for components, reactions, streams, equipment, utility systems, scenarios, KPIs and diagnostics.
3. Require `START_HERE.m` to determine project root using `mfilename('fullpath')` and a project marker/configuration file, never `pwd`. The project must work after copying/extracting to any directory without editing `pathdef.m` or hard-coded user paths.
4. Add only controlled project source folders to the MATLAB path. Do not recursively add archives, old versions, arbitrary dependencies or unrelated folders.
5. Discover data only within configured project directories. Use explicit manifest/config paths first, exact filenames next, then documented unambiguous matching. If multiple matches exist, list candidates and stop for user choice; never silently load the first match.
6. Support only declared formats. Validate headers, required columns, units, missing values, duplicates, ranges, component identities, compositions, source metadata and schema version.
7. Create output/report/log directories. Preserve previous results unless overwrite is explicit. Log configuration, data file hashes, warnings, errors, software version and run status.
8. Provide actionable errors for missing or ambiguous data, unsupported properties, unavailable toolboxes, invalid inputs, infeasible operating conditions and solver failures.
9. Define testable interfaces for each calculation module and avoid a single monolithic script.
10. Document the required MATLAB release and toolboxes only after verifying their availability.

**Constraints and prohibitions**
- Do not implement a dummy or placeholder solver as a completed engineering module.
- Do not depend on current working directory or manual path setup.
- Do not overwrite user files silently.

**Expected deliverables**
- `MATLAB/START_HERE.m`
- `MATLAB/main.m`
- All requested module `.m` files (initially with documented interfaces only if implementation is assigned to Prompt 19)
- `MATLAB/project_config.json` or equivalent
- `MATLAB/README.md`
- `MATLAB/docs/Software_Architecture.md`
- `MATLAB/docs/Data_Discovery_and_Error_Handling.md`

**Acceptance criteria**
A copied/extracted project can identify its own root, validate configuration and locate its declared data without hard-coded paths. A source-only smoke test demonstrates path setup if MATLAB is available; otherwise runtime status is NOT RUN.

**Handoff**
Pass architecture, API contracts, project configuration and startup design to Prompt 19.

---

## PROMPT 19 — Implement the MATLAB Green-Methanol Engineering Modules

**Objective**  
Implement the substantive ENERGY-008 calculation engine in MATLAB using the frozen models, equations and hand-calculation fixture.

**Context and inputs**  
Use the architecture from Prompt 18 and verified data/model outputs from Prompts 5–17. Implement only the selected route and the documented alternatives.

**Instructions**
1. Implement property/data loading, reaction stoichiometry, reactor calculation, recycle/purge, stream properties, total/component/elemental material balances, energy balances, entropy/exergy calculations, equipment sizing, utilities, environmental KPIs and economics.
2. Implement input validation and structured diagnostic results. Each function must return both values and status/warnings/source provenance where relevant.
3. Use SI units internally. Add unit conversions at import/export boundaries and assert dimensional plausibility.
4. Implement recycle convergence and reaction/process solvers from Prompt 16. Record iteration history, residual norms, convergence status and failure reason.
5. Implement operating scenarios: base, two alternatives, turndown and selected disturbance. Keep all scenario inputs explicit and versioned.
6. Implement data-driven calculations from actual source registers. Never hard-code an undocumented property or performance constant in a calculation function.
7. Implement equipment sizing relations and datasheet data structures. Separate preliminary correlations from any code-level design not implemented.
8. Implement utilities and cost models with input sources, currency/reference year, escalation and uncertainty fields. Preserve BLOCKED/SCREENING_ONLY status when cost or utility basis is incomplete.
9. Implement KPI formulas and ensure every reported KPI is traceable to streams, duties, electricity, water, emissions or cost inputs.
10. Use structured output objects/tables and export CSV/XLSX/JSON as practical.
11. Add comments for equations, symbols, units, assumptions, source limitations and tolerances.

**Constraints and prohibitions**
- Do not populate result tables with expected answers instead of computing them.
- Do not use hidden global variables for process inputs.
- Do not silently catch an error and return a plausible result.
- Do not label the model validated before Prompt 21.

**Expected deliverables**
- Implemented MATLAB modules named in Prompt 18
- `MATLAB/data/default_case.json` and versioned case files
- `MATLAB/results/` with actual run exports only
- `MATLAB/tests/` with unit-test source
- `MATLAB/docs/Model_Implementation.md`

**Acceptance criteria**
Every required calculation has an actual implementation or an explicit documented blocker. The default run reproduces the independent benchmark within stated tolerances when the software is executed.

**Handoff**
Pass the engine, APIs, test fixtures and initial run logs to Prompt 20.

---

## PROMPT 20 — MATLAB GUI, HMI-Inspired Screens, Plotting and Export

**Objective**  
Create a working MATLAB GUI that exposes the engineering model and required outputs without embedding calculation logic in UI callbacks.

**Context and inputs**  
Use the MATLAB engine from Prompts 18–19 and the control philosophy/HMI specification from Prompt 14. The assignment requests tabs for design basis, streams, operating conditions, equipment, balances, utilities, economics, automation, sensitivity and reports.

**Instructions**
1. Build an App Designer or programmatic UI implementation supported by the target MATLAB release. GUI must call the tested engine functions.
2. Provide tabs/pages for design basis, streams, operating conditions, process model, balances, equipment, utilities/environment, economics, automation/control status, sensitivity/optimisation and reports.
3. Provide unit-aware inputs, drop-downs for approved cases/models, reset to defaults, Run/Calculate, validation messages, calculation status, warnings and detailed error messages.
4. Display key stream tables, component/elemental balance closure, energy/entropy/exergy summaries, equipment datasheets, utility summary, CAPEX/OPEX, KPIs and sensitivity plots.
5. Clearly mark sourced, calculated, fitted, assumed and estimated values. Display uncertainty and model applicability warnings.
6. Provide export of numerical results, stream tables, datasheets, plots and run logs. Include run ID, case ID, timestamp, model version, data version and assumptions.
7. Keep UI layout usable at normal desktop resolutions. Test empty/invalid inputs, missing data, failure states and repeated runs.
8. Do not display fictitious example results as current solver results. Include a label for example/synthetic fixtures where used.

**Constraints and prohibitions**
- GUI callbacks must not duplicate model equations.
- Do not present a failed calculation as a valid green indicator or successful design.
- Do not claim GUI testing unless actual MATLAB execution evidence exists.

**Expected deliverables**
- `MATLAB/gui/ENERGY008_App.m` or `.mlapp`
- `MATLAB/run_gui.m`
- `MATLAB/docs/GUI_User_Guide.md`
- GUI screenshots from actual application runs if available
- Export examples generated by actual test cases

**Acceptance criteria**
The GUI is connected to the calculation engine, displays run status and warnings, and exports traceable results. If MATLAB cannot be run, source creation and unexecuted status must be stated separately.

**Handoff**
Pass GUI source, test procedure and actual run evidence to Prompt 21.

---

## PROMPT 21 — Verification, Validation, Regression Testing and Defect Correction

**Objective**  
Independently establish which ENERGY-008 requirements and calculations are verified, validated, failed, blocked or not run.

**Context and inputs**  
Use the original assignment, requirements matrix, all prior phase outputs, MATLAB source, GUI and independent hand calculations.

**Instructions**
1. Review every requirement in the traceability matrix and inspect actual source/code/data/output evidence.
2. Create tests for at least three reproducible cases: base case, Alternative 1 and Alternative 2. Also test normal/turndown/upset or disturbance cases and invalid input conditions.
3. Include unit tests for component/elemental balances, reaction stoichiometry, property functions, heat duties, pump/compressor power, entropy/exergy signs, equipment calculations, KPI equations, recycle convergence and economic units.
4. Include integration tests for the complete process path, recycle loops, utilities, HMI exports and failure handling.
5. Compare MATLAB results with the independent hand calculation and at least one external literature/reference case where meaningful. Do not treat the same calculation function run twice as independent validation.
6. Check energy/mass conservation, dimensional consistency, physical bounds, reaction feasibility, product specification, pressure/temperature limits, equipment margin and positive entropy generation where applicable.
7. Test invalid/edge conditions: negative/zero flow, invalid composition, missing property, out-of-range property correlation, zero/negative conversion, unavailable utility, non-convergent recycle, equipment overload, sensor/actuator fault and missing input file.
8. Verify `START_HERE.m` after extraction into a different directory and test data path discovery without `pwd` dependence.
9. Test GUI Run, Reset, message handling, data tables, plots and exports. Include actual screenshots or test logs where possible.
10. Report absolute and relative deviations with suitable denominator rules; never divide by zero or use relative error against a zero target.
11. Maintain `PASS`, `FAIL`, `BLOCKED`, `NOT RUN` and `SCREENING ONLY` statuses. Correct defects and rerun affected tests; preserve a record of original failures and corrective changes.
12. Update requirement evidence links only after test evidence exists.

**Constraints and prohibitions**
- A present source file is not proof it ran.
- A solver exit flag is not physical validation.
- A failed test must not be relabelled PASS because the output is plausible.
- Do not claim a literature validation when only the same dataset was used to fit the model.

**Expected deliverables**
- `21_Verification/ENERGY008_Verification_Matrix.xlsx`
- `21_Verification/ENERGY008_Unit_Integration_Test_Report.md`
- `21_Verification/ENERGY008_Independent_Comparison.xlsx`
- `21_Verification/ENERGY008_Test_Logs/`
- `21_Verification/ENERGY008_Defect_and_Correction_Log.csv`

**Acceptance criteria**
All 27 assignment topics have evidence/status. Three reproducible cases are compared. Runtime and GUI tests are accurately classified based on actual execution.

**Handoff**
Pass verified model results and unresolved issues to Prompt 22. Only verified or explicitly screening results may feed final optimisation conclusions.

---

## PROMPT 22 — Six-Variable Sensitivity, Uncertainty, Alternative Cases and Optimisation

**Objective**  
Complete the required sensitivity and optimisation analysis and recommend a feasible operating window for the base route and alternatives.

**Context and inputs**  
Use the approved design basis, model, verified code, test records and equipment/utility limits from Prompts 3–21.

**Instructions**
1. Run at least six independent sensitivity variables selected from the assignment list: throughput, feed composition, temperature, pressure, residence time, recovery/yield, utility price, downtime, efficiency or control setpoint. Add route-specific variables such as H₂/CO₂ ratio, recycle/purge ratio, electrolyser specific energy, CO₂ purity, heat-recovery approach or catalyst performance where relevant.
2. For each study state baseline, varied variable, range, step, fixed inputs, output metrics, constraints, convergence status and source/assumption rationale for the range.
3. Include one multivariable method (e.g. factorial design, response surface, Latin hypercube or Monte Carlo) chosen for the available model and computational budget. Explain sampling and statistical interpretation.
4. Quantify uncertainty from major input parameters: capacity, feed composition, catalyst performance, conversion/selectivity, electricity price/carbon intensity, thermal duties, heat-transfer coefficients, equipment factors and cost indices as applicable.
5. Compare base case with at least two alternatives under common product and boundary definitions. Report methanol rate/quality, carbon utilisation, specific power/heat, water use, exergy performance, emissions intensity, equipment sizes, CAPEX/OPEX and levelised methanol cost where supported.
6. Optimise a defined objective such as minimum levelised cost, minimum specific energy, minimum CO₂e intensity or a multiobjective compromise. Apply constraints on product grade, pressure/temperature, equipment capacity, safety limits, renewable electricity availability, water demand and availability.
7. Identify Pareto trade-offs, infeasible regions and an operating window. Distinguish recommendations supported by the model from exploratory indications.
8. Ensure failed/infeasible numerical cases are not connected as valid trend lines or included in averages without explicit handling.
9. Report which variables most affect energy KPIs and process economics and quantify uncertainty intervals.

**Constraints and prohibitions**
- Do not report fewer than six varied inputs.
- Do not call an arbitrary parameter sweep an optimisation unless an objective and constraints are defined.
- Do not extrapolate outside source/model validity without clearly labelling exploratory results.

**Expected deliverables**
- `22_Sensitivity_Optimisation/ENERGY008_Sensitivity_Plan.xlsx`
- `22_Sensitivity_Optimisation/ENERGY008_Sensitivity_Results.xlsx`
- `22_Sensitivity_Optimisation/ENERGY008_Uncertainty_Analysis.xlsx`
- `22_Sensitivity_Optimisation/ENERGY008_Alternative_Comparison.xlsx`
- `22_Sensitivity_Optimisation/ENERGY008_Operating_Window_and_Recommendation.md`
- All labelled sensitivity/optimisation plots.

**Acceptance criteria**
At least six independent sensitivity studies and one multivariable method are complete. Base and alternatives are compared on a common basis. Recommended operating window respects model and engineering constraints.

**Handoff**
Pass final verified metrics and limitations to Prompt 23 and the final report phase.

---

## PROMPT 23 — Python/Open-Source Migration and Cross-Platform Reproducibility

**Objective**  
Create a documented migration path from the MATLAB model to a Python/open-source stack while preserving equations, units and test outputs.

**Context and inputs**  
Use the MATLAB module architecture, verified model, data schemas and test fixtures from Prompts 18–22. The assignment names NumPy, SciPy, pandas and Matplotlib and asks that CoolProp, Cantera, BioSTEAM or DWSIM be considered where suitable.

**Instructions**
1. Map each MATLAB module to a Python module and define its responsibility, inputs, outputs, data types, errors and unit conventions.
2. Use NumPy/SciPy for numerical computation, pandas for tabular streams/data, Matplotlib for plots and an appropriate package for thermophysical/reaction modelling only where technically valid.
3. Evaluate CoolProp, Cantera, BioSTEAM and DWSIM for actual project needs, limitations, licensing, model availability, property coverage and installation compatibility. Do not add dependencies solely for name recognition.
4. Port core functions in a staged manner: input/configuration, property methods, reaction model, stream balances, energy/entropy/exergy, equipment, utilities/economics, KPIs, sensitivity and exports.
5. Keep GUI-independent core calculations. If a Python UI is proposed, state that it is a future extension unless specifically implemented.
6. Reuse the frozen benchmark fixture and compare MATLAB/Python outputs within defined tolerances. Explain differences due to solver, rounding or property-library version.
7. Provide a lock file/environment specification and exact clean installation/run/test instructions.
8. Preserve source citations, data provenance and licence notices for all data/dependencies.

**Constraints and prohibitions**
- Do not claim full migration if only documentation or partial stubs are produced.
- Do not change the model formulation silently during porting.
- Do not distribute proprietary or restricted property databases.

**Expected deliverables**
- `Python/` modular source tree
- `Python/pyproject.toml` or `requirements.txt` and lock file
- `Python/README.md`
- `Python/tests/`
- `Python/results/` from actual executions
- `Python/docs/MATLAB_to_Python_Mapping.xlsx`

**Acceptance criteria**
The migration scope is explicit. Implemented modules pass parity tests against MATLAB/hand benchmarks or are identified as incomplete.

**Handoff**
Pass completed source, tests and reproducibility evidence to Prompt 24.

---

## PROMPT 24 — Final Technical Report and Short Presentation

**Objective**  
Prepare the final engineering report and presentation from actual, audited results and the original ENERGY-008 assignment.

**Context and inputs**  
Use the original `PSLassignment2.pdf`, all approved design-basis/data registers, calculations, MATLAB/Python source, PFD/P&ID, datasheets, automation documents, safety/environment records, sensitivity results and verification evidence from Prompts 1–23. Use the CPS-01 report from the earlier conversation as a **visual and structural reference only**. If the file is not accessible in the execution session, ask the user to reattach it rather than inventing its appearance.

**Instructions**
1. Build the report in the assignment's exact order and preserve all 27 numbered assignment topics. Do not renumber ENERGY-008 to another project's section scheme.
2. Use a professional A4 report format similar to the CPS-01 reference: formal project cover and shaded identification/submission table; document control and engineering basis; executive summary; clickable table of contents with accurate page numbers; nomenclature/units; numbered technical sections; figure/table lists where useful; appendices; page number footer; internal “Back to Contents” navigation; and engineering sign-off/declaration.
3. Cover the assignment-required report content: executive summary/design basis; literature/standards review and provenance; process description/PFD/stream tables; equations, assumptions and numerical method; equipment calculations/datasheets; mass/energy/entropy/exergy balances; automation philosophy, loop register, sequence and alarm matrix; utilities/environment/safety; CAPEX/OPEX; sensitivity/optimisation; validation; limitations and recommendations.
4. Include a substantial worked calculation trail with equations, units, substituted numbers, intermediate values, result, source, assumption status and independent check. Do not replace calculations with summaries.
5. Insert the actual PFD, P&ID-level sketch, process/solver/automation flowcharts, relevant equipment diagrams, heat integration plots, KPI plots, sensitivity/optimisation plots and validation figures. Every figure/table must have a number, caption, units and in-text reference.
6. Include stream tables, equipment datasheets, utility tables, loop register, alarm/interlock matrix, operation sequence, disturbance response, environmental/waste table, cost breakdown and test/verification matrix.
7. Include current source citations and a reference list that match exactly. Clearly distinguish peer-reviewed data, official databases, standards, vendor data, calculated values and assumptions.
8. Preserve all failed, blocked, not-run and screening-only results. Never claim a MATLAB test, GUI run, validation, code compliance or vendor guarantee without evidence.
9. The user's previous preference is for a highly detailed substantive report, typically around 150 pages or more where justified. Aim for that level only by including meaningful engineering content, calculations, datasheets, drawings, appendices and test evidence. Do not pad pages or duplicate text to achieve a count.
10. Use consistent Times New Roman or a close formal serif, readable 11–12 pt body, blue hierarchy for headings, consistent table styling, proper margins, A4 page size and clean captions. Avoid orphaned headings, table clipping, excessive blank pages and malformed equations.
11. Produce editable Word and a PDF review copy. Render the Word document and inspect cover, contents, representative technical pages, tables, appendices and final pages. Update TOC page numbers after the final render.
12. Prepare a short presentation (approximately 12–18 slides) summarising route, design basis, process, core balances, energy KPIs, equipment, automation, environment/safety, alternatives, sensitivities, economics, verification and recommendation.

**Constraints and prohibitions**
- Do not import any CPS-01 or CPS-22 engineering values, equations or conclusions unless separately justified for ENERGY-008.
- Do not report assumed performance or illustrative values as measured plant performance.
- Do not delete limitations to make the report look complete.

**Expected deliverables**
- `Report/ENERGY008_Technical_Report.docx`
- `Report/ENERGY008_Technical_Report.pdf`
- `Presentation/ENERGY008_Short_Presentation.pptx`
- Figure/table registers and bibliography
- Any source diagrams embedded as editable files in the project.

**Acceptance criteria**
All 27 assignment topics appear in order, required report contents are present, all displayed values trace to actual output or labelled assumptions, and the rendered PDF matches the Word source with correct TOC page references.

**Handoff**
Pass final documents, source bibliography, result version and render QA report to Prompt 25.

---

## PROMPT 25 — Repository Integration, Reproducibility, Final Audit and ZIP Packaging

**Objective**  
Integrate all completed work into one clean, reproducible ENERGY-008 submission package and audit it against the original assignment.

**Context and inputs**  
Use all artefacts from Prompts 1–24. Do not recreate calculations from memory or replace corrected Phase outputs with earlier versions.

**Instructions**
1. Build a clean repository tree with `README.md`, MATLAB source, optional Python source, configuration, raw/processed data, sources, calculations, results, tests, report, presentation, PFD/P&ID, flowcharts, datasheets, control/sequence documents, environmental/safety registers and logs.
2. Identify canonical latest files. Archive superseded versions in a clearly labelled archive or omit them only after recording the reason. Never silently overwrite or delete original source data.
3. Create a manifest with relative path, file size, SHA-256, purpose, source/version and verification status. Exclude the manifest itself from recursive checksum calculation or state the method.
4. Create a final requirements matrix mapping every assignment requirement to its evidence file/report section/test result and PASS/FAIL/BLOCKED/NOT RUN status.
5. Audit the final deliverables against the assignment's acceptance checklist: process boundary/basis; equations and units; all four balances (mass, energy, entropy, exergy); equipment sizing/datasheets; automation loops/HMI/alarms/interlocks/sequences; utilities/environment/waste; CAPEX/OPEX; six sensitivity variables and multivariable analysis; MATLAB architecture/GUI; verification; Python migration; report/presentation; drawings/flowcharts.
6. Run the complete documented start/test/export procedure from a fresh extraction directory if the relevant runtimes are available. Test `START_HERE.m` and ensure it works from a copied folder. If MATLAB is unavailable, mark runtime checks NOT RUN and give exact commands for later execution.
7. Check that links and paths inside README/report point to files that exist. Check archive integrity with an archive test and extraction smoke test.
8. Create an issue register with remaining data requests, vendor confirmations, code/standard reviews, process safety actions and software tests.
9. Produce an exact final contents list and handoff instructions. State what is complete, screening-only, failed, blocked or not run.

**Constraints and prohibitions**
- Do not call the project “validated”, “industrial ready”, “safe”, “compliant” or “certified” unless objective evidence supports the exact claim.
- Do not include temporary render folders, caches, unrelated older CPS projects or duplicate bulky outputs in the final ZIP.
- Do not claim archive integrity or runtime success without executing the checks.

**Expected deliverables**
- `ENERGY-008_Submission/` complete project repository
- `ENERGY-008_Submission.zip`
- `ENERGY-008_Submission_Manifest.csv`
- `ENERGY-008_Final_Compliance_Matrix.xlsx`
- `ENERGY-008_Open_Issues.md`
- `ENERGY-008_Final_Audit_Report.md`

**Acceptance criteria**
Every assignment requirement is mapped to evidence or a transparent open status. The ZIP passes integrity and extraction tests. A new user can follow the README to reproduce the default run, test it and locate every major deliverable.

**Handoff**
Provide the ZIP link, exact contents summary, execution instructions and unresolved engineering issues. Do not perform any further unrecorded changes after the final manifest is generated.

---

## 4. Execution Instructions

1. Start with **Prompt 1** in a fresh execution turn or project conversation. Attach `PSLassignment2.pdf` and `Universal_Engineering_Master_Prompt(1).txt`.
2. Run prompts manually and sequentially. Do not paste all prompts as one request; each is a stage gate.
3. At the end of each phase, inspect the deliverables and decide whether to approve, request corrections or hold. Do not proceed when an upstream acceptance criterion has failed.
4. Attach or otherwise make available the previous phase's handoff files when starting the next prompt. Keep a single canonical project directory and do not create parallel project versions.
5. For Prompt 2, approve the selected green-methanol route before design-basis freeze. For Prompt 3, approve the capacity, feed/product assumptions and case definitions. For Prompt 6, approve model choices. For Prompts 18–20, review architecture/source and actual GUI behaviour. For Prompt 21, review test status before sensitivity/optimisation and final reporting.
6. Run Prompt 24 only after the calculation and verification records are stable. The report must be written from actual results, not planned calculations.
7. Run Prompt 25 last. Retain all phase handoff documents, source datasets, raw files, test logs and manifests.

## 5. Material Assumptions and Blockers

- The green-methanol route is not fixed in the assignment; Prompt 2 must select it using a documented route comparison.
- No capacity, feed quality, product grade, site or operating conditions are supplied; Prompt 3 must create an illustrative and explicitly labelled basis.
- “Green” status needs an explicit renewable hydrogen/carbon-source and lifecycle-emissions boundary.
- Indian legal/standards applicability must be checked against current official sources; do not assume every listed authority applies.
- Full equipment, cost and safety design may require vendor data, site data, licensed tools and competent engineering review. The prompts require such limitations to remain visible.
- MATLAB runtime availability is unknown. Code can be authored without a runtime, but unexecuted tests must remain NOT RUN.
- The prior CPS-01 report is a format reference only. If it is not attached or accessible to the future execution session, reattach it. Its PR EOS calculations and hydrocarbon design basis are not transferable to ENERGY-008.
