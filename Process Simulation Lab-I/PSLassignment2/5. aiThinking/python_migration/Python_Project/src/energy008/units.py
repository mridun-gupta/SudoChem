"""Explicit unit conversion helpers. Canonical calculation basis is SI."""
from __future__ import annotations
import numpy as np

SECONDS_PER_DAY = 86_400.0


def kg_day_to_kg_s(value): return np.asarray(value, dtype=float) / SECONDS_PER_DAY

def kg_s_to_kg_day(value): return np.asarray(value, dtype=float) * SECONDS_PER_DAY

def kmol_day_to_mol_s(value): return np.asarray(value, dtype=float) * 1000.0 / SECONDS_PER_DAY

def mol_s_to_kmol_day(value): return np.asarray(value, dtype=float) * SECONDS_PER_DAY / 1000.0

def kg_day_to_kg_h(value): return np.asarray(value, dtype=float) / 24.0

def m3_h_to_m3_s(value): return np.asarray(value, dtype=float) / 3600.0


def convert(value, conversion: str, density_kg_m3: float | None = None):
    x = np.asarray(value, dtype=float)
    if not np.all(np.isfinite(x)):
        raise ValueError("Unit conversion input must be finite.")
    methods = {
        "t_day_to_kg_day": lambda a: a * 1000.0,
        "kg_day_to_t_day": lambda a: a / 1000.0,
        "kg_day_to_kg_s": kg_day_to_kg_s,
        "kg_s_to_kg_day": kg_s_to_kg_day,
        "mol_s_to_kmol_day": mol_s_to_kmol_day,
        "kmol_day_to_mol_s": kmol_day_to_mol_s,
        "kg_day_to_kg_h": kg_day_to_kg_h,
        "m3_h_to_m3_s": m3_h_to_m3_s,
    }
    if conversion == "kg_h_to_m3_s":
        if density_kg_m3 is None or not np.isfinite(density_kg_m3) or density_kg_m3 <= 0:
            raise ValueError("kg/h to m3/s requires positive density_kg_m3.")
        return x / 3600.0 / density_kg_m3
    if conversion not in methods:
        raise ValueError(f"Unsupported conversion: {conversion}")
    return methods[conversion](x)
