#!/usr/bin/env python3
"""Static integrity and implementation-scope checks for ENERGY-008 Prompts 18-20.

This does not parse/execute MATLAB. MATLAB runtime remains NOT RUN if MATLAB is
not installed; use run_startup_smoke_test.m and run_prompt19_tests.m in MATLAB.
"""
from __future__ import annotations
import csv
import hashlib
import json
import re
import shutil
import sys
from pathlib import Path
from zipfile import ZipFile
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
MATLAB = ROOT / "MATLAB"
errors: list[str] = []
checks: list[str] = []

def require(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)
    else:
        checks.append(message)

# 1. Expected project structure.
required_files = [
    ".energy008-root", "README.md", "data/data_manifest.json",
    "MATLAB/project_config.json", "MATLAB/START_HERE.m", "MATLAB/main.m",
    "MATLAB/data/sensitivity_plan_v0.1.0.json",
    "MATLAB/README.md", "MATLAB/docs/Software_Architecture.md",
    "MATLAB/docs/Data_Discovery_and_Error_Handling.md", "MATLAB/docs/Model_Implementation.md",
    "MATLAB/docs/Prompt19_Handoff.md", "MATLAB/docs/Prompt20_Handoff.md",
    "MATLAB/docs/RUNTIME_TEST_STATUS.md", "MATLAB/docs/PROMPT19_BUILD_REPORT.md",
    "MATLAB/tests/run_startup_smoke_test.m", "MATLAB/tests/execute_prompt19_test_suite.m", "MATLAB/run_prompt19_tests.m",
    "MATLAB/tests/test_prompt19_reference_assertions.m", "MATLAB/tests/Prompt19_Test_Contract.md",
    "tests/check_project_static.py", "tests/check_prompt19_regression.py",
    "flowcharts/STARTUP_SEQUENCE.mmd", "flowcharts/PROMPT19_ENGINE_SEQUENCE.mmd",
]
for rel in required_files:
    require((ROOT / rel).is_file(), f"required file exists: {rel}")
required_dirs = ["MATLAB/gui", "MATLAB/data", "MATLAB/tests", "MATLAB/results", "MATLAB/docs",
                 "data/raw", "data/processed", "data/reference", "data/schemas", "flowcharts", "logs", "outputs"]
for rel in required_dirs:
    require((ROOT / rel).is_dir(), f"required directory exists: {rel}")

# 2. Config safety and versioned data manifest.
config = json.loads((MATLAB / "project_config.json").read_text(encoding="utf-8"))
manifest = json.loads((ROOT / "data/data_manifest.json").read_text(encoding="utf-8"))
require(config.get("project_id") == "ENERGY-008", "project ID")
require(config.get("project_version", "").startswith("0.3"), "Prompt 19/20 project version")
require(config.get("run_control", {}).get("calculation_engine_enabled") is False, "START_HERE remains startup-only")
require(config.get("run_control", {}).get("gui_calculation_engine_enabled") is True, "GUI engine orchestration explicitly enabled")
require(config.get("run_control", {}).get("overwrite_outputs") is False, "overwrite disabled")
require(config.get("run_control", {}).get("verify_sha256") is True, "hash checks enabled")
require(config.get("engine_policy", {}).get("reference_calculations_enabled") is True, "reference calculations enabled")
for key in ("physical_flowsheet_solver_enabled", "plant_recycle_solver_enabled", "pfr_kinetic_solver_enabled",
            "pr78_flash_enabled", "meoh_water_vle_enabled", "dynamic_control_simulation_enabled"):
    require(config.get("engine_policy", {}).get(key) is False, f"physical gate disabled: {key}")
require(config.get("project_status") == "ROUTE_C_WORKING_BASIS_G3_NOT_FROZEN", "G3 provisional status retained")
require(manifest.get("manifest_status") == "PROMPT19_EXECUTABLE_REFERENCE_ENGINE_WITH_EXPLICIT_PHYSICAL_BLOCKERS", "manifest engine status")
require(set(config["paths"]["data_roots"]) == set(manifest["discovery_policy"]["allowed_roots"]), "config/manifest allowed roots match")
require(len(manifest.get("datasets", [])) == 55, "55 project-controlled data snapshots declared")

for ds in manifest.get("datasets", []):
    rel = ds.get("explicit_path", "")
    path = Path(rel)
    if not rel or path.is_absolute() or ".." in path.parts:
        errors.append(f"unsafe or missing explicit manifest path: {ds.get('dataset_id')}")
        continue
    p = ROOT / path
    if not p.is_file():
        errors.append(f"missing manifest dataset: {ds.get('dataset_id')} {rel}")
        continue
    if p.name != ds.get("exact_filename"):
        errors.append(f"exact filename mismatch: {ds.get('dataset_id')}")
    if p.suffix.lower().lstrip(".") != str(ds.get("format", "")).lower():
        errors.append(f"format mismatch: {ds.get('dataset_id')}")
    actual = hashlib.sha256(p.read_bytes()).hexdigest()
    if actual != ds.get("expected_sha256", "").lower():
        errors.append(f"SHA-256 mismatch: {ds.get('dataset_id')} {rel}")
    try:
        p.resolve().relative_to(ROOT.resolve())
    except ValueError:
        errors.append(f"manifest path escapes project root: {ds.get('dataset_id')}")
    if not any(rel.startswith(root.rstrip("/") + "/") for root in config["paths"]["data_roots"]):
        errors.append(f"manifest path outside data roots: {ds.get('dataset_id')}")
    suffix = p.suffix.lower()
    if suffix == ".json":
        try: json.loads(p.read_text(encoding="utf-8"))
        except Exception as exc: errors.append(f"invalid JSON {rel}: {exc}")
    elif suffix == ".csv":
        try:
            with p.open("r", encoding="utf-8-sig", newline="") as fh:
                header = next(csv.reader(fh))
            if len(header) != len(set(header)): errors.append(f"duplicate CSV headers: {rel}")
            missing = [c for c in ds.get("required_columns", []) if c not in header]
            if missing: errors.append(f"CSV header contract missing {rel}: {missing}")
        except Exception as exc: errors.append(f"cannot inspect CSV {rel}: {exc}")
    elif suffix == ".xlsx":
        try:
            with ZipFile(p) as zf:
                wb = ET.fromstring(zf.read("xl/workbook.xml"))
            ns={"m":"http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
            names={e.attrib["name"] for e in wb.findall("m:sheets/m:sheet",ns)}
            missing=[s for s in ds.get("required_sheets",[]) if s not in names]
            if missing: errors.append(f"workbook sheet contract missing {rel}: {missing}")
        except Exception as exc: errors.append(f"cannot inspect XLSX {rel}: {exc}")
    elif suffix in {".drawio", ".svg"}:
        try: ET.parse(p)
        except Exception as exc: errors.append(f"invalid XML {rel}: {exc}")
    elif suffix == ".png":
        if not p.read_bytes().startswith(b"\x89PNG\r\n\x1a\n"):
            errors.append(f"invalid PNG signature: {rel}")
checks.append("all declared manifest hashes, formats and parseable schemas verified")

# 3. Required engine modules now expose implementations, not Prompt 18 stubs.
modules = ["input_validation", "property_models", "material_balance", "energy_balance", "entropy_exergy",
           "equipment_sizing", "utilities_model", "control_logic", "economics", "sensitivity_optimisation",
           "validation_checks", "reporting_plots", "environmental_kpis", "reactor_calculation",
           "recycle_solver", "pfr_integrator", "scenario_runner"]
for module in modules:
    p=MATLAB/f"{module}.m"
    if not p.is_file():
        errors.append(f"missing MATLAB module {module}.m"); continue
    text=p.read_text(encoding="utf-8")
    if not re.search(rf"^function\s+result\s*=\s*{re.escape(module)}\(modelInput,\s*request,\s*options\)", text, re.M):
        errors.append(f"module signature mismatch: {module}")
    if "ENERGY008:ImplementationPending" in text:
        errors.append(f"obsolete Prompt 18 implementation stub remains: {module}")
    if "function result" not in text:
        errors.append(f"module has no result function: {module}")
checks.append("17 calculation/engine modules use documented result contracts")
material_text=(MATLAB/"material_balance.m").read_text(encoding="utf-8")
input_text=(MATLAB/"input_validation.m").read_text(encoding="utf-8")
property_text=(MATLAB/"property_models.m").read_text(encoding="utf-8")
energy_text=(MATLAB/"energy_balance.m").read_text(encoding="utf-8")
require("stoichiometric_matrix_products_positive" in material_text and "bsxfun(@times,N" in material_text,
        "material balance calculates contributions from the versioned reaction matrix")
require("ratiosFromNetwork" in input_text and "fresh_H2_to_MeOH_molar_ratio" in input_text,
        "input validation cross-checks case ratios against loaded reaction coefficients")
require("p.benchmark_conditions" in property_text,
        "pure-property reference temperatures come from the versioned data record")
require("thermo(iR).temperature_K" in energy_text and "thermo(iR).pressure_MPa_abs" in energy_text,
        "reaction reference state is sourced from the thermochemistry register")
suite_text=(MATLAB/"tests/execute_prompt19_test_suite.m").read_text(encoding="utf-8")
require(suite_text.count("checks{end+1}")==31,
        "31 direct MATLAB test functions are declared (runtime status still separate)")

# 4. Startup and main remain relocation-safe and do not alter MATLAB user paths.
start=(MATLAB/"START_HERE.m").read_text(encoding="utf-8")
main=(MATLAB/"main.m").read_text(encoding="utf-8")
resolver=(MATLAB/"private/resolve_project_data.m").read_text(encoding="utf-8")
for label, txt in [("START_HERE",start),("main",main),("data resolver",resolver)]:
    if "pwd(" in txt: errors.append(f"{label} uses pwd() for path resolution")
    if "genpath(" in txt: errors.append(f"{label} uses prohibited genpath()")
    if "pathdef.m" in txt: errors.append(f"{label} edits pathdef.m")
require("mfilename('fullpath')" in start, "startup uses mfilename(fullpath)")
require(".energy008-root" in start and "project_config.json" in start, "startup uses marker and configuration")
require(len(re.findall(r"\baddpath\s*\(",start))==1, "startup uses one controlled addpath call")
require("run.calculation_status = 'NOT_RUN'" in main and "run.status = 'STARTUP_READY'" in main,
        "main is startup-only and never claims a calculation run")
gui_engine=(MATLAB/"gui_run_engine.m").read_text(encoding="utf-8")
require("reporting_plots(" in gui_engine and "sensitivity_optimisation(" in gui_engine,
        "GUI orchestrator delegates reporting and sensitivity to engine modules")
require("input_validation(" in gui_engine and "material_balance(" in gui_engine and "energy_balance(" in gui_engine,
        "GUI orchestrator delegates calculations to engine modules")
require("writeRunLogs" in gui_engine and "createRunId" in gui_engine, "GUI run logs and unique run IDs")
require("REFERENCE_OR_SCREENING_CALCULATIONS_COMPLETE" in gui_engine and "physical_flowsheet_validated = false" in gui_engine,
        "GUI reference run remains explicitly unvalidated")

# 5. Scenario and frozen fixture status.
fixture=json.loads((ROOT/"data/reference/ENERGY008_Benchmark_Fixture.json").read_text())
require(len(fixture.get("independent_test_cases",[]))==18, "18 Prompt 17 fixture cases retained")
require(fixture.get("blocked_values",{}) and all(v is None for v in fixture["blocked_values"].values()), "fixture blocked values remain null")
scenarios=[json.loads(p.read_text()) for p in sorted((MATLAB/"data/cases").glob("*.json"))]
require(len(scenarios)==4, "three route cases plus DB-059 disturbance declared")
require(any(s.get("route_id")=="Route B" and s.get("case_status")=="BLOCKED" for s in scenarios), "Route B remains blocked")
scenario_runner=(MATLAB/"scenario_runner.m").read_text(encoding="utf-8")
require("modelInput.case_data" in scenario_runner and "DB-059" in scenario_runner and "input_validation" in scenario_runner,
        "scenario runner validates cases, includes base and DB-059")
require("A-INDCO2" in scenario_runner or "Route A" in scenario_runner, "Route A common-core comparator")
sensitivity_plan=json.loads((MATLAB/"data/sensitivity_plan_v0.1.0.json").read_text())
require(sensitivity_plan.get("throughputs_t_day")==[45.0,50.0,55.0] and sensitivity_plan.get("units",{}).get("throughputs_t_day")=="t/day",
        "45/50/55 t/day sensitivity points are versioned with units and provenance")
require("sensitivity_plan_file" in config.get("paths",{}) and "sensitivity_plan" in (MATLAB/"load_model_inputs.m").read_text(),
        "versioned sensitivity plan is loaded from an explicit configuration path")

# 6. Fail-closed templates and reporting/test behavior.
env_template=json.loads((MATLAB/"data/environmental_basis_template.json").read_text())
require(env_template.get("inputs") and all(v is None for v in env_template["inputs"].values()),
        "environmental measurement input values remain null")
require(env_template.get("required_units") and env_template.get("required_source_map_fields"),
        "environmental input schema declares units and per-field source mapping")
cost_template=json.loads((MATLAB/"data/cost_basis_template.json").read_text())
cost_inputs=cost_template.get("inputs",{})
require(cost_inputs and all(v is None for k,v in cost_inputs.items() if k!="screening_cost_model"),
        "legacy cost basis measurement inputs remain null")
cm=cost_inputs.get("screening_cost_model",{})
require(cm.get("quote_items") is None and cm.get("annual_cost_drivers") and
        all(v is None for v in cm["annual_cost_drivers"].values()),
        "screening cost quotes and annual drivers remain null while schema is populated")
require("BLOCKED" in (MATLAB/"environmental_kpis.m").read_text() and "source_map" in (MATLAB/"environmental_kpis.m").read_text(),
        "environmental KPIs block without sourced measurements and field-level traceability")
require("BLOCKED" in (MATLAB/"economics.m").read_text() and "capital_recovery_factor" in (MATLAB/"economics.m").read_text(),
        "economics blocks without source inputs and implements cost recovery screening")
require("module_diagnostics.json" in (MATLAB/"reporting_plots.m").read_text(), "structured module diagnostics exported")
require("PROMPT21" in (MATLAB/"validation_checks.m").read_text().upper(), "Prompt 21 validation remains a separate gate")

# 7. No false MATLAB runtime success or precomputed run outputs.
runtime=(MATLAB/"docs/RUNTIME_TEST_STATUS.md").read_text(encoding="utf-8")
require("NOT RUN" in runtime, "MATLAB runtime status remains NOT RUN")
require("not installed" in runtime.lower() or "unavailable" in runtime.lower(), "runtime absence is documented")
result_files=[p for p in (MATLAB/"results").iterdir() if p.is_file()]
require(result_files==[MATLAB/"results/README.md"], "no fabricated MATLAB run exports are packaged")

# 8. Build handoff docs include the limitations and exact next step.
impl=(MATLAB/"docs/Model_Implementation.md").read_text(encoding="utf-8")
hand=(MATLAB/"docs/Prompt20_Handoff.md").read_text(encoding="utf-8")
for token in ["REFERENCE_ONLY","SCREENING_ONLY","BLOCKED","SI units","Prompt 21","S-209","PR78","DB-059"]:
    require(token.lower() in impl.lower(), f"implementation documentation covers {token}")
for token in ["Prompt 20","GUI callbacks","BLOCKED","REFERENCE_ONLY","physical flowsheet validated"]:
    require(token.lower() in hand.lower(), f"Prompt 20 handoff covers {token}")

if errors:
    print(f"Prompt 19 static integrity check: FAIL ({len(errors)} errors, {len(checks)} checks)")
    for e in errors: print("ERROR:",e)
    sys.exit(1)
print(f"Prompt 19 static integrity check: PASS ({len(checks)} checks; {len(manifest['datasets'])} hashed datasets)")
