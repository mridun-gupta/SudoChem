# Equipment datasheet: P-401

**Package:** ENERGY-008 Prompt 11  
**Revision:** 0.1-DRAFT  
**Design status:** FLOW ANCHOR ONLY  
**Equipment:** Distillate/product transfer pump

## 1. Service and connections

| Field | Basis |
|---|---|
| Tag / service | P-401 / Transfer net methanol product to TK-401 |
| Control volume | CV-400 |
| PFD inlet stream(s) | S-304 |
| PFD outlet stream(s) | S-305 |
| Phase | Liquid |
| Composition / quality | Methanol-rich product target; exact water/trace composition unknown |
| Process function | Distillate/product transfer pump |

## 2. Capacity and operating cases

| Case | Capacity / flow basis | State |
|---|---|---|
| Minimum stable | Methanol product-equivalent 1,041.67 kg/h; ~31.57 m³/day at 0.792 t/m³ reference density | Draft operating-envelope case; equipment turndown not vendor-verified |
| Normal | Methanol product-equivalent 2,083.33 kg/h; ~63.13 m³/day at 0.792 t/m³ reference density | Draft reference case |
| Maximum continuous | Methanol product-equivalent 2,291.67 kg/h; ~69.44 m³/day at 0.792 t/m³ reference density | Draft screening case |
| Process design | Methanol product-equivalent 2,520.83 kg/h; ~76.39 m³/day at 0.792 t/m³ reference density | Draft process capacity; DB-011 10% margin is already embedded, do not add again |
| Upset | Renewable electricity 50% of nominal for 2 h (OP-026) | Buffer/ramp response not approved; no continuity assumption |

**Case-specific screening note:** Product component-equivalent throughput is 2,520.8 kg/h at design; pump head and NPSH are unknown.

## 3. Process and mechanical design conditions

| Parameter | Value / status |
|---|---|
| Normal operating temperature | 20°C density reference used only for volume conversion |
| Normal operating pressure | Suction pressure TBD |
| Outlet / local operating conditions | TBD / Tank/dispatch pressure TBD |
| Mechanical design temperature | TBD from maximum/minimum metal temperature, credible upsets, start-up/shutdown, reaction excursion and applicable code |
| Mechanical design pressure | TBD from maximum credible pressure, blocked-in, control failure, thermal expansion, compressor shutoff, relief/vent basis and code |
| Vacuum / external pressure | TBD where applicable |
| Pressure drop | TBD by hydraulic / vendor calculation |

The operating limits (including 200–300°C and 5–10 MPa(a) on the synthesis loop) are not mechanical design ratings.

## 4. Sizing method and calculated result

**Method / status:** Flow calculated; head, NPSH, hydraulic power and driver power cannot be calculated without system curve

**Sizing conclusion:** At 60.5 t/day, product component-equivalent mass throughput is 2,520.8 kg/h. A 20°C reference density of 0.792 t/m3 gives approximately 3.183 m3/h. Pump head, NPSH, hydraulics and power remain unknown.

No unsupported balancing, generic equipment correlation or vendor guarantee has been used. Where numerical output is not shown, the item is **not sized**, rather than zero-sized.

## 5. Materials, corrosion and fouling

| Item | Preliminary basis |
|---|---|
| Materials of construction | Methanol compatibility, seals, elastomers and electrical area classification review; grade TBD |
| Corrosion / erosion allowance | Corrosion allowance not assigned; contamination/corrosion assessment needed |
| Fouling / plugging / poisoning | Corrosion allowance not assigned; contamination/corrosion assessment needed |
| Cleaning / regeneration / maintenance | Seal maintenance, drainability, flushing and dry-run protection TBD |
| Hydrogen compatibility | Where H2 is present, assess permeation, embrittlement, fatigue, weld procedure, sealing, leakage and pressure cycling. Grade and allowable stress are not selected. |
| Oxygen compatibility | For O2 service, conduct oxygen cleanliness, ignition and non-metallic compatibility review; no material grade is selected. |
| KOH compatibility | For electrolyte service, confirm concentration, temperature, stress-corrosion/corrosion compatibility and OEM material schedule. |

No corrosion allowance or material grade is assigned without assay, temperature, concentration, code and corrosion review.

## 6. Turndown, margin and operating flexibility

- Plant minimum stable throughput assumption: 25 t/day (50% of 50 t/day normal), pending vendor/process validation.
- Equipment-specific turndown: Vendor pump curve/NPSH and minimum continuous stable flow required
- Process design capacity: 60.5 t/day is derived from 55 t/day maximum screening case × 1.10. Do not add the same 10% process margin a second time.
- Start-up/shutdown ramp and durations: vendor/catalyst SOP required.
- Bypass, standby, parallel-train and redundancy philosophy: not selected except where expressly identified in the equipment package.

## 7. Connections, instruments, utilities and safeguards

**Connections:** PFD streams S-304 → S-305; utility connections and nozzle sizes remain TBD.

**Instrumentation/control to develop:** flow, pressure, temperature, level and composition instruments as required by the equipment service; package-specific controls, alarms, trips, permissives and control-valve fail action require HAZID/HAZOP/LOPA and control philosophy.

**Relief and safeguards:** relief-device sizing, set pressure, discharge destination, blowdown/depressurisation, isolation, ESD, gas/fire detection, hazardous-area classification and safe venting remain open. No device size or SIL claim is made.

**Utilities:** Utility requirements and rates are not calculated; see Prompt 7 Utility Register U-001 to U-010.

**Footprint/layout:** no plot plan, access envelope, maintenance pull space, lifting path, hazardous-area layout, fire separation or foundation load is available. Vendor GA / 3D model and plot plan are required.

**Cleaning and maintenance access:** Seal maintenance, drainability, flushing and dry-run protection TBD

## 8. Codes and standards to verify

ASME B31.3:2024 for applicable process piping; equipment construction code to be selected by service/type and jurisdiction. No code compliance is claimed.

These are candidate references only. Confirm statutory applicability, current adopted edition, site jurisdiction and owner requirements before design, procurement or construction. This datasheet does not demonstrate code compliance.

## 9. Required closure items before design release

Suction/discharge pressure, elevation, line loss, tank pressure, NPSHA, temperature, vapor pressure and pump type

Additional common inputs: approved G3 design basis; source and stream assays; validated Prompt 8 material balance; solved Prompt 9 duties; equipment package/vendor guarantees; mechanical design basis; relief/vent design; corrosion/materials review; HAZID/HAZOP; electrical and hazardous-area classification; site design conditions.

---
*Editable engineering datasheet. All TBD fields are intentional hold points, not zero values.*
