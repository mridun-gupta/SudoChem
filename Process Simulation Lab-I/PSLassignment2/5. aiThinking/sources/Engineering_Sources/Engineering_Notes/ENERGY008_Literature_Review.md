# ENERGY-008 Literature and Technical Data Review

**Project:** ENERGY-008 – Green methanol synthesis: utility integration and energy KPIs  
**Research retrieval cut-off:** 31 October 2026  
**Working route:** Route C – biogenic CO₂ + renewable electrolytic H₂; alkaline (ALK) reference, PEM flexibility case  
**Alternatives:** Route A – existing industrial CO₂ + renewable H₂; Route B – sustainable biomass gasification and syngas-to-methanol  
**Design basis referenced:** `03_Design_Basis/ENERGY008_Design_Basis.xlsx`, Rev 0.1-DRAFT  
**Phase status:** Research/source baseline only. No process design, balances, equipment sizing, cost estimate, MATLAB implementation or certification claim is produced here.

---

## 1. Executive summary

The reviewed sources support the **route architecture** selected for ENERGY-008, but do not yet support every numerical assumption in the draft design basis.

The selected route is CO₂ hydrogenation using biogenic CO₂ and renewable electrolytic hydrogen. ALK remains the reference electrolyser; PEM remains a flexibility comparison. Existing industrial CO₂ plus renewable H₂ (Route A) and biomass gasification/syngas-to-methanol (Route B) remain comparators.

Three critical technical data issues have emerged.

1. **Kinetic pressure-range mismatch.** The draft design basis uses 7 MPa(a), equivalent to 70 bar(a). The foundational kinetic data by Graaf et al. extend to approximately 50 bar, and the Vanden Bussche/Froment commercial-catalyst model uses data up to approximately 51 bar. A broader literature operating range of 5–10 MPa does not validate those rate expressions at 70 bar. The kinetic model and pressure basis therefore remain a Prompt 5 hold point. [SRC-005, SRC-006, SRC-004]

2. **High-pressure mixture-property gap.** NIST WebBook and JANAF provide useful pure-species reference data, and IAPWS IF97 is authoritative for water and steam. They do not alone provide the validated high-pressure EOS, mixture parameters, phase-stability treatment and methanol-water VLE required for the synthesis loop and purification train. REFPROP and DIPPR require paid access; CoolProp is open-source but its pair/flash support and state-point consistency must be checked. No property package was run against the ENERGY-008 mixture in this phase. [SRC-027–SRC-034]

3. **Water-accounting inconsistency.** MNRE guidance gives 18–20 L/kg H₂ as a total including purification/process cooling; NITI Aayog gives approximately 18–25 L/kg H₂; a PNGRB case study reports 59–95 kg/kg with broader demineralisation/cooling assumptions. The figures have different system boundaries and must not be averaged. The next phase must split withdrawal, DI feed, treatment reject, cooling makeup, cooling recirculation, blowdown and net consumption. [SRC-024–SRC-026]

The Indian regulatory position has also been clarified. MNRE's Green Methanol Standard dated 27 February 2026 requires Green Hydrogen, allows CO₂ from biogenic sources, direct air capture or existing industrial sources, and sets a ceiling of 0.44 kg CO₂e/kg methanol for non-biogenic emissions from the specified stages, averaged over the preceding 12 months. The notification says detailed methanol MRV/certification procedures will be specified separately; no later procedure was confirmed in this review. [SRC-001]

For product quality, BIS lists IS 517:2020, Third Revision, reviewed in 2024, with two amendments and voluntary certification. The Methanol Quality Control Order 2019 was withdrawn by Gazette notification S.O.3379(E), effective 23 July 2025. IMPCA V10 remains a useful industry reference target, but must be compared with the full BIS text/amendments and any customer contract before the product grade is frozen. [SRC-047, SRC-048, SRC-046]

**Readiness judgement:** the evidence base is adequate to guide the next property-data and model-selection phase. It is not yet adequate to perform detailed thermodynamic calculations without first resolving the kinetic pressure gap and mixture-property package.

---

## 2. Research scope and evidence method

### 2.1 Routes covered

| Route | Carbon source | Hydrogen source | Main route-specific research |
|---|---|---|---|
| C – selected working route | Biogenic CO₂, with biogas-upgrading CO₂ as a source archetype only | Renewable electrolytic H₂; ALK reference, PEM flexibility case | CO₂ source quality/recovery, electrolysis, water and power, high-pressure CO₂ hydrogenation |
| A – alternative 1 | Existing industrial CO₂; fossil/biogenic origin must be separately recorded | Renewable electrolytic H₂ | Capture/recovery, contaminants, source carbon origin and lifecycle attribution |
| B – alternative 2 | Sustainable biomass residues | H₂ and CO contained in biomass-derived syngas | Biomass preparation, gasification, tar/particulate/sulfur/halide/nitrogen cleanup, syngas conditioning and certification treatment |

All routes retain the common product boundary at the methanol product storage/loading manifold. Their upstream operations, feed compositions, utilities and wastes remain route-specific.

### 2.2 Evidence hierarchy and source quality

The source register uses a 1–5 evidence-quality score:

| Score | Meaning |
|---:|---|
| 5 | Primary experimental data; primary official legal instrument; official reference database; or authoritative standards catalogue |
| 4 | Peer-reviewed review or official technical report. Good synthesis, but use cited primary data for numeric engineering parameters |
| 3 | Operator project announcement, industry source or public index headline. Useful for maturity/scale context, not independent performance guarantee |
| 2 | Secondary summary or vendor marketing; corroboration required |
| 1 | Weak or unverified source; not suitable as a parameter basis |

Retrieval metadata, conditions/ranges, uncertainties, route applicability, intended use and access status are recorded in `ENERGY008_Source_Register.xlsx`. Where full text, supplements, standards or commercial databases were not accessible, the register says so. No unviewed paper or paywalled dataset is represented as extracted.

---

## 3. Route C: biogenic CO₂ hydrogenation with renewable electrolytic H₂

### 3.1 Reaction network and thermodynamic constraints

The desired reaction is:

\[
\mathrm{CO_2 + 3H_2 \rightleftharpoons CH_3OH + H_2O}
\]

The reaction is exothermic, so the reactor must remove heat and control catalyst temperature. The reverse water-gas-shift pathway competes:

\[
\mathrm{CO_2 + H_2 \rightleftharpoons CO + H_2O}
\]

Where CO is present or generated, CO hydrogenation may also contribute to methanol formation. The model must keep reaction stoichiometry, thermodynamic equilibrium, kinetic limitations, feed composition and recycle definitions consistent.

The reviews by Alam et al. and Dieterich et al. describe mechanisms, thermodynamic constraints, catalyst families and reactor/heat-management options. The 2026 industrial-scale review by Wang et al. identifies catalyst stability, operating conditions, CO₂ capture and purification, renewable hydrogen supply, economics and commercialisation as coupled constraints. [SRC-004, SRC-007, SRC-008]

**Implication:** the stoichiometric H₂ and CO₂ quantities in the design-basis workbook are lower-bound anchors only. They are not actual fresh-feed rates, single-pass reactor rates or guaranteed yields. Actual flows depend on conversion, selectivity, recycle, purge, source recovery, gas losses and off-spec production.

### 3.2 Kinetics and pressure validity

| Primary source | Identified basis | ENERGY-008 consequence |
|---|---|---|
| Graaf, Stamhuis & Beenackers (1988) | Cu-Zn-Al catalyst; approximately 210–245°C and 15–50 bar; multiple rate equations assessed | A foundational kinetic basis inside its tested range; not evidence for 70 bar(a) |
| Vanden Bussche & Froment (1996) | Commercial Cu/ZnO/Al₂O₃ catalyst; approximately 180–280°C; experimental/model data up to about 51 bar | A strong candidate model for comparison, but it must not be described as validated at the draft 70 bar(a) point |

Some reviews describe industrial CO₂ hydrogenation in a broad pressure envelope extending beyond 50 bar. This is a statement about industrial process conditions and route context, not proof that the Graaf or Vanden Bussche/Froment kinetic expressions predict rates accurately at 70 bar.

**Prompt 5 hold point:** obtain primary data or a catalyst/OEM kinetic model validated at the pressure, temperature, composition, space velocity and catalyst age relevant to the proposed model. If this is not available, either retain the model within its validated range and label the 70-bar case extrapolative, or return the pressure assumption for user approval before it becomes a calculation basis. [SRC-005, SRC-006, SRC-004]

### 3.3 Catalyst formulation, deactivation and feed cleanliness

Cu/ZnO/Al₂O₃ is the established reference catalyst family for low-temperature methanol synthesis. It is a literature reference only; no commercial catalyst grade or vendor has been selected.

The reviewed catalyst-stability literature identifies sintering and oxidation as material deactivation mechanisms and discusses effects of water/CO₂ exposure and catalyst structure. Performance also depends on active phase, support/promoters, particle geometry, activation/reduction, space velocity, temperature profile, feed contaminants and time-on-stream. One liquid-phase-assisted deactivation study reports water/sintering effects in its specific solvent-assisted configuration; those data are not quantitatively transferable to a gas-phase reactor without validation. [SRC-009, SRC-010]

For Route C, the assumed biogenic CO₂ source is only an archetype. Potential source-dependent contaminants include H₂S, water, methane, nitrogen, oxygen, siloxanes and volatile organics. No ppm limits are assigned. The source gas assay and catalyst supplier's feed-acceptance specification must govern dryer/guard-bed and purification requirements.

For Route B, syngas cleanliness is a major additional barrier. Biomass-derived gas may contain particles, tar, sulfur species, halides, nitrogen compounds, alkali and trace metals. Their amount depends on the biomass feed, gasifier and gasification medium. Peer-reviewed reviews describe wet and dry clean-up options and examples of contaminant limits, but these are not a methanol catalyst supplier specification. [SRC-012–SRC-014]

### 3.4 Reactor technology and heat removal

The PtL process review compares multiple methanol reactor concepts and their heat-removal characteristics. Concepts discussed in the literature include adiabatic/quench arrangements, gas-cooled systems, steam-raising/boiling-water-cooled reactors, fluidised beds and liquid-phase-assisted synthesis. They differ in temperature-profile control, heat-transfer area, catalyst handling, pressure drop, scale-up and operating flexibility. [SRC-008]

A separate liquid-phase process study reports very high single-pass CO₂ conversion for specific solvent-assisted process cases, but solvent recovery energy and the study's process assumptions materially affect the result. This does not establish a higher conversion for the selected gas-phase reference route and does not select a liquid-phase reactor for ENERGY-008. [SRC-011]

**No reactor type is selected here.** Reactor selection belongs in the later equipment/model phase after kinetic validity, property models, heat-removal duty and catalyst constraints are reviewed.

### 3.5 Gas cooling, condensation, recycle and purge

A CO₂ hydrogenation synthesis loop commonly separates condensed methanol/water from unreacted gas, recycles a portion of the gas and purges inerts or contaminants. Recycle reduces fresh-feed losses but increases circulating gas, compression duty and equipment load. Purge prevents inert build-up but can lose hydrogen/carbon unless recovery is justified.

The later model must include:
- reactor inlet and outlet component flows;
- condenser and separator phase split;
- methanol/water crude liquid composition;
- recycle flow and composition;
- purge flow, composition and carbon/hydrogen loss;
- inert accumulation and purge control;
- off-gas treatment/emissions;
- any justified recovery of H₂ or CO₂ from purge.

No recycle ratio, purge fraction or separator state is selected by this research phase.

### 3.6 Crude methanol purification and product quality

Crude liquid from the synthesis/separation train contains water and may contain trace impurities from reaction side-products or feed contamination. A methanol purification train is needed to meet the selected product specification.

The later model needs:
- pressure-specific methanol-water VLE;
- NRTL/UNIQUAC or another justified liquid-activity model where appropriate;
- binary parameters traced to experimental data;
- liquid enthalpy/density/viscosity data;
- trace impurity partition where it affects product acceptance;
- condenser/reboiler properties and heat integration.

Pure methanol EOS data or an aqueous binary incompressible property fit do not establish general methanol-water VLE. CoolProp's mixture support must be checked for the exact input pair and composition range, and its methanol fluid page must be used only within documented validity and consistency limits. [SRC-030–SRC-033]

---

## 4. Renewable hydrogen: ALK reference and PEM flexibility case

### 4.1 Electrolyser maturity and performance

IRENA's 2023 technology comparison classifies alkaline and PEM electrolysers as commercial technologies in its comparison; SOEC is at demonstration level and AEM is less mature in that assessment. Reported electricity use, operating load, pressure, temperature and start-up ranges are literature comparators, not guaranteed OEM values. [SRC-016]

The working arrangement retains:
- ALK as reference where renewable electricity can be scheduled, firmed or buffered;
- PEM as a flexibility configuration where variable renewable supply and rapid response have value;
- SOEC only if a real high-temperature heat source and a credible vendor/durability package become available;
- AEM only if a bankable supplier and performance guarantees are found.

The model requires a vendor performance map, not a single kWh/kg value. Required fields include kWh/kg H₂ at each load, stack vs system boundary, outlet pressure, purity/moisture, gas crossover, response/ramp, minimum load, availability, degradation, replacement schedule, water quality and warranty.

IEA cost/project reports provide useful market benchmarks, but global/overseas regional figures are not Indian vendor quotations. They must retain date, currency, scale and equipment/system boundary. [SRC-017, SRC-018]

### 4.2 Renewable electricity and carbon-intensity records

Renewable electricity provenance must be evidenced by the supply arrangement, source, generation profile and compliant storage/grid-banking treatment. The GHCI and Green Methanol Standard create separate accounting boundaries. The design basis does not yet contain a PPA, hourly generation profile, storage/dispatch record, grid banking arrangement or tariff.

The future model should separately meter and report:
- electrolyser system electricity;
- water treatment;
- CO₂ and H₂ compression;
- synthesis loop compression and pumping;
- cooling/refrigeration;
- product purification;
- other site auxiliaries;
- renewable vs grid/backup electricity and storage losses.

Do not label all electricity renewable merely because the process is called green.

### 4.3 Water use: non-comparable published estimates

| Source | Indicative quantity | Boundary/limitation |
|---|---:|---|
| MNRE model state-level guidance | 9 L DI water/kg H₂; 18–20 L/kg total | Includes purification/process cooling in the total figure |
| NITI Aayog | About 9 L purified water/kg H₂; about 18–25 L/kg including cooling/pretreatment | Notes cooling-water recycling; accounting boundary differs from MNRE |
| PNGRB case study | Approximately 59–95 kg/kg H₂ in its case assumptions | Includes broader demineralisation/cooling use and is not directly comparable to MNRE planning guidance |

These values are not to be averaged or treated as a single plant guarantee. The water ledger must separately record raw-water withdrawal, RO feed/reject, DI feed, cooling makeup, cooling recirculation, evaporation, blowdown, wastewater, reuse and net water consumption. [SRC-024–SRC-026]

The site water source and water-quality analysis remain unselected. Water availability may be a route feasibility constraint, especially in water-stressed regions.

### 4.4 Oxygen by-product and safe handling

Electrolysis produces oxygen in the stoichiometric water-splitting reaction. The theoretical quantity in the existing design basis is a stoichiometric anchor only. It is not a guaranteed saleable oxygen output.

Any O₂ export/credit requires actual oxygen purity, pressure, water/contaminant analysis, conditioning/compression, storage, compatible materials, customer offtake and a safe system design. No oxygen revenue or avoided-emissions credit is assumed.

---

## 5. Route A: existing industrial CO₂ + renewable H₂

Route A retains the same CO₂ hydrogenation synthesis core and renewable H₂ supply but changes the carbon-source and capture/conditioning front end.

The MNRE Green Methanol Standard explicitly includes existing industrial CO₂ as an eligible source category. That means Route A is not automatically disqualified by the notified standard. However, carbon origin must remain distinct: existing industrial CO₂ may be fossil-origin or biogenic depending on its source. Source eligibility is not proof that the carbon is renewable or permanently removed. [SRC-001]

Required source-specific data include:
- industrial facility and source process;
- CO₂ gas composition and carbon origin;
- pressure, temperature and continuity;
- capture/recovery process and energy;
- moisture and contaminants;
- source ownership, transfer and chain-of-custody;
- downstream methanol end-use and carbon fate.

No industrial CO₂ facility is selected.

---

## 6. Route B: biomass gasification and syngas-to-methanol

Route B has a materially different front end: biomass receipt/preparation, gasification, hot-gas cooling, tar/particulate removal, sulfur/halide/nitrogen cleanup, syngas conditioning, compression and then methanol synthesis.

The reviews by Rey et al., Motta et al. and the 2026 ACS Omega raw-gas-treatment paper identify the broad contaminant families and clean-up train choices. Actual raw-gas composition and cleaning duty depend on the feedstock, gasifier type, gasification agent and operating regime. [SRC-012–SRC-014]

Indian resource evidence includes the SSS-NIBE National Biomass Atlas, but its historic data basis is 2017–18. It is a resource inventory, not evidence of a present sustainable catchment, contract quantity, feedstock quality or delivered cost. NITI Aayog's IISc/Praj biomass-to-syngas milestone demonstrates domestic R&D activity, not commercial operation of an integrated biomass-to-methanol plant. [SRC-022, SRC-023]

The GHCI recognises biomass conversion, including gasification, as an eligible Green Hydrogen pathway. Its hydrogen boundary includes process steps such as biomass processing, heat/steam generation, conversion and hydrogen purification/drying/compression/storage. Route B currently sends mixed syngas directly toward methanol synthesis. A biomass H₂ production pathway being eligible does not, by itself, resolve Green Methanol certification for direct mixed-syngas conversion.

**Route B must remain certification-unresolved** until a written interpretation from the relevant MNRE/BEE/accredited verification authority is obtained.

---

## 7. CO₂ recovery, purification and compression

For Route C the selected carbon-source archetype remains a biogenic CO₂-rich source, such as biogas upgrading. No actual facility or source assay has been identified.

Before selecting a purification method, obtain:
1. source process flow diagram and carbon-origin evidence;
2. raw gas sample certificate and dry/wet basis;
3. CO₂, H₂O, CH₄, H₂S, O₂, N₂, CO and source-specific siloxane/volatile impurity data;
4. source pressure, temperature, flow, uptime and seasonal profile;
5. catalyst supplier's feed-acceptance specification;
6. recovery efficiency, pressure-drop, electricity/heat, solvent/sorbent and waste information from supplier or primary data.

CO₂ recovery/conditioning should be recorded in the expanded engineering gate-to-gate and lifecycle inventories. Do not quietly include/exclude it from the MNRE regulatory metric; follow the official MMRV methodology once its current implementation is confirmed.

No capture technology, compressor type or capacity is selected in this phase.

---

## 8. Equipment design methods and standards

### 8.1 Equipment correlation source

Towler and Sinnott, *Chemical Engineering Design*, Third Edition (2021), is a suitable broad screening reference for process flowsheets, pressure vessels, reactors, separation, heat exchangers, pumps/compressors, storage, utilities, safety and cost estimation. Generic correlations from a textbook are preliminary methods; they do not replace construction codes, vendor calculations, materials approval, relief analysis or independent competent review. [SRC-035]

Later equipment work should source separate methods and data for:
- reactor catalyst volume, kinetics, pressure drop and heat-removal geometry;
- pressure vessel material, code, design pressure/temperature, corrosion allowance and examination;
- compressor gas properties, performance map, surge, seals, materials and efficiency;
- pump curves, NPSH, motor efficiency and service factor;
- heat exchanger U-values, fouling, allowable pressure drop, materials and vendor thermal/hydraulic checks;
- gas-liquid separator and demister sizing;
- storage, transfer and loading;
- water treatment, wastewater, off-gas and vent/relief systems.

### 8.2 Codes and equipment standards identified

| Standard | Edition/status identified | Intended scope | Limitation |
|---|---|---|---|
| ASME BPVC Section VIII | 2025 edition | Pressure vessels | Licensed; Indian adoption/code-of-record not selected |
| ASME B31.3 | 2024 edition | Process piping | Licensed; local/client acceptance and hydrogen material basis required |
| TEMA | 2026 Edition issued 1 Aug 2026 | Shell-and-tube exchanger details | Subscription; not applicable to all exchanger types |
| API 610 | 13th Edition/2026 catalogue listing | Centrifugal pumps in petroleum/petrochemical/natural-gas service | Not a universal small utility-pump standard |
| API 617 | API STD 617:2022; current BSI listing 29 Jan 2026 | Axial/centrifugal compressors and expander-compressors | Not reciprocating compressors |
| API 520 Part I | 10th Edition announcement | Pressure-relieving devices in refinery scope | Does not replace complete relief scenario/disposal design |
| API 521 | Current edition not confirmed in this research pass | Relief/depressuring systems | Must verify edition before use |

The publication of a current international code does not establish that it is legally mandatory in India or selected for this academic project. The site jurisdiction, client/faculty requirement, service and regulator acceptance must govern the code-of-record decision. Full ASME/API/TEMA/ASTM texts were not accessed in this phase. [SRC-040–SRC-045]

### 8.3 Boilers and pressure systems

The Boilers Act 2025 came into force on 1 May 2025. It applies to boilers and boiler components as statutorily defined; it is not a generic pressure-vessel design code for every synthesis reactor or separator. [SRC-050]

PESO requirements depend on the actual hydrogen storage and transport configuration. The 2 February 2026 PESO circular specifically concerns approved hydrogen cylinder cascades mounted on a vehicle for road transport. It should not be treated as blanket approval for every stationary bulk hydrogen system. Current Gas Cylinders Rules and SMPV(U) amendments listed by PESO need clause-by-clause comparison before any storage compliance claim. [SRC-053–SRC-055]

---

## 9. Thermophysical and thermochemical property-data strategy

### 9.1 Pure-species sources

| Source | Data and role | Limit |
|---|---|---|
| NIST Chemistry WebBook SRD 69 | Species molecular weights, phase-change, thermochemical and selected transport data; individual records cite source measurements/correlations | Individual species records must be extracted with phase and T/P validity; not a complete mixture EOS |
| NIST-JANAF SRD 13 | Evaluated Cp, enthalpy, entropy, Gibbs functions and equilibrium functions vs temperature | Pure-species standard thermochemistry; data content last updated 1998; not mixture fugacity |
| IAPWS IF97 R7-97(2012) | Industrial water/steam thermodynamics | Water/steam only, not methanol-water VLE |
| NIST REFPROP v10 | Reference EOS and transport tool for pure fluids and supported mixtures | Paid/licensed; verify required mixture coverage and version |
| CoolProp 8.0.0 | Open property library with pure-fluid and selected mixture models, including cubic PR/SRK backends | Pair-specific interaction data and flash support are limited; state consistency must be tested |
| DIPPR 801 | Evaluated pure-component and mixture property database | Paid/licensed; no institute licence assumed |

### 9.2 Component and mixture list

The source workbook's Property Inventory lists CO₂, H₂, methanol, water, CO, O₂, N₂, CH₄, Ar, H₂S, NH₃, HCN, sulfur-containing species and route-specific mixtures.

For each relevant component, the next phase must record:
- molecular weight, component identifier and source;
- Cp(T), enthalpy and entropy with reference state;
- standard heat/Gibbs of formation and equilibrium functions;
- critical properties and EOS parameters if used;
- vapour pressure and phase boundary;
- density, viscosity and thermal conductivity;
- T/P/phase validity and uncertainty;
- original reference/correlation underlying software output.

For mixtures, a validated EOS and pair parameters are required. NIST pure-component pages do not supply complete mixture fugacities. CoolProp's mixture documentation explicitly requires pair-specific excess/reducing-function information and has limits on flash input pairs. A software package must be tested for each actual mixture pair and state range before it is accepted. [SRC-027–SRC-034]

### 9.3 Methanol-water VLE

The purification train requires experimental methanol-water VLE data at the intended pressure range and a justified liquid activity model or other validated thermodynamic model. A binary NRTL/UNIQUAC fit must be supported by traceable experimental data and checked against independent measurements. Pure methanol EOS data or an aqueous incompressible fit are not enough.

### 9.4 Licence and access status

- NIST WebBook/JANAF: public reference sources.
- IAPWS IF97: public formulation.
- CoolProp: open-source; preserve release, licence and pair coverage.
- REFPROP: paid/licensed; no licence or project run claimed.
- DIPPR 801: paid/licensed; no licence or parameter retrieval claimed.
- ASME/API/TEMA/ASTM: licensed or subscription standards; catalogue metadata was inspected, not full clause text.
- Vendor electrolyser/catalyst/CO₂ capture packages: no quotations or performance guarantees were received.

The Access and Licensing sheet defines honest proxy strategies for each unavailable source.

---

## 10. Indian regulatory and standards screening

### 10.1 Green Methanol and Green Hydrogen

The MNRE Green Methanol Standard dated 27 February 2026 is the project green-methanol claim basis. It requires Green Hydrogen, allows biogenic CO₂, DAC and existing industrial CO₂ source categories, and establishes the 0.44 kg CO₂e/kg methanol non-biogenic ceiling on the specified 12-month basis. The detailed methanol MMRV procedure was stated to be separately specified. [SRC-001]

The GHCI scheme defines a distinct hydrogen certification boundary and 2.0 kg CO₂e/kg H₂ threshold. It includes electrolysis and biomass-conversion pathways. Do not use the GH2 threshold as the methanol threshold, and do not assume that Route B's mixed syngas feed is certified Green H₂ without a formal interpretation. [SRC-002, SRC-003]

### 10.2 Methanol product quality

BIS lists IS 517:2020, Third Revision, with review in 2024 and two amendments. The BIS catalogue lists voluntary certification. The Methanol QCO 2019 was withdrawn on 23 July 2025 by S.O.3379(E). This makes it necessary to distinguish:
- Indian product standard IS 517:2020 and its amendments;
- voluntary IMPCA V10 reference;
- specific buyer/offtake product contract;
- any future replacement QCO or export-market specification.

The full IS 517 text and amendments must be obtained before final QA limits/test methods are selected. [SRC-046–SRC-048]

### 10.3 Environment, water and air

The Water Act, Air Act, Environment Protection Act/Rules and 2025 water-consent guidelines provide national legal frameworks. State/UT boards and authorities administer many site-specific consent conditions. The Water (Amendment) Act 2024's state/UT applicability must be confirmed for the eventual site. [SRC-049, SRC-056]

The EIA Notification 2006 and amendments require project-specific screening against the actual facility, schedule category, capacity, location and integrated project scope. This review does not assign the green methanol facility automatically to any particular EIA category. Obtain a written MoEFCC/SEIAA screening determination. [SRC-057]

### 10.4 Hazardous chemicals, workplace safety and pressure systems

The MSIHC Rules 1989 and Chemical Accidents Rules 1996 may create notification, safety-report and emergency-planning obligations depending on actual inventories and thresholds. No applicability conclusion is possible without maximum methanol/H₂ inventories and storage details. Hazardous Waste Rules 2016 applicability depends on the actual spent catalyst, adsorbent, solvent and sludge classification. [SRC-058–SRC-060]

The OSHWC Code 2020 was announced as effective on 21 November 2025. State rules and establishment-specific requirements need site review. CEA's 2023 electrical-safety regulations and listed 2026 amendment require consolidated text review for the actual voltage and installation. PESO rules need actual storage/transport configuration. [SRC-051–SRC-055]

### 10.5 Code selection and legal applicability

ASME BPVC VIII, B31.3, API and TEMA are technical standards candidates, not automatic declarations of Indian legal compliance. The project must record the code of record, edition/addenda, service, adoption/acceptance, full-text access, deviations and competent reviewer.

No environmental clearance, statutory consent, hazardous-storage licence, equipment-code compliance or safety-integrity certification is claimed in this research phase.

---

## 11. CAPEX/OPEX estimation and cost indices

AACE RP 18R-97 is a process-industry estimate-classification guideline. At low project definition a Class 5 estimate can have a broad indicative accuracy range, sometimes approximately −30% to +100%, depending on project definition and evidence. It is not a fixed confidence interval or vendor quote. [SRC-036]

CEPCI is a U.S.-oriented process plant index. The latest public monthly update identified at the 31 October 2026 cut-off lists August 2026 preliminary and July 2026 final; full values/subindices may require member access. It is not an India location factor. [SRC-037]

India's Office of Economic Adviser released a new WPI base year 2022–23 and Output PPI/Trial Input PPI series in June 2026. These are relevant Indian price statistics, but not a dedicated process-plant capital index. A suitable manufacturing/commodity sub-index may be used later as a disclosed proxy. [SRC-038, SRC-039]

Later cost records must preserve:
- base currency and price year;
- region and location factor;
- capacity and technology;
- supply-only vs installed scope;
- EPC/owner/commissioning/contingency/exclusions;
- index and sub-index used;
- FX conversion date/method;
- uncertainty and estimate class;
- source class: vendor quote, public project, index, handbook or academic estimate.

No CAPEX, OPEX or LCOM number is produced in Prompt 4.

---

## 12. Contradiction and gap register

Fourteen contradictions are recorded in the source workbook, and the companion CSV records 37 data gaps with required data, acceptable resolution, priority and gate.

The most critical are:
1. 50–51 bar kinetic data versus 70 bar(a) draft operating point.
2. CO₂-H₂-CO-MeOH-H₂O mixture EOS and interaction parameters not assembled.
3. Methanol-water VLE/activity-coefficient basis not selected.
4. Water factors with non-comparable boundaries.
5. IS 517 vs IMPCA product basis and QCO withdrawal.
6. GMeOH regulatory boundary versus expanded plant/LCA inventory.
7. Route B mixed syngas versus GHCI H₂ certification scope.
8. No source assay/chain of custody for biogenic CO₂.
9. No catalyst-grade impurity acceptance specification or catalyst lifetime guarantee.
10. No electrolyser supplier performance map.
11. No site renewable-power profile or water source.
12. No EIA/CTE/CTO/state legal screening.
13. No pressure vessel/piping code-of-record decision or relief basis.
14. No India vendor quotes or site utility/feedstock tariffs.

---

## 13. Prompt 5 handoff and phase gate

**Prompt 4 status:** research-source baseline assembled.  
**Property package:** not selected or validated.  
**Kinetic model:** not approved at 70 bar(a).  
**Regulatory applicability:** screened nationally; site-specific approval remains open.  
**CAPEX/OPEX:** no values produced.  
**Calculations and MATLAB:** not started.

Prompt 5 should first establish the thermophysical/thermochemical property basis:
1. Extract exact property data and source ranges for all relevant species from NIST WebBook/JANAF/IAPWS and primary property papers.
2. Check REFPROP/DIPPR licence availability and verify exact mixture support.
3. Test CoolProp pair/flash support and property consistency at project states.
4. Assemble high-pressure mixture EOS/interaction parameters and validation data.
5. Assemble methanol-water VLE data and parameter basis.
6. Resolve how the 70 bar kinetic/model mismatch will be treated.
7. Keep every unavailable property and extrapolation visible in the data-gap register.

Do not proceed to detailed balances or equipment calculations until this property-data package has been reviewed and approved.
