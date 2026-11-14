# ENERGY-008 Model Assumptions, Selection and Validity

**Document:** ENERGY008-MAV-0.1  
**Model version:** `ENERGY008-MODEL-0.1.0`  
**Reaction network version:** `ENERGY008-RXN-0.1.0`  
**Property data version:** `ENERGY008-DATA-0.1.0`  
**Date:** 1 November 2026  
**Route:** Route C, biogenic CO₂ + renewable electrolytic H₂, ALK reference  
**Approval status:** Provisional modelling basis. Formal route-selection approval is not evidenced in the prior route/design-basis files. G3 design basis remains Rev 0.1-DRAFT.

---

## 1. Executive model decisions

| Model block | Governing provisional choice | Why | What remains blocked |
|---|---|---|---|
| Reaction network | CO₂ hydrogenation + RWGS; electrolysis as separate H₂ generation subsystem | These are the two independent synthesis reactions for the CO₂-rich route, plus net water electrolysis | Actual feed composition and measured impurities |
| Stoichiometry | Three independent reactions in integrated network: CO₂-to-MeOH, RWGS, electrolysis | Exact integer matrix rank and C/H/O closure are verified | Trace-element species balances await feed assay |
| Reactor | 1-D pseudo-homogeneous, non-isothermal packed-bed PFR | Matches the fixed-bed plug-flow kinetic evidence and supports axial composition, temperature and pressure profiles | Reactor hardware, catalyst formulation, heat-transfer geometry, pellet size and coolant boundary |
| Kinetics | Mbatha et al. 2023 MOD LHHW model structure, conditional on catalyst match to Cu/ZnO/Al₂O₃/MgO | Experimental data span 210–260 °C, 40–77 bar and H₂/CO₂ ratios 3.0–4.4; the draft 250 °C / 70 bar / 3:1 anchor lies within this reported test envelope | Draft catalyst is only described as generic CZA; MgO formulation is not approved; parameters are not part of the frozen data layer |
| Kinetic fallback | van Schagen et al. 2025 seven-parameter CZA model | Based on 1,470 data points and CZA formulation, closer to the generic catalyst family presently named | Full parameter/data package is available on request; exact validity domain and methanol/water-feed treatment must be confirmed |
| Thermodynamics | PR78 with classical vdW one-fluid mixing as the lead EOS candidate; modified SRK as cross-check | PR was used in a validated methanol synthesis miniplant loop; SRK has a published high-pressure simultaneous phase/chemical equilibrium application | Complete, source-matched binary parameter matrix and phase validation |
| Product distillation | Low-pressure gamma-phi model with Wilson as lead liquid model; NRTL as comparator | Direct methanol-water ThermoML data are represented by Wilson at 95.3 kPa and sub-atmospheric pressures | Column pressure not selected; Wilson/NRTL parameters not regressed |
| ALK electrolyser | Faraday production + vendor voltage/performance map + explicit BOP | Prevents inventing fixed system efficiency and separates stack from plant auxiliaries | OEM curve, pressure, purity, Faradaic efficiency, ramp, minimum load, degradation and BOP |
| Gas cleanup/compression | Component-removal balance plus supplier performance/pressure-drop data; real-gas compressor model | Cleanup performance is source- and catalyst-specific; compression depends on real-fluid enthalpy | Raw CO₂ assay, contaminant limits, source conditions and vendor maps |

**Nothing in this document selects a commercial reactor vessel, catalyst grade, electrolyser model, compressor, column design or relief-system design.**

## 2. Route and data-version control

### 2.1 Route C is a working basis, not a closed feasibility decision

The Prompt 2 route report recommends Route C as the preferred academic reference route, but also states that a continuous, traceable and economically recoverable biogenic CO₂ source is a hard feasibility gate. The Prompt 3 design-basis Control sheet says the route-selection gate response was not explicitly recorded and G3 is not frozen.

Therefore:
- use Route C only as the current model-development basis;
- do not describe the route as formally approved;
- retain Route A as the fallback if a bankable biogenic source cannot be evidenced;
- do not reuse Route C reaction or feed assumptions for Route B biomass gasification.

### 2.2 Design values are draft inputs, not frozen model conditions

The Prompt 3 Rev 0.1-DRAFT basis contains 7 MPa(a), 250 °C and 50 t/day as assumptions/illustrative selections. They are used here only for a range-screening comparison. They are not equipment design conditions or operating guarantees. The fresh H₂/CO₂ value of 3:1 is a reaction stoichiometric anchor; actual synthesis-loop composition will include recycle and may include CO, H₂O, methanol, inert gases and measured traces.

### 2.3 Prompt 5 data limits

The frozen Prompt 5 dataset contains pure-component reference data and correlations, but:
- no complete CO₂/H₂/CO/MeOH/H₂O EOS;
- no complete binary interaction parameter matrix;
- no validated synthesis-loop flash or phase-stability model;
- no numerical methanol-water VLE fit;
- no state-specific transport properties;
- no vendor electrolyser map;
- no source gas assay or catalyst impurity specification.

All missing values remain null/blocked. This document proposes methods and validation gates; it does not populate missing parameters.

## 3. Reaction network and stoichiometric independence

### 3.1 Independent synthesis reactions

**R-01: CO₂ hydrogenation to methanol**

\[
\mathrm{CO_2 + 3H_2 \rightleftharpoons CH_3OH + H_2O}
\]

**R-02: reverse water-gas shift**

\[
\mathrm{CO_2 + H_2 \rightleftharpoons CO + H_2O}
\]

For an equilibrium calculation, write activities/fugacities using one consistent standard state. For the reactor state, methanol and water are treated as real-fluid species; the gas-standard-state reaction is used only to formulate equilibrium functions. Do not use the liquid-product Prompt 5 standard reaction enthalpy as the reactor heat release.

### 3.2 Electrolysis subsystem

Net alkaline water electrolysis:

\[
\mathrm{2H_2O(l) \rightarrow 2H_2(g) + O_2(g)}
\]

Alkaline half-reactions can be written as:

Cathode:
\[
\mathrm{2H_2O + 2e^- \rightarrow H_2 + 2OH^-}
\]

Anode:
\[
\mathrm{2OH^- \rightarrow \tfrac12 O_2 + H_2O + 2e^-}
\]

The net stoichiometry is included in the integrated plant matrix, but the electrochemical rate/voltage/power model is a separate subsystem.

### 3.3 CO hydrogenation is dependent, not an independent net reaction

\[
\mathrm{CO + 2H_2 \rightleftharpoons CH_3OH}
\]

For species order \([CO_2,H_2,CO,CH_3OH,H_2O,O_2]\):

\[
\nu_{CO-H_2} = \nu_{CO_2-MeOH} - \nu_{RWGS}
\]

The CO hydrogenation vector is therefore linearly dependent on R-01 and R-02. Adding it as an independent extent would make the reaction network over-parameterised and could double-count methanol formation. The selected high-CO₂ MOD kinetic model also excludes direct CO hydrogenation while accounting for CO adsorption. A separate CO-hydrogenation rate should only be added if a different feed/catalyst system is selected and validated with suitable experiments.

### 3.4 Stoichiometric rank and elemental conservation

The integrated independent reaction set is R-01, R-02 and E-01. Exact integer arithmetic gives:
- rank of the three independent columns: **3**;
- rank after appending dependent CO hydrogenation: **3**;
- C, H and O elemental residual for every reaction column: **zero**.

The detailed matrices and element-check table are in `ENERGY008_Reaction_Network.xlsx`.

### 3.5 Trace elements

Sulfur, nitrogen, silicon and halides are not assigned unsupported reaction chemistry. Once the actual biogenic CO₂ assay is available, maintain separate elemental ledgers for:
- sulfur: feed, treated gas, purge/off-gas, guard bed/spent adsorbent, wastewater and solid waste;
- nitrogen: N₂/inert, NH₃/HCN if measured, purge and condensate;
- silicon: siloxanes, guard media and spent media;
- halides: gas, condensate, adsorbent and waste;
- source organic carbon: only species confirmed by assay.

No trace-element balance may disappear into an unlabelled “impurity” lump.

## 4. Reactor representation

### 4.1 Provisional selection

Use a **one-dimensional pseudo-homogeneous, non-isothermal packed-bed plug-flow reactor (PFR)** as the governing academic reactor representation.

The PFR species balance on catalyst mass is:

\[
\frac{dF_i}{dW_{cat}} = \sum_j \nu_{ij}r_j
\]

where \(F_i\) is component molar flow [mol/s], \(W_{cat}\) is catalyst mass [kg_cat], and \(r_j\) is rate [mol/(kg_cat·s)].

The pseudo-homogeneous assumption treats gas and catalyst pellet as locally thermally equilibrated for the first model. It does not prove the absence of intra-pellet temperature/concentration gradients or radial hot spots.

### 4.2 Why not equilibrium-only as the reactor model

An equilibrium model is useful as:
- a thermodynamic upper/lower bound;
- a consistency check for K(T), fugacity and reaction direction;
- a check on how pressure, temperature and feed ratio shift the equilibrium.

It is not adequate to predict finite-rate conversion, catalyst inventory, residence time, hot-spot behaviour, pressure drop or reactor volume. Therefore, equilibrium is **not** the primary reactor model.

### 4.3 Kinetic model candidate and pressure-range correction

The Prompt 4 data-gap note originally identified the classic Graaf and Vanden Bussche–Froment kinetic datasets as extending only to approximately 50–51 bar. Subsequent route-specific research found a more relevant source:

- Mbatha et al. (2023) studied Cu/ZnO/Al₂O₃/MgO catalyst in an isothermal fixed-bed PFR;
- temperature range: 210–260 °C;
- pressure range: 40–77 bar;
- H₂/CO₂ ratio: 3.0–4.4;
- the proposed MOD model has nine parameters, three active site families and includes CO adsorption while excluding direct CO hydrogenation;
- the newly generated high-GHSV subset used 516,000–774,000 h⁻¹ and mostly produced differential-condition CO₂ conversions below 10%; the paper also compared the model with other literature datasets.

The draft 250 °C, 70 bar and 3:1 fresh stoichiometric anchor lie within the cited temperature, pressure and H₂/CO₂ ratio envelope. The actual ENERGY-008 GHSV, recycle composition, methanol/water content and catalyst formulation are not known. This improves the kinetic evidence situation but does **not** close the gap because the Prompt 3 catalyst description is generic CZA and does not approve the MgO-containing formulation or catalyst grade. Do not claim the MOD model validates a different catalyst or an unknown plant GHSV.

A 2025 seven-parameter kinetic model for Cu/ZnO/Al₂O₃ uses 1,470 data points and is closer to the generic CZA family named in the design basis. Its parameter/data package is available on request, and the paper notes further work is needed for methanol and water in the feed. Since reactor recycle may contain residual methanol/water, that limitation is relevant.

**Selection:** MOD LHHW is the provisional governing kinetic structure if the catalyst formulation is confirmed as matching CZA/MgO and the exact parameter table is obtained. If the project retains CZA without MgO, obtain and assess the 2025 CZA model parameters instead. Until that decision is made, numerical kinetic rates remain blocked.

### 4.4 Thermal representation

The first reactor equation should use total species enthalpy flow, including formation and sensible contributions:

\[
\frac{d}{dW_{cat}}\left(\sum_i F_i h_i(T,P,y)\right)
=-q'_{removed}
\]

For distributed heat removal:

\[
q'_{removed}=U a'_{cat}(T_g-T_c)
\]

A coupled coolant energy balance can be added when coolant flow and geometry are available.

**No separate \(-r_j\Delta H_{r,j}\) term should be added to the total-enthalpy formulation above.** Doing so would count chemical enthalpy change twice. The alternative formulation is a sensible-enthalpy balance with one explicit reaction-heat term, with exactly the same reference-state and phase convention.

### 4.5 Pressure drop and transport checks

Use the Ergun packed-bed equation as the first pressure-drop correlation only after catalyst particle size, bed voidage, flow, density and viscosity are available. Integrate it with local pressure-dependent density/viscosity. Check whether gas compressibility and non-spherical pellet corrections matter.

Before assuming intrinsic kinetics apply directly at plant scale:
- evaluate Weisz–Prater internal-diffusion criterion;
- evaluate Mears external mass-transfer criterion;
- compare an effective-pellet model if either criterion is not small;
- obtain catalyst geometry, porosity, tortuosity, diffusivity and supplier data.

No effectiveness factor is set to one by default. No pressure-drop result is calculated in this phase.

## 5. Thermodynamic equilibrium and kinetic coupling

For each independent synthesis reaction \(j\):

\[
K_j(T)=\exp\left[-\frac{\Delta_rG_j^\circ(T)}{RT}\right]
\]

\[
Q_j=\prod_i\left(\frac{f_i}{f^\circ}\right)^{\nu_{ij}},
\qquad \ln Q_j=\sum_i\nu_{ij}\ln(f_i/f^\circ)
\]

\[
\ln Q_j-\ln K_j(T)=0 \quad \text{at equilibrium}
\]

Use the same species standard-state convention and phase in \(\Delta_rG^\circ(T)\), fugacity/activity expressions and equilibrium quotient. A kinetic model's published partial-pressure convention must not be changed to fugacity without refitting or revalidation.

The Prompt 5 dataset lacks a complete gas-phase methanol standard Gibbs/formation basis at the reactor standard state and a validated EOS. Therefore no numerical \(K_p(T)\), equilibrium conversion or fugacity quotient is generated here.

## 6. Hydrogen production model

The governing electrolysis model is:

1. net stoichiometry from E-01;
2. Faraday-law material production;
3. cell polarisation relation;
4. stack, rectifier and BOP power split;
5. water demand and reject/reuse ledger;
6. H₂/O₂ crossover and product purity;
7. stack heat balance;
8. degradation/availability only when supported by supplier or test data.

Faraday law:

\[
\dot n_{H_2}=\frac{N_{cell}\eta_F I}{2F},
\qquad
\dot n_{O_2}=\frac{N_{cell}\eta_F I}{4F}
\]

Cell voltage:

\[
V_{cell}=E_{rev}+\eta_{act,a}+\eta_{act,c}+\eta_{ohm}+\eta_{conc}
\]

Stack DC power:

\[
P_{DC,stack}=N_{cell} I V_{cell}
\]

System AC power can be represented as:

\[
P_{AC,system}=\frac{P_{DC,stack}}{\eta_{rectifier}}+P_{BOP}
\]

Keep H₂ compression outside the electrolyser-system boundary unless the chosen vendor guarantees it inside that boundary. If included, state it exactly once.

For an empirical system model, use a vendor curve \(P=f(\dot m_{H2},T,P,\text{load})\) and record the stack/BOP boundary. Do not substitute a single generic kWh/kg value for an OEM guarantee. ALK is the reference configuration; PEM remains a flexibility alternative, not the selected baseline.

O₂ is a coproduct, not a credited product. Product quality, H₂ crossover, moisture, compression, storage and safe handling remain unverified.

## 7. Front-end, compression, heat transfer and separation models

### 7.1 Biogenic CO₂ recovery and purification

Treat the carbon source as an unresolved biogenic CO₂-rich gas stream. The actual composition, pressure, temperature, availability and impurity list require a source assay. The model may use component-removal fractions or vendor performance curves for:
- condensate/water removal;
- H₂S/sulfur guard bed;
- siloxane/volatile-organic removal if measured;
- CO₂ recovery/purification;
- drying and guard-bed changeout.

No generic raw-biogas composition or ppm impurity acceptance limit is assigned. The conditioned-feed targets in Prompt 3 are screening assumptions only and cannot be used as catalyst acceptance limits.

### 7.2 Compression

For each compressor, use a real-gas state calculation:

\[
\dot W_s=\dot n(h_{2s}-h_1), \qquad
\dot W_{actual}=\dot W_s/\eta_{is}
\]

with \(s_{2s}=s_1\) at discharge pressure. Intercooling, staging and compressor map must be determined from the actual vendor package and pressure ratios. No isentropic efficiency is selected.

### 7.3 Heat exchangers

Use stream enthalpy differences for heat duties and \(Q=UA\Delta T_{lm}\) for preliminary thermal sizing after states and utility limits are available. U-values, fouling factors and allowable pressure drops are service- and geometry-specific; none are inserted as generic constants.

### 7.4 Condensation and flash

Use a \(\phi-\phi\) EOS flash for the high-pressure synthesis-gas condenser/separator, with PR as the lead candidate and SRK comparison. Flash equations include component balances, phase-fugacity equality, normalisation and an energy balance. No flash or separator recovery is calculated until the EOS is complete and phase-validated.

### 7.5 Recycle and purge

Recycle uncondensed synthesis gas. Purge is the necessary inert/contaminant bleed. Solve the purge from measured inert input and allowed loop concentration, subject to H₂/CO₂ recovery trade-offs. Do not assign a fixed purge fraction before the source gas composition and separator model exist.

### 7.6 Crude methanol distillation

Use an equilibrium-stage MESH model after:
- column pressure is selected;
- Wilson/NRTL parameters are regressed and validated at that pressure;
- crude methanol composition and trace-impurity partition data are available;
- product quality is fixed.

The product target presently references IMPCA Methanol Reference Specifications V10, but it remains an academic target, not a customer contract. No stage count, reflux ratio, recovery, reboiler duty or column design is selected.

## 8. State variables and boundary/initial conditions

### 8.1 Steady-state first calculation model

Independent reactor coordinate: catalyst mass \(W_{cat}\), or axial bed coordinate \(z\) if geometry is established.

Dependent state vector:
- component flows \(F_i(W_{cat})\);
- gas/catalyst temperature \(T_g(W_{cat})\);
- absolute pressure \(P(W_{cat})\);
- optional coolant temperature \(T_c(z)\);
- adsorption coverages \(\theta_{s,k}\);
- reaction rates \(r_{CO2}\), \(r_{RWGS}\).

Algebraic variables:
- gas fugacities and EOS roots;
- phase compositions \(x_i,y_i\);
- \(K_j(T)\), \(Q_j\);
- adsorption/site-balance variables;
- flash split, recycle and purge tear streams;
- electrolyser voltage, H₂/O₂ production, stack and system power.

### 8.2 Boundary conditions

Symbolic boundary conditions for later approval:
- reactor inlet \(F_{i,0}\): from conditioned CO₂, conditioned H₂ and recycle mixer;
- reactor inlet \(T_0\): from feed-preheater outlet, currently TBD;
- reactor inlet \(P_0\): draft 7 MPa(a), not frozen;
- reactor outlet: integrated model plus pressure-drop relation;
- coolant inlet \(T_{c,in}\), mass flow and pressure: TBD from selected utility;
- electrolyser current/load: dispatch/control input from renewable-power availability and vendor map;
- gas-liquid separator feed: reactor cooler outlet from EOS enthalpy/phase calculation.

No numerical initial temperature profile, catalyst activity, holdup, coolant flow or equipment geometry is assigned.

### 8.3 Dynamic extension

The first model is steady state. For later start-up, shutdown and renewable-power disturbance cases, add:
- species holdup ODEs;
- vessel/bed thermal-capacitance ODEs;
- electrolyser stack thermal and gas-volume dynamics;
- H₂ buffer inventory;
- recycle compressor/valve response;
- controller and interlock state logic.

Dynamic initial conditions must come from approved initial inventory, catalyst state, vessel conditions and operating procedure. Ramp rates and trip thresholds remain vendor/HAZOP inputs; no dynamic transient is simulated here.

## 9. Assumption and validity register

| ID | Assumption/model choice | Validity or source range | What invalidates it | Status |
|---|---|---|---|---|
| M-01 | Route C working model | Route recommendation in Prompt 2 | No bankable biogenic CO₂ source; formal gate not approved | Provisional |
| M-02 | 7 MPa(a), 250 °C draft reactor point | Broad literature range 5–10 MPa, 200–300 °C | Catalyst/vendor envelope or approved design basis differs | Draft only |
| M-03 | H₂/CO₂ = 3 fresh stoichiometric anchor | Reaction stoichiometry | Not actual reactor feed/recycle composition | Stoichiometric only |
| M-04 | R-01/R-02 independent reaction network | CO₂-rich hydrogenation and associated RWGS | New feed species/reactions materially alter network | Frozen structure |
| M-05 | No independent CO hydrogenation reaction | MOD model excludes direct pathway in high-CO₂ feed; stoichiometric dependence also proven | A different catalyst/feed supports significant independent CO hydrogenation pathway | Provisional |
| M-06 | 1-D pseudo-homogeneous PFR | Fixed-bed plug-flow kinetic literature | Radial gradients, pellet transfer or thermal gradients invalidate simplification | Provisional |
| M-07 | MOD LHHW catalyst model | 210–260 °C; 40–77 bar; H₂/CO₂ 3.0–4.4; CZA/MgO | Catalyst composition not matched; recycle water/methanol effects outside model | Parameter blocked |
| M-08 | PR78 EOS | Selected VLE data and source-specific pair parameters | Missing kij, phase split residuals or conditions outside validation | Parameter blocked |
| M-09 | Wilson liquid model | MeOH–H₂O data at 95.3 kPa and 15.19–67.38 kPa | Column pressure or composition outside validated range | Parameter blocked |
| M-10 | Ideal-gas Shomate functions | Listed pure-component T intervals and standard state | High-pressure nonideality or phase change | Reference-only |
| M-11 | Electrolysis Faraday model | Stack-level electrical chemistry | Faradaic loss, crossover, shunt currents, dynamic and BOP losses not represented | Structure defined |
| M-12 | Vendor performance curves | Only within guaranteed load/T/P/purity range | Extrapolation outside supplier map | Not yet obtained |

## 10. Alternative model formulations

- **Thermodynamic equilibrium reactor:** retained as a limiting bound only; not used for sizing or finite-rate conversion.
- **Isothermal kinetic PFR:** reproduces the lab kinetic-data condition and isolates the catalyst model; useful for rate-model verification.
- **Non-isothermal pseudo-homogeneous PFR:** provisional governing reactor model for axial composition, temperature and pressure profiles.
- **Multi-stage adiabatic/quench beds:** process-configuration alternative supported by a published methanol miniplant loop; its cited demonstration used steel-gas feed, not the Route C CO₂-only feed, so a Route C revalidation is required.
- **Modified SRK:** thermodynamic comparison to the PR EOS.
- **NRTL:** liquid-phase alternative to Wilson for the MeOH–H₂O column.

CSTR is not selected because the reference route is a heterogeneous fixed-bed catalytic gas-phase synthesis. It may be used only as a deliberately simplified comparison if clearly labelled.

## 11. Mandatory model validation before numerical use

1. Exact stoichiometric matrix rank and C/H/O closure (completed in the reaction network workbook).
2. Reproduce the source MOD kinetic data for the chosen catalyst formulation.
3. Obtain and reproduce the 2025 CZA 7-parameter kinetic data if the catalyst basis remains CZA without MgO.
4. Benchmark PR and SRK against source PVT/VLE/phase-equilibrium data; report pair-wise residuals and uncertainty.
5. Regress Wilson and NRTL to the same methanol-water dataset; validate against independent VLE points at the selected column pressure.
6. Check phase stability for synthesis feed, reactor outlet and condenser/flash.
7. Check reaction and total-energy closure without double-counting heat of reaction.
8. Check Weisz–Prater/Mears criteria and Ergun pressure drop.
9. Reconcile electrolyser Faraday balance, cell/stack/BOP electrical power and H₂/O₂ product quality against OEM performance data.
10. Close separator/recycle/purge inert balances and demonstrate solver convergence.
11. Validate distillation MESH results against product-quality test basis and independent VLE data.
12. Validate dynamic cases only after equipment holdups, thermal masses, controls, ramp limits and safe-state responses are available.

## 12. Handoff status

**Provisional model architecture selected:** Route C reaction network; independent CO₂ hydrogenation and RWGS; electrolyser net reaction; pseudo-homogeneous non-isothermal packed-bed PFR; PR78 EOS candidate; Wilson gamma-phi column candidate; Faraday + vendor-map ALK model.

**Not approved/frozen:** route selection gate, G3 design basis, catalyst formulation/grade, kinetic parameter set, complete EOS binary matrix, VLE parameters, reactor hardware, heat-removal layout, electrolyser guarantee, compressor/equipment specifications.

Prompt 7 may use the equation and schema definitions, but must not treat any blocked parameter as known. No material/energy balances, reaction conversion, equipment sizing or cost calculations have been performed in this phase.

---

## Selected references

- Mbatha et al. (2023), DOI [10.3390/catal13101349](https://doi.org/10.3390/catal13101349).
- van Schagen et al. (2025), DOI [10.1016/j.cej.2025.159953](https://doi.org/10.1016/j.cej.2025.159953).
- Nestler et al. (2022), DOI [10.1002/cite.202200022](https://doi.org/10.1002/cite.202200022).
- High-pressure phase and chemical equilibrium in methanol synthesis (2012), DOI [10.1021/ie3017362](https://doi.org/10.1021/ie3017362).
- Soujanya et al. (2010), DOI [10.1016/j.jct.2009.11.020](https://doi.org/10.1016/j.jct.2009.11.020).
- IRENA/AEL modelling review (2025), DOI [10.1016/j.rser.2025.116005](https://doi.org/10.1016/j.rser.2025.116005).
