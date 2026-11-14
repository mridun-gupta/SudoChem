# ENERGY-008 | Prompt 13 Safety Study Limitations and Preliminary HAZID

**Document:** ENERGY008-SAFETY-001  
**Revision:** 0.1-DRAFT  
**Date:** 1 November 2026  
**Project:** Green methanol synthesis: utility integration and energy KPIs  
**Status:** Preliminary screening only. Not approved for construction, procurement, statutory submission, commissioning or operation.

## 1. Executive summary

This package identifies process-specific hazards and records preliminary safeguards, cause/effect requirements, relief scenarios, materials questions and proposed safe-state principles for the conceptual Route C flowsheet. It is intended to prepare the project for formal process-safety studies.

**It is not a completed HAZOP, LOPA, SIL assessment, QRA, hazardous-area classification, relief-device design, fire-protection design, emergency-response plan, materials selection report or code-compliance certificate.**

The Route C selection remains provisional. The process design basis is Prompt 3 Rev 0.1-DRAFT and has not been frozen. The project site is not selected. The Prompt 7 PFD is conceptual and is not a P&ID. Prompts 8–10 did not produce a solved physical plant material/energy/exergy balance, and Prompt 11 equipment ratings are predominantly screening-only or blocked. Therefore actual inventories, compositions, operating limits, relief loads and safety-system setpoints are not established.

The registers deliberately distinguish:
- **Existing design provision:** information actually present in the current PFD or design basis.
- **Proposed safeguard:** an item for design or study, not an installed or credited safeguard.
- **Required action:** work needed to close the hazard.
- **Action priority:** P1/P2 indicates engineering sequence only. No risk ranking is implied.

## 2. Basis, operating envelope and scope

### 2.1 Route and flowsheet

The primary case is Route C: biogenic CO₂ receipt and conditioning, pressurised alkaline electrolysis for renewable H₂, high-pressure methanol synthesis, recycle/purge, methanol-water purification, product storage and off-gas/wastewater handling. Route A (industrial CO₂ + renewable H₂) and Route B (biomass gasification to syngas) remain alternatives and require route-specific hazard reviews. Route B introduces additional hazards not fully represented here, including biomass storage/self-heating, gasifier high-temperature operation, tar/particulate handling, syngas toxicity/flammability, char/ash and possible air/oxygen gasification systems.

### 2.2 Draft operating reference

| Item | Current screening reference | Status |
|---|---:|---|
| Minimum stable methanol production | 25 t/day | Draft operating envelope |
| Normal methanol production | 50 t/day | Illustrative reference only |
| Maximum continuous production | 55 t/day | Draft operating envelope |
| Process design capacity | 60.5 t/day | Draft design capacity, includes 10% above maximum continuous |
| Synthesis nominal condition | 7 MPa(a), 250°C | Draft process reference, not mechanical design |
| Broad synthesis range | 5–10 MPa(a), 200–300°C | Literature/screening envelope only |
| ALK H₂ outlet interface | 20 bar(a) nominal assumption; 15–30 bar(a) sensitivity | Draft interface assumption |
| Draft dry-gas purity targets | CO₂ ≥99.5 mol%; H₂ ≥99.9 mol% | Screening assumptions, not guarantees |
| Stoichiometric H₂:CO₂ | 3:1 molar | Fresh-feed stoichiometric anchor only; not synthesis-loop composition |

No pressure or temperature above is a design pressure, MAWP, design metal temperature, trip limit, relief set pressure or permitted operating limit. Those values require approved design conditions and mechanical calculations.

### 2.3 Nodes and tags

The formal HAZOP node list is proposed in the `HAZOP Nodes` sheet of `ENERGY008_HAZID_WhatIf.xlsx`. It covers:
1. CO₂ receipt and conditioning: V-101, F-101, P-101.
2. CO₂ compression: K-101.
3. Water treatment and alkaline electrolyser: W-201, ELY-201, O-201.
4. H₂ drying, purification, compression and buffer: D-201, K-201.
5. O₂ handling: O-201 and BL-O01.
6. Feed mixing and recuperation: M-301, HX-301.
7. Synthesis reactor: R-301.
8. Effluent cooling and high-pressure separation: E-302, V-301.
9. Recycle and purge: SP-301, K-301, PCV-301.
10. Liquid letdown/degassing: V-302.
11. Distillation/reflux: T-401, E-401, V-401, E-402.
12. Product transfer/storage: P-401, TK-401.
13. Off-gas collection/treatment: U-501.
14. Wastewater/drains/solid waste: W-501, SW-501, DR-501.
15. Plant utilities, electrical, instrument air, N₂, ESD, relief, vents, layout and emergency systems.

## 3. Process-specific hazard themes

### 3.1 Hydrogen and electrolyser

Hydrogen is a highly flammable, low-density gas that can leak through small clearances, permeate seals, accumulate at high points/enclosures and ignite from electrical, static, hot-surface or mechanical sources. The ALK package adds DC electrical hazards, KOH handling, gas-separation/diaphragm failure, H₂-in-O₂ and O₂-in-H₂ crossover, differential-pressure excursions, water-quality failure, cooling loss and pressure-control failures.

A hydrogen detector and ventilation concept must be developed from a release-source and dispersion study, not simply by placing detectors at arbitrary points. Detector technology, coverage, alarm/trip setpoints, voting, environmental effects, calibration and failure response require engineering. PESO's 2025 SMPV(U) amendment introduced a definition for a bulk compressed hydrogen system above 5,000 standard cubic feet (about 141.6 Nm³) and includes associated generation/compression and transfer elements in its scope definition. For hydrogen facilities within the statutory scope, the 2025 amendment includes visual/audible gas-detection alarm and emergency-shutdown provisions; the scoped flammable-gas alarm criterion is no higher than 25% LEL, with specified H2 detection and ESD arrangements. This is a statutory-scope check, not a generic setpoint recommendation for every detector. Whether and how those provisions apply to the final configuration must be confirmed with PESO/legal review.

### 3.2 Oxygen

Electrolyser oxygen can enrich an area and greatly intensify combustion. O₂ must not share a vent or disposal header with H₂, hydrocarbon/methanol vapour or incompatible process gases. Materials, valves, regulators, instruments, seals and cleaning must be reviewed for oxygen service. Oil/grease and particulate contamination can create ignition hazards, particularly during rapid pressurisation or adiabatic compression. No O₂ offtake, product specification, storage or disposal basis is currently selected.

### 3.3 CO, CO₂ and synthesis gas

CO may be present in the synthesis/recycle loop through the reverse water-gas-shift reaction and can be present in purge or off-gas. It is acutely toxic and requires exposure-control, detector and emergency-response review. CO₂ is an asphyxiant; release can displace oxygen and accumulate in low-lying or poorly ventilated spaces. Neither hazard is adequately controlled by odour or visual observation.

### 3.4 Methanol

Methanol and methanol-rich vapours are toxic and flammable. Potential releases include pump seals, column and condenser connections, tank vents, sampling points, loading/transfer connections, drains and wastewater treatment. Exposure routes, closed sampling, spill containment, ventilation, ignition control, tank overfill, venting, static control, fire protection and emergency access require review. Off-spec product must be segregated from the on-spec product system pending disposition.

### 3.5 Pressure, temperature and utility upsets

Credible high-pressure cases include blocked outlet, control valve failure, compressor discharge blockage, thermal expansion of trapped liquid, fire exposure, regulator failure, tube rupture, pressure-control failure and loss of downstream demand. Thermal risks include reactor hot spots, loss of heat removal, abnormal heat input, exchanger tube leak, loss of condenser/reflux, reboiler overheat, low-temperature effects during letdown/depressurisation and thermal cycling.

Loss of electrical power, cooling water, instrument air, nitrogen or control systems can produce common-cause failures. The project must define which functions are powered from emergency/UPS supplies and which rotating equipment or process segments are tripped/isolated first. No generic valve fail position is assigned.

### 3.6 Catalyst, chemicals, wastes and maintenance

Catalyst and guard media can retain methanol, H₂, CO, source contaminants or other adsorbed compounds. Fresh, reduced, spent and passivated catalyst may have different handling requirements. Use supplier SDS and validated handling/passivation procedures; do not assume all catalyst is pyrophoric or inert. KOH is corrosive and can cause chemical burns; concentration, temperature and compatible wetted materials are unknown. Wastewater may contain methanol, KOH, salts, metals, catalyst fines and treatment chemicals. Incompatible waste mixing, uncontrolled vapour generation, overflow and unapproved discharge are credible concerns.

Maintenance hazards include residual pressure, trapped liquid, toxic/flammable gas, oxygen enrichment, nitrogen asphyxiation, hot surfaces, rotating equipment, electrical stored energy, catalyst exposure, confined space and line-breaking. Permit-to-work, LOTO, positive isolation where needed, gas testing, purge verification, entry/rescue planning and contractor competence must be addressed in site procedures.

## 4. Preliminary safeguards and cause/effect design basis

The `ENERGY008_Safeguard_and_CauseEffect_Register.xlsx` contains 29 proposed function records and 16 safe-state principles. Typical design requirements to be developed include:

| Hazard / initiating condition | Proposed response to study | Important design caution |
|---|---|---|
| H₂ detector alarm / escalation | Audible and visual alarm, control-room annunciation, source isolation, electrolyser/compressor trip at defined escalation, ventilation, engineered H₂ vent route | No detector locations, alarm values or trip thresholds assigned; no uncontrolled atmospheric blowdown |
| O₂ crossover / oxygen impurity | De-energise or trip electrolyser; isolate affected gas headers; prevent H₂/O₂ cross-connection | Use OEM allowable crossover limits and independent verification |
| CO detector alarm | Alarm, evacuate/cordon, isolate remotely where practicable, trained emergency response | Do not attempt unprotected rescue |
| CO₂ release | Evacuate, isolate source, ventilate and test atmosphere | No reliance on odour; consider low areas and enclosed spaces |
| R-301 high-high temperature / loss of cooling | Stop reactant feeds, isolate reactor as defined, preserve available cooling and controlled pressure | No unvalidated quench or direct venting; model catalyst/reactor shutdown response |
| Compressor trip / surge | Trip driver, prevent reverse flow, preserve OEM anti-surge/seal utility functions during coastdown as applicable | Valve sequence must follow compressor dynamics and OEM requirements |
| V-301 / V-401 / TK-401 high-high level | Stop feed/transfer, protect downstream gas outlets, isolate loading/transfer as needed | Independent tank overfill protection must be evaluated |
| T-401 condenser failure / high pressure | Stop reboiler heat, reduce/isolate feed, preserve available cooling/reflux, isolate product transfer if needed | Pressure and vacuum protection are separate cases |
| Loss of power/instrument air | Execute node-specific trip/isolation sequence; retain independent power for detection, alarms, ESD, essential ventilation/fire systems | Fail position determined valve-by-valve from risk analysis |
| U-501 unavailable / high backpressure | Isolate or trip sources that cannot safely discharge; controlled shutdown | No bypass to atmosphere without composition, dispersion and permit review |
| Methanol spill/fire | Stop transfer, isolate source/receiver, containment and site emergency response | Tank bund, drains, firefighting media and loading ESD require dedicated design |

**No SIL level is proposed.** A function in the cause/effect workbook is not automatically a Safety Instrumented Function. Alarm, basic process control, interlock, mechanical protection and SIS allocation must be determined through hazard/risk assessment and independent-layer review. Reset and restart are intended to be deliberate and manual after cause investigation, equipment/safety-system readiness, gas testing and approved restart checks. ESD reset must not itself restart the plant.

## 5. Relief and vent-system cases

The `Relief Scenarios` sheet identifies 24 case families. These require case-specific evaluation, including:
- blocked outlet and upstream pressure-control failure;
- compressor discharge blockage, deadhead, surge or recycle/anti-surge failure;
- external fire exposure where credible for inventory and siting;
- exchanger tube rupture and cross-contamination between pressure sides;
- gas generation / electrolysis pressure-control failure and H₂/O₂ separator differential pressure;
- runaway-like or abnormal heat-input/temperature excursion where a credible reaction/thermal model supports it;
- cooling-water, instrument air, power or control failure;
- thermal expansion of blocked-in liquids;
- two-phase flashing and choked flow at V-302 letdown;
- column condenser/reflux loss, reboiler control failure, high pressure and vacuum/air ingress;
- tank overfill, vent blockage, vacuum, thermal breathing and fire case;
- vent/off-gas header blockage, treatment-package outage, backpressure and incompatible gas mixing;
- vacuum/air-ingress cases and external fire/common-cause scenarios.

Relief-device sizing requires approved design pressure and temperature, fluid composition and phase, relieving temperature, credible scenario rates, backpressure, simultaneous scenarios, allowable accumulation, inlet/outlet pressure drop, built-up/superimposed backpressure, two-phase methodology where needed, disposal-system hydraulics, dispersion and reaction/incompatibility review. API 520/521, ASME BPVC and applicable Indian/PESO requirements are candidate references only; select a code of record and relief philosophy before calculations. OISD-STD-106 may be relevant sector guidance where its scope is applicable.

**No PSV, rupture disc, set pressure, orifice, vent-header size or discharge destination is selected in this package.**

## 6. Preliminary materials compatibility / corrosion / fouling

The `ENERGY008_Materials_Compatibility_Register.xlsx` contains 28 service records and 15 review holdpoints. The key engineering questions are:

- **Hydrogen:** hydrogen-assisted cracking/embrittlement, fatigue, permeation, weld/HAZ hardness, strength, cycles, pressure and temperature; validate all metallic and non-metallic pressure-boundary items under the governing hydrogen code and actual design conditions.
- **Wet/dry CO₂:** dry CO₂ versus condensation/free-water service must be separated. Water plus CO₂ and source contaminants can create corrosive aqueous phases; obtain source assay for H₂S, SOx, NOx, O₂, chlorides, solvent carryover and particulates.
- **Synthesis gas:** review combined H₂/CO/CO₂/MeOH/H₂O composition, high pressure and metal temperature, welds, thermal cycling and catalyst contaminants.
- **Oxygen:** oxygen compatibility, ignition sensitivity, cleanliness and component non-metallic compatibility. No oil/grease contamination.
- **Methanol/water:** solvent compatibility for seals and gaskets, product contamination, wet-service corrosion, storage vent/roof and coating/lining compatibility.
- **KOH:** concentration/temperature-dependent caustic corrosion and stress-corrosion risks, diaphragm compatibility and OEM qualified wetted materials.
- **Catalyst/adsorbent:** supplier SDS, residual reactants, adsorbed contaminants, self-heating/passivation risk, metals analysis and waste classification.
- **Utilities/waste:** cooling-water chemistry, microbiological/under-deposit corrosion, steam/condensate corrosion, KOH/methanol wastewater compatibility and nitrogen purge interfaces.

No generic stainless-steel grade or polymer compatibility chart is a sufficient material selection basis. Candidate codes include ASME B31.3 for process piping, ASME B31.12 for hydrogen piping where applicable, ASME BPVC Section VIII for pressure vessels, and relevant API/ISO/BIS standards within their actual scope. ISO 11114-4 applies to metallic materials for gas cylinders and must not be treated as a universal process-piping material approval. The final material selection report must include design conditions, actual chemistry, material data, corrosion mechanism review, weld procedure, NDE, heat treatment/hardness where required, leak testing and inspection/monitoring plan.

## 7. Indian statutory and standards screen (reviewed 1 November 2026)

The Standards Matrix worksheet records type, edition/date, potential trigger, action, authority and official-source URL. The list below is a screening register, not a legal opinion.

### 7.1 Indian statutory instruments

1. **SMPV(U) Rules, 2016 and PESO amendments.** PESO's 25 June 2025 amendment G.S.R.374(E) introduced the bulk compressed-hydrogen-system definition and hydrogen-system provisions. The 5 June 2026 amendment G.S.R.448(E) is final. It permits ISO tank containers to be used for above-ground compressed-gas storage subject to a properly fixed foundation and structural-integrity certification by a structural engineer; it changes the permitted above-ground vessel group count to up to nine (subject to the rule); omits Rule 47; and revises ISO-tank compressed-gas import/transport permission provisions. The design team must assess final H₂ inventory and storage format against the consolidated Rules. Do not assume the 2026 amendment changes the 2025 5,000 scf bulk-H₂ definition.
2. **Gas Cylinders Rules, 2016 and amendments.** Conditional on cylinder/cascade storage, calibration gases or transport arrangements; check the latest 2026 gazette amendments and PESO approval/inspection requirements.
3. **MSIHC Rules, 1989 and Chemical Accidents Rules, 1996.** Inventory and concentration schedules must be assessed for H₂, CO, methanol, KOH and other hazardous chemicals. The rules may trigger notifications, safety reports, on-site/off-site emergency planning and crisis-group obligations at specified thresholds. No threshold can be concluded until inventories are frozen.
4. **OSHWC Code, 2020.** S.O.5321(E) dated 21 November 2025 brought the Code into force. Determine the appropriate government, facility coverage, registration, safety management, worker health and applicable central/state rules for the selected site.
5. **Water Act, Air Act, Environment (Protection) Act/Rules and EIA Notification, 2006.** Screen consent-to-establish/operate, effluent/emission conditions, water abstraction/discharge, and environmental-clearance applicability based on exact project activity and site. Do not assign category 5(f) automatically from the conceptual PFD.
6. **Hazardous and Other Wastes Rules, 2016 and amendments.** Characterise spent catalyst, guard/adsorbent media, filters, chemical residues and ETP sludge against current schedules. Waste classification, manifests, storage and authorised disposal/recycling depend on actual composition and analysis.
7. **Public Liability Insurance Act, 1991.** Check hazardous-substance inventory and statutory thresholds/insurance requirements.
8. **Boilers Act, 2025.** In force from 1 May 2025. Apply if an onsite boiler is included; Prompt 7 currently has a steam/hot utility interface but no onsite boiler selected.
9. **CEA (Measures relating to Safety and Electric Supply) Regulations, 2023 and 2026 amendment.** Applicable to electrical installation and use of electricity; use current notified text for ALK rectifier, motors, switchgear, earthing/bonding, protection, work and inspection.
10. **Fire and local approvals.** Fire NOC, factory/building approvals, land-use/siting, emergency access, water and firewater permissions and any local hazardous-industry requirements depend on the site.

### 7.2 Engineering standards and good practice

- **ISO 22734-1:2025** is the current published ISO safety standard for electrolysis-based hydrogen generators. Compare the ELY-201 OEM package against the Indian standard register's **IS 16509:2020**; verify current BIS status and the delta before procurement.
- **IS 16253:2016** is listed by BIS for stationary hydrogen detection. Verify current edition/reaffirmation and detector design.
- **IS 5572:2009** provides area-classification guidance for flammable gases/vapours; use with applicable IS 5571 and IEC 60079 series for electrical apparatus selection, installation and inspection.
- **IEC 61882:2016** is the HAZOP application guide; formal HAZOP needs defined nodes, guidewords, approved design intent, P&IDs and a multidisciplinary team.
- **IEC 61511-1:2016 + AMD1:2017** is the process-industry functional-safety lifecycle reference where SIS functions are required. It does not prescribe a SIL for this project.
- **OISD-STD-241:2024** is relevant hydrogen safety guidance for production/storage/transportation. Other candidate OISD standards include 106 (pressure relief/disposal), 109 (blowdown/sewer), 113 (hazardous-area classification), 114 (hazardous chemical handling), 116 (fire protection), 118 (layout), 128/129/130/132 (inspection of vessels/tanks/piping/PRDs). OISD documents are sector-specific; confirm applicability or authority/client adoption rather than assuming they are universally mandatory.
- **ASME BPVC VIII, ASME B31.3, ASME B31.12, API 520/521**, and applicable tank, exchanger and rotating-equipment standards are candidates for code-of-record selection and detailed calculations. The final edition and Indian statutory acceptance must be checked at design freeze.

## 8. Studies required before design release

At minimum, commission the following work with qualified, independent and appropriately competent specialists:

1. **Formal HAZOP** after P&IDs, line list, cause/effect, control narrative, operating limits, vendor package data and design intent are sufficiently mature. Use a competent facilitator and multidisciplinary team; track actions to closeout.
2. **LOPA and SIL assessment** for candidate safety instrumented functions only after HAZOP recommendations and initiating-event data are available. Then prepare SRS, independence/common-cause review, verification/validation and proof-test regime under the IEC 61511 lifecycle.
3. **QRA and occupied-building / siting risk assessment** for H₂, O₂, CO, CO₂ and methanol releases, fire/explosion, toxic exposure, escalation and emergency access where required by project risk and authority.
4. **Hazardous-area classification** by a competent engineer using final release sources, ventilation, gas groups, temperature classes, equipment protection levels and site layout.
5. **Relief and disposal system design** by process/relief specialists, including API 520/521 or selected code methods, two-phase cases, vent header hydraulics, dispersion and safe disposal route.
6. **Fire protection and emergency response design**: firewater/foam, detection, alarm, hydrants/monitors, emergency shutdown stations, access, muster points, mutual aid, site/off-site plans, spill containment and drills as required.
7. **Materials selection and corrosion study** based on actual impurity assays, process conditions, material properties, hydrogen effects, oxygen compatibility, KOH and methanol-water chemistry, weld qualification and inspection strategy.
8. **Package-specific safety reviews** with the ALK OEM, compressors, reactor/catalyst vendor, tank designer, off-gas treatment supplier and water/wastewater treatment vendor.
9. **Human factors / operability review**: sampling, isolation, access/egress, lifting/maintenance, catalyst handling, manual handling, confined-space entry and emergency response.
10. **Management of Change (MOC) and pre-startup safety review (PSSR)** after design and action closeout, before introduction of hazardous materials or commissioning.

A licensed/certified engineer or statutory competent person must verify all pressure equipment, statutory storage systems, electrical installations, boiler systems (if any), fire systems and other regulated equipment within their respective jurisdiction. This package makes no claim of statutory approval or code compliance.

## 9. Open design holdpoints and handoff to Prompts 14–15

The following must be passed forward as unresolved design inputs:

- Final route approval and site selection.
- Frozen design basis, operating cases and approved maximum/minimum P/T and pressure-cycle limits.
- Actual H₂, O₂, CO₂, CO, methanol and off-gas compositions and maximum inventories.
- P&IDs, line list, equipment datasheets, valve list, control narrative, electrical single-line and hazardous-area layout.
- Approved material and corrosion basis, source assay, catalyst/adsorbent SDS and waste characterization.
- Full numerical material, energy and utility balances; physical plant recycle, purge and off-gas loads.
- Vendor package safeguards and interface limits for ELY-201, compressors, reactor, tank and waste/vent packages.
- Relief, depressurisation, vent disposal and emergency power philosophy.
- Formal HAZOP/LOPA/SIL/QRA/area classification outcomes and action closeout.

### Prompt 14–15 handoff summary

**Carry forward:** 50 What-If/HAZID records, 24 relief-case families, 15 proposed HAZOP nodes, 29 preliminary cause/effect requirements, 16 safe-state principles, 28 compatibility records and 15 materials holdpoints.

**Do not carry forward as approved:** alarm/trip setpoints, valve fail positions, detector thresholds, SIL values, relief sizing, vent destinations, final metallurgy, corrosion allowance, statutory compliance or emergency response instructions.

---

## 10. Official sources and catalogues

1. PESO, SMPV(U) Amendment Rules 2026, G.S.R.448(E), 5 June 2026: https://peso.gov.in/web/sites/default/files/2026-06/SMPV%20Amendment%20Rules%202026%2005-06-2026.pdf
2. PESO, SMPV(U) Amendment Rules 2025, 25 June 2025: https://peso.gov.in/web/en/smpvu-amendment-rules-2025-25062025
3. PESO sitemap / current Gazette notification index: https://peso.gov.in/web/en/sitemap
4. Ministry of Labour and Employment, S.O.5321(E), OSHWC Code effective 21 November 2025: https://labour.gov.in/sites/default/files/e-noti-osh-1.pdf
5. MoEFCC, Rules and Regulations (MSIHC and Chemical Accidents Rules): https://moef.gov.in/rules-regulations-3
6. India Code, Water Act 1974: https://www.indiacode.nic.in/indiacode/handle/123456789/1612
7. India Code, Environment (Protection) Act 1986: https://www.indiacode.nic.in/indiacode/handle/123456789/1876
8. MoEFCC, EIA / PARIVESH portal: https://parivesh.nic.in/
9. MoEFCC, Hazardous and Other Wastes Rules archive: https://moef.gov.in/index.php/rules-regulations-3
10. India Code, Boilers Act 2025: https://www.indiacode.nic.in/indiacode/handle/123456789/21395?view_type=browse
11. CEA, Notified Safety and Electric Supply Regulations and amendments: https://cea.nic.in/sub-sub-heading-view?lang=en&mappingId=653&subHeadingId=1036&subSubHeadingId=10091
12. ISO, ISO 22734-1:2025: https://www.iso.org/standard/82766.html
13. BIS, Indian hydrogen standards list: https://www.bis.gov.in/wp-content/uploads/2023/10/List_Standards_Hydrogen.pdf
14. BIS, IS 5572:2009 scope: https://www.services.bis.gov.in/php/BIS_2.0/bisconnect/Group_wise_standards_list/show_scope?row=MTIzNTQ%3D
15. IEC, IEC 61882:2016: https://webstore.iec.ch/en/publication/24321
16. IEC, IEC 61511-1:2016+AMD1:2017: https://webstore.iec.ch/en/publication/61289
17. OISD, current standards catalogue: https://oisd.gov.in/oisd-standards

**Document control:** This safety package is a planning aid for qualified engineering teams. It must be updated after route/site approval, design-basis freeze, P&IDs, vendor data, inventory calculations and formal studies.
