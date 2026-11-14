"""Reference-only material KPIs and explicit environmental KPI blockers."""
from __future__ import annotations
import pandas as pd
from .status import ModelResult, Status


def material_kpis(material: ModelResult) -> ModelResult:
    if not material.value:
        return ModelResult("material_kpis", Status.BLOCKED, warnings=["Material KPI calculation requires material-balance result."])
    kpis = material.value["ideal_reference_kpis"]
    rows = [{"KPI": key, "Value": value, "Units": "fraction or mol/mol", "Status": str(material.status)} for key, value in kpis.items()]
    return ModelResult("material_kpis", Status.REFERENCE_ONLY if material.status == Status.REFERENCE_ONLY else Status.SCREENING_ONLY,
                       value=pd.DataFrame(rows), warnings=["Ideal conversion/selectivity/product purity values are imposed by the limiting stoichiometric reference and are not reactor/product performance predictions."])


def environmental_kpis_blocked() -> ModelResult:
    return ModelResult("environmental_kpis", Status.BLOCKED,
                       value={"ghg_intensity": None, "water_intensity": None, "waste_intensity": None},
                       warnings=["Environmental KPIs require source-mapped, metered data and an approved boundary/MRV method."])
