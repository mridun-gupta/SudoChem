"""Matrix-driven reaction stoichiometry. Coefficients are read from JSON data."""
from __future__ import annotations
import numpy as np
from .config import ModelData, Energy008Error


def stoichiometric_matrix(data: ModelData) -> tuple[np.ndarray, list[str], list[str]]:
    net = data.reactions
    matrix = np.asarray(net["stoichiometric_matrix_products_positive"], dtype=float)
    species = list(net["species_order"])
    reaction_ids = list(net["reaction_order"])
    if matrix.shape != (len(species), len(reaction_ids)):
        raise Energy008Error("ENERGY008:StoichiometryShape", "Stoichiometric matrix shape mismatch.")
    if not np.all(np.isfinite(matrix)):
        raise Energy008Error("ENERGY008:StoichiometryInvalid", "Stoichiometric matrix contains non-finite values.")
    return matrix, species, reaction_ids


def derive_extents(data: ModelData) -> dict[str, float]:
    """Return independent reaction extents on mol/s basis for a reference case.

    R-01 extent is set by the component-equivalent methanol rate. R-02 is read
    from the case as an explicitly reference-only assumption. E-01 closes H2
    supply against declared synthesis stoichiometry. This is not kinetics.
    """
    c = data.case
    N, species, reaction_ids = stoichiometric_matrix(data)
    assumptions = c["assumptions"]
    component_by_species = {x["formula"].replace("-", ""): x for x in data.properties["components"]}
    if "CH3OH" not in component_by_species:
        raise Energy008Error("ENERGY008:ComponentMissing", "Methanol molecular weight not available.")
    mw_meoh_kg_mol = component_by_species["CH3OH"]["molecular_weight_kg_kmol"] / 1000.0
    target_kg_s = float(c["methanol_component_equivalent_kg_day"]) / 86_400.0
    target_mol_s = target_kg_s / mw_meoh_kg_mol

    def idx(items: list[str], key: str) -> int:
        try:
            return items.index(key)
        except ValueError as exc:
            raise Energy008Error("ENERGY008:StoichiometryIdentityMissing", f"Missing {key} in reaction register.") from exc

    i_h2, i_meoh = idx(species, "H2"), idx(species, "CH3OH")
    j_r01, j_r02, j_e01 = (idx(reaction_ids, k) for k in ("R-01", "R-02", "E-01"))
    nu_meoh = N[i_meoh, j_r01]
    nu_h2_e = N[i_h2, j_e01]
    if nu_meoh <= 0 or nu_h2_e <= 0:
        raise Energy008Error("ENERGY008:ReactionStoichInvalid", "R-01 must produce methanol and E-01 must produce hydrogen.")
    xi_r01 = target_mol_s / nu_meoh
    xi_r02 = float(assumptions["R02_extent_kmol_day"]) * 1000.0 / 86_400.0
    xi_e01 = (-N[i_h2, j_r01] * xi_r01 - N[i_h2, j_r02] * xi_r02) / nu_h2_e
    extents = {"R-01": xi_r01, "R-02": xi_r02, "E-01": xi_e01}
    if any((not np.isfinite(x) or x < 0) for x in extents.values()):
        raise Energy008Error("ENERGY008:ReactionExtentInvalid", "Reaction extents must be finite and nonnegative mol/s.")
    return extents
