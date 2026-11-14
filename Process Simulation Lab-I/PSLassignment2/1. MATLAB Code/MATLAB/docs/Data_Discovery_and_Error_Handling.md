# Data Discovery, Validation and Error Handling

**Document ID:** ENERGY008-DATA-IO-001  
**Revision:** 0.1-DRAFT  
**Applies to:** Prompt 18 startup and Prompt 19 data ingestion implementation

## 1. Discovery roots and priority

Data discovery is restricted to the root-relative directories declared in `MATLAB/project_config.json` and repeated in `data/data_manifest.json`:

1. `data/raw/` for immutable source snapshots from earlier phases.
2. `data/processed/` for controlled derived machine-readable data.
3. `data/reference/` for independent benchmarks and comparison fixtures.
4. `data/schemas/` for versioned schema contracts.

No discovery function may scan the whole drive, user home, MATLAB path, current working directory, arbitrary download directories, archives, old-version directories, or external network locations.

For each manifest dataset, resolution order is:

1. **Explicit path:** resolve the manifest's `explicit_path` relative to the project root. It must exist and be inside an allow-listed data root.
2. **Exact filename:** if the explicit path is missing, recursively search only the allow-listed roots for `exact_filename`. Exact matching is case-sensitive by baseline policy.
3. **Documented unambiguous rule:** only if the dataset declares `match_regex` and a nonempty `match_rule_description`, search the same roots. This is disabled for every Prompt 18 dataset.

Zero matches on a required dataset raise `ENERGY008:DataMissing`. More than one exact/regex match raises `ENERGY008:DataAmbiguous` and prints every candidate path. The user/maintainer must update the manifest to select the intended file. The resolver must never take `matches(1)` or otherwise silently pick the first candidate.

All paths are root-relative. Absolute paths, `..` traversal and symlink/canonical paths outside the project roots are rejected. `pwd` is not a source of truth. The current working directory may be any directory.

## 2. Manifest record and change control

Each dataset entry records:

- `dataset_id`, `logical_name`, `role`;
- `explicit_path`, `exact_filename`, `format`, `required`;
- `schema_id`, `source_version`, `source_metadata`;
- `required_sheets` for workbooks and `required_columns` for CSV inputs;
- `expected_sha256`;
- optional `match_regex` plus `match_rule_description`.

The manifest is itself versioned (`ENERGY008-DATA-MANIFEST-0.1.0`). File content changes require an explicit review and new manifest hash. Raw snapshots must not be silently replaced. Processed data must retain transformation code/version, source IDs/hashes, units, and processing timestamp. Independent Prompt 17 reference fixtures are kept separate from calibration/training data.

## 3. Supported formats

Prompt 18 runtime data formats are limited to `.csv`, `.json` and `.xlsx`. Project documentation is `.md`/`.txt`; flowcharts are `.mmd`, `.dot`, `.svg` and `.png`; source diagram assets may also use `.drawio`. Unsupported `.xls`, `.xlsm`, `.ods`, `.mat` and `.parquet` are not accepted by the current runtime data configuration. A future format addition requires an explicit parser, schema, tests and configuration change.

No data are imported through generic `load` calls. Prompt 19 must select the parser by manifest format and apply that format's schema. Spreadsheet sheet names and headers must be declared; no guessed sheet or header row is allowed.

## 4. Required content validation before calculations

`input_validation.m` is the single engineering-data gate. It must validate all of the following before any model module is invoked:

| Check | Required treatment |
|---|---|
| Schema version | Validate file/sidecar schema ID against manifest and supported migration table. Reject unknown major versions. |
| Headers/columns | Exact required header set or an explicitly versioned mapping; reject missing/duplicate headers. |
| Units | Every numeric field has declared units and basis. Convert only through explicit, dimensionally checked conversion functions. Pressure is MPa absolute internally. |
| Missing values | Unknown is null/blank plus data status; do not impute zero. Required missing data block only dependent model blocks where possible. |
| Duplicates | Primary IDs unique within declared scope; duplicate source IDs/rows are diagnostic or fatal per schema. |
| Ranges | Validate numeric type, finite values, positivity/nonnegativity and correlation/operating validity intervals. No silent extrapolation. |
| Component identity | Every stream/reaction component ID resolves to the canonical component register; formula and molecular weight have source lineage. |
| Reaction identity | Independent/dependent columns, exact rank and element conservation are checked. No dependent reaction double-counting. |
| Composition | Mole/mass basis explicit. Sum-to-one is enforced only for complete compositions; incomplete analyses are not renormalised. |
| Provenance | Each source-backed/calculated/assumed numeric value carries source ID, source location/record, provenance class and approval status. |
| Workbook structure | Required workbook/sheet names, header rows, required columns and units checked against manifest/schema. Hidden sheets do not satisfy requirements unless declared. |
| Integrity | SHA-256 of every resolved source must match its manifest digest before ingestion. |

The data schema contract is stored at `data/schemas/ENERGY008_Data_Schema_Contract.json`. The independent Prompt 17 fixture schema is pinned in `data/schemas/ENERGY008_Benchmark_Fixture_Schema.json`. The source fixture itself is preserved unchanged and exposes `revision=0.1-DRAFT`, not a `schema_version` field; its schema version is therefore pinned by the sidecar and manifest. Prompt 19 must validate the fixture against that sidecar without editing the raw fixture.

## 5. Missing-data and blocked-state rules

The Prompt 16 status vocabulary remains authoritative:

- `CALCULATED`: all required data and acceptance gates passed.
- `REFERENCE_ONLY`: algebraic or standard-state benchmark only.
- `SCREENING_ONLY`: limited estimate with explicit assumptions and validity.
- `BLOCKED`: required data/property/model/vendor/site input is unavailable or unvalidated.
- `FAILED`: numerical or physical acceptance gate failed; preserve residuals and last iterate.
- `NOT_RUN`: calculation intentionally not executed.

A `BLOCKED` value is null and carries a reason, dependency ID, source needed and remediation. It is not a zero flow, zero duty, zero cost or successful calculation.

Current known blockers include high-pressure mixture EOS/BIP matrix, MeOH-water VLE, measured raw CO2 composition, source impurities, catalyst-matched kinetic parameters, actual process stream states, ALK OEM voltage/performance maps, compressor performance maps, cooling/steam supply conditions, site tariffs and grid emission factors. Physical S-209 recycle and S-207 purge remain `NOT_RUN/BLOCKED`. Plant energy and exergy closure remain blocked.

## 6. Actionable error catalogue

| Error ID | Trigger | Required message/remediation |
|---|---|---|
| `ENERGY008:RootNotFound` | Marker/config not found above entry point | Extract complete folder; confirm marker and `MATLAB/project_config.json` remain together. |
| `ENERGY008:ConfigProjectMismatch` | Config project ID mismatch | Restore the project-controlled config or correct under change control. |
| `ENERGY008:UnsafePathPolicy` | Runtime path includes undeclared folder or genpath behavior | Use only configured source roots; do not add data, output, test or archive folders. |
| `ENERGY008:ManifestMissing` | Configured manifest missing | Restore `data/data_manifest.json` or correct its root-relative config path. |
| `ENERGY008:ConfigParseFailure` | Configuration JSON is malformed | Restore valid JSON and re-run the static package check before launching MATLAB. |
| `ENERGY008:ManifestParseFailure` | Data manifest JSON is malformed | Restore the manifest or validate the edited JSON before startup. |
| `ENERGY008:DataRootMissing` / `ENERGY008:DataRootOutsideProject` | Declared data root is absent or escapes the root | Restore the declared folder or revise the root-relative allow-list under change control. |
| `ENERGY008:HashUnavailable` | MATLAB JVM is unavailable | Use a JVM-enabled MATLAB session; hash verification is not bypassed. |
| `ENERGY008:PrematureSolverEnable` | A configuration enables solver execution before Prompt 19 | Restore both calculation and solver flags to `false`. |
| `ENERGY008:DataMissing` | Required source not found | Check file placement and exact filename; update the manifest only after confirming the intended source. |
| `ENERGY008:DataAmbiguous` | More than one candidate | Review listed paths and explicitly select one in the manifest. |
| `ENERGY008:UnsupportedFormat` | Extension not declared | Convert through a controlled, logged transformation or add a tested parser/schema. |
| `ENERGY008:HashMismatch` | File differs from controlled snapshot | Restore original or formally revise source/version and manifest digest. |
| `ENERGY008:SchemaUnsupported` | Unknown schema ID/version | Add a reviewed migration adapter and regression tests; do not guess. |
| `ENERGY008:UnitsInvalid` | Missing or incompatible units | Supply units and conversion source; do not assume SI by column position. |
| `ENERGY008:CompositionInvalid` | Complete composition fails closure or basis unclear | Correct assay or declare incomplete status and block dependent models. |
| `ENERGY008:PropertyUnavailable` | Required property absent/blocked | Identify property ID, state, source/model and required validation evidence. |
| `ENERGY008:PropertyOutOfRange` | T outside correlation range | Obtain valid data/model; no extrapolation by default. |
| `ENERGY008:ToolboxUnavailable` | Selected solver dependency absent | Install/license approved toolbox or use a separately validated base-MATLAB method. |
| `ENERGY008:InfeasibleCondition` | Negative flows, invalid extent, impossible state/equipment constraint | Report violated physical bound and upstream IDs; do not clip. |
| `ENERGY008:SolverFailure` | Nonconvergence or numerical instability | Preserve final iterate, residual vector, scaling, bounds, algorithm, iterations and recovery attempts. |
| `ENERGY008:BalanceFailure` | Independent conservation/energy gate fails | Reject result and report residual against absolute/relative limit. |
| `ENERGY008:ImplementationPending` | Interface module called before Prompt 19 | Implement and verify module; do not interpret as a calculated result. |

## 7. Logging and file preservation

Every run must log the selected configuration, manifest hash, data paths/hashes, MATLAB release, run ID, status, warnings and errors. Prompt 19 adds module versions, toolbox versions, solver settings, residuals, and diagnostics. Logs are append-by-new-file, not append-overwriting an existing run. Outputs are stored in unique run-specific folders and prior runs remain untouched.

## 8. Discovery regression tests for Prompt 19

The test suite shall include:

1. Copy/extract to a new path and run from an unrelated MATLAB current folder.
2. Remove one required source and confirm `DataMissing`.
3. Duplicate one exact filename under another configured root and confirm `DataAmbiguous` with both paths.
4. Add duplicate regex matches and confirm hard stop.
5. Place a similarly named file outside configured roots and confirm it is ignored.
6. Change a source byte and confirm `HashMismatch`.
7. Change a declared file extension to an unsupported format and confirm rejection.
8. Supply malformed config/manifest schema versions and confirm rejection.
9. Confirm only `MATLAB/` enters the runtime path; `gui/`, tests, data, outputs, logs and archives remain off path.
10. Confirm no prior run output or log is overwritten.


## Dataset validation boundary for Prompt 19

Prompt 18's startup resolver establishes file-level integrity only: configuration and manifest schema IDs, root-contained paths, allow-listed locations, exactly declared extensions, explicit path/exact-name/optional documented-regex resolution, ambiguity rejection and SHA-256. It deliberately does not parse the workbook/csv/json records into engineering objects.

Before any Prompt 19 calculation module may consume a file, `input_validation.m` must implement the complete schema-level and semantic validation contract in `data/schemas/ENERGY008_Data_Schema_Contract.json` and each dataset entry in `data/data_manifest.json`. This includes exact workbook sheet names where declared, headers and required columns, unit names/bases, null-vs-zero handling, missing values, duplicate IDs, physical/correlation ranges, component/reaction/stream/equipment/utility/scenario/KPI identities, reaction rank and elemental closure, complete/incomplete composition handling, source metadata, provenance, approval status, schema version and source hashes. Invalid or unsupported inputs fail with the relevant `ENERGY008:*` code and a remediation message. A schema check not yet implemented is not to be represented as passed.

`data_manifest.json` includes the archived Prompt 5 `ENERGY008_Data_Manifest.csv` and `data_version.json` as lineage evidence; it does not mean every historical file listed in those prior manifests is included in this Prompt 18 source bundle. Only files explicitly present in the current manifest are discoverable here.


### Source-archive scope

The current manifest includes 43 explicit source snapshots and reference files. Prompt 15 control sequence, mode/disturbance matrices and editable PID source are also archived for the Prompt 19 control module. Prompt 16's top-level, solver and automation state flowcharts are retained as DOT/SVG/PNG artifacts. Prompt 17's manual calculation workbook and independent-check CSV are retained alongside the independent JSON fixture and calculation report. These references are discoverable only by their manifest entries, source hashes and allow-listed roots.
