# ENERGY-008 Control Philosophy and Automation Basis

**Document:** ENERGY008-CTRL-001  
**Revision:** 0.1-DRAFT  
**Date:** 1 November 2026  
**Route:** Route C - biogenic CO2 + renewable electrolytic H2, pressurised alkaline electrolysis (ALK reference)  
**PFD:** ENERGY008-PFD-001 Rev 0.1-DRAFT  
**Status:** Preliminary engineering package for academic design development. Not approved for construction, procurement, operation, statutory submission, or emergency response.

> **Important design-status statement.** The control package is mapped to the current conceptual 28-equipment-tag / 55-material-stream PFD. The route selection remains provisional and G3 design basis is not frozen. No stream flow, composition, temperature, pressure or enthalpy table has been solved. No compressor map, electrolyser operating map, catalyst envelope, distillation design, utility duty, relief basis or final valve schedule is available. Therefore every numeric control setpoint, alarm threshold, trip threshold, instrument span, delay, deadband, valve fail position and voting arrangement that requires those inputs is intentionally marked **TBD / design hold point**. Values such as 7 MPa(a), 250 degC, 20 bar(a), 3:1 fresh-feed stoichiometry, 99.5 mol% dry CO2, 99.9 mol% dry H2 and 50 t/d are screening/design-basis references only and are not adopted as control limits.

---

## 1. Purpose, scope and governing basis

This document defines the preliminary control-system architecture, process control philosophy, loop allocation, alarm management, candidate protective functions, cause-and-effect intent and operator-interface requirements for the Route C e-methanol configuration.

The package covers:

1. CO2 receipt, knockout, filtration/guarding, purification and compression.
2. DI-water supply, ALK electrolysis, H2 purification/drying/compression and O2 handling.
3. Fresh-feed/recycle mixing, synthesis feed preheat, packed-bed reactor, effluent cooling/condensation, high-pressure separator, recycle and purge.
4. Crude-liquid letdown/degassing, methanol-water distillation, reflux, reboiler, product pumping and storage/dispatch.
5. Off-gas, wastewater, segregated drains, solid/hazardous waste, utilities and plant-wide gas/fire detection interfaces.

The PFD is not a P&ID. It does not establish instrument locations, valve arrangement, bypasses, isolation valves, pressure relief, vent headers, electrical segregation, package logic, cause-and-effect implementation or final control narratives. The loop register proposes tag families for P&ID development; it does not assert that instruments, valves or safeguards currently exist.

### 1.1 Route and operating references (all provisional unless noted)

| Item | Current reference | Control-design treatment |
|---|---|---|
| Process route | Route C: biogenic CO2 + renewable H2, ALK reference | Working configuration only; route gate approval remains open |
| PFD | ENERGY008-PFD-001 Rev 0.1-DRAFT | Conceptual; 28 equipment/package tags and 55 material streams |
| Capacity | 25 t/d minimum stable; 50 t/d normal; 55 t/d max continuous; 60.5 t/d process design | Screening cases only; do not code rate limits until approved balances and vendor turndown data |
| Reactor reference | 7 MPa(a), 250 degC nominal screening point; literature envelope 5-10 MPa(a), 200-300 degC | Not mechanical design conditions, controller setpoints or trip values |
| ALK H2 interface | 20 bar(a), sensitivity 15-30 bar(a) | Draft package interface only |
| Feed purity | CO2 >=99.5 mol% dry; H2 >=99.9 mol% dry | Screening targets only; actual contaminant acceptance limits require source assay and OEM/catalyst data |
| Feed ratio | 3:1 H2:CO2 | Stoichiometric anchor for fresh feed only; not the loop ratio or a validated operating setpoint |
| Power disturbance | 50% available renewable power for 2 h | Scenario selected for dynamic assessment; not a guaranteed grid/PPA condition or automatic trip threshold |
| Product quality | IMPCA Methanol Reference Specifications V10 academic target | Not a buyer contract; online analyser does not replace release testing |
| Utility conditions | U-001 to U-010 flows and supply/return conditions unquantified | Utility alarms/permissives require confirmed battery-limit data |

### 1.2 Design principles

- Normal regulatory control shall maintain stable, efficient operation without using protective trips as routine control actions.
- Equipment-package PLCs shall retain fast, vendor-specific machine and process protections. Plant DCS shall supervise, coordinate and display those packages.
- Safety instrumented functions (SIFs), where required by HAZOP/LOPA, shall be implemented in an independent safety system with documented independence, lifecycle management and proof testing. A DCS alarm or standard PLC interlock is not credited as a SIF by this document.
- Fire and gas detection shall use a dedicated FGS subsystem with independently powered field detectors and defined links to ESD, ventilation, annunciation and emergency systems.
- Pressure relief, tank P/V protection and other mechanical safeguards are independent protective layers. No software control loop substitutes for a correctly designed and sized relief device.
- Loss of communications, bad analyser quality, bad instrument quality or a failed permissive shall not silently be interpreted as a healthy process condition.
- No common H2/O2 vent, relief or drain header is assumed. Compatibility must be demonstrated before streams are combined.
- A process upset shall move the plant to a controlled, energy-minimised state while preserving required cooling, detection, ventilation, pressure protection and engineered disposal paths.

---

## 2. Control-system architecture and responsibilities

### 2.1 Recommended architecture

| Layer / subsystem | Primary responsibility | Typical signals and interfaces | Restrictions |
|---|---|---|---|
| Field instruments and final elements | Continuous measurement and actuation | 4-20 mA/HART, pulse, RTD/TC, discrete contacts, smart valve positioners, analysers, vibration probes | Hazardous-area certification, environmental rating and materials compatibility must follow the area classification and materials review |
| DCS / BPCS controllers | Plant regulatory control, sequences, ratio/cascade logic, permissives that are not safety functions, alarm generation | FIC/TIC/PIC/LIC, process sequences, package status, utility coordination | DCS is not assigned safety credit; do not implement SIF logic here |
| Package PLCs | ELY-201, K-101, K-201, K-301, P-101 and vendor skids | OEM-defined local loops, machinery protection, compressor sequencing, stack shutdown, diagnostics, local E-stop | Vendor safety functions remain within the package boundary unless a formal interface allocation transfers responsibility |
| SIS / ESD logic solver | Independently assessed SIFs and plant shutdown functions | Dedicated transmitters/switches, hardwired ESD pushbuttons, de-energise-to-trip outputs, ESD valves, compressor/stack trip interfaces | No direct SCADA write access; no SIL assigned; architecture and independence pending HAZOP/LOPA |
| FGS subsystem | H2, CO, CO2, O2, methanol vapour, flame/heat and related detection logic | Fixed gas detectors, manual call points, flame/heat detectors, local sounders/beacons, FGS-to-ESD interface | Detector coverage, voting and actions require dispersion/layout study; FGS alarms must not be hidden behind process graphics |
| Machinery protection system | Vibration, axial displacement, bearing temperature, speed and other OEM-defined rotating equipment protection | Dedicated probes/monitoring relays and package PLC/DCS status | Keep fast protection independent of DCS scan/communications where OEM requires it |
| HMI / operator stations | Operator monitoring, alarm response, approved supervisory commands and trends | DCS HMI clients, alarm/event server, engineering station | Commands to SIS are prohibited except authorised reset where designed; all reset actions require permissives and audit trail |
| SCADA / plant supervisory layer | Plant-wide KPI display, remote supervisory visibility, reporting and authorised interfaces | Read-only OPC UA or equivalent from DCS/package data gateways; selected supervisory writes only through DCS command/permissive path | No direct control path from enterprise network to controllers; no direct SIS or package safety writes |
| Historian / reporting | High-resolution event and process history, power/water/material KPIs, batch/quality records | DCS, PLC, SIS/FGS event mirrors, utility meters, laboratory/LIMS | Preserve source, quality flag, timestamp, engineering unit and configuration version |
| OT network/security | Segmentation, remote access control, backup, patching, asset inventory and time synchronisation | Managed switches, industrial firewall, DMZ, jump host, central logging, secure time | Apply project OT cybersecurity risk assessment and zones/conduits design before procurement |

**Recommended topology:** redundant DCS controllers and redundant operator/HMI servers where justified by availability study; segregated package-control networks; dedicated SIS and FGS networks; separate machinery-protection path; industrial DMZ between OT and business IT; historian replication through controlled interfaces. Use hardwired signals for critical trip demands, status feedback and critical permissives where communications latency or failure could affect safe shutdown. Package data may use an approved industrial protocol (e.g., OPC UA, Modbus TCP or vendor protocol) through a managed interface gateway. Protocol selection and register mapping remain vendor / cybersecurity actions.

### 2.2 Allocation by equipment

| Equipment / group | Normal controller ownership | Independent protection / package ownership |
|---|---|---|
| V-101, F-101, P-101 | DCS regulatory loops and sequence coordination | Package-specific P-101 logic; independent V-101 high-high level protection if HAZOP requires |
| K-101 | Compressor package PLC for sequencing and machine control; DCS setpoint/supervision | OEM machinery protection, discharge pressure/temperature, vibration, lube/seal protection |
| W-201 | DCS / water-treatment PLC for water train | OEM water-quality permissive to ELY-201; independent low-low supply protection if required |
| ELY-201 / D-201 / O-201 | ELY package PLC; DCS supervisory power/load command and availability | OEM crossover, separator differential pressure, pressure, stack temperature, rectifier and emergency shutdown functions |
| K-201 | H2 compressor / buffer package PLC | OEM overpressure, machinery, buffer and storage protection; PESO/code applicability review |
| M-301 / HX-301 / R-301 / E-302 | DCS for ratio, feed, pressure, temperature monitoring and cooling coordination | Candidate SIS reactor temperature/pressure/feed-isolation functions; independent mechanical relief; reactor specialist to define heat removal |
| V-301 / SP-301 / K-301 / PCV-301 | DCS level, purge/inert and coordinated loop control; K-301 package PLC | Compressor anti-surge/machinery protection; independent level trips if required; purge backpressure protection |
| V-302 / T-401 / E-401 / V-401 / E-402 | DCS column pressure, feed, reflux, reboiler, level and quality control | Independent column pressure relief; E-402 low-low level/heat-input isolation if allocated |
| P-401 / TK-401 | DCS transfer and tank level management; pump package protection | Independent tank high-high level and P/V protection; loading ESD |
| U-501 / W-501 / SW-501 / DR-501 | DCS monitoring, treatment package coordination and waste routing | Backpressure and FGS protections; independent bund/overfill protection where required |
| Utilities U-001 to U-010 | DCS utility summary and load-shedding coordination | Electrical protection, instrument-air source protection, emergency power and pressure protection per utility design |

### 2.3 Redundancy and signal integrity requirements

1. Redundant DCS controllers, network paths and HMI/historian services should be evaluated against availability targets. Do not duplicate every transmitter by default.
2. Candidate independent reactor protection measurements: multiple axial bed thermocouples at process-defined locations; separate SIS temperature elements from BPCS control elements where risk analysis requires independence. A 2oo3 arrangement is only a candidate for study, not a selected vote.
3. Candidate independent reactor pressure measurement for a high-high trip, separate from the normal PIC, if LOPA requires a SIF.
4. V-301 normal LT/LIC shall not be the only high-high or low-low protective sensor if carryover / gas blow-by is a credible hazard; separate LSHH/LSLL devices are proposed.
5. ELY-201 hydrogen/oxygen crossover, separator differential pressure and gas purity detection must be package-integrated and independent of ordinary load control to the extent required by OEM safety design.
6. K-101/K-201/K-301 vibration and fast machinery trips shall use OEM machinery protection hardware or package safety logic rather than depending solely on a DCS software alarm.
7. Gas detector placement and voting shall follow site dispersion and congestion assessment. No generic 1ooN/2ooN trip vote is prescribed.
8. Product quality analyser readings require a sample-system quality flag, calibration status and independent laboratory release method. Bad quality shall inhibit automatic product release.
9. Critical SIS/FGS power, I/O, communications and field circuits shall be segregated from BPCS where independence is required. UPS/emergency power scope and autonomy are TBD.
10. All analogue input channels require bad-quality detection, overrange/underrange handling, sensor fault diagnostics and timestamped event recording.

---

## 3. Control philosophy by process train

### 3.1 CO2 receipt and conditioning (V-101 / F-101 / P-101 / K-101)

- **Source flow and admission:** measure S-001 source flow and monitor pressure, temperature, moisture and source contaminant quality. Source flow control is subordinate to the selected downstream capacity and feed demand. A source qualification permissive is required before admitting gas to P-101 / synthesis service.
- **V-101 knockout:** continuous level control shall route condensate S-002 to W-501 via closed, compatible handling. Independent high-high level protection shall isolate/reduce source feed or stop upstream gas transfer if liquid carryover threatens downstream equipment. Low-low level protection is not assumed unless a liquid outlet can expose the gas train to gas blow-by.
- **F-101 guard train:** differential pressure across each filter/bed section shall be trended and alarmed. Breakthrough monitoring shall be selected from the source assay and catalyst vendor impurity limits. A common bypass must not defeat the guard barrier; bypass keying and permissives are a P&ID action.
- **P-101 purification:** package PLC owns solvent/adsorbent circulation, regeneration, sequencing and local permissives once technology is chosen. DCS monitors feed/product/reject flow, product composition, key temperatures, pressure and package status. Off-spec product gas shall be diverted/isolated from synthesis feed; reject S-007 remains collected by U-501.
- **K-101 CO2 compression:** package PLC controls compressor start/stop, load, lube/seal auxiliaries and any anti-surge/unloader logic required by machine type. DCS receives suction/discharge P/T, flow, vibration, power, trip code and availability. Discharge pressure control shall not override OEM minimum-flow or temperature limits.
- **Moisture/corrosion:** measure or sample dew point/moisture at relevant dry-gas boundaries and monitor condensate drains. Actual alarm limits require corrosion/materials review and catalyst acceptance limits.

### 3.2 DI water, ALK electrolyser, hydrogen and oxygen (W-201 / ELY-201 / D-201 / K-201 / O-201)

- **DI water quality:** measure DI make-up flow S-102 and online conductivity/resistivity at the electrolyser inlet; add other parameters only to the OEM water-quality specification. Off-spec water or low-low supply shall inhibit start or request an OEM-approved controlled shutdown. W-201 reject S-103 and electrolyte waste S-112 remain segregated.
- **Electrolyser power following:** the DCS may send an authorised power/load demand to the ELY package within vendor-approved ramp, min-load, turndown and stack temperature limits. The ELY PLC retains current/voltage control, gas separation, electrolyte circulation and shutdown. Renewable availability is a supervisory constraint, not permission to violate stable operating limits.
- **Power shortfall response:** on a sustained power constraint, ramp ELY load within OEM limits, use available H2 buffer only within its approved pressure/inventory envelope, then reduce synthesis feed in a ratio-preserving coordinated manner. If H2 availability cannot sustain the validated minimum feed composition, stop/inhibit synthesis feeds and hold/cool the reactor using the approved shutdown procedure. The 50% power-for-2-h scenario is for dynamic testing only; controller thresholds and time delays are not assigned.
- **ALK safety:** continuously monitor H2-side and O2-side pressures, separator differential pressure, electrolyte/stack temperature, H2-in-O2 and O2-in-H2 or OEM-defined purity/crossover variables, water flow and package status. Crossover or abnormal separator differential pressure invokes the OEM safety shutdown, isolation and separate purge/vent sequence. H2 and O2 shall never be cross-connected or sent to a common vent.
- **H2 drying and compression:** D-201 moisture/dew-point measurement and H2 purity are required at the catalyst feed boundary. K-201 package controls compressor and buffer; high buffer pressure limits/stops H2 generation and compressor loading. Buffer form, inventory, pressure design and protection remain open.
- **Oxygen handling:** O-201 monitors O2 purity, water content, H2 crossover and pressure. No export or vent permissive is assigned until the destination, gas quality, vent dispersion and oxygen-service design are approved.

### 3.3 Synthesis loop and recycle (M-301 / HX-301 / R-301 / E-302 / V-301 / SP-301 / K-301 / PCV-301)

- **Feed ratio:** use independent CO2 and H2 flow measurements. A ratio station shall calculate H2 demand from measured CO2 feed using an approved process-model / catalyst envelope and cascade to the H2 FIC. The 3:1 value is not loaded as a final SP; recycle gas composition changes the reactor inlet mixture and must be considered by the validated loop model. Analyzer bad quality, flowmeter failure or ratio excursion shall block feed increase and may require feed isolation.
- **Composition quality:** online gas analysis at the conditioned fresh feeds and/or reactor inlet should cover H2, CO2, CO, O2 and inerts as required by source assay and the reaction model. Analyser sample lag, validation and failure response must be included in control logic. No automatic feed permissive shall rely on an invalid/bad-quality analyser.
- **Recycle:** measure recycle flow S-209 and recycle gas composition. K-301 controls recycle throughput within compressor map and stable reactor flow. Recycle flow is not used as a substitute for maintaining fresh H2:CO2 ratio or purge/inert balance.
- **Loop pressure:** pressure control shall be resolved in the detailed control study. A candidate PIC-301 may coordinate fresh-feed compressor loading/capacity, with a high-pressure override limiting feed; the purge valve PCV-301 shall not be used as the sole routine pressure controller because it also controls loop inert removal and increases H2/CO loss. Final pressure actuator, split-range/override logic and pressure limits require solved mass/energy balance, dynamic simulation, compressor maps and relief study.
- **HX-301 feed preheat:** feed temperature control by a bypass or other heat-balance arrangement is conditional because no bypass is shown on the PFD and exchanger duty/thermal arrangement is unselected. Add the bypass, isolation and thermal protection to P&ID only after exchanger design review. Monitor hot/cold inlet/outlet temperatures and differential pressure.
- **R-301 temperature:** provide multi-point bed-temperature indication/trending along the catalyst bed, including rate-of-rise diagnostics. Ordinary temperature control shall act only on a defined preheat/heat-removal mechanism after reactor thermal design is complete. High-high temperature or validated rapid-rise criteria should initiate candidate independent feed isolation and preserve engineered cooling/heat-removal. The control package does not prescribe trip temperatures.
- **R-301 pressure and differential pressure:** continuously measure reactor inlet/outlet pressure and bed differential pressure. High pressure and abnormal DP alarms initiate operator response; independent protection and relief are determined by HAZOP/LOPA and mechanical design.
- **E-302 cooling/condensation:** regulate outlet temperature using cooling-medium flow or duty only after coolant side and condenser operating envelope are defined. Low cooling flow/high outlet temperature shall reduce reactant feed; if temperature control cannot be maintained, initiate the validated shutdown. Do not trip off cooling if it is required to remove stored heat unless an approved emergency sequence says otherwise.
- **V-301 level:** LIC-301 manipulates crude liquid outlet to V-302. Independent high-high level protects against liquid carryover to K-301; independent low-low level prevents gas blow-by into V-302. Demister efficiency, vessel holdup and operating level band are design inputs, not invented setpoints.
- **Recycle compressor anti-surge:** if K-301 is a centrifugal compressor, provide a vendor-engineered fast anti-surge controller using suction/discharge pressure, temperature and flow (and corrected map variables as vendor requires), with a fast recycle valve that moves to the vendor-defined protective position. If reciprocating or another machine type is selected, use OEM unloading / pulsation / minimum-flow protection instead; do not apply a centrifugal surge algorithm. Anti-surge is package control, separate from DCS recycle-flow control.
- **Purge:** FIC-305 / PCV-301 shall manage a purge rate determined from the validated inert balance and gas composition. High loop inerts, low purge, high purge loss, purge valve fault or U-501 high backpressure requires alarm and coordinated feed/load reduction. No purge stream shall be routed to atmosphere or a relief header without an approved disposition design.

### 3.4 Crude-liquid letdown and degassing (V-302)

- Maintain V-302 pressure through a closed gas outlet to the approved U-501 treatment system only after capacity and backpressure are confirmed. No direct vent is assumed.
- LIC-302 controls liquid feed to T-401. High-high level/pressure and unexpectedly high flash-gas flow shall alarm and invoke a process cutback/isolation sequence if the downstream disposal system is constrained.
- Flash gas S-211 shall be monitored for flow and composition. Gas disposal pressure and allowable backpressure are mechanical/process design hold points.

### 3.5 Methanol-water distillation and product (T-401 / E-401 / V-401 / E-402 / P-401 / TK-401)

- **Feed:** FIC-401 controls crude methanol feed from V-302 within column capacity. Feed composition and temperature shall be trended; feed rate is limited by column pressure, condenser/reboiler capability and quality constraints.
- **Column pressure:** PIC-401 coordinates E-401 condenser duty and/or a closed non-condensable outlet to the approved off-gas system. The final pressure-control method depends on column pressure and condenser design. High-high column pressure or loss of condenser/reflux shall isolate/cut hot utility to E-402 and stop/cut feed in the approved sequence. Independent relief remains required.
- **Reflux and quality:** reflux flow is measured; reflux ratio or top-temperature control may adjust reflux/product draw only after VLE/column simulation. Temperature profile measurements support diagnosis; a product analyser provides quality indication but does not replace lab certification.
- **Reboiler:** E-402 steam/hot-fluid flow is measured and controlled. A temperature/boil-up cascade may modulate hot utility. Independent low-low reboiler level or loss-of-circulation protection shall isolate hot utility if required by selected reboiler type. Failure-open of steam valve shall have an independent means of heat isolation.
- **Levels:** LIC-401 controls V-401 reflux drum liquid inventory through net distillate draw; reflux flow is independently measured. LIC-402 controls column bottoms inventory through water-rich bottoms S-307. Level control shall not compromise reflux or reboiler wetting/circulation.
- **Product transfer and quality:** product transfer permissive requires the receiving tank line-up, tank capacity, quality status, pump readiness, vapour/vent path, grounding/bonding and transfer ESD availability. Off-spec or unknown-quality material is held; automatic transfer to the product tank is inhibited. No off-spec diversion route is assumed until PFD revision adds it.
- **Tank:** independent high-high level protection stops P-401/loading and closes transfer ESD valves. Tank P/V and vacuum protection are mechanical. Nitrogen blanketing is conditional on tank design; if selected, monitor blanket pressure and low pressure, but never isolate required tank vent protection.
- **P-401:** package protection covers low suction, seal leakage, motor overload and other vendor limits. DCS provides start permissives, flow/transfer command and trip status.

### 3.6 Off-gas, wastewater, drains and waste (U-501 / W-501 / DR-501 / SW-501)

- **U-501:** measure aggregate inlet flow and representative gas composition (H2, CO, CO2, methanol vapour, O2 and relevant inerts) at a point agreed with the selected technology. Monitor header pressure/backpressure and treatment availability. High backpressure or unavailable treatment shall reduce/stop upstream purge and flash-gas sources through an orderly process shutdown; it shall not close or block a pressure-relief path. Relief disposal and routine process off-gas disposal must be separately engineered.
- **W-501:** level control maintains collection/treatment inventory. Online pH and conductivity are basic indicators; methanol/COD/chemical compatibility require analytical or package-specific monitoring. Off-spec effluent shall be retained or diverted to an approved hold tank/route, not automatically discharged. KOH electrolyte S-112 remains segregated and shall not be combined with ordinary wastewater absent verified compatibility.
- **DR-501:** drains stay segregated by compatibility class and source until the drain classification matrix is approved. Drain valves and routing should be locked / labelled, and transfer to W-501 requires receiving capacity and compatibility permissives.
- **SW-501:** waste containers/holding locations are monitored and inventoried by stream. Handling and dispatch are procedural, not continuous control loops; catalyst/guard media/KOH are kept in segregated approved packages.

### 3.7 Utility and throughput coordination

- **Electrical power:** separately meter electrolyser stack/rectifier, electrolyser BOP, process compressors, pumps, water treatment, cooling and other auxiliaries. Avoid double-counting U-001/U-009. DCS shall calculate plant load, kWh/t methanol, electrolyser SEC and renewable electricity share from validated meters and accounting inputs.
- **Cooling water U-002/U-003:** monitor supply pressure/temperature, main header flow, return temperature and key consumer flows. Low cooling availability shall cause process feed cutback/shutdown in the priority sequence defined by the utility failure study. E-302 and critical reactor heat-removal service receive explicit priority.
- **Instrument air U-005:** pressure, dew point/quality and compressor status are alarmed. Loss of air shall move valves to their engineered fail state; SIS/FGS and emergency ventilation power shall not rely on normal instrument air without a validated fail-safe design.
- **Nitrogen U-006:** pressure/flow/quality are monitored. Low N2 inhibits start-up, purging and catalyst-handling sequences. Automatic nitrogen admission is not initiated merely because an alarm occurs; the purge volume, endpoint and vent route must be designed.
- **Throughput:** master throughput target is constrained by CO2/H2 availability, electrolyser stable range, H2 buffer pressure/inventory, synthesis ratio/composition, reactor temperature/pressure, recycle compressor map, condenser duty, distillation capacity, off-gas treatment and utilities. A master rate controller may issue coordinated demand reductions but must not override unit protective limits.

---

## 4. Instrumentation and measurement requirements

### 4.1 Measurement matrix

| Variable / measurement | Application | Technology / notes | Required data-quality or design action |
|---|---|---|---|
| Flow | CO2 source/product; H2; recycle; purge; DI water; cooling water; steam; off-gas; product; effluent | Coriolis, thermal mass, ultrasonic, DP, vortex or magnetic as appropriate to phase, pressure, composition and turndown | Define minimum/normal/maximum flow, density/composition, pressure drop, straight-run, custody/KPI accuracy and turndown before meter selection |
| Pressure | Vessel, compressor suction/discharge, synthesis loop, ELY separators, H2 buffer, column, tank, utility headers, off-gas | Pressure transmitter with suitable diaphragm/seal; local gauge for maintenance/verification | Span to cover design and credible upset conditions; independent pressure switch/transmitter for candidate trips; impulse-line design and H2 compatibility review |
| Temperature | Reactor axial/radial bed, feed/effluent, compressor stages, ELY stack/electrolyte, condenser/reboiler/column trays, utilities | RTD or thermocouple based on temperature, response, sheath and pressure boundary | Multipoint reactor coverage and independent trip sensors where justified; response-time and thermowell integrity review |
| Level | V-101, V-301, V-302, V-401, T-401 bottoms, ELY separators, W-501, TK-401 | DP, guided wave radar, radar, displacer or OEM level technology | Select for foaming, density, dielectric, vapour space, pressure, caustic service and interface; independent HH/LL switches for critical hazards |
| Differential pressure | F-101 filter/guard, R-301 bed, HX-301, ELY separator membrane/diaphragm, filters/dryers | DP transmitter or OEM differential-pressure sensor | Alarm/trip limits from vendor and design pressure-drop allowance; separate ELY H2/O2 differential protection |
| H2 / CO2 / CO / O2 / methanol vapour composition | Fresh feeds, reactor inlet/loop/purge, U-501, ELY crossover, O2 export, product | Process GC, TCD/IR/paramagnetic/laser or application-specific analyser; fixed gas detectors for area protection | Sample conditioning, response time, calibration span, cross-sensitivity, sample return/disposal, bad-quality logic and proof/validation plan |
| Moisture / dew point | CO2/H2 conditioned feeds, H2 dryer outlet, product gas | Chilled mirror or calibrated moisture analyser appropriate to pressure/temperature | Set limit from catalyst/feed acceptance and corrosion review; account for sample-line pressure drop/condensation |
| Vibration / speed / axial position | K-101, K-201, K-301, P-401 rotating equipment | OEM proximity probes, velocity accelerometers, speed pickups, bearing RTDs, machinery monitor | Fast package protection separate from DCS display; alarm/trip values from OEM and mechanical acceptance criteria |
| Gas detection | H2, CO, CO2, O2 enrichment, methanol vapour by hazard zone | Fixed point/open-path detectors as justified; flame/heat detection where required | Coverage mapping from leak scenarios, ventilation and dispersion; detector type, placement, proof testing and voting from risk assessment |
| Water quality | DI feed to ELY, cooling water, wastewater and effluent | Conductivity/resistivity, pH, temperature, turbidity and OEM-specified ions/TOC as applicable | Raw-water analysis and vendor limits required; no generic conductivity limit assigned |
| Electrical power | ELY stack, rectifier, BOP, compressors, pumps, utility loads | Revenue/plant energy meters, power quality meters, DC voltage/current transducers | Separate metering boundary, timestamps and renewable attribute evidence; monitor harmonics, power factor, frequency and trips |

### 4.2 Analyser and sample-system principles

- Use representative, closed sample systems with pressure reduction, isolation, purge and return/disposal engineered for the analysed gas. No open high-pressure sampling is assumed.
- Sample conditioning shall avoid condensation, adsorption or reaction that biases H2, CO2, CO, methanol, water or O2 readings.
- Each analyser value shall have validity status, calibration status, maintenance bypass status and stale-data detection.
- A stale or invalid analyser shall not be treated as a normal composition. Feed ratio control may hold its last valid value only for a documented, time-limited period if approved by process safety; otherwise block feed increase and move to the approved fallback.
- Use laboratory analysis and certified calibration gases with traceable standards. Online analyser performance must be proven against lab reference samples before quality permissives are enabled.

---

## 5. Control modes, sequencing and permissives

### 5.1 Modes

| Mode | Purpose | Permitted commands | Key constraints |
|---|---|---|---|
| Local / maintenance | OEM maintenance and test under permit | Local jog/test only with isolations and bypass controls | Normal process operation inhibited; LOTO and bypass register mandatory |
| Manual | Operator direct output control | Manual valve/power demand within configured limits | Interlocks remain active; no SIS bypass through DCS manual mode |
| Auto | Regulatory PV-to-SP control | FIC/TIC/PIC/LIC and cascade control | SP limited by validated min/max envelope and package permissives |
| Cascade / ratio | Feed ratio, reflux ratio, temperature cascade | Secondary controller receives master demand | Ratio/quality limits and analyser validity required |
| Sequence / startup | Purge, package startup, controlled warm-up, feed admission | Step commands under permissive logic | Each step has timeout, feedback, abort state and operator prompt; sequences require OEM procedures |
| Shutdown / standby | Controlled reduction, reactant isolation, thermal management, depressurisation if designed | Coordinated unit demand and approved valve actions | Preserve cooling, vent/relief path, detection and safe isolation; no automatic unapproved blowdown |
| ESD | Emergency safe-state initiation | SIS / package safety action | Reset only after cause removed, inspection and authorised restart; no remote SCADA reset |

### 5.2 Startup permissive groups (design requirements)

**Plant / synthesis permissives:** approved route and G3 design basis; approved HAZOP actions closed; ESD/SIS/FGS healthy; no active trip; pressure relief and vent systems available; instrument air and required electrical supply healthy; cooling available; N2 available and approved purge sequence completed; oxygen ingress criteria met; source/feed analysers valid; H2 and CO2 quality within approved limits; ELY and compressor packages available; reactor temperature/pressure in vendor-approved startup envelope; V-301/V-302 levels suitable; U-501 treatment available; no active maintenance bypass that defeats a required protection.

**ELY-201 permissives:** OEM DI-water quality and flow; electrolyte system ready; stack thermal management available; gas separators within pressure/differential pressure limits; H2 and O2 paths line-up verified and segregated; O2 disposition path ready; package ESD and detector interfaces healthy; rectifier protection healthy; gas analyser/crossover channels valid.

**Column/product permissives:** column pressure protection available; E-401 cooling ready; E-402 utility available and isolated on demand; V-401 level instrumentation healthy; bottoms/reflux paths open; W-501 receiving capacity confirmed; product tank destination and quality status valid; tank level/PV protection and loading ESD healthy.

No automatic restart shall follow a trip without cause acknowledgement, required checks, permissive revalidation and authorised reset. Reset does not start equipment automatically unless an approved sequence explicitly requires it.

### 5.3 Coordinated throughput and power-shortfall narrative

1. DCS receives plant throughput demand, renewable power availability and unit availability signals.
2. The load coordinator calculates an admissible plant rate from approved constraints, but it does not calculate new process limits online unless that function is designed, verified and version-controlled.
3. On power shortfall, ELY load is ramped down inside OEM limits. H2 buffer inventory is monitored and used only within the approved operating band.
4. If H2 buffer pressure/inventory approaches the model-derived reserve boundary, DCS reduces CO2 feed and H2 feed together to preserve the approved feed composition. The 3:1 stoichiometric anchor is not used as an automatic override unless the final process model validates it.
5. If the reactor feed mixture exits its approved composition envelope, the system inhibits further feed increase and executes a controlled feed isolation/standby action as defined by HAZOP.
6. Recycle compressor, reactor temperature and pressure controllers remain within equipment/vendor limits; purge control prevents inert accumulation only to the extent that U-501 is available.
7. When renewable power recovers, ELY ramps up under OEM restrictions. Synthesis throughput increases only after H2 purity, pressure, flow and ratio permissives are stable for the approved qualification period.
8. If the plant cannot remain within the validated stable window, transition to controlled shutdown. Do not force operation at the draft 25 t/d minimum or 50% power case without dynamic validation.

---

## 6. Alarm management philosophy

Alarm design shall follow a documented alarm philosophy and rationalisation lifecycle consistent with IEC 62682:2022 / the current adopted equivalent and ISA-18.2. Each alarm must have a defined abnormal condition, consequence, priority, operator action, response time basis, deadband, on/off delay, shelving policy and rationalisation approval.

### 6.1 Priority definition

| Priority | Intended meaning | Response expectation | Typical examples |
|---|---|---|---|
| P1 - Critical | Immediate operator action needed to prevent or respond to a significant process-safety or major equipment event | Immediate, annunciated persistently; independent protective function may also act | Reactor high-high temperature, confirmed toxic/flammable gas alarm, ELY crossover trip, plant ESD demand |
| P2 - High | Prompt operator action needed to prevent escalation, loss of control or equipment damage | Prompt response within rationalised response time | High separator level, low cooling flow, compressor vibration alarm, high off-gas backpressure |
| P3 - Advisory | Abnormal condition requiring planned operator attention or maintenance, without immediate response deadline | Acknowledge and investigate within operating/shift routine | Filter DP approaching changeout criterion, analyser maintenance due, utility trend deviation |

Priority is an alarm-response category, not a HAZID risk ranking or SIL allocation. The preliminary HAZID P1/P2 labels indicate action sequencing only.

### 6.2 Alarm rules

- Alarm only on conditions requiring operator action. Raw status, permissive state and sequence step are indications unless intervention is required.
- Use one primary alarm for a common initiating event; suppress consequential low-value alarms only through approved state-based suppression logic. Do not suppress independent safety alarms.
- Apply alarm deadband and on/off delay from process dynamics, instrument accuracy and operator response analysis. Do not assign identical delays to fast machinery trips and slow tank-level alarms.
- Use first-out / first-up trip indication and sequence-of-events timestamps to identify initiating causes.
- Alarm limits shall be below or above trip limits with adequate margin for response and uncertainty, proven by dynamic analysis. No numeric margins are assigned here.
- Use shelving only with role-based access, reason, owner, expiry and historian record. No permanent disabling of standing alarms.
- Bad instrument / analyser quality shall create a distinct diagnostic alarm and invalidate dependent permissives; do not generate multiple process alarms from the same failed transmitter.
- Configure out-of-service and maintenance modes explicitly. Acknowledgement does not clear the abnormal process condition.
- Monitor standing alarms, chattering, fleeting alarms, stale alarms, alarm floods, per-operator alarm rate, priority distribution and bypass/shelving duration.

---

## 7. Safety, ESD and interlock separation

### 7.1 Protective-system allocation

| Function type | Normal implementation | Safety credit status in this package |
|---|---|---|
| Process alarm | DCS / package HMI | Operator response only; no automatic risk-reduction credit assumed |
| BPCS interlock / equipment permissive | DCS or package PLC | Operational protection only unless formally assessed and allocated otherwise |
| Machinery protection | Dedicated OEM machinery monitor / package PLC | Equipment protection; not automatically an IEC 61511 SIF |
| Electrolyser package safety | Vendor safety PLC / OEM hardwired trips | OEM-defined safety function; interface and independence review required |
| Fire and gas | Dedicated FGS logic solver | Detection and emergency action; final independence and risk reduction to be assessed |
| Plant ESD / SIS | Independent safety PLC / SIS | Candidate SIFs only after HAZOP/LOPA; no SIL assigned |
| Mechanical relief / P-V protection | PSV, rupture disc, tank P/V valve, thermal relief | Independent mechanical protection; sizing and destination unresolved |

### 7.2 Candidate SIF / ESD functions

The interlock register identifies candidate functions for: plant manual ESD; H2/CO/CO2/O2/methanol gas escalation; fire; ELY H2/O2 crossover and separator abnormal differential pressure; ELY high pressure; reactor high-high bed temperature / rapid rise; reactor high-high pressure; loss of required heat removal; V-301 high-high level and low-low level; high-pressure buffer protection; TK-401 independent high-high level; and selected utility failure actions. Allocation to SIS, FGS, package safety PLC or BPCS remains subject to HAZOP/LOPA, OEM package safety manual, independence assessment and functional safety lifecycle.

No SIL target, proof-test interval, risk reduction factor, PFDavg, diagnostic coverage or voting architecture is assigned. A formal SRS, SIL determination/verification, validation plan, bypass procedure, proof-test procedure, modification management and functional safety assessment are required before any SIF is implemented or credited. The IEC 61511-2026 series catalogue exists as a 2026 series package; the detailed applicable part and adopted national edition must be confirmed by the project standards register before design freeze.

### 7.3 Safe-state intent

- Stop generation and admission of additional H2/CO2 when feed composition, reactor temperature/pressure or gas detection demands it.
- Isolate H2 and O2 independently; retain separate pressure relief and safe disposal routes.
- Trip or unload compressors on vendor-defined limits; prevent reverse flow with check/isolation arrangements.
- Maintain validated reactor cooling / heat removal and essential detection/ventilation after feed isolation.
- Stop methanol product transfer and isolate the affected section on fire, vapour release, tank high-high level or transfer leak.
- Isolate E-402 hot utility on column high pressure, condenser failure or reboiler protection demand.
- Never close a relief device or block a required relief path to protect a routine process vent header. If U-501 is unavailable, stop/limit routine purge and flash-gas generation using a safe shutdown; pressure relief remains independently routed.
- Depressurisation is only to a designed and studied system with verified material minimum temperature, dispersion, backpressure and simultaneous-release cases. No atmospheric blowdown sequence is specified.

---

## 8. HMI / SCADA design requirements

The HMI shall be an operator work tool, not a decorative PFD mimic. Use a consistent high-performance graphic hierarchy: muted process backgrounds, standard equipment symbols, clear line direction, visible equipment state, limited colour reserved for abnormal conditions and alarm state, and no animation that distracts from decision-making.

### 8.1 Mandatory display set

1. **Plant overview:** status of five process trains, throughput, reactor pressure/temperature, H2 availability, CO2/H2 feed ratio, recycle/purge status, off-gas availability, utilities, product tank and active ESD/SIF summary.
2. **CO2 train:** source feed, V-101 level, F-101 DP, P-101 package state, CO2 quality, K-101 suction/discharge and condensate routing.
3. **Electrolyser and H2/O2 train:** ELY stack power/current, DI water quality/flow, stack temperature, H2/O2 separator pressures and differential pressure, crossover/purity, H2 buffer pressure, compressor state and O2 disposition.
4. **Synthesis loop:** feed ratio and quality, reactor axial temperature profile, pressure, DP, HX-301 heat recovery/bypass, E-302 outlet/cooling, V-301 level, recycle compressor anti-surge, purge flow/composition and U-501 status.
5. **Distillation / product:** column pressure and temperature profile, reflux and reboiler, V-401 level, product analyser status/quality, P-401 transfer state, TK-401 level/PV status and loading permissives.
6. **Off-gas / wastewater / waste:** U-501 flows/composition/backpressure/treatment availability, W-501 level/pH/conductivity/effluent quality, drain segregation status and waste-container status.
7. **Utilities / energy / water:** power by use category, renewable availability, cooling supply/return, instrument air, nitrogen, steam/hot-fluid, water intake and wastewater discharge.
8. **Alarm summary:** active/unacknowledged/standing/shelved alarms by priority and unit, first-out trip, alarm flood banner, operator action text and time-in-state.
9. **Interlock / SIF status:** active and bypassed interlocks, first-out cause, trip latch, reset permissives, proof-test due status, bypass owner and expiry. SIS read-only except authorised reset workflow.
10. **Trends / event review:** configured process trend groups, sequence-of-events, historian queries and operator annotations.

### 8.2 Faceplates and command design

Each equipment faceplate shall display tag, service, mode, PV, SP, output, units, range, alarm limits, device quality, local/remote status, package ready/running/tripped state, interlock/permissive status, bypass indication and recent alarms. Commands shall include explicit confirmation for start, stop, reset, isolation, mode change and setpoint change where appropriate. Show the reason when a command is rejected. Manual mode shall not bypass SIS or OEM safety protection. Critical setpoint and bypass changes require role-based permission, entry of a reason and historian audit trail.

### 8.3 Operator guidance

Alarm help shall state: what is abnormal, likely cause, immediate consequence, first action, whether automatic protection has operated, what must not be done, and restart condition. For gas detection, fire, ELY crossover, reactor high-high temperature/pressure and tank overfill, instructions shall prioritise evacuation/incident response and remote isolation; no unprotected entry or local intervention is implied.

---

## 9. Historian, KPI and data-management requirements

Historian tags shall include value, quality, timestamp, engineering units, source system, scan/event class and configuration version. Time synchronisation shall be coordinated across DCS, package PLCs, SIS, FGS, machinery protection, historian and electrical meters. Sequence-of-events resolution shall be specified for protective functions by the functional safety and event analysis requirements.

### 9.1 Dashboard KPI set

| KPI | Calculation / data source | Constraint |
|---|---|---|
| Methanol production rate | Product S-314 mass flow / inventory reconciliation | Use calibrated meter and tank inventory reconciliation |
| CO2 consumption and utilisation | S-008 fresh CO2 flow; product carbon balance; purge/off-gas CO2 | Do not infer capture utilisation from feed rate alone |
| H2 consumption | S-107 H2 mass flow and product stoichiometric balance | Include buffer inventory change when reconciling |
| Fresh-feed H2:CO2 ratio | Validated H2 and CO2 flowmeters | Stoichiometric anchor is not a quality KPI without composition and recycle correction |
| Loop recycle / purge ratio | S-209 recycle and S-207 purge flow | Purge target comes from loop inert balance |
| Product quality compliance | Online analyser plus lab release records | IMPCA reference remains academic until buyer spec is approved |
| Electricity SEC | kWh electricity / t methanol, separated by electrolyser and non-electrolyser loads | No plant SEC target until solved balance and power data exist |
| Renewable electricity share | Metered eligible electricity and contractual/dispatch evidence | Accounting rules and time period must be documented |
| Water intensity | Raw water intake / t methanol; DI water to ELY tracked separately | Recycle S-309 credited only after verified water quality and mass balance |
| Cooling intensity | Cooling-water circulation, makeup and blowdown separately | Circulation is not net water consumption |
| Off-gas loss | Flow and composition to U-501 and S-311 | Emissions and recovery depend on selected treatment system |
| Waste intensity | S-315/S-316/S-317 mass per tonne methanol | Quantities and classification remain open |
| Equipment reliability | Package availability, trip count, MTBF/MTTR and bypass duration | Distinguish planned maintenance from process trips |

---

## 10. Testing, commissioning and lifecycle requirements

1. Complete instrument index, I/O list, instrument datasheets, loop diagrams, cable schedule, hook-up drawings, control valve datasheets and electrical load list.
2. Obtain vendor package P&IDs, cause/effect, sequence narratives, compressor maps, anti-surge data, trip limits, stack load map, gas crossover limits, water-quality limits and safety manuals.
3. Complete HAZOP and LOPA; allocate SIFs; prepare SRS; establish SIL targets only where assessed; verify and validate the complete safety lifecycle before start-up.
4. Complete relief and disposal studies independently of BPCS control; establish PSV, rupture-disc, thermal relief, emergency depressurisation and vent-stack/flare/oxidiser decisions.
5. Perform control-loop review and dynamic simulation for feed ratio, power shortfall, H2 buffer, reactor thermal response, loss of cooling, compressor trip, purge malfunction, separator level and distillation condenser failure.
6. Perform FAT for DCS, package PLCs, SIS, FGS, historian and network interfaces. Include bad-quality signals, instrument failure, communication loss, power loss, controller failover, time sync, alarm suppression and first-out logic.
7. Perform SAT and loop checks; verify polarity, range, fail action, valve stroke, feedback, travel time, partial-stroke or proof-test requirements, trip latching, reset permissives and inter-system signals.
8. Validate alarm setpoints and response guidance against operator response-time analysis; conduct alarm rationalisation workshop and simulated alarm-flood testing.
9. Execute cause-and-effect validation and integrated ESD/FGS/ELY tests with vendor participation. Do not bypass live safeguards without approved test plans and compensating measures.
10. Complete cybersecurity zoning/conduits, account management, backups, restore tests, patch and remote-access procedures, time synchronisation and change-control processes.
11. Complete PSSR before introducing H2, CO2, CO-containing synthesis gas, methanol or oxygen. Verify operating procedures, training, emergency response and proof-test records.
12. Establish MOC for process limits, alarm setpoints, controller tuning, control logic, analyser substitution, package firmware, network changes and SIF modifications.

---

## 11. Open design actions and hold points

| ID | Required closure | Why it blocks final control design | Responsible discipline |
|---|---|---|---|
| A-01 | Approve Route C and freeze G3 design basis | Process scope and control boundaries are provisional | Project / Process |
| A-02 | Solve full 55-stream mass, composition, pressure and temperature balance | Required for meter ranges, ratio SP, valve sizing, alarms and throughput limits | Process |
| A-03 | Obtain biogenic CO2 source assay and variability | Contaminant analyser, guard breakthrough and feed permissives | Process / Supplier |
| A-04 | Select P-101 technology and obtain vendor package P&ID / guarantees | Package control, reject handling and alarm limits | Process / OEM |
| A-05 | Obtain compressor types, maps and OEM protection data for K-101/K-201/K-301 | Anti-surge / unload philosophy and trip settings | Rotating Equipment / OEM |
| A-06 | Obtain ELY OEM safety manual, load map, crossover, DP, water, temperature and pressure limits | ELY package logic and safety interlocks | Electrolyser OEM |
| A-07 | Select H2 buffer type, inventory and pressure boundary | H2 storage control, pressure protection and PESO applicability | Mechanical / Process Safety |
| A-08 | Validate catalyst formulation, feed impurity limits and reactor kinetics | H2/CO2 ratio and gas-quality envelope | Reactor Specialist / Catalyst OEM |
| A-09 | Design reactor heat removal and obtain thermal dynamic model | Reactor temperature control and independent trip basis | Process / Mechanical / Reactor Specialist |
| A-10 | Complete relief and disposal philosophy, including U-501 and dedicated H2/O2 vents | Fail positions, backpressure trip response and safe state | Process Safety / Mechanical |
| A-11 | Select HX-301 bypass/thermal-control arrangement | Determines TIC-301 final element and failure response | Heat Exchanger / Process |
| A-12 | Validate E-302 cooling duty, utility source and coast-down response | Cooling-flow alarms and reactor feed cutback | Utilities / Process |
| A-13 | Complete V-301/V-302 vessel sizing and phase model | Level bands, carryover/gas blow-by trips and pressure ranges | Process / Mechanical |
| A-14 | Solve purge and inert balance, PCV-301 Cv and U-501 capacity | Purge controller SP and high/low alarms | Process / Environmental |
| A-15 | Select distillation pressure, stages, reflux, reboiler and condenser | Column loop tuning and alarm/trip basis | Process / Column Specialist |
| A-16 | Define product specification and off-spec hold/diversion route | Product analyser permissive and dispatch interlocks | Quality / Process / Operations |
| A-17 | Select tank type, blanketing, vents, overfill prevention and loading system | TK-401 loops, P/V control and independent protection | Tank Specialist / Mechanical |
| A-18 | Obtain raw/DI water analysis and electrolyser water spec | Conductivity/resistivity limit and water permissive | Water Treatment / OEM |
| A-19 | Select W-501 treatment, drain classes, effluent limits and hold capacity | Level, pH, discharge and incompatibility interlocks | Environmental / Process |
| A-20 | Define cooling, steam, instrument-air, N2 and electrical utility data | Alarm ranges, utility failure and shutdown sequencing | Utilities / Electrical |
| A-21 | Complete plot plan, hazardous-area classification and gas detector coverage | Detector type, location, alarm action and voting | Process Safety / Electrical / HVAC |
| A-22 | Complete HAZOP / LOPA and allocate SIFs | SIS scope, SIL target and voting remain unassigned | Process Safety / SIS Engineer |
| A-23 | Complete SIS architecture, SRS, verification and validation | Required before any safety function is credited | Functional Safety Engineer |
| A-24 | Establish OT cybersecurity zoning and interface protocol | Secure DCS/PLC/SCADA integration | OT Cybersecurity / Controls |
| A-25 | Approve control valve fail states and actuator energy source | Failure response depends on relief, vent, cooling and package design | Process / Instrumentation / Process Safety |
| A-26 | Define alarm response-time basis and rationalise each alarm | No defensible delay/deadband/priority closure yet | Operations / Controls |
| A-27 | Produce complete instrument index, I/O list, P&IDs and loop diagrams | Enables procurement and implementation | Instrumentation / EPC |
| A-28 | Dynamic testing of 50% renewable-power shortfall for 2 h and recovery | H2 buffer, ratio, reactor and column coordination unproven | Process / Controls / OEM |
| A-29 | Confirm Indian regulatory / BIS adoption and statutory authority requirements for site | Legal applicability depends on final site and plant classification | Project / EHS / Legal |
| A-30 | Define proof-test intervals, bypass procedure and maintenance criticality | Lifecycle and functional safety obligations | SIS / Maintenance / Operations |

---

## 12. Handoff to Prompt 15 and P&ID development

**Prompt 15 handoff:** use the mode table, throughput/power-shortfall narrative, startup permissive groups, protective-system allocation and the interlock cause-and-effect workbook as the control constraints for the next design stage. Carry each open action as a tracked design dependency; do not replace TBD values with generic textbook setpoints.

**P&ID development record:** add proposed instrument tags and valves to P&IDs only after confirming stream states and equipment boundaries. For each tag, link the loop register row, alarm register row (where applicable), interlock ID (where applicable), datasheet, I/O type, control-system owner, fail position, bypass policy and proof-test requirement. Add independent sensors and final elements where SIF/ESD allocation requires them. Show package PLC interfaces, ESD hardwiring, FGS links, relief devices, drains, vents, sample systems, utility failure logic and isolation philosophy. Revise the PFD-to-register cross-check whenever tags or stream IDs change.

**Implementation boundary:** the diagrams, narratives and matrices in this package are engineering design deliverables only. They are not a validated PLC application, executable DCS/SIS logic, approved operating procedure or SIL certification.

---

## 13. Reference standards and engineering references

Apply the current contractually adopted editions and Indian statutory/BIS requirements after site and jurisdiction are confirmed. The standards below are candidates for the design basis, not a statement of compliance or certification:

- IEC 61511 series - Functional safety, safety instrumented systems for the process industry sector. Confirm the applicable part / adopted edition in the project standards register; IEC catalogue identifies a 2026 series package.
- IEC 62682:2022 / ISA-18.2 - Alarm-system lifecycle management for process industries.
- ISA-101.01-2015 and ISA-TR101.01-2022 - HMI design and HMI philosophy.
- ISA/IEC 62443 series, including ANSI/ISA-62443-2-1:2024 and current applicable technical reports - IACS cybersecurity.
- IEC 60079 series / applicable Indian hazardous-area electrical standards, after area classification.
- ISO 22734-1:2025 - Safety requirements for water-electrolysis hydrogen generators; verify package scope and Indian adoption/interface requirements.
- Applicable OEM machinery-protection, compressor, electrolyser, tank and instrument standards; applicable Indian PESO / pressure-vessel / electrical / environmental requirements as confirmed by site-specific legal register.

**External standard catalogue references:** IEC 61511 series catalogue (https://webstore.iec.ch/en/publication/5527); IEC 62682:2022 (https://webstore.iec.ch/en/publication/65543); ISA-101 series (https://www.isa.org/standards-and-publications/isa-standards/isa-101-standards); ISA/IEC 62443 series (https://www.isa.org/standards-and-publications/isa-standards/isa-iec-62443-series); ISO 22734-1:2025 (https://www.iso.org/standard/82766.html).
