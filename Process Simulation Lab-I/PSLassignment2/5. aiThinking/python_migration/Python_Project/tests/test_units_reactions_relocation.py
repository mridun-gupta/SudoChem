from __future__ import annotations
import os
import shutil
import subprocess
import sys
from pathlib import Path

import numpy as np
import pytest

from energy008.units import convert
from energy008.reactions import stoichiometric_matrix
from energy008.config import package_root


def test_explicit_unit_conversions_round_trip_and_density_guard():
    assert float(convert(86_400.0, "kg_day_to_kg_s")) == pytest.approx(1.0)
    assert float(convert(1.0, "kg_s_to_kg_day")) == pytest.approx(86_400.0)
    assert float(convert(86.4, "kmol_day_to_mol_s")) == pytest.approx(1.0)
    assert float(convert(1.0, "mol_s_to_kmol_day")) == pytest.approx(86.4)
    assert float(convert(3_600.0, "kg_h_to_m3_s", density_kg_m3=1_000.0)) == pytest.approx(0.001)
    with pytest.raises(ValueError):
        convert(3_600.0, "kg_h_to_m3_s")
    with pytest.raises(ValueError):
        convert(1.0, "unit_that_does_not_exist")


def test_only_three_independent_reaction_vectors_and_signs(base_data):
    matrix, species, reaction_ids = stoichiometric_matrix(base_data)
    assert reaction_ids == ["R-01", "R-02", "E-01"]
    row = {name: i for i, name in enumerate(species)}
    col = {name: j for j, name in enumerate(reaction_ids)}
    expected = {
        ("CO2", "R-01"): -1, ("H2", "R-01"): -3,
        ("CH3OH", "R-01"): 1, ("H2O", "R-01"): 1,
        ("CO2", "R-02"): -1, ("H2", "R-02"): -1,
        ("CO", "R-02"): 1, ("H2O", "R-02"): 1,
        ("H2O", "E-01"): -2, ("H2", "E-01"): 2,
        ("O2", "E-01"): 1,
    }
    for (sp, rxn), coefficient in expected.items():
        assert matrix[row[sp], col[rxn]] == pytest.approx(coefficient)
    # No independent CO + 2H2 -> CH3OH vector is introduced.
    assert len(reaction_ids) == 3
    assert np.isfinite(matrix).all()


def test_extracted_package_discovers_data_outside_original_directory(tmp_path):
    original = package_root()
    relocated = tmp_path / "fresh_extract" / "Python"
    relocated.mkdir(parents=True)
    shutil.copytree(original / "src", relocated / "src")
    shutil.copytree(original / "data", relocated / "data")
    unrelated_cwd = tmp_path / "elsewhere"
    unrelated_cwd.mkdir()
    env = os.environ.copy()
    env["PYTHONPATH"] = str(relocated / "src")
    code = (
        "from energy008.config import package_root, load_model; "
        "d=load_model(); print(package_root()); print(d.case['case_id'])"
    )
    completed = subprocess.run(
        [sys.executable, "-c", code], cwd=unrelated_cwd, env=env,
        text=True, capture_output=True, check=True,
    )
    lines = completed.stdout.strip().splitlines()
    assert Path(lines[0]) == relocated
    assert lines[1] == "C-BIOCO2-REH2-ALK-REF-50TPD"
