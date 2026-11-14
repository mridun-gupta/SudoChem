# Equipment datasheet: ELY-201

**Package:** ENERGY-008 Prompt 11  
**Revision:** 0.1-DRAFT  
**Design status:** CAPACITY FLOW ANCHOR ONLY  
**Equipment:** Pressurised alkaline electrolyser package

## 1. Service and connections

| Field | Basis |
|---|---|
| Tag / service | ELY-201 / Generate renewable H2 and O2 with electrolyte circulation and gas/liquid separation |
| Control volume | CV-200 |
| PFD inlet stream(s) | S-102 / U-001 / S-111 |
| PFD outlet stream(s) | S-104 / S-108 / S-112 |
| Phase | Liquid + H2/O2 gas |
| Composition / quality | H2 >=99.9 mol% dry provisional; O2 purity/crossover and KOH concentration/vendor data absent |
| Process function | Pressurised alkaline electrolyser package |

## 2. Capacity and operating cases

| Case | Capacity / flow basis | State |
|---|---|---|
| Minimum stable | H₂ 4.719 t/day (196.61 kg/h); O₂ 37.450 t/day (1,560.40 kg/h), theoretical | Draft operating-envelope case; equipment turndown not vendor-verified |
| Normal | H₂ 9.437 t/day (393.21 kg/h); O₂ 74.899 t/day (3,120.80 kg/h), theoretical | Draft reference case |
| Maximum continuous | H₂ 10.381 t/day (432.53 kg/h); O₂ 82.389 t/day (3,432.88 kg/h), theoretical | Draft screening case |
| Process design | H₂ 11.419 t/day (475.79 kg/h); O₂ 90.628 t/day (3,776.16 kg/h), theoretical | Draft process capacity; DB-011 10% margin is already embedded, do not add again |
| Upset | Renewable electricity 50% of nominal for 2 h (OP-026) | Buffer/ramp response not approved; no continuity assumption |

**Case-specific screening note:** H2 475.79 kg/h, O2 3,776.16 kg/h and DI water guidance 4.282 m3/h at design; all are theoretical/reference quantities.

## 3. Process and mechanical design conditions

| Parameter | Value / status |
|---|---|
| Normal operating temperature | Vendor map TBD |
| Normal operating pressure | 15-30 bar(a) assumed outlet range; normal 20 bar(a) |
| Outlet / local operating conditions | Vendor map TBD / 15-30 bar(a) assumed outlet range |
| Mechanical design temperature | TBD from maximum/minimum metal temperature, credible upsets, start-up/shutdown, reaction excursion and applicable code |
| Mechanical design pressure | TBD from maximum credible pressure, blocked-in, control failure, thermal expansion, compressor shutoff, relief/vent basis and code |
| Vacuum / external pressure | TBD where applicable |
| Pressure drop | TBD by hydraulic / vendor calculation |

The operating limits (including 200–300°C and 5–10 MPa(a) on the synthesis loop) are not mechanical design ratings.

## 4. Sizing method and calculated result

**Method / status:** Faraday law establishes charge flow only; stack current needs cell count/current efficiency; AC capacity needs SEC/load map

**Sizing conclusion:** Stack current, area, cell count, voltage, DC/AC power, specific electricity consumption, thermal balance, electrolyte loop and gas crossover cannot be assigned without OEM data. The Faraday charge rate is not a stack current until N_series and Faradaic efficiency are known.

No unsupported balancing, generic equipment correlation or vendor guarantee has been used. Where numerical output is not shown, the item is **not sized**, rather than zero-sized.

## 5. Materials, corrosion and fouling

| Item | Preliminary basis |
|---|---|
| Materials of construction | KOH compatibility, gas crossover, diaphragm/separator and hydrogen embrittlement review; OEM MOC TBD |
| Corrosion / erosion allowance | Electrolyte corrosion/caustic attack; no CA assigned |
| Fouling / plugging / poisoning | Electrolyte corrosion/caustic attack; no CA assigned |
| Cleaning / regeneration / maintenance | OEM electrolyte changeout, stack inspection, DI flushing and safe maintenance |
| Hydrogen compatibility | Where H2 is present, assess permeation, embrittlement, fatigue, weld procedure, sealing, leakage and pressure cycling. Grade and allowable stress are not selected. |
| Oxygen compatibility | For O2 service, conduct oxygen cleanliness, ignition and non-metallic compatibility review; no material grade is selected. |
| KOH compatibility | For electrolyte service, confirm concentration, temperature, stress-corrosion/corrosion compatibility and OEM material schedule. |

No corrosion allowance or material grade is assigned without assay, temperature, concentration, code and corrosion review.

## 6. Turndown, margin and operating flexibility

- Plant minimum stable throughput assumption: 25 t/day (50% of 50 t/day normal), pending vendor/process validation.
- Equipment-specific turndown: Plant minimum assumed 50%; ALK turndown/ramp not vendor-confirmed
- Process design capacity: 60.5 t/day is derived from 55 t/day maximum screening case × 1.10. Do not add the same 10% process margin a second time.
- Start-up/shutdown ramp and durations: vendor/catalyst SOP required.
- Bypass, standby, parallel-train and redundancy philosophy: not selected except where expressly identified in the equipment package.

## 7. Connections, instruments, utilities and safeguards

**Connections:** PFD streams S-102 / U-001 / S-111 → S-104 / S-108 / S-112; utility connections and nozzle sizes remain TBD.

**Instrumentation/control to develop:** flow, pressure, temperature, level and composition instruments as required by the equipment service; package-specific controls, alarms, trips, permissives and control-valve fail action require HAZID/HAZOP/LOPA and control philosophy.

**Relief and safeguards:** relief-device sizing, set pressure, discharge destination, blowdown/depressurisation, isolation, ESD, gas/fire detection, hazardous-area classification and safe venting remain open. No device size or SIL claim is made.

**Utilities:** Renewable electricity U-001; raw/DI water BL-W01/S-102; cooling and instrument utilities TBD.

**Footprint/layout:** no plot plan, access envelope, maintenance pull space, lifting path, hazardous-area layout, fire separation or foundation load is available. Vendor GA / 3D model and plot plan are required.

**Cleaning and maintenance access:** OEM electrolyte changeout, stack inspection, DI flushing and safe maintenance

## 8. Codes and standards to verify

ISO 22734-1:2025 (hydrogen generators using water electrolysis safety); plus applicable Indian electrical, hazardous-area and pressure package requirements.

These are candidate references only. Confirm statutory applicability, current adopted edition, site jurisdiction and owner requirements before design, procurement or construction. This datasheet does not demonstrate code compliance.

## 9. Required closure items before design release

OEM guaranteed kg H2/h, SEC, current density, cell count, voltage, efficiency, load/turndown, ramp, cooling, gas purity, crossover, electrolyte and water specs

Additional common inputs: approved G3 design basis; source and stream assays; validated Prompt 8 material balance; solved Prompt 9 duties; equipment package/vendor guarantees; mechanical design basis; relief/vent design; corrosion/materials review; HAZID/HAZOP; electrical and hazardous-area classification; site design conditions.

---
*Editable engineering datasheet. All TBD fields are intentional hold points, not zero values.*
