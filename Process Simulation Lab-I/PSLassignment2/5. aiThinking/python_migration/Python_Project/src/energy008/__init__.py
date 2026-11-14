"""ENERGY-008 staged Python migration package.

The package deliberately exposes only reference/screening calculations supported
by the frozen Prompt 17 fixture and versioned Prompt 19 data. Physical flowsheet
models remain explicitly BLOCKED where source data or validation are absent.
"""

__version__ = "0.1.0"
MODEL_VERSION = "ENERGY008-MODEL-0.1.0"
DATA_VERSION = "ENERGY008-DATA-0.1.0"
REACTION_VERSION = "ENERGY008-RXN-0.1.0"
