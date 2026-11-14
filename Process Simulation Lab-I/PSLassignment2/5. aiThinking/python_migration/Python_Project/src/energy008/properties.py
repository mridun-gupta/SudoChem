"""Source-limited property methods; unsupported mixture models fail closed."""
from __future__ import annotations
import math
from typing import Any
from .config import ModelData
from .status import ModelResult, Status


def _mw_by_formula(data: ModelData) -> dict[str, float]:
    return {c["formula"].replace("-", ""): float(c["molecular_weight_kg_kmol"]) for c in data.properties["components"]}


def shomate_enthalpy_increment(coefficients: dict[str, Any], temperature_K: float) -> float:
    """NIST Shomate H°−H°(298.15 K), kJ/mol. Only within declared range."""
    t_min, t_max = float(coefficients["temperature_min_K"]), float(coefficients["temperature_max_K"])
    if not math.isfinite(temperature_K) or not (t_min <= temperature_K <= t_max):
        raise ValueError(f"Shomate temperature must be in [{t_min}, {t_max}] K; got {temperature_K} K.")
    t = temperature_K / 1000.0
    return (coefficients["A"] * t + coefficients["B"] * t**2 / 2.0 +
            coefficients["C"] * t**3 / 3.0 + coefficients["D"] * t**4 / 4.0 - coefficients["E"] / t)


def co2_sensible_duty_kW(data: ModelData, t1_K: float, t2_K: float) -> dict[str, float | str]:
    corr = data.properties["correlations"]["shomate_CO2_ideal_gas"]
    if not t2_K > t1_K:
        raise ValueError("CO2 Shomate heating requires T2 > T1.")
    dh_kJ_mol = shomate_enthalpy_increment(corr, t2_K) - shomate_enthalpy_increment(corr, t1_K)
    mw = _mw_by_formula(data)["CH3OH"]
    n_meoh_mol_s = (float(data.case["methanol_component_equivalent_kg_day"]) / mw) * 1000.0 / 86_400.0
    return {
        "correlation_id": corr["correlation_id"], "T1_K": float(t1_K), "T2_K": float(t2_K),
        "delta_h_kJ_mol": dh_kJ_mol, "molar_flow_mol_s": n_meoh_mol_s,
        "duty_kW": n_meoh_mol_s * dh_kJ_mol,
        "validity_K": [corr["temperature_min_K"], corr["temperature_max_K"]],
        "status": "SCREENING_ONLY", "source_id": corr["source_id"],
        "provenance_class": corr["provenance_class"],
    }


def methanol_latent_duty_kW(data: ModelData, temperature_K: float) -> dict[str, float | str]:
    corr = data.properties["correlations"]["methanol_latent_heat"]
    t_min, t_max = float(corr["temperature_min_K"]), float(corr["temperature_max_K"])
    if not math.isfinite(temperature_K) or not (t_min <= temperature_K <= t_max):
        raise ValueError(f"Methanol latent heat is valid only in [{t_min}, {t_max}] K; got {temperature_K} K.")
    tr = temperature_K / float(corr["critical_temperature_K"])
    if tr >= 1.0:
        raise ValueError("Methanol saturation temperature must be below critical temperature.")
    dh_kJ_mol = float(corr["A_kJ_mol"]) * math.exp(-float(corr["alpha"]) * tr) * (1.0 - tr) ** float(corr["beta"])
    mw = _mw_by_formula(data)["CH3OH"]
    n_meoh_mol_s = (float(data.case["methanol_component_equivalent_kg_day"]) / mw) * 1000.0 / 86_400.0
    return {
        "correlation_id": corr["correlation_id"], "T_K": float(temperature_K), "Tr": tr,
        "delta_hvap_kJ_mol": dh_kJ_mol, "molar_flow_mol_s": n_meoh_mol_s,
        "duty_kW": n_meoh_mol_s * dh_kJ_mol,
        "validity_K": [t_min, t_max], "status": "SCREENING_ONLY",
        "source_id": corr["source_id"], "provenance_class": corr["provenance_class"],
    }


def evaluate_properties(data: ModelData, property_request: str = "all_benchmark",
                        co2_t1_K: float | None = None, co2_t2_K: float | None = None,
                        methanol_temperature_K: float | None = None) -> ModelResult:
    req = property_request.lower()
    if req in {"pr78_mixture", "pr78_flash", "mixture_fugacity"}:
        return ModelResult("property_models", Status.BLOCKED,
                           value={"domain": "PR78_FULL_SYNTHESIS_MIXTURE", "value": None},
                           warnings=["PR78 mixture evaluation blocked: active binary kij matrix is incomplete. Missing kij values must not be set to zero."],
                           provenance={"source_ids": ["ENERGY008-DATA-0.1.0"]})
    if req in {"wilson", "nrtl", "methanol_water_vle", "distillation_flash"}:
        return ModelResult("property_models", Status.BLOCKED,
                           value={"domain": "METHANOL_WATER_VLE", "value": None},
                           warnings=["Methanol-water VLE blocked: no fitted and independently validated Wilson/NRTL parameter set at an approved column pressure."],
                           provenance={"source_ids": ["ENERGY008-DATA-0.1.0"]})
    if req not in {"all_benchmark", "co2_sensible", "methanol_latent", "mw_table"}:
        return ModelResult("property_models", Status.BLOCKED, value={"requested_property": property_request},
                           warnings=[f"Property request {property_request!r} is not implemented."])
    values: dict[str, Any] = {"molecular_weights_kg_kmol": _mw_by_formula(data),
                              "blocked_property_domains": data.properties.get("blocked_property_domains", [])}
    b = data.properties["benchmark_conditions"]
    try:
        if req in {"all_benchmark", "co2_sensible"}:
            values["co2_sensible"] = co2_sensible_duty_kW(
                data, float(co2_t1_K if co2_t1_K is not None else b["co2_shomate_temperature_start_K"]),
                float(co2_t2_K if co2_t2_K is not None else b["co2_shomate_temperature_end_K"]))
        if req in {"all_benchmark", "methanol_latent"}:
            values["methanol_latent"] = methanol_latent_duty_kW(
                data, float(methanol_temperature_K if methanol_temperature_K is not None else b["methanol_latent_temperature_K"]))
    except (ValueError, KeyError, TypeError) as exc:
        return ModelResult("property_models", Status.FAILED, errors=[{"code": "ENERGY008:PropertyOutOfRangeOrInvalid", "message": str(exc)}])
    return ModelResult("property_models", Status.SCREENING_ONLY, value=values,
                       warnings=["Pure-fluid reference correlations are not a complete high-pressure mixture property model.",
                                 "Pure methanol latent heat is not a methanol-water column duty."],
                       provenance={"property_data_version": data.properties.get("property_data_version"),
                                   "source_ids": ["SHOMATE-04", "DHVAP-MEOH-01", "PROP-0001", "PROP-0002", "PROP-0003"]})
