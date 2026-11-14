"""Traceable, non-overwriting run exports using pandas and Matplotlib."""
from __future__ import annotations
import json
import os
import platform
import sys
from datetime import datetime, timezone
from pathlib import Path
from uuid import uuid4
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

from . import __version__
from .status import ModelResult


def _json_safe(value):
    if isinstance(value, ModelResult):
        return value.to_dict()
    if isinstance(value, dict): return {str(k): _json_safe(v) for k, v in value.items()}
    if isinstance(value, (list, tuple)): return [_json_safe(v) for v in value]
    if isinstance(value, pd.DataFrame): return value.to_dict(orient="records")
    if hasattr(value, "item"):
        try: return value.item()
        except (ValueError, AttributeError): pass
    return value


def export_run(run: dict, results_root: str | Path | None = None) -> Path:
    root = Path(results_root).resolve() if results_root else Path(__file__).resolve().parents[2] / "results"
    root.mkdir(parents=True, exist_ok=True)
    run_id = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ") + "_" + uuid4().hex[:8]
    out = root / run_id
    out.mkdir(exist_ok=False)
    metadata = {
        "run_id": run_id, "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "case_id": run["case"].get("case_id"), "model_version": run["model_version"],
        "data_version": run["property_data_version"], "python_version": sys.version,
        "platform": platform.platform(), "package_version": __version__,
        "assumptions": "See copied versioned case/property/reaction JSON; unknown process data remain null/blocked.",
    }
    serial = {k: _json_safe(v) for k, v in run.items() if k != "modules"}
    serial["run_metadata"] = metadata
    serial["modules"] = {k: v.to_dict() for k, v in run["modules"].items()}
    (out / "results.json").write_text(json.dumps(serial, indent=2, allow_nan=False), encoding="utf-8")
    for module_id, module in run["modules"].items():
        if not isinstance(module.value, dict):
            continue
        tables = module.value.get("tables", {})
        for table_name, table in tables.items():
            if isinstance(table, pd.DataFrame):
                table.to_csv(out / f"{module_id}_{table_name}.csv", index=False)
        for key, value in module.value.items():
            if isinstance(value, pd.DataFrame):
                value.to_csv(out / f"{module_id}_{key}.csv", index=False)
        if module_id == "equipment_sizing" and isinstance(module.value.get("datasheet_register"), pd.DataFrame):
            module.value["datasheet_register"].to_csv(out / "equipment_datasheet_register.csv", index=False)
    balance = run["modules"].get("material_balance")
    if balance and balance.value:
        flow = balance.value["tables"]["component_flows"]
        fig, ax = plt.subplots(figsize=(9, 5))
        ax.bar(flow["ComponentOrLedger"], flow["Flow_kg_day"])
        ax.set_ylabel("kg/day")
        ax.set_title("ENERGY-008 reaction-block ledger (reference/screening only)")
        ax.tick_params(axis="x", rotation=25)
        fig.tight_layout()
        fig.savefig(out / "reaction_block_ledger.png", dpi=160)
        plt.close(fig)
    log_lines = [f"run_id={run_id}", f"case_id={metadata['case_id']}",
                 f"overall_status={run['overall_status']}", f"module_status={run['module_status']}",
                 "MATLAB comparison status=NOT_RUN (MATLAB runtime unavailable in migration environment)"]
    (out / "run.log").write_text("\n".join(log_lines) + "\n", encoding="utf-8")
    return out
