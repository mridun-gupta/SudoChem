# Equipment datasheet: P-101

**Package:** ENERGY-008 Prompt 11  
**Revision:** 0.1-DRAFT  
**Design status:** BLOCKED - throughput lower-bound only  
**Equipment:** CO2 recovery and purification package

## 1. Service and connections

| Field | Basis |
|---|---|
| Tag / service | P-101 / Recover/purify biogenic CO2 and manage reject stream |
| Control volume | CV-100 |
| PFD inlet stream(s) | S-004 |
| PFD outlet stream(s) | S-006 / S-007 |
| Phase | Gas; technology dependent |
| Composition / quality | Raw assay and product impurity specs unresolved; target CO2 >=99.5 mol% dry is provisional |
| Process function | CO2 recovery and purification package |

## 2. Capacity and operating cases

| Case | Capacity / flow basis | State |
|---|---|---|
| Minimum stable | CO₂ component lower bound 34.337 t/day at 25 t/day methanol-equivalent; raw source gas flow/recovery TBD | Draft operating-envelope case; equipment turndown not vendor-verified |
| Normal | CO₂ component lower bound 68.675 t/day at 50 t/day; raw source gas flow/recovery TBD | Draft reference case |
| Maximum continuous | CO₂ component lower bound 75.542 t/day at 55 t/day; raw source gas flow/recovery TBD | Draft screening case |
| Process design | CO₂ component lower bound 83.097 t/day at 60.5 t/day; raw source gas flow/recovery TBD | Draft process capacity; DB-011 10% margin is already embedded, do not add again |
| Upset | Renewable electricity 50% of nominal for 2 h (OP-026) | Buffer/ramp response not approved; no continuity assumption |

**Case-specific screening note:** Theoretical CO2 product need is 83.10 t/day at 60.5 t/day methanol, before losses and recovery. Raw source and recovery are unprovided.

## 3. Process and mechanical design conditions

| Parameter | Value / status |
|---|---|
| Normal operating temperature | TBD |
| Normal operating pressure | TBD |
| Outlet / local operating conditions | TBD / TBD |
| Mechanical design temperature | TBD from maximum/minimum metal temperature, credible upsets, start-up/shutdown, reaction excursion and applicable code |
| Mechanical design pressure | TBD from maximum credible pressure, blocked-in, control failure, thermal expansion, compressor shutoff, relief/vent basis and code |
| Vacuum / external pressure | TBD where applicable |
| Pressure drop | TBD by hydraulic / vendor calculation |

The operating limits (including 200–300°C and 5–10 MPa(a) on the synthesis loop) are not mechanical design ratings.

## 4. Sizing method and calculated result

**Method / status:** Package mass balance, recovery, purity, solvent/adsorbent and energy requirement

**Sizing conclusion:** No equipment dimension, mechanical rating or vendor capacity is released for this tag until the outstanding model and design inputs are resolved.

No unsupported balancing, generic equipment correlation or vendor guarantee has been used. Where numerical output is not shown, the item is **not sized**, rather than zero-sized.

## 5. Materials, corrosion and fouling

| Item | Preliminary basis |
|---|---|
| Materials of construction | Technology/materials selection after water/H2S/siloxane/solvent review |
| Corrosion / erosion allowance | Solvent/adsorbent degradation and fouling basis TBD |
| Fouling / plugging / poisoning | Solvent/adsorbent degradation and fouling basis TBD |
| Cleaning / regeneration / maintenance | Vendor regeneration / replacement schedule TBD |
| Hydrogen compatibility | Where H2 is present, assess permeation, embrittlement, fatigue, weld procedure, sealing, leakage and pressure cycling. Grade and allowable stress are not selected. |
| Oxygen compatibility | For O2 service, conduct oxygen cleanliness, ignition and non-metallic compatibility review; no material grade is selected. |
| KOH compatibility | For electrolyte service, confirm concentration, temperature, stress-corrosion/corrosion compatibility and OEM material schedule. |

No corrosion allowance or material grade is assigned without assay, temperature, concentration, code and corrosion review.

## 6. Turndown, margin and operating flexibility

- Plant minimum stable throughput assumption: 25 t/day (50% of 50 t/day normal), pending vendor/process validation.
- Equipment-specific turndown: Turn-down and turndown recovery map required
- Process design capacity: 60.5 t/day is derived from 55 t/day maximum screening case × 1.10. Do not add the same 10% process margin a second time.
- Start-up/shutdown ramp and durations: vendor/catalyst SOP required.
- Bypass, standby, parallel-train and redundancy philosophy: not selected except where expressly identified in the equipment package.

## 7. Connections, instruments, utilities and safeguards

**Connections:** PFD streams S-004 → S-006 / S-007; utility connections and nozzle sizes remain TBD.

**Instrumentation/control to develop:** flow, pressure, temperature, level and composition instruments as required by the equipment service; package-specific controls, alarms, trips, permissives and control-valve fail action require HAZID/HAZOP/LOPA and control philosophy.

**Relief and safeguards:** relief-device sizing, set pressure, discharge destination, blowdown/depressurisation, isolation, ESD, gas/fire detection, hazardous-area classification and safe venting remain open. No device size or SIL claim is made.

**Utilities:** Utility requirements and rates are not calculated; see Prompt 7 Utility Register U-001 to U-010.

**Footprint/layout:** no plot plan, access envelope, maintenance pull space, lifting path, hazardous-area layout, fire separation or foundation load is available. Vendor GA / 3D model and plot plan are required.

**Cleaning and maintenance access:** Vendor regeneration / replacement schedule TBD

## 8. Codes and standards to verify

ASME B31.3:2024 for applicable process piping; equipment construction code to be selected by service/type and jurisdiction. No code compliance is claimed.

These are candidate references only. Confirm statutory applicability, current adopted edition, site jurisdiction and owner requirements before design, procurement or construction. This datasheet does not demonstrate code compliance.

## 9. Required closure items before design release

Source flow/assay, recovery fraction, product specs, reject composition, energy/solvent data, technology selection

Additional common inputs: approved G3 design basis; source and stream assays; validated Prompt 8 material balance; solved Prompt 9 duties; equipment package/vendor guarantees; mechanical design basis; relief/vent design; corrosion/materials review; HAZID/HAZOP; electrical and hazardous-area classification; site design conditions.

---
*Editable engineering datasheet. All TBD fields are intentional hold points, not zero values.*
