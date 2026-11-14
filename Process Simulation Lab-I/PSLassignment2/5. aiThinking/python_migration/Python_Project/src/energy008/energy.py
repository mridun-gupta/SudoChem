"""Standard-state reaction reference and pure-fluid duty references."""
from __future__ import annotations
import math
from .config import ModelData
from .status import ModelResult, Status


def energy_balance(data: ModelData, material: ModelResult, properties: ModelResult) -> ModelResult:
    if material.status in {Status.BLOCKED, Status.FAILED, Status.NOT_RUN} or not material.value:
        return ModelResult("energy_balance", Status.BLOCKED,
                           value={"plant_energy_closure": {"status": "BLOCKED", "value": None}},
                           warnings=["Energy reference requires a valid reaction-block material balance."])
    if properties.status in {Status.BLOCKED, Status.FAILED, Status.NOT_RUN} or not properties.value:
        return ModelResult("energy_balance", Status.BLOCKED,
                           warnings=["Required pure-fluid benchmark properties are unavailable."])
    xi = material.value["reaction_extents_mol_s"]
    if xi["R-02"] > 1e-12:
        return ModelResult("energy_balance", Status.BLOCKED,
                           value={"plant_energy_closure": {"status": "BLOCKED", "value": None}},
                           warnings=["R-02 is nonzero but source-supported R-02 reaction thermochemistry and compatible phase enthalpy data are absent."])
    thermo = {row["reaction_id"]: row for row in data.properties["reaction_thermochemistry"]}
    try:
        r01, e01, net = thermo["R-01"], thermo["E-01"], thermo["NET-01"]
    except KeyError:
        return ModelResult("energy_balance", Status.BLOCKED, warnings=["Required standard reaction enthalpy record is missing."])
    h_r01 = float(r01["delta_h_kJ_mol_reaction"])
    h_e01 = float(e01["delta_h_kJ_mol_reaction"])
    h_net = float(net["delta_h_kJ_mol_reaction"])
    n_meoh = float(material.value["molar_flows_mol_s"]["CH3OH"])
    r01_kw = xi["R-01"] * h_r01
    e01_kw = xi["E-01"] * h_e01
    net_kw = n_meoh * h_net
    extent_ratio = xi["E-01"] / xi["R-01"] if xi["R-01"] else math.nan
    identity = h_r01 + extent_ratio * h_e01
    kW_to_GJ_day = 86_400.0 / 1.0e6
    uncertainty = {
        "status": "SOURCE_PROPAGATED_SCREENING",
        "R01_rate_sigma_GJ_day": abs(xi["R-01"]) * float(r01["uncertainty_kJ_mol_reaction"]) * kW_to_GJ_day,
        "E01_rate_sigma_GJ_day": abs(xi["E-01"]) * float(e01["uncertainty_kJ_mol_reaction"]) * kW_to_GJ_day,
        "net_rate_sigma_GJ_day": abs(n_meoh) * float(net["uncertainty_kJ_mol_reaction"]) * kW_to_GJ_day,
        "interpretation": "Source-propagated enthalpy uncertainty only; not a confidence interval and excludes throughput/model-form/covariance uncertainty.",
    }
    values = {
        "reaction_reference": {
            "R01_delta_h_kJ_mol": h_r01, "R01_rate_kW": r01_kw, "R01_rate_GJ_day": r01_kw * kW_to_GJ_day,
            "E01_delta_h_kJ_mol_reaction": h_e01, "E01_rate_kW": e01_kw, "E01_rate_GJ_day": e01_kw * kW_to_GJ_day,
            "net_delta_h_kJ_mol_MeOH": h_net, "net_rate_kW": net_kw, "net_rate_GJ_day": net_kw * kW_to_GJ_day,
            "R01_plus_electrolysis_kJ_mol": identity, "E01_extent_per_R01_extent": extent_ratio,
            "identity_residual_kJ_mol": identity - h_net,
            "reference_state_T_K": r01["temperature_K"],
            "reference_state_P_Pa_abs": float(r01["pressure_MPa_abs"]) * 1e6,
            "status": "REFERENCE_ONLY",
        },
        "reaction_reference_uncertainty": uncertainty,
        "co2_sensible_heating": properties.value.get("co2_sensible"),
        "methanol_latent_reference": properties.value.get("methanol_latent"),
        "plant_energy_closure": {"status": "BLOCKED", "value": None, "reason": "Physical stream enthalpies, mixture properties, equipment duties and utility states are unavailable."},
        "reactor_cooling_duty": {"status": "BLOCKED", "value": None},
        "distillation_duties": {"status": "BLOCKED", "value": None},
    }
    return ModelResult("energy_balance", Status.SCREENING_ONLY, value=values,
                       warnings=["Standard-state reaction enthalpies are references, not equipment duties.",
                                 "CO2 sensible and methanol latent duties are pure-fluid benchmark illustrations.",
                                 "Plant energy closure, reactor cooling and distillation duties remain BLOCKED."],
                       residuals={"reaction_enthalpy_identity_residual_kJ_mol": identity - h_net},
                       provenance={"source_ids": [r01["source_id"], e01["source_id"], net["source_id"]]})
