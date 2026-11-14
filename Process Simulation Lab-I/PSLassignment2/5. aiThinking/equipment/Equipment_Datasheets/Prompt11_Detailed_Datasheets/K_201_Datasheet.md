# Equipment datasheet: K-201

**Package:** ENERGY-008 Prompt 11  
**Revision:** 0.1-DRAFT  
**Design status:** SCREENING CALCULATION ONLY - NOT RATING  
**Equipment:** Hydrogen compression and buffer package

## 1. Service and connections

| Field | Basis |
|---|---|
| Tag / service | K-201 / Compress H2 from electrolyser interface to synthesis loop; buffer decoupling |
| Control volume | CV-200 |
| PFD inlet stream(s) | S-106 |
| PFD outlet stream(s) | S-107 |
| Phase | Gas |
| Composition / quality | Pure H2 assumed for screening only; no real-gas/compressibility or impurity correction |
| Process function | Hydrogen compression and buffer package |

## 2. Capacity and operating cases

| Case | Capacity / flow basis | State |
|---|---|---|
| Minimum stable | 196.61 kg/h H₂; 52.47 kW motor-input screen at 30→50 bar(a); assumed two-stage case | Draft operating-envelope case; equipment turndown not vendor-verified |
| Normal | 393.21 kg/h H₂; 271.70 kW motor-input screen at 20→70 bar(a); assumed two-stage case | Draft reference case |
| Maximum continuous | 432.53 kg/h H₂; 474.73 kW motor-input screen at 15→100 bar(a); assumed two-stage case | Draft screening case |
| Process design | 475.79 kg/h H₂; 522.20 kW motor-input screen at 15→100 bar(a); assumed two-stage case | Draft process capacity; DB-011 10% margin is already embedded, do not add again |
| Upset | Renewable electricity 50% of nominal for 2 h (OP-026) | Buffer/ramp response not approved; no continuity assumption |

**Case-specific screening note:** H2 component lower-bound is 475.79 kg/h at design. Normal model uses 20→70 bar(a); design envelope uses 15→100 bar(a).

## 3. Process and mechanical design conditions

| Parameter | Value / status |
|---|---|
| Normal operating temperature | 40°C assumed suction/interstage temperature |
| Normal operating pressure | 20 bar(a) normal; 15 bar(a) low |
| Outlet / local operating conditions | 40°C aftercooler target assumption / 7.0 MPa(a) normal; 10 MPa(a) upper loop envelope |
| Mechanical design temperature | TBD from maximum/minimum metal temperature, credible upsets, start-up/shutdown, reaction excursion and applicable code |
| Mechanical design pressure | TBD from maximum credible pressure, blocked-in, control failure, thermal expansion, compressor shutoff, relief/vent basis and code |
| Vacuum / external pressure | TBD where applicable |
| Pressure drop | TBD by hydraulic / vendor calculation |

The operating limits (including 200–300°C and 5–10 MPa(a) on the synthesis loop) are not mechanical design ratings.

## 4. Sizing method and calculated result

**Method / status:** Two-stage ideal-gas Shomate compression screen at 75% isentropic/95% motor efficiency; no real-gas correction or ΔP

**Sizing conclusion:** Calculated screening only: two stages, equal pressure ratio, perfect intercooling/aftercooling to 40°C; NIST Shomate ideal-gas H2; assumed η_is=0.75 and η_motor=0.95. Design-envelope electrical input is approximately 522.2 kW; shaft power approximately 496.1 kW; intercooler and aftercooler duties approximately 248.0 kW each. No real-gas, pressure-drop, seal, pulsation, vibration or vendor-map correction.

No unsupported balancing, generic equipment correlation or vendor guarantee has been used. Where numerical output is not shown, the item is **not sized**, rather than zero-sized.

## 5. Materials, corrosion and fouling

| Item | Preliminary basis |
|---|---|
| Materials of construction | Hydrogen-compatible materials, embrittlement, seals, lubricants, cleanliness and leak-tightness assessment; TBD |
| Corrosion / erosion allowance | Hydrogen service materials/fatigue assessment; no corrosion allowance assigned |
| Fouling / plugging / poisoning | Hydrogen service materials/fatigue assessment; no corrosion allowance assigned |
| Cleaning / regeneration / maintenance | Vendor compressor/valve/seal inspection; buffer inspection code TBD |
| Hydrogen compatibility | Where H2 is present, assess permeation, embrittlement, fatigue, weld procedure, sealing, leakage and pressure cycling. Grade and allowable stress are not selected. |
| Oxygen compatibility | For O2 service, conduct oxygen cleanliness, ignition and non-metallic compatibility review; no material grade is selected. |
| KOH compatibility | For electrolyte service, confirm concentration, temperature, stress-corrosion/corrosion compatibility and OEM material schedule. |

No corrosion allowance or material grade is assigned without assay, temperature, concentration, code and corrosion review.

## 6. Turndown, margin and operating flexibility

- Plant minimum stable throughput assumption: 25 t/day (50% of 50 t/day normal), pending vendor/process validation.
- Equipment-specific turndown: Minimum/maximum speed and recycle controls require vendor map; H2 buffer usable inventory TBD
- Process design capacity: 60.5 t/day is derived from 55 t/day maximum screening case × 1.10. Do not add the same 10% process margin a second time.
- Start-up/shutdown ramp and durations: vendor/catalyst SOP required.
- Bypass, standby, parallel-train and redundancy philosophy: not selected except where expressly identified in the equipment package.

## 7. Connections, instruments, utilities and safeguards

**Connections:** PFD streams S-106 → S-107; utility connections and nozzle sizes remain TBD.

**Instrumentation/control to develop:** flow, pressure, temperature, level and composition instruments as required by the equipment service; package-specific controls, alarms, trips, permissives and control-valve fail action require HAZID/HAZOP/LOPA and control philosophy.

**Relief and safeguards:** relief-device sizing, set pressure, discharge destination, blowdown/depressurisation, isolation, ESD, gas/fire detection, hazardous-area classification and safe venting remain open. No device size or SIL claim is made.

**Utilities:** Electrical U-009; intercooling/aftercooling cooling water U-002/U-003; instrument air U-005 as required.

**Footprint/layout:** no plot plan, access envelope, maintenance pull space, lifting path, hazardous-area layout, fire separation or foundation load is available. Vendor GA / 3D model and plot plan are required.

**Cleaning and maintenance access:** Vendor compressor/valve/seal inspection; buffer inspection code TBD

## 8. Codes and standards to verify

Hydrogen storage/pressure package legal screen: SMPV(U) Rules (as amended), IS 2825 / ASME VIII as applicable; H2 piping B31.12/B31.3 review. Compressor-specific API standard depends on final machine type.

These are candidate references only. Confirm statutory applicability, current adopted edition, site jurisdiction and owner requirements before design, procurement or construction. This datasheet does not demonstrate code compliance.

## 9. Required closure items before design release

Confirmed suction T/P, guaranteed H2 flow/purity, real-gas EOS, compressor type/map, surge/stage constraints, pressure drop, buffer configuration and statutory code

Additional common inputs: approved G3 design basis; source and stream assays; validated Prompt 8 material balance; solved Prompt 9 duties; equipment package/vendor guarantees; mechanical design basis; relief/vent design; corrosion/materials review; HAZID/HAZOP; electrical and hazardous-area classification; site design conditions.

---
*Editable engineering datasheet. All TBD fields are intentional hold points, not zero values.*
