"""Independent acceptance checks for sign and conservation conventions."""
from __future__ import annotations
from .status import ModelResult, Status


def validate_entropy_generation(value_kW_K: float, tolerance: float = 1e-12) -> ModelResult:
    """Reject negative control-volume entropy generation; never clip to zero."""
    value = float(value_kW_K)
    if value < -abs(tolerance):
        return ModelResult("entropy_sign_validation", Status.FAILED,
                           value={"entropy_generation_kW_K": value},
                           errors=[{"code": "ENERGY008:NegativeEntropyGeneration", "message": "Negative entropy generation violates the applied sign convention; investigate model, boundary and data."}])
    return ModelResult("entropy_sign_validation", Status.CALCULATED,
                       value={"entropy_generation_kW_K": value})
