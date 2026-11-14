#!/usr/bin/env python3
"""Prompt 20 GUI source-contract check (not MATLAB execution or syntax validation)."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MATLAB = ROOT / "MATLAB"
APP = MATLAB / "gui" / "ENERGY008_App.m"
LAUNCHER = MATLAB / "run_gui.m"
ORCHESTRATOR = MATLAB / "gui_run_engine.m"
GUIDE = MATLAB / "docs" / "GUI_User_Guide.md"
HANDOFF = MATLAB / "docs" / "Prompt21_GUI_Handoff.md"
CONFIG = MATLAB / "project_config.json"

required = [APP, LAUNCHER, ORCHESTRATOR, GUIDE, HANDOFF]
missing = [str(p.relative_to(ROOT)) for p in required if not p.is_file()]
if missing:
    raise SystemExit(f"FAIL: missing GUI deliverables: {missing}")

app = APP.read_text(encoding="utf-8")
launcher = LAUNCHER.read_text(encoding="utf-8")
engine = ORCHESTRATOR.read_text(encoding="utf-8")
guide = GUIDE.read_text(encoding="utf-8")
handoff = HANDOFF.read_text(encoding="utf-8")
config = json.loads(CONFIG.read_text(encoding="utf-8"))

checks: list[str] = []
def require(condition: bool, name: str) -> None:
    if not condition:
        raise AssertionError(name)
    checks.append(name)

# All required tab pages are declared in the programmatic UI.
tabs = [
    "Design Basis", "Streams", "Operating Conditions", "Process Model", "Balances",
    "Equipment", "Utilities & Environment", "Economics", "Automation & Control",
    "Sensitivity & Optimisation", "Reports",
]
for title in tabs:
    require(f"Title','{title}'" in app or f"Title', '{title}'" in app, f"tab:{title}")

# UI layer routes runs through one orchestrator, not individual calculation modules.
for control in ["Run / Calculate", "Reset defaults", "Export run", "User guide"]:
    require(control in app, f"control:{control}")
require("gui_run_engine(app.ProjectRoot" in app, "single-engine-orchestration-call")
for module in [
    "input_validation", "property_models", "material_balance", "energy_balance",
    "entropy_exergy", "reactor_calculation", "recycle_solver", "equipment_sizing",
    "utilities_model", "control_logic", "environmental_kpis", "economics",
    "scenario_runner", "sensitivity_optimisation", "validation_checks", "reporting_plots",
]:
    require(f"{module}(" in engine, f"engine-module:{module}")
for forbidden in [
    "material_balance(", "energy_balance(", "property_models(", "equipment_sizing(",
    "utilities_model(", "economics(", "sensitivity_optimisation(", "validation_checks(",
]:
    require(forbidden not in app, f"no-calculation-module-in-ui:{forbidden}")

# Launcher path policy and run traceability / non-overwrite controls.
require("pwd(" not in launcher and "genpath(" not in launcher, "root-resolution-not-cwd-or-genpath")
require("runtime_path_folders" in launcher and "gui_path_folders" in launcher, "explicit-path-policy")
require(config["paths"].get("gui_path_folders") == ["MATLAB/gui"], "config-gui-path-policy")
for token in ["run_id", "timestamp_local", "model_version", "data_version", "design_basis_version",
              "source_hashes", "assumptions", "run_directory", "report_directory"]:
    require(token in engine, f"traceability:{token}")
require("Refusing to reuse an existing run directory" in engine, "unique-run-folder-no-overwrite")
require("Refusing to overwrite" in engine, "no-overwrite-export-files")
require("SHA256_VERIFIED" in engine and "resolve_project_data" in engine, "manifest-and-hash-preflight")

# Fail/blocked states, provenance labels, and explicit HMI/protection boundary.
for token in ["RUN_FAILED", "BLOCKED_SELECTED_CASE", "REFERENCE_ONLY", "SCREENING_ONLY", "BLOCKED"]:
    require(token in app or token in engine, f"status:{token}")
for token in ["SOURCED", "CALCULATED", "FITTED", "ASSUMED", "ESTIMATED", "UNCERTAINTY"]:
    require(token in app, f"provenance:{token}")
for token in ["DCS", "PLC", "SIS", "FGS", "No start, stop, reset, bypass"]:
    require(token in app, f"hmi-boundary:{token}")
require("DiagnosticsText" in app and "WARNINGS" in app and "ERRORS" in app, "visible-run-diagnostics")
require("MATLAB_RUNTIME_EXECUTED_AT_REPORT_GENERATION" in (MATLAB / "reporting_plots.m").read_text(),
        "runtime-metadata-label-corrected")

# Documented runtime status and Prompt 21 verification procedure.
for token in ["No MATLAB runtime test", "1366x768", "missing", "Repeated runs", "screenshots"]:
    require(token.lower() in guide.lower(), f"guide-test-procedure:{token}")
require("no matlab runtime test" in guide.lower(), "guide-does-not-claim-runtime-evidence")
require("unexecuted" in handoff.lower() or "unverified" in handoff.lower(), "handoff-states-runtime-limit")

print(f"Prompt 20 GUI static source-contract check: PASS ({len(checks)} checks)")
print("This is a file/source-contract check only. It does not parse MATLAB, launch the GUI, or execute engine modules.")
