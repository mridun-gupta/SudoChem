"""Status and result contract shared by all Python modules."""
from __future__ import annotations
from dataclasses import asdict, dataclass, field
from enum import StrEnum
from typing import Any


class Status(StrEnum):
    CALCULATED = "CALCULATED"
    REFERENCE_ONLY = "REFERENCE_ONLY"
    SCREENING_ONLY = "SCREENING_ONLY"
    BLOCKED = "BLOCKED"
    FAILED = "FAILED"
    NOT_RUN = "NOT_RUN"


@dataclass(slots=True)
class ModelResult:
    module_id: str
    status: Status
    value: Any = None
    units: dict[str, str] = field(default_factory=dict)
    warnings: list[str] = field(default_factory=list)
    errors: list[dict[str, str]] = field(default_factory=list)
    residuals: dict[str, float] = field(default_factory=dict)
    provenance: dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> dict[str, Any]:
        def convert(obj: Any) -> Any:
            try:
                import numpy as np
                if isinstance(obj, np.ndarray):
                    return obj.tolist()
                if isinstance(obj, np.generic):
                    return obj.item()
            except ImportError:  # pragma: no cover - numpy is required by this package
                pass
            try:
                import pandas as pd
                if isinstance(obj, pd.DataFrame):
                    return obj.to_dict(orient="records")
                if isinstance(obj, pd.Series):
                    return obj.to_dict()
            except ImportError:  # pragma: no cover
                pass
            if hasattr(obj, "to_dict") and callable(obj.to_dict):
                return obj.to_dict()
            if hasattr(obj, "__dataclass_fields__"):
                return asdict(obj)
            if isinstance(obj, dict):
                return {str(k): convert(v) for k, v in obj.items()}
            if isinstance(obj, (list, tuple)):
                return [convert(v) for v in obj]
            if isinstance(obj, StrEnum):
                return str(obj)
            return obj
        return {
            "module_id": self.module_id,
            "status": str(self.status),
            "value": convert(self.value),
            "units": self.units,
            "warnings": self.warnings,
            "errors": self.errors,
            "residuals": self.residuals,
            "provenance": self.provenance,
        }
