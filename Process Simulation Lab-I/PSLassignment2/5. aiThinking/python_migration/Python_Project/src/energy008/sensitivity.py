"""Ported throughput screening and generic DOE sampling helpers."""
from __future__ import annotations
from copy import deepcopy
from dataclasses import replace
import numpy as np
import pandas as pd
from scipy.stats import qmc
from .config import ModelData
from .balances import material_balance
from .status import ModelResult, Status


def throughput_sensitivity(data: ModelData) -> ModelResult:
    plan = data.sensitivity_plan
    values_t_day = [float(x) for x in plan["throughputs_t_day"]]
    base_t_day = float(data.case["methanol_component_equivalent_kg_day"]) / 1000.0
    r02_base = float(data.case["assumptions"]["R02_extent_kmol_day"])
    rows = []
    for t_day in values_t_day:
        case = deepcopy(data.case)
        case["methanol_component_equivalent_kg_day"] = t_day * 1000.0
        case["assumptions"]["R02_extent_kmol_day"] = r02_base * (t_day / base_t_day)
        case["case_id"] = f"{data.case['case_id']}::THROUGHPUT::{t_day:g}TPD"
        scenario = replace(data, case=case)
        result = material_balance(scenario)
        if result.status in {Status.BLOCKED, Status.FAILED, Status.NOT_RUN} or not result.value:
            rows.append({"throughput_t_day": t_day, "status": str(result.status), "methanol_kg_day": np.nan,
                         "co2_kg_day": np.nan, "h2_kg_day": np.nan, "electrolyser_water_kg_day": np.nan,
                         "element_residual_max_kmol_atoms_day": np.nan})
            continue
        m = result.value["mass_flows_kg_day"]
        elem = result.value["element_residual_kmol_atoms_day"]
        rows.append({"throughput_t_day": t_day, "status": str(result.status),
                     "methanol_kg_day": m["CH3OH_kg_day"], "co2_kg_day": m["CO2_kg_day"],
                     "h2_kg_day": m["H2_kg_day"], "electrolyser_water_kg_day": m["electrolyser_water_kg_day"],
                     "element_residual_max_kmol_atoms_day": max(abs(v) for v in elem.values())})
    table = pd.DataFrame(rows)
    return ModelResult("sensitivity_optimisation", Status.SCREENING_ONLY,
                       value={"method": plan["method"], "plan_id": plan["plan_id"], "table": table,
                              "optimisation": {"status": "BLOCKED", "objective": None,
                                               "reason": "The available engine does not contain the physical process model and constraints needed for optimisation."}},
                       warnings=[plan["interpretation"], "Only throughput sensitivity is implemented in the core Prompt 19 MATLAB sensitivity function; this port does not claim six-variable optimisation."],
                       provenance={"source_ids": [plan["source_id"]]})


def latin_hypercube_samples(bounds: dict[str, tuple[float, float]], n_samples: int = 128,
                            seed: int = 20261102) -> pd.DataFrame:
    """Generate a reproducible unit-hypercube mapped DOE; not a process simulator."""
    if n_samples < 1 or not bounds:
        raise ValueError("Provide at least one variable and one sample.")
    names = list(bounds)
    for name, (lo, hi) in bounds.items():
        if not np.isfinite([lo, hi]).all() or hi <= lo:
            raise ValueError(f"Invalid LHS bounds for {name}: require finite upper > lower.")
    sampler = qmc.LatinHypercube(d=len(names), seed=seed, optimization=None)
    unit = sampler.random(n=n_samples)
    scaled = qmc.scale(unit, [bounds[n][0] for n in names], [bounds[n][1] for n in names])
    return pd.DataFrame(scaled, columns=names)
