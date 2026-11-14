"""Prompt 17 exchanger/pump arithmetic examples; not rated equipment design."""
from __future__ import annotations
import math
import pandas as pd
from .config import ModelData
from .status import ModelResult, Status


def equipment_screening(data: ModelData, material: ModelResult, energy: ModelResult) -> ModelResult:
    if not material.value or not energy.value or "co2_sensible_heating" not in energy.value:
        return ModelResult("equipment_sizing", Status.BLOCKED, warnings=["Equipment screen requires reference energy and material results."])
    assumptions = data.properties["screening_assumptions"]
    hx, pump = assumptions["heat_exchanger"], assumptions["water_pump"]
    q_w = float(energy.value["co2_sensible_heating"]["duty_kW"]) * 1000.0
    denom = float(hx["overall_U_W_m2_K"]) * float(hx["correction_factor"]) * float(hx["lmtd_K"])
    if denom <= 0 or q_w < 0:
        return ModelResult("equipment_sizing", Status.FAILED, errors=[{"code": "ENERGY008:EquipmentInputInvalid", "message": "HX U, correction factor and LMTD must be positive; heat duty must be non-negative."}])
    area_m2 = q_w / denom
    mdot_kg_s = float(material.value["mass_flows_kg_s"]["electrolyser_water"])
    rho, head, eta, gravity = (float(pump[k]) for k in ("density_kg_m3", "head_m", "efficiency", "gravity_m_s2"))
    if rho <= 0 or head < 0 or not 0 < eta <= 1 or gravity <= 0:
        return ModelResult("equipment_sizing", Status.FAILED, errors=[{"code": "ENERGY008:PumpInputInvalid", "message": "Pump density/gravity must be positive; head non-negative; efficiency in (0,1]."}])
    qv_m3_s = mdot_kg_s / rho
    power_kw = rho * gravity * qv_m3_s * head / eta / 1000.0
    flow_margin = float(pump["flow_margin_fraction"])
    if flow_margin < 0:
        return ModelResult("equipment_sizing", Status.FAILED, errors=[{"code": "ENERGY008:PumpMarginInvalid", "message": "Pump flow margin cannot be negative."}])
    eq_rows = [{"equipment_id": e["equipment_id"], "equipment_type": e["equipment_type"],
                "service": e["service"], "data_status": e["data_status"],
                "required_inputs": "; ".join(e.get("required_inputs", []))} for e in data.equipment["equipment"]]
    values = {
        "datasheet_register": pd.DataFrame(eq_rows),
        "HX_example": {"equipment_id": "HX-A01", "heat_duty_kW": q_w / 1000.0,
                       "U_W_m2_K": hx["overall_U_W_m2_K"], "F": hx["correction_factor"],
                       "LMTD_K": hx["lmtd_K"], "area_m2": area_m2, "status": "SCREENING_ONLY",
                       "source_id": hx["source_id"]},
        "W201_pump_example": {"equipment_id": "W-201", "water_mass_flow_kg_s": mdot_kg_s,
                              "water_mass_flow_kg_h": mdot_kg_s * 3600.0, "density_kg_m3": rho,
                              "volumetric_flow_m3_s": qv_m3_s, "volumetric_flow_m3_h": qv_m3_s * 3600.0,
                              "head_m": head, "efficiency": eta, "shaft_power_kW": power_kw,
                              "flow_margin_fraction": flow_margin,
                              "flow_with_margin_m3_h": qv_m3_s * 3600.0 * (1 + flow_margin),
                              "power_with_margin_kW": power_kw * (1 + flow_margin),
                              "status": "SCREENING_ONLY", "source_id": pump["source_id"]},
        "other_major_equipment": {"status": "BLOCKED", "items": ["R-301 PFR", "K-101/K-201/K-301 compressors", "vessels/columns", "relief/mechanical design"]},
    }
    return ModelResult("equipment_sizing", Status.SCREENING_ONLY, value=values,
                       warnings=["HX-A01 and W-201 equations reproduce benchmark arithmetic only; they are not equipment ratings or vendor selections."],
                       provenance={"source_ids": [hx["source_id"], pump["source_id"]]})
