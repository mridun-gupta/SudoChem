# Equipment datasheet: R-301

**Package:** ENERGY-008 Prompt 11  
**Revision:** 0.1-DRAFT  
**Design status:** BLOCKED - REACTOR SIZE NOT CALCULATED  
**Equipment:** Methanol synthesis packed-bed reactor

## 1. Service and connections

| Field | Basis |
|---|---|
| Tag / service | R-301 / Catalytic CO2 hydrogenation and RWGS |
| Control volume | CV-300 |
| PFD inlet stream(s) | S-202 |
| PFD outlet stream(s) | S-203 |
| Phase | Gas; reactor phase model pseudo-homogeneous |
| Composition / quality | CO2/H2/CO/MeOH/H2O/inerts; catalyst formulation and finite kinetics not approved |
| Process function | Methanol synthesis packed-bed reactor |

## 2. Capacity and operating cases

| Case | Capacity / flow basis | State |
|---|---|---|
| Minimum stable | Fresh CO₂ + H₂ component lower bound ~1,627 kg/h; reactor loop flow higher/unknown due recycle | Draft operating-envelope case; equipment turndown not vendor-verified |
| Normal | Fresh CO₂ + H₂ component lower bound ~3,255 kg/h; reactor loop flow higher/unknown due recycle | Draft reference case |
| Maximum continuous | Fresh CO₂ + H₂ component lower bound ~3,580 kg/h; reactor loop flow higher/unknown due recycle | Draft screening case |
| Process design | Fresh CO₂ + H₂ component lower bound ~3,938 kg/h; reactor loop flow higher/unknown due recycle | Draft process capacity; DB-011 10% margin is already embedded, do not add again |
| Upset | Renewable electricity 50% of nominal for 2 h (OP-026) | Buffer/ramp response not approved; no continuity assumption |

**Case-specific screening note:** Fresh feed component lower-bound is approximately 3,938 kg/h at design; recycle and reactor conversion are unknown.

## 3. Process and mechanical design conditions

| Parameter | Value / status |
|---|---|
| Normal operating temperature | 250°C normal; 200–300°C screening range |
| Normal operating pressure | 7 MPa(a) normal; 5–10 MPa(a) envelope |
| Outlet / local operating conditions | 250°C nominal target; reactor profile unknown / 7 MPa(a) operating target; mechanical design P TBD |
| Mechanical design temperature | TBD from maximum/minimum metal temperature, credible upsets, start-up/shutdown, reaction excursion and applicable code |
| Mechanical design pressure | TBD from maximum credible pressure, blocked-in, control failure, thermal expansion, compressor shutoff, relief/vent basis and code |
| Vacuum / external pressure | TBD where applicable |
| Pressure drop | TBD by hydraulic / vendor calculation |

The operating limits (including 200–300°C and 5–10 MPa(a) on the synthesis loop) are not mechanical design ratings.

## 4. Sizing method and calculated result

**Method / status:** Packed-bed PFR selected as model form; catalyst mass/volume/diameter/length cannot be solved without validated kinetics, catalyst properties, ΔP and heat removal

**Sizing conclusion:** No catalyst mass, reactor volume, diameter, length, bed height or residence time can be calculated. The Prompt 6 packed-bed pseudo-homogeneous non-isothermal PFR is a model architecture, not a physical design. Kinetic coefficients are not authorised until catalyst match and data validation.

No unsupported balancing, generic equipment correlation or vendor guarantee has been used. Where numerical output is not shown, the item is **not sized**, rather than zero-sized.

## 5. Materials, corrosion and fouling

| Item | Preliminary basis |
|---|---|
| Materials of construction | Catalyst support, hydrogen, CO/CO2/H2O/high-T pressure compatibility; metallurgy grade TBD |
| Corrosion / erosion allowance | Corrosion/erosion/catalyst attrition and thermal cycling; allowances TBD |
| Fouling / plugging / poisoning | Corrosion/erosion/catalyst attrition and thermal cycling; allowances TBD |
| Cleaning / regeneration / maintenance | Catalyst loading/unloading, screening and replacement SOP/vendor requirements |
| Hydrogen compatibility | Where H2 is present, assess permeation, embrittlement, fatigue, weld procedure, sealing, leakage and pressure cycling. Grade and allowable stress are not selected. |
| Oxygen compatibility | For O2 service, conduct oxygen cleanliness, ignition and non-metallic compatibility review; no material grade is selected. |
| KOH compatibility | For electrolyte service, confirm concentration, temperature, stress-corrosion/corrosion compatibility and OEM material schedule. |

No corrosion allowance or material grade is assigned without assay, temperature, concentration, code and corrosion review.

## 6. Turndown, margin and operating flexibility

- Plant minimum stable throughput assumption: 25 t/day (50% of 50 t/day normal), pending vendor/process validation.
- Equipment-specific turndown: Thermal and pressure stability through 50% minimum only assumed at plant level; reactor turn-down unvalidated
- Process design capacity: 60.5 t/day is derived from 55 t/day maximum screening case × 1.10. Do not add the same 10% process margin a second time.
- Start-up/shutdown ramp and durations: vendor/catalyst SOP required.
- Bypass, standby, parallel-train and redundancy philosophy: not selected except where expressly identified in the equipment package.

## 7. Connections, instruments, utilities and safeguards

**Connections:** PFD streams S-202 → S-203; utility connections and nozzle sizes remain TBD.

**Instrumentation/control to develop:** flow, pressure, temperature, level and composition instruments as required by the equipment service; package-specific controls, alarms, trips, permissives and control-valve fail action require HAZID/HAZOP/LOPA and control philosophy.

**Relief and safeguards:** relief-device sizing, set pressure, discharge destination, blowdown/depressurisation, isolation, ESD, gas/fire detection, hazardous-area classification and safe venting remain open. No device size or SIL claim is made.

**Utilities:** Electricity for auxiliaries, cooling/heat-removal utility TBD; inerting nitrogen U-006 where approved.

**Footprint/layout:** no plot plan, access envelope, maintenance pull space, lifting path, hazardous-area layout, fire separation or foundation load is available. Vendor GA / 3D model and plot plan are required.

**Cleaning and maintenance access:** Catalyst loading/unloading, screening and replacement SOP/vendor requirements

## 8. Codes and standards to verify

ASME B31.3:2024 for applicable process piping; equipment construction code to be selected by service/type and jurisdiction. No code compliance is claimed.

These are candidate references only. Confirm statutory applicability, current adopted edition, site jurisdiction and owner requirements before design, procurement or construction. This datasheet does not demonstrate code compliance.

## 9. Required closure items before design release

Catalyst grade, kinetics, bed density/voidage, pellet size, allowable ΔP, thermal arrangement, coolant/boiling system, reactor duty, mechanical P/T and relief basis

Additional common inputs: approved G3 design basis; source and stream assays; validated Prompt 8 material balance; solved Prompt 9 duties; equipment package/vendor guarantees; mechanical design basis; relief/vent design; corrosion/materials review; HAZID/HAZOP; electrical and hazardous-area classification; site design conditions.

---
*Editable engineering datasheet. All TBD fields are intentional hold points, not zero values.*
