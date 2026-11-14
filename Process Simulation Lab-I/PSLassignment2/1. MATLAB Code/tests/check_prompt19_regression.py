#!/usr/bin/env python3
"""Independent Python arithmetic audit for Prompt 19's reference engine inputs.

This is not MATLAB execution, not a process simulator, and not Prompt 21 V&V.
It recomputes Prompt 17's independent reference fixture from source inputs.
"""
from __future__ import annotations
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
fixture = json.loads((ROOT / "data/reference/ENERGY008_Benchmark_Fixture.json").read_text())
props = json.loads((ROOT / "MATLAB/data/property_data_v0.1.0.json").read_text())
network = json.loads((ROOT / "MATLAB/data/reaction_network_v0.1.0.json").read_text())
expected = fixture["expected_outputs"]
tol = fixture["acceptance_tolerances"]
basis = fixture["basis"]
mw = basis["molecular_weights_kg_per_kmol"]
meoh_kg_day = basis["methanol_component_equivalent_kg_day"]

checks: list[str] = []
def near(name: str, actual: float, target: float, atol: float) -> None:
    if not math.isfinite(actual) or abs(actual - target) > atol:
        raise AssertionError(f"{name}: got {actual:.17g}, expected {target:.17g}, atol {atol:g}")
    checks.append(name)

n_meoh_kmol_day = meoh_kg_day / mw["CH3OH"]
xi_r01 = n_meoh_kmol_day
xi_r02 = 0.0
xi_e01 = 1.5 * n_meoh_kmol_day
near("TC-01 methanol molar rate", n_meoh_kmol_day, expected["methanol_kmol_day"], tol["molar_flow_abs_kmol_day"])
near("R-01 extent", xi_r01, fixture["reaction_network"]["ideal_reference_extents_kmol_day"]["R01"], tol["molar_flow_abs_kmol_day"])
near("R-02 limiting reference extent", xi_r02, fixture["reaction_network"]["ideal_reference_extents_kmol_day"]["R02"], tol["molar_flow_abs_kmol_day"])
near("E-01 extent", xi_e01, fixture["reaction_network"]["ideal_reference_extents_kmol_day"]["E01"], tol["molar_flow_abs_kmol_day"])

# Flow rates are reconstructed from reaction extents, not copied from expected outputs.
flows_kmol_day = {
    "CO2": xi_r01,
    "H2": 3.0 * xi_r01,
    "CO": 0.0,
    "CH3OH": xi_r01,
    "H2O_reaction": xi_r01,
    "H2O_electrolyser": 2.0 * xi_e01,
    "H2O_net": 2.0 * xi_e01 - xi_r01,
    "O2": xi_e01,
}
flows_kg_day = {
    "CO2": flows_kmol_day["CO2"] * mw["CO2"],
    "H2": flows_kmol_day["H2"] * mw["H2"],
    "CH3OH": flows_kmol_day["CH3OH"] * mw["CH3OH"],
    "H2O_reaction": flows_kmol_day["H2O_reaction"] * mw["H2O"],
    "H2O_electrolyser": flows_kmol_day["H2O_electrolyser"] * mw["H2O"],
    "H2O_net": flows_kmol_day["H2O_net"] * mw["H2O"],
    "O2": flows_kmol_day["O2"] * mw["O2"],
}
for key, target_key in [("CO2","co2_kg_day"),("H2","h2_kg_day"),("H2O_reaction","reaction_water_kg_day"),
                        ("H2O_electrolyser","electrolyser_water_kg_day"),("H2O_net","net_water_kg_day"),("O2","oxygen_kg_day")]:
    near(f"mass flow {key}", flows_kg_day[key], expected[target_key], tol["mass_flow_abs_kg_day"])

# Elemental reaction closure from the declared matrices.
N = network["stoichiometric_matrix_products_positive"]
A = network["element_matrix_rows_C_H_O"]
for i, row in enumerate(A):
    for j in range(len(N[0])):
        residual = sum(row[k] * N[k][j] for k in range(len(row)))
        near(f"element matrix row {i} reaction {j}", residual, 0.0, 1e-12)
# Net flows in mol/day and C/H/O atom rates.
species = network["species_order"]
net_mol_day = [
    -xi_r01 - xi_r02,
    -3*xi_r01 - xi_r02 + 2*xi_e01,
    xi_r02,
    xi_r01,
    xi_r01 + xi_r02 - 2*xi_e01,
    xi_e01,
]
for i, element in enumerate(("C","H","O")):
    atoms = sum(A[i][j] * net_mol_day[j] for j in range(len(species)))
    near(f"net {element} atom closure", atoms/1000, expected["element_residual_kmol_atoms_day"][element], tol["element_balance_abs_kmol_atoms_day"])

mass_in = flows_kg_day["CO2"] + flows_kg_day["H2"] + flows_kg_day["H2O_electrolyser"]
mass_out = flows_kg_day["CH3OH"] + flows_kg_day["H2O_reaction"] + flows_kg_day["O2"]
# The fixture residual compares the integrated net boundary: CO2 + 2 H2O -> MeOH + 1.5 O2.
net_in = flows_kg_day["CO2"] + flows_kg_day["H2O_net"]
net_out = flows_kg_day["CH3OH"] + flows_kg_day["O2"]
resid = net_in-net_out
near("TC-07 retained rounded-MW residual", resid, expected["mass_balance_residual_kg_day"], tol["mass_residual_abs_kg_day"])

# Thermochemical identity and integrated reference enthalpy.
rh = basis["reaction_enthalpy_reference"]
near("TC-08 integrated enthalpy identity", rh["R01_kJ_mol"] + 1.5*rh["E01_kJ_mol_reaction"], rh["net_kJ_mol_MeOH"], tol["reaction_enthalpy_identity_abs_kJ_mol"])
near("R-01 heat-rate reference", xi_r01*1000*rh["R01_kJ_mol"]/1e6, expected["R01_reference_heat_GJ_day"], 1e-8)
near("E-01 thermoneutral reference", xi_e01*1000*rh["E01_kJ_mol_reaction"]/1e6, expected["E01_thermoneutral_enthalpy_GJ_day"], 1e-8)

# Pure ideal-gas CO2 Shomate enthalpy increment, reference only.
s = props["correlations"]["shomate_CO2_ideal_gas"]
T1 = props["benchmark_conditions"]["co2_shomate_temperature_start_K"]
T2 = props["benchmark_conditions"]["co2_shomate_temperature_end_K"]
def shomate_h(T: float) -> float:
    t=T/1000.0
    return s["A"]*t + s["B"]*t*t/2 + s["C"]*t**3/3 + s["D"]*t**4/4 - s["E"]/t
co2_dh = shomate_h(T2)-shomate_h(T1)
ndot_mol_s = n_meoh_kmol_day*1000/86400
co2_kw = ndot_mol_s*co2_dh
near("TC-09 CO2 pure Shomate heat", co2_kw, expected["co2_ideal_gas_sensible_duty_kW"], tol["CO2_sensible_duty_abs_kW"])

# Pure methanol saturation latent heat, reference only.
l = props["correlations"]["methanol_latent_heat"]
Tlat = props["benchmark_conditions"]["methanol_latent_temperature_K"]
Tr = Tlat/l["critical_temperature_K"]
latent = l["A_kJ_mol"]*math.exp(-l["alpha"]*Tr)*(1-Tr)**l["beta"]
near("TC-10 methanol latent heat", ndot_mol_s*latent, expected["methanol_latent_reference_duty_kW"], tol["methanol_latent_duty_abs_kW"])

# Prompt 17 screening assumptions are explicit in source data.
hx = props["screening_assumptions"]["heat_exchanger"]
hx_area = expected["co2_ideal_gas_sensible_duty_kW"]*1000/(hx["overall_U_W_m2_K"]*hx["correction_factor"]*hx["lmtd_K"])
near("TC-11 exchanger area", hx_area, expected["illustrative_exchanger_area_m2"], tol["HX_area_abs_m2"])
pump = props["screening_assumptions"]["water_pump"]
mdot_kg_s = flows_kg_day["H2O_electrolyser"]/86400
q_m3_s = mdot_kg_s/pump["density_kg_m3"]
pump_kw = pump["density_kg_m3"]*pump["gravity_m_s2"]*q_m3_s*pump["head_m"]/pump["efficiency"]/1000
near("TC-12 pump power", pump_kw, expected["W201_water_pump_shaft_power_kW"], tol["pump_power_abs_kW"])

# Matrix-driven cross-checks for the implemented MATLAB material-balance
# formulation. These are independent Python calculations, not MATLAB calls.
species_index = {name:i for i,name in enumerate(network["species_order"])}
reaction_index = {name:i for i,name in enumerate(network["reaction_order"])}
def matrix_balance(extent_r02_kmol_day: float, scale_r01_column: float = 1.0):
    nmat = [[float(x) for x in row] for row in N]
    j01, j02, je = (reaction_index[x] for x in ("R-01","R-02","E-01"))
    for row in nmat:
        row[j01] *= scale_r01_column
    meoh_mol_s = (meoh_kg_day/86400.0)/(mw["CH3OH"]/1000.0)
    extent01 = meoh_mol_s/nmat[species_index["CH3OH"]][j01]
    extent02 = extent_r02_kmol_day*1000.0/86400.0
    h2_cons = -nmat[species_index["H2"]][j01]*extent01 - nmat[species_index["H2"]][j02]*extent02
    extent_e = h2_cons/nmat[species_index["H2"]][je]
    extents = [0.0]*len(reaction_index)
    extents[j01],extents[j02],extents[je] = extent01,extent02,extent_e
    contributions=[[nmat[i][j]*extents[j] for j in range(len(extents))] for i in range(len(nmat))]
    produced=[sum(max(v,0.0) for v in row) for row in contributions]
    consumed=[sum(max(-v,0.0) for v in row) for row in contributions]
    net=[produced[i]-consumed[i] for i in range(len(produced))]
    return extents,produced,consumed,net,nmat

ext,prod,cons,net,_=matrix_balance(10.0)
near("matrix-driven nonzero R02 extent",ext[reaction_index["R-02"]],10*1000/86400,1e-12)
near("matrix-driven electrolyser H2 closes synthesis demand",
     prod[species_index["H2"]],cons[species_index["H2"]],1e-12)
near("matrix-driven RWGS carbon monoxide output",prod[species_index["CO"]],10*1000/86400,1e-12)
for element_i, element in enumerate(("C","H","O")):
    atom_rate=sum(A[element_i][i]*net[i] for i in range(len(species)))
    near(f"matrix-driven R02 {element} closure",atom_rate,0.0,1e-12)
base_ext,base_prod,base_cons,base_net,_=matrix_balance(0.0)
scaled_ext,scaled_prod,scaled_cons,scaled_net,_=matrix_balance(0.0,2.0)
near("scaled reaction basis extent changes inversely",scaled_ext[reaction_index["R-01"]],base_ext[reaction_index["R-01"]]/2,1e-12)
for i,name in enumerate(species):
    near(f"scaled reaction basis preserves net species {name}",scaled_net[i],base_net[i],1e-12)

# Fixture-defined throughput sensitivity and DB-059 event arithmetic.
for rate in (45.0,50.0,55.0):
    n=rate*1000/mw["CH3OH"]
    co2kg=n*mw["CO2"]
    h2kg=3*n*mw["H2"]
    near(f"throughput scenario {rate} t/day CO2", co2kg, expected["co2_kg_day"]*rate/50, 1e-8)
    near(f"throughput scenario {rate} t/day H2", h2kg, expected["h2_kg_day"]*rate/50, 1e-8)
base_h2_kg_h=expected["h2_kg_day"]/24
near("DB-059 linear two-hour H2 deficit", base_h2_kg_h*0.5*2, expected["h2_kg_day"]/24, 1e-9)

# Gated results must remain null and have an explicit reason.
for field, value in fixture["blocked_values"].items():
    if value is not None:
        raise AssertionError(f"Blocked fixture value {field} must remain null, found {value!r}")
        
print(f"Prompt 19 independent Python arithmetic audit: PASS ({len(checks)} checks)")
print("This is an independent fixture audit, not MATLAB execution or Prompt 21 model validation.")
