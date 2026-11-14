# ENERGY-008 Prompt 11 — Equipment Selection and Preliminary Sizing

**Package:** `ENERGY008-EQUIPMENT-SCREEN-0.1.0`  
**Revision:** 0.1-DRAFT  
**Assessment date:** 1 November 2026  
**Route:** Route C, biogenic CO₂ + renewable electrolytic H₂, pressurised alkaline electrolyser as the working reference  
**Overall status:** **Preliminary capacity screening completed; complete equipment sizing and equipment feasibility acceptance remain blocked.**

---

## 1. Executive conclusion

This package carries the 28 tags from the Prompt 7 PFD into an equipment register and one editable datasheet per tag. It translates the draft Prompt 3 operating envelope into minimum, normal, maximum-continuous, process-design and renewable-power-shortfall cases.

Only a limited set of capacities can be quantified from the available inputs:

1. **Stoichiometric capacity anchors:** CO₂, H₂, electrolyser water, oxygen and methanol product-equivalent flow rates across the operating cases.
2. **ELY-201:** theoretical H₂/O₂ flow, DI-water guidance and Faraday charge-rate equivalent. Stack current, stack area, AC power, stack thermal duty, redundancy and ramping remain blocked.
3. **K-201:** a two-stage ideal-gas H₂ compression screening estimate using NIST Shomate thermodynamic functions and explicitly assumed compressor/motor efficiencies.
4. **W-201:** DI-water product capacity based on the MNRE 9 L/kg H₂ guidance. Raw-water feed capacity and water-treatment recovery remain unknown.
5. **TK-401:** net product inventory scenarios for 8, 24 and 72 hours. No inventory duration or tank configuration is selected.
6. **P-401:** product flow only; pump head, NPSH and power remain blocked.

No reactor volume/catalyst mass, separator diameter/height, column diameter/stages, exchanger duty/area, CO₂ compressor power, recycle compressor power, valve Cv, waste package size, pressure-vessel design pressure, piping class or material grade has been released.

**Important basis discipline:** the 60.5 t/day process design capacity is already the 55 t/day maximum continuous screening rate multiplied by the 10% process margin in DB-011. No second 10% allowance is applied to the flow basis.

The 50 t/day nominal target remains benchmark-aligned and pending G3 approval. The 25/55/60.5 t/day cases are draft assumptions, not guaranteed operating points.

## 2. Source and status hierarchy

| Input | Carried value | Provenance / status | Use in this package |
|---|---|---|---|
| Selected route | Route C | Prompt 2 selection; Route C is the working design route | Primary equipment architecture |
| Electrolyser | Alkaline (ALK) | Working selection, vendor not selected | ELY-201 reference package |
| Normal methanol | 50 t/day | DB-004 benchmark-aligned; G3 pending | Normal scenario |
| Minimum stable methanol | 25 t/day | DB-013 / OP-001 assumption | Turndown screening |
| Maximum continuous methanol | 55 t/day | DB-015 / OP-001 screening assumption | Maximum operating case |
| Process design capacity | 60.5 t/day | DB-012, 55 × 1.10 | Preliminary capacity ladder |
| Synthesis operating condition | 250°C, 7 MPa(a) normal | DB-030/032, model/catalyst approval pending | Operating reference only |
| Synthesis operating envelope | 200–300°C, 5–10 MPa(a) | DB-031/033, literature screening range | Operating envelope only, not mechanical design conditions |
| H₂ electrolyser outlet pressure | 20 bar(a) normal; 15–30 bar(a) range | DB-042 / OP-015, supplier confirmation pending | K-201 screening inlet pressure range |
| Conditioned feed temperature | 40°C | DB-043 / OP-016 interface placeholder | Only used as an explicit K-201 stage-inlet/intercool temperature assumption; not a vendor-guaranteed suction condition |
| CO₂ / H₂ purity | ≥99.5 / ≥99.9 mol% dry | DB-036/037 placeholder targets | Quality target only, supplier/catalyst confirmation required |
| Product density | 0.7910–0.7930 t/m³ at 20°C | DB-052 academic specification basis | Inventory flow conversion only |
| Renewable-power event | 50% available for 2 h | OP-026 assumed disturbance | H₂ buffer lower-bound screening |

### 2.1 Data carried from Prompts 5–10

- Prompt 5 provides selected pure-component reference data including H₂ Shomate heat-capacity functions. It does not provide validated high-pressure multicomponent properties, CO₂/H₂ mixture EOS parameters, synthesis-loop phase equilibrium, crude methanol/water VLE or KOH solution properties.
- Prompt 6 selects the one-dimensional pseudo-homogeneous non-isothermal packed-bed PFR as the reactor model structure. It does not release a catalyst-matched, validated design kinetic parameter set or catalyst physical properties.
- Prompt 7 defines the 28 equipment tags, 55 material stream IDs, seven control volumes and ten utility interfaces.
- Prompt 8 calculates only ideal stoichiometric component lower bounds. It does not solve physical process stream rates, reactor conversion/selectivity, flash splits, column feeds, recycle or purge.
- Prompt 9 calculates reference standard-state reaction thermochemistry but no equipment duties, compressor/pump loads, utility consumption or exchanger area.
- Prompt 10 does not calculate unit-operation exergy destruction or total exergy loads.

Accordingly, missing data are left blank/TBD. `Unknown` is not equivalent to zero.

## 3. Operating cases and capacity ladder

| Case | Methanol (t/day) | CO₂ minimum (t/day) | H₂ minimum (t/day) | H₂ (kg/h) | DI-water guidance (m³/day) | O₂ theoretical (t/day) |
|---|---:|---:|---:|---:|---:|---:|
| Minimum stable | 25.0 | 34.337 | 4.719 | 196.61 | 42.47 | 37.450 |
| Normal | 50.0 | 68.675 | 9.437 | 393.21 | 84.93 | 74.899 |
| Maximum continuous | 55.0 | 75.542 | 10.381 | 432.53 | 93.43 | 82.389 |
| Process design capacity | 60.5 | 83.097 | 11.419 | 475.79 | 102.77 | 90.628 |

Other design-case component anchors:

- CO₂: 3,462.36 kg/h.
- H₂: 475.79 kg/h.
- Electrolysis water consumption by stoichiometry: 102.05 t/day.
- DI-water guidance: 102.77 m³/day, or 4.282 m³/h.
- Total-water guidance: 205.54–228.38 m³/day (18–20 L/kg H₂; boundary clarification is still needed).
- Oxygen: 3,776.16 kg/h theoretical.
- Reaction water generation: 34.016 t/day.
- Methanol product-equivalent: 2,520.83 kg/h, approximately 3.183 m³/h using the 20°C reference density midpoint.

These figures assume ideal R-01 stoichiometry, 100% carbon-to-methanol component equivalence, no purge/loss, no side reaction and no product recovery loss. They are not fresh-feed design guarantees.

### 3.1 Upset: 50% renewable power for 2 hours

For the ideal stoichiometric H₂ requirement, a 50% H₂ supply deficit for 2 hours gives:

| Basis | Full H₂ rate | 50% deficit × 2 h | Ideal gas volume equivalent at 20 bar(a), 40°C |
|---|---:|---:|---:|
| 50 t/day normal | 393.21 kg/h | 393.21 kg usable H₂ | 253.93 m³ |
| 60.5 t/day design | 475.79 kg/h | 475.79 kg usable H₂ | 307.26 m³ |

The gas-volume equivalence uses ideal gas \(V=nRT/P\). It does **not** size a hydrogen vessel. Compressibility, buffer pressure swing, usable residual, vessel technology, reserve, thermal effects, code, relief and whether the buffer sits upstream/downstream of K-201 are unresolved. The plant must alternatively be allowed to ramp down or shut down under an approved dynamic/SOP case; production continuity is not assumed.

## 4. ELY-201 — alkaline electrolyser package

### 4.1 Calculable flow and electrical-charge anchors

At 60.5 t/day methanol component-equivalent:

- H₂ output: **475.79 kg/h** theoretical.
- O₂ coproduct: **3,776.16 kg/h** theoretical.
- DI water guidance: **4.282 m³/h**.
- Faraday charge-rate equivalent: **12.651 MA-cell-equivalent**.

The total stack current depends on the number of cells electrically in series and Faradaic efficiency:

\[
I_{stack}=\frac{2F\dot n_{H_2}}{N_{series}\eta_F}
\]

The number of series cells, current efficiency and current density are not available. Stack current, electrode area, number of stacks and parallel train capacity therefore remain uncalculated.

### 4.2 Power and thermal load

Prompt 9's standard-state thermoneutral enthalpy reference corresponds to approximately **18.74 MW** at the 60.5 t/day design case. This is a thermochemical enthalpy-equivalent reference, **not AC electricity demand, stack nameplate power or a heat-rejection duty**.

AC/DC power requires the OEM stack voltage/current/efficiency map, DC/AC rectifier losses, balance-of-plant consumption, auxiliaries and degradation allowance. Cooling requires the vendor heat balance and thermal-management design. No electrolyser energy consumption or capacity factor is assumed.

### 4.3 Vendor information required

- Guaranteed H₂ flow/purity and O₂ purity/H₂ crossover.
- Guaranteed SEC at normal, minimum and maximum load, with AC/DC boundary.
- Cell count, stack current, cell voltage, active area and current density.
- Faradaic efficiency and gas recovery.
- Outlet pressure, outlet temperature, water consumption, KOH concentration, electrolyte circulation and purge/bleed.
- Minimum stable load, cold/warm start, ramp rate, stop/start cycling and degradation.
- Cooling duty and utility state, gas-liquid separator performance, mist carryover and package battery limits.
- Redundancy, availability, stack replacement and maintenance envelope.

ISO 22734-1:2025 is the current published ISO hydrogen-generator safety standard identified for water-electrolysis systems; ISO records it as replacing ISO 22734:2019. It is a design verification reference, not evidence that a package complies. [ISO 22734-1:2025](https://www.iso.org/standard/82766.html)

## 5. K-201 — hydrogen compressor screening calculation

### 5.1 Method

A transparent two-stage, equal-stage-pressure-ratio ideal-gas calculation was run using the frozen NIST Shomate coefficients for H₂ over 298–1000 K. The entropy/enthalpy functions are integrated with temperature; constant-Cp compression was not used.

For each stage:

\[
S^\circ(T_{2s})-S^\circ(T_1)=R\ln(P_2/P_1)
\]

\[
\Delta h_s=H^\circ(T_{2s})-H^\circ(T_1)
\]

\[
\Delta h_{actual}=\frac{\Delta h_s}{\eta_{is}}
\]

\[
\dot W_{shaft}=N_{stage}\dot m_{H_2}\Delta h_{actual}
\quad;\quad
\dot W_{electric}=\frac{\dot W_{shaft}}{\eta_{motor}}
\]

Analyst-only assumptions used for the screen:

- Two compression stages with equal pressure ratio.
- Intercooling after stage 1 and aftercooling after stage 2 back to 40°C.
- Isentropic efficiency = 75%.
- Motor efficiency = 95%.
- Pure H₂ ideal-gas pressure behaviour.
- No line, cooler or check-valve pressure drops.
- No real-gas \(Z\)/departure correction or vendor map.
- Suction/intercool temperature of 40°C is an explicit analyst assumption. DB-043/OP-016 is a feed-temperature interface placeholder and does not establish compressor suction conditions.

### 5.2 Results

| Case | H₂ (kg/h) | Suction → discharge (bar(a)) | Overall pressure ratio | Stage outlet actual T (°C) | Shaft power (kW) | Motor input (kW) | Intercooler (kW) | Aftercooler (kW) |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Minimum stable | 196.61 | 30 → 50 | 1.667 | 71.7 | 49.85 | 52.47 | 24.92 | 24.92 |
| Normal | 393.21 | 20 → 70 | 3.500 | 121.9 | 258.12 | 271.70 | 129.06 | 129.06 |
| Maximum continuous | 432.53 | 15 → 100 | 6.667 | 169.9 | 450.99 | 474.73 | 225.50 | 225.50 |
| Process design capacity | 475.79 | 15 → 100 | 6.667 | 169.9 | 496.09 | 522.20 | 248.04 | 248.04 |

The design pressure pair is the conservative combination of the lowest draft electrolyser H₂ outlet pressure (15 bar(a)) and maximum synthesis operating pressure (10 MPa(a) = 100 bar(a)). It is not a mechanical design pressure case. The design process flow already embeds DB-011's 10% process margin.

**Interpretation:** 522.2 kW is a model-based electrical input estimate for the stated assumptions, not an approved motor nameplate rating. Before equipment selection, confirm real-gas behaviour, actual stream suction T/P, purity, compression architecture, vendor efficiency, interstage cooling, allowable discharge temperature, pulsation/vibration, seal design, pressure-loss budget, anti-surge/minimum-flow strategy and buffer location.

The H₂ compressor service also needs an explicit hydrogen-material compatibility and embrittlement assessment. No material grade or vessel rating is specified.

## 6. W-201 — water-treatment package

At the 60.5 t/day design case, the DB-026 guidance of 9 L DI water/kg H₂ gives a DI product capacity anchor of **102.77 m³/day (4.282 m³/h)**.

The 18–20 L/kg H₂ total-water guidance corresponds to **205.54–228.38 m³/day**. This is not the raw-water feed capacity, and the original boundary must be clarified because purification/process cooling and circulating/cooling water may be included. No RO/EDI recovery, reject, regeneration, chemical consumption, storage or pretreatment rate can be selected without feedwater analysis and OEM specifications.

W-201 is therefore assigned a DI product-flow anchor only; it is not a sized water-treatment train.

## 7. TK-401 — product storage inventory scenarios

At 60.5 t/day product-equivalent and the midpoint of the draft 20°C density range (0.792 t/m³):

| Inventory duration | Net product mass | Net liquid volume |
|---|---:|---:|
| 8 h | 20.17 t | 25.46 m³ |
| 24 h | 60.50 t | 76.39 m³ |
| 72 h | 181.50 t | 229.17 m³ |

No storage duration has been approved. These are net liquid inventory scenarios only; no gross tank volume, fill limit, freeboard, heel, thermal expansion, roof/vent, nitrogen blanketing, vapour recovery, loading, bund, firewater or tank layout has been calculated.

API 650 14th Edition (2025) is a candidate only if the eventual tank type/service lies within its scope. Its applicability to the selected methanol tank and local Indian statutory/fire requirements must be confirmed before design. [API 650 standards notice](https://www.api.org/products-and-services/standards/important-standards-announcements/standard650) and [BSI listing of API 650:2025 Ed. 14](https://knowledge.bsigroup.com/products/welded-tanks-for-oil-storage-2).

## 8. P-401 — product pump throughput anchor

At 60.5 t/day:

- Methanol product-equivalent flow = 2,520.83 kg/h.
- Using 0.792 t/m³ at 20°C, reference volumetric flow is approximately 3.183 m³/h.

Pump type, head, NPSH available/required, static lift, line losses, tank pressure, vapour pressure and product composition remain unavailable. Hydraulic and motor power are therefore not calculated. A flow value is not a pump selection.

## 9. Equipment-by-equipment sizing status

| Tag | Service | Status | What is or is not released |
|---|---|---|---|
| V-101 | CO₂ inlet knockout | BLOCKED | Source gas/liquid loads and properties unavailable |
| F-101 | Filter/guard train | BLOCKED | Contaminant loading, face velocity, media capacity and DP unavailable |
| P-101 | CO₂ recovery/purification | BLOCKED | CO₂ lower-bound flow only; source assay/recovery/technology absent |
| K-101 | CO₂ compressor | BLOCKED | CO₂ component flow lower bound only; suction P/T/Z and map absent |
| W-201 | DI water treatment | SCREENING OUTPUT ONLY | 102.77 m³/day DI-water guidance at process design rate |
| ELY-201 | ALK package | CAPACITY ANCHOR ONLY | H₂/O₂ flow and Faraday charge only; no stack/power rating |
| D-201 | H₂ dryer/purifier | BLOCKED | H₂ lower-bound throughput only; dewpoint/crossover and package data absent |
| K-201 | H₂ compressor/buffer | SCREENING ONLY | Two-stage ideal-gas/Shomate screen; not rating-level |
| O-201 | O₂ handling | FLOW ANCHOR ONLY | Theoretical O₂ flow only; purity/crossover/disposition absent |
| M-301 | Mixer | FLOW ANCHOR ONLY | Fresh feed component lower bound only; recycle and ΔP absent |
| HX-301 | Feed/effluent recuperator | BLOCKED | No duty, LMTD, U, area or ΔP |
| R-301 | Synthesis reactor | BLOCKED | No catalyst mass/bed/volume/diameter/length/heat-transfer rating |
| E-302 | Trim cooler/condenser | BLOCKED | No flash, duties, phases, area or pressure drop |
| V-301 | HP gas/liquid separator | BLOCKED | No phase split/vapour-liquid loading; no Souders–Brown estimate applied |
| SP-301 | Recycle/purge split | BLOCKED | No inert balance or purge fraction |
| K-301 | Recycle compressor | BLOCKED | Prompt 8 physical recycle not converged; no flow/map |
| PCV-301 | Purge control valve | BLOCKED | No composition, state, flow or Cv |
| V-302 | Degassing drum | BLOCKED | No flash/liquid/gas release calculation |
| T-401 | Methanol-water column | BLOCKED | No feed/VLE/reflux/stages/diameter/hydraulics |
| E-401 | Overhead condenser | BLOCKED | No overhead flow/latent duty/utility state |
| V-401 | Reflux drum | BLOCKED | No liquid/gas rates or holdup basis |
| E-402 | Reboiler | BLOCKED | No column bottoms/duty/steam state |
| P-401 | Product pump | FLOW ANCHOR ONLY | 2,520.8 kg/h or ~3.183 m³/h; no head/power |
| TK-401 | Product storage | INVENTORY SCENARIOS ONLY | 8/24/72 h net inventory; no selected tank capacity |
| U-501 | Off-gas treatment | BLOCKED | Off-gas flow/composition/LHV/toxicity and treatment unselected |
| W-501 | Wastewater treatment | BLOCKED | Wastewater flow/chemistry and consent requirements absent |
| SW-501 | Solid/hazardous waste | BLOCKED | Waste rates/characterization/disposal route absent |
| DR-501 | Segregated drains | BLOCKED | Peak drain rates, flash and compatibility data absent |

No arbitrary vessel-separator correlation has been applied. Souders–Brown sizing is not used because vapour/liquid rates, density, surface tension, foaming/entrainment tendency and correlation service range are not established.

## 10. Materials, corrosion, maintenance and mechanical design

No materials of construction, corrosion allowances, fouling allowances, erosion allowances or cleaning procedures are approved in Prompts 3–10. The 28 datasheets provide service-specific materials questions, not grade selections.

Material review must address at least:

- Dry/wet CO₂, H₂S, siloxanes, condensate pH and impurity-specific corrosion.
- High-pressure hydrogen permeability, embrittlement, fatigue, welds, seals, elastomers, lubricants and cyclic pressure.
- KOH/electrolyte concentration, temperature, stress-corrosion and package-specific materials.
- Oxygen cleanliness, ignition compatibility and allowable non-metallics.
- Methanol/water/trace contaminant compatibility, tank coatings/linings, seals and product contamination.
- Catalyst/adsorbent dust, filter solids, spent electrolyte, sludge and hazardous waste containment.
- Condensation, wet gas, chlorides/sulphur and cleaning chemistry in exchangers/columns.

Mechanical design pressure and temperature are TBD for every pressure boundary. The 5–10 MPa(a) synthesis operating envelope is not a design pressure. Design basis must include blocked-in cases, compressor shutoff, control failure, static head, vacuum, thermal expansion, fire/external heat where applicable, reaction excursion, start-up/shutdown and relief-system cases.

## 11. Candidate codes and statutory verification

The workbook's `Code Review` sheet and tag datasheets list candidate references. Current source checks identified:

- **Electrolyser safety:** ISO 22734-1:2025 is the published current ISO edition for hydrogen generators using water electrolysis; ISO's record says it supersedes ISO 22734:2019. [ISO record](https://www.iso.org/standard/82766.html).
- **Indian pressure vessels:** the Static and Mobile Pressure Vessels (Unfired) Rules, 2016 and subsequent amendments must be screened for applicability. The published 2025 amendment changes Rule 13, including the accepted construction-code list and additional hydrogen storage/transport considerations. [DPIIT/Gazette amendment](https://www.dpiit.gov.in/static/uploads/2025/06/9efdbe3d3aad865fa5ea54915a3384b8.pdf). Rule application and statutory classification require legal/PESO review.
- **Pressure-vessel construction candidates:** IS 2825 and ASME BPVC Section VIII Divisions 1/2 (and Division 3 only where legally/design justified) are candidates, not a selected code. [ASME BPVC Section VIII Div. 1 listing](https://www.asme.org/codes-standards/find-codes-standards/bpvc-viii-1-bpvc-section-viii-rules-construction-pressure-vessels-division-1).
- **Process piping:** ASME B31.3:2024 is a candidate process piping code. [ASME B31.3:2024](https://www.asme.org/codes-standards/find-codes-standards/b31-3-process-piping/2024/pdf). Hydrogen-specific B31.12 applicability should be assessed for the H₂ piping scope.
- **Atmospheric storage:** API 650 14th Edition (2025) is only a candidate if the selected tank is within its scope; Indian statutory/fire/environmental requirements and methanol-specific design controls remain separate.

No pressure-vessel, boiler, piping, electrical or machinery-code compliance is claimed. Code edition, jurisdiction, statutory approvals, certification scope, materials and inspection requirements must be fixed before procurement.

## 12. Feasibility checks and limitations

| Case | Capacity check | Result |
|---|---|---|
| 25 t/day minimum stable | Stoichiometric flows and K-201 model output | Flow basis available; electrolyser and compressor minimum-flow capability unverified |
| 50 t/day normal | H₂ 393.2 kg/h, DI water 84.93 m³/day, K-201 271.7 kW screen | Reference calculation complete; vendor guarantees and actual stream data absent |
| 55 t/day max continuous | H₂ 432.5 kg/h, DI water 93.43 m³/day, K-201 474.7 kW screen | Screening only; not a guaranteed operating point |
| 60.5 t/day process design | H₂ 475.8 kg/h, DI water 102.77 m³/day, K-201 522.2 kW screen | Preliminary capacity anchor; no equipment nameplate released |
| 50% renewable power for 2 h | H₂ deficit 393.2 kg at normal or 475.8 kg at design | Buffer lower bound only; vendor dynamic response and safe turndown/shutdown unresolved |

The K-201 model covers only a single assumed operating path with ideal H₂ thermodynamics. The true compressor operating envelope, map, stability, temperature limits, vibration/pulsation and real-gas performance are not checked. W-201 is a water-product flow estimate, not a package capacity guarantee. Tank values are net liquid inventory scenarios, not selected tank sizes.

## 13. Alternative routes

- **Route A (industrial CO₂ + renewable H₂):** the ideal synthesis stoichiometry and theoretical H₂ demand are unchanged at the same methanol rate. The CO₂ capture/purification source package, impurity limits and carbon-intensity accounting differ. No new source assay or capture package guarantees are available.
- **Route B (biomass gasification to syngas):** the ideal CO-hydrogenation synthesis block implies 43.709 t/day CO and 6.291 t/day H₂ at 50 t/day methanol component-equivalent. Route B has no approved PFD in Prompt 7 and no biomass assay, gasifier configuration, raw syngas analysis, tar/sulphur cleanup or gasifier energy balance. A gasifier, biomass handling, syngas cooling/cleanup, shift/ratio adjustment and solid-residue train cannot be sized. Route B is not represented as a designed alternative equipment train.

## 14. Priority closure list before equipment design release

1. Approve/freeze G3 process capacity, boundary, feed source and operating cases.
2. Obtain biogenic CO₂ source assay/flow/P/T/seasonality and recovery guarantee.
3. Confirm catalyst formulation, validated kinetics and reactor heat-removal arrangement.
4. Obtain electrolyser OEM performance, gas quality, load map, stack/electrical/thermal data and package interfaces.
5. Complete Prompt 8 with actual process material balance, physical recycle convergence, flash and separation.
6. Complete Prompt 9 with duties, utility states, compression/pumping powers and heat recovery.
7. Obtain CO₂/H₂/recycle compressor vendor maps and actual suction/discharge states.
8. Fit/validate methanol-water VLE and complete column simulation/hydraulics.
9. Obtain source/waste assays for wastewater, off-gas and solids and select treatment/disposition.
10. Approve mechanical design basis, pressure/temperature, code, relief, corrosion, materials, hazardous areas, HAZID/HAZOP/LOPA and layout.

## 15. Prompt 12–13 handoff

### Capacities and duties that may be carried as provisional references

- Process design methanol-equivalent rate: 60.5 t/day.
- CO₂ component lower bound: 83.10 t/day (3,462 kg/h).
- H₂ component lower bound: 11.419 t/day (475.79 kg/h).
- DI-water guidance: 102.77 m³/day (4.282 m³/h).
- Oxygen theoretical coproduct: 90.63 t/day (3,776 kg/h).
- K-201 two-stage ideal-gas screening power: 522.2 kW motor input at the defined worst operating pressure pair; 496.1 kW shaft power.
- K-201 intercooler/aftercooler screening duties: approximately 248.0 kW each at the process design case.
- H₂ shortfall buffer lower bound for the 50%/2 h event at process design rate: 475.8 kg usable H₂.
- TK-401 net inventory scenarios: 25.46/76.39/229.17 m³ for 8/24/72 h at process design capacity.

### Open equipment and materials questions

No actual equipment nameplate, pressure rating, vessel dimensions, reactor volume, catalyst mass, exchanger area, column diameter/stages, pump head, compressor selected model, utility rate, material grade, corrosion allowance or code compliance is passed as approved design data.

Prompt 12–13 should use these figures as provisional load references and carry forward the explicit blockers. Do not use the K-201 screening power as a motor specification or assume W-201 guidance is raw-water intake.

---

**Final acceptance statement:** The package provides traceable screening calculations and an editable datasheet for every PFD equipment tag. It does **not** meet the full equipment sizing acceptance criteria because most equipment cannot be sized without the missing Prompt 8 stream solution, Prompt 9 duties, vendor performance maps, source assays, mechanical design basis and phase-equilibrium data. No vendor data or quotes were invented; no code compliance is claimed.
