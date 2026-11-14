"""Controlled, package-relative loading of ENERGY-008 configuration and data."""
from __future__ import annotations
import hashlib
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .status import ModelResult, Status


class Energy008Error(Exception):
    """Base exception carrying a stable ENERGY-008 failure code."""
    def __init__(self, code: str, message: str):
        super().__init__(message)
        self.code = code
        self.message = message


@dataclass(frozen=True, slots=True)
class ModelData:
    root: Path
    case: dict[str, Any]
    properties: dict[str, Any]
    reactions: dict[str, Any]
    fixture: dict[str, Any]
    equipment: dict[str, Any]
    utilities: dict[str, Any]
    cost_basis: dict[str, Any]
    environmental_basis: dict[str, Any]
    sensitivity_plan: dict[str, Any]


def package_root() -> Path:
    """Return the Python project root without consulting the process CWD."""
    return Path(__file__).resolve().parents[2]


def _read_json(path: Path) -> dict[str, Any]:
    if not path.is_file():
        raise Energy008Error("ENERGY008:DataMissing", f"Required JSON data file not found: {path}")
    try:
        with path.open("r", encoding="utf-8") as f:
            value = json.load(f)
    except (OSError, json.JSONDecodeError) as exc:
        raise Energy008Error("ENERGY008:DataParseFailure", f"Unable to read {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise Energy008Error("ENERGY008:SchemaInvalid", f"Expected JSON object at {path}")
    return value


def sha256_file(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as f:
        for block in iter(lambda: f.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def load_model(case_id: str | None = None, data_dir: str | Path | None = None) -> ModelData:
    root = Path(data_dir).resolve() if data_dir is not None else package_root() / "data"
    if not root.is_dir():
        raise Energy008Error("ENERGY008:DataRootMissing", f"Data root does not exist: {root}")
    case = _read_json(root / "default_case.json")
    if case_id:
        matches = []
        for path in sorted((root / "cases").glob("*.json")):
            candidate = _read_json(path)
            if candidate.get("case_id") == case_id:
                matches.append(candidate)
        if case.get("case_id") == case_id:
            matches.append(case)
        if len(matches) == 0:
            raise Energy008Error("ENERGY008:CaseMissing", f"Case ID not found in controlled package data: {case_id}")
        if len(matches) > 1:
            raise Energy008Error("ENERGY008:CaseAmbiguous", f"Multiple case records found for case ID: {case_id}")
        case = matches[0]
    return ModelData(
        root=root,
        case=case,
        properties=_read_json(root / "property_data_v0.1.0.json"),
        reactions=_read_json(root / "reaction_network_v0.1.0.json"),
        fixture=_read_json(root / "ENERGY008_Benchmark_Fixture.json"),
        equipment=_read_json(root / "equipment_register_v0.1.0.json"),
        utilities=_read_json(root / "utility_register_v0.1.0.json"),
        cost_basis=_read_json(root / "cost_basis_template.json"),
        environmental_basis=_read_json(root / "environmental_basis_template.json"),
        sensitivity_plan=_read_json(root / "sensitivity_plan_v0.1.0.json"),
    )


def validate_inputs(data: ModelData) -> ModelResult:
    c = data.case
    required_case = (
        "case_id", "route_id", "case_status", "methanol_component_equivalent_kg_day",
        "assumptions", "units", "source_ids", "provenance_class",
    )
    missing = [name for name in required_case if name not in c]
    if missing:
        return ModelResult("input_validation", Status.FAILED,
                           errors=[{"code": "ENERGY008:CaseFieldMissing", "message": f"Missing case fields: {missing}"}])
    flow = c["methanol_component_equivalent_kg_day"]
    if not isinstance(flow, (int, float)) or not (flow > 0):
        return ModelResult("input_validation", Status.FAILED,
                           errors=[{"code": "ENERGY008:InvalidThroughput", "message": "Methanol basis must be finite and positive kg/day."}])
    if not isinstance(flow, (int, float)) or not __import__("math").isfinite(flow):
        return ModelResult("input_validation", Status.FAILED,
                           errors=[{"code": "ENERGY008:InvalidThroughput", "message": "Methanol basis must be finite and positive kg/day."}])
    if c.get("case_status") == "BLOCKED":
        return ModelResult("input_validation", Status.BLOCKED,
                           value={"case_id": c["case_id"], "blockers": c.get("blockers", [])},
                           warnings=["Case is marked BLOCKED in the versioned source case; no physical calculation is attempted."],
                           provenance={"source_ids": c.get("source_ids", [])})
    assumptions = c.get("assumptions", {})
    r02 = assumptions.get("R02_extent_kmol_day")
    if not isinstance(r02, (int, float)) or not __import__("math").isfinite(r02) or r02 < 0:
        return ModelResult("input_validation", Status.FAILED,
                           errors=[{"code": "ENERGY008:InvalidReactionExtent", "message": "R-02 extent must be finite and non-negative kmol/day."}])
    if assumptions.get("R02_extent_status") != "REFERENCE_BLOCK_ASSUMPTION_ONLY":
        return ModelResult("input_validation", Status.FAILED,
                           errors=[{"code": "ENERGY008:ReactionAssumptionProvenanceMissing", "message": "R-02 extent must retain reference-only provenance."}])
    n = data.reactions.get("stoichiometric_matrix_products_positive", [])
    species = data.reactions.get("species_order", [])
    reactions = data.reactions.get("reaction_order", [])
    if len(n) != len(species) or any(len(row) != len(reactions) for row in n):
        return ModelResult("input_validation", Status.FAILED,
                           errors=[{"code": "ENERGY008:StoichiometryShape", "message": "Stoichiometric matrix dimensions do not match species and reaction order."}])
    if c.get("route_id") not in ("Route A", "Route C"):
        return ModelResult("input_validation", Status.BLOCKED,
                           value={"case_id": c["case_id"], "blockers": c.get("blockers", ["Unsupported route model."])},
                           warnings=["No independently validated route-specific reaction network is available."])
    if c.get("scenario_type") not in ("STOICHIOMETRIC_REFERENCE", "TURNDOWN_SCREENING"):
        return ModelResult("input_validation", Status.BLOCKED, value={"case_id": c["case_id"]},
                           warnings=["Scenario type is outside the implemented reference model boundary."])
    return ModelResult("input_validation", Status.CALCULATED,
                       value={"case_id": c["case_id"], "schema_id": c.get("schema_id")},
                       provenance={"source_ids": c.get("source_ids", []), "provenance_class": c.get("provenance_class")})
