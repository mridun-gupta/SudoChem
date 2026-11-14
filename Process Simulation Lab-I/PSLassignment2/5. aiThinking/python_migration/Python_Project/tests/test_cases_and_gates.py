from __future__ import annotations
from dataclasses import replace
from copy import deepcopy
from energy008.config import load_model, validate_inputs
from energy008.balances import material_balance
from energy008.engine import run_case
from energy008.status import Status


def test_alternative_1_route_a_shared_core_matches_route_c():
    base = load_model()
    route_a = load_model("A-INDCO2-REH2-ALK-REF-50TPD")
    rc = material_balance(base)
    ra = material_balance(route_a)
    assert ra.status == Status.REFERENCE_ONLY
    for field in ("CO2_kg_day", "H2_kg_day", "CH3OH_kg_day", "electrolyser_water_kg_day"):
        assert abs(ra.value["mass_flows_kg_day"][field] - rc.value["mass_flows_kg_day"][field]) < 1e-8
    assert "industrial CO2 capture" not in str(ra.value).lower()  # not a captured-route calculation


def test_alternative_2_route_b_is_explicitly_blocked():
    run = run_case("B-BIOMASS-SYNGAS-50TPD")
    assert run["overall_status"] == "BLOCKED"
    assert run["module_status"]["input_validation"] == "BLOCKED"
    assert run["module_status"]["material_balance"] == "BLOCKED"


def test_turndown_case_is_linear_screening_only():
    data = load_model("C-BIOCO2-REH2-ALK-TURNDOWN-25TPD")
    m = material_balance(data)
    assert m.status == Status.SCREENING_ONLY
    assert abs(m.value["mass_flows_kg_day"]["CH3OH_kg_day"] - 25_000.0) < 1e-8
    base = material_balance(load_model())
    assert abs(m.value["mass_flows_kg_day"]["CO2_kg_day"] / base.value["mass_flows_kg_day"]["CO2_kg_day"] - 0.5) < 1e-12


def test_negative_and_zero_throughput_fail_validation(base_data):
    for invalid in (-1.0, 0.0, float("nan"), float("inf")):
        case = deepcopy(base_data.case)
        case["methanol_component_equivalent_kg_day"] = invalid
        m = replace(base_data, case=case)
        assert validate_inputs(m).status == Status.FAILED


def test_negative_r02_extent_fails_validation(base_data):
    case = deepcopy(base_data.case)
    case["assumptions"]["R02_extent_kmol_day"] = -0.1
    assert validate_inputs(replace(base_data, case=case)).status == Status.FAILED


def test_missing_case_data_raises_code(tmp_path):
    from energy008.config import Energy008Error
    import pytest
    with pytest.raises(Energy008Error) as exc:
        load_model(data_dir=tmp_path)
    assert exc.value.code == "ENERGY008:DataMissing"
