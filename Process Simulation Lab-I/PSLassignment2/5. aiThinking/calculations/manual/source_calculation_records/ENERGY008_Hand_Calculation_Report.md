# ENERGY-008 Hand Calculation Report

**Document:** ENERGY008-MAN-001  
**Revision:** 0.1-DRAFT  
**Date:** 1 November 2026  
**Route:** Route C, biogenic CO2 + renewable electrolytic H2, pressurised ALK reference  
**Basis:** ENERGY008-DATA-0.1.0; PFD ENERGY008-PFD-001 Rev 0.1-DRAFT; Prompts 3–16  
**Status:** Independent hand-check reference. Not a frozen plant design basis, equipment datasheet, operating procedure or validated process calculation.

---

## 1. Executive result and scope

This package establishes an independently reproducible, ideal stoichiometric reference case at **50,000 kg/day methanol component-equivalent**. It is deliberately not described as a plant-wide material balance. The source stream register has 55 material streams with blank physical state and flow data; catalyst-matched kinetic constants, full PR78 binary interaction data, flash/VLE parameters, ALK vendor maps, compressor maps and cooling/steam utility conditions remain unavailable.

Two nested boundaries are used:

1. **Synthesis reactor reference block:** `CO2 + 3 H2 -> CH3OH(l) + H2O(l)`.
2. **Integrated Route C ideal reference:** electrolyser E-01 supplies the stoichiometric hydrogen, giving the net equation `CO2 + 2 H2O(l) -> CH3OH(l) + 1.5 O2(g)`.

No RWGS extent, recycle, purge, source impurity, conversion loss or product loss is assigned in this *ideal reference block*. This does not imply those effects are zero in the actual plant.

### Independent results at the reference point

| Result | Hand-calculated value | Interpretation |
|---|---:|---|
| Methanol component-equivalent | 50,000 kg/day | Illustrative basis only |
| Methanol production | 1,560.456777 kmol/day | Ideal product component |
| CO2 minimum consumption | 68.67492 t/day | Stoichiometric lower bound |
| H2 minimum consumption | 9.43708 t/day | Stoichiometric lower bound |
| Electrolyser DI-water stoichiometry | 84.33620 t/day | Excludes treatment reject and other use |
| O2 theoretical coproduct | 74.89912 t/day | No product/sale credit |
| Reaction water formed | 28.11207 t/day | Phase split not solved |
| Net chemical water consumption | 56.22413 t/day | Electrolysis water less R-01 water formed |
| R-01 reference enthalpy rate | -205.699 GJ/day | Not R-301 cooling duty |
| E-01 thermoneutral enthalpy | 1,338.076 GJ/day | Not purchased electricity |
| CO2 ideal-gas sensible heating example | 168.854 kW | 298.15 to 523.15 K, pure ideal CO2 |
| Methanol pure-component latent example | 677.083 kW | At 298.15 K saturation correlation |
| Illustrative exchanger area equation | 56.28 m2 | Assumed U and LMTD; not HX-301 rating |
| W-201 package water-pump shaft power | 0.684 kW | Assumed 50 m head, 70% pump efficiency |

---

## 2. Design basis and input provenance

| ID | Input | Value | Unit | Provenance/status | Source or interpretation |
|---|---|---:|---|---|---|
| DB-004 | Methanol basis | 50,000 | kg/day | Benchmark-aligned selection; pending G3 | Design Basis Rev 0.1-DRAFT, Stoichiometric Anchor |
| DB-016 | Methanol molecular weight | 32.0419 | kg/kmol | Sourced reference | NIST Chemistry WebBook; PROP-0003 |
| DB-017 | CO2 molecular weight | 44.0095 | kg/kmol | Sourced reference | 40 CFR 1065.1005; design-basis anchor |
| DB-018 | H2 molecular weight | 2.01588 | kg/kmol | Sourced reference | 40 CFR 1065.1005; design-basis anchor |
| DB-019 | H2O molecular weight | 18.01528 | kg/kmol | Sourced reference | 40 CFR 1065.1005; design-basis anchor |
| DB-020 | O2 molecular weight | 31.9988 | kg/kmol | Sourced reference | 40 CFR 1065.1005; design-basis anchor |
| RXN-001 | R-01 standard enthalpy | -131.820 | kJ/mol reaction | Reference state only | ENERGY008-DATA-0.1.0; 298.15 K, 0.1 MPa(a) |
| RXN-001 uncertainty | R-01 enthalpy uncertainty | ±0.241868 | kJ/mol reaction | Source-propagated | Formation enthalpy uncertainty RSS |
| E-01 | Electrolysis enthalpy | 571.660 | kJ/mol reaction | Thermoneutral enthalpy reference | 2 H2O(l) -> 2 H2 + O2 |
| SHOMATE-04 | CO2 Cp correlation | Coefficients below | J/mol/K | Frozen pure-component correlation | NIST/JANAF; valid 298–1200 K |
| DHVAP-MEOH-01 | Methanol ΔHvap | Correlation below | kJ/mol | Frozen pure-component correlation | NIST WebBook; valid 298–477 K |
| HX-A01 | Overall U | 100 | W/m2/K | Screening assumption only | Illustrative exchanger equation check |
| HX-A02 | LMTD | 30 | K | Screening assumption only | Illustrative terminal approach |
| P-A01 | Water density | 997 | kg/m3 | Screening assumption | DI water near ambient temperature |
| P-A02 | Pump head | 50 | m | Screening assumption | Not from a hydraulic network |
| P-A03 | Pump efficiency | 0.70 | - | Screening assumption | Not a vendor map |
| DB-011 | Flow margin | 10% | - | Design-basis screening allowance | Pending G3; not vendor margin |

**Important molecular-weight note:** the hand calculation uses the values listed in the Prompt 3 stoichiometric anchor. The property register's canonical NIST water molecular weight is shown as 18.0153 kg/kmol; the anchor uses 18.01528 kg/kmol from its declared reference source. The small difference is not silently averaged.

---

## 3. Manual component and reaction calculations

### 3.1 Methanol molar rate

`n_MeOH = 50,000 kg/day / 32.0419 kg/kmol = 1,560.45677691 kmol/day`

This is a component-equivalent rate, not a measured stream flow.

### 3.2 Synthesis reaction extent and fresh reactants

For R-01:

`CO2 + 3 H2 -> CH3OH + H2O`

The ideal extent equals the desired methanol component rate:

`xi_R01 = 1,560.45677691 kmol/day`

`n_CO2,consumed = 1 × xi_R01 = 1,560.45677691 kmol/day`

`n_H2,consumed = 3 × xi_R01 = 4,681.37033072 kmol/day`

Mass rates follow from `m_dot_i = n_dot_i × MW_i`:

- CO2: 68,674.923 kg/day = 2,861.455 kg/h.
- H2: 9,437.081 kg/day = 393.212 kg/h.
- CH3OH: 50,000.000 kg/day = 2,083.333 kg/h.
- Reaction water: 28,112.066 kg/day = 1,171.336 kg/h.

**R-301 interpretation:** the ideal reference block has 100% CO2 conversion, 100% hydrogen conversion and 100% carbon selectivity to methanol. These are limiting stoichiometric values, not kinetic PFR predictions. Actual conversion/selectivity remain blocked pending catalyst match and rate parameters.

### 3.3 Electrolyser water and oxygen

For E-01:

`2 H2O -> 2 H2 + O2`

One mole of water is consumed per mole of H2 generated:

`n_H2O,ely = n_H2 = 4,681.37033072 kmol/day`

`xi_E01 = n_H2 / 2 = 2,340.68516536 kmol reaction/day`

`n_O2 = xi_E01 = 2,340.68516536 kmol/day`

Hence the stoichiometric DI water is 84,336.197 kg/day and oxygen is 74,899.116 kg/day.

The net water consumption for the integrated reaction is:

`n_H2O,net = 3 n_MeOH - n_MeOH = 2 n_MeOH = 3,120.91355382 kmol/day`

This excludes W-201 reject, regeneration water, cleaning, cooling-water makeup and all water recovery.

### 3.4 Ideal product flow/composition

The ideal R-01 product stream contains one mole methanol and one mole water per reaction extent. After a theoretical perfect split, the methanol product component-equivalent is 50,000 kg/day and its composition is 100 mol% / 100 mass% methanol.

That ideal purity is **not** a T-401 prediction or product release result. The real crude composition, MeOH-H2O VLE, column pressure, stage count, reflux and product assay are not available.

### 3.5 Conversion, selectivity and yield definitions

For this reference block:

- CO2 conversion = (CO2 in - CO2 out) / CO2 in = 1.000.
- Carbon selectivity to methanol = carbon in methanol / carbon converted = 1.000.
- Methanol yield = n_MeOH / n_CO2,fed = 1.000 mol/mol.

All three are ideal stoichiometric benchmarks; no physical process performance is asserted.

### 3.6 Recycle and purge

The physical recycle S-209 and purge S-207 are **not calculated**. A zero recycle or zero purge would be a false plant assumption because no validated V-301 flash, inert feed assay, loop composition, purge criterion or K-301 map exists. The workbook and fixture represent these as `BLOCKED_NOT_COMPUTED` / null.

The zero R-02 extent is used only to define the R-01 limiting reference case, not as a prediction that RWGS does not occur.

---

## 4. Element and material closure

### 4.1 R-301 reactor-block atoms

For R-01 at extent xi:

- Carbon in = 1 xi; carbon out = 1 xi.
- Hydrogen in = 3 × 2 xi = 6 xi H atoms; hydrogen out = 4 xi + 2 xi = 6 xi H atoms.
- Oxygen in = 2 xi; oxygen out = 1 xi + 1 xi = 2 xi.

### 4.2 Integrated Route C boundary

The overall equation is:

`CO2 + 2 H2O -> CH3OH + 1.5 O2`

C, H and O residuals are zero at exact integer stoichiometric precision.

### 4.3 Mass closure with source molecular weights

`m_in = m_CO2 + m_H2O,net = 124,899.054 kg/day`

`m_out = m_MeOH + m_O2 = 124,899.116 kg/day`

`epsilon_m = m_in - m_out = -0.062418 kg/day`

The small residual is retained. It arises because the reference molecular weights are rounded independently and the net reaction mass equality is not exact to the last decimal. It is not assigned to an invented loss stream, and no balancing stream is added.

**Closure status:** ideal reaction-block C/H/O closure passes. The full 55-stream physical plant mass balance remains blocked.

---

## 5. Reactor quantity independent check

The independent check is the limiting R-01 reaction extent and outlet composition, not a numerical PFR integration:

- R-301 feed CO2: 65.019032 kmol/h.
- R-301 feed H2: 195.057097 kmol/h.
- R-01 extent: 65.019032 kmol/h.
- Ideal outlet MeOH: 65.019032 kmol/h.
- Ideal outlet reaction water: 65.019032 kmol/h.
- Ideal outlet residual CO2 and H2: zero only under the full-conversion benchmark.

The governing kinetic model is the provisional 1-D pseudo-homogeneous non-isothermal packed-bed PFR:

`dF_i/dW_cat = sum_j(nu_ij × r_j)`

No reactor volume or catalyst mass can be obtained from this benchmark because kinetic parameters, catalyst match, GHSV, pellet data, heat removal and pressure-drop data are not frozen. Equilibrium-only conversion is also unavailable because the complete EOS and standard Gibbs basis are blocked.

---

## 6. Manual heat calculations

### 6.1 CO2 sensible-heating example

Use the NIST/JANAF CO2 Shomate correlation SHOMATE-04, valid from 298 to 1200 K:

`Cp = A + B t + C t^2 + D t^3 + E/t^2`, with `t = T/1000`.

Coefficients: A=24.99735, B=55.18696, C=-33.69137, D=7.948387, E=-0.136638. Units of Cp are J/mol/K.

The enthalpy increment form is:

`H(T)-H(298) = A t + B t^2/2 + C t^3/3 + D t^4/4 - E/t + F-H`

For a difference, the constant F-H cancels. At 298.15 K to 523.15 K:

`delta_h_CO2 = 9.349192 kJ/mol`

`n_dot_CO2 = (1,560.456777 kmol/day × 1000) / 86400 = 18.060842 mol/s`

`Q_sensible = n_dot_CO2 × delta_h = 168.854 kW`

This is a pure-component ideal-gas example at the stated temperature interval. It is not a 7 MPa synthesis-feed heater duty. High-pressure residual enthalpy and the actual K-101 discharge state require a validated PR78/SRK mixture model.

### 6.2 Reaction thermochemistry and latent-duty reference

R-01 standard-state reference:

`Hdot_R01 = xi_R01 × delta_H_R01 = -205.699 GJ/day`

This is an exothermic thermochemical reference, not the R-301 cooling duty.

E-01 thermoneutral enthalpy equivalent:

`Hdot_E01 = xi_E01 × delta_H_E01 = 1,338.076 GJ/day`

This is not actual ALK electricity. Stack voltage, Faradaic efficiency, rectifier and BOP loads are required to calculate electrical demand.

Pure methanol latent heat at 298.15 K is calculated from NIST correlation DHVAP-MEOH-01:

`delta_Hvap = A exp(-alpha Tr) (1-Tr)^beta`

with A=45.3 kJ/mol, alpha=-0.31, beta=0.4241, Tr=T/Tc, Tc=512.6 K.

At 298.15 K, `delta_Hvap = 37.48899 kJ/mol`. If the full 50 t/day pure methanol component-equivalent were vaporised:

`Q_latent = n_dot_MeOH × delta_Hvap = 677.08 kW`

This is a pure-component latent-heat illustration, not E-401, E-302 or T-401 duty. Actual duties require the column pressure, composition, reflux, vapour fraction and methanol-water mixture enthalpy.

### 6.3 Exchanger area calculation

Use the sensible-heating example as a numerical check of the exchanger equation only:

`Q = U A F delta_T_LM`

Assumptions: U=100 W/m2/K, F=1.0, delta_T_LM=30 K. These values are explicit screening assumptions, not vendor or HX-301 design data.

`A = 168854.29 W / (100 W/m2/K × 1.0 × 30 K) = 56.28 m2`

A sensitivity range using assumed U = 75–150 W/m2/K and LMTD = 20–40 K is 28.14–112.57 m2. This is not a rated HX-301 area. HX-301 requires actual hot/cold inlet/outlet states, approach constraints, bypass design, pressure drops, fouling and a thermal rating.

---

## 7. Hydraulic equipment check: W-201 DI-water feed pump

Use the stoichiometric DI-water requirement for an illustrative W-201 package feed pump:

`m_dot_water = 3,514.008 kg/h`

With assumed water density rho=997 kg/m3:

`Qv = m_dot / rho = 3.5246 m3/h`

Pump shaft power:

`P_shaft = rho g Qv H / eta_p`

`P_shaft = (997 × 9.80665 × 0.000979051 × 50) / 0.70 = 0.6837 kW`

Applying the 10% preliminary flow allowance from DB-011:

- Preliminary hydraulic capacity: 3.877 m3/h.
- Estimated shaft power at the same 50 m head and 70% efficiency: 0.752 kW.

This is a preliminary pump hydraulic duty point for the theoretical DI-water flow only. It excludes pretreatment losses, regeneration, water reuse, line losses, static elevation, NPSH, control-valve losses and pump curve selection. A motor rating and equipment tag should be fixed only after hydraulic-network and vendor review. Treat the pump as an internal W-201 package component, not a separately approved PFD equipment item.

---

## 8. KPI reconstruction

At the ideal stoichiometric baseline:

| KPI | Hand-calculated value | Basis |
|---|---:|---|
| CO2 minimum per tonne MeOH | 1,373.498 kg/t | 1 mol CO2/mol MeOH |
| H2 minimum per tonne MeOH | 188.742 kg/t | 3 mol H2/mol MeOH |
| Electrolyser water per tonne MeOH | 1,686.724 kg/t | 3 mol H2O/mol MeOH |
| O2 coproduct per tonne MeOH | 1,497.982 kg/t | 1.5 mol O2/mol MeOH |
| Methanol HHV | 22.647533 MJ/kg | Formation-enthalpy reference; liquid water product |
| Methanol HHV | 6.290981 kWh/kg | Same HHV basis |
| H2 electrolysis thermoneutral enthalpy | 39.38589 kWh/kg H2 | Not ALK system electricity |

No actual carbon utilisation, plant SEC, process energy efficiency, exergy efficiency, GHG intensity or product recovery KPI is reported because the physical balances and operating data are not closed.

---

## 9. Uncertainty and sensitivity

### 9.1 Source-propagated reaction enthalpy uncertainty

The R-01 reference reaction enthalpy uncertainty is ±0.241868 kJ/mol. On this component-equivalent basis:

`u(Hdot_R01) = xi_R01 × 1000 × 0.241868 / 1e6 = 0.3774 GJ/day`

Therefore the R-01 reference is -205.699 ± 0.3774 GJ/day. This is the propagated source-property uncertainty only, not a statistical confidence interval and not total plant-model uncertainty.

The net integrated thermochemical reference uncertainty is ±0.3926 GJ/day.

### 9.2 Throughput sensitivity

An explicit ±10% scenario band around the 50 t/day benchmark is used for sensitivity only. It is not a probabilistic interval or approval of 45/55 t/day operating capacity.

| Scenario | MeOH t/day | CO2 t/day | H2 t/day | DI water t/day | O2 t/day |
|---|---:|---:|---:|---:|---:|
| LOW_45_TPD | 45.0 | 61.807 | 8.493 | 75.903 | 67.409 |
| BASE_50_TPD | 50.0 | 68.675 | 9.437 | 84.336 | 74.899 |
| HIGH_55_TPD | 55.0 | 75.542 | 10.381 | 92.770 | 82.389 |

For this limiting stoichiometric model, these mass flow results scale linearly with methanol throughput. Actual equipment loads need not scale linearly due to turndown, purge, recycle, package minimum load, efficiency and phase behaviour.

---

## 10. Energy, entropy and exergy closure status

### Energy reference identity

`delta_H_net = delta_H_R01 + 1.5 delta_H_E01 = -131.82 + 1.5(571.66) = 725.67 kJ/mol MeOH`

The independently calculated direct net reaction formation-enthalpy value is also 725.67 kJ/mol MeOH. The identity residual is numerical round-off only. This is a **standard-state thermochemical identity**, not a plant energy closure.

### Entropy and exergy

The reproducible reference state is T0=298.15 K, P0=0.1 MPa(a). It is a thermochemical reference, not a site meteorological dead state.

- R-02 has a standard-state reaction entropy reference of +42.030 J/mol/K, but the ideal base fixture assigns R-02 zero extent.
- R-01 entropy calculation remains blocked by absent liquid methanol/water standard entropy entries in the frozen dataset.
- E-01 entropy calculation remains blocked by liquid-water entropy/reference and electrochemical process state needs.
- Actual stream entropy, S_gen, physical exergy, chemical exergy, unit destruction and plant exergy closure remain blocked.

Negative entropy generation, if later obtained, must be reported as a diagnostic failure or reference/sign inconsistency. It must not be clipped to zero.

---

## 11. Calculation register and independent checks

The accompanying workbook includes a master calculation register (HC-001–HC-018) with ID, purpose, inputs, equation, substitutions, result, units, independent check, source and status. The Reactor-Thermo and Heat-Hydraulics detail sheets use distinct RT- and HH-prefixed identifiers to avoid ID collisions. `ENERGY008_Independent_Checks.csv` provides a flat test-oriented export linked to fixture test IDs.

| Calculation ID | Calculation | Status |
|---|---|---|
| HC-001–HC-006 | Stoichiometric feeds, extents and product/byproduct component flows | Independent hand calculation |
| HC-007–HC-008 | C/H/O and mass closure | Independent hand check; MW rounding residual retained |
| HC-009–HC-011 | R-01 / E-01 reference enthalpy rates and net reaction identity | Reference-state check |
| HC-012–HC-014 | CO2 sensible heat, methanol latent heat and exchanger area | Screening examples |
| HC-015–HC-016 | W-201 hydraulic power and stoichiometric intensity KPI | Screening / reference KPI |
| HC-017–HC-018 | Physical recycle/purge and plant entropy/exergy closure | Blocked |

---

## 12. Frozen regression fixture and Prompt 18 handoff

`ENERGY008_Benchmark_Fixture.json` freezes:

- Input values, units, provenance/status and reaction stoichiometry.
- Expected reference flows, component masses, extents and product-basis metrics.
- C/H/O and mass residuals.
- Reaction, sensible-heat, latent-heat, exchanger and pump reference results.
- Numerical tolerances and explicit blocked values.
- Eighteen independent test cases (TC-01 through TC-18) and expected acceptance behaviour.

Prompt 18 should read the fixture without changing expected values during first implementation. Any later revision to a property, basis or assumption must create a new fixture revision and retain this original case for regression.

**Required data/test handling:**
1. Store units and provenance with each fixture value.
2. Treat blank/null as unavailable, never zero.
3. Preserve the known mass rounding residual.
4. Reject negative physical flows, nonphysical states and invalid reaction extents.
5. Fail loudly on missing active EOS kij, kinetic parameters, VLE parameters, vendor curves or enthalpy data.
6. Keep S-209 recycle and S-207 purge `BLOCKED_NOT_COMPUTED` until the physical model is complete.
7. Do not accept a solver success flag without independent residual, bounds, atom-balance and energy/property checks.
