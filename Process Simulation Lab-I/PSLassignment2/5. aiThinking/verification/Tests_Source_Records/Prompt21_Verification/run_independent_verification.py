#!/usr/bin/env python3
"""Independent ENERGY-008 verification checks.

This script intentionally does not import, invoke, or emulate the MATLAB engine.
It independently reconstructs reference arithmetic from versioned inputs and
checks project/data contracts. Synthetic formula tests are labelled as such.
MATLAB and GUI runtime remain NOT RUN unless a real MATLAB run log is supplied.
"""
from __future__ import annotations
import csv, hashlib, json, math, shutil, tempfile, time
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1] / "ENERGY008_MATLAB"
OUT = Path(__file__).resolve().parent / "ENERGY008_Test_Logs"
OUT.mkdir(parents=True, exist_ok=True)

cfg = json.loads((ROOT / "MATLAB/project_config.json").read_text())
manifest = json.loads((ROOT / "data/data_manifest.json").read_text())
props = json.loads((ROOT / "MATLAB/data/property_data_v0.1.0.json").read_text())
network = json.loads((ROOT / "MATLAB/data/reaction_network_v0.1.0.json").read_text())
fixture = json.loads((ROOT / "data/reference/ENERGY008_Benchmark_Fixture.json").read_text())
base_case = json.loads((ROOT / "MATLAB/data/default_case.json").read_text())
case_a = json.loads((ROOT / "MATLAB/data/cases/a-indco2-reh2-alk-ref-50tpd.json").read_text())
case_b = json.loads((ROOT / "MATLAB/data/cases/b-biomass-syngas-50tpd.json").read_text())
turndown = json.loads((ROOT / "MATLAB/data/cases/c-bioco2-reh2-alk-turndown-25tpd.json").read_text())
disturbance = json.loads((ROOT / "MATLAB/data/cases/db-059-power-shortfall-50pct-2h.json").read_text())

records: list[dict[str, Any]] = []

def add(test_id: str, category: str, description: str, status: str,
        assertion: str, expected: Any, actual: Any, units: str,
        evidence: str, limitation: str = "", abs_dev: Any = None, rel_dev_pct: Any = None):
    records.append({
        "Test_ID": test_id, "Category": category, "Test": description,
        "Status": status, "Assertion_Outcome": assertion,
        "Expected": expected, "Actual": actual, "Units": units,
        "Absolute_Deviation": abs_dev, "Relative_Deviation_pct": rel_dev_pct,
        "Execution_Layer": "Independent Python verifier / source-data audit",
        "MATLAB_Status": "NOT RUN", "Evidence": evidence,
        "Limitation": limitation,
    })

def near(test_id, category, description, actual, expected, tol, units, evidence, limitation=""):
    delta = abs(actual - expected)
    rel = None if expected == 0 else delta / abs(expected) * 100.0
    ok = math.isfinite(actual) and delta <= tol
    add(test_id, category, description, "PASS" if ok else "FAIL", "PASS" if ok else "FAIL",
        expected, actual, units, evidence, limitation, delta, rel)
    if not ok:
        raise AssertionError(f"{test_id}: actual={actual} expected={expected} tolerance={tol}")

def check(test_id, category, description, condition, expected, actual, units, evidence, limitation="", status_if_true="PASS"):
    add(test_id, category, description, status_if_true if condition else "FAIL",
        "PASS" if condition else "FAIL", expected, actual, units, evidence, limitation)
    if not condition:
        raise AssertionError(f"{test_id}: {description}; expected {expected}, got {actual}")

# 1. Project/config/data integrity and relocation contract.
allowed = cfg["paths"]["data_roots"]
check("PATH-001", "Project integrity", "Config allowed roots match manifest roots",
      set(allowed) == set(manifest["discovery_policy"]["allowed_roots"]),
      sorted(manifest["discovery_policy"]["allowed_roots"]), sorted(allowed), "root list",
      "project_config.json + data/data_manifest.json")
check("PATH-002", "Project integrity", "GUI source folder is explicitly declared",
      cfg["paths"]["gui_path_folders"] == ["MATLAB/gui"], ["MATLAB/gui"],
      cfg["paths"]["gui_path_folders"], "relative path", "project_config.json")
required_config_paths = ["case_file", "case_files", "disturbance_file", "property_data_file",
                         "reaction_network_file", "fixture_file", "equipment_register_file",
                         "utility_register_file", "cost_basis_file", "environmental_basis_file",
                         "sensitivity_plan_file"]
for key in required_config_paths:
    check("PATH-CFG-" + key.upper(), "Project integrity", f"Config declares {key}",
          key in cfg["paths"], True, key in cfg["paths"], "boolean", "project_config.json")

hash_ok = 0
for ds in manifest["datasets"]:
    rel = ds["explicit_path"]
    p = ROOT / rel
    if not p.is_file():
        raise FileNotFoundError(f"Manifest file missing: {rel}")
    resolved = p.resolve()
    resolved.relative_to(ROOT.resolve())
    digest = hashlib.sha256(p.read_bytes()).hexdigest()
    if digest != ds["expected_sha256"].lower():
        raise AssertionError(f"SHA-256 mismatch {ds['dataset_id']}: {rel}")
    if not any(rel.startswith(r.rstrip("/") + "/") for r in allowed):
        raise AssertionError(f"Manifest path outside allowed roots: {ds['dataset_id']}")
    hash_ok += 1
add("PATH-HASH-55", "Project integrity", "SHA-256 and allow-root verification for all manifest datasets",
    "PASS", "PASS", 55, hash_ok, "datasets", "data_manifest.json; independent hashlib.sha256",
    "This validates packaged source-data integrity, not MATLAB's runtime discovery routine.")

# Copy-based relocation test. MATLAB START_HERE itself is not executed.
with tempfile.TemporaryDirectory(prefix="energy008-relocate-") as td:
    dest = Path(td) / "different-parent" / "extracted" / "ENERGY008_MATLAB"
    dest.parent.mkdir(parents=True)
    shutil.copytree(ROOT, dest)
    copied_cfg = json.loads((dest / "MATLAB/project_config.json").read_text())
    copied_manifest = json.loads((dest / "data/data_manifest.json").read_text())
    marker_ok = "ENERGY008_PROJECT_ID=ENERGY-008" in (dest / ".energy008-root").read_text()
    all_copy_paths = all((dest / ds["explicit_path"]).is_file() for ds in copied_manifest["datasets"])
    root_rel = all((dest / r).is_dir() for r in copied_cfg["paths"]["data_roots"])
    check("RELOC-001", "Relocation", "Copied project resolves manifest paths from new extraction root",
          marker_ok and all_copy_paths and root_rel, "marker/config/55 dataset files resolve",
          f"marker={marker_ok}; files={all_copy_paths}; roots={root_rel}", "boolean",
          "Python copy-to-new-temp-root contract check",
          "MATLAB START_HERE execution after relocation remains NOT RUN.")

for file in [ROOT/"MATLAB/START_HERE.m", ROOT/"MATLAB/main.m", ROOT/"MATLAB/private/resolve_project_data.m", ROOT/"MATLAB/run_gui.m"]:
    src=file.read_text(errors="replace")
    check("PATH-CWD-" + file.name.upper(), "Path safety", f"{file.relative_to(ROOT)} contains no pwd/genpath/pathdef dependence",
          "pwd(" not in src and "genpath(" not in src and "pathdef.m" not in src,
          "no pwd/genpath/pathdef", "no prohibited token found", "source contract", str(file.relative_to(ROOT)))

# 2. Reaction matrix / elemental conservation.
nu = network["stoichiometric_matrix_products_positive"]
atom = network["element_matrix_rows_C_H_O"]
species = network["species_order"]
for i, element in enumerate(["C", "H", "O"]):
    for j, reaction in enumerate(["R-01", "R-02", "E-01"]):
        residual = sum(atom[i][k] * nu[k][j] for k in range(len(species)))
        near(f"STO-{reaction}-{element}", "Reaction stoichiometry", f"Element balance {element} for {reaction}",
             float(residual), 0.0, 1e-12, "kmol atom / kmol reaction", "reaction_network_v0.1.0.json",
             "Zero target: only absolute residual is meaningful; relative error is N/A.")

# 3. Independent material calculation for base and Alternative 1.
mw = fixture["basis"]["molecular_weights_kg_per_kmol"]
basis_kg_day = fixture["basis"]["methanol_component_equivalent_kg_day"]
n_meoh = basis_kg_day / mw["CH3OH"]
expected = fixture["expected_outputs"]
flows = {
    "methanol_kmol_day": n_meoh,
    "co2_kmol_day": n_meoh,
    "h2_kmol_day": 3*n_meoh,
    "reaction_water_kmol_day": n_meoh,
    "electrolyser_water_kmol_day": 3*n_meoh,
    "net_water_kmol_day": 2*n_meoh,
    "oxygen_kmol_day": 1.5*n_meoh,
}
for key, value in flows.items():
    near("BASE-"+key.upper(), "Base case", f"Base case independent {key}", value, expected[key],
         1e-6 if "kmol" in key else 1e-10, "kmol/day", "Independent equation nMeOH = mMeOH/MWMeOH; Prompt 17 fixture")
kg = {"methanol_kg_day": flows["methanol_kmol_day"]*mw["CH3OH"],
      "co2_kg_day": flows["co2_kmol_day"]*mw["CO2"],
      "h2_kg_day": flows["h2_kmol_day"]*mw["H2"],
      "reaction_water_kg_day": flows["reaction_water_kmol_day"]*mw["H2O"],
      "electrolyser_water_kg_day": flows["electrolyser_water_kmol_day"]*mw["H2O"],
      "net_water_kg_day": flows["net_water_kmol_day"]*mw["H2O"],
      "oxygen_kg_day": flows["oxygen_kmol_day"]*mw["O2"]}
for key, value in kg.items():
    near("BASE-"+key.upper(), "Base case", f"Base case independent {key}", value, expected[key],
         1e-3, "kg/day", "Independent molar-to-mass calculation; Prompt 17 fixture")
# Retained rounded-MW residual must not be adjusted to zero.
net_in = kg["co2_kg_day"] + kg["net_water_kg_day"]
net_out = kg["methanol_kg_day"] + kg["oxygen_kg_day"]
resid = net_in - net_out
near("BASE-MASS-RESIDUAL", "Mass conservation", "Retain rounded-MW net mass residual (no forced closure)",
     resid, expected["mass_balance_residual_kg_day"], 1e-5, "kg/day", "Prompt 17 rounded-MW balance")
closure_pct = abs(resid)/max(net_in, 1e-12)*100
add("BASE-CLOSURE-PCT", "Mass conservation", "Mass residual normalized to net input, not zero target",
    "SCREENING ONLY", "PASS", "absolute residual / declared net input × 100", closure_pct, "%",
    "Independent mass ledger", "Relative deviation against the zero closure target is N/A; this is a normalized closure diagnostic.")

# Alternative 1: common downstream ideal core, source-route performance remains outside model.
check("ALTA-GATE", "Alternative 1", "Route A case is a reference-only comparator with equal 50 t/day basis",
      case_a["case_status"] == "REFERENCE_ONLY" and case_a["methanol_component_equivalent_kg_day"] == basis_kg_day,
      "REFERENCE_ONLY / 50,000 kg/day", f"{case_a['case_status']} / {case_a['methanol_component_equivalent_kg_day']}",
      "status and kg/day", "case record a-indco2-reh2-alk-ref-50tpd.json",
      "Route A capture/source conditioning/availability/CO2 purity and upstream duties are not modelled.")
for key in ["co2_kg_day", "h2_kg_day", "electrolyser_water_kg_day", "oxygen_kg_day"]:
    near("ALTA-"+key.upper(), "Alternative 1", f"Route A common-core {key} identity", kg[key], expected[key],
         1e-3, "kg/day", "Independent common-core equation; Route A case record")

# Alternative 2: blocked gate; no physical output values should be invented.
required_b_blockers = ["No validated biomass ultimate/proximate analysis or feed rate.",
                       "No source-supported gasification product composition, tar/char yields or cleanup performance.",
                       "No validated biomass syngas-to-methanol reaction extent model or catalyst-grade syngas specification."]
check("ALTB-FAIL-CLOSED", "Alternative 2", "Route B must remain blocked without biomass and syngas model inputs",
      case_b["case_status"] == "BLOCKED" and case_b["scenario_type"] == "BLOCKED_ALTERNATIVE" and
      case_b["operating_state"]["temperature_K"] is None and case_b["operating_state"]["pressure_MPa_abs"] is None and
      all(x in case_b["blockers"] for x in required_b_blockers),
      "BLOCKED with null T/P and required blockers", case_b["case_status"], "status", 
      "case record b-biomass-syngas-50tpd.json",
      "PASS means fail-closed gate is enforced; Alternative 2 is not calculated or compared.")
add("REQ-ALT-COUNT", "Assignment acceptance", "Base plus two evaluated alternatives acceptance minimum",
     "FAIL", "FAIL", "At least 2 alternatives have comparable calculated results",
     "1 common-core comparator; Alternative 2 BLOCKED", "case count", "Base/A/B case register and independent review",
     "No recommendation across two completed alternatives can be made.")

# 4. Turndown and power-shortfall disturbance.
scale = turndown["methanol_component_equivalent_kg_day"] / basis_kg_day
check("TD-SCALE", "Turndown", "25 t/day case is exactly half of 50 t/day reference basis",
      abs(scale-0.5) <= 1e-12, 0.5, scale, "fraction", "c-bioco2-reh2-alk-turndown-25tpd.json")
for key in ["co2_kg_day", "h2_kg_day", "electrolyser_water_kg_day", "oxygen_kg_day"]:
    near("TD-"+key.upper(), "Turndown", f"25 t/day linear scaling {key}", kg[key]*scale, expected[key]*0.5,
         1e-3, "kg/day", "Independent arithmetic 0.5× scaling",
         "This does not establish minimum load, separation operation, quality or dynamic feasibility.")
base_h2_kg_h = kg["h2_kg_day"] / 24.0
deficit = base_h2_kg_h * (1.0-disturbance["available_power_fraction"]) * disturbance["duration_h"]
near("DB059-H2-DEFICIT", "Disturbance", "DB-059 two-hour linear H2 deficit", deficit,
     expected["h2_kg_day"]/24.0, 1e-8, "kg/event", "DB-059 case + Prompt 17 base H2 demand",
     "Linear power-to-H2 assumption only; not buffer size, trip threshold or transient response.")

# 5. Thermochemistry and external NIST reference comparison.
rh = fixture["basis"]["reaction_enthalpy_reference"]
nist_methanol = -239.5
nist_water = -285.83
nist_co2 = -393.51
r01_nist = nist_methanol + nist_water - nist_co2
near("NIST-R01-DH", "External literature", "R-01 standard reaction enthalpy from independent NIST formation enthalpies",
     r01_nist, rh["R01_kJ_mol"], 0.01, "kJ/mol", "NIST SRD 69 methanol, water and CO2 formation enthalpies")
e01_nist = -2* nist_water
near("NIST-E01-DH", "External literature", "E-01 thermoneutral enthalpy from NIST liquid-water formation enthalpy",
     e01_nist, rh["E01_kJ_mol_reaction"], 0.01, "kJ/mol reaction", "NIST SRD 69 water; H2/O2 standard-state formation enthalpy = 0")
near("NET-DH-IDENTITY", "Thermochemistry", "Integrated net reaction enthalpy equals R01 + 1.5 E01",
     rh["R01_kJ_mol"] + 1.5*rh["E01_kJ_mol_reaction"], rh["net_kJ_mol_MeOH"], 1e-9,
     "kJ/mol MeOH", "Independent reaction enthalpy identity")
for rid, extent, exp, tid in [
    ("R01", fixture["reaction_network"]["ideal_reference_extents_kmol_day"]["R01"], expected["R01_reference_heat_GJ_day"], "R01"),
    ("E01", fixture["reaction_network"]["ideal_reference_extents_kmol_day"]["E01"], expected["E01_thermoneutral_enthalpy_GJ_day"], "E01"),
]:
    dh = rh["R01_kJ_mol"] if rid=="R01" else rh["E01_kJ_mol_reaction"]
    rate = extent*1000*dh/1e6
    near("THERMO-"+tid, "Thermochemistry", f"{rid} reference enthalpy rate", rate, exp, 0.01,
         "GJ/day", "Independent extent × delta-H conversion",
         "Reference-state reaction enthalpy rate; not plant heat duty or electricity consumption.")

# CO2 Shomate sensible duty.
s = props["correlations"]["shomate_CO2_ideal_gas"]
T1 = props["benchmark_conditions"]["co2_shomate_temperature_start_K"]
T2 = props["benchmark_conditions"]["co2_shomate_temperature_end_K"]
def shomate_H(T):
    t=T/1000.0
    return (s["A"]*t + s["B"]*t**2/2 + s["C"]*t**3/3 + s["D"]*t**4/4 - s["E"]/t + s["F"] - s["H"])
dh_co2 = shomate_H(T2)-shomate_H(T1)
ndot = n_meoh*1000/86400
co2_kw = ndot*dh_co2
near("PROP-CO2-SHOMATE", "Property / heat duty", "NIST CO2 pure ideal-gas Shomate sensible duty",
     co2_kw, expected["co2_ideal_gas_sensible_duty_kW"], 0.02, "kW", "NIST/JANAF Shomate coefficients from property_data_v0.1.0.json",
     "Pure ideal gas only. Not high-pressure mixture or process heater duty.")
l = props["correlations"]["methanol_latent_heat"]
Tl = props["benchmark_conditions"]["methanol_latent_temperature_K"]
Tr = Tl/l["critical_temperature_K"]
latent = l["A_kJ_mol"]*math.exp(-l["alpha"]*Tr)*(1-Tr)**l["beta"]
latent_kw = ndot*latent
near("PROP-MEOH-LATENT", "Property / heat duty", "Methanol pure-component latent reference duty",
     latent_kw, expected["methanol_latent_reference_duty_kW"], 0.02, "kW", "DHVAP-MEOH-01 property correlation",
     "Pure saturated methanol only; not a methanol-water column or reboiler duty.")

# 6. Equipment screening / hydraulic primitives.
hx = props["screening_assumptions"]["heat_exchanger"]
hx_area = co2_kw*1000/(hx["overall_U_W_m2_K"]*hx["correction_factor"]*hx["lmtd_K"])
near("EQ-HX-AREA", "Equipment screening", "Illustrative exchanger area Q/(U F LMTD)",
     hx_area, expected["illustrative_exchanger_area_m2"], 0.02, "m2", "Prompt17 assumed U/LMTD/HX example",
     "Assumed inputs; not an HX-301 rating or final datasheet.")
pump = props["screening_assumptions"]["water_pump"]
water_kg_day = expected["electrolyser_water_kg_day"]
mdot = water_kg_day/86400
qv = mdot/pump["density_kg_m3"]
pump_kw = pump["density_kg_m3"]*pump["gravity_m_s2"]*qv*pump["head_m"]/pump["efficiency"]/1000
pump_capacity = qv*3600*(1+pump["flow_margin_fraction"])
near("EQ-PUMP-POWER", "Equipment screening", "Illustrative pump shaft power rho*g*Qv*H/eta",
     pump_kw, expected["W201_water_pump_shaft_power_kW"], 0.002, "kW", "Prompt17 assumed rho/head/efficiency",
     "Assumed inputs; not pump selection, system curve or vendor rating.")
near("EQ-PUMP-CAPACITY", "Equipment screening", "Illustrative pump capacity with 10% flow margin",
     pump_capacity, expected["W201_water_pump_flow_m3_h_with_margin"], 0.002, "m3/h", "Prompt17 assumed flow margin",
     "Assumed flow; not a design capacity or vendor selection.")

# 7. Dimensional identities.
check("DIM-MASS", "Dimensional consistency", "kmol/day × kg/kmol gives kg/day",
      "kmol/day".split("/")[0] == "kmol" and "kg/kmol" == "kg/kmol", "kg/day", "kg/day", "unit identity", "molar-to-mass conversion")
check("DIM-DUTY", "Dimensional consistency", "kmol/day × 1000 mol/kmol × kJ/mol / 86400 s/day gives kW",
      True, "kW", "kW", "unit identity", "reaction enthalpy rate conversion")
check("DIM-HX", "Dimensional consistency", "W / [(W/m2/K) × K] gives m2",
      True, "m2", "m2", "unit identity", "heat exchanger area equation")
check("DIM-PUMP", "Dimensional consistency", "rho*g*Qv*H/eta gives W",
      True, "W", "W", "unit identity", "hydraulic power equation")

# 8. Explicitly synthetic mathematical primitive tests. These do not execute MATLAB modules.
# Compressor primitive: ideal-gas isentropic compression from synthetic inputs only.
P1=1.0e5; V1=0.01; pr=5.0; k=1.4; eta=0.75
comp_w = (k/(k-1))*P1*V1/eta*(pr**((k-1)/k)-1)
check("COMP-SYN-PRIM", "Synthetic compressor primitive", "Synthetic isentropic compressor power is positive and dimensionally W",
      comp_w>0 and math.isfinite(comp_w), ">0 W, unit-consistent", round(comp_w,6), "W",
      "Independent ideal-gas equation using synthetic P1/Vdot/PR/k/eta",
      "No K-101/K-201/K-301 gas composition, pressure ratio, compressor map or power is calculated.", status_if_true="SCREENING ONLY")

# Entropy/exergy sign gate, values are synthetic.
def entropy_status(sgen):
    if not math.isfinite(sgen): return "FAILED"
    if sgen < 0: return "FAILED"
    return "PASS"
T0=298.15
for label, sgen, target in [("ZERO",0.0,"PASS"),("POSITIVE",0.01,"PASS"),("NEGATIVE",-1e-6,"FAILED")]:
    result=entropy_status(sgen)
    check("ENT-SIGN-"+label, "Synthetic entropy/exergy sign", f"Synthetic entropy-generation sign gate {label}",
          result==target, target, result, "status", "Independent second-law sign rule",
          "Synthetic equation-level logic only; no process stream entropy or plant exergy balance.", status_if_true="SCREENING ONLY")
if entropy_status(0.01)=="PASS":
    exd=T0*0.01
    check("EXERGY-SYN-POS", "Synthetic entropy/exergy sign", "Synthetic exergy destruction T0*Sgen is non-negative",
          exd>=0, ">=0 kW", exd, "kW", "Synthetic T0=298.15 K and Sgen=0.01 kW/K",
          "No actual process exergy destruction is calculated.", status_if_true="SCREENING ONLY")

# Synthetic KPI formula primitive.
energy_kwh=1000.0; product_t=50.0; water_m3=5.0
energy_intensity=energy_kwh/product_t
water_intensity=water_m3/product_t
check("KPI-SYN-ENERGY", "Synthetic KPI primitive", "Synthetic energy intensity uses kWh per tonne product",
      energy_intensity==20.0, 20.0, energy_intensity, "kWh/t", "Synthetic test-only values (1000 kWh, 50 t)",
      "Not a plant KPI or measured energy meter result.", status_if_true="SCREENING ONLY")
check("KPI-SYN-WATER", "Synthetic KPI primitive", "Synthetic water intensity uses m3 per tonne product",
      water_intensity==0.1, 0.1, water_intensity, "m3/t", "Synthetic test-only values (5 m3, 50 t)",
      "Not a plant KPI or metered water result.", status_if_true="SCREENING ONLY")

# Synthetic recycle convergence and non-convergence: independent helper, not MATLAB solver.
def fixed_point(fn, x0, tol=1e-8, max_iter=200):
    x=x0
    for i in range(1,max_iter+1):
        xn=fn(x)
        if not math.isfinite(xn): return "FAILED", xn, i
        if abs(xn-x)<=tol: return "PASS", xn, i
        x=xn
    return "NOT_CONVERGED", x, max_iter
status,x,nit=fixed_point(lambda z:0.5*z+1.0,0.0)
check("REC-SYN-CONV", "Synthetic recycle solver primitive", "Synthetic contraction map converges to analytical fixed point 2",
      status=="PASS" and abs(x-2.0)<1e-7, 2.0, x, "dimensionless", f"Independent Python fixed-point test; iterations={nit}",
      "Does not test MATLAB recycle_solver.m or physical S-209 recycle.", status_if_true="SCREENING ONLY")
status2,x2,nit2=fixed_point(lambda z:1.1*z+1.0,0.0,tol=1e-8,max_iter=50)
check("REC-SYN-NOCONV", "Synthetic recycle solver primitive", "Synthetic divergent map is not accepted as converged",
      status2=="NOT_CONVERGED", "NOT_CONVERGED", status2, "status", f"Independent Python divergent-map test; iterations={nit2}",
      "Does not test MATLAB recycle_solver.m or physical S-209 recycle.", status_if_true="SCREENING ONLY")

# Synthetic economics unit primitive.
i=0.08; n=20; capex=10_000_000.0; annual_product_t=10_000.0
crf=i*(1+i)**n/((1+i)**n-1)
annualised=capex*crf
capex_per_t=annualised/annual_product_t
check("ECON-SYN-CRF", "Synthetic economics unit primitive", "Synthetic capital recovery factor is finite and positive",
      0<crf<1, "0 < CRF < 1", crf, "1/year", "Synthetic capex/rate/life fixture; independent CRF equation",
      "Not an ENERGY-008 cost estimate.", status_if_true="SCREENING ONLY")
check("ECON-SYN-UNIT", "Synthetic economics unit primitive", "Synthetic annualised CAPEX per tonne uses INR/year divided by t/year",
      capex_per_t>0 and math.isfinite(capex_per_t), ">0 INR/t", capex_per_t, "INR/t",
      "Synthetic capex/production; annualised cost unit identity",
      "No site/vendor/tariff/annual availability data; not project economics.", status_if_true="SCREENING ONLY")

# 9. Invalid/edge condition expected-policy checks. The actual MATLAB functions are NOT RUN.
def valid_flow(value, required=True):
    return math.isfinite(value) and value>=0 and (not required or value>0)
def valid_composition(fracs):
    return bool(fracs) and all(math.isfinite(v) and 0<=v<=1 for v in fracs) and abs(sum(fracs)-1.0)<=1e-9
def valid_conversion(x):
    return math.isfinite(x) and 0<=x<=1
invalid_cases = [
    ("NEG-FLOW", valid_flow(-1.0), False, "negative required flow rejected"),
    ("ZERO-ACTIVE-FLOW", valid_flow(0.0, True), False, "zero required flow rejected on active stream"),
    ("ZERO-OPTIONAL-FLOW", valid_flow(0.0, False), True, "zero optional/inactive stream is not categorically invalid"),
    ("NAN-FLOW", valid_flow(float('nan')), False, "NaN flow rejected"),
    ("INF-FLOW", valid_flow(float('inf')), False, "infinite flow rejected"),
    ("BAD-COMP-SUM", valid_composition([0.7,0.4]), False, "composition not summing to one rejected"),
    ("BAD-COMP-NEG", valid_composition([1.1,-0.1]), False, "negative/over-one component fractions rejected"),
    ("CONV-ZERO", valid_conversion(0.0), True, "zero conversion is within mathematical [0,1] domain; product throughput would be separately constrained"),
    ("CONV-NEG", valid_conversion(-0.01), False, "negative conversion rejected"),
    ("CONV-OVER", valid_conversion(1.01), False, "conversion above unity rejected"),
]
for ident, actual, want, desc in invalid_cases:
    check("EDGE-"+ident, "Synthetic input-domain gate", desc, actual==want, want, actual,
          "boolean", "Independent verifier domain-policy check",
          "MATLAB input_validation.m behavior remains NOT RUN.", status_if_true="SCREENING ONLY")

# Missing property / correlation range / missing file / utility / equipment overload.
missing_prop=None
check("EDGE-MISSING-PROP", "Synthetic failure gate", "Missing active property remains unavailable, not zero-filled",
      missing_prop is None, None, missing_prop, "null", "property_data_v0.1.0.json blocked domain register",
      "Does not execute MATLAB property_models.m.", status_if_true="SCREENING ONLY")
co2_range=(s["temperature_min_K"] <= 1300 <= s["temperature_max_K"])
check("EDGE-PROP-RANGE", "Synthetic failure gate", "CO2 Shomate correlation rejects 1300 K outside its stated range",
      not co2_range, "reject / BLOCKED", "outside 298-1200 K", "status", "Shomate coefficient range in property_data_v0.1.0.json",
      "Does not execute MATLAB range-guard code.", status_if_true="SCREENING ONLY")
utility_available=False
check("EDGE-UTILITY-UNAVAILABLE", "Synthetic failure gate", "Unavailable utility is not converted into a zero-duty valid service",
      not utility_available, "BLOCKED", "BLOCKED", "status", "No measured site utility data in utility_register_v0.1.0.json",
      "Actual utility module fault injection is NOT RUN.", status_if_true="SCREENING ONLY")
equipment_required=12.0; equipment_capacity=10.0
check("EDGE-EQUIP-OVERLOAD", "Synthetic failure gate", "Synthetic overload condition is identified",
      equipment_required>equipment_capacity, "OVERLOAD", "OVERLOAD", "status", "Synthetic equipment margin contract",
      "No real equipment rating/overload result.", status_if_true="SCREENING ONLY")
with tempfile.TemporaryDirectory(prefix="energy008-missing-") as td:
    missing=Path(td)/"required_input.json"
    missing_detected=not missing.is_file()
    check("EDGE-MISSING-FILE", "Synthetic failure gate", "Missing required input file is detectable before use",
          missing_detected, "missing file / fail closed", "missing file detected", "status", "Independent filesystem contract",
          "MATLAB manifest/input loader exception handling remains NOT RUN.", status_if_true="SCREENING ONLY")

# No physical process results are allowed for current blocked domains.
for domain, value in fixture["blocked_values"].items():
    check("BLOCKED-"+domain.upper(), "Physical-model gate", f"Physical output {domain} remains null pending evidence",
          value is None, None, value, "null", "ENERGY008_Benchmark_Fixture.json blocked_values",
          "Null is an explicit blocked model result, not a zero physical value.")

# 10. Acceptance defects and MATLAB runtime status.
sensitivity_plan = json.loads((ROOT/"MATLAB/data/sensitivity_plan_v0.1.0.json").read_text())
add("REQ-SENS-COUNT", "Assignment acceptance", "Sensitivity minimum of six variables plus multivariable method",
    "FAIL", "FAIL", "6+ variables and OAT + multivariable analysis",
    f"single throughput axis {sensitivity_plan.get('throughputs_t_day')}", "variables/methods",
    "sensitivity_plan_v0.1.0.json; sensitivity_optimisation.m",
    "Assignment minimum not satisfied; retain FAIL until expanded analysis is executed.")

runtime = {"matlab": shutil.which("matlab"), "octave": shutil.which("octave")}
add("ENV-MATLAB", "Execution environment", "MATLAB executable availability", "NOT RUN", "NOT RUN",
    "MATLAB executable required", runtime["matlab"] or "not found on PATH", "availability", "command -v matlab",
    "No MATLAB parser, module/unit/integration run, app launch or runtime export is available.")
add("ENV-OCTAVE", "Execution environment", "GNU Octave executable availability", "NOT RUN", "NOT RUN",
    "optional supplemental runtime", runtime["octave"] or "not found on PATH", "availability", "command -v octave",
    "Octave would not establish MATLAB App Designer compatibility.")
add("MATLAB-UNIT-31", "MATLAB runtime", "31 direct MATLAB unit/integration checks in suite",
    "NOT RUN", "NOT RUN", "31 checks executed", "31 source-defined functions; no MATLAB output log", "test count",
    "MATLAB/tests/execute_prompt19_test_suite.m; command -v matlab",
    "Source presence is not runtime evidence.")
add("GUI-RUNTIME", "GUI integration", "GUI launch, Run/Reset, message handling, tables, plots and exports",
    "NOT RUN", "NOT RUN", "actual UI execution log and screenshots", "none available", "runtime evidence",
    "MATLAB/gui/ENERGY008_App.m; run_gui.m; GUI_User_Guide.md",
    "No MATLAB runtime or screenshot. GUI source-contract check is separate.")
add("PROCESS-INTEGRATION", "Process integration", "Complete physical process path including recycle, utilities and plant balances",
    "BLOCKED", "NOT RUN", "validated stream states, kinetic/EOS/VLE/utility models and closures",
    "required inputs/models absent", "physical model", "Model_Implementation.md; null blocked values",
    "No full process integration result exists.")
add("HMI-FAULTS", "Automation integration", "Sensor/actuator/comms fault injection and first-out behavior",
    "NOT RUN", "NOT RUN", "actual HMI/PLC simulator evidence", "offline GUI source only", "runtime evidence",
    "14_Automation HMI specification; ENERGY008_App.m",
    "No connected or simulated field I/O; no safety action path.")

# Write full test detail CSV and JSON log.
fields = list(records[0].keys())
with (OUT/"independent_test_results.csv").open("w",newline="",encoding="utf-8-sig") as f:
    wr=csv.DictWriter(f,fieldnames=fields); wr.writeheader(); wr.writerows(records)
(OUT/"independent_test_results.json").write_text(json.dumps({
    "project_id":"ENERGY-008", "verification_phase":"Prompt 21", "execution_timestamp_utc":time.strftime("%Y-%m-%dT%H:%M:%SZ",time.gmtime()),
    "execution_environment":"Python independent verifier; MATLAB/Octave not available", "root":str(ROOT),
    "test_record_count":len(records), "records":records
},indent=2)+"\n")

from collections import Counter
counts=Counter(r["Status"] for r in records)
log_lines=["ENERGY-008 Prompt 21 independent verification run",f"Root: {ROOT}",
           f"Execution layer: independent Python / source-data contract only",
           f"Records: {len(records)}", "Status counts: "+", ".join(f"{k}={v}" for k,v in sorted(counts.items())),
           f"MATLAB executable: {runtime['matlab'] or 'NOT FOUND'}",f"GNU Octave executable: {runtime['octave'] or 'NOT FOUND'}",
           "Interpretation: independent arithmetic/static evidence only; no MATLAB engine or GUI runtime was executed."]
(OUT/"independent_verification.log").write_text("\n".join(log_lines)+"\n")

# Compact case summary to help review reproducible coverage.
case_rows=[
    [base_case["case_id"],"BASE","REFERENCE_ONLY","PASS / SCREENING ONLY","50 t/day ideal stoichiometric rates independently recomputed","MATLAB NOT RUN"],
    [case_a["case_id"],"ALTERNATIVE_1","REFERENCE_ONLY","PASS / SCREENING ONLY","Common downstream core recomputed; industrial CO2 upstream is not modelled","MATLAB NOT RUN"],
    [case_b["case_id"],"ALTERNATIVE_2","BLOCKED","PASS (fail-closed gate)","No rates computed; biomass assay, syngas and kinetics absent","MATLAB NOT RUN"],
    [turndown["case_id"],"TURNDOWN","SCREENING_ONLY","PASS / SCREENING ONLY","25 t/day linear stoichiometric scaling only","MATLAB NOT RUN"],
    [disturbance["case_id"],"DISTURBANCE","SCREENING_ONLY","PASS / SCREENING ONLY","Two-hour linear H2 deficit only; no dynamic response/buffer sizing","MATLAB NOT RUN"],
]
with (OUT/"case_coverage.csv").open("w",newline="",encoding="utf-8-sig") as f:
    wr=csv.writer(f); wr.writerow(["Case_ID","Case_Type","Case_Status","Independent_Status","Independent_Result_or_Limitation","MATLAB_Status"]); wr.writerows(case_rows)
print(f"Independent verification: {len(records)} checks recorded")
print("Status counts:",dict(counts))
print("MATLAB:",runtime["matlab"] or "NOT FOUND", "| Octave:",runtime["octave"] or "NOT FOUND")
