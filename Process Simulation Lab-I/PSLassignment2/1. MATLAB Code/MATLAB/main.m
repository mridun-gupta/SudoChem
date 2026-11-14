function run = main(projectRoot, configPath)
%MAIN Prompt 18 startup orchestrator. Does not execute process calculations.
%   run = main(projectRoot, configPath)
%   Resolves the project data manifest, verifies configured file formats and
%   SHA-256 hashes, creates a unique run directory, and writes run logs.
%   All calculation-engine orchestration is deliberately deferred to Prompt 19.

if nargin ~= 2
    error('ENERGY008:MainArguments', 'Usage: run = main(projectRoot, configPath).');
end
projectRoot = char(projectRoot);
configPath = char(configPath);
if exist(projectRoot, 'dir') ~= 7
    error('ENERGY008:ProjectRootMissing', 'Project root does not exist: %s', projectRoot);
end
markerPath = fullfile(projectRoot, '.energy008-root');
if exist(markerPath, 'file') ~= 2 || isempty(strfind(fileread(markerPath), 'ENERGY008_PROJECT_ID=ENERGY-008')) %#ok<STREMP>
    error('ENERGY008:MarkerInvalid', 'Project marker is missing or does not identify ENERGY-008.');
end
expectedConfig = fullfile(projectRoot, 'MATLAB', 'project_config.json');
if exist(configPath, 'file') ~= 2 || ~samePath(configPath, expectedConfig) || ~isWithinRoot(projectRoot, configPath)
    error('ENERGY008:ConfigPathUnexpected', 'Configuration must be MATLAB/project_config.json under the detected project root: %s', expectedConfig);
end

% Prepare project-contained output roots. Check each parent before creating children.
defaultOutputRoot = fullfile(projectRoot, 'outputs');
defaultReportRoot = fullfile(projectRoot, 'outputs', 'reports');
defaultLogRoot = fullfile(projectRoot, 'logs');
ensureDirectory(defaultOutputRoot);
if ~isWithinRoot(projectRoot, defaultOutputRoot)
    error('ENERGY008:OutputPathOutsideProject', 'outputs resolves outside the project root. Check for a symlinked folder.');
end
ensureDirectory(defaultReportRoot);
if ~isWithinRoot(projectRoot, defaultReportRoot)
    error('ENERGY008:ReportPathOutsideProject', 'outputs/reports resolves outside the project root.');
end
ensureDirectory(defaultLogRoot);
if ~isWithinRoot(projectRoot, defaultLogRoot)
    error('ENERGY008:LogPathOutsideProject', 'logs resolves outside the project root.');
end
runId = createRunId(defaultOutputRoot);
runDirectory = fullfile(defaultOutputRoot, runId);
reportDirectory = fullfile(runDirectory, 'reports');
ensureDirectory(runDirectory);
ensureDirectory(reportDirectory);
if ~isWithinRoot(projectRoot, runDirectory) || ~isWithinRoot(projectRoot, reportDirectory)
    error('ENERGY008:RunDirectoryOutsideProject', 'Run and report folders must resolve inside the project root.');
end
logJson = fullfile(defaultLogRoot, [runId '.json']);
logText = fullfile(defaultLogRoot, [runId '.log']);

run = struct();
run.project_id = 'ENERGY-008';
run.project_root = projectRoot;
run.run_id = runId;
run.started_local = datestr(now, 'yyyy-mm-ddTHH:MM:SS');
run.matlab_version = version;
run.software_version = version;
run.data_integrity = 'NOT_VERIFIED';
run.computer = computer;
run.status = 'STARTUP_IN_PROGRESS';
run.calculation_status = 'NOT_RUN';
run.implementation_gate = 'PROMPT_19_REQUIRED';
run.run_directory = runDirectory;
run.report_directory = reportDirectory;
run.log_json = logJson;
run.log_text = logText;
run.resolved_data = struct([]);
run.warnings = {};
run.errors = {};
run.configuration = struct();

try
    if exist(configPath, 'file') ~= 2 || exist(markerPath, 'file') ~= 2
        error('ENERGY008:ProjectControlFileMissing', 'Project marker or configuration disappeared during startup.');
    end
    run.config_path = configPath;
    run.config_sha256 = sha256_file(configPath);
    try
        cfg = jsondecode(fileread(configPath));
    catch parseME
        error('ENERGY008:ConfigParseFailure', 'Could not parse project_config.json: %s', parseME.message);
    end
    run.configuration = cfg;
    validateProjectConfig(projectRoot, configPath, cfg);

    paths = cfg.paths;
    manifestPath = resolveRootRelative(projectRoot, char(paths.data_manifest));
    if exist(manifestPath, 'file') ~= 2
        error('ENERGY008:ManifestMissing', 'Data manifest not found: %s', manifestPath);
    end
    if ~isWithinRoot(projectRoot, manifestPath)
        error('ENERGY008:ManifestOutsideProject', 'Data manifest must be inside the project root: %s', manifestPath);
    end
    run.manifest_path = manifestPath;
    run.manifest_sha256 = sha256_file(manifestPath);
    try
        manifest = jsondecode(fileread(manifestPath));
    catch parseME
        error('ENERGY008:ManifestParseFailure', 'Could not parse data_manifest.json: %s', parseME.message);
    end
    validateManifest(manifest, cfg.project_id);

    allowedRoots = toCellText(paths.data_roots);
    manifestRoots = toCellText(manifest.discovery_policy.allowed_roots);
    if ~isequal(sort(allowedRoots), sort(manifestRoots))
        error('ENERGY008:DataRootPolicyMismatch', 'project_config.json paths.data_roots must exactly match data_manifest.json discovery_policy.allowed_roots.');
    end
    allowedFormats = [toCellText(cfg.formats.runtime_data), toCellText(cfg.formats.project_documentation), ...
        toCellText(cfg.formats.flowcharts), toCellText(cfg.formats.project_source_assets)];
    [catalog, discoveryWarnings] = resolve_project_data(projectRoot, manifest, allowedRoots, allowedFormats, cfg.run_control.verify_sha256);
    run.resolved_data = catalog;
    run.warnings = [run.warnings, discoveryWarnings];
    run.data_integrity = 'SHA256_VERIFIED';
    run.status = 'STARTUP_READY';
    run.calculation_status = 'NOT_RUN';
    run.note = ['Architecture and startup are prepared. No material, energy, entropy/exergy, ' ...
        'equipment, utilities, control or economic solver has been executed.'];
    run.finished_local = datestr(now, 'yyyy-mm-ddTHH:MM:SS');
    if ~isWithinRoot(projectRoot, runDirectory) || ~isWithinRoot(projectRoot, reportDirectory) || ...
            ~isWithinRoot(projectRoot, defaultLogRoot)
        error('ENERGY008:RunDirectoryOutsideProject', 'Run, report and log directories must remain inside the project root.');
    end
    writeRunLog(run, logJson, logText);
catch ME
    run.status = 'STARTUP_FAILED';
    run.calculation_status = 'NOT_RUN';
    run.finished_local = datestr(now, 'yyyy-mm-ddTHH:MM:SS');
    run.errors = {struct('identifier', ME.identifier, 'message', ME.message)};
    try
        writeRunLog(run, logJson, logText);
    catch logME
        warning('ENERGY008:LogWriteFailure', 'Could not persist startup failure log: %s', logME.message);
    end
    rethrow(ME);
end
end

function validateProjectConfig(projectRoot, configPath, cfg)
if ~isstruct(cfg) || ~isscalar(cfg)
    error('ENERGY008:ConfigStructureInvalid', 'project_config.json must contain one JSON object at the top level.');
end
required = {'project_id','config_schema_version','paths','formats','run_control','execution_policy','toolbox_policy'};
for k = 1:numel(required)
    if ~isfield(cfg, required{k})
        error('ENERGY008:ConfigFieldMissing', 'project_config.json is missing required field: %s', required{k});
    end
end
if ~strcmp(char(cfg.project_id), 'ENERGY-008')
    error('ENERGY008:ConfigProjectMismatch', 'project_id must equal ENERGY-008.');
end
if ~strcmp(char(cfg.config_schema_version), 'ENERGY008-PROJECT-CONFIG-0.1.0')
    error('ENERGY008:ConfigSchemaUnsupported', 'Unsupported config_schema_version: %s', char(cfg.config_schema_version));
end
nestedConfig = {'paths','formats','run_control','execution_policy','toolbox_policy'};
for k = 1:numel(nestedConfig)
    if ~isstruct(cfg.(nestedConfig{k})) || ~isscalar(cfg.(nestedConfig{k}))
        error('ENERGY008:ConfigStructureInvalid', 'project_config.json field %s must be a JSON object.', nestedConfig{k});
    end
end
if ~samePath(configPath, fullfile(projectRoot, 'MATLAB', 'project_config.json'))
    error('ENERGY008:ConfigPathUnexpected', 'Configuration must be MATLAB/project_config.json under the marker root.');
end

pathFields = {'runtime_path_folders','gui_path_folders','data_manifest','data_roots','outputs','reports','logs','flowcharts','docs','tests'};
for k = 1:numel(pathFields)
    if ~isfield(cfg.paths, pathFields{k})
        error('ENERGY008:ConfigPathPolicyMissing', 'paths.%s is required.', pathFields{k});
    end
end
sourcePaths = toCellText(cfg.paths.runtime_path_folders);
if numel(sourcePaths) ~= 1 || ~strcmp(sourcePaths{1}, 'MATLAB')
    error('ENERGY008:UnsafePathPolicy', 'Prompt 18 permits only MATLAB as a runtime path folder.');
end
guiPaths = toCellText(cfg.paths.gui_path_folders);
if numel(guiPaths) ~= 1 || ~strcmp(guiPaths{1}, 'MATLAB/gui')
    error('ENERGY008:UnsafeGuiPathPolicy', ...
        'Only the project-controlled MATLAB/gui folder may be declared for explicit GUI launch.');
end
guiFull = resolveRootRelative(projectRoot, guiPaths{1});
if exist(guiFull, 'dir') ~= 7 || ~isWithinRoot(projectRoot, guiFull)
    error('ENERGY008:GuiFolderInvalid', 'The declared GUI folder is missing or outside the project root.');
end
% START_HERE intentionally adds only MATLAB/; run_gui.m adds MATLAB/gui/ after
% a separate marker/config/path check when the user explicitly launches the UI.
if ~strcmp(char(cfg.paths.data_manifest), 'data/data_manifest.json')
    error('ENERGY008:ManifestPathUnexpected', 'Prompt 18 baseline expects data/data_manifest.json.');
end
if ~strcmp(char(cfg.paths.outputs), 'outputs') || ~strcmp(char(cfg.paths.reports), 'outputs/reports') || ...
        ~strcmp(char(cfg.paths.logs), 'logs') || ~strcmp(char(cfg.paths.flowcharts), 'flowcharts') || ...
        ~strcmp(char(cfg.paths.docs), 'MATLAB/docs') || ~strcmp(char(cfg.paths.tests), 'MATLAB/tests')
    error('ENERGY008:RunPathUnexpected', 'Configured output/documentation/test paths differ from the controlled project layout.');
end

formatFields = {'runtime_data','project_documentation','flowcharts','project_source_assets','explicitly_unsupported'};
for q = 1:numel(formatFields)
    if ~isfield(cfg.formats, formatFields{q})
        error('ENERGY008:FormatPolicyMissing', 'formats.%s must be declared.', formatFields{q});
    end
end
allowedFormatFields = {'runtime_data','project_documentation','flowcharts','project_source_assets'};
allAllowed = {};
for q = 1:numel(allowedFormatFields)
    formats = toCellText(cfg.formats.(allowedFormatFields{q}));
    if isempty(formats) && ~strcmp(allowedFormatFields{q}, 'project_source_assets')
        error('ENERGY008:FormatPolicyMissing', 'formats.%s must be a nonempty declared list.', allowedFormatFields{q});
    end
    for j = 1:numel(formats)
        if isempty(regexp(formats{j}, '^\.[A-Za-z0-9]+$', 'once'))
            error('ENERGY008:FormatExtensionInvalid', 'Invalid extension in formats.%s: %s', allowedFormatFields{q}, formats{j});
        end
    end
    allAllowed = [allAllowed, formats]; %#ok<AGROW>
end
unsupported = toCellText(cfg.formats.explicitly_unsupported);
if any(ismember(lowerCell(allAllowed), lowerCell(unsupported)))
    error('ENERGY008:FormatPolicyConflict', 'A format cannot be both supported and explicitly unsupported.');
end

roots = toCellText(cfg.paths.data_roots);
if isempty(roots) || numel(unique(roots)) ~= numel(roots)
    error('ENERGY008:DataRootPolicyInvalid', 'data_roots must be a nonempty unique list.');
end
for k = 1:numel(roots)
    rel = char(roots{k});
    full = resolveRootRelative(projectRoot, rel);
    if ~isWithinRoot(projectRoot, full)
        error('ENERGY008:DataRootOutsideProject', 'Configured data root is outside the project: %s', rel);
    end
    if exist(full, 'dir') ~= 7
        error('ENERGY008:DataRootMissing', 'Configured data root does not exist: %s', full);
    end
end

runFields = {'calculation_engine_enabled','overwrite_outputs','create_unique_run_directory', ...
    'write_json_run_log','write_text_run_log','verify_sha256','fail_on_hash_mismatch', ...
    'fail_on_ambiguous_data','allow_solver_execution'};
for k = 1:numel(runFields)
    if ~isfield(cfg.run_control, runFields{k})
        error('ENERGY008:RunControlFieldMissing', 'run_control.%s is required.', runFields{k});
    end
end
if cfg.run_control.overwrite_outputs ~= false
    error('ENERGY008:OverwritePolicyInvalid', 'overwrite_outputs must be false in the Prompt 18 baseline.');
end
if cfg.run_control.create_unique_run_directory ~= true || cfg.run_control.write_json_run_log ~= true || cfg.run_control.write_text_run_log ~= true
    error('ENERGY008:RunControlPolicyInvalid', 'Unique run directories and both run logs must be enabled.');
end
if cfg.run_control.verify_sha256 ~= true || cfg.run_control.fail_on_hash_mismatch ~= true || cfg.run_control.fail_on_ambiguous_data ~= true
    error('ENERGY008:IntegrityPolicyInvalid', 'SHA-256 verification, fail-on-mismatch and fail-on-ambiguity must be enabled.');
end
if cfg.run_control.calculation_engine_enabled ~= false || cfg.run_control.allow_solver_execution ~= false
    error('ENERGY008:PrematureSolverEnable', 'Calculation execution is prohibited until Prompt 19 implements and validates the modules.');
end

policyFlags = {'never_use_pwd_for_root_or_data_resolution','never_addpath_genpath','never_scan_outside_data_roots', ...
    'never_zero_fill_missing_data','stop_on_multiple_matches','block_unsupported_property_calls','gui_separate_from_engine'};
for q = 1:numel(policyFlags)
    if ~isfield(cfg.execution_policy, policyFlags{q}) || cfg.execution_policy.(policyFlags{q}) ~= true
        error('ENERGY008:UnsafeExecutionPolicy', 'execution_policy.%s must remain true.', policyFlags{q});
    end
end
if ~isfield(cfg.toolbox_policy, 'required_toolboxes_for_prompt18_startup') || ...
        ~isempty(toCellText(cfg.toolbox_policy.required_toolboxes_for_prompt18_startup))
    error('ENERGY008:UnexpectedStartupToolbox', 'Prompt 18 startup must not require additional MATLAB toolboxes.');
end
end

function validateManifest(manifest, projectId)
if ~isstruct(manifest) || ~isscalar(manifest)
    error('ENERGY008:ManifestStructureInvalid', 'data_manifest.json must contain one JSON object at the top level.');
end
required = {'manifest_schema_version','project_id','discovery_policy','datasets','schema_validation_policy'};
for k = 1:numel(required)
    if ~isfield(manifest, required{k})
        error('ENERGY008:ManifestFieldMissing', 'Data manifest is missing field: %s', required{k});
    end
end
if ~strcmp(char(manifest.project_id), char(projectId))
    error('ENERGY008:ManifestProjectMismatch', 'Data manifest project_id does not match project_config.json.');
end
if ~strcmp(char(manifest.manifest_schema_version), 'ENERGY008-DATA-MANIFEST-0.1.0')
    error('ENERGY008:ManifestSchemaUnsupported', 'Unsupported data manifest schema: %s', char(manifest.manifest_schema_version));
end
if ~isstruct(manifest.discovery_policy) || ~isscalar(manifest.discovery_policy) || ...
        ~isstruct(manifest.schema_validation_policy) || ~isscalar(manifest.schema_validation_policy) || ...
        ~isstruct(manifest.datasets)
    error('ENERGY008:ManifestStructureInvalid', 'Manifest discovery_policy/schema_validation_policy must be objects and datasets must be an array of objects.');
end
policy = manifest.discovery_policy;
policyFields = {'allowed_roots','explicit_path_first','exact_filename_second','regex_fallback_only_when_declared', ...
    'multiple_matches','zero_matches','case_sensitive_exact_filename','recursive_search_within_allowed_roots','never_select_first_match'};
for k = 1:numel(policyFields)
    if ~isfield(policy, policyFields{k})
        error('ENERGY008:DiscoveryPolicyFieldMissing', 'discovery_policy.%s is required.', policyFields{k});
    end
end
if policy.explicit_path_first ~= true || policy.exact_filename_second ~= true || ...
        policy.regex_fallback_only_when_declared ~= true || policy.case_sensitive_exact_filename ~= true || ...
        policy.recursive_search_within_allowed_roots ~= true || policy.never_select_first_match ~= true || ...
        ~strcmp(char(policy.multiple_matches), 'STOP_AND_REPORT_CANDIDATES') || ...
        ~strcmp(char(policy.zero_matches), 'ERROR_IF_REQUIRED')
    error('ENERGY008:UnsafeDiscoveryPolicy', 'Manifest discovery policy does not match the explicit, exact, unambiguous baseline.');
end
if isempty(toCellText(policy.allowed_roots)) || isempty(manifest.datasets)
    error('ENERGY008:ManifestEmpty', 'Manifest must contain allow-listed roots and declared datasets.');
end
if ~isfield(manifest.schema_validation_policy, 'implementation_phase') || ...
        ~strcmp(char(manifest.schema_validation_policy.implementation_phase), 'PROMPT_19')
    error('ENERGY008:SchemaGateMismatch', 'Record-level schema validation must remain assigned to Prompt 19.');
end

ids = cell(1, numel(manifest.datasets));
logicalNames = cell(1, numel(manifest.datasets));
requiredDatasetFields = {'dataset_id','logical_name','explicit_path','exact_filename','format','required', ...
    'role','schema_id','source_version','expected_sha256','required_sheets','required_columns', ...
    'match_regex','match_rule_description','source_metadata'};
for k = 1:numel(manifest.datasets)
    ds = manifest.datasets(k);
    for j = 1:numel(requiredDatasetFields)
        if ~isfield(ds, requiredDatasetFields{j})
            error('ENERGY008:DatasetManifestFieldMissing', 'Dataset entry %d is missing field %s.', k, requiredDatasetFields{j});
        end
    end
    ids{k} = char(ds.dataset_id);
    logicalNames{k} = char(ds.logical_name);
    if isempty(ids{k}) || isempty(logicalNames{k}) || isempty(char(ds.schema_id)) || isempty(char(ds.source_version)) || isempty(char(ds.exact_filename))
        error('ENERGY008:DatasetManifestMetadataMissing', 'Dataset entry %d needs ID, logical name, schema ID and source version.', k);
    end
    if ~isstruct(ds.source_metadata) || ~isscalar(ds.source_metadata)
        error('ENERGY008:DatasetSourceMetadataInvalid', 'Dataset %s source_metadata must be an object.', ids{k});
    end
    sourceFields = {'source_phase','source_file_name','snapshot_policy','model_use'};
    for q = 1:numel(sourceFields)
        if ~isfield(ds.source_metadata, sourceFields{q}) || isempty(char(ds.source_metadata.(sourceFields{q})))
            error('ENERGY008:DatasetSourceMetadataInvalid', 'Dataset %s source_metadata.%s is required.', ids{k}, sourceFields{q});
        end
    end
    if ~strcmp(char(ds.source_metadata.source_file_name), char(ds.exact_filename))
        error('ENERGY008:DatasetSourceMetadataInvalid', 'Dataset %s source_file_name must match exact_filename.', ids{k});
    end
    if ~islogical(ds.required) || ~isscalar(ds.required)
        error('ENERGY008:DatasetRequiredFlagInvalid', 'Dataset %s required flag must be a logical scalar.', ids{k});
    end
    if ~isempty(ds.explicit_path)
        pathText = char(ds.explicit_path);
        parts = strsplit(strrep(pathText, char(92), '/'), '/');
        if pathText(1) == '/' || ~isempty(regexp(pathText, '^[A-Za-z]:', 'once')) || any(strcmp(parts, '..'))
            error('ENERGY008:DatasetPathUnsafe', 'Dataset %s explicit_path must be project-relative without traversal.', ids{k});
        end
        [~, explicitBase, explicitExt] = fileparts(pathText);
        if ~strcmp([explicitBase explicitExt], char(ds.exact_filename))
            error('ENERGY008:DatasetFilenameContractMismatch', 'Dataset %s exact_filename must match the basename of explicit_path.', ids{k});
        end
    end
    formatText = lower(char(ds.format));
    if isempty(regexp(formatText, '^[a-z0-9]+$', 'once'))
        error('ENERGY008:DatasetFormatInvalid', 'Dataset %s has an invalid format token.', ids{k});
    end
    hashValue = char(ds.expected_sha256);
    if isempty(regexp(hashValue, '^[A-Fa-f0-9]{64}$', 'once'))
        error('ENERGY008:DatasetHashInvalid', 'Dataset %s must declare a 64-character SHA-256 hash.', ids{k});
    end
    if ~isempty(ds.match_regex)
        if ~isfield(ds, 'match_rule_description') || isempty(ds.match_rule_description)
            error('ENERGY008:UndocumentedMatchRule', 'Dataset %s declares regex matching without a documented rule.', ids{k});
        end
    end
    sheetNames = toCellText(ds.required_sheets); % Enforce declared sheet-list type.
    columns = toCellText(ds.required_columns); % Enforce declared column-list type.
    if strcmpi(formatText, 'xlsx') && isempty(sheetNames)
        error('ENERGY008:DatasetSheetContractMissing', 'Workbook dataset %s must declare required_sheets.', ids{k});
    end
    if strcmpi(formatText, 'csv') && isempty(columns)
        error('ENERGY008:DatasetColumnContractMissing', 'CSV dataset %s must declare required_columns.', ids{k});
    end
    if numel(unique(sheetNames)) ~= numel(sheetNames) || numel(unique(columns)) ~= numel(columns)
        error('ENERGY008:DuplicateDatasetContractField', 'Dataset %s contains duplicate required sheet or column names.', ids{k});
    end
end
if numel(unique(ids)) ~= numel(ids)
    error('ENERGY008:DuplicateDatasetId', 'Data manifest contains duplicate dataset_id values.');
end
if numel(unique(logicalNames)) ~= numel(logicalNames)
    error('ENERGY008:DuplicateLogicalDatasetName', 'Data manifest contains duplicate logical_name values.');
end
end

function values = lowerCell(values)
for q = 1:numel(values), values{q} = lower(values{q}); end
end

function tf = samePath(a, b)
[okA, aa] = fileattrib(a); if okA, a = aa.Name; end
[okB, bb] = fileattrib(b); if okB, b = bb.Name; end
if ispc, tf = strcmpi(char(a), char(b)); else, tf = strcmp(char(a), char(b)); end
end

function p = resolveRootRelative(root, rel)
rel = strrep(char(rel), char(92), '/');
parts = strsplit(rel, '/');
if isempty(rel) || rel(1)=='/' || ~isempty(regexp(rel, '^[A-Za-z]:', 'once')) || any(strcmp(parts, '..'))
    error('ENERGY008:UnsafeRelativePath', 'Path must be project-relative and cannot contain parent traversal: %s', rel);
end
p = fullfile(root, rel);
if ~isWithinRoot(root, p)
    error('ENERGY008:PathOutsideProject', 'Resolved path is outside project root: %s', rel);
end
end

function tf = isWithinRoot(root, candidate)
[okRoot, a] = fileattrib(root);
[okFile, b] = fileattrib(candidate);
if okRoot, rootName = a.Name; else, rootName = root; end
if okFile, fileName = b.Name; else, fileName = candidate; end
rootName = char(rootName); fileName = char(fileName);
prefix = [rootName filesep];
if ispc
    tf = strcmpi(fileName, rootName) || strncmpi(fileName, prefix, numel(prefix));
else
    tf = strcmp(fileName, rootName) || strncmp(fileName, prefix, numel(prefix));
end
end

function values = toCellText(value)
if iscell(value)
    values = cell(size(value));
    for q = 1:numel(value), values{q} = char(value{q}); end
elseif isstring(value)
    values = cellstr(value);
elseif ischar(value)
    values = {value};
elseif isempty(value)
    values = {};
else
    error('ENERGY008:ConfigTypeInvalid', 'Expected a string or string array in project configuration.');
end
end

function ensureDirectory(folder)
if exist(folder, 'dir') ~= 7
    [ok, msg] = mkdir(folder);
    if ~ok
        error('ENERGY008:DirectoryCreateFailed', 'Could not create directory %s: %s', folder, msg);
    end
end
end

function runId = createRunId(outputRoot)
stamp = datestr(now, 'yyyymmdd_HHMMSS');
for attempt = 1:100
    token = regexprep(tempname, '[^A-Za-z0-9]', '');
    token = token(max(1, numel(token)-7):end);
    candidate = ['run_' stamp '_' token];
    candidatePath = fullfile(outputRoot, candidate);
    if exist(candidatePath, 'dir') ~= 7
        runId = candidate;
        return;
    end
end
error('ENERGY008:RunIdExhausted', 'Could not allocate a unique output run directory.');
end

function writeRunLog(run, jsonPath, textPath)
if exist(jsonPath, 'file') == 2 || exist(textPath, 'file') == 2
    error('ENERGY008:LogCollision', 'Refusing to overwrite an existing run log for run ID %s.', run.run_id);
end
jsonText = jsonencode(run);
fid = fopen(jsonPath, 'w');
if fid < 0, error('ENERGY008:LogWriteFailed', 'Cannot open JSON run log: %s', jsonPath); end
cleaner = onCleanup(@() fclose(fid));
fwrite(fid, jsonText, 'char');
fprintf(fid, '\n');
clear cleaner;
fid = fopen(textPath, 'w');
if fid < 0, error('ENERGY008:LogWriteFailed', 'Cannot open text run log: %s', textPath); end
cleaner = onCleanup(@() fclose(fid));
fprintf(fid, 'ENERGY-008 RUN LOG\nRun ID: %s\nStatus: %s\nCalculation status: %s\nProject root: %s\nMATLAB/software version: %s\nStarted: %s\nFinished: %s\nData integrity: %s\n', ...
    run.run_id, run.status, run.calculation_status, run.project_root, run.matlab_version, run.started_local, run.finished_local, run.data_integrity);
if isfield(run, 'config_sha256'), fprintf(fid, 'CONFIG SHA256: %s\n', run.config_sha256); end
if isfield(run, 'manifest_sha256'), fprintf(fid, 'MANIFEST SHA256: %s\n', run.manifest_sha256); end
if isfield(run, 'resolved_data')
    for k=1:numel(run.resolved_data)
        fprintf(fid, 'DATA %s | %s | %s | SHA256 %s\n', run.resolved_data(k).dataset_id, run.resolved_data(k).logical_name, run.resolved_data(k).resolved_path, run.resolved_data(k).sha256);
    end
end
if isfield(run, 'warnings')
    for k=1:numel(run.warnings), fprintf(fid, 'WARNING: %s\n', char(run.warnings{k})); end
end
if isfield(run, 'errors')
    for k=1:numel(run.errors)
        fprintf(fid, 'ERROR %s: %s\n', run.errors{k}.identifier, run.errors{k}.message);
    end
end
clear cleaner;
end
