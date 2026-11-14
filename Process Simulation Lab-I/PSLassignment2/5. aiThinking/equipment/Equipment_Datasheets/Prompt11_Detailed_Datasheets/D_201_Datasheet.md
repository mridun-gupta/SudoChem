# Equipment datasheet: D-201

**Package:** ENERGY-008 Prompt 11  
**Revision:** 0.1-DRAFT  
**Design status:** BLOCKED - flow lower-bound only  
**Equipment:** Hydrogen gas purification and drying

## 1. Service and connections

| Field | Basis |
|---|---|
| Tag / service | D-201 / Condition electrolyser product H2 to synthesis catalyst acceptance |
| Control volume | CV-200 |
| PFD inlet stream(s) | S-104 |
| PFD outlet stream(s) | S-105 / S-106 |
| Phase | Gas + condensed liquid |
| Composition / quality | H2 purity target >=99.9 mol% dry; dewpoint/oxygen/electrolyte carryover acceptance TBD |
| Process function | Hydrogen gas purification and drying |

## 2. Capacity and operating cases

| Case | Capacity / flow basis | State |
|---|---|---|
| Minimum stable | At least 196.61 kg/h H₂ component at 25 t/day methanol-equivalent; dryer load/purity guarantee TBD | Draft operating-envelope case; equipment turndown not vendor-verified |
| Normal | At least 393.21 kg/h H₂ component at 50 t/day; actual gas quality/dew point TBD | Draft reference case |
| Maximum continuous | At least 432.53 kg/h H₂ component at 55 t/day; actual gas quality/dew point TBD | Draft screening case |
| Process design | At least 475.79 kg/h H₂ component at 60.5 t/day; actual gas quality/dew point TBD | Draft process capacity; DB-011 10% margin is already embedded, do not add again |
| Upset | Renewable electricity 50% of nominal for 2 h (OP-026) | Buffer/ramp response not approved; no continuity assumption |

**Case-specific screening note:** H2 component lower-bound is 475.79 kg/h at design. Gas purity, dew point, O2 crossover and electrolyte aerosol limits are unprovided.

## 3. Process and mechanical design conditions

| Parameter | Value / status |
|---|---|
| Normal operating temperature | TBD |
| Normal operating pressure | 15-30 bar(a) interface range, provisional |
| Outlet / local operating conditions | TBD / 15-30 bar(a) interface range |
| Mechanical design temperature | TBD from maximum/minimum metal temperature, credible upsets, start-up/shutdown, reaction excursion and applicable code |
| Mechanical design pressure | TBD from maximum credible pressure, blocked-in, control failure, thermal expansion, compressor shutoff, relief/vent basis and code |
| Vacuum / external pressure | TBD where applicable |
| Pressure drop | TBD by hydraulic / vendor calculation |

The operating limits (including 200–300°C and 5–10 MPa(a) on the synthesis loop) are not mechanical design ratings.

## 4. Sizing method and calculated result

**Method / status:** Dryer/PSA/membrane selection requires gas assay, dewpoint spec and vendor curves

**Sizing conclusion:** No equipment dimension, mechanical rating or vendor capacity is released for this tag until the outstanding model and design inputs are resolved.

No unsupported balancing, generic equipment correlation or vendor guarantee has been used. Where numerical output is not shown, the item is **not sized**, rather than zero-sized.

## 5. Materials, corrosion and fouling

| Item | Preliminary basis |
|---|---|
| Materials of construction | Hydrogen and electrolyte aerosol compatibility; adsorbent, vessel and seals TBD |
| Corrosion / erosion allowance | Adsorbent loading, moisture breakthrough and caustic carryover TBD |
| Fouling / plugging / poisoning | Adsorbent loading, moisture breakthrough and caustic carryover TBD |
| Cleaning / regeneration / maintenance | Regeneration/changeout and drain segregation TBD |
| Hydrogen compatibility | Where H2 is present, assess permeation, embrittlement, fatigue, weld procedure, sealing, leakage and pressure cycling. Grade and allowable stress are not selected. |
| Oxygen compatibility | For O2 service, conduct oxygen cleanliness, ignition and non-metallic compatibility review; no material grade is selected. |
| KOH compatibility | For electrolyte service, confirm concentration, temperature, stress-corrosion/corrosion compatibility and OEM material schedule. |

No corrosion allowance or material grade is assigned without assay, temperature, concentration, code and corrosion review.

## 6. Turndown, margin and operating flexibility

- Plant minimum stable throughput assumption: 25 t/day (50% of 50 t/day normal), pending vendor/process validation.
- Equipment-specific turndown: Parallel beds/swing strategy and minimum flow TBD
- Process design capacity: 60.5 t/day is derived from 55 t/day maximum screening case × 1.10. Do not add the same 10% process margin a second time.
- Start-up/shutdown ramp and durations: vendor/catalyst SOP required.
- Bypass, standby, parallel-train and redundancy philosophy: not selected except where expressly identified in the equipment package.

## 7. Connections, instruments, utilities and safeguards

**Connections:** PFD streams S-104 → S-105 / S-106; utility connections and nozzle sizes remain TBD.

**Instrumentation/control to develop:** flow, pressure, temperature, level and composition instruments as required by the equipment service; package-specific controls, alarms, trips, permissives and control-valve fail action require HAZID/HAZOP/LOPA and control philosophy.

**Relief and safeguards:** relief-device sizing, set pressure, discharge destination, blowdown/depressurisation, isolation, ESD, gas/fire detection, hazardous-area classification and safe venting remain open. No device size or SIL claim is made.

**Utilities:** Utility requirements and rates are not calculated; see Prompt 7 Utility Register U-001 to U-010.

**Footprint/layout:** no plot plan, access envelope, maintenance pull space, lifting path, hazardous-area layout, fire separation or foundation load is available. Vendor GA / 3D model and plot plan are required.

**Cleaning and maintenance access:** Regeneration/changeout and drain segregation TBD

## 8. Codes and standards to verify

ASME B31.3:2024 for applicable process piping; equipment construction code to be selected by service/type and jurisdiction. No code compliance is claimed.

These are candidate references only. Confirm statutory applicability, current adopted edition, site jurisdiction and owner requirements before design, procurement or construction. This datasheet does not demonstrate code compliance.

## 9. Required closure items before design release

H2 purity/moisture/oxygen/crossover/electrolyte, actual H2 flow and package selection

Additional common inputs: approved G3 design basis; source and stream assays; validated Prompt 8 material balance; solved Prompt 9 duties; equipment package/vendor guarantees; mechanical design basis; relief/vent design; corrosion/materials review; HAZID/HAZOP; electrical and hazardous-area classification; site design conditions.

---
*Editable engineering datasheet. All TBD fields are intentional hold points, not zero values.*
