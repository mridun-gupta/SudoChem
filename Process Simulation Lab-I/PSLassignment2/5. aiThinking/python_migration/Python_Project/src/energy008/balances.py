"""Matrix-driven stoichiometric component/element ledger (not 55-stream flowsheet)."""
from __future__ import annotations
import numpy as np
import pandas as pd
from .config import ModelData, Energy008Error
from .reactions import stoichiometric_matrix, derive_extents
from .status import ModelResult, Status


def material_balance(data: ModelData) -> ModelResult:
    case_status = data.case.get("case_status")
    if case_status == "BLOCKED" or data.case.get("route_id") not in {"Route A", "Route C"}:
        return ModelResult("material_balance", Status.BLOCKED,
                           value={"case_id": data.case.get("case_id"), "blockers": data.case.get("blockers", [])},
                           warnings=["Physical stream balance not available for this route. No zero-fill is applied."],
                           provenance={"source_ids": data.case.get("source_ids", [])})
    try:
        N, species, reaction_ids = stoichiometric_matrix(data)
        extents_by_id = derive_extents(data)
        xi = np.array([extents_by_id[rid] for rid in reaction_ids], dtype=float)
        contributions = N * xi[np.newaxis, :]
        net_mol_s = contributions.sum(axis=1)
        gross_produced_mol_s = np.maximum(contributions, 0.0).sum(axis=1)
        gross_consumed_mol_s = np.maximum(-contributions, 0.0).sum(axis=1)
        mw = {c["formula"]: float(c["molecular_weight_kg_kmol"]) / 1000.0 for c in data.properties["components"]}
        index = {s: i for i, s in enumerate(species)}
        def g(v: np.ndarray, sp: str) -> float: return float(v[index[sp]])
        molar = {
            "CH3OH": g(gross_produced_mol_s, "CH3OH"),
            "CO2": g(gross_consumed_mol_s, "CO2"),
            "H2": g(gross_consumed_mol_s, "H2"),
            "CO": g(gross_produced_mol_s, "CO"),
            "H2O_reaction": g(gross_produced_mol_s, "H2O"),
            "H2O_electrolyser": g(gross_consumed_mol_s, "H2O"),
            "H2O_net": g(gross_consumed_mol_s, "H2O") - g(gross_produced_mol_s, "H2O"),
            "O2": g(gross_produced_mol_s, "O2"),
            "H2_from_electrolyser": g(gross_produced_mol_s, "H2"),
        }
        # The reaction register formula symbols are canonical; gross component flows are converted kg/s.
        mw_map = {"CH3OH": mw["CH3OH"], "CO2": mw["CO2"], "H2": mw["H2"], "CO": mw["CO"],
                  "H2O": mw["H2O"], "O2": mw["O2"]}
        mass_kg_s = {
            "CH3OH": molar["CH3OH"] * mw_map["CH3OH"], "CO2": molar["CO2"] * mw_map["CO2"],
            "H2": molar["H2"] * mw_map["H2"], "CO": molar["CO"] * mw_map["CO"],
            "reaction_water": molar["H2O_reaction"] * mw_map["H2O"],
            "electrolyser_water": molar["H2O_electrolyser"] * mw_map["H2O"],
            "net_water": molar["H2O_net"] * mw_map["H2O"], "O2": molar["O2"] * mw_map["O2"],
        }
        mass_kg_day = {f"{k}_kg_day": v * 86_400.0 for k, v in mass_kg_s.items()}
        mass_in = mass_kg_s["CO2"] + mass_kg_s["net_water"]
        mass_out = mass_kg_s["CH3OH"] + mass_kg_s["CO"] + mass_kg_s["O2"]
        mass_resid_kg_day = (mass_in - mass_out) * 86_400.0
        A = np.asarray(data.reactions["element_matrix_rows_C_H_O"], dtype=float)
        elem_mol_s = A @ net_mol_s
        elements_kmol_day = {el: float(v * 86_400.0 / 1000.0) for el, v in zip(["C", "H", "O"], elem_mol_s)}
        molar_kmol_day = {k: float(v * 86_400.0 / 1000.0) for k, v in molar.items() if k != "H2_from_electrolyser"}
        flows = []
        labels = [
            ("CH3OH", "CH3OH"), ("CO2", "CO2"), ("H2", "H2"), ("CO", "CO"),
            ("H2O_reaction", "reaction_water"), ("H2O_electrolyser", "electrolyser_water"),
            ("H2O_net", "net_water"), ("O2", "O2")]
        for label, mkey in labels:
            flows.append({"ComponentOrLedger": label, "Flow_kmol_day": molar_kmol_day.get(label, 0.0),
                          "Flow_kg_day": mass_kg_day[f"{mkey}_kg_day"], "Status": case_status})
        flow_table = pd.DataFrame(flows)
        elem_table = pd.DataFrame([{"Element": k, "Residual_kmol_atoms_day": v} for k, v in elements_kmol_day.items()])
        species_table = pd.DataFrame([{"Species": sp, "Net_Species_Rate_kmol_day": float(net_mol_s[i] * 86_400 / 1000)} for i, sp in enumerate(species)])
        if abs(molar["H2_from_electrolyser"] - molar["H2"]) > 1e-10 * max(1.0, molar["H2"]):
            raise Energy008Error("ENERGY008:HydrogenSubsystemClosure", "Electrolyser H2 production does not equal synthesis H2 consumption.")
        status = Status.REFERENCE_ONLY if case_status == "REFERENCE_ONLY" else Status.SCREENING_ONLY
        values = {
            "case_id": data.case["case_id"], "route_id": data.case["route_id"], "case_status": case_status,
            "basis": {"methanol_component_equivalent_kg_day": float(data.case["methanol_component_equivalent_kg_day"]),
                      "hours_per_day": float(data.case.get("operating_hours_per_day", 24.0))},
            "reaction_extents_mol_s": extents_by_id,
            "reaction_extents_kmol_day": {k: float(v * 86_400 / 1000) for k, v in extents_by_id.items()},
            "reaction_contribution_mol_s": contributions, "species_order": species, "reaction_order": reaction_ids,
            "molar_flows_mol_s": molar, "molar_flows_kmol_day": molar_kmol_day,
            "mass_flows_kg_s": mass_kg_s, "mass_flows_kg_day": mass_kg_day,
            "mass_balance": {"input_kg_day": mass_in * 86_400.0, "output_kg_day": mass_out * 86_400.0,
                             "residual_input_minus_output_kg_day": mass_resid_kg_day},
            "element_residual_kmol_atoms_day": elements_kmol_day,
            "ideal_reference_kpis": {
                "co2_conversion_fraction": 1.0,
                "h2_conversion_fraction": 1.0,
                "carbon_selectivity_to_methanol_fraction": extents_by_id["R-01"] / max(extents_by_id["R-01"] + extents_by_id["R-02"], np.finfo(float).eps),
                "methanol_yield_mol_per_mol_CO2": extents_by_id["R-01"] / max(molar["CO2"], np.finfo(float).eps),
                "methanol_mass_fraction_in_ideal_product": 1.0,
                "methanol_mole_fraction_in_ideal_product": 1.0,
            },
            "tables": {"component_flows": flow_table, "element_closure": elem_table, "net_species_stoichiometry": species_table},
            "physical_recycle": {"stream_id": "S-209", "status": "BLOCKED_NOT_COMPUTED", "value": None},
            "physical_purge": {"stream_id": "S-207", "status": "BLOCKED_NOT_COMPUTED", "value": None},
        }
        return ModelResult("material_balance", status, value=values,
                           warnings=["This is a reaction-block ledger, not the complete 55-stream physical flowsheet.",
                                     "Physical S-209 recycle and S-207 purge remain BLOCKED, not zero."],
                           residuals={"mass_balance_residual_kg_day": mass_resid_kg_day, **{f"element_{k}_kmol_atoms_day": v for k, v in elements_kmol_day.items()}},
                           provenance={"source_ids": data.case.get("source_ids", []), "reaction_network_version": data.reactions.get("reaction_network_version")})
    except (ValueError, KeyError, TypeError, IndexError, Energy008Error) as exc:
        code = exc.code if isinstance(exc, Energy008Error) else "ENERGY008:MaterialBalanceFailure"
        return ModelResult("material_balance", Status.FAILED, errors=[{"code": code, "message": str(exc)}])
