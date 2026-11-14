# ENERGY-008 P&ID-Level Definition and Operating Sequence Basis

**Document:** ENERGY008-PIDSEQ-001  
**Revision:** 0.1-DRAFT  
**Date:** 1 November 2026  
**Working route:** Route C - biogenic CO2 + renewable electrolytic H2, pressurised alkaline electrolysis (ALK reference)  
**PFD basis:** ENERGY008-PFD-001 Rev 0.1-DRAFT  
**Control basis:** ENERGY008-CTRL-001 Rev 0.1-DRAFT  
**Status:** Conceptual engineering design input. Not approved for construction, commissioning, operation, maintenance, statutory submission or emergency response.

> **Safety and status limitation.** The source PFD and design basis remain provisional, and the design gate is not frozen. The sketch is P&ID-level only: it is not a complete P&ID, line list, valve list, instrument index, relief register, isolation register, executable PLC/DCS logic or approved operating procedure. All sequence statements below are design requirements for later HAZOP/LOPA, OEM and operations review. No hazardous depressurisation, purging, venting, catalyst activation, electrolyte service or maintenance steps are prescribed.

---

## 1. Governing configuration and design basis

The working plant arrangement is the Route C configuration in the ENERGY008 process description:

1. **CO2 receipt and conditioning:** V-101 knockout, F-101 coalescing/guard train, P-101 recovery/purification and K-101 compression.
2. **Water and hydrogen:** W-201 pretreatment/DI polishing, ELY-201 pressurised alkaline electrolysis, D-201 H2 drying/purification, K-201 H2 compression/buffer and O-201 oxygen handling.
3. **Synthesis loop:** M-301 fresh/recycle mixer, HX-301 candidate feed/effluent recuperator, R-301 packed-bed reactor, E-302 trim cooler/condenser, V-301 separator, SP-301 recycle/purge split, K-301 recycle compressor and PCV-301 purge valve.
4. **Purification and product:** V-302 crude-liquid letdown/degassing, T-401 methanol/water column, E-401 overhead condenser, V-401 reflux drum, E-402 reboiler, P-401 product pump and TK-401 storage.
5. **Offsites:** U-501 off-gas management, W-501 wastewater collection/treatment, SW-501 segregated solids/hazardous waste and DR-501 segregated drains.

The PFD identifies 28 equipment/package tags, 55 material streams and 10 utility interfaces. No stream flow, composition, temperature, pressure or enthalpy table has been solved. Vendor package data, compressor maps, electrolyser maps, catalyst start-up instructions, distillation design, relief sizing and vent/disposal destination are not yet available.

### Screening values that must not be coded as controller limits

| Reference | Value | Use in this package |
|---|---:|---|
| Normal methanol capacity | 50 t/day | Illustrative screening case only |
| Minimum stable / normal / max continuous / process design rates | 25 / 50 / 55 / 60.5 t/day | Screening points; not approved operating limits |
| Synthesis reference | 7 MPa(a), 250 degC | Thermodynamic/model screening point only; not equipment design pressure/temperature or trip setpoint |
| Broad synthesis literature envelope | 5-10 MPa(a), 200-300 degC | Context only; not a guaranteed process envelope |
| ALK H2 interface | 20 bar(a) | Draft interface assumption only |
| Fresh-feed H2:CO2 | 3:1 molar | Stoichiometric anchor only; actual reactor feed envelope must include recycle composition and validated model limits |
| Renewable power disturbance | 50% of nominal available power for 2 h | Assumed disturbance DB-059, not measured operating history |

No numeric timer, ramp rate, stable-time requirement, valve fail position or permissive threshold is assigned unless supported by an approved design/vendor basis. Symbolic timer names in this document are placeholders for Prompt 16 and must be parameterised after process dynamics and operator response-time studies.

---

## 2. P&ID sketch conventions and engineering requirements

The accompanying five-sheet PDF and editable source show representative P&ID functions for critical equipment. Use the following conventions when converting the sketch into controlled P&IDs:

- **XV / MOV:** isolation or shutdown valve. Final-element fail action, actuator type, fire-safe requirement and position feedback are TBD by service and HAZOP/LOPA.
- **FCV / PCV / LCV:** modulating flow, pressure or level valve. A control valve is not an ESD valve unless separately specified and qualified.
- **NRV:** non-return/check valve, especially compressor and gas-product discharge protection. Selection and orientation require hydraulic/transient review.
- **DV / BDV / VENT:** closed drain, blowdown or vent connection. The sketch labels service-specific engineered destination placeholders. It does not authorise discharge to atmosphere or a common header.
- **PSV / PVRV:** mechanical pressure/vacuum protection requirement, shown symbolically only. No set pressure, capacity, orifice, backpressure or disposal destination is designed in this package. Relief path must not be isolated by a routine control action.
- **SP:** closed sample-point requirement with pressure reduction, safe sample return/collection and purge provision to be designed. No open sampling is implied.
- **Control-valve bypass:** where shown as a candidate maintenance feature, the bypass is normally locked/car-sealed closed under the approved line-up. It must not become an uncontrolled parallel flow path. Bypass installation itself requires process safety review.
- **DBB / maintenance boundary:** dashed equipment boundary indicates a design review zone only. Final isolation may require double block and bleed, positive isolation/spade, drain/vent, gas-free test and LOTO as determined by service, code and permit-to-work procedure.
- **Instrument bubbles:** tags are aligned to Prompt 14 where available. New local valve/relief/drain/sample identifiers on the sketch are proposed only and must be reconciled in the instrument index and valve list.
- **Utility tie-ins:** U-001 electrical, U-002/U-003 cooling water, U-004/U-010 hot utility/return, U-005 instrument air and U-006 nitrogen are shown as interfaces, not sized utilities.

### Dedicated vent and relief segregation

Hydrogen, oxygen, CO-containing synthesis gas, CO2-rich reject, methanol-bearing flash gas and routine off-gas have different compatibility, dispersion, ignition and toxic/asphyxiant constraints. The sketch uses separate destination arrows and explicit “destination TBD” notes. Do not combine these streams in a common vent, relief or drain header until composition, simultaneous release, backpressure, dispersion, flashback/ignition, low-temperature and materials reviews demonstrate compatibility. U-501 is an off-gas collection/treatment interface, not an assumed flare, oxidiser or atmospheric vent.

### Minimum instrument and valve schedule additions before detailed P&IDs

The P&ID engineer should add or verify: upstream/downstream isolation valves; bypass/bleed details; drains at true low points; vents at true high points; PSV/PVRV and thermal-relief needs; NRVs; closed sampling systems; double isolation/positive isolation boundaries; package battery limits; utility isolation and check valves; line class/spec breaks; hazardous-area cable/instrument segregation; cause/effect references; instrument air and UPS supplies; local indicators; valve position feedback; spectacle blinds/spades; and tie-in/test points. Every added item requires tag, line number, service, size/rating/material, fail action and owner.

---

## 3. Operating modes and mode arbitration

The workbook `ENERGY008_Operating_Mode_Matrix.xlsx` defines the operating modes, entry permissives, allowed authority, transitions, aborts, prompts and reset rules. The priority hierarchy is:

1. **Independent protective action** (SIS candidate, FGS, electrical protection, machinery protection and OEM package trips) overrides all ordinary modes.
2. **ESD latch / protective hold** prevents sequencer progression and automatic restart.
3. **Package PLC** retains equipment-local control and OEM protection if the DCS/network is unavailable, subject to package design.
4. **DCS/BPCS** provides regulatory control and supervisory sequencing.
5. **Operator manual command** is permitted only within defined limits and does not defeat protective actions.

`OFF`, `MAINTENANCE`, `MANUAL`, `AUTOMATIC`, `START-UP`, `NORMAL`, `TURNDOWN`, `CLEANING/REGENERATION`, `CONTROLLED SHUTDOWN`, `EMERGENCY SHUTDOWN`, `RESTART HOLD`, `PRODUCT QUALITY HOLD` and `TRIP INVESTIGATION` are distinct states or authorities. They are not interchangeable. A reset only clears a latched function after authorised checks; it never starts equipment.

---

## 4. Start-up sequence - conceptual state/step narrative

This sequence is a design skeleton. It intentionally stops at the boundary of missing OEM and process-safety procedures. No gas introduction, leak-test pressure, inerting endpoint, heat-up rate, pressurisation rate, catalyst activation method, depressurisation route or timer value is specified here.

### S00 - OFF / request received

**Operator request:** select the intended unit train and request `PRE-START`. The DCS records operator, time, active bypasses, trip latches, equipment mode and first-out history.

**Prerequisites:** no ESD latch; no unresolved package trip; maintenance/permit status known; equipment inventory and isolation status known; no unapproved bypass; sequence revision current.

**Abort / hold:** active ESD, unknown isolation, unsafe atmosphere, unverified inventory or failed critical signal. Proceed only to S10 when the request and unit scope are valid.

### S10 - PRE-START verification

Verify mechanical completion, pressure-boundary documentation, line-up, valve feedback, drains/vents, package documentation, catalyst/electrolyte status, instrument calibration, sample-system readiness, and status of relief/vent routes. Check the P&ID, line list, valve list, I/O list, C&E and alarm database revisions agree.

**Operator prompt:** confirm permits closed, blinds/spades reconciled, maintenance handback complete, equipment tags match the intended sequence, and personnel accounted for.

**Transition:** all unit-specific pre-start checklist items complete and signed; then S20.

**Abort:** any missing relief route, incompatible drain/vent connection, instrument bypass, gas detector fault without an approved compensating measure, or incomplete vendor procedure. Hold in S10.

### S20 - Utilities and protection ready

Confirm electrical supply and distribution (U-001/U-009), instrument air (U-005), cooling (U-002/U-003), nitrogen/inert gas (U-006), DI water package availability, control power/UPS, ESD/FGS availability, package PLC health, historian/time synchronisation and communications. Confirm U-501 off-gas route and W-501 wastewater capacity/status for the intended start-up envelope.

**Permissives:** utility pressure/flow/quality within approved site/package ranges; ESD/FGS ready; cooling users ready; off-gas destination authorised; wastewater/drain destinations available; all key PV quality bits healthy.

**Operator prompt:** acknowledge any utility limitation and select only a validated constrained-start path if one exists.

**Transition:** permissives stable for `T_UTIL_STABLE` (TBD after dynamics/operator response study); then S30.

**Abort:** loss of essential power, cooling, instrument air, nitrogen needed for the sequence, detector/ESD fault, or unavailable off-gas/waste route. Return to S10 or controlled shutdown as applicable.

### S30 - Isolation, inerting and integrity verification hold point

This state represents the approved isolation and inerting/leak-test work package. Nitrogen is not substituted with compressed air. The package must confirm separate hydrogen and oxygen systems, no cross-connected vent/drain, and approved discharge destinations. The actual purge volumes, endpoint, leak-test medium/pressure, test hold time and test boundary are not defined in this document.

**Permissives:** approved vendor/site procedure available; N2 source and flow measurement valid; dedicated gas routes available; O2 analyser valid at each required sample point; pressure boundary and test boundary approved; no open maintenance scope.

**Transition:** only after authorised test certificate and analyser acceptance are recorded; then S40.

**Abort:** oxygen criterion not met, analyser bad quality, leakage, pressure decay outside approved test criterion, common vent/drain discovered, or N2 unavailable. Keep reactant admission inhibited.

### S40 - Package readiness and feed conditioning

**CO2 train:** place V-101, F-101, P-101 and K-101 in the vendor-defined ready state. Confirm source assay, contaminant acceptance, moisture/dew-point target, filter/guard DP, purification package performance and compression package permissives. CO2 is not admitted to synthesis if AIT-101 or its quality input is invalid.

**Water/electrolyser train:** W-201 must deliver DI water within the electrolyser OEM specification. Verify AIC-201, flow FIC-201, electrolyte state, cooling, stack separator differential pressure, H2/O2 crossover measurement, dedicated product/vent routes and emergency trip interface. Do not infer water quality from a manual reading where the OEM requires a continuous permissive.

**H2 conditioning:** D-201 drying/purification quality and K-201 compressor/buffer conditions must be available; the vendor defines start permissives, minimum flow and pressure limits.

**Transition:** all intended packages report `READY`; then S50. Package-ready is not permission to introduce reactant to R-301.

### S50 - Reactor/catalyst conditioning hold point

R-301 catalyst loading, passivation, reduction/activation, preheat, cool-down and maintenance handling are specialist/vendor-controlled. No chemical activation gas, ramp rate, hold temperature or sequence is specified here. The reactor instrumentation architecture should provide multiple axial bed-temperature readings TIT-301A/B/C, pressure PT/PIC, differential pressure DPIT-301 and verified independent protective channels where allocated.

**Permissives:** catalyst certificate and vendor procedure approved; correct catalyst batch and loading record; R-301 mechanical completion; heat-removal/thermal-control path proven; trip and pressure-protection functions tested; H2/CO2 feeds inhibited until released.

**Transition:** vendor/owner authorises catalyst condition and bed state; then S60.

**Abort:** abnormal bed temperature/rate of rise, loss of cooling, high pressure, invalid critical thermocouple, abnormal DP or loss of utilities. Execute the approved package/reaction safety response; do not improvise a cooldown or vent route.

### S60 - H2 generation / CO2 conditioning available

ELY-201 is loaded only within the vendor power/current map. H2 purity/crossover and pressure are monitored. O2 remains on a separate approved handling route. K-201 compression and buffer operation follow the OEM map. CO2 is separately conditioned and compressed by P-101/K-101.

**Permissives:** H2 and CO2 composition valid; moisture/contaminant acceptance valid; no H2/O2 crossover; pressure boundaries and compressor maps valid; U-501 available for normal purge/degassing services planned for the start.

**Transition:** conditioned streams available with valid measurements; then S70.

**Abort:** ELY trip, crossover, package pressure/dP trip, water-quality failure, CO2 impurity excursion or compressor trip. Inhibit reactor feed and transition to HOLD/controlled shutdown.

### S70 - Recycle loop and pressure state established

Confirm V-301 / SP-301 / K-301 / PCV-301 path line-up, recycle gas quality, anti-surge system readiness and U-501 capacity. K-301 is started and loaded only by its OEM sequence. The pressure build-up medium, sequence and limits are not defined in this package; use only the process/vendor-approved inert/recycle procedure. Purge PCV-301 remains within the loop-model and off-gas capacity limits.

**Permissives:** recycle compressor ready; anti-surge controller healthy and vendor map loaded; V-301 level protection healthy; pressure instruments valid; U-501 backpressure/composition/capacity valid; relief paths available.

**Transition:** stable recycle and pressure conditions within approved envelope for `T_RECYCLE_STABLE` (TBD); then S80.

**Abort:** recycle compressor trip/surge, V-301 high-high/low-low level, high U-501 backpressure, purge analyser invalid or unsafe oxygen content. Reactant admission remains inhibited.

### S80 - Controlled reactant admission

Introduce conditioned H2 and CO2 only after the ratio/permissive logic is proven healthy. The DCS ratio controller uses FT-301/FT-302 with the validated ratio basis; AIT-301/AIT-302 confirm composition and analyser validity. Recycle composition is included in the final reactor-envelope calculation. Fresh 3:1 stoichiometry is not the complete loop composition limit.

**Control intent:** rate increases are coordinated, H2/CO2 are matched, compressor/feed limits are respected, and R-301 bed temperature and pressure are supervised. If ratio or gas quality becomes invalid, feed increases are blocked and the validated reduction/isolation action applies.

**Transition:** reactor conditions and gas composition remain within the approved envelope; then S90.

**Abort:** ratio outside approved range, AIT bad quality, temperature excursion/rate-of-rise, pressure excursion, loss of cooling or machine trip. The CE-015/016/017/018 protective responses apply according to approved allocation.

### S90 - Condensation, separation and crude transfer available

E-302 cooling and V-301 level/pressure controls are placed in approved automatic modes. V-301 LSHH-301 and LSLL-301 protective functions are independent of normal LIC-301 where allocated. Crude-liquid transfer via LCV-301 to V-302 is permitted only when downstream V-302/T-401 capacity and off-gas handling are ready. No phase split or liquid rate is assumed.

**Transition:** stable separator level, no compressor liquid carryover, acceptable crude stream and downstream readiness; then S100.

**Abort:** V-301 HH/LL, cooling loss, compressor trip, V-302 pressure rise or off-gas route unavailable. Cut back/stop feed as defined; do not bypass level protection.

### S100 - Distillation and product quality stabilisation

T-401 start-up, E-401 condenser operation, V-401 reflux inventory, E-402 hot-utility admission and column feed are sequenced from the eventual column vendor/process design. Steam/hot utility U-004 is controlled by FIC-403/TIC-402; high-high pressure/condenser failure and reboiler low-low/high-high protection are separate candidate protective functions. Column pressure, reflux ratio, key temperatures, drum level and bottoms level are monitored.

Product is not transferred to released storage/dispatch solely because temperature is stable. AIT-401 / lab test, batch identity, tank compatibility and quality authority release are required. No off-spec diversion path is assumed.

**Transition:** agreed product specification met and quality-authorised release; then S110.

**Abort:** condenser failure, column pressure/temperature protection, reboiler level/temperature protection, cooling loss, bad analyser, contaminated tank line-up or no segregated hold inventory. Enter PRODUCT QUALITY HOLD or controlled shutdown.

### S110 - NORMAL / TURNDOWN

Normal operation uses automatic regulatory controls and supervisory coordination. Turndown is permitted only after vendor maps and minimum stable operating points are available. Rate reduction must preserve the validated H2:CO2 feed envelope, reactor thermal control, recycle compressor margin, separator inventories, distillation stability and off-gas treatment capacity.

**Transition:** supply constraint, power disturbance, feed loss or other constraint triggers S110A TURNDOWN; sustained limitation triggers S120 controlled shutdown. Any ESD demand transitions immediately to S900.

---

## 5. Controlled shutdown narrative

This is a sequence design outline, not a shutdown operating instruction.

1. **Request / reason:** operator requests normal shutdown or the supervisor identifies a sustained constraint that cannot be maintained within the approved turndown envelope.
2. **Quality / dispatch coordination:** stop new product dispatch where required; place product in its identified batch/tank status. Do not send unverified or off-spec product to released storage.
3. **Reduce production demand:** DCS supervisor requests a coordinated reduction of fresh H2 and CO2, maintains the validated ratio during reduction, and confirms compressor/anti-surge, reactor thermal and separator stability.
4. **Stop reactant addition:** close designated feed isolation elements only according to the approved sequence and valve/line-up study. Compressor shutdown order and residual gas routing are package and process-safety decisions.
5. **Maintain required circulation / heat removal:** retain cooling, recycle or other services only where validated by reactor/vendor transient analysis. Do not assume a universal “keep recycle on” or “stop all utilities” rule.
6. **Distillation heat isolation:** isolate E-402 hot utility and stop/cut back column feed in the approved order; maintain condenser/reflux only as required by column shutdown design.
7. **Package shutdown:** ELY-201, K-101, K-201, K-301, pumps and process packages follow OEM shutdown sequences. Confirm gas-production stop, compressor coast-down, check-valve response and isolation feedback.
8. **Residual inventory:** any depressurisation, venting, purge, drain or displacement is performed only by a separate engineered shutdown procedure with approved pressure/temperature envelope, relief capacity, vent-system capacity and dispersion basis. This document does not provide those instructions.
9. **Shutdown verification:** confirm no energy addition, stable pressure/temperature/levels, safe waste/condensate handling and status of ESD/FGS/essential utilities. Record actual inventory; do not label equipment “gas-free” without a permitted gas test.

**Exit state:** `SHUTDOWN VERIFIED` only after the unit-specific checklist is signed. Maintenance then requires a separate isolation certificate and LOTO.

---

## 6. Emergency shutdown narrative

The plant-wide and zonal response is defined by Prompt 14 C&E IDs CE-001 through CE-037. The final ESD architecture, voting, output energisation, fail positions and zoning remain unallocated pending HAZOP/LOPA and SIS/FGS design.

On a qualified demand, the conceptual safe-state intent is to stop energy and material addition, isolate affected process sources, trip affected compressors/pumps and ELY rectifier, isolate product transfer, remove hot utility from E-402, and retain essential detection, emergency ventilation, pressure protection, engineered vent paths and cooling functions where the emergency power and utility study requires them. The exact affected zone and retained functions must be determined by the approved C&E matrix and fire/gas mapping.

- ESD demand is latched; no automatic restart follows power, communications or detector recovery.
- The DCS displays first-out cause, affected equipment, commanded output, actual feedback and any discrepancy.
- Operator actions are evacuation/personnel accountability, emergency response and remote isolation only as authorised by the site emergency plan. No unprotected rescue or manual opening of a pressurised system is implied.
- Depressurisation, purge and cool-down are not generic ESD outputs. They require scenario-specific process safety analysis and engineered discharge capacity.
- Reset is an authorised administrative and technical action after cause investigation, equipment inspection, gas test where required, functional test and pre-startup safety review. Reset does not command start.

---

## 7. Disturbance response basis

The companion `ENERGY008_Disturbance_Response_Matrix.xlsx` covers 14 disturbances with detection, automatic response, operator action, time scale, process impact, recovery condition, validation status and Prompt 14 loop/C&E references.

### 7.1 Quantified disturbance: 50% renewable power for 2 h

DB-059 defines an assumed disturbance of **50% nominal available power for 2 h**. It is an analysis scenario, not a measured renewable dispatch event. At the illustrative 50 t/day methanol case, the stoichiometric requirement is:

\[
\dot m_{H_2,stoich}=\frac{50{,}000}{32.04}\times 3\times 2.016\div 24
=393.3\;\mathrm{kg\,h^{-1}}
\]

If (and only if) H2 production were assumed to reduce linearly with available power from 100% to 50% for the full two hours, the equivalent missing H2 would be:

\[
\Delta m_{H_2}=393.3\times(1-0.50)\times 2
=393.3\;\mathrm{kg}
\]

This is an algebraic stoichiometric screening quantity, not a buffer size, guaranteed deficit, capacity margin or two-hour ride-through claim. It excludes ALK voltage/current behaviour, Faradaic efficiency, balance-of-plant load, electrolyser minimum load, ramp limits, H2 purity/crossover response, compression, buffer pressure limits, purge, recycle, process losses and synthesis-loop dynamics.

**Control response concept:** EPM-001 / package power measurement detects the reduction; ELY-201 follows only its OEM-validated power map. The supervisory controller calculates available H2 versus validated synthesis demand, reduces H2 and CO2 feed demand in coordination, preserves the approved reactor feed envelope, and commands turndown. If minimum stable rates, buffer margin or heat removal cannot be maintained, the sequence transitions to controlled shutdown. The stack is not forced to operate below OEM limits. No manual ratio override is permitted.

**Validation status:** no dynamic model or OEM performance curve is available; only the conditional stoichiometric arithmetic and qualitative logic review are complete.

### 7.2 Other disturbances

The disturbance workbook also addresses CO2 feed loss/off-spec, electrolyser/H2 production loss, cooling loss, K-301 surge/trip, critical sensor/analyser failure, final-element failure, instrument-air loss, electrical power loss, network/communications loss, off-spec methanol, U-501 unavailable/high backpressure, DI-water quality/flow loss and H2/O2 crossover or gas detection escalation. Each case must be converted into a dynamic scenario or structured logic test in Prompt 16 and then validated during FAT/SAT and commissioning.

---

## 8. Interlock and loop traceability

The following associations preserve Prompt 14 tag names. Protective actions are candidate design functions, not proof of a complete or independent safeguard.

| Function / service | Prompt 14 instruments / loops | C&E reference | Expected state response |
|---|---|---|---|
| CO2 receipt / V-101 level | FIC-101, LIC-101, LSHH-101 | CE-018, CE-037 (source/feed permissive) | Hold source/feed or isolate on independent level demand; no liquid carryover |
| F-101 guard/filter | PDIT-101, AIT-101 | CE-018 | Alarm on DP/quality; no automatic bypass assumed |
| K-101 CO2 compression | PIC-101, MPS-101 | CE-012 | Package unload/trip and reverse-flow prevention per OEM |
| W-201 / DI water | FIC-201, AIC-201 | CE-010, CE-033 | Inhibit/controlled ramp-down of ELY on low flow or off-spec water |
| ELY-201 / D-201 / K-201 | AIT-202/203, XOV-202/203, PIC-201/202/203, ASC-201, OEM package protection interface | CE-008 to CE-013 | OEM stack trip/crossover and pressure protection; H2 supply reduced/isolated |
| M-301 feed ratio | FIC-301/302, RATIO-301, AIT-301/302 | CE-018 | Inhibit/cut back feed on invalid ratio or composition |
| R-301 bed / pressure / cooling | TIT-301A/B/C, DPIT-301, PIC-301, TIC-301/302 | CE-015 to CE-017 | Stop feed and retain only validated heat-removal/pressure-protection functions |
| E-302 / V-301 | FIC-304, TIC-302, LIC-301, LSHH-301, LSLL-301 | CE-019/020/032 | Control condensation and level; protect recycle machine from liquid and gas blow-by |
| K-301 / purge | ASC-301, MPS-301, FIC-305, AIT-303, PIC-302 | CE-014/021 | Fast anti-surge, feed cutback on trip, purge only within approved U-501 envelope |
| V-302 / T-401 / E-401 / E-402 / V-401 | PIC-303, LIC-302, PIC-401, TIC-401/402, RIC-401, LIC-401/402, FIC-403 | CE-022 to CE-024 | Closed flash-gas handling; cut hot utility/feed on column or reboiler protection |
| P-401 / TK-401 | AIT-401, LIC-411, LSHH-411, PIC-411, FIC-411, MPS-411 | CE-025 to CE-027, CE-035 | Stop transfer/dispatch on overfill, pump protection or product quality hold |
| U-501 / W-501 / utilities | FIC-501, AIT-501/502, PIC-501, LIC-501, AIC-501, FIC-502, AIT-503, EPM-001, PIC-601/602 | CE-028 to CE-037 | Contain and inhibit discharges; respond to utility / disposal failure without blocking relief |
| Plant-wide FGS / ESD | FGS-H2-01, FGS-CO-01, FGS-CO2-01, FGS-O2-01, FGS-MEOH-01, FGS-FIRE-01, FGS-001 | CE-001 to CE-007 | Zone-specific alarm, isolation/ESD and evacuation per approved F&G/ESD design |

### Redundancy and independence design actions

- R-301 bed temperatures require multiple spatial measurements; the final number, voting and independence must come from thermal/hazard review. The Prompt 14 A/B/C axial points are candidate channels, not a declared voting architecture.
- R-301 pressure protection requires an independent mechanical relief basis. A DCS PIC is not a substitute for a PSV or independent safety function.
- V-101 and V-301 high-high level candidates should be independent of the normal level controller when credited as a protective layer; confirm separate sensing, tapping, power, logic and final element.
- ELY H2/O2 crossover, separator differential pressure and product pressure protection require OEM-integrated independent measurements/logic as specified by package safety design.
- K-301 anti-surge is a fast OEM machinery function with corrected map variables and a dedicated final element; it must not depend only on a supervisory DCS loop.
- FGS devices need a site coverage/dispersion study, detector health diagnostics, emergency power and validated cause/effect. Do not assume sensor voting.
- ESD output power, I/O, network, UPS, final element de-energise philosophy and proof-test strategy require formal functional-safety engineering.

---

## 9. Prompt 16 handoff: state logic and calculation-workflow inputs

The accompanying state diagram (`ENERGY008_Automation_State_Diagram.png`) and this file provide a sequence/state interface for Prompt 16.

### State identifiers and transition guards

| State ID | State | Entry guard / required evidence | Normal transition | Abort / fault branch |
|---|---|---|---|---|
| ST-00 | OFF | No start request active; state recorded | ST-10 on authorised request | ST-90 if ESD demand |
| ST-10 | PRE-START REVIEW | Permits, equipment scope, maintenance handback and revision check | ST-20 when checklist signed | Hold ST-10 / ST-95 |
| ST-20 | UTILITIES & PROTECTION READY | U-001/002/003/004/005/006/009 as required; UPS, DCS, ESD, FGS, U-501 and W-501 ready | ST-30 after `T_UTIL_STABLE` (TBD) | ST-95 or ST-90 |
| ST-30 | ISOLATION / INERT / INTEGRITY HOLD | Approved N2, O2 analyser, leak-test package and dedicated destination available | ST-40 after certificate and analyser acceptance | Hold / ST-90 |
| ST-40 | PACKAGE READY | W-201, ELY-201, CO2 and H2 conditioning package states healthy | ST-50 when package ready signals true | ST-95 / ST-90 |
| ST-50 | CATALYST / REACTOR CONDITIONING | Vendor catalyst procedure complete; temperature, pressure, cooling and instrumentation accepted | ST-60 on authorised release | ST-90 on abnormal thermal/pressure condition |
| ST-60 | CONDITIONED H2 / CO2 AVAILABLE | Product purity, moisture, composition, pressure and package maps valid | ST-70 when both trains ready | ST-95 / ST-90 |
| ST-70 | RECYCLE / PRESSURE ESTABLISHED | K-301 ready, anti-surge healthy, U-501 ready, V-301 protections healthy | ST-80 after `T_RECYCLE_STABLE` (TBD) | ST-95 / ST-90 |
| ST-80 | REACTANT ADMISSION | Ratio, analysers, cooling, reactor temperature/pressure protections and feed isolation ready | ST-90 when reactor stable | ST-90 / ST-95 / ST-90 (ESD) |
| ST-90A | SEPARATION / CRUDE HANDLING | E-302 and V-301 stable; V-302 and T-401 available | ST-100 | ST-95 / ST-90 |
| ST-100 | DISTILLATION / QUALITY STABILISE | Condenser, reflux, reboiler and product lab/analyser ready | ST-110 after quality release | ST-120 product hold or ST-90 |
| ST-110 | NORMAL / TURNDOWN | All required control loops auto and no protective demand | ST-110A on constraint; ST-80 only on validated recovery sequence | ST-120 or ST-90 |
| ST-110A | TURNDOWN | Constraint identified; vendor minimum stable maps available | ST-110 when recovered | ST-120 if no stable feasible point |
| ST-120 | CONTROLLED SHUTDOWN | Shutdown request or sustained non-emergency constraint | ST-130 after inventory/energy state verification | ST-90 on emergency demand |
| ST-130 | SHUTDOWN VERIFIED | Unit checklist signed; no automatic restart | ST-10 on new start request | ST-95 for maintenance boundary checks |
| ST-90 | EMERGENCY SHUTDOWN LATCHED | Qualified ESD/FGS/package protective demand | ST-95 only after authorised reset and review | Remain latched on any active cause |
| ST-95 | TRIP INVESTIGATION / RESTART HOLD | First-out captured; cause removed; inspection/tests and permissives complete | ST-10 only after authorised reset | Remain held or return to ST-90 |
| ST-120Q | PRODUCT QUALITY HOLD | AIT-401/lab invalid or off-spec; tank identity unreleased | ST-100 only after quality authority releases | Stop transfer; no unapproved diversion |

### Prompt 16 calculation and logic workflow

1. **Freeze boundary and configuration:** confirm Route C decision, equipment list, stream IDs, package battery limits, utilities and site/relief/vent concept. Reconcile any changes to the PFD and this P&ID sketch.
2. **Close material balances:** solve source assay, CO2 conditioning recovery, ALK H2/O2/water, reactor reaction network, recycle/purge, V-301 phase split, crude-liquid letdown and distillation. Populate all stream rates and compositions with provenance.
3. **Validate properties and process states:** validate high-pressure mixture EOS and methanol-water VLE; calculate stream T/P/phase/enthalpy; solve duties and equipment operating limits.
4. **Close utility and package maps:** obtain ALK voltage/current/Faradaic efficiency/auxiliary-load and ramp map; all compressor performance maps; minimum stable loads; anti-surge control lines; cooling and steam supply states; instrument-air/N2 capacity and UPS autonomy.
5. **Build static setpoint envelopes:** calculate normal/min/max, alarm and trip boundaries from mass/energy balances, vendor limits, instrument accuracy, relief basis and operator response time. Record the basis and approver for each value.
6. **Build dynamic model:** model power shortfall, H2 buffer, coordinated H2/CO2 feed turndown, reactor thermal inertia, recycle loop pressure/composition, compressor trips, cooling failure, column response and shutdown inventory. Determine ramp rates, timers and whether the plant can ride through DB-059.
7. **Implement sequence/state logic:** define state machine, permissives, timers, sequence aborts, output ownership, latched faults, reset rules and bad-quality behaviour. Keep BPCS, package PLC, machinery protection, FGS and SIS boundaries explicit.
8. **Verify and validate:** run structured logic simulation / HIL, cause-and-effect test, alarm rationalisation, FAT, SAT, loop checks, valve stroke tests, proof tests and pre-startup safety review. Close all P&ID, I/O, instrument index and MOC discrepancies.

**Prompt 16 machine-readable placeholders:** `T_UTIL_STABLE`, `T_ANALYSER_VALID`, `T_LEAK_TEST`, `T_RECYCLE_STABLE`, `T_REACTOR_STABLE`, `T_COLUMN_STABLE`, `T_POWER_RECOVERY`, `T_COMM_WATCHDOG`, `RAMP_H2_UP`, `RAMP_H2_DOWN`, `RAMP_CO2_UP`, `RAMP_CO2_DOWN`, `MIN_ELY_LOAD`, `MIN_SYNTHESIS_LOAD`, `MAX_LOOP_INERT`, `RATIO_MIN`, `RATIO_MAX`, `R301_T_HIGH`, `R301_T_HH`, `R301_P_HIGH`, `R301_P_HH`, `V301_L_HH`, `V301_L_LL`, `U501_P_HIGH`, `U501_FLOW_MAX` and `W501_HOLD_CAPACITY`. Every placeholder requires engineering derivation and approval before implementation.

---

## 10. Verification requirements before detailed design release

- Complete formal HAZOP for the process nodes and sequence deviations; complete LOPA / SIF allocation where safeguards require it; do not assign SIL before the lifecycle assessment.
- Complete relief and depressurisation studies, vent network/backpressure and dispersion analysis, fire/explosion and hazardous-area assessment, including simultaneous releases and low-temperature cases.
- Obtain all package OEM P&IDs, control narratives, start/stop instructions, trip lists, interlocks, fail positions, maps, alarm limits and communication failure modes.
- Complete line-by-line P&ID review, valve/line/instrument indexes, drain and vent segregation, isolation register, cause/effect, I/O list, control-system architecture and network/cybersecurity design.
- Validate control-room alarm load, priority, deadband, shelving/bypass controls, first-out presentation, trend retention and operator response-time assumptions.
- Prove cause/effect, package interface and independent-protection functions through FAT/SAT and proof testing. No bypass is accepted without a controlled impairment/MOC process.
- Complete catalyst, electrolyte, chemical, wastewater and product handling procedures with OEM/EHS/operations approval.

**End of Prompt 15 design input.** The files in this folder are engineering design artifacts for Prompt 16; none constitutes an approved operating procedure or certified safety implementation.
