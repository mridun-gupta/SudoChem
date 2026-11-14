from __future__ import annotations
import json
import os
from pathlib import Path
import numpy as np
from energy008.sensitivity import throughput_sensitivity, latin_hypercube_samples
from energy008.numerics import solve_synthetic_nonlinear
from energy008.engine import run_case
from energy008.exports import export_run
from energy008.config import load_model, package_root
from energy008.status import Status


def test_throughput_sensitivity_uses_versioned_plan(base_data):
    result = throughput_sensitivity(base_data)
    assert result.status == Status.SCREENING_ONLY
    table = result.value["table"]
    assert table["throughput_t_day"].tolist() == [45.0, 50.0, 55.0]
    assert all(table["status"].isin(["REFERENCE_ONLY", "SCREENING_ONLY"]))


def test_latin_hypercube_is_reproducible_and_bounded():
    bounds = {"x": (1.0, 2.0), "y": (10.0, 20.0), "z": (-1.0, 1.0)}
    a = latin_hypercube_samples(bounds, 32, seed=123)
    b = latin_hypercube_samples(bounds, 32, seed=123)
    assert np.allclose(a.to_numpy(), b.to_numpy())
    assert a["x"].between(1, 2).all() and a["y"].between(10, 20).all() and a["z"].between(-1, 1).all()


def test_synthetic_nonlinear_solver_is_labelled():
    result = solve_synthetic_nonlinear(lambda x: np.array([x[0] ** 2 - 4.0]), [1.0])
    assert result["status"] == "CONVERGED_SYNTHETIC_ONLY"
    assert abs(result["solution"][0] - 2.0) < 1e-8
    assert "not physical" in result["applicability"].lower()


def test_package_data_discovery_does_not_depend_on_cwd(tmp_path, monkeypatch):
    before = package_root()
    monkeypatch.chdir(tmp_path)
    after = package_root()
    data = load_model()
    assert before == after
    assert data.case["case_id"] == "C-BIOCO2-REH2-ALK-REF-50TPD"


def test_exports_create_traceable_results_without_overwrite(tmp_path):
    run = run_case()
    out = export_run(run, tmp_path)
    assert out.is_dir()
    assert (out / "results.json").is_file()
    assert (out / "run.log").is_file()
    assert (out / "reaction_block_ledger.png").is_file()
    assert list(out.glob("material_balance_*.csv"))
    report = json.loads((out / "results.json").read_text(encoding="utf-8"))
    assert report["run_metadata"]["case_id"] == run["case"]["case_id"]
    assert report["run_metadata"]["model_version"] == run["model_version"]
    assert report["module_status"]["recycle_solver"] == "BLOCKED"
