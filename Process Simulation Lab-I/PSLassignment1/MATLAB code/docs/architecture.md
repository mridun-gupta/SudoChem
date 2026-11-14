# CPS-22 MATLAB Architecture

## Data flow

`main.m` loads `data/default_case.json`, validates inputs, builds a reference-interpolation fixture from the transcribed experimental dataset, runs the NRTL-SRK diagnostic solver, computes material-balance closure and preliminary separator screening, reports blocked energy/utility/economics modules, evaluates five documented sensitivity groups, and exports tables/plots/diagnostics.

`run_gui.m` opens `gui/cps22_gui.m`. The GUI calls the same `src/` functions as the command-line workflow. GUI and calculations are separate.

## Modules

| Module | Interface / purpose | Status |
|---|---|---|
| `cps22_load_config` | Read JSON and resolve paths | Implemented |
| `cps22_validate_config` | Validate dimensions, bounds, parameter arrays and Antoine ranges | Implemented |
| `cps22_antoine_psat` | Antoine saturation pressure in Pa | Implemented within stored validity ranges |
| `cps22_rackett_volume` | Liquid molar-volume estimate for Poynting/screening | Approximation only |
| `cps22_nrtl_gamma` | NRTL activity coefficients | Implemented; parameter set not accepted for selected state |
| `cps22_srk_phi` | SRK mixture properties, real roots, vapour root and fugacity coefficient | Implemented; stability not evaluated |
| `cps22_gamma_phi` | High-pressure fugacity residual with saturated-vapour and Poynting corrections | Implemented diagnostic |
| `cps22_flash_tp` | Multi-start nonlinear TP-flash residual minimization | Implemented; not validated for production use |
| `cps22_reference_flash` | Interpolate source dataset, classify reference phase, calculate lever-rule split | Implemented as a separate benchmark fixture only |
| `cps22_material_balance` | Total/component closure | Implemented |
| `cps22_equipment_screen` | Souders-Brown and liquid hold-up screening | Screening only; approximate physical properties and K-factor |
| `cps22_energy_balance` | Enthalpy balance interface | Explicitly blocked pending accepted enthalpy model |
| `cps22_utilities` | Process duty conversion | Explicitly blocked |
| `cps22_economics` | Screening costs | Explicitly blocked |
| `cps22_run_sensitivities` | Five independent sensitivity groups | Reference-based and diagnostic, not target-model acceptance evidence |
| `cps22_model_comparison` | Import/export literature-reported azeotrope comparison | Sources are not independently recomputed |
| `cps22_make_plots` | Generate six plots | Implemented |
| `cps22_gui` | Run/reset/export UI and results/status display | Source created; not runtime-tested here |

## Units

Internal thermodynamic units: K, Pa, mol/mol, J/mol, m³/mol, kg/mol. Flow is stored at the interface as kmol/h and converted to mol/s for balances and equipment calculations. Plot labels and exported tables state units.

## Failure conventions

Invalid inputs produce errors at module boundaries or a structured `INVALID_INPUT` result in the flash solver. Missing/invalid EOS roots raise diagnostic errors. The flash solver records residuals independently of `fminsearch` exit status. Energy, utilities and costs return `BLOCKED_*` statuses rather than numeric placeholders.

## Portability

The property formulas map to NumPy arrays and SciPy optimizers. Use pandas for data tables and matplotlib for charts. Keep JSON fields and CSV column names stable across both platforms. MATLAB's `fminsearch` corresponds approximately to SciPy Nelder-Mead; tolerance semantics need explicit mapping during migration.
