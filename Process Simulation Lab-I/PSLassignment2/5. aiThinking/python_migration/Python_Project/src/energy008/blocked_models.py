"""Explicit fail-closed modules where physical model data are not yet available."""
from __future__ import annotations
from .config import ModelData
from .status import ModelResult, Status


def entropy_exergy(data: ModelData) -> ModelResult:
    return ModelResult("entropy_exergy", Status.BLOCKED,
                       value={"plant_entropy_generation": {"status": "BLOCKED", "value": None, "units": "kW/K"},
                              "plant_exergy_destruction": {"status": "BLOCKED", "value": None, "units": "kW"}},
                       warnings=["Validated stream entropies, heat/work boundaries and approved dead-state environment are missing."])


def utilities_model(data: ModelData) -> ModelResult:
    return ModelResult("utilities_model", Status.BLOCKED,
                       value={"electricity": None, "cooling_and_steam": None, "emissions": None},
                       warnings=["ALK vendor polarization/performance map, rectifier/BOP loads, compressor maps, site utilities and tariffs are unavailable."])


def economics(data: ModelData) -> ModelResult:
    return ModelResult("economics", Status.BLOCKED,
                       value={"CAPEX_INR_2026": None, "OPEX_INR_year": None, "LCOM_INR_per_t": None},
                       warnings=["Dated vendor quotations, cost factors, tariffs, production basis and finance inputs remain null in the versioned cost template."])


def environmental_kpis(data: ModelData) -> ModelResult:
    return ModelResult("environmental_kpis", Status.BLOCKED,
                       value={"GHG_intensity_kgCO2e_per_kg_MeOH": None,
                              "net_water_intensity_m3_per_t_MeOH": None,
                              "solid_waste_intensity_kg_per_t_MeOH": None},
                       warnings=["Metered electricity, source-specific emission factor, carbon chain-of-custody, measured water/waste and MRV method are unavailable."])


def reactor_calculation(data: ModelData) -> ModelResult:
    return ModelResult("reactor_calculation", Status.BLOCKED,
                       value={"conversion": None, "catalyst_mass_kg": None, "reactor_volume_m3": None},
                       warnings=["Catalyst-matched kinetic expression/parameters, validity range, geometry and heat-transfer boundary are absent."])


def physical_recycle(data: ModelData) -> ModelResult:
    return ModelResult("recycle_solver", Status.BLOCKED,
                       value={"physical_recycle_status": "BLOCKED_NOT_COMPUTED", "stream_id": "S-209", "flow": None,
                              "purge_status": "BLOCKED_NOT_COMPUTED", "purge_fraction": None},
                       warnings=["Physical recycle requires validated PR EOS/flash, stream composition/inerts, purge criterion and compressor performance."])


def control_status(data: ModelData) -> ModelResult:
    return ModelResult("control_logic", Status.BLOCKED,
                       value={"mode": "OFFLINE / NOT CONNECTED", "BPCS": "NOT_CONNECTED", "SIS_ESD_FGS": "INDICATION_ONLY_NOT_CONNECTED"},
                       warnings=["No live instrumentation or control system is connected. No commands or setpoints are issued."])
