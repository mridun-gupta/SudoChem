# ENERGY-008 Route Comparison and Decision Report

**Project:** ENERGY-008, Green methanol synthesis: utility integration and energy KPIs  
**Decision phase:** Prompt 2, process-route screening  
**Evidence cut-off:** 31 October 2026  
**Decision status:** **Provisional recommendation. User approval required.**  
**Design status:** No capacity selected, no design basis frozen, and no process or equipment calculations performed.

---

## 1. Executive decision

### Provisional recommendation

Carry forward **Route C: biogenic CO₂ hydrogenation using renewable-electrolysis hydrogen** as the preferred academic reference route. Use **pressurised alkaline electrolysis (ALK)** as the initial electrolyser configuration for comparison because it is commercially established and is a reasonable reference where renewable supply is firmed or scheduled. Retain **PEM electrolysis** as a defined flexibility configuration for a more variable renewable-power profile. These are route-screening choices, not equipment selections.

Carry forward two alternatives:

1. **Route A, industrial point-source CO₂ plus renewable electrolytic H₂.** This is a meaningful comparator because it retains the same CO₂-hydrogenation synthesis core while changing the carbon source and its capture/conditioning requirements. Importantly, India's Green Methanol Standard notified on 27 February 2026 explicitly lists existing industrial CO₂ sources as eligible. This does not make the carbon itself renewable, and it does not remove the need to report the source's origin and downstream carbon fate.
2. **Route B, sustainable biomass-residue gasification to cleaned syngas and methanol.** This is a distinct biogenic-carbon route with a different front end, utility profile, contaminant-control train and operating risk. India's Green Hydrogen Certification Scheme includes conversion of biomass, including biomass gasification, as an eligible hydrogen-production pathway. However, the integrated use of hydrogen embedded in raw/conditioned syngas is not assumed to be separately certifiable as Green Hydrogen without checking the required purification, compression, storage and certification boundary. Route B is therefore retained as a renewable-methanol comparator with a specific regulatory-interpretation issue, not presumed compliant.

The route decision is **not robust to the absence of a bankable site-specific CO₂ source**. Route C ranks first in the defined weighted and weight-sensitivity cases, but a missing or non-bankable biogenic CO₂ supply is a hard feasibility stop, not something that can be hidden by a high national-level score. If a verified biogenic source cannot be secured and an existing industrial source can be secured, Route A becomes the leading practical candidate, subject to its emissions accounting and the notified Indian standard.

### Weighted screening result

| Route | Weighted score (1 to 5) | Screening position |
|---|---:|---|
| C. Biogenic CO₂ + renewable electrolytic H₂ | **4.05** | Preferred provisional base route |
| A. Existing industrial CO₂ + renewable electrolytic H₂ | **3.80** | Alternative 1, close second |
| B. Biomass gasification and syngas-to-methanol | **3.15** | Alternative 2, greater front-end complexity |

Scores are structured engineering judgements, not measured plant performance, quotations or vendor ratings. The matrix and alternative weight profiles are in `ENERGY008_Route_Comparison.xlsx`. Score definitions, evidence strength and uncertainty are recorded there. No score substitutes for a site-specific resource study.

---

## 2. Governing requirements and route-decision boundary

The ENERGY-008 assignment requires a base case and at least two alternatives, a defined boundary from feed receipt/conditioning to product, recycle, waste and utilities, and evaluation of steady state, start-up/shutdown, turndown and at least one disturbance. The assignment also requires quality/yield, environmental and process-hazard treatment. This phase identifies the route family and comparable cases only.

**Included in this phase:** carbon-source and hydrogen-source concepts; route-specific unit-operation boundaries; technology maturity; broad literature operating envelopes; catalyst and separation considerations; qualitative utility and waste implications; India policy context; route scoring and open route risks.

**Explicitly excluded:** production capacity, site selection, feedstock quantities, detailed process conditions, equipment selection/sizing, balances, energy/exergy calculations, plant costs, detailed safety design, final operating window and MATLAB implementation.

The common product comparison boundary is **methanol at the product-storage outlet**, with feed receipt/conditioning at the inlet and all material and utility interfaces included. The boundary must be translated into a formal design basis only after the route gate is approved.

---

## 3. What “green methanol” means for this comparison

### 3.1 Current Indian standard

The Ministry of New and Renewable Energy's Office Memorandum **No. 353/35/2022-NT dated 27 February 2026** defines Green Methanol as methanol produced using Green Hydrogen. It permits renewable electricity stored in an energy-storage system or banked with the grid, subject to applicable regulations. The standard sets a ceiling of **0.44 kg CO₂-equivalent per kg methanol** for total **non-biogenic** greenhouse-gas emissions arising from Green Hydrogen production, methanol synthesis, purification and on-site storage, averaged over the preceding 12 months. It expressly permits CO₂ from **biogenic sources, Direct Air Capture (DAC), or existing industrial sources**. The Ministry may revise eligible sources prospectively. The notification says a detailed methodology for measurement, reporting, monitoring, on-site verification and certification will be specified separately.

Consequences for route screening:

- Route C is directly aligned with the stated hydrogen and biogenic-CO₂ pathway, subject to the 0.44 kg CO₂e/kg methanol threshold and the applicable MRV method.
- Route A is **not automatically disqualified**. Existing industrial CO₂ is an expressly eligible source category under the notified Indian standard. If the CO₂ is fossil-origin, it must still be labelled as fossil-origin in the engineering and lifecycle records. The standard's source eligibility must not be misrepresented as proof that the carbon is renewable or permanently removed.
- Route B can use biomass conversion as a Green Hydrogen pathway under the separate Green Hydrogen Certification Scheme. However, the scheme's hydrogen production boundary extends through purification, drying, compression and on-site storage. A syngas-to-methanol process that consumes mixed syngas directly is not assumed to satisfy that separate hydrogen certification boundary. Its Green Methanol classification requires a documented interpretation of how the GH2 requirement applies to the integrated syngas route.

The Indian Green Methanol threshold is **not** treated as a complete cradle-to-grave lifecycle assessment. The broader project assessment should separately disclose carbon-source origin, capture or biomass supply chain, electricity attributes, transport, process emissions, purge/off-gas, product use and end-of-life fate. If methanol is used as a fuel, carbon contained in the methanol is released on oxidation; capture and utilisation should not be called permanent carbon removal.

### 3.2 Green hydrogen requirements

The Indian Green Hydrogen Standard uses a non-biogenic GHG threshold of **2.0 kg CO₂e/kg H₂**, averaged over 12 months. The Green Hydrogen Certification Scheme of India (GHCI, April 2025) describes project-level certification and a boundary extending to hydrogen purification, compression and on-site storage. For electrolysis, the scheme includes emissions from water treatment, electrolysis, purification, drying, compression and on-site storage. For biomass conversion, it includes biomass processing, heat/steam generation, conversion of biomass to hydrogen and the associated purification, drying, compression and storage.

Renewable electricity claims must be supported by evidence of source and quantity. Grid electricity and non-renewable captive supply cannot simply be relabelled renewable. The GHCI includes energy-storage and grid-banking arrangements where they meet applicable policy provisions.

### 3.3 Chain of custody and export claims

ISCC PLUS is a **voluntary** sustainability and traceability scheme, not a substitute for the Indian Green Methanol Standard. It provides chain-of-custody approaches including physical segregation, controlled blending and mass balance. ISCC states that each site handling alternative materials in a certified chain must hold a valid site certificate. If export-market claims are later targeted, the relevant market-specific rules and certification must be checked separately. This report does not assume EU RFNBO eligibility or any export certification.

### 3.4 Required carbon-accounting ledger for the later design phase

Whichever route is approved, the later emissions ledger should keep at least these entries distinct:

1. Carbon-source category and origin: biogenic, DAC or existing industrial source; for industrial CO₂, whether the originating carbon is fossil or biogenic.
2. Source facility, production process, capture method, gas composition, contaminants, quantity records, continuity and chain-of-custody evidence.
3. Electricity source, renewable generation attributes, temporal/geographical matching or permitted banking/storage evidence, grid backup and transmission/distribution treatment where required.
4. Hydrogen production pathway and GHCI evidence, including water treatment, power, fuels, input materials, purification, drying, compression and storage.
5. CO₂ capture/recovery, purification, compression and transport emissions, pending the final methanol MRV method.
6. Methanol synthesis, purification, on-site storage, process heat, auxiliary power, cooling, purge/off-gas and waste-treatment emissions.
7. Co-product allocation rules, including oxygen and recoverable heat. No revenue or emissions credit is assumed simply because a by-product exists.
8. Product destination and end-use scenario. Carbon utilisation and permanent carbon removal are not equivalent.

---

## 4. Route chemistry and technical comparison

### 4.1 Route A: existing industrial point-source CO₂ + renewable electrolytic H₂

**Core chemistry**

\[
\mathrm{CO_2 + 3H_2 \rightleftharpoons CH_3OH + H_2O}
\]

The reaction is exothermic; a peer-reviewed review reports a standard reaction enthalpy of approximately **−49.5 kJ mol⁻¹** at 25 °C for the gas-phase reaction. The reverse water-gas-shift reaction competes:

\[
\mathrm{CO_2 + H_2 \rightleftharpoons CO + H_2O}
\]

Methanol formation is favoured thermodynamically by lower temperature and higher pressure, while sufficient temperature is still needed for practical reaction rates. Literature reports broad methanol-synthesis conditions around **200–300 °C and 50–100 bar** for conventional Cu/ZnO/Al₂O₃ synthesis systems. These are literature screening ranges, not selected design conditions.

**Feed and catalyst**

The H₂ feed must meet the selected synthesis catalyst's purity requirements. CO₂ quality is source-dependent. Existing industrial sources may require capture, bulk contaminant removal, drying, purification and compression. Flue-gas-derived CO₂ may require a more demanding conditioning and capture train than a concentrated process stream. Sulphur, nitrogen oxides, oxygen, water and trace contaminants must be characterised rather than assumed absent.

Cu/ZnO/Al₂O₃ is a conventional methanol-synthesis catalyst family. CO₂-rich feeds introduce reverse water-gas shift competition and produce water in the synthesis loop; water management and catalyst tolerance matter. Alternative catalyst families exist in the research literature, but no novel catalyst is assumed for the academic reference route.

**Conversion, selectivity and recycle**

Published conversion and selectivity results vary materially with catalyst formulation, temperature, pressure, feed ratio, space velocity, reactor design and time-on-stream. A literature review reports examples such as 25% CO₂ conversion and 73% methanol selectivity for a particular supported Cu-Zn catalyst at 170 °C and 50 bar, while other catalysts and conditions report very different results. These are laboratory/review examples, **not plant guarantees**. The later model must use a source-matched and validated kinetic/equilibrium basis. A recycle loop with purge is a normal process concept for unreacted gas management; the purge composition and recovery strategy must be established later.

**Heat, water, utilities, by-products and emissions**

The synthesis is exothermic and requires reactor temperature management and heat removal/recovery. Water is formed stoichiometrically and must be separated from crude methanol. Cooling, condensation, gas-liquid separation, recycle compression, product distillation and water treatment are expected. Unconverted gas and purge treatment are within the process boundary. Hydrogen compression/storage and hydrogen leak/fire protection are material safety interfaces. Industrial-source CO₂ capture adds capture energy, solvent/sorbent handling where applicable, contaminants, wastewater and source-specific emissions.

**Maturity and evidence**

The CO₂-hydrogenation synthesis core is well represented in the literature and related to existing methanol synthesis technology. Commercial-scale renewable e-methanol operation is demonstrated internationally, although the best-known cited example here uses biogenic CO₂ rather than fossil point-source CO₂. Route A's carbon-source capture train must therefore be assessed independently rather than assuming the entire chain is identical to an operating biogenic-CO₂ plant.

**Indian-context assessment**

India has industrial point sources, but no site, source facility, CO₂ concentration, availability, pressure, contaminants or capture arrangement has been provided. The 2026 Indian Green Methanol Standard explicitly includes existing industrial sources as eligible CO₂ sources. A fossil-origin source remains fossil-origin and may give a different full lifecycle result from biogenic CO₂ or DAC, particularly for fuel use. This route is an essential policy-aligned comparator, not the preferred carbon-integrity case.

### 4.2 Route B: sustainable biomass residues → gasification → cleaned syngas → methanol

**Core chemistry and process concept**

Biomass gasification produces a raw synthesis gas containing varying proportions of H₂, CO, CO₂, CH₄, water vapour and contaminants. Methanol can be synthesised from CO-rich syngas through:

\[
\mathrm{CO + 2H_2 \rightleftharpoons CH_3OH}
\]

This reaction is exothermic. Gasifier selection, biomass moisture/ash, oxygen/steam ratio and gas-conditioning decisions determine raw-gas composition. The synthesis-gas stoichiometric balance may require water-gas-shift adjustment, CO₂ removal or other conditioning. Those choices remain open; no gasifier type or syngas composition is selected here.

**Feed and gas cleaning**

Potential feed categories include sustainably sourced agricultural and forestry residues and other eligible biogenic wastes. Feedstock screening must include moisture, ash, alkali, sulphur, chlorine, nitrogen, particle size, bulk density, seasonal storage and competing uses. The NIBE National Biomass Atlas reports an estimated national surplus of approximately **230 million tonnes per year for 2017–18**, with state- and crop-level information. This is a historical resource assessment, not a current procurement commitment, sustainable-removal guarantee or plant-specific supply estimate.

Raw gas can contain tar, particulates, H₂S/COS and other sulphur compounds, NH₃/HCN, halides, alkali metals and trace metals. A recent 2026 review and a 2024 syngas-cleaning review describe the stringent contaminant-control needs for methanol catalysts. The cleaning train can include particulate separation/hot-gas filtration, tar reforming or removal, cooling, scrubbing, desulphurisation, halide/nitrogen removal, drying and compression. Final specifications must come from the selected catalyst supplier or a defensible published basis.

**Conversion, selectivity and recycle**

The downstream methanol loop is based on established syngas chemistry, but the integrated biomass-to-methanol chain is less mature than natural-gas-to-methanol technology. Syngas composition adjustment and impurity removal are critical to catalyst life and selectivity. The later design must not insert generic conversion values from a fossil syngas plant into a biomass route without feed-specific justification.

**Heat, water, utilities, by-products and emissions**

The route requires biomass reception, storage, size reduction and usually drying; oxygen and/or steam supply; gasifier heat; gas cooling; extensive cleanup; compression; methanol synthesis cooling; condensation; purification; and waste handling. Potential streams include ash, char, tar, spent sorbents, scrubber liquor, wastewater, off-gas and rejected biomass. Depending on gasifier and heat-integration configuration, heat may be recovered, but no credit is assigned in this phase. Oxygen demand and water/steam use are configuration-specific.

**Maturity and Indian-context assessment**

IRENA's renewable-methanol outlook describes biomass/MSW gasification as an early-commercialisation pathway compared with established fossil syngas routes. In India, NITI Aayog documents an IISc Bengaluru/Praj Industries biomass-to-methanol R&D initiative in which Phase-I biomass-to-syngas demonstration was reported in January 2019. This is evidence of domestic R&D activity, not proof of a large commercial biomass-to-methanol plant. The biomass atlas demonstrates a broad theoretical resource base, but local sustainable surplus, logistics and competing uses are decisive.

**Green classification issue**

The GHCI includes conversion of biomass as an eligible Green Hydrogen pathway, including biomass gasification. To use that pathway in a Green Methanol claim, the later project must demonstrate that the hydrogen used meets the applicable GHCI requirement and certification boundary. Direct use of an unseparated mixed syngas stream must not be assumed equivalent to a certified GH2 stream. The exact integrated-route treatment remains an open regulatory interpretation.

### 4.3 Route C: biogenic CO₂ + renewable electrolytic H₂

**Core chemistry**

The synthesis reaction is the same CO₂-hydrogenation reaction as Route A. The principal change is the carbon-source origin and its upstream recovery train. Suitable source concepts include concentrated biogenic CO₂ streams associated with biogas upgrading or fermentation, subject to verified biomass/waste origin, gas composition, continuity and chain of custody.

**Feed and catalyst**

CO₂ recovered from biogas or fermentation is not automatically synthesis-grade. It can contain water, sulphur compounds, oxygen, nitrogen, volatile organics and other source-specific contaminants. The feed must be sampled and specified. Renewable electrolytic H₂ must satisfy the Indian Green Hydrogen Standard/GHCI requirements, including power provenance and measured emissions. A conventional Cu/ZnO/Al₂O₃ methanol-synthesis basis is an appropriate literature reference; novel catalyst performance is not assumed.

**Conversion, selectivity, recycle and product**

The same CO₂-hydrogenation equilibrium, RWGS competition, water formation and recycle/purge principles apply as in Route A. The downstream methanol purification train is not presumed simpler just because the CO₂ is biogenic. Product quality is established by actual purification and product analysis, not by the carbon source.

**Heat, water, utilities, by-products and emissions**

The route includes biogenic CO₂ recovery/conditioning and compression, water treatment, electrolyser auxiliaries, H₂ purification/drying/compression, O₂ handling, H₂ buffering/storage, feed mixing/preheat, synthesis heat removal, cooling/condensation, gas-liquid separation, recycle/purge, crude methanol purification, product storage, water treatment, off-gas treatment and utility interfaces. Electrolysis produces oxygen and low-temperature heat; these are potential integration opportunities, not guaranteed revenue or avoided-emissions credits. No oxygen sale or heat credit is assumed.

**Maturity and demonstration evidence**

European Energy reported first raw e-methanol production at Kassø on 12 March 2025 using biogenic CO₂ sourced from a local biogas facility. It subsequently reported the facility's inauguration on 13 May 2025, a 42,000 t/y annual capacity and operation on renewable energy. European Energy reported an industry-grade batch above 99.85% purity on 3 April 2025. These are operator announcements and useful commercial-demonstration evidence; they are not independent vendor guarantees or a transferable design basis for India.

**Indian-context assessment**

This route is aligned with the 2026 Indian Green Methanol Standard's explicit biogenic-CO₂ option and GH2 requirement. Its weakest unverified assumption is the existence of a sufficiently large, continuous, traceable and economically recoverable biogenic CO₂ source close to a feasible renewable-power and water supply. No location, biogas/fermentation source, CO₂ stream data, water source or renewable power contract has been identified. Route C is therefore the best academic base route only if that carbon-source gate can be passed.

---

## 5. Green hydrogen production technology comparison

The base route requires renewable electrolytic H₂. IRENA's 2023 technology comparison treats alkaline (ALK) and PEM electrolysers as commercial technologies, SOEC as demonstration-stage and AEM as under research in that comparison. Its broad system-level electricity ranges are literature comparison values, not current vendor guarantees.

| Attribute | Alkaline (ALK) | PEM | SOEC | AEM |
|---|---|---|---|---|
| Readiness in IRENA 2023 comparison | Commercial | Commercial | Demonstration | Under research |
| Typical operating temperature in IRENA table | 70–90 °C | 50–80 °C | 700–850 °C | 40–60 °C |
| Cell pressure in IRENA table | <30 bar | ≤40 bar | About 1 bar | <35 bar |
| System electricity range shown by IRENA | 50–78 kWh/kg H₂ | 50–83 kWh/kg H₂ | 40–50 kWh/kg H₂ | 57–69 kWh/kg H₂ |
| Flexibility indication in IRENA table | 15–100% load | 0–160% load | 20–125% load | 5–100% load |
| Start-up indication in IRENA table | 1–10 min | 1 sec to 5 min | <60 min | Not reported in the table |
| Screening strengths | Mature, lower system cost in the cited comparison, broad supply base | Fast response, high current density, useful for variable renewable input | Can use high-temperature heat; potentially higher electrical efficiency | Potential lower-cost materials, less mature evidence |
| Screening constraints | Slower response than PEM in the cited comparison; alkaline electrolyte management | Titanium-based components and noble-metal catalysts/coatings contribute to cost | High-temperature heat integration, start-up and durability challenges | Limited commercial bankability and limited system-cost evidence |
| Role in this phase | **Provisional reference configuration** if power is firmed/scheduled | Flexibility alternative if renewable profile is variable | Not selected as base; revisit only if a credible heat source/vendor basis is available | Not selected |

The cited IRENA table gives indicative system electricity ranges of 50–78 kWh/kg H₂ for ALK and 50–83 kWh/kg H₂ for PEM. These wide ranges should not be used as guaranteed plant consumption. The later design basis must use a current vendor data sheet or a traceable performance curve at the selected load, pressure and product purity.

**Water:** India's model state-level Green Hydrogen guidelines state that electrolysis requires about 9 litres of deionised water per kg H₂, with another 10–12 litres for purification and process cooling. The same document includes a rounded callout of 18–20 litres/kg. Treat these as indicative screening figures; the later project must reconcile the exact boundary, water recovery and cooling arrangement. Site water availability is a gate, especially in water-stressed regions.

**Oxygen:** Electrolysis generates oxygen as a stoichiometric co-product. The theoretical reaction corresponds to 8 kg O₂ per kg H₂. This is a chemistry-based ratio, not a guaranteed saleable output. Oxygen quality, compression, handling, demand and safety must be established before any credit is considered. IRENA also identifies low-temperature heat as a possible electrolysis co-product.

**Indian market context:** PIB reported approximately 8,000 tonnes per annum of commissioned green-hydrogen production capacity in India through February 2026, against the National Green Hydrogen Mission's 5 million tonnes per annum ambition for 2030. This shows a developing supply chain, but not assured local availability or a specific delivered price. Site-specific power contracts, hydrogen storage/backup, grid banking rules and vendor capability remain open.

---

## 6. India-context comparison

| Dimension | Route A: industrial CO₂ + RE-H₂ | Route B: biomass syngas | Route C: biogenic CO₂ + RE-H₂ |
|---|---|---|---|
| Carbon source | Existing industrial CO₂; may be fossil-origin or biogenic depending on source | Sustainable biomass residues or eligible biogenic feed | Biogenic CO₂, e.g. biogas upgrading or fermentation |
| Indian Green Methanol Standard | Expressly permitted CO₂ source category; still requires GH2 and ≤0.44 kg CO₂e/kg MeOH non-biogenic emissions | Requires GH2 under the Green Methanol Standard; GHCI allows biomass-to-H2, but direct mixed-syngas use needs certification interpretation | Expressly permitted biogenic CO₂ source and GH2 |
| Source availability | Industrial sources exist, but capture-ready quality/continuity not mapped | National residue resource is substantial in historic atlas; local bankable surplus not established | Biogenic point sources exist in relevant sectors, but no local quantity/duration/quality inventory |
| Power | High renewable-electricity dependence for electrolysis | Gasification auxiliaries and oxygen/steam; less dependence on electrolytic power in a direct syngas reference | High renewable-electricity dependence for electrolysis |
| Water | Electrolysis water plus capture/cooling and synthesis utilities | Feed moisture and gasification/cleanup water; location and gasifier-dependent | Electrolysis water plus CO₂ conditioning and synthesis utilities |
| Infrastructure | Industrial source capture, CO₂ conditioning/compression, H₂ and high-pressure synthesis | Biomass logistics, gasifier, oxygen/steam, extensive syngas cleaning, high-pressure synthesis | Biogenic CO₂ recovery, H₂ electrolyser, water treatment and high-pressure synthesis |
| Scale suitability | Modular CO₂/H₂ synthesis can be considered; source capacity and H₂ supply constrain scale | Scale is sensitive to biomass catchment, feed logistics and gasifier configuration | Depends on co-located CO₂ supply and renewable power; commercial-scale international example exists |
| Safety complexity | H₂ handling, high-pressure synthesis, CO₂ capture solvent/process hazards | Above plus combustible/toxic raw gas, tar, dust, ash, hot gas, gasifier and cleanup hazards | H₂ handling, high-pressure synthesis, CO₂ conditioning and oxygen handling |
| Cost-data availability | Some public route literature; current capture and H₂ vendor data needed | Biomass supply, gas cleanup and integrated plant costs are uncertain and configuration-specific | International project data and electrolyser literature exist, but no India site/vendor quote is supplied |

**No site-specific conclusion can be made** about biomass versus CO₂ availability, water, renewable-electricity profile, utility infrastructure, tariffs, logistics or offtake until a location and potential source facilities are nominated.

---

## 7. Weighted decision matrix

### 7.1 Scoring definitions

Each criterion is scored from 1 to 5:

- **1:** poor fit, major disadvantage or unsupported evidence.
- **2:** weak fit; significant technical, regulatory or supply-chain issue.
- **3:** mixed or strongly site-dependent; key evidence is incomplete.
- **4:** strong fit with credible supporting evidence and manageable dependencies.
- **5:** very strong fit with directly relevant evidence and relatively low uncertainty.

A higher score for process complexity means **lower complexity / lower burden**. A higher score for electricity and water means **more favourable resource burden**. Scores are screening judgements; the assignment did not prescribe weights or scoring.

### 7.2 Criteria and weights

| Criterion | Weight | Basis |
|---|---:|---|
| Carbon provenance and broader climate integrity | 20% | Renewable/biogenic/DAC provenance, source accountability and lifecycle risk |
| Alignment with India's notified Green Methanol Standard | 15% | Use of GH2, permitted carbon source category and certification pathway |
| Technology maturity and demonstration evidence | 15% | Process maturity, operating evidence and availability of credible data |
| Indian source/feedstock bankability | 10% | Potential source availability, continuity and logistics at an Indian site |
| Process complexity and safety burden | 10% | Number and severity of process steps, contaminants and hazard interfaces |
| Electricity and water burden | 10% | Dependence on renewable power, water and auxiliary utilities |
| Product quality and purification evidence | 5% | Demonstrated product purification and quality evidence |
| India industrial integration potential | 5% | Fit with Indian industrial/agro-industrial interfaces and infrastructure |
| Evidence accessibility and modelability | 10% | Availability of traceable data suitable for an auditable academic model |

### 7.3 Scores

| Criterion | Weight | Route A | Route B | Route C |
|---|---:|---:|---:|---:|
| Carbon provenance / climate integrity | 20 | 3.5 | 4.0 | 4.5 |
| Indian Green Methanol Standard alignment | 15 | 4.5 | 2.5 | 4.5 |
| Technology maturity / demonstration | 15 | 4.0 | 2.5 | 4.5 |
| Indian source / feedstock bankability | 10 | 3.5 | 3.5 | 3.0 |
| Process simplicity / lower safety burden | 10 | 3.5 | 2.0 | 3.5 |
| Electricity and water fit | 10 | 2.5 | 3.5 | 2.5 |
| Product-quality evidence | 5 | 4.5 | 3.5 | 4.5 |
| India industrial integration | 5 | 4.0 | 3.5 | 3.5 |
| Evidence accessibility / modelability | 10 | 4.5 | 3.5 | 5.0 |
| **Weighted total (1 to 5)** | **100** | **3.80** | **3.15** | **4.05** |

### 7.4 Why the scores differ

- **Route C** leads on carbon provenance, direct fit to the notified biogenic-CO₂ + GH2 route, commercial demonstration evidence and accessible process literature. It loses points for unverified Indian biogenic CO₂ bankability and high electricity/water dependence.
- **Route A** is close behind. The 2026 Indian standard expressly permits existing industrial CO₂ sources, so it is not assigned a regulatory zero. It loses points because the carbon may be fossil-origin and its full lifecycle/end-use implications differ from biogenic CO₂, while source capture/purification is site-specific.
- **Route B** scores well on potential biogenic carbon and reduced electrolytic-power dependency, but is penalised for gasification and gas-cleaning complexity, lower integrated biomass-to-methanol maturity, and uncertainty about GH2 certification when hydrogen is consumed within mixed syngas rather than as a separately certified stream.

### 7.5 Weight-sensitivity check

The weights were shifted to six alternative profiles. The total weight in each profile is 100%.

| Weight profile | Route A | Route B | Route C | Highest |
|---|---:|---:|---:|---|
| Base weights | 3.800 | 3.150 | **4.050** | C |
| Carbon-integrity priority | 3.725 | 3.300 | **4.050** | C |
| Indian-standard priority | 3.850 | 3.025 | **4.025** | C |
| Indian-source priority | 3.700 | 3.175 | **3.800** | C |
| Technology-maturity priority | 3.800 | 3.075 | **4.050** | C |
| Power/water-constrained | 3.575 | 3.225 | **3.750** | C |
| Process-complexity priority | 3.725 | 3.000 | **3.900** | C |

Route C stays first in these tested profiles, but it is only 0.10 points above Route A under the India-source profile. The matrix does **not** prove that a local biogenic CO₂ source exists. If no continuous biogenic source is available, Route C fails its source gate irrespective of its weighted score. Route A is then the logical fallback, provided the industrial CO₂ source is characterised and the Indian GHG threshold can be met.

This is a deterministic weight-sensitivity test, not a statistical uncertainty analysis. Score uncertainty is documented as high/medium/low in the workbook. A formal Monte Carlo treatment is deferred until actual site/source data are available.

---

## 8. Route-specific unit-operation boundaries

### 8.1 Shared downstream block for Routes A and C

1. CO₂ feed receiving, metering and source-quality verification.
2. CO₂ conditioning: knock-out, contaminant removal as required, drying, purification and compression.
3. Renewable H₂ production by electrolysis, water treatment, gas separation, H₂ purification/drying and compression.
4. H₂/O₂ segregation, oxygen safe handling, H₂ buffer/storage and pressure control.
5. Feed ratio control, mixing and preheating.
6. Catalytic methanol synthesis reactor and heat removal/recovery interface.
7. Effluent cooling/condensation and gas-liquid separation.
8. Unreacted-gas recycle, purge and purge-gas handling.
9. Crude methanol/water separation and product purification.
10. Product storage and dispatch.
11. Water treatment, wastewater, off-gas/vent treatment, utilities, electrical systems, instrumentation, shutdown and safeguards.

### 8.2 Route A-specific front end

- Existing industrial CO₂ source tie-in and gas analysis.
- Capture or recovery system as applicable to source concentration and pressure.
- Source-specific pre-treatment for particulates, SOx/NOx, oxygen, moisture and trace contaminants.
- Capture-regeneration heat/electricity, solvent/sorbent handling, condensate and spent media management where relevant.
- CO₂ compression and transfer to the common synthesis block.
- Carbon-origin and source-fate evidence register.

### 8.3 Route C-specific front end

- Biogenic CO₂ source interface, such as biogas upgrading or fermentation off-gas.
- Source process documentation and proof of biogenic origin.
- CO₂ recovery, drying, purification and compression.
- Contaminant monitoring for water, H₂S/sulphur, oxygen, nitrogen and volatile compounds as relevant to the actual source.
- Chain-of-custody records and no-double-counting controls.
- Renewable electricity supply/firming and electrolyser interface.

### 8.4 Route B-specific train

1. Biomass receipt, weighing, sampling and traceable sourcing.
2. Biomass storage, handling, size reduction and drying as required.
3. Oxygen/steam supply and gasifier.
4. Ash/char separation and handling.
5. Raw gas cooling and particulate removal.
6. Tar mitigation/removal or reforming.
7. Sulphur, halide, nitrogen-compound and trace-metal removal.
8. Gas drying and compression.
9. Syngas analysis and conditioning to methanol-synthesis stoichiometry, with WGS/CO₂ removal/H₂ adjustment only when supported by selected route data.
10. Methanol synthesis reactor and heat removal/recovery.
11. Cooling/condensation, gas-liquid separation, recycle/purge and off-gas handling.
12. Crude methanol purification, storage and dispatch.
13. Ash, char, tar, spent sorbent, scrubber liquor, wastewater and rejected biomass handling.
14. If a Green Methanol claim is pursued, define exactly how a GHCI-compliant hydrogen stream is produced, measured and certified in the integrated configuration.

These are route boundaries only. They are not a selected PFD or equipment list.

---

## 9. Base and alternative case definitions

| Case ID | Role | Route definition | Controlled comparison logic | Main unresolved gate |
|---|---|---|---|---|
| `C-BIOCO2-REH2-ALK` | Base | Biogenic CO₂ + renewable electrolytic H₂; ALK reference electrolyser; CO₂ hydrogenation methanol loop | Reference route with biogenic carbon and Green Hydrogen | Secure and characterise a continuous biogenic CO₂ source; verify power and water |
| `A-INDCO2-REH2-ALK` | Alternative 1 | Existing industrial point-source CO₂ + renewable electrolytic H₂; ALK reference electrolyser; same CO₂ hydrogenation loop | Isolates the carbon-source/capture difference while holding the synthesis core and H₂ configuration conceptually consistent | Identify source; establish carbon origin, contaminants, capture duty and full carbon accounting |
| `B-BIOMASS-SYNGAS` | Alternative 2 | Sustainable biomass residues → oxygen/steam gasification → syngas cleanup/conditioning → methanol synthesis | Compares a distinct biogenic-carbon and gasification route with different front end and utility/waste profile | Verify sustainable local residues, integrated gas cleaning and GH2 certification treatment |

**Electrolyser subcase:** For Route C (and Route A), compare PEM as a renewable-flexibility configuration against ALK. This is a configuration sensitivity within the CO₂-hydrogenation route family, not a fourth process route.

**Comparability rule:** Compare all cases at the same final methanol product boundary and product-specification target after the design basis is approved. Do not force equal feedstock quantities, electricity use, yields or equipment when the routes differ. Those are model outputs, not assumptions to be normalised away.

---

## 10. Route risks and pre-design dependencies

| ID | Issue / unresolved decision | Why it matters | Evidence needed before route/design-basis freeze |
|---|---|---|---|
| R-01 | No site or industrial cluster nominated | Prevents bankability ranking of CO₂, biomass, water, power, infrastructure and tariffs | User selects a location or approves a generic India academic context with explicit limits |
| R-02 | No biogenic CO₂ source identified | Route C hard dependency | Source facility, CO₂ flow/composition, pressure, availability profile, ownership and chain of custody |
| R-03 | No industrial CO₂ source identified | Route A hard dependency | Source gas data, origin, capture/recovery method, continuity and contaminants |
| R-04 | No biomass source/catchment identified | Route B hard dependency | Crop/residue inventory, sustainable surplus, competing uses, seasonal availability, moisture/ash and logistics |
| R-05 | Methanol MRV method under 2026 standard | Needed to establish exact measurement and certification treatment | Confirm current MNRE methodology/portal instructions before a certification claim |
| R-06 | Integrated biomass syngas hydrogen certification | Direct-use mixed syngas may not satisfy GHCI's H₂ product boundary | Confirm whether H₂ must be isolated and certified or if an integrated route is accepted |
| R-07 | Renewable electricity supply profile unknown | Determines ALK vs PEM and hydrogen emissions/availability | PPA, generation profile, storage/banking rules, grid backup and source evidence |
| R-08 | Water source and quality unknown | Electrolysis and cooling demand; water stress can block C/A | Water availability, source sustainability, demineralisation and cooling-water approach |
| R-09 | CO₂ quality and catalyst limits unknown | Determines pretreatment and catalyst protection | Actual source analysis and supplier/published impurity limits |
| R-10 | Product grade not supplied | Determines distillation and quality assurance requirements | User/faculty approval of product specification |
| R-11 | Carbon fate depends on end-use | Reuse is not necessarily permanent removal | Define fuel, chemical feedstock or other end-use and lifecycle boundary |
| R-12 | Vendor and cost data absent | Prevents credible economics/equipment selection | Source current vendor data later; no budget values used in this route phase |

**Hard stop conditions:** Do not freeze Route C without a demonstrable biogenic CO₂ source and renewable-power/water route. Do not freeze Route A without a characterised industrial CO₂ source and explicit fossil/biogenic origin. Do not freeze Route B without a sustainable biomass supply and a credible gas-cleaning/catalyst-compatibility basis.

---

## 11. Route-selection gate decision

**Gate:** `G2 - Route Selection Approval`  
**Decision requested:** Approve one route family as the reference route and retain the two comparison alternatives.

**Recommended approval:**

- Base route: **Route C, biogenic CO₂ + renewable electrolytic H₂**.
- Base electrolyser configuration: **ALK** for the reference model; **PEM** retained as a flexibility comparison.
- Alternative 1: **Route A, existing industrial CO₂ + renewable electrolytic H₂**.
- Alternative 2: **Route B, sustainable biomass gasification + cleaned syngas-to-methanol**, with the GH2 certification interpretation explicitly open.

**Conditions attached to approval:**

1. Route selection does not authorise a plant capacity, site or operating value.
2. The route boundary in this report becomes the basis for Prompt 3 only after approval.
3. If Route C's biogenic CO₂ source cannot be evidenced, return to this gate and reconsider Route A.
4. Route B remains a comparability case unless the integrated GH2 status is resolved.
5. Do not claim the plant is certified, compliant, industrial-ready or safe.

**Gate status:** `SUBMITTED FOR USER APPROVAL - NOT APPROVED / NOT FROZEN`.

---

## 12. References and evidence register

All web sources were accessed on **31 October 2026**. Operator announcements are labelled as such. Literature values are not treated as vendor guarantees.

| ID | Source | Evidence type / use | URL |
|---|---|---|---|
| S01 | MNRE, Green Methanol Standard for India, Office Memorandum No. 353/35/2022-NT, 27 Feb 2026 | Primary Indian standard; GH2 requirement, ≤0.44 kg CO₂e/kg MeOH non-biogenic threshold, eligible CO₂ sources, 12-month average, future detailed MRV method | https://cdnbbsr.s3waas.gov.in/s3716e1b8c6cd17b771da77391355749f3/uploads/2026/03/2026030385758932.pdf |
| S02 | PIB/MNRE, announcement of Green Ammonia and Green Methanol Standards, 7 Mar 2026 | Official summary of S01 | https://www.pib.gov.in/PressReleaseIframePage.aspx?PRID=2236255&lang=2&reg=48 |
| S03 | MNRE, Green Hydrogen Certification Scheme of India, Apr 2025 | Primary scheme; GH2 threshold and electrolysis/biomass eligible pathways and boundaries | https://nghm.mnre.gov.in/admin/uploads/resources/174582349578999Green%20Hydrogen%20Certification%20Scheme%20of%20India.pdf |
| S04 | IRENA and Methanol Institute, Innovation Outlook: Renewable Methanol, 2021 | Intergovernmental/industry outlook; renewable methanol pathways and maturity context | https://www.irena.org/Publications/2021/Jan/Innovation-Outlook-Renewable-Methanol |
| S05 | IRENA, Innovation Landscape for Smart Electrification, 2023 | Electrolyser maturity, operating ranges, electricity, flexibility and coproducts; not vendor data | https://www.irena.org/-/media/Files/IRENA/Agency/Publication/2023/Jun/IRENA_Innovation_landscape_smart_electrification_2023.pdf?rev=786ef5cd85024414b21bc32d0af8be3c |
| S06 | European Energy, first raw e-methanol at Kassø, 12 Mar 2025 | Operator report; first production with locally sourced biogenic CO₂ | https://europeanenergy.com/2025/03/12/european-energy-produces-first-raw-e-methanol-at-kasso/ |
| S07 | European Energy, first industry-grade e-methanol at Kassø, 3 Apr 2025 | Operator report; batch purity above 99.85% and IMPCA specification claim | https://europeanenergy.com/2025/04/03/kasso-e-methanol-facility-produces-industry-grade-e-methanol-for-the-first-time/ |
| S08 | European Energy, Kassø facility inauguration, 13 May 2025 | Operator report; 42,000 t/y stated capacity and renewable energy operation | https://europeanenergy.com/2025/05/13/kasso-e-methanol-facility-officially-inaugurated/ |
| S09 | NITI Aayog, Methanol Economy | Indian project context; biomass-to-syngas demonstration reported in Jan 2019; not commercial plant proof | https://www.niti.gov.in/key-initiatives/methanol-economy |
| S10 | SSS-NIBE, National Biomass Atlas of India | Official atlas; state/crop resource context; surplus estimate is for 2017–18 | https://nibe.res.in/english/biomass-atlas.php |
| S11 | Singh et al., Mechanistic and multiscale aspects of thermo-catalytic CO₂ conversion to C₁ products, Catalysis Science & Technology, 2021, DOI 10.1039/D1CY00922B | Peer-reviewed reaction, thermodynamic and catalyst discussion | https://pubs.rsc.org/en/content/articlehtml/2021/cy/d1cy00922b |
| S12 | Power-to-liquid via synthesis of methanol, DME or Fischer-Tropsch-fuels: a review, Energy & Environmental Science, 2020, DOI 10.1039/D0EE01187H | Peer-reviewed reaction stoichiometry, exothermicity and equilibrium effects | https://pubs.rsc.org/en/content/articlehtml/2020/ee/d0ee01187h |
| S13 | Kanuri et al., An insight of CO₂ hydrogenation to methanol synthesis, International Journal of Energy Research, 2022, DOI 10.1002/er.7562 | Peer-reviewed catalyst and operating-parameter review; individual catalyst results are not plant guarantees | https://onlinelibrary.wiley.com/doi/full/10.1002/er.7562 |
| S14 | MNRE, Model Comprehensive Guidelines for State-Level Green Hydrogen Policy, 2024 | Indian policy guidance; water requirement and resource constraints | https://nghm.mnre.gov.in/admin/uploads/resources/172710376116547ASPIRE%20Model%20Comprehensive%20Guidelines%20for%20Green%20Hydrogen%20Zero_20092024.pdf |
| S15 | Raw Gas Treatment and Conditioning for Methanol Production from Biomass and Waste Gasification, ACS Omega, 2026, DOI 10.1021/acsomega.6c05837 | Peer-reviewed recent review; biomass syngas contaminants and cleaning train | https://doi.org/10.1021/acsomega.6c05837 |
| S16 | A review of cleaning technologies for biomass-derived syngas, Fuel, 2024, DOI 10.1016/j.fuel.2024.132776 | Peer-reviewed review of contaminants and syngas-cleaning requirements | https://doi.org/10.1016/j.fuel.2024.132776 |
| S17 | PIB/MNRE, India commissions 8,000 TPA Green Hydrogen capacity till February 2026, 25 Mar 2026 | Official Indian market/mission status; not a project-specific supply guarantee | https://www.pib.gov.in/PressReleasePage.aspx?PRID=2245157&lang=2&reg=48 |
| S18 | ISCC PLUS certification | Voluntary chain-of-custody scheme; segregation, controlled blending, mass balance and site certification | https://iscc-system.org/certification/certification-schemes/iscc-plus/ |

---

## 13. Handoff to Prompt 3

Subject to user approval, Prompt 3 should consume:

- the approved base route and two alternative case IDs;
- the common product comparison boundary;
- route-specific unit-operation lists;
- the electrolyser comparison and selected reference configuration;
- the Indian Green Methanol Standard/GHCI interpretation and open certification issues;
- the site/source evidence still required;
- the scoring matrix and route-gate conditions.

Prompt 3 may then formulate the design basis. It must not treat national biomass estimates or international operator announcements as site data, and must obtain approval for capacity, feed/product specification, operating hours, site, utility assumptions and case definitions before design-basis freeze.
