# ENERGY-008 Process Description and PFD Basis

**Document:** `ENERGY008-PD-0.1`  
**PFD:** `ENERGY008-PFD-001`, Rev 0.1-DRAFT  
**Date:** 1 November 2026  
**Process route:** Route C, biogenic CO₂ + renewable electrolytic H₂, ALK reference  
**Status:** Conceptual process configuration for review. **Not an approved/frozen design basis and not for construction.**

---

## 1. Design-status and source control

Prompt 2 recommends Route C as the preferred academic base route, but the route decision report explicitly requires user approval. Prompt 3's design-basis Control sheet records that the route-selection gate response was not explicitly recorded and G3 is not frozen. Accordingly, this document uses Route C as the working process configuration, not as an approved project route.

The current design-basis workbook contains the following draft assumptions/targets, which are shown only as context and are not equipment design values:

- Synthesis reactor screening point: 7 MPa(a) and 250 °C.
- Illustrative capacity: 50 t/day, not an approved plant capacity.
- Conditioned CO₂ purity target: at least 99.5 mol% dry, screening target only.
- Conditioned H₂ purity target: at least 99.9 mol% dry, screening target only.
- Product reference: IMPCA Methanol Reference Specifications Version 10 as an academic target, not a buyer contract.

No raw CO₂ composition, source flow, electrolyser performance, actual synthesis conversion, loop composition, purge fraction, crude methanol composition, distillation pressure, utility duty or equipment size is assigned in this phase.

**Governing inputs:** `02_Route_Selection/ENERGY008_Route_Decision_Report.md`; `03_Design_Basis/ENERGY008_Design_Basis.xlsx` Rev 0.1-DRAFT; `05_Data/ENERGY008_Property_Register.xlsx` / `ENERGY008-DATA-0.1.0`; `06_Model/ENERGY008_Model_Assumptions_and_Validity.md`; `06_Model/ENERGY008_Property_Method_Selection.md`.

## 2. Process configuration overview

The conceptual plant is arranged as five linked process/residuals trains plus site utilities:

1. **Biogenic CO₂ receipt and conditioning:** source-gas knockout, particulate/coalescing and contaminant guard service, CO₂ recovery/purification, compression and condensate handling.
2. **Renewable H₂ production and conditioning:** raw-water pretreatment/DI polishing, pressurised ALK electrolysis, wet-gas separation, H₂ purification/drying/compression and oxygen coproduct handling.
3. **Methanol synthesis loop:** fresh-feed/recycle mixing, optional effluent/feed recuperation, packed-bed PFR synthesis reactor, effluent cooling/condensation, high-pressure gas/liquid separation, recycle compression and an explicit purge branch.
4. **Crude methanol purification and product storage:** crude-liquid letdown/degassing, methanol-water distillation, overhead condenser/reflux drum, reboiler, product pump, storage and dispatch.
5. **Environmental/residuals services:** collected off-gas treatment/disposition, wastewater collection/treatment/reuse decision and segregated solid/hazardous-waste holding/export.

The PFD is a conceptual process diagram. It is not a P&ID and does not show detailed isolation valves, control valves other than the purge function, relief devices, drain-valve details, instrument tags, line classes, electrical single-line diagrams or safety interlocks.

## 3. Unit-operation description

### 3.1 Biogenic CO₂ receipt and conditioning (CV-100)

**Source interface S-001 / BL-C01.** A CO₂-rich gas from an as-yet-unselected biogenic source archetype is received at the plant boundary. A biogas-upgrading or fermentation source is not selected. Its upstream process facility is outside the physical plant-gate boundary. Source identity, feedstock origin, chain-of-custody, assay, flow profile, pressure and temperature must be obtained before the feed package can be specified.

**V-101, inlet knockout.** Removes free condensate/liquid carryover before filters and guard beds. Condensate leaves as S-002 to W-501. The gas proceeds as S-003.

**F-101, coalescing filter and guard train.** Provides particulate/coalescing service and source-specific contaminant protection. The sequence and media are not chosen until the source assay and catalyst acceptance limits are known. Filtered/guarded gas continues as S-004. Spent media and captured solids leave internally as S-005 to SW-501 and are dispatched as S-315. Fresh guard/filter media enters separately as S-404 from BL-CHEM01; S-401 is reserved for P-101 purification solvent/process chemicals.

**P-101, CO₂ recovery and purification.** Produces a recovered CO₂ stream S-006 to K-101. No absorption, membrane, PSA or other separation technology is selected. The rejected gas S-007 is routed to U-501; it is not silently vented or returned to the source. CO₂ recovery, purity, pressure drop, regeneration heat, power, chemical use, tail-gas composition and carbon slip remain open.

**K-101, CO₂ compression.** Raises recovered CO₂ to the synthesis-feed pressure after intercooling/aftercooling as determined by the eventual compressor package. The discharge is S-008 to M-301. Interstage/aftercooler condensate, if formed, is S-009 to W-501. Prompt 3's 7 MPa(a) / 40 °C CO₂ interface is a draft assumption only; no compressor pressure ratio, staging, efficiency or condensate rate is calculated.

### 3.2 Water treatment and renewable hydrogen (CV-200)

**W-201, water pretreatment and DI polishing.** Raw site water enters as S-101. DI make-up S-102 feeds ELY-201. Treatment reject/regeneration waste S-103 goes to W-501. Water quality, source reliability, treatment recovery, reject composition and abstraction permission are all open. W-201 pretreatment/DI reagents enter as S-403. Wastewater treatment reagents enter separately as S-405 to W-501.

**ELY-201, pressurised alkaline electrolyser.** Uses renewable/eligible electricity U-001 and DI water S-102 to produce hydrogen and oxygen according to the net reaction:

\[
2H_2O(l) \rightarrow 2H_2(g)+O_2(g)
\]

The electrolyser package includes its vendor-defined electrolyte circulation and gas/liquid separation. Wet hydrogen S-104 proceeds to D-201. Oxygen-rich anode gas S-108 proceeds to O-201. KOH electrolyte make-up S-111 crosses at the separate BL-KOH01 chemical interface. Spent/bleed electrolyte S-112 is segregated to SW-501, not presumed suitable for ordinary wastewater treatment.

**D-201, H₂ purification/drying.** Removes moisture and any specified crossover/aerosols to meet catalyst-feed acceptance once the catalyst and electrolyser vendor specifications are known. Condensate/drains S-105 go to W-501. Dry purified H₂ S-106 proceeds to K-201. The draft ≥99.9 mol% dry H₂ value is a screening target, not an OEM guarantee.

**K-201, H₂ compressor/buffer.** Compresses H₂ to the synthesis-feed pressure and provides only a conceptual buffer interface; storage form and volume are not selected. S-107 supplies H₂ to M-301. Prompt 3's 20 bar(a) ALK outlet and 7 MPa(a) conditioned-feed pressure are draft interface assumptions, not final guarantees.

**O-201, oxygen coproduct handling.** Receives S-108, separates/conditions as required and provides S-109 to the oxygen battery limit BL-O01. S-110 is the associated condensate/drain to W-501. No oxygen sale, product-grade quality, compression, storage or vent disposition is assumed. O₂ purity, H₂ crossover and safe handling must be established before an offtake or release route is selected.

### 3.3 Methanol synthesis loop (CV-300)

**M-301, fresh/recycle mixer.** Combines conditioned CO₂ S-008, conditioned H₂ S-107 and compressed recycle gas S-209. Mixed feed S-201 goes to HX-301. The actual H₂/CO₂ ratio, CO content, inert fraction, water and methanol content are not known; the 3:1 value in Prompt 3 is a fresh-feed stoichiometric anchor only.

**HX-301, candidate effluent/feed recuperator.** Feed S-201 is preheated to S-202 using heat from hot reactor effluent S-203, which returns to HX-301 and leaves as S-204. This is the only process-to-process heat link currently drawn. It is a candidate heat-integration opportunity only: no duty, heat-transfer area, temperature approach, bypass arrangement or energy credit has been calculated or claimed.

**R-301, methanol synthesis reactor.** Uses the selected model structure: one-dimensional pseudo-homogeneous non-isothermal packed-bed PFR with independent CO₂ hydrogenation and RWGS reactions. R-01 and R-02 form methanol/water and CO/water, respectively. The catalyst family and final reactor hardware/heat-removal configuration are not selected. Hot reactor effluent S-203 returns through HX-301. Catalyst make-up S-402 enters at the catalyst-loading interface. Spent catalyst/fines S-312 go to SW-501 and are exported as S-317 during maintenance.

**E-302, trim cooler/condenser.** Further cools S-204 and may condense crude methanol/water, producing vapour-liquid stream S-205 to V-301. Cooling duty and cooling-medium conditions are TBD. Cooling-water supply/return interfaces U-002/U-003 are shown as aggregate utility connections.

**V-301, high-pressure gas/liquid separator.** Separates condensed crude liquid S-210 from uncondensed loop gas S-206. The separator split must be calculated from a validated mixture EOS/phase model; no recovery or phase fraction is assumed.

**SP-301 / K-301 / PCV-301, recycle and purge.** Separator overhead S-206 is split into recycle S-208 and purge S-207. Recycle gas is compressed in K-301 and returned as S-209 to M-301. Purge S-207 passes through PCV-301 to U-501 to control inert/contaminant accumulation. No purge fraction is assumed. It must be determined from the actual feed assay, separator model, maximum allowable loop concentrations, hydrogen loss trade-off and off-gas safety/treatment design.

### 3.4 Crude methanol letdown and purification (CV-400)

**V-302, crude-liquid letdown/degassing.** High-pressure crude liquid S-210 is let down and flashed to release dissolved/non-condensable gas. The gas S-211 goes to U-501. Degassed crude methanol/water S-212 feeds T-401. Flash pressure, gas composition, methanol loss and liquid composition are not calculated.

**T-401, methanol-water purification column.** Separates a methanol-rich overhead from water-rich bottoms. The governing model architecture is a MESH equilibrium-stage column with a low-pressure gamma-phi formulation. Wilson is the lead liquid activity model candidate and NRTL is the comparator. Neither has fitted parameters, and the column pressure, stage count, feed stage, reflux ratio and recovery are not selected.

**E-401 and V-401, overhead condenser/reflux drum.** Column overhead vapour S-301 is condensed in E-401; condensate S-302 enters V-401. Reflux S-303 returns to T-401, while net methanol-rich distillate S-304 goes to P-401. Non-condensables S-306 go to U-501.

**E-402, reboiler.** Provides boil-up to T-401 using steam or another hot utility through U-004. Condensate/hot-fluid return is U-010 if a condensing utility is eventually chosen. Utility source and duty are unknown; no fired boiler is selected. Potential heat integration between reactor heat and the distillation reboiler is not drawn or credited because temperature levels and duties are not established.

**P-401, TK-401 and BL-P01.** Net distillate S-304 is pumped via S-305 to product storage TK-401. Final product dispatch crosses the plant boundary as S-314. The reference product target in Prompt 3 is an academic IMPCA V10 target, not a buyer contract. Storage tank type, inventory, nitrogen blanketing, vapour recovery, loading controls and statutory design basis are open.

### 3.5 Off-gas, wastewater and solid-waste services (CV-500)

**U-501, off-gas management/treatment interface.** Collects CO₂ purification reject S-007, synthesis-loop purge S-207, crude-liquid degassing gas S-211 and distillation non-condensables S-306. The treatment/recovery/disposition technology is not selected. Treated off-gas S-311 crosses at BL-VENT01 only after composition, emissions, dispersion, toxicity, flammability and safety review. No flare, thermal oxidiser, fuel-gas recovery or direct vent is assumed by this PFD. If an oxidiser/boiler is selected, fuel gas U-007 and combustion air U-008 may become real boundary streams and the PFD must be revised.

**W-501, wastewater collection/treatment interface.** Collects V-101 condensate S-002, CO₂ compressor condensate S-009, water-treatment reject S-103, H₂ dryer condensate S-105, oxygen handling condensate S-110, distillation bottoms S-307 and segregated process drains S-313. It produces treated effluent S-308 to BL-E01, and may conditionally recover water as S-309 to W-201 if DI polishing and electrolyser OEM requirements are met. S-309 is not a credited water saving at this stage. Sludge S-310 transfers internally to SW-501 and is dispatched as S-316. Cooling-water return U-003 is not ordinary process wastewater; cooling-tower blowdown/makeup is an unresolved utility boundary.

**SW-501, segregated solid/hazardous waste interface.** Receives spent filter/guard material S-005, wastewater sludge S-310, spent electrolyte S-112 and spent catalyst S-312. It provides separate exports: spent media/filter solids S-315, wastewater sludge S-316 and spent catalyst S-317. Waste classification, quantity, packaging, recovery/disposal and authorised transporter remain open.

**DR-501, segregated process drain header.** Receives sampling, wash and maintenance drains as S-313. Methanol, caustic/electrolyte and cleaning chemical streams must be segregated pending compatibility and treatment review; they must not be combined as a generic drain without verification.

## 4. Material stream register and PFD traceability

The authoritative per-stream register, including phase, numerical blank fields, quality attributes, provenance, status, control volume and PFD flag, is `ENERGY008_Stream_Register.xlsx`. The following index lists every material stream appearing in the PFD. Numeric mass flow, molar flow, volumetric flow, composition, temperature, pressure and enthalpy remain null because no balances have been solved.

### 4.1 CO₂ receipt/conditioning

| Stream ID | From → To | Phase | Description |
|---|---|---|---|
| S-001 | BL-C01 → V-101 | Gas | Raw biogenic CO2-rich source gas |
| S-002 | V-101 → W-501 | Liquid | Raw source knockout condensate |
| S-003 | V-101 → F-101 | Gas | Knocked-out CO2-rich gas to filter/guard train |
| S-004 | F-101 → P-101 | Gas | Filtered/guarded CO2-rich gas to purification |
| S-005 | F-101 → SW-501 | Solid | Spent filter/guard media and captured solids |
| S-006 | P-101 → K-101 | Gas | Recovered/purified biogenic CO2 gas |
| S-007 | P-101 → U-501 | Gas | CO2 purification reject/off-gas |
| S-008 | K-101 → M-301 | Gas | Compressed/conditioned CO2 to synthesis mixer |
| S-009 | K-101 → W-501 | Liquid | CO2 compressor interstage/aftercooler condensate |

### 4.2 Water, electrolyser and hydrogen train

| Stream ID | From → To | Phase | Description |
|---|---|---|---|
| S-101 | BL-W01 → W-201 | Liquid | Raw site water to pretreatment/DI polishing |
| S-102 | W-201 → ELY-201 | Liquid | DI water make-up to ALK electrolyser |
| S-103 | W-201 → W-501 | Liquid | Pretreatment/DI train reject and regeneration waste |
| S-104 | ELY-201 → D-201 | Gas | Wet hydrogen product gas from ALK separator |
| S-105 | D-201 → W-501 | Liquid | Hydrogen dryer/purifier condensate and drains |
| S-106 | D-201 → K-201 | Gas | Purified/dried hydrogen to compressor |
| S-107 | K-201 → M-301 | Gas | Compressed H2 to synthesis mixer/buffer outlet |
| S-108 | ELY-201 → O-201 | Gas | Oxygen-rich anode gas from ALK separator |
| S-109 | O-201 → BL-O01 | Gas | Conditioned oxygen coproduct or controlled disposition stream |
| S-110 | O-201 → W-501 | Liquid | Oxygen handling condensate |
| S-111 | BL-KOH01 → ELY-201 | Liquid | ALK electrolyte (KOH) make-up / replacement chemical |
| S-112 | ELY-201 → SW-501 | Liquid | Spent/bleed alkaline electrolyte and contaminated package drains |

### 4.3 Synthesis loop and recycle/purge

| Stream ID | From → To | Phase | Description |
|---|---|---|---|
| S-201 | M-301 → HX-301 | Gas | Mixed fresh and recycle synthesis feed |
| S-202 | HX-301 → R-301 | Gas | Preheated synthesis reactor feed |
| S-203 | R-301 → HX-301 | Gas / possible multiphase if local conditions permit | Hot synthesis reactor effluent to recuperator hot side |
| S-204 | HX-301 → E-302 | Gas / possible multiphase | Recuperator-cooled synthesis effluent to trim cooler |
| S-205 | E-302 → V-301 | Vapour-liquid | Cooled/partially condensed high-pressure synthesis effluent |
| S-206 | V-301 → SP-301 | Gas | Uncondensed synthesis-loop overhead gas |
| S-207 | SP-301 → PCV-301 | Gas | Controlled purge branch from synthesis loop |
| S-208 | SP-301 → K-301 | Gas | Recycle gas to recycle compressor |
| S-209 | K-301 → M-301 | Gas | Compressed recycle gas returned to synthesis mixer |
| S-210 | V-301 → V-302 | Liquid | High-pressure crude methanol/water liquid to letdown/degassing |

### 4.4 Degassing, purification, product, wastewater, off-gas and waste

| Stream ID | From → To | Phase | Description |
|---|---|---|---|
| S-211 | V-302 → U-501 | Gas | Non-condensable/flash gas released on crude-liquid letdown |
| S-212 | V-302 → T-401 | Liquid | Degassed crude methanol/water feed to purification |
| S-301 | T-401 → E-401 | Vapour | Methanol-rich distillation overhead vapour |
| S-302 | E-401 → V-401 | Liquid / possible vapour | Condensed overhead to reflux drum |
| S-303 | V-401 → T-401 | Liquid | Distillation reflux return |
| S-304 | V-401 → P-401 | Liquid | Net methanol-rich distillate to product pump |
| S-305 | P-401 → TK-401 | Liquid | Pumped methanol product to storage |
| S-306 | V-401 → U-501 | Gas | Distillation reflux-drum non-condensables |
| S-307 | T-401 → W-501 | Liquid | Water-rich distillation bottoms |
| S-308 | W-501 → BL-E01 | Liquid | Treated wastewater effluent / discharge interface |
| S-309 | W-501 → W-201 | Liquid | Conditionally recovered water for further polishing/reuse |
| S-310 | W-501 → SW-501 | Solid / slurry | Wastewater-treatment sludge / concentrated residuals |
| S-311 | U-501 → BL-VENT01 | Gas | Treated off-gas / controlled emissions outlet |
| S-312 | R-301 → SW-501 | Solid | Spent catalyst and catalyst fines during maintenance |
| S-313 | DR-501 → W-501 | Liquid | Collected cleaning, sampling and maintenance aqueous drains |
| S-314 | TK-401 → BL-P01 | Liquid | Methanol product at storage/dispatch battery limit |
| S-315 | SW-501 → BL-SW01 | Solid | Spent CO2 guard media and filter solids for authorised recovery/disposal |
| S-316 | SW-501 → BL-SW02 | Solid / slurry | Wastewater treatment sludge/concentrated solids for authorised disposal/recovery |
| S-317 | SW-501 → BL-SW03 | Solid | Spent methanol synthesis catalyst and catalyst fines for authorised recovery/disposal |

### 4.5 Chemical and catalyst feeds

| Stream ID | From → To | Phase | Description |
|---|---|---|---|
| S-401 | BL-CHEM01 → P-101 | Liquid / solid (technology dependent) | CO₂ purification solvent/process chemicals |
| S-402 | BL-CAT01 → R-301 | Solid | Fresh catalyst/replacement catalyst charge |
| S-403 | BL-CHEM02 → W-201 | Liquid / solid (treatment dependent) | Water pretreatment/DI treatment chemicals |
| S-404 | BL-CHEM01 → F-101 | Solid / liquid (media dependent) | Filter/guard-bed adsorbent and media makeup/replacement |
| S-405 | BL-WW-CHEM01 → W-501 | Liquid / solid (treatment dependent) | Wastewater treatment chemicals/reagents |

## 5. Utility and energy interfaces

| Utility ID | Direction | Service / use | Boundary control |
|---|---|---|---|
| U-001 | IN | Renewable/eligible electricity; users: ELY-201, K-101, K-201, K-301, P-401, W-201, W-501, control and auxiliaries | OPEN_SITE_INPUT |
| U-002 | IN | Cooling-water supply; users: K-101 intercoolers, K-201 aftercooler if selected, E-302, E-401 and other coolers as justified | OPEN_SITE_INPUT |
| U-003 | OUT | Cooling-water return; users: From K-101/E-302/E-401 cooling users to cooling-water return system | OPEN_SITE_INPUT |
| U-004 | IN | Steam or other hot utility; users: E-402 reboiler; other heat users only if later justified | OPEN_SITE_INPUT |
| U-005 | IN | Instrument air; users: Control valves, actuators and instrument consumers including PCV-301 | OPEN_SITE_INPUT |
| U-006 | IN | Nitrogen/inert gas; users: Equipment purging, catalyst handling and maintenance inerting points as required | OPEN_ENGINEERING_INPUT |
| U-007 | HOLD | Fuel gas / fuel; users: No current fired equipment selected; conditional off-gas oxidiser/boiler if later required | NOT_IN_CURRENT_CONFIGURATION |
| U-008 | HOLD | Combustion air / process air; users: No combustion device or air-fed process unit currently selected | NOT_IN_CURRENT_CONFIGURATION |
| U-009 | IN | Electric power for general plant loads; users: CO2/H2/recycle compressors, pumps, water treatment, controls and auxiliaries | OPEN_SITE_INPUT |
| U-010 | OUT | Steam condensate / hot-fluid return; users: BL-THERM02 | OPEN_CONDITIONAL |

U-007 fuel gas and U-008 combustion/process air are documented as hold points, not present flows. U-005 instrument air is distinct from combustion air. U-001 electrolyser electricity and U-009 general plant electrical power must be separately metered and counted once. U-002 cooling-water supply and U-003 cooling return are not the same as net water consumption; cooling tower makeup, blowdown and heat rejection need a separate utility boundary if a cooling tower is selected. U-004 steam/hot utility and U-010 condensate/hot-fluid return are conditional on the final utility source.

## 6. Heat recovery and energy links

### 6.1 Shown on the PFD

- **HX-301, reactor effluent/feed recuperator:** process-to-process heat transfer from hot reactor effluent S-203 to mixed fresh/recycle feed S-201, producing preheated feed S-202 and recuperator-cooled effluent S-204. The duty, temperature approach, pressure drop, area, bypass and operability are uncalculated. No energy saving is credited.
- **E-302, reactor effluent trim cooler/condenser:** rejects remaining heat to a cooling utility; the cooling duty and condensate fraction are not calculated.
- **E-401, distillation overhead condenser:** rejects overhead heat to a cooling utility; duty and condensate split are not calculated.
- **E-402, distillation reboiler:** receives heat from U-004; the utility grade and duty are not selected.
- **ALK electrolyser:** stack heat and balance-of-plant cooling are not quantified. No low-grade heat link to water preheat is drawn because the OEM stack temperature and duty are unavailable.

### 6.2 Opportunities not included as confirmed PFD links

Potential recovery from E-302 or E-401 to feedwater/other low-temperature users, or from synthesis heat to the distillation reboiler, can only be assessed after stream enthalpies, temperature profiles, heat loads, utility levels, simultaneity and pinch constraints are known. These are not treated as present integrations, duties or energy credits.

## 7. Process boundary and balance control volumes

Physical plant-gate boundary: feed receipt/conditioning through product storage/dispatch. The upstream biogenic source facility and downstream transport/customer use are outside the physical plant boundary. They may still be required for Green Methanol carbon-origin evidence and extended lifecycle/MRV reporting.

| CV ID | Control volume | Included units | Boundary streams / interfaces |
|---|---|---|---|
| CV-00 | Overall plant-gate process boundary | Feed receipt/conditioning through methanol storage/dispatch, including onsite H2, synthesis, purification, off-gas, wastewater, solid waste and utility interfaces | IN: S-001, S-101, S-111, S-401 to S-405, U-001/002/004/005/006/009; OUT: S-109, S-308, S-311, S-314, S-315, S-316, S-317, U-003/U-010 |
| CV-100 | Biogenic CO2 receipt and conditioning | V-101, F-101, P-101 and K-101 including interstage condensate/reject and spent media | IN S-001/S-401/S-404; OUT S-005/S-007/S-008/S-009 |
| CV-200 | Renewable hydrogen generation and conditioning | W-201, ELY-201, D-201, K-201 and O-201 | IN S-101/S-111/S-403/U-001/U-009; OUT S-103/S-105/S-107/S-109/S-110/S-112 |
| CV-300 | Methanol synthesis loop | M-301, HX-301, R-301, E-302, V-301, SP-301 and K-301 | IN S-008/S-107/S-209 plus U-002/U-009; OUT S-207/S-210/S-312; internal S-201 to S-206/S-208/S-209 |
| CV-400 | Crude methanol purification and product storage | V-302, T-401, E-401, V-401, E-402, P-401 and TK-401 | IN S-210/S-212/U-004/U-009; OUT S-306/S-307/S-314/U-010 |
| CV-500 | Environmental and residuals management | U-501, W-501 and SW-501 collection/treatment/disposition interfaces | IN S-002/S-005/S-007/S-009/S-103/S-105/S-110/S-112/S-207/S-211/S-306/S-307/S-313/S-312/S-405; OUT S-308/S-311/S-315/S-316/S-317 dispatch |
| CV-600 | Utility supply and distribution | Site power, cooling water, steam/hot utility, instrument air and nitrogen headers | IN U-001/U-002/U-004/U-005/U-006/U-009; OUT U-003/U-010; U-007/U-008 held out |

The separate Battery-Limit Register workbook provides the detailed 27-row battery/context interface register, including tie-in point, accounting treatment, metering needs and status. Major boundary crossings are:

- **Material feeds:** S-001 biogenic CO₂-rich gas; S-101 raw water; S-111 KOH; S-401 CO₂ purification chemicals; S-402 catalyst; S-403 W-201 pretreatment/DI reagents; S-404 F-101 guard/filter media; S-405 W-501 wastewater treatment reagents.
- **Energy/utility inputs:** U-001 electrolyser electricity; U-009 other plant electricity; U-002 cooling water; U-004 steam/hot utility; U-005 instrument air; U-006 nitrogen.
- **Utility returns:** U-003 cooling-water return; U-010 steam condensate/hot-fluid return if applicable.
- **Product/coproduct outputs:** S-314 methanol product dispatch; S-109 oxygen coproduct or controlled disposition.
- **Waste/emissions outputs:** S-308 treated wastewater; S-311 treated off-gas; S-315 spent media/filter solids; S-316 wastewater sludge; S-317 spent catalyst.
- **Conditional/non-present services:** U-007 fuel gas and U-008 combustion/process air are not selected in this configuration.

## 8. Process/equipment register

The PFD contains 28 equipment/package tags: V-101, F-101, P-101, K-101, W-201, ELY-201, D-201, K-201, O-201, M-301, HX-301, R-301, E-302, V-301, SP-301, K-301, PCV-301, V-302, T-401, E-401, V-401, E-402, P-401, TK-401, U-501, W-501, SW-501 and DR-501.

The Stream Register workbook's Equipment Register includes the process justification, package status and open data/design dependencies for each tag. No datasheets, operating conditions, design pressure/temperature, dimensions, metallurgy, nozzle schedule, relief basis or vendor performance data are selected in this phase.

## 9. Boundary-sensitive missing units and interfaces

The following decisions could change the flowsheet, battery-limit streams or energy/environmental KPIs:

1. **CO₂ source facility and purification technology:** source pressure/composition may add upstream compression, water/acid-gas removal, solvent regeneration heat, sweep gas, purge or recovery streams.
2. **Off-gas treatment:** recovery, fuel use, flare, thermal oxidiser or controlled vent would change fuel gas, combustion air, stack emissions, heat recovery and safety boundaries. No option is selected.
3. **Electrolyser vendor integration:** gas separators, dryers, electrolyte purge/filtration, H₂ buffer/storage, O₂ purification/compression and cooling may be inside or outside the vendor package. Vendor battery limits must reconcile with S-104 to S-112 and U-001.
4. **Steam source:** an external steam supply uses U-004/U-010; an onsite boiler would add fuel, combustion air, boiler feedwater, blowdown, stack emissions and a new utility-generation control volume.
5. **Cooling system:** once-through water, cooling tower, air cooler or chilled water changes water withdrawal, makeup, blowdown, power and thermal discharge. Cooling-water blowdown/makeup are not yet stream IDs.
6. **Water reuse:** S-309 is conditional and may require RO/EDI/polishing; reuse is not credited until water analysis and DI quality requirements are met.
7. **Oxygen disposition:** an actual consumer could require O₂ drying, purification, compression, buffer storage and additional safety systems. No sale or vent credit is assumed.
8. **Product storage/loading:** tank type, nitrogen blanketing, vapour recovery, loading arms and tank vents may add N₂, electricity, product vapour and emissions streams.
9. **Relief/blowdown and emergency vent system:** PSVs, depressuring, emergency shutdown vent routing, flare/oxidiser and dispersion basis are not shown on this PFD. They must be developed from code, HAZID/HAZOP and relief scenarios; do not infer a flare.
10. **Catalyst commissioning/maintenance:** activation/reduction gas, nitrogen purging, catalyst loading, fines collection and spent catalyst handling may add temporary material/vent streams.
11. **Cooling tower/utility-system boundaries:** makeup, blowdown, chemical dosing and heat rejection need separate streams once the cooling concept is selected.
12. **Stormwater, sanitary sewage, firewater and offsite emergency utilities:** not shown as routine process streams; screen and include in site/environmental boundary as appropriate.

## 10. PFD consistency and handoff

- PFD material-stream arrows: **55**, each with a unique S-ID.
- Stream Register material rows: **55**, including S-315/S-316/S-317 waste-dispatch exits plus separate chemical supply streams S-404/S-405.
- Utility interfaces: **10** in the Utility Register; 8 are drawn as current/conditional connection lines, while U-007/U-008 remain unselected hold points.
- Equipment/package tags: **28**.
- Battery/context interfaces: **28**.
- Balance control volumes: **7**.

The Stream Register workbook includes the PFD Cross-check sheet. The editable `.drawio` file, SVG source, PNG and PDF share drawing number ENERGY008-PFD-001 and Rev 0.1-DRAFT. PFD labels and register IDs must be updated together under change control.

**Prompt 8 handoff:** use the tagged equipment register, 55-row stream register, utility register, 28-interface battery-limit register and CV definitions as the process configuration baseline. Numerical stream states remain blocked pending approved G3 design basis, source assay, vendor data, validated mixture properties and subsequent material/energy balances. Do not treat this PFD as an approved route or a construction drawing.
