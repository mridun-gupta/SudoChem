from __future__ import annotations
from energy008.properties import evaluate_properties
from energy008.blocked_models import entropy_exergy, physical_recycle, reactor_calculation, economics
from energy008.economics import capital_recovery_factor
from energy008.status import Status


def test_shomate_range_is_enforced(base_data):
    result = evaluate_properties(base_data, co2_t1_K=298.15, co2_t2_K=1201.0)
    assert result.status == Status.FAILED
    assert result.errors[0]["code"] == "ENERGY008:PropertyOutOfRangeOrInvalid"


def test_methanol_latent_range_is_enforced(base_data):
    result = evaluate_properties(base_data, methanol_temperature_K=477.1)
    assert result.status == Status.FAILED


def test_pr78_and_meoh_water_vle_are_blocked(base_data):
    assert evaluate_properties(base_data, "pr78_mixture").status == Status.BLOCKED
    assert evaluate_properties(base_data, "methanol_water_vle").status == Status.BLOCKED


def test_physical_recycle_reactor_economics_and_exergy_remain_blocked(base_data):
    assert physical_recycle(base_data).value["physical_recycle_status"] == "BLOCKED_NOT_COMPUTED"
    assert reactor_calculation(base_data).status == Status.BLOCKED
    assert economics(base_data).value["LCOM_INR_per_t"] is None
    ex = entropy_exergy(base_data)
    assert ex.status == Status.BLOCKED
    assert ex.value["plant_entropy_generation"]["value"] is None


def test_entropy_sign_check_is_not_silently_clipped():
    # Negative Sgen is retained as a diagnostic failure in this engineering gate.
    from energy008.validation import validate_entropy_generation
    result = validate_entropy_generation(-0.01)
    assert result.status == Status.FAILED
    assert result.value["entropy_generation_kW_K"] == -0.01


def test_capital_recovery_factor_dimensions_and_zero_rate():
    assert capital_recovery_factor(0.0, 20) == 0.05
    crf = capital_recovery_factor(0.08, 20)
    assert 0.09 < crf < 0.11
