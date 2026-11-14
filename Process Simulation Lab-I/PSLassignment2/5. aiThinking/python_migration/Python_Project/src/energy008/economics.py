"""Economics utilities. Full ENERGY-008 CAPEX/OPEX/LCOM remains data-gated."""
from __future__ import annotations


def capital_recovery_factor(discount_rate_fraction: float, plant_life_years: int) -> float:
    """Return dimensionless CRF for positive n and r >= 0; r=0 gives 1/n."""
    r = float(discount_rate_fraction)
    n = int(plant_life_years)
    if r < 0 or n <= 0:
        raise ValueError("Discount rate must be non-negative and plant life positive.")
    if r == 0:
        return 1.0 / n
    return r * (1 + r) ** n / ((1 + r) ** n - 1)
