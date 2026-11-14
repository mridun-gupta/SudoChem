# Python API, types and unit contract

## Shared result contract

Every module returns `energy008.status.ModelResult`:

| Field | Python type | Meaning |
|---|---|---|
| `module_id` | `str` | stable module identifier |
| `status` | `Status` enum | CALCULATED / REFERENCE_ONLY / SCREENING_ONLY / BLOCKED / FAILED / NOT_RUN |
| `value` | `dict`, `pandas.DataFrame`, scalar or `None` | module payload; blocked numeric fields remain `None` |
| `units` | `dict[str,str]` | unit labels for values |
| `warnings` | `list[str]` | limitations and status caveats |
| `errors` | `list[dict[str,str]]` | stable code and message |
| `residuals` | `dict[str,float]` | unrounded residuals |
| `provenance` | `dict` | source IDs and versions |

## Module API map

| Python module | Public function | Inputs | Output / type | Units / errors |
|---|---|---|---|---|
| `config` | `load_model(case_id=None,data_dir=None)` | case ID; explicit package data root optional | `ModelData` dataclass of JSON dicts and `Path` | source JSON units retained; raises `Energy008Error` with stable code for missing/invalid data |
| `config` | `validate_inputs(data)` | `ModelData` | `ModelResult` | checks positive finite kg/day, case status, R-02 reference provenance, matrix dimensions and route boundary |
| `units` | `convert(value,conversion,density_kg_m3=None)` | numeric scalar/array and named conversion | NumPy array/scalar | explicit names for kg/day, kg/s, mol/s, kmol/day, kg/h, m3/s; raises `ValueError` on bad/unknown unit conversion |
| `reactions` | `stoichiometric_matrix(data)` | reaction JSON | `(numpy.ndarray, species:list[str], reaction_ids:list[str])` | coefficients dimensionless; `Energy008Error` if map inconsistent |
| `reactions` | `derive_extents(data)` | `ModelData` | `dict[str,float]` | mol/s; rejects negative/non-finite extent and missing reaction identities |
| `properties` | `evaluate_properties(data,...)` | data plus optional temperatures/request | `ModelResult` with nested dicts | kJ/mol, mol/s, kW, K; property range -> FAILED; PR78/VLE -> BLOCKED |
| `balances` | `material_balance(data)` | `ModelData` | `ModelResult`; `pandas.DataFrame` tables | internally mol/s, kg/s; exports kmol/day, kg/day, kmol atom/day |
| `energy` | `energy_balance(data,material,properties)` | prior module results | `ModelResult` | kJ/mol, kW, GJ/day; non-zero R-02 -> BLOCKED for missing enthalpy support |
| `equipment` | `equipment_screening(data,material,energy)` | prior module results | `ModelResult`, DataFrame datasheets | W, kg/s, m3/s, Pa, m; report kW, m2, m3/h; screening only |
| `blocked_models` | `entropy_exergy(data)` | `ModelData` | `ModelResult` | kW/K, kW remain null/BLOCKED |
| `blocked_models` | `utilities_model(data)` | `ModelData` | `ModelResult` | actual power/duties remain null/BLOCKED |
| `blocked_models` | `economics(data)` | `ModelData` | `ModelResult` | INR, INR/year, INR/t remain null/BLOCKED |
| `blocked_models` | `environmental_kpis(data)` | `ModelData` | `ModelResult` | intensity values remain null/BLOCKED |
| `blocked_models` | `reactor_calculation(data)` | `ModelData` | `ModelResult` | conversion, kg catalyst, m3 remain null/BLOCKED |
| `blocked_models` | `physical_recycle(data)` | `ModelData` | `ModelResult` | S-209/S-207 remain null/BLOCKED_NOT_COMPUTED |
| `sensitivity` | `throughput_sensitivity(data)` | case + versioned plan | `ModelResult` with DataFrame | t/day, kg/day; linear screening only |
| `sensitivity` | `latin_hypercube_samples(bounds,n,seed)` | ranges, sample count, seed | `pandas.DataFrame` | dimensionless sampled independent variables; not connected automatically to blocked process model |
| `numerics` | `solve_synthetic_nonlinear(fun,x0,...)` | residual function and vector guess | dict | numerical residual only; synthetic tests only |
| `engine` | `run_case(case_id=None,data_dir=None)` | controlled case and optional data root | dict of module results and statuses | no GUI dependency |
| `exports` | `export_run(run,results_root=None)` | engine output | `Path` | unique run directory with JSON/CSV/PNG/log |

## Null and numeric conventions

- JSON null maps to Python `None`, never `0.0`.
- Failed/blocked numeric results are not stored as NaN in report outputs unless a tabular analysis explicitly marks the row invalid; JSON serializer rejects NaN by default.
- Component and reaction ledgers use canonical species strings from the reaction network. Case and property data are the authority for molecular weights and assumptions.
- Pressures remain absolute. Temperatures remain K. Mass is kg; amount is mol or kmol. Energy units are explicitly named at each boundary.
- `DataFrame` column names carry units as suffixes (`Flow_kg_day`, `Residual_kmol_atoms_day`).
