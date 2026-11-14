# Equipment datasheet: TK-401

**Package:** ENERGY-008 Prompt 11  
**Revision:** 0.1-DRAFT  
**Design status:** SCREENING INVENTORY SCENARIOS ONLY  
**Equipment:** Methanol product storage and dispatch

## 1. Service and connections

| Field | Basis |
|---|---|
| Tag / service | TK-401 / Provide finished-product inventory and dispatch buffer |
| Control volume | CV-400 |
| PFD inlet stream(s) | S-305 |
| PFD outlet stream(s) | S-314 / dispatch |
| Phase | Liquid |
| Composition / quality | Methanol-rich product; quality target 99.85 wt% and density 0.7910-0.7930 at 20/20°C are draft/academic targets |
| Process function | Methanol product storage and dispatch |

## 2. Capacity and operating cases

| Case | Capacity / flow basis | State |
|---|---|---|
| Minimum stable | Net product throughput ~31.57 m³/day; inventory duration/gross tank volume TBD | Draft operating-envelope case; equipment turndown not vendor-verified |
| Normal | Net product throughput ~63.13 m³/day; inventory duration/gross tank volume TBD | Draft reference case |
| Maximum continuous | Net product throughput ~69.44 m³/day; inventory duration/gross tank volume TBD | Draft screening case |
| Process design | Net product throughput ~76.39 m³/day; inventory duration/gross tank volume TBD | Draft process capacity; DB-011 10% margin is already embedded, do not add again |
| Upset | Renewable electricity 50% of nominal for 2 h (OP-026) | Buffer/ramp response not approved; no continuity assumption |

**Case-specific screening note:** Inventory scenarios only; no duration selected and no gross volume, vent or blanketing design.

## 3. Process and mechanical design conditions

| Parameter | Value / status |
|---|---|
| Normal operating temperature | TBD |
| Normal operating pressure | Storage pressure/temp and design P/T TBD |
| Outlet / local operating conditions | TBD / Storage pressure/temp and design P/T TBD |
| Mechanical design temperature | TBD from maximum/minimum metal temperature, credible upsets, start-up/shutdown, reaction excursion and applicable code |
| Mechanical design pressure | TBD from maximum credible pressure, blocked-in, control failure, thermal expansion, compressor shutoff, relief/vent basis and code |
| Vacuum / external pressure | TBD where applicable |
| Pressure drop | TBD by hydraulic / vendor calculation |

The operating limits (including 200–300°C and 5–10 MPa(a) on the synthesis loop) are not mechanical design ratings.

## 4. Sizing method and calculated result

**Method / status:** 8/24/72 h net inventory scenarios only; no selected storage duration, gross volume, venting or bund design

**Sizing conclusion:** At the 60.5 t/day process design capacity and density midpoint 0.792 t/m3, net product volume is approximately 76.39 m3/day. Net inventory scenarios are 25.46 m3 (8 h), 76.39 m3 (24 h), and 229.17 m3 (72 h). No storage duration is selected.

No unsupported balancing, generic equipment correlation or vendor guarantee has been used. Where numerical output is not shown, the item is **not sized**, rather than zero-sized.

## 5. Materials, corrosion and fouling

| Item | Preliminary basis |
|---|---|
| Materials of construction | Methanol compatibility, water/trace contamination, tank coating/lining/roof seals and nitrogen blanketing review |
| Corrosion / erosion allowance | Corrosion allowance, corrosion monitoring and bottom-water management TBD |
| Fouling / plugging / poisoning | Corrosion allowance, corrosion monitoring and bottom-water management TBD |
| Cleaning / regeneration / maintenance | Tank inspection, water draw, cleaning, vapour-space and access requirements TBD |
| Hydrogen compatibility | Where H2 is present, assess permeation, embrittlement, fatigue, weld procedure, sealing, leakage and pressure cycling. Grade and allowable stress are not selected. |
| Oxygen compatibility | For O2 service, conduct oxygen cleanliness, ignition and non-metallic compatibility review; no material grade is selected. |
| KOH compatibility | For electrolyte service, confirm concentration, temperature, stress-corrosion/corrosion compatibility and OEM material schedule. |

No corrosion allowance or material grade is assigned without assay, temperature, concentration, code and corrosion review.

## 6. Turndown, margin and operating flexibility

- Plant minimum stable throughput assumption: 25 t/day (50% of 50 t/day normal), pending vendor/process validation.
- Equipment-specific turndown: Inventory autonomy and dispatch profile determine tank train/turnover
- Process design capacity: 60.5 t/day is derived from 55 t/day maximum screening case × 1.10. Do not add the same 10% process margin a second time.
- Start-up/shutdown ramp and durations: vendor/catalyst SOP required.
- Bypass, standby, parallel-train and redundancy philosophy: not selected except where expressly identified in the equipment package.

## 7. Connections, instruments, utilities and safeguards

**Connections:** PFD streams S-305 → S-314 / dispatch; utility connections and nozzle sizes remain TBD.

**Instrumentation/control to develop:** flow, pressure, temperature, level and composition instruments as required by the equipment service; package-specific controls, alarms, trips, permissives and control-valve fail action require HAZID/HAZOP/LOPA and control philosophy.

**Relief and safeguards:** relief-device sizing, set pressure, discharge destination, blowdown/depressurisation, isolation, ESD, gas/fire detection, hazardous-area classification and safe venting remain open. No device size or SIL claim is made.

**Utilities:** General plant power U-009; nitrogen blanketing only if selected and engineered.

**Footprint/layout:** no plot plan, access envelope, maintenance pull space, lifting path, hazardous-area layout, fire separation or foundation load is available. Vendor GA / 3D model and plot plan are required.

**Cleaning and maintenance access:** Tank inspection, water draw, cleaning, vapour-space and access requirements TBD

## 8. Codes and standards to verify

API 650 14th Edition (2025) only if the selected tank type/service falls within its scope; also applicable Indian fire, environmental, PESO and local requirements.

These are candidate references only. Confirm statutory applicability, current adopted edition, site jurisdiction and owner requirements before design, procurement or construction. This datasheet does not demonstrate code compliance.

## 9. Required closure items before design release

Site, dispatch schedule, tank configuration, allowable fill, vent/blanket, fire protection, emissions and statutory code

Additional common inputs: approved G3 design basis; source and stream assays; validated Prompt 8 material balance; solved Prompt 9 duties; equipment package/vendor guarantees; mechanical design basis; relief/vent design; corrosion/materials review; HAZID/HAZOP; electrical and hazardous-area classification; site design conditions.

---
*Editable engineering datasheet. All TBD fields are intentional hold points, not zero values.*
