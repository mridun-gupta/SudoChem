# ENERGY-008 Prompt 9: Energy balance and heat-integration assessment

**Package:** `ENERGY008-ENERGY-REFERENCE-0.1.0`  
**Source data:** `ENERGY008-DATA-0.1.0`  
**Material-balance reference:** `BALANCE-REFERENCE-0.1.0`  
**PFD:** `ENERGY008-PFD-001`, Rev `0.1-DRAFT`  
**Assessment date:** 1 November 2026  
**Overall status:** **Standard-state thermochemical reference calculated; complete plant energy balance and utility model blocked.**

---

## 1. Executive result

The frozen Prompt 5 data subset supports standard formation enthalpies at 298.15 K and 0.1 MPa(a), selected ideal-gas heat-capacity correlations, methanol gas-phase tabular heat capacities, and three standard-state reaction enthalpies. These data are sufficient to calculate standard-state reaction-energy references on the ideal stoichiometric 50 t/day methanol-equivalent basis.

They are not sufficient to calculate a plant-wide steady-state energy balance. The Prompt 7 stream register carries 55 streams, but numeric mass/molar flow, composition, temperature, pressure and enthalpy fields remain null. The high-pressure synthesis-mixture EOS and its binary interaction parameters are blocked; methanol-water VLE and liquid mixture enthalpies are not fitted; ALK vendor power/thermal data and rotating-equipment maps are absent; and no cooling-water or steam supply/return states are assigned.

Accordingly:

- Standard-state reaction heat and electrolysis thermoneutral enthalpy equivalents are calculated.
- Actual reactor cooling duty, electrolyser electricity/heat split, compressor/pump power, cooler/condenser/reboiler duty, drying and water-treatment duty, utility consumption, exchanger area, pinch targets, heat-recovery credit and plant energy closure are not calculated.
- `HX-301` remains the only PFD-identified process-process heat-recovery candidate. It has not been rated and no heat recovery is credited.
- No numerical composite curves can be constructed from the supplied stream data. The delivered composite-curves image is an explicit blocked-status plot, not fabricated curves.

## 2. Boundary, datum and sign convention

### 2.1 Boundary

The physical process boundary follows Prompt 7: feed receipt/conditioning (CO2, water and any required chemicals) through ALK hydrogen generation, synthesis, product purification, product storage/dispatch and internal residuals/waste interfaces. Renewable electricity and external hot/cold utilities enter through the designated utility battery limits. Upstream CO2-source facility operation, upstream biomass cultivation/processing, off-site utility generation and downstream methanol transport/end use remain external context unless a later lifecycle boundary explicitly includes them.

The calculations in this package are narrower: they cover the reference reaction blocks only and must not be mistaken for the physical plant boundary balance.

### 2.2 Enthalpy datum

Set the reference temperature to **298.15 K** and reference pressure to **0.1 MPa(a)**. Pure-component enthalpies begin with the phase-explicit standard enthalpy of formation in `05_Data/ENERGY008_Property_Register.xlsx`, `Formation Enthalpies` sheet. For a state calculation the intended form is:

\[
h_i(T,P,\phi)=\Delta_f H_i^\circ(298.15\,K,\phi^\circ)
+\Delta h_{i,\mathrm{sensible}}
+\Delta h_{i,\mathrm{phase}}
+h_{i,\mathrm{residual/mix}}(T,P,\mathbf{x})
\]

The sensible, phase and residual/mixing terms are included only when a valid source correlation or validated model covers the requested state. The phase reference is explicit; gas and liquid formation enthalpies are not interchanged.

### 2.3 Sign convention and steady-state equation

- Heat, \(\dot Q\), is **positive into** the control volume. Negative \(\dot Q\) is heat removed from it.
- Shaft work and electrical work are **positive into** the control volume.
- Flow enthalpy includes formation, sensible, phase and real-fluid departure terms where available.
- Kinetic and potential energy changes are omitted at this conceptual level and must be reconsidered for final equipment balances where material.

\[
\dot Q+\dot W_{shaft,in}+\dot W_{el,in}
+\sum_{in}\dot n_i h_i-\sum_{out}\dot n_i h_i
=\frac{dE_{CV}}{dt}
\]

The accumulation term is zero only for the ideal reaction-block reference calculation. It is **not** set to zero for unsolved equipment inventories, recycle-loop transients, start-up, shutdown or other dynamic cases.

### 2.4 Avoiding reaction-heat double counting

The intended full stream-enthalpy balance uses standard formation enthalpies plus valid sensible/phase/EOS increments. In that method, reaction enthalpy is already contained in the difference between inlet and outlet species enthalpy flows. Do **not** add a separate \(\xi\Delta H_r^\circ\) term a second time.

An alternative hand-calculation method may use sensible enthalpy relative to a defined reference plus an explicit reaction heat term. It must not also include formation enthalpies. The present reference reaction ledger reports \(\xi\Delta H_r^\circ\) as a separate thermochemical diagnostic and does not combine it with a plant stream enthalpy ledger.

## 3. Standard-state thermochemical references

### 3.1 Calculation basis

The reference target is 50,000 kg/day of methanol component-equivalent, not an approved design production rate. Using the source molecular weight 32.0419 kg/kmol:

\[
\dot n_{MeOH}=\frac{50{,}000}{32.0419}
=1{,}560.4568\;\mathrm{kmol/day}
\]

Base C and Alternative A use ideal R-01 stoichiometry and E-01 electrolysis. R-02 is assigned zero extent solely in this ideal reference block. This is not an approved finite-conversion, selectivity or reactor-model assumption. Alternative B uses only the ideal CO-hydrogenation reaction block; no gasifier or biomass preparation energy is calculated.

### 3.2 Reaction-energy reference table

| Case / block | Extent (kmol reaction/day) | \(\Delta H_r^\circ\) (kJ/mol reaction) | Signed enthalpy (GJ/day) | Interpretation |
|---|---:|---:|---:|---|
| Base C / Alternative A, R-01 | 1,560.4568 | −131.820 | −205.6994 | Standard-state exothermic reference; not R-301 cooling duty |
| Base C / Alternative A, E-01 | 2,340.6852 | +571.660 | +1,338.0761 | Thermoneutral electrolysis enthalpy equivalent; not electrical demand |
| Base C / Alternative A, net reaction | 1,560.4568 molar methanol basis | +725.670 per mol MeOH | +1,132.3767 | Net standard-state reaction enthalpy |
| Alternative B, CO hydrogenation | 1,560.4568 | −128.970 | −201.2521 | Reaction-block heat reference only; gasifier excluded |

The net Route C/A reaction is:

\[
CO_2(g)+2H_2O(l)\rightarrow CH_3OH(l)+\frac{3}{2}O_2(g)
\]

The direct formation-enthalpy result for this net reaction is +725.670 kJ/mol methanol. It equals the sum of R-01 plus 1.5 times E-01 on the same phase basis. The standard-state identity closes to numerical precision. This is the thermochemical energy stored in methanol on an HHV basis, not a claim that all of the value is purchased electricity.

### 3.3 Equivalent rates and specific values

At the 50 t/day illustrative throughput:

| Reference term | GJ/day | MW equivalent | GJ/t MeOH | kWh/t MeOH |
|---|---:|---:|---:|---:|
| R-01 standard-state heat release, magnitude | 205.6994 | 2.3808 | 4.11399 | 1,142.77 |
| E-01 thermoneutral enthalpy requirement | 1,338.0761 | 15.4870 | 26.76152 | 7,433.76 |
| Net Route C/A standard-state thermochemical requirement | 1,132.3767 | 13.1062 | 22.64753 | 6,290.98 |
| Alternative B CO-hydrogenation standard-state heat release, magnitude | 201.2521 | 2.3293 | 4.02504 | 1,118.07 |

The MW values are daily enthalpy rates divided by 24 hours. They are **not** compressor loads, grid draw, cooling-water loads or rated equipment duties.

### 3.4 HHV/LHV convention

All chemical-energy KPI references in this package use an **HHV basis**, with liquid water as the standard combustion product. The methanol HHV calculated from the same standard formation enthalpies is 22.6475 MJ/kg, or 6.2910 kWh/kg. Hydrogen HHV implied by water formation is 141.789 MJ/kg, or 39.3859 kWh/kg. No LHV figures are combined with these values.

The 39.3859 kWh/kg-H2 value is the standard-state thermoneutral enthalpy equivalent for liquid-water electrolysis. It is not an actual ALK stack or AC-system specific electricity consumption. The electrical/thermal split depends on reversible voltage, operating voltage, current efficiency, temperature, pressure and package losses, none of which is frozen in the supplied inputs.

### 3.5 Reference uncertainty

The source reaction-enthalpy uncertainties are propagated from the curated reference values. The approximate daily reference uncertainties are:

- R-01: ±0.3774 GJ/day.
- E-01: ±0.1873 GJ/day, using ±0.08 kJ/mol reaction for the two-water electrolysis stoichiometry.
- Net Route C/A reaction: ±0.3926 GJ/day from the phase-explicit formation-enthalpy contributors, with the shared water formation-enthalpy source treated consistently through the net stoichiometry.
- Route B CO hydrogenation: ±0.4096 GJ/day.

These uncertainties do not include process-model uncertainty, catalyst uncertainty, stream measurement uncertainty or plant losses.

## 4. Sensible enthalpy, phase change and real-fluid methods

### 4.1 Available heat-capacity support

The property register contains NIST/JANAF Shomate ideal-gas Cp(T) intervals for H2, CO2, CO, O2, N2 and water vapour, and tabular NIST gas-phase methanol Cp values. They can support pure-component ideal-gas sensible enthalpy increments only when the temperature lies inside a listed interval. The methanol gas data remain tabular and are not a fitted correlation.

Important coverage limitations:

- Water-vapour Shomate support starts at 500 K. The data register directs lower-temperature steam/water calculations to IAPWS IF97, but no IF97 state calculation is present in this data version.
- Liquid methanol Cp and state-dependent enthalpy are blocked.
- Liquid water enthalpy/Cp is identified through IAPWS IF97 but not evaluated in this model build.
- The high-pressure synthesis mixture has no validated PR78/SRK mixing parameter set, fugacity model, phase-stability result or residual enthalpy calculation.
- Methanol-water liquid/vapour enthalpy of mixing and pressure-specific VLE are not available.
- Raw source gas, inert and impurity Cp/enthalpy coverage is incomplete; biomass, char, ash, tar and KOH solution are not parameterised.

No temperature-dependent Cp integration was used to manufacture plant duties. The correlation coverage and exact intervals are provided in `generated/heat_capacity_coverage.csv` and the workbook.

### 4.2 Pressure and real-fluid effects

A pure ideal-gas Cp integral is not an adequate process enthalpy model for the 7 MPa(a) draft synthesis loop. The Prompt 6 candidate PR78 equation of state with classical van der Waals one-fluid mixing cannot be used quantitatively until the binary interaction parameters and phase behaviour are validated. The missing kij values remain missing, not zero. Modified SRK was retained as a cross-check candidate, not a validated substitute.

### 4.3 Phase-change loads

The methanol and water Antoine intervals and methanol heat-of-vaporisation correlation in the property register do not define the multicomponent separator or distillation duties. Actual vapour/liquid fractions, dissolved gases, liquid mixing enthalpy, column pressure, reflux, reboiler boil-up and condensation fraction remain unknown. Latent heat is therefore not assigned to E-302, E-401, E-402 or V-302.

## 5. Equipment duty register and utility requirements

`ENERGY008_Equipment_Duty_Register.xlsx` covers the 28 Prompt 7 equipment tags. For each tag it records service, associated stream IDs, expected utility type, requested state/duty fields, status and missing inputs. Inlet/outlet temperatures and pressures, mass flow, phase states, duty, utility flow, approach temperature, U, correction factor, fouling allowance, UA and area are deliberately blank where unsolved.

The reference R-01 heat and E-01 enthalpy equivalent are shown in a separate field for R-301 and ELY-201 with explicit `not duty` labels. The numerical values are not copied into the actual `Duty_kW` or `Duty_GJ_day` fields.

| Unit / tag | Duty category | Utility interface | Current status |
|---|---|---|---|
| K-101 / K-201 / K-301 | Compression shaft power and intercooling/aftercooling | U-001, U-002 | Blocked: inlet states, pressure ratios, maps and efficiencies missing |
| ELY-201 | Stack electrical work and thermal management | U-001; stack cooling interface TBD | Blocked: OEM voltage, current efficiency, rectifier/BOP and thermal map missing |
| HX-301 | Process-process heat recovery | No utility by definition | Candidate only; no duty or credit |
| R-301 | Reaction and sensible enthalpy balance | Heat removal/recovery configuration TBD | Reaction reference available; reactor duty blocked |
| E-302 / E-401 | Cooling and condensation | U-002 / U-003 | Blocked: vapour-liquid split, states and cooling-water conditions missing |
| E-402 | Distillation reboiler | U-004 / U-010 conditional | Blocked: column MESH, utility grade and return state missing |
| P-401 | Product pump shaft power | U-001 | Blocked: flow, pressure rise and efficiency missing |
| P-101 / W-201 / D-201 / O-201 / U-501 / W-501 | Package, treatment, regeneration and residual handling loads | Package-specific services TBD | Blocked: technology/vendor and feed quality not selected |

### 5.1 Utility register

All 10 Prompt 7 utility services are carried forward. Rates and supply/return states remain uncalculated:

- U-001 and U-009: renewable/eligible electric power and general plant loads. Keep electrolyser stack/rectifier/BOP separately metered from compressor, pump and auxiliary power to prevent double counting.
- U-002 and U-003: cooling-water supply/return. Circulation flow is not net water consumption; cooling tower makeup and blowdown remain outside the current calculation.
- U-004 and U-010: steam/hot utility and conditional condensate/hot-fluid return. No steam grade or heat-source configuration is selected.
- U-005: instrument air; U-006: nitrogen/inert gas. Intermittent purge/maintenance use is not a continuous process energy flow.
- U-007 fuel and U-008 combustion/process air remain HOLD points. No fired boiler, flare or thermal oxidiser is assumed.

No utility consumption, specific electrical energy, steam use, cooling load, fuel or refrigeration requirement is reported as a number.

## 6. Heat integration and pinch screen

### 6.1 PFD-supported opportunity

`HX-301` is the sole currently drawn process-process heat-recovery candidate. It transfers sensible heat from synthesis reactor effluent stream S-203 to mixed fresh/recycle synthesis feed S-201, giving S-204 and S-202 respectively. It is a conceptual recuperator only.

This candidate is attractive in principle because a hot reactor effluent and a colder synthesis feed occupy the same synthesis loop and can potentially reduce external feed heating/cooling. It must not be committed until:

1. The reactor outlet and mixed-feed T/P/phase/composition are solved with the validated synthesis-mixture property method.
2. A temperature-enthalpy match shows positive driving force over the full exchanger profile, including minimum approach and possible condensation/phase-envelope effects.
3. Pressure drop, catalyst inlet temperature control, feed bypass, reactor startup, turndown and upset cases are checked.
4. The exchanger is checked for fouling/contamination, mechanical design, thermal stress and isolation/bypass requirements.
5. Heat recovered in HX-301 is subtracted once from the downstream trim-cooler load and once from any corresponding feed-heating requirement. It must not be separately credited again as a utility saving.

### 6.2 Other candidates

No second process-process heat recovery match is supported by current stream state data. Potential future candidates include using a proven high-temperature process stream to preheat a defined column feed or water-treatment stream, and recovering eligible compressor/stack heat into a compatible low-temperature sink. These are **future data-screening ideas only**, not PFD connections or approved heat-recovery services.

The R-301 reaction heat reference cannot be routed to E-402 or another user solely because the standard-state heat is large. The reactor temperature profile, available cooling temperature, reaction heat-release profile, process stream approach temperatures and reboiler temperature level have not been calculated.

### 6.3 Pinch and composite curves

No hot or cold process stream currently has a numeric inlet temperature, outlet temperature, enthalpy flow or valid heat-capacity flowrate. Latent loads and temperature-dependent Cp data for the relevant mixtures are incomplete. A numerical composite-curve or grand-composite-curve construction is therefore not possible. The minimum approach temperature, pinch temperature, hot utility target, cold utility target, minimum heating/cooling and heat recovery are all **TBD**, not set to a generic default.

`ENERGY008_Composite_Curves.png` reports this blocked status visibly. It intentionally contains no fabricated hot/cold curve, pinch point, or utility target.

## 7. Heat-exchanger calculation method and assumptions

For future exchanger screening, use:

\[
\dot Q = \dot m\int_{T_1}^{T_2} C_p(T,P,\phi,\mathbf{x})\,dT
\]

Only when Cp can reasonably be treated constant over a validated narrow range may the approximation be used:

\[
\dot Q\approx\dot m C_p\Delta T
\]

For a phase change use validated state enthalpies or a phase-specific latent-heat method. For multicomponent/high-pressure process streams, use the selected validated property method rather than a pure-component ideal-gas surrogate.

Preliminary exchanger area is:

\[
A=\frac{|\dot Q|}{U\,F\,\Delta T_{LM}}
\]

with counter-current LMTD (or the applicable flow arrangement) and a correction factor \(F\). No U value, fouling allowance, F factor, minimum approach or design margin is inserted because no service-specific source, geometry, materials or approved design basis has been provided. These fields are left blank in the duty register. Area and UA are not calculated.

## 8. Overall energy closure and route comparison

### 8.1 Reference reaction-network closure

At the standard-state reaction reference level, Base C and Alternative A satisfy:

\[
\Delta H_{net}=\Delta H_{R01}+1.5\Delta H_{E01}
=725.670\;\mathrm{kJ/mol\ MeOH}
\]

The independent direct formation-enthalpy calculation gives the same result. The residual is numerical rounding only. This is a reaction-thermochemistry identity, not a plant energy closure.

### 8.2 Plant energy closure

Plant closure requires all feed/product stream enthalpy flows, heat loss, shaft/electrical work, utility enthalpy flows and inventory accumulation at the same battery-limit boundary. None is fully available. The overall plant energy closure for Base C, Alternative A and Alternative B is consequently not calculated. The plant closure fields are blank, not zero.

### 8.3 Comparable production basis

All three ideal reaction-block references use the same 50 t/day pure-methanol component-equivalent target. Base C and Alternative A have identical ideal CO2 hydrogenation and ALK stoichiometry, so their reaction thermochemical references are identical. The real-world differences in CO2 purification, source conditioning, transport, compression and source emissions are not calculable without the industrial/biogenic source assays and process choices.

Alternative B has only a CO + 2H2 synthesis reaction-block reference. No biomass feed HHV, gasifier heat demand, char/ash/tar balance, oxygen/steam demand, syngas cleanup duty or syngas compressor energy is available. Comparing its −201.252 GJ/day reaction reference against Base C's +1,338.076 GJ/day electrolysis enthalpy is **not a complete route energy comparison** because the Alternative B upstream gasifier block is omitted.

No recovery improvement percentage or utility penalty is reported for any route.

## 9. Required closures before Prompt 9 can be accepted as a plant energy balance

1. Freeze G3 design basis, capacity, route decision, design cases and process boundary.
2. Complete all 55 stream flow/composition/T/P/phase values from Prompt 8 and retain component provenance.
3. Validate synthesis-mixture EOS, binary interaction parameters, fugacity/phase stability and enthalpy departures at the operating envelope.
4. Implement IAPWS IF97 and evaluate water/liquid-water enthalpy consistently; add the missing liquid methanol and methanol-water mixture enthalpy model.
5. Complete flash, condenser, degassing and distillation MESH calculations including dissolved gas and trace impurity partitions.
6. Obtain ALK vendor performance data: current-voltage/voltage-efficiency maps, Faradaic efficiency, H2/O2 crossover, pressure, temperature, electrolyte, cooling and rectifier/BOP losses.
7. Obtain compressor and pump maps, pressure drops, isentropic/mechanical efficiencies, motor efficiencies and operating points.
8. Specify cooling-water design supply/return/seasonal envelope and steam/hot utility supply/return conditions, plus utility-system efficiency and distribution losses.
9. Solve hot/cold stream enthalpy profiles; establish the pinch minimum approach from design constraints; build composite curves and screen heat-recovery networks including start-up and bypass cases.
10. Complete heat-loss and energy-accounting rules; separate purchased electricity, external thermal utilities and feed chemical energy, while retaining a single HHV basis for chemical-energy KPI reporting.
11. Calculate equipment and plant energy closure with one datum, one sign convention and consistent boundaries; retain residuals and explain all deviations.

## 10. Handoff

### Prompt 10: entropy/exergy

Pass the declared 298.15 K / 0.1 MPa(a) reference state, phase-explicit formation-enthalpy basis, heat/work sign convention, reaction enthalpy references and their uncertainties. Do not infer process entropy/exergy destruction from the standard-state reaction heat. Prompt 10 remains blocked for physical unit exergy destruction until stream states, mixture entropy and environmental dead-state conditions are established.

### Prompts 11–12: sizing and utility summaries

Pass the 28 equipment tags, 55 process stream IDs, 10 utility IDs, the duty register schema and the single HX-301 heat-recovery candidate. No equipment duty, U value, area, compressor power, pump power, utility rate, steam grade, cooling-water flow or specific electricity value is approved for sizing or utility summary. Use the reference thermochemistry as a cross-check only.

---

## Source files used

- `03_Design_Basis/ENERGY008_Design_Basis.xlsx` Rev 0.1-DRAFT, including the 50 t/day illustrative anchor and draft synthesis conditions.
- `05_Data/data_version.json` and `05_Data/ENERGY008_Property_Register.xlsx`, data version `ENERGY008-DATA-0.1.0`.
- `06_Model/ENERGY008_Property_Method_Selection.md`, `ENERGY008_Model_Assumptions_and_Validity.md`, `ENERGY008_Reaction_Network.xlsx` and `ENERGY008_Governing_Equations_Register.xlsx`.
- `07_Process/ENERGY008_Process_Description.md`, `ENERGY008_Stream_Register.xlsx`, `ENERGY008_PFD-001` drawing set and utility register.
- `08_Balances/ENERGY008_Component_and_Element_Balances.xlsx`, `ENERGY008_AlternativeCase_Balances.xlsx`, `generated/reaction_heat_reference.csv` and `LIMITATIONS.md`.

The calculation package preserves the source data status and does not silently upgrade a draft assumption, screening value or missing property to an approved design input.
