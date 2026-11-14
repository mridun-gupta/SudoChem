"""GUI-independent ENERGY-008 calculation orchestration."""
from __future__ import annotations
from typing import Any
from .config import load_model, validate_inputs, Energy008Error
from .status import ModelResult, Status
from .properties import evaluate_properties
from .balances import material_balance
from .energy import energy_balance
from .equipment import equipment_screening
from .blocked_models import entropy_exergy, utilities_model, economics, environmental_kpis, reactor_calculation, physical_recycle, control_status
from .kpis import material_kpis
from .sensitivity import throughput_sensitivity


def run_case(case_id: str | None = None, data_dir: str | None = None) -> dict[str, Any]:
    data = load_model(case_id=case_id, data_dir=data_dir)
    validation = validate_inputs(data)
    modules: dict[str, ModelResult] = {"input_validation": validation}
    if validation.status in {Status.BLOCKED, Status.FAILED}:
        for module in ("material_balance", "property_models", "energy_balance", "equipment_sizing"):
            modules[module] = ModelResult(module, Status.BLOCKED,
                                          warnings=["Upstream case/input gate is not open; no calculation attempted."])
    else:
        material = material_balance(data)
        properties = evaluate_properties(data)
        energy = energy_balance(data, material, properties)
        equipment = equipment_screening(data, material, energy)
        modules.update({
            "material_balance": material,
            "property_models": properties,
            "energy_balance": energy,
            "equipment_sizing": equipment,
        })
    modules["entropy_exergy"] = entropy_exergy(data)
    modules["utilities_model"] = utilities_model(data)
    modules["economics"] = economics(data)
    modules["environmental_kpis"] = environmental_kpis(data)
    modules["reactor_calculation"] = reactor_calculation(data)
    modules["recycle_solver"] = physical_recycle(data)
    modules["control_logic"] = control_status(data)
    if "material_balance" in modules:
        modules["material_kpis"] = material_kpis(modules["material_balance"])
    modules["sensitivity_optimisation"] = throughput_sensitivity(data) if validation.status == Status.CALCULATED else ModelResult("sensitivity_optimisation", Status.BLOCKED, warnings=["Input/case gate blocks sensitivity."])
    statuses = {name: str(result.status) for name, result in modules.items()}
    overall = "SCREENING_ONLY" if any(s in {"REFERENCE_ONLY", "SCREENING_ONLY"} for s in statuses.values()) else "BLOCKED"
    if any(s == "FAILED" for s in statuses.values()):
        overall = "FAILED"
    return {
        "project_id": "ENERGY-008",
        "project_version": "0.3.0-prompt19-engine-prompt20-gui",
        "model_version": "ENERGY008-MODEL-0.1.0",
        "property_data_version": data.properties.get("property_data_version"),
        "reaction_network_version": data.reactions.get("reaction_network_version"),
        "case": {"case_id": data.case.get("case_id"), "route_id": data.case.get("route_id"),
                 "case_status": data.case.get("case_status"),
                 "methanol_component_equivalent_kg_day": data.case.get("methanol_component_equivalent_kg_day")},
        "overall_status": overall,
        "module_status": statuses,
        "modules": modules,
        "interpretation": "Prompt 19 reference/screening migration only. This is not a validated physical plant model or operating recommendation.",
        "provenance": {"case_source_ids": data.case.get("source_ids", []),
                       "fixture_id": data.fixture.get("fixture_id"),
                       "data_root": str(data.root)},
    }
