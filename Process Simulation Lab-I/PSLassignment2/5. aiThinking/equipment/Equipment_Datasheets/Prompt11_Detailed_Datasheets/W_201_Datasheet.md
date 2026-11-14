# Equipment datasheet: W-201

**Package:** ENERGY-008 Prompt 11  
**Revision:** 0.1-DRAFT  
**Design status:** SCREENING OUTPUT CAPACITY ONLY  
**Equipment:** Water pretreatment and DI polishing package

## 1. Service and connections

| Field | Basis |
|---|---|
| Tag / service | W-201 / Produce feedwater quality accepted by ALK package |
| Control volume | CV-200 |
| PFD inlet stream(s) | S-101 |
| PFD outlet stream(s) | S-102 / S-103 |
| Phase | Liquid |
| Composition / quality | Raw water and DI product quality unknown; reject chemistry unknown |
| Process function | Water pretreatment and DI polishing package |

## 2. Capacity and operating cases

| Case | Capacity / flow basis | State |
|---|---|---|
| Minimum stable | DI product-water guidance 42.47 m³/day at 25 t/day; raw-water feed/recovery TBD | Draft operating-envelope case; equipment turndown not vendor-verified |
| Normal | DI product-water guidance 84.93 m³/day at 50 t/day; raw-water feed/recovery TBD | Draft reference case |
| Maximum continuous | DI product-water guidance 93.43 m³/day at 55 t/day; raw-water feed/recovery TBD | Draft screening case |
| Process design | DI product-water guidance 102.77 m³/day at 60.5 t/day; raw-water feed/recovery TBD | Draft process capacity; DB-011 10% margin is already embedded, do not add again |
| Upset | Renewable electricity 50% of nominal for 2 h (OP-026) | Buffer/ramp response not approved; no continuity assumption |

**Case-specific screening note:** DI output guidance is 102.77 m3/day at design; no raw-water quality or recovery yield is known.

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

**Method / status:** DI water demand sizing from MNRE 9 L/kg H2 guidance; raw-water feed requires recovery/yield

**Sizing conclusion:** At 60.5 t/day methanol component-equivalent the 9 L/kg H2 DI-water guidance corresponds to approximately 102.77 m3/day DI product, or 4.282 m3/h. Raw-water intake is higher and remains unknown because recovery and reject rates are not known.

No unsupported balancing, generic equipment correlation or vendor guarantee has been used. Where numerical output is not shown, the item is **not sized**, rather than zero-sized.

## 5. Materials, corrosion and fouling

| Item | Preliminary basis |
|---|---|
| Materials of construction | Raw water / permeate / DI quality and chemical compatibility; polymer/metal selection by OEM |
| Corrosion / erosion allowance | Membrane scaling/fouling and ion-exchange regeneration waste TBD |
| Fouling / plugging / poisoning | Membrane scaling/fouling and ion-exchange regeneration waste TBD |
| Cleaning / regeneration / maintenance | CIP/regeneration and cartridge replacement per OEM water analysis |
| Hydrogen compatibility | Where H2 is present, assess permeation, embrittlement, fatigue, weld procedure, sealing, leakage and pressure cycling. Grade and allowable stress are not selected. |
| Oxygen compatibility | For O2 service, conduct oxygen cleanliness, ignition and non-metallic compatibility review; no material grade is selected. |
| KOH compatibility | For electrolyte service, confirm concentration, temperature, stress-corrosion/corrosion compatibility and OEM material schedule. |

No corrosion allowance or material grade is assigned without assay, temperature, concentration, code and corrosion review.

## 6. Turndown, margin and operating flexibility

- Plant minimum stable throughput assumption: 25 t/day (50% of 50 t/day normal), pending vendor/process validation.
- Equipment-specific turndown: Package turndown/backwash/standby train TBD
- Process design capacity: 60.5 t/day is derived from 55 t/day maximum screening case × 1.10. Do not add the same 10% process margin a second time.
- Start-up/shutdown ramp and durations: vendor/catalyst SOP required.
- Bypass, standby, parallel-train and redundancy philosophy: not selected except where expressly identified in the equipment package.

## 7. Connections, instruments, utilities and safeguards

**Connections:** PFD streams S-101 → S-102 / S-103; utility connections and nozzle sizes remain TBD.

**Instrumentation/control to develop:** flow, pressure, temperature, level and composition instruments as required by the equipment service; package-specific controls, alarms, trips, permissives and control-valve fail action require HAZID/HAZOP/LOPA and control philosophy.

**Relief and safeguards:** relief-device sizing, set pressure, discharge destination, blowdown/depressurisation, isolation, ESD, gas/fire detection, hazardous-area classification and safe venting remain open. No device size or SIL claim is made.

**Utilities:** Raw water BL-W01, electricity and chemical supplies; reject to W-501.

**Footprint/layout:** no plot plan, access envelope, maintenance pull space, lifting path, hazardous-area layout, fire separation or foundation load is available. Vendor GA / 3D model and plot plan are required.

**Cleaning and maintenance access:** CIP/regeneration and cartridge replacement per OEM water analysis

## 8. Codes and standards to verify

ASME B31.3:2024 for applicable process piping; equipment construction code to be selected by service/type and jurisdiction. No code compliance is claimed.

These are candidate references only. Confirm statutory applicability, current adopted edition, site jurisdiction and owner requirements before design, procurement or construction. This datasheet does not demonstrate code compliance.

## 9. Required closure items before design release

Raw-water assay, recovery %, product resistivity/silica/TOC, storage, pretreatment process and reject routing

Additional common inputs: approved G3 design basis; source and stream assays; validated Prompt 8 material balance; solved Prompt 9 duties; equipment package/vendor guarantees; mechanical design basis; relief/vent design; corrosion/materials review; HAZID/HAZOP; electrical and hazardous-area classification; site design conditions.

---
*Editable engineering datasheet. All TBD fields are intentional hold points, not zero values.*
