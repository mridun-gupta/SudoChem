# ENERGY-008 Prompt 22 | Sensitivity, Uncertainty and Optimisation Screen

**Project:** ENERGY-008 Green Methanol Synthesis  
**Date:** 02 November 2026  
**Design status:** Route C remains provisional; G3 design basis Rev 0.1-DRAFT; no validated physical plant operating window  
**Model version:** ENERGY008-MODEL-0.1.0 / RXN-0.1.0 / DATA-0.1.0  
**Evidence basis:** Prompts 3–21, Prompt 17 independent hand calculations, Prompt 21 verification matrix and external technology references.

---

## 1. Executive conclusion

The Prompt 22 sensitivity deliverable contains **12 independent one-at-a-time (OAT) studies** and a **1,000-point, eight-variable deterministic Latin Hypercube Sample (LHS)**. It calculates algebraic stoichiometric/electrolyser screening quantities, selected water scenarios, and the Prompt 17 illustrative exchanger and pump examples. It does **not** execute the MATLAB engine or solve the physical process model.

**No validated or physically feasible operating window can be recommended from the available evidence.** Pressure, temperature, residence time, conversion/selectivity, catalyst performance, physical recycle/purge, product quality, plant-wide energy/exergy, equipment capacity, emissions compliance and full project economics are still blocked by missing data and unvalidated models. The LHS Pareto set is consequently a *proxy trade-off screen*, not a plant design optimum.

The Prompt 21 acceptance gap for sensitivity breadth is addressed at the **screening tier**: 12 OAT variables and one multivariable method are now documented. It is not promoted to a PASS for physical process optimisation. Route A remains a common downstream-core comparison only, and Route B biomass syngas remains BLOCKED; a complete base-plus-two-alternative comparison has not been achieved.

### Principal findings (base reference screen)

The 50 t/day ideal stoichiometric reference, using 55 kWh/kg H₂ system electricity, ₹5/kWh, an assumed 0.40 kg CO₂e/kWh electricity factor, and an assumed total water intensity of 50 L/kg H₂, gives:

| Metric | Result | Status / boundary |
|---|---:|---|
| Methanol component-equivalent | 50 t/on-stream day | Assumed reference basis, not plant capacity |
| CO₂ lower-bound component flow | 68.675 t/day | Ideal stoichiometry |
| H₂ lower-bound flow | 9.437 t/day | Ideal stoichiometry |
| Direct electrolysis feedwater | 84.336 t/day (about 84.34 m³/day) | Stoichiometric feedwater only |
| Electrolyser electricity intensity | 10.381 kWh/kg MeOH | Screening only; H₂-system SEC only |
| Electrolyser electric load | 21.627 MW | Screening only; compression and downstream loads excluded |
| Annual electricity at 300 operating days | 155.712 GWh/year | Scenario annualisation |
| Electricity-only variable cost contribution | ₹51.90/kg MeOH | Excludes all other OPEX and CAPEX |
| Electricity-related emissions | 4.152 kg CO₂e/kg MeOH | Assumed CI; not regulatory or lifecycle intensity |
| Total electrolysis water scenario | 471.85 m³/on-stream day | 50 L/kg H₂ total feedstock plus cooling scenario |

The direct stoichiometric water figure is contained within the IEA total-water scenario and **must not be added to it**. The 50 L/kg H₂ value is the scenario midpoint of a 30–70 L/kg H₂ total feedstock-plus-cooling range.

---

## 2. Evidence and method status

### Status vocabulary

- **SCREENING ONLY:** a numerical result follows a transparent algebraic equation or an explicit scenario assumption, but does not establish process feasibility or validated plant performance.
- **BLOCKED:** required process data, property parameters, equipment limits or model validation are absent. Values remain null.
- **NOT RUN:** a required runtime execution was not performed.
- **PASS (arithmetic/source assertion):** only applies to the explicitly stated independent arithmetic/source check. It does not establish physical-model validity.

MATLAB and GNU Octave were unavailable during Prompt 21. Prompt 22 calculations in this package were independently implemented as Python closed-form equations and verified in workbooks. There is no claim that MATLAB sensitivity or optimisation routines ran, and no process solver convergence is claimed.

### Calculation scope

The numerical boundary is limited to:
1. R-01 ideal stoichiometric methanol component-equivalent feed demand.
2. ALK hydrogen production electricity, using an explicit system-specific-electricity scenario.
3. Electricity-only variable cost and electricity-related emissions contributions.
4. Electrolyser water scenarios.
5. Conditioned dry gas molar flow from a CO₂ purity fraction.
6. Prompt 17 pure-CO₂ ideal-gas sensible duty and illustrative HX area.
7. Prompt 17 water-pump hydraulic example, with design-flow margin varied separately from duty power.

The following are not solved: source-gas recovery, source-specific contaminant removal, electrolyser vendor polarization/BOP map, hydrogen compression, synthesis reactor, flash/VLE, recycle/purge, distillation, plant utilities, entropy/exergy closure, full emissions inventory, CAPEX, full OPEX and levelised cost.

---

## 3. One-at-a-time sensitivity programme

All OAT calculations vary one input while keeping the other reference inputs fixed. All points are labelled **SCREENING ONLY**. The closed-form calculations have no iterative convergence requirement; their solver/convergence field is “not applicable”. That is not a successful process-model convergence flag.

**Fixed reference inputs across OAT studies:** 50 t/on-stream day; SEC 55 kWh/kg H₂; tariff ₹5/kWh; electricity CI 0.40 kg CO₂e/kWh; 300 operating days/year (82.19% of 365); fresh H₂/CO₂ = 3.00 mol/mol; dry CO₂ purity 99.5 mol%; total water intensity 50 L/kg H₂; HX U = 100 W/m²/K; LMTD = 30 K; pump head = 50 m; pump efficiency = 70%; pump flow margin = 10%; heat recovery = 25%. For each study, only the named variable changes.

| ID | Independent variable | Values / range | Output metrics | Range basis and applicability |
|---|---|---|---|---|
| S01 | Throughput | 45, 50, 55 t/day | Stoichiometric component rates, electrolyser MW and annual methanol/electricity | Existing Prompt 17/19 reference points; not a capacity envelope |
| S02 | ALK system SEC | 48, 52, 55 kWh/kg H₂ | Specific electricity, MW, electricity-only cost and emissions | DOE system status/target/ultimate target ladder; targets are not vendor guarantees |
| S03 | Electricity tariff | ₹3, ₹5, ₹8/kWh | Electricity-only INR/kg, INR/t and annual electricity spend | Assumed low/mid/high scenarios because no site tariff/PPA is supplied |
| S04 | Electricity carbon intensity | 0.05, 0.40, 0.80 kg CO₂e/kWh | Electricity-related emissions per kg and annual emissions | Assumed supply scenarios; no PPA attribute or project-specific emission factor |
| S05 | Annual operating availability | 80%, 82.19%, 95% | Annual methanol, electricity, electricity spend and water | 300 days/year is implied by 15,000 t/year ÷ 50 t/day; 80–95% is assumed |
| S06 | Fresh H₂/CO₂ ratio | 3.00, 3.15, 3.30 mol/mol | Gross H₂ equivalent, MW, electricity intensity/cost/emissions | 3.00 is R-01 stoichiometry; +5/+10% are feed stress cases with no recycle credit |
| S07 | Conditioned CO₂ dry purity | 99.0%, 99.5%, 100.0 mol% | Total conditioned dry gas molar flow for fixed pure CO₂ demand | Design basis 99.5 mol% assumed screening target with ±0.5 mol% variation; impurity identity is unknown |
| S08 | Total water intensity | 30, 50, 70 L/kg H₂ | Total water demand per on-stream day and year | IEA 2024 feedstock-plus-cooling water range |
| S09 | HX overall U | 75, 100, 125 W/m²/K | Area for fixed 168.854 kW pure-CO₂ example at 30 K LMTD | ±25% stress around Prompt 17 assumed U=100 |
| S10 | HX LMTD | 20, 30, 40 K | Area for same fixed duty at U=100 W/m²/K | ±10 K stress around Prompt 17 assumed LMTD=30 K |
| S11 | Pump design-flow margin | 0%, 10%, 20% | Capacity and power at margin flow | Prompt 17 uses 10% allowance; hydraulic network and vendor curve remain absent |
| S12 | Heat recovery fraction | 0%, 25%, 50% | Recovered and residual share of the 168.854 kW reference duty | Hypothetical fraction on one pure-component duty only; not whole-plant heat integration |

### Selected OAT effects

- **Throughput:** 45–55 t/day changes the calculated electrolyser load from 19.464 to 23.789 MW, linearly. At 300 operating days, annual component-equivalent output is 13,500–16,500 t/year. This proves arithmetic scaling only.
- **ALK SEC:** 48–55 kWh/kg H₂ changes specific electricity from 9.060 to 10.381 kWh/kg MeOH and the calculated electrolyser load from 18.874 to 21.627 MW.
- **Tariff:** ₹3–8/kWh changes the electricity-only contribution from ₹31.14 to ₹83.05/kg MeOH, with all other inputs fixed.
- **Electricity carbon intensity:** 0.05–0.80 kg CO₂e/kWh changes the electricity-related emission contribution from 0.519 to 8.305 kg CO₂e/kg MeOH. This is not a regulatory GHG calculation.
- **Availability:** 80–95% changes annual methanol component-equivalent from 14,600 to 17,337.5 t/year at 50 t/on-stream day. Specific energy per tonne does not change in this static formulation.
- **H₂/CO₂ ratio:** 3.00–3.30 increases gross H₂ equivalent and electricity by 10% at the upper point. No recycle, recovery or benefit from excess H₂ is modelled, so this is not an operating-ratio recommendation.
- **CO₂ purity:** 99.0–100.0 mol% changes total conditioned dry-gas flow from 1,576.219 to 1,560.457 kmol/day. This does not calculate contaminant removal duty or poisoning risk.
- **Water:** 30–70 L/kg H₂ changes total water demand from 283.112 to 660.596 m³/on-stream day. This is total feedstock-plus-cooling water and includes the electrolysis feedwater component.
- **HX U:** 75–125 W/m²/K changes illustrative area from 75.046 to 45.028 m² at fixed duty and LMTD.
- **HX LMTD:** 20–40 K changes illustrative area from 84.427 to 42.214 m² at fixed duty and U.
- **Pump margin:** 0–20% changes design capacity from 3.525 to 4.229 m³/h. Duty shaft power remains 0.683743 kW; power at the margin flow scales to 0.820492 kW at 20%. At the 10% point, design capacity is 3.877 m³/h and margin-flow power is 0.752117 kW.
- **Heat recovery:** 0–50% of the reference duty corresponds to 0–84.427 kW recovered and 168.854–84.427 kW residual. The service is not a selected plant exchanger.

All detailed points, fixed values, units, and statuses are in `ENERGY008_Sensitivity_Results.xlsx`.

---

## 4. Multivariable method: deterministic Latin Hypercube

A 1,000-point Latin Hypercube was constructed with NumPy random seed `20261102`. Eight independent uniform input ranges were sampled:

| Input | Minimum | Maximum | Distribution / provenance |
|---|---:|---:|---|
| Throughput | 45 | 55 t/day | Prompt 17 reference points |
| ALK system SEC | 48 | 55 kWh/kg H₂ | DOE system status/target ladder |
| Electricity tariff | 3 | 8 INR/kWh | Assumed scenario |
| Electricity carbon intensity | 0.05 | 0.80 kg CO₂e/kWh | Assumed scenario |
| Annual availability | 0.80 | 0.95 | Assumed scenario; base annualisation is 300/365 |
| Fresh H₂/CO₂ ratio | 3.00 | 3.30 mol/mol | Stoichiometric minimum plus excess-feed stress |
| Total water intensity | 30 | 70 L/kg H₂ | IEA range |
| CO₂ dry purity | 0.990 | 1.000 mol fraction | Assumed 99.5% target ±0.5 percentage point |

The chosen proxy objectives are:
1. Minimise electricity-only variable cost contribution, INR/kg methanol.
2. Minimise electricity-related emissions, kg CO₂e/kg methanol.

The outputs are calculated as:

\[
m_{H_2}/m_{MeOH} = \frac{r_{H_2/CO_2}\,MW_{H_2}}{MW_{MeOH}}
\]

\[
e_{MeOH} = (m_{H_2}/m_{MeOH})\;SEC
\]

\[
C_{elec} = e_{MeOH}\;p_{elec}
\qquad
G_{elec} = e_{MeOH}\;CI_{elec}
\]

Annual output, energy, electricity cost and water scale with the selected on-stream throughput and availability. CO₂ gross dry-gas flow scales with 1/purity.

The LHS uses independent uniform inputs because there is no measured joint distribution, covariance matrix, vendor uncertainty set or site history. Its P05/P50/P95 output percentiles are therefore **conditional scenario quantiles**, not statistical confidence intervals or prediction intervals. The LHS has no plant solver, recycle convergence or equipment capacity check.

### Conditional LHS output intervals

| Output | P05 | P50 | P95 | Interpretation |
|---|---:|---:|---:|---|
| Specific electricity | 9.440 | 10.179 | 11.037 kWh/kg MeOH | Electrolyser-only screen |
| Electricity-only cost contribution | ₹33.14 | ₹55.96 | ₹79.78/kg MeOH | Variable electricity only |
| Electricity-related emissions | 0.878 | 4.329 | 7.833 kg CO₂e/kg MeOH | Power emissions only |
| Electrolyser load | 18.679 | 21.217 | 23.930 MW | H₂ production system scenario |
| Annual methanol | 13,936 | 15,934 | 17,960 t/year | Assumed throughput/availability |
| Annual electricity | 139.332 | 162.257 | 187.285 GWh/year | Electrolyser-system scenario |
| Annual electricity cost | ₹518.7 | ₹890.8 | ₹1,308.2 million/year | Electricity only |
| Total water | 315.604 | 491.296 | 684.572 m³/on-stream day | Feedstock plus cooling scenario |

These intervals should not be transferred to final plant design, bankability, regulatory reporting or guaranteed production.

---

## 5. Multivariable proxy optimisation and Pareto interpretation

The LHS generated 11 sampled non-dominated points for the two proxy objectives. The sampled points illustrate a cost/emissions trade-off created by independently varying tariff and electricity carbon intensity.

- Lowest electricity-only cost observed in the 1,000 samples: **₹28.50/kg MeOH**, with **1.407 kg CO₂e/kg MeOH** electricity-related emissions.
- Lowest electricity-related emissions observed in the 1,000 samples: **0.489 kg CO₂e/kg MeOH**, with **₹57.49/kg MeOH** electricity-only cost.
- Base reference screen: **₹51.90/kg MeOH** and **4.152 kg CO₂e/kg MeOH** under the stated central assumptions.

These are the best observed *sample points* for the proxy objective, not global optima. The frontier is especially sensitive to the assumed tariff and carbon-intensity ranges. No correlation between low-carbon power and tariff was established.

### Optimisation constraints and exclusions

Only the LHS assumption ranges and positive algebraic flow constraints were applied. The following required engineering constraints are not numerically evaluable and were **not** silently treated as satisfied:

- Methanol product purity ≥99.85 wt% and water/impurity specifications.
- Reactor temperature, pressure, residence time and catalyst thermal limits.
- Validated pressure drop, compressor surge, pump NPSH, exchanger duty/approach and equipment capacity.
- Renewable electricity availability, hourly matching, firming/storage, ramp and minimum-load limits.
- Water source yield, permitted abstraction, treatment recovery and seasonal availability.
- HAZOP/LOPA-derived safeguards and approved operating limits.
- Route-specific CO₂ capture/recovery, biomass and syngas constraints.
- Full CAPEX, OPEX, replacements, financing and levelised methanol cost.

Consequently the “Pareto front” is a **screening proxy frontier**, not a feasible plant Pareto frontier. It does not support a chosen optimum, route ranking or safe operating setpoint.

---

## 6. Energy KPI and economics sensitivity ranking

Spearman rank association within the independent LHS sample gives the following dominant input associations:

| Output metric | Largest rank associations (Spearman ρ) | Interpretation in this algebraic screen |
|---|---|---|
| Specific electricity | ALK SEC +0.820; H₂/CO₂ ratio +0.528 | SEC and gross H₂ demand dominate specific electricity |
| Electricity-only cost/kg | Tariff +0.985; SEC +0.138; H₂/CO₂ +0.099 | Electricity tariff dominates this partial cost |
| Electricity-related emissions/kg | Electricity CI +0.995; SEC +0.107; H₂/CO₂ +0.058 | Power carbon factor dominates this partial emissions result |
| Annual electricity | Throughput +0.650; uptime +0.542; SEC +0.441; H₂/CO₂ +0.274 | Annual energy follows capacity, on-stream days and SEC |
| Total water/on-stream day | Water intensity +0.966; throughput +0.216; H₂/CO₂ +0.067 | Water intensity dominates the water scenario |

These rank values reflect the selected equations and independent sample ranges, not validated physical causality. Pressure, temperature, residence time, catalyst activity, conversion, selectivity and heat integration were not represented in the LHS and therefore cannot be ranked.

### Uncertainty treatment

Numerical scenario ranges are quantified for throughput, ALK SEC, tariff, power CI, uptime, H₂/CO₂ feed ratio, CO₂ purity and total water intensity. The following uncertainties remain unquantified: source CO₂/H₂ impurities, catalyst performance and lifetime, conversion/selectivity, reactor duty, PR78 interaction parameters, methanol-water VLE, recycle/purge, full thermal duties, equipment/vendor margins, cost indices, replacements, site water and source-specific upstream emissions.

Prompt 17 HX U and LMTD and pump head/efficiency are stress assumptions, not statistical uncertainty distributions. The ±25% U and ±10 K LMTD studies do not establish a vendor uncertainty interval. The 10% pump allowance is a design-basis screening margin only.

---

## 7. Base and alternative comparison

All route cases use a common comparison basis of 50 t/day methanol component-equivalent, the academic product target of at least 99.85 wt% methanol, and the same product dispatch boundary. Annualisation is 300 on-stream days/year. The product grade is not calculated in any route.

### Route C base and Alternative 1 (Route A)

Route C (biogenic CO₂ + renewable ALK H₂) and Route A (industrial CO₂ + renewable ALK H₂) share the same ideal downstream CO₂-to-methanol reaction core. Therefore, only the common-core theoretical flows and ALK electricity contribution can be compared numerically:

- CO₂: 68.675 t/day pure component lower bound.
- H₂: 9.437 t/day stoichiometric lower bound.
- Direct electrolyser feedwater: 84.336 t/day by stoichiometry.
- ALK-system electricity: 10.381 kWh/kg methanol and 21.627 MW at the central SEC assumption.
- Electricity-only cost: ₹51.90/kg at assumed ₹5/kWh.
- Electricity-related emissions: 4.152 kg CO₂e/kg at assumed 0.40 kg CO₂e/kWh.

These are not route-specific upstream capture, compression, purification, utility or economics results. Route A capture energy and carbon origin are unknown; Route C biogenic source continuity, purity and chain of custody are unknown. The two routes cannot be ranked on this basis.

### Alternative 2 (Route B biomass syngas)

Route B remains **BLOCKED**. The biomass assay, moisture/ash, gasifier yield, syngas composition, tar/char, cleanup duty, contaminant limits, catalyst-grade specification and route-specific kinetics are missing. Route B uses a different syngas-to-methanol reaction network; Route C CO₂/H₂ stoichiometric flows must not be transferred to it. No numerical power, water, heat, CAPEX/OPEX or emissions result is claimed.

### Economics and environmental limits

Full CAPEX, full OPEX and levelised methanol cost are **BLOCKED for all three routes**. Only the electricity-only variable cost contribution is quantified for the common ALK H₂ sub-system. No oxygen sales credit is taken. No full plant carbon-utilisation, GHG compliance, MRV or exergy benefit is calculated.

---

## 8. Operating-window recommendation

### Recommendation

**Do not issue or publish a plant operating window or selected optimum from Prompt 22.** The physical model is not validated and the engineering constraints needed to establish feasibility are unavailable.

For continuation of academic calculations only, retain the following as a **reference-screening envelope**, not as an operating window:

- Throughput: 45–55 t/on-stream day reference cases around the 50 t/day illustrative base.
- Fresh H₂/CO₂: 3.00 mol/mol stoichiometric lower-bound anchor; 3.15 and 3.30 are gross feed stress cases only, with no recycle credit.
- Conditioned CO₂ purity: 99.5 mol% dry assumed target, with 99.0–100.0 mol% sensitivity; actual source and contaminant acceptance remain open.
- ALK specific electricity: 48–55 kWh/kg H₂ scenario bracket based on DOE status/target references; obtain an OEM-guaranteed system map and define whether compression/BOP are inside its boundary.
- Electricity price and carbon intensity: keep as site/PPA inputs, not fixed recommendations.
- Total water: 30–70 L/kg H₂ scenario; obtain a site water balance and separately report feedwater, cooling makeup, recycle, reject and withdrawal.
- Draft 7 MPa(a) and 250 °C synthesis anchors remain **screening assumptions**, not approved pressure/temperature limits or setpoints.

This screening envelope does not clear reactor kinetics, phase behaviour, safety, product grade, equipment, power availability or water availability. It cannot be interpreted as a safe or feasible operating range.

### Gates required before true process optimisation

1. Freeze the route/G3 basis and approve the site, feed source, product boundary and design capacity.
2. Obtain source-specific biogenic/industrial CO₂ assays, H₂ quality and renewable power attributes.
3. Obtain the electrolyser OEM system map (SEC, pressure, purity, turndown, degradation, BOP and ramp behaviour).
4. Freeze catalyst formulation and matched kinetic parameters; independently validate conversion/selectivity and reactor heat removal.
5. Complete PR78 binary parameters, methanol-water VLE, flash and physical recycle/purge.
6. Close material, energy, entropy and exergy balances for all physical streams.
7. Obtain equipment limits, utility guarantees, water-source limits, cost quotations and dated cost indices.
8. Re-run the GUI/MATLAB regression and independently verify the solver in a supported MATLAB release.
9. Re-run multivariable optimisation on the validated model with product, pressure, temperature, equipment, renewable-power, water and safety constraints.

---

## 9. Handoff to Prompt 23 / final report

### Permitted downstream use

- Prompt 17/21 stoichiometric values may be quoted as ideal reference arithmetic.
- Prompt 22 OAT values may be quoted as explicitly labelled screening sensitivities.
- LHS P05/P50/P95 may be quoted only as conditional scenario quantiles under the independent uniform ranges and seed listed here.
- The 11 sampled Pareto points may be displayed only as an exploratory electricity-cost/electricity-emissions proxy frontier.
- Route C/Route A common-core arithmetic may be shown side-by-side, but not used to rank the upstream routes.

### Prohibited downstream claims

Do not claim a validated operating window, optimised reactor setpoints, verified plant utilities, full energy efficiency, exergy efficiency, emissions compliance, CAPEX, full OPEX, LCOM or a selected route. Do not describe Route B as evaluated. Do not report MATLAB sensitivity/GUI runtime testing.

### Included evidence files

- `ENERGY008_Sensitivity_Plan.xlsx`
- `ENERGY008_Sensitivity_Results.xlsx`
- `ENERGY008_Uncertainty_Analysis.xlsx`
- `ENERGY008_Alternative_Comparison.xlsx`
- `Plots/*.png`
- `Prompt22_Calculation_Method.py`
- `ENERGY008_Prompt22_Handoff.md`

---

## 10. References

1. U.S. Department of Energy, *Technical Targets for Liquid Alkaline Electrolysis*. The system electricity values shown are 55 kWh/kg H₂ (2022 status), 52 (2026 target) and 48 (ultimate target). Targets are not OEM guarantees.  
   https://www.energy.gov/cmei/fuels/technical-targets-liquid-alkaline-electrolysis

2. International Energy Agency, *Global Hydrogen Review 2024*, water section. It reports approximately 10 L/kg H₂ feedwater and 30–70 L/kg H₂ total water for feedstock plus cooling, depending on technology and climate.  
   https://iea.blob.core.windows.net/assets/89c1e382-dc59-46ca-aa47-9f7d41531ab5/GlobalHydrogenReview2024.pdf

3. IRENA, *Technology Innovation Indicators 2022*. Reports average AEL electricity use around 52 kWh/kg H₂ as corroborative technology context; not a project-specific guarantee.  
   https://www.irena.org/-/media/Files/IRENA/Agency/Publication/2022/Mar/IRENA_Tech_Innovation_Indicators_2022_

4. ENERGY-008 Prompt 3, `ENERGY008_Design_Basis.xlsx`, Rev 0.1-DRAFT: scale, annual equivalent, feed/product screening targets, boundaries and unresolved inputs.

5. ENERGY-008 Prompt 17, `ENERGY008_Manual_Calculation_Workbook.xlsx`, `ENERGY008_Hand_Calculation_Report.md` and `ENERGY008_Independent_Checks.csv`: stoichiometric reference and illustrative heat/hydraulic examples.

6. ENERGY-008 Prompt 19, `MATLAB/data/default_case.json`, `sensitivity_plan_v0.1.0.json`, `property_data_v0.1.0.json`, `reaction_network_v0.1.0.json`: source-controlled baseline and current model blockers.

7. ENERGY-008 Prompt 21, `ENERGY008_Verification_Matrix.xlsx`, `ENERGY008_Independent_Comparison.xlsx` and `Prompt22_Handoff.md`: independent verification disposition and limitations.
