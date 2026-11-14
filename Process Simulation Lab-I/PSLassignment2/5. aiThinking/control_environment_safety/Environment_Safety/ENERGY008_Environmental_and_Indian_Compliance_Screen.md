# ENERGY-008 Prompt 12 — Utility, Water, Emissions and Waste Assessment

**Package:** `ENERGY008-UTILITIES-ENV-0.1.0`  
**Date:** 1 November 2026  
**Basis status:** Prompt 3 Rev 0.1-DRAFT; G3 not frozen; no selected process site  
**Working configuration:** Route C, biogenic CO₂ + renewable electrolytic H₂ using ALK as the reference electrolyser. Route C remains a working selection, not a closed route-gate approval.

## 1. Executive status

This package is a **reference utility and environmental screening ledger**, not a completed utility/water/emissions balance. Prompts 8–10 did not deliver a solved physical plant material balance or plant energy balance. Actual process-stream flow rates, compositions, temperatures, pressures, duties, electricity demands, wastewater quantities and off-gas emissions remain unavailable. They are left blank and marked `BLOCKED_NOT_CALCULATED`.

The package quantifies:
- the 50 t/day ideal stoichiometric feed and water anchors for Base C and Alternative A;
- the ideal clean-syngas synthesis block for Alternative B;
- the Prompt 11 K-201 hydrogen-compressor screening load;
- a clearly segregated CEA national-grid comparator for that one compressor load;
- the MNRE Green Methanol non-biogenic emissions ceiling and corresponding production-basis equivalents;
- the PFD stream register for wastewater, waste, off-gas and carbon accounting.

It does **not** claim full plant utility closure, water closure, GHG compliance, zero emissions, zero wastewater, zero waste, or permanent carbon removal.

## 2. Common boundary, annualisation and case comparison

### 2.1 Proposed reporting boundary

The project boundary follows Prompt 3/7: receipt of raw CO₂ source gas and external water/electricity/utilities through CO₂ conditioning, H₂ production/conditioning, methanol synthesis, purification, on-site storage and product dispatch. The upstream biogas digester/industrial source facility is outside the base gate-to-gate boundary, although source-gas recovery/conditioning from the raw-gas tie-in is included in the expanded engineering ledger. Transport and product use beyond the plant gate are excluded.

The MNRE Green Methanol Standard's non-biogenic emissions boundary specifically includes Green H₂ production, methanol synthesis, purification and on-site storage. The proposed engineering boundary must therefore remain aligned with the applicable MNRE MMRV/certification method when it is issued/applied.

### 2.2 Annualisation

| Input | Value | Status |
|---|---:|---|
| Normal capacity | 50 t/day | Illustrative benchmark-aligned basis |
| Annual on-stream hours | 8,000 h/y | Draft planning assumption |
| Average on-stream load factor | 90% | Draft planning assumption |
| Equivalent full-load hours | 7,200 h/y | Derived |
| Equivalent full-load days | 300 d/y | Derived |
| Annual product reference | 15,000 t/y | Derived, not guaranteed |

The annualisation method is `50 t/day × (8,000 h/y ÷ 24 h/day) × 0.90 = 15,000 t/y`. Annual water and energy references in this report use 300 equivalent full-load days or 7,200 equivalent full-load hours. They are not actual meter totals.

### 2.3 Ideal 50 t/day reaction-block comparison

| Quantity | Base C | Alternative A | Alternative B |
|---|---:|---:|---:|
| Methanol product-equivalent | 50.000 t/day | 50.000 t/day | 50.000 t/day |
| CO₂ feed, theoretical | 68.675 t/day | 68.675 t/day | Not the reactant in this block |
| CO feed, theoretical | Not applicable | Not applicable | 43.709 t/day |
| H₂ feed, theoretical | 9.437 t/day | 9.437 t/day | 6.291 t/day |
| Electrolyser water, stoichiometric | 84.336 t/day | 84.336 t/day | Not modelled / not an ALK case |
| DI water guidance | 84.934 m³/day | 84.934 m³/day | Not applicable to the ideal clean-syngas block |
| Total water guidance, inclusive of DI | 169.867–188.742 m³/day | 169.867–188.742 m³/day | Unavailable; gasifier and syngas-cleaning water unmodelled |
| Reactor reaction water | 28.112 t/day | 28.112 t/day | No water in ideal CO + 2H₂ → CH₃OH block |
| O₂ electrolysis coproduct | 74.899 t/day | 74.899 t/day | Not calculated |
| Actual utilities, emissions and waste | Blocked | Blocked | Blocked |

Base C and Alternative A have the same ideal reaction stoichiometry. Their real utility/emissions performance may differ because CO₂ source pressure, impurities, purification/recovery and upstream carbon allocation differ. Alternative B is only an ideal clean-CO synthesis block: biomass feed, gasification, syngas cleaning, char, tar, ash, water/steam and gasifier utility requirements are not modelled. These are not complete route comparisons.

## 3. Utility balance

### 3.1 Quantified electrical reference

The only equipment electrical load with a substituted numerical calculation is K-201 from Prompt 11.

| Parameter | Normal-case screening value |
|---|---:|
| H₂ flow | 393.212 kg/h |
| Suction / discharge | 20 / 70 bar(a) |
| Stages | 2, equal pressure ratio |
| Isentropic efficiency | 75% (analyst assumption) |
| Motor efficiency | 95% (analyst assumption) |
| Motor input | 271.703 kW |
| Shaft power | 258.117 kW |
| Intercooler duty | 129.059 kW |
| Aftercooler duty | 129.059 kW |

This is a pure-H₂ ideal-gas screening calculation. It is not a compressor vendor rating and omits real-gas compressibility, line losses, equipment-map limits, auxiliaries, seal systems and driver-specific guarantees.

Annualised at 7,200 equivalent full-load hours:
- K-201 electricity: **1,956,258 kWh/y**;
- K-201 partial specific electricity: **130.417 kWh/t methanol**.

This is a **partial component-only** specific energy, not gross or net plant electricity. Electrolyser stack/rectifier/BOP, K-101, K-301, pumps, cooling, controls, water treatment and other auxiliaries are not included. Gross and net specific energy for the plant are therefore **not calculable**.

### 3.2 Grid comparator only

The Central Electricity Authority's Version 22.0 guide (August 2026) reports an FY 2025–26 all-India weighted-average grid factor of 0.675 tCO₂/MWh, equivalent to 0.675 kgCO₂/kWh. It is used here only to illustrate a **grid-electricity comparator** for the K-201 screening load:
- K-201 annual comparator emissions: **1,320.474 tCO₂/y**;
- K-201 comparator intensity: **88.032 kgCO₂/t methanol**.

This is not a site-specific power factor or a measurement. It must not be applied as the emissions factor for eligible renewable electricity. No zero emissions factor is assigned to renewable electricity: the project must supply PPA/contract and generation evidence, metered grid import, banking/storage/dispatch records and the applicable MNRE MMRV treatment. Project-specific renewable and grid shares remain blank.

### 3.3 Utility service status

| Utility | Current status |
|---|---|
| Electrolyser electricity and rectifier | Blocked pending OEM SEC/performance map, stack configuration and metered power boundary |
| CO₂ compression and purification power | Blocked; raw feed composition, suction state, recovery and compressor map missing |
| H₂ compression K-201 | Screening-only result above |
| Recycle compression K-301 | Blocked; no converged recycle flow or composition |
| Pumps P-101/P-401/water/waste | Blocked; flow, head, NPSH and pump efficiencies absent |
| Cooling water supply/return U-002/U-003 | Blocked; no duties, cooling range, utility inlet/return conditions or cooling-tower basis |
| Chilled water/refrigeration | Not selected; no pinch/cold-end requirement or duty |
| Steam/hot utility U-004 | Blocked; no reboiler duty, steam grade, condensate return or source |
| Instrument air U-005 | Blocked; instrument/actuator list and pressure/dew-point requirement absent |
| Nitrogen U-006 | Blocked; purge/inerting volumes and HAZOP requirements not established |
| Fuel gas/combustion air U-007/U-008 | PFD hold points; no fired boiler, flare or oxidiser selected in the current configuration |
| General plant power U-009 | Blocked; complete connected/load list absent |
| Utility condensate/hot-fluid return U-010 | Conditional; no steam source selected |
| Wastewater treatment utility | Blocked; treatment technology, hydraulic/contaminant load and discharge/reuse endpoint absent |

Cooling-water circulation is not the same as water consumption. A utility-water balance requires circulation flow and duty separately from tower make-up, evaporation, drift and blowdown. Internally recovered heat through HX-301 remains only a candidate; no recovery credit or utility reduction has been booked.

## 4. Water balance

### 4.1 Route C/A theoretical water sub-balance at 50 t/day

Electrolysis requires one mole of water per mole of hydrogen generated. The ideal route C/A material balance therefore gives:
- electrolyser chemical water consumption: **84.336 t/day**;
- reaction water generated by CO₂ hydrogenation: **28.112 t/day**;
- net stoichiometric chemical water consumption: **56.224 t/day**.

This is a reaction stoichiometry sub-balance. It is not the external raw-water intake. The reaction water's actual phase, recovery, contamination, separation and reuse to the electrolyser are unknown.

Prompt 3's sourced guidance is:
- DI water: **9 L/kg H₂**, or **84.934 m³/day** at the 50 t/day reference;
- total water: **18–20 L/kg H₂**, or **169.867–188.742 m³/day**.

The 18–20 L/kg H₂ total-water guidance includes DI water and purification/process cooling. It is not an additional volume to add on top of the 9 L/kg H₂ DI figure. The arithmetical guidance beyond DI is 84.934–103.808 m³/day, but this is not a measured or designed allocation between cooling, wash, process make-up, treatment losses and other consumers.

Using 300 full-load-equivalent days/year:
- DI guidance: **25,480 m³/y**;
- total process-water guidance: **50,960–56,622 m³/y**;
- stoichiometric electrolyser water: **25,301 t/y**;
- reaction water generation: **8,434 t/y**;
- net stoichiometric water consumption: **16,867 t/y**.

Annualised guidance remains indicative only. No water abstraction or purchase quantity is approved.

### 4.2 Missing water flows and closure

The PFD water/wastewater routes include S-101 raw site water, S-102 DI feed, S-103 treatment reject, S-105 H₂-dryer condensate, S-110 O₂-handling condensate, S-307 water-rich column bottoms, S-308 treated effluent, S-309 conditional reuse and S-313 cleaning/maintenance drains. Their actual flows and analyses remain blank.

A full water balance cannot close because raw-water intake, DI recovery/reject, cooling tower evaporation/drift/blowdown, cleaning use, condensate recovery, wastewater split, product/moisture water, sludge moisture and accumulation are unknown. S-309 is not credited as reuse without a quantified flow and quality acceptance. Cooling-water circulation is not counted as make-up or external water consumption.

### 4.3 Alternative B water

The ideal CO + 2H₂ → CH₃OH reaction block has no water in its stoichiometric reaction. That does **not** mean Alternative B has zero water demand: gasifier steam/moisture, gas cooling, scrubbing, tar washing, boiler make-up, cooling tower make-up and wastewater require a separate gasification/conditioning model. Those values are unavailable.

## 5. Carbon, GHG and emission streams

### 5.1 Carbon transfer reference

At the 50 t/day ideal reference:
- Base C / Alternative A: CO₂ feed = 68.675 t/day; carbon in methanol = approximately 18.743 tC/day, equivalent to 68.675 tCO₂/day.
- Alternative B: CO feed = 43.709 t/day; carbon in methanol is the same 18.743 tC/day in the ideal reaction block.

The 100% carbon transfer in the reference block is a result of the one-reaction stoichiometric construction. It is not actual plant carbon conversion/utilisation. Actual feed impurity, incomplete conversion, purge, purge recovery, off-spec product, dissolved carbon, vent losses and upstream/downstream allocation are not quantified.

Carbon from biogenic CO₂ is not automatically a permanent removal. Industrial-source CO₂ in Alternative A also does not create an automatic avoided-emission credit; source ownership, counterfactual, custody transfer and allocation must be documented. Product use/combustion beyond the plant gate is excluded from the proposed gate-to-gate boundary.

### 5.2 MNRE Green Methanol Standard

MNRE's Green Methanol Standard dated 27 February 2026 specifies a maximum of **0.44 kg CO₂e/kg methanol**, averaged over the preceding 12 months, for non-biogenic GHG emissions arising from Green H₂ production, methanol synthesis, purification and on-site storage. It recognises CO₂ from biogenic sources, DAC or existing industrial sources, and states that the detailed MMRV/certification methodology is to be specified by MNRE.

At a 50 t/day output reference, the numerical cap equivalent is 22 tCO₂e/day; at 15,000 t/y it is 6,600 tCO₂e/y. These are threshold equivalents, not project emissions. The current case is **not assessable** against the standard because electrolyser/plant electricity, direct process emissions, fugitive emissions and other non-biogenic sources are missing.

### 5.3 Emission source inventory

The required monitoring and accounting list includes:
- Scope 2: ELY-201/rectifier, K-101, K-201, K-301, pumps, cooling, controls and auxiliaries;
- direct process offgas: S-007 CO₂ purification reject, S-207 loop purge, S-211 degassing gas, S-306 distillation noncondensables and S-311 treated offgas outlet;
- fugitives: hydrogen, CO₂, methanol and VOC-containing equipment/services;
- fuel combustion: U-007/U-008 remain hold points; no fired equipment has been selected in the current conceptual configuration;
- route-specific upstream sources: biogenic-source processing, industrial CO₂ allocation or biomass/gasifier emissions, depending on route.

No actual mass emission rate can be calculated from the present data. S-311 is not assumed clean, permitted or emission-free; gas flow, speciation, control efficiency, monitoring and consent conditions must be defined.

## 6. Waste, by-products and recovery

### 6.1 Current PFD waste/residual list

| Stream | Description | Required next step |
|---|---|---|
| S-002 / S-009 | CO₂-side knockout/compressor condensate | Analyse source contaminants; segregate and determine recovery/treatment |
| S-005 / S-315 | Spent CO₂ filter/guard media and captured solids | Identify media and contaminant loading; assess regeneration/recycler route |
| S-007 | CO₂ purification reject/offgas | Measure CO₂ slip/impurities; evaluate recovery before treatment |
| S-103 | Pretreatment/DI reject | Analyse salts/regenerant; quantify recovery and brine handling |
| S-105 / S-110 | H₂ dryer and O₂ handling condensates | Confirm electrolyte/alkali carryover; segregate/recover where quality allows |
| S-112 | KOH bleed/spent electrolyte | Verify concentration/contaminants; OEM return/reconditioning or authorised treatment |
| S-207 / S-211 / S-306 | Synthesis purge, degassing gas and distillation noncondensables | Flow/GC/VOC analysis; assess recovery/recycle/treatment; no assumed direct vent |
| S-307 | Water-rich column bottoms | Quantify methanol loss/COD; evaluate methanol recovery and wastewater treatment |
| S-308 | Treated effluent | Confirm quality and consent before reuse/discharge |
| S-310 / S-316 | Wastewater sludge | Characterise, dewater and classify before recovery/TSDF |
| S-311 | Treated offgas outlet | Define treatment/stack/vent design and monitor before release |
| S-312 / S-317 | Spent catalyst/fines | Obtain catalyst composition/SDS and supplier take-back or metal recovery route |
| S-313 | Cleaning/sampling/maintenance drains | Segregate incompatible/solvent/caustic drains; avoid dilution into general wastewater |

These stream names are not legal hazardous-waste determinations. Waste classification must follow process origin, material SDS, applicable schedules and representative laboratory characterisation. No waste quantities or disposal costs are available.

### 6.2 Recovery priorities

1. **Closed-loop hydrogen/CO₂ recovery from purge and offgas:** only after purge composition/inert build-up and recycle model are available. Evaluate membranes/PSA or equivalent recovery and quantify the energy penalty.
2. **Methanol recovery from column bottoms and vents:** quantify dissolved methanol and VOCs, then evaluate flash/stripping/condensation or return to purification.
3. **Reaction-water and condensate reuse:** segregate and analyse water from the synthesis/product train; reuse only if it meets the electrolyser or other utility-user quality requirements.
4. **Spent media and catalyst take-back:** request supplier regeneration/recycling or metal recovery options before classifying for disposal.
5. **Wastewater source segregation:** keep KOH, high-COD methanol streams, saline DI reject and clean condensates separate to avoid increasing treatment demand.

No recovery percentage or environmental saving is claimed because none has been modelled.

## 7. Indian regulatory and environmental compliance screen

**Project site is not selected.** The approval authority and state-specific requirements therefore cannot be finalised. The following is a screening register, not a legal opinion or permit determination.

| Instrument / authority | Potential applicability | Required project action | Status |
|---|---|---|---|
| EIA Notification 2006, Schedule item 5(f) | Synthetic organic chemicals industry includes basic organic chemicals. A methanol plant should be screened under item 5(f); category depends on site and notified industrial-area status, and any relevant amendments/conditions. | Obtain written project classification. Determine Category A/B and appraisal authority (MoEFCC/EAC or SEIAA/SEAC as applicable); obtain prior EC if required before construction. | Site/classification open |
| Air (Prevention and Control of Pollution) Act 1981 and Uniform Consent Guidelines (2025, amended 2026) | Process vents/offgas and any fuel combustion or fugitive emissions; industrial unit consent requirements depend on category and state. | Apply for Consent to Establish and Consent to Operate from applicable SPCB/PCC; establish stack/vent inventory, control devices, monitoring and conditions. Check consolidated consent/authorisation procedure. | Applicable screening required |
| Water (Prevention and Control of Pollution) Act 1974, section 25 | New industry/process or treatment/disposal system likely to discharge sewage/trade effluent to stream, well, sewer or land generally requires prior State Board consent, subject to statutory exemptions. | Establish water source, drains, discharge/reuse points, wastewater treatment and effluent characteristics; obtain consent and comply with conditions. | Applicable if discharge / outlet |
| Environment (Protection) Rules 1986, Schedule VI | General effluent standards, alongside any more specific industry or consent limits. | Test effluent for parameters relevant to the selected discharge route and comply with site-specific/sector-specific conditions. General pH range in Schedule VI is 5.5–9.0; receiving-media columns and other parameters differ. | Limits not yet set |
| Hazardous and Other Wastes (Management and Transboundary Movement) Rules 2016, as amended (including 2024) | Applies to listed or otherwise characterised hazardous and other waste categories; spent electrolyte, catalyst, contaminated adsorbent and sludge need classification. | Characterise each waste stream; obtain authorisation where required; segregate, label, store, manifest, transport and send to authorised recycler/TSDF as applicable. | Waste classification open |
| Solid Waste Management Rules 2026 | Municipal/domestic/commercial solid waste generated at plant. Rules supersede 2016 SWM Rules and are effective from 1 April 2026. | Segregate the four waste streams at source and manage through authorised local channels. Check Bulk Waste Generator status if water consumption ≥40 kL/day, solid-waste generation ≥100 kg/day or floor area ≥20,000 m². The 50 t/day water-guidance range (169.9–188.7 kL/day) is above the water trigger, so this deserves an early site check, but guidance is not metered actual consumption. | Likely trigger to verify with actual data |
| Manufacture, Storage and Import of Hazardous Chemical Rules 1989 (MSIHC) | Hydrogen and methyl alcohol are listed in Schedule 1; Schedule 4 includes organic-chemical installations using hydrogenation and distillation. Application of specific duties remains threshold- and activity-dependent. | Complete maximum on-site inventory and SDS register; aggregate inventories and assess the applicable Schedule thresholds, safety report, on-site emergency plan, notification and disclosure duties. Do not infer threshold applicability from chemical listing alone. | Prompt 13 critical |
| Static and Mobile Pressure Vessels (Unfired) Rules 2016, amended 2025 and 2026; PESO | Bulk compressed hydrogen gas system definition includes systems exceeding 5,000 scf (141.6 Nm³) and includes electrolyser, compressor, buffer storage and associated equipment. | If the P11 2-hour 50%-shortfall buffer scenario is adopted, ~475.8 kg H₂ corresponds to ~5.3 thousand Nm³, above the 141.6 Nm³ definition threshold in the 2025 amendment; confirm the applicable licensing/approval route with PESO. The 5 June 2026 amendment also changes ISO-tank-container permissions and certain storage provisions, so the latest consolidated rules must be checked against the final storage configuration. | Conditional on buffer/storage design |
| Boiler Act 2025 / applicable boiler rules | Only if an on-site boiler is subsequently selected. Current PFD has an external steam/hot utility interface and no fired boiler selected. | If an on-site boiler is chosen, verify registration, inspection, certification and operating requirements with the competent boiler authority. | Not selected |
| Groundwater abstraction / CGWA or State groundwater authority | Applies if the selected water source is groundwater; requirements vary with location and current categorisation. | Confirm source, entitlement/NOC and any state-specific abstraction conditions before design. | Source not selected |

### 7.1 Site-dependent state consent

If a Haryana site is eventually chosen, Haryana publicly stated that it adopted the Water (Prevention and Control of Pollution) Amendment Act, 2024 on **2 September 2026**. This must not be treated as a site selection or as an automatic exemption from consent. The Haryana State Pollution Control Board is the relevant state authority for applicable consents. For any other state, re-check the then-current state adoption, rules and SPCB/PCC procedure.

### 7.2 Legal requirements versus good engineering practice

**Legal/permit-driven items (subject to applicability and final classification):**
- prior environmental clearance when the EIA Notification requires it;
- Air/Water consent and compliance with consent conditions;
- permitted air/effluent discharge and monitoring requirements;
- hazardous-waste authorisation, records, manifests and authorised disposal where applicable;
- MSIHC and PESO duties if inventory/process thresholds and definitions are met;
- groundwater permissions if abstraction is selected;
- boiler registration/inspection if an on-site boiler is selected.

**Good engineering practice (not asserted as universally mandated by a single statute):**
- metering and sub-metering of electrolyser, compressors, pumps and utility consumers;
- closed recovery of CO₂/H₂/methanol-rich purge and vent streams where safe and economic;
- segregated wastewater collection, source control and water reuse;
- LDAR for hydrogen, CO₂ and VOC service;
- supplier take-back for catalyst/adsorbents/electrolyte where practicable;
- site-specific water stress assessment and cooling-water optimisation;
- independent environmental legal register and permit-to-operate compliance audit.

## 8. Prompt 12 acceptance status and Prompt 13 handoff

### 8.1 Acceptance status

| Acceptance item | Status |
|---|---|
| Utility service inventory and battery-limit map | Prepared; quantitative balance blocked except K-201 screen |
| Gross/net plant SEC | Blocked; only K-201 partial SEC quantified |
| Water balance closure | Blocked; theoretical/guidance references only |
| Carbon/CO₂ reference balance | Stoichiometric reaction-block reference only |
| Direct/indirect GHG inventory | Source register prepared; only K-201 grid comparator quantified |
| Waste/offgas/wastewater register | PFD stream register mapped; actual quantities and classification blocked |
| Indian compliance screen | Current national screen prepared; site-specific permits/category and applicability open |

### 8.2 Prompt 13 hazardous inventory inputs

Carry forward for the HAZID/LOPA/process-safety and regulatory inventory review:
- hydrogen generation, compression, 2-hour shortfall buffer scenario (~475.8 kg / ~5.3 kNm³ at design rate), line-pack and any storage inventory;
- methanol tank, column/reflux/crude inventories, loading and transfer volumes (Prompt 11 inventory scenarios are not approved tank design);
- KOH electrolyte inventory, concentration and handling/waste route;
- catalyst type, mass, handling and regeneration/replacement plan;
- CO₂ source impurity inventory and any H₂S/contaminant removal media;
- filter/guard media, water-treatment chemicals, wastewater chemicals and cleaning solvents;
- nitrogen purge inventory and oxygen coproduct inventory/quality.

Obtain current SDS, maximum credible inventory per vessel and interconnected system, aggregate on-site quantities and schedule-threshold calculations before concluding MSIHC/PESO applicability.

### 8.3 Prompt 13 utility/environmental loads

Carry forward as **screening-only or blocked**:
- ELY-201 electrical capacity and cooling (OEM SEC/performance map required);
- K-201 normal screening motor input 271.703 kW; P11 process-design screening 522.199 kW;
- K-101 and K-301 compressor power (blocked);
- P-101/P-401 and water/waste pump power (blocked);
- cooling-water duties, supply/return and makeup/blowdown (blocked);
- E-402 reboiler/steam and condensate return (blocked);
- instrument air and nitrogen demand (blocked);
- wastewater and offgas treatment capacity (blocked);
- CO₂ source gas and O₂ product handling;
- S-007/S-207/S-211/S-306/S-311 offgas flow/speciation and S-002/S-103/S-105/S-110/S-307/S-313 wastewater flow/analysis;
- waste characterisation and annual mass of S-005/S-112/S-310/S-312/S-315/S-316/S-317.

## 9. Key project decisions needed to close Prompt 12

1. Freeze G3 design basis, route gate and site/location.
2. Select actual electricity procurement split and provide RE PPA/banking/storage records, electricity tariff and CEA reporting year.
3. Obtain ELY-201 vendor guarantee and full electrical/BOP utility loads.
4. Complete CO₂ and syngas feed assays and the physical material balance including recycle/purge and separations.
5. Complete Prompt 9 duties and utility-source conditions.
6. Select cooling system, steam source, water source, treatment process, wastewater disposition and offgas treatment.
7. Characterise waste streams and identify authorised recovery/disposal routes.
8. Confirm EIA category, SPCB/PCC consent path, hazardous inventory thresholds and PESO scope with the selected state/site.

**Conclusion:** Prompt 12 supplies a traceable utility/environmental register and useful ideal/reference quantities, but it cannot pass a plant-wide utility or environmental load as a design input yet. Prompt 13 should treat the listed inventories and partial loads as screening leads, not approved capacities or emissions.

## 10. Official references checked for this screening

1. **MNRE, Green Methanol Standard for India**, Office Memorandum No. 353/35/2022-NT, 27 February 2026:  
   https://cdnbbsr.s3waas.gov.in/s3716e1b8c6cd17b771da77391355749f3/uploads/2026/03/2026030385758932.pdf

2. **Central Electricity Authority, CO₂ Baseline Database for the Indian Power Sector, User Guide Version 22.0**, August 2026, Table S (FY 2025–26):  
   https://cea.nic.in/api/cdm-report-version/view-pdf/en/82  
   CEA database page: https://cea.nic.in/cdm-co2-baseline-view?lang=en&mappingId=234

3. **MoEFCC, EIA Notification 2006 and amendments** portal:  
   https://environmentclearance.nic.in/report/View_EIA_Notifications.aspx  
   **MoEFCC Office Memorandum**, 17 December 2025, clarification on item 5(f) same-category categories:  
   https://parivesh.nic.in/publicdocument/UPLOAD_OM_NOTIFICATION/IA_DOCS/1002_18122025124221.pdf

4. **MoEFCC / PIB, Uniform Consent Guidelines amendments**, 28 January 2026:  
   https://www.pib.gov.in/PressReleasePage.aspx?PRID=2219415&lang=2&reg=3

5. **Water (Prevention and Control of Pollution) Act, 1974**, IndiaCode (see section 25):  
   https://www.indiacode.nic.in/handle/123456789/18919?locale=en  
   Haryana adoption announcement, 2 September 2026:  
   https://prms.prharyana.gov.in/press-release/4997

6. **Environment (Protection) Rules 1986, Schedule VI**, CPCB copy of general effluent standards:  
   https://cpcb.gov.in/generalstandards.pdf

7. **Hazardous and Other Wastes (Management and Transboundary Movement) Rules** and amendments, MoEFCC rules portal:  
   https://moef.gov.in/rules-regulations-3  
   The portal lists G.S.R. 177(E), 12 March 2024 amendment.

8. **Solid Waste Management Rules 2026**, MoEFCC/PIB release, 28 January 2026 (effective 1 April 2026):  
   https://www.pib.gov.in/PressReleasePage.aspx?PRID=2219676&lang=1&reg=3

9. **Manufacture, Storage and Import of Hazardous Chemicals Rules 1989**, IndiaCode source PDF:  
   https://upload.indiacode.nic.in/showfile?actid=AC_CH_60_1035_00003_00003_1597386791818&filename=manufacture%2C_storage%20and%20import%20of%20hazardous%20chemical%20rules%2C%201989.pdf&type=rule

10. **PESO, Static and Mobile Pressure Vessels (Unfired) (Amendment) Rules 2025** (including definition of bulk hydrogen compressed gas system, >5,000 scf / 141.6 Nm³):  
    https://www.peso.gov.in/en/smpvunfiredamendment-rules-2025  
    **PESO, SMPV(U) (Amendment) Rules 2026**, Gazette notification G.S.R. 448(E), 5 June 2026 (ISO tank containers for above-ground compressed-gas storage subject to anchoring/structural certification; mounded vessel grouping and licensing provisions):  
    https://peso.gov.in/web/sites/default/files/2026-06/SMPV%20Amendment%20Rules%202026%2005-06-2026.pdf

11. **Boilers Act, 2025**, IndiaCode (only if an on-site boiler is selected):  
    https://www.indiacode.nic.in/handle/123456789/21395?view_type=browse

12. **CGWA consolidated groundwater guidelines** (where groundwater abstraction is proposed):  
    https://cgwa-noc.gov.in/landingpage/Guidlines/ConsolidateGuidline.pdf
