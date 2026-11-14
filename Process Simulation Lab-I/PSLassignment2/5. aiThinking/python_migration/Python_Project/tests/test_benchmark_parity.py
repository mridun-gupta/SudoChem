from __future__ import annotations
import math
import pytest
from energy008.balances import material_balance
from energy008.properties import evaluate_properties
from energy008.energy import energy_balance
from energy008.equipment import equipment_screening
from energy008.status import Status


def _results(data):
    material = material_balance(data)
    props = evaluate_properties(data)
    energy = energy_balance(data, material, props)
    equipment = equipment_screening(data, material, energy)
    return material, props, energy, equipment


def test_base_case_matches_frozen_material_fixture(base_data, fixture):
    material, *_ = _results(base_data)
    assert material.status == Status.REFERENCE_ONLY
    expected = fixture["expected_outputs"]
    actual = material.value
    tolerances = fixture["acceptance_tolerances"]
    assert abs(actual["molar_flows_kmol_day"]["CH3OH"] - expected["methanol_kmol_day"]) <= tolerances["molar_flow_abs_kmol_day"]
    assert abs(actual["molar_flows_kmol_day"]["CO2"] - expected["co2_kmol_day"]) <= tolerances["molar_flow_abs_kmol_day"]
    assert abs(actual["molar_flows_kmol_day"]["H2"] - expected["h2_kmol_day"]) <= tolerances["molar_flow_abs_kmol_day"]
    assert abs(actual["mass_flows_kg_day"]["CO2_kg_day"] - expected["co2_kg_day"]) <= tolerances["mass_flow_abs_kg_day"]
    assert abs(actual["mass_flows_kg_day"]["H2_kg_day"] - expected["h2_kg_day"]) <= tolerances["mass_flow_abs_kg_day"]
    assert abs(actual["mass_flows_kg_day"]["electrolyser_water_kg_day"] - expected["electrolyser_water_kg_day"]) <= tolerances["mass_flow_abs_kg_day"]
    assert abs(actual["mass_flows_kg_day"]["O2_kg_day"] - expected["oxygen_kg_day"]) <= tolerances["mass_flow_abs_kg_day"]
    assert abs(actual["mass_balance"]["residual_input_minus_output_kg_day"] - expected["mass_balance_residual_kg_day"]) <= tolerances["mass_residual_abs_kg_day"]
    for element, expected_residual in expected["element_residual_kmol_atoms_day"].items():
        assert abs(actual["element_residual_kmol_atoms_day"][element] - expected_residual) <= tolerances["element_balance_abs_kmol_atoms_day"]


def test_base_case_property_and_energy_fixture_parity(base_data, fixture):
    _, props, energy, _ = _results(base_data)
    expected = fixture["expected_outputs"]
    tol = fixture["acceptance_tolerances"]
    assert abs(props.value["co2_sensible"]["duty_kW"] - expected["co2_ideal_gas_sensible_duty_kW"]) <= tol["CO2_sensible_duty_abs_kW"]
    assert abs(props.value["methanol_latent"]["duty_kW"] - expected["methanol_latent_reference_duty_kW"]) <= tol["methanol_latent_duty_abs_kW"]
    er = energy.value["reaction_reference"]
    assert abs(er["R01_rate_GJ_day"] - expected["R01_reference_heat_GJ_day"]) < 1e-9
    assert abs(er["E01_rate_GJ_day"] - expected["E01_thermoneutral_enthalpy_GJ_day"]) < 1e-9
    assert abs(er["net_rate_GJ_day"] - expected["net_reaction_enthalpy_GJ_day"]) < 1e-9
    assert abs(er["identity_residual_kJ_mol"]) <= tol["reaction_enthalpy_identity_abs_kJ_mol"]


def test_base_case_equipment_fixture_parity(base_data, fixture):
    material, props, energy, equipment = _results(base_data)
    expected = fixture["expected_outputs"]
    tol = fixture["acceptance_tolerances"]
    assert abs(equipment.value["HX_example"]["area_m2"] - expected["illustrative_exchanger_area_m2"]) <= tol["HX_area_abs_m2"]
    assert abs(equipment.value["W201_pump_example"]["shaft_power_kW"] - expected["W201_water_pump_shaft_power_kW"]) <= tol["pump_power_abs_kW"]
    assert abs(equipment.value["W201_pump_example"]["flow_with_margin_m3_h"] - expected["W201_water_pump_flow_m3_h_with_margin"]) <= 1e-6
    assert abs(equipment.value["W201_pump_example"]["power_with_margin_kW"] - expected["W201_water_pump_shaft_power_with_margin_kW"]) <= tol["pump_power_abs_kW"]
