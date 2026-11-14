"""Command-line entry point."""
from __future__ import annotations
import argparse
import json
from .engine import run_case
from .exports import export_run


def main() -> int:
    parser = argparse.ArgumentParser(description="Run ENERGY-008 reference/screening case (not a physical flowsheet).")
    parser.add_argument("--case-id", default=None, help="Controlled case ID; omit for default Route C reference.")
    parser.add_argument("--data-dir", default=None, help="Optional explicit package data directory.")
    parser.add_argument("--results-dir", default=None, help="Optional explicit results directory.")
    args = parser.parse_args()
    run = run_case(case_id=args.case_id, data_dir=args.data_dir)
    out = export_run(run, results_root=args.results_dir)
    print(json.dumps({"case": run["case"], "overall_status": run["overall_status"],
                      "module_status": run["module_status"], "export_directory": str(out)}, indent=2))
    return 0 if run["overall_status"] != "FAILED" else 2

if __name__ == "__main__":
    raise SystemExit(main())
