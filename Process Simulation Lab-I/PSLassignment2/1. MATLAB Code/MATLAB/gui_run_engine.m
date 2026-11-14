function [R, meta] = gui_run_engine(projectRoot, cfg, selectedCase, throughputKgDay, operatingHoursPerDay)
%GUI_RUN_ENGINE Run the Prompt 19 modules for one GUI-selected case.
% This function orchestrates existing engine modules. It contains no process equations.
% All calculations remain in input_validation/property_models/material_balance/etc.

narginchk(5,5);
R = struct();
meta = struct('project_id','ENERGY-008','status','STARTUP_IN_PROGRESS', ...
    'calculation_status','NOT_RUN','data_integrity','NOT_VERIFIED','warnings',{{}},'errors',{{}});
runId = createRunId(fullfile(projectRoot,'outputs'));
meta.run_id = runId;
meta.timestamp_local = datestr(now,'yyyy-mm-ddTHH:MM:SS.FFF');
meta.matlab_version = version;
meta.matlab_release = version('-release');
meta.computer = computer;
meta.project_root = projectRoot;
meta.case_id = char(selectedCase.case_id);
meta.scenario_name = char(selectedCase.scenario_name);
meta.route_id = char(selectedCase.route_id);
meta.case_status = char(selectedCase.case_status);
meta.input_basis = struct('methanol_component_equivalent_kg_day',throughputKgDay, ...
    'operating_hours_per_day',operatingHoursPerDay,'throughput_units','kg/day', ...
    'throughput_provenance','USER_SELECTED_GUI_INPUT_ON_DECLARED_REFERENCE_OR_SCREENING_CASE', ...
    'operating_hours_provenance','USER_SELECTED_GUI_INPUT');
meta.model_version = char(cfg.model_version);
meta.data_version = char(cfg.property_data_version);
meta.design_basis_version = char(cfg.design_basis_version);
meta.assumptions = struct('case_source_ids',{selectedCase.source_ids}, ...
    'case_provenance_class',char(selectedCase.provenance_class), ...
    'R01_conversion_fraction',selectedCase.assumptions.R01_conversion_fraction, ...
    'R01_conversion_status',char(selectedCase.assumptions.R01_conversion_status), ...
    'R02_extent_kmol_day',selectedCase.assumptions.R02_extent_kmol_day, ...
    'R02_extent_status',char(selectedCase.assumptions.R02_extent_status), ...
    'operating_state',selectedCase.operating_state, ...
    'physical_operating_conditions','TBD / BLOCKED; no plant setpoints are assigned');

outputRoot = fullfile(projectRoot,'outputs');
logRoot = fullfile(projectRoot,'logs');
reportRoot = fullfile(projectRoot,'MATLAB','results');
ensureDirectory(outputRoot); ensureDirectory(logRoot); ensureDirectory(reportRoot);
runDirectory = fullfile(outputRoot,runId);
reportDirectory = fullfile(reportRoot,runId);
if exist(runDirectory,'file')==2 || exist(runDirectory,'dir')==7 || ...
        exist(reportDirectory,'file')==2 || exist(reportDirectory,'dir')==7
    error('ENERGY008:GUIRunDirectoryCollision','Refusing to reuse an existing run directory.');
end
ensureDirectory(runDirectory); ensureDirectory(reportDirectory);
meta.run_directory = runDirectory;
meta.report_directory = reportDirectory;
meta.log_json = fullfile(logRoot,[runId '.json']);
meta.log_text = fullfile(logRoot,[runId '.log']);
meta.exports = {};

try
    % Match Prompt 19's manifest, allowed-root and SHA-256 gate before reading model data.
    configPath = fullfile(projectRoot,'MATLAB','project_config.json');
    manifestPath = fullfile(projectRoot,char(cfg.paths.data_manifest));
    if ~withinRoot(projectRoot,configPath) || exist(configPath,'file')~=2
        error('ENERGY008:GUIConfigPathInvalid','The project configuration file is missing or outside the project.');
    end
    if ~withinRoot(projectRoot,manifestPath) || exist(manifestPath,'file')~=2
        error('ENERGY008:GUIManifestMissing','The declared data manifest is missing or outside the project.');
    end
    manifest = jsondecode(fileread(manifestPath));
    if ~isfield(manifest,'project_id') || ~strcmp(char(manifest.project_id),'ENERGY-008')
        error('ENERGY008:GUIManifestProjectMismatch','The data manifest project_id does not match ENERGY-008.');
    end
    allowedRoots = energy008.cellstr_safe(cfg.paths.data_roots);
    manifestRoots = energy008.cellstr_safe(manifest.discovery_policy.allowed_roots);
    if ~isequal(sort(allowedRoots),sort(manifestRoots))
        error('ENERGY008:GUIDataRootPolicyMismatch','The manifest and project configuration allowed roots differ.');
    end
    formats = [energy008.cellstr_safe(cfg.formats.runtime_data), ...
        energy008.cellstr_safe(cfg.formats.project_documentation), ...
        energy008.cellstr_safe(cfg.formats.flowcharts), ...
        energy008.cellstr_safe(cfg.formats.project_source_assets)];
    [~, discoveryWarnings] = resolve_project_data(projectRoot,manifest,allowedRoots,formats,cfg.run_control.verify_sha256);
    meta.data_integrity = 'SHA256_VERIFIED';
    meta.warnings = [meta.warnings,discoveryWarnings];
    configHash = sha256_file(configPath);
    manifestHash = sha256_file(manifestPath);

    modelInput = load_model_inputs(projectRoot,cfg,runId);
    modelInput.source_hashes = struct('configuration',configHash,'manifest',manifestHash);
    meta.source_hashes = modelInput.source_hashes;
    meta.source_files = modelInput.source_files;
    meta.engine_versions = modelInput.versions;
    selected = findCase(modelInput,selectedCase.case_id);
    if isempty(selected)
        error('ENERGY008:GUICaseNotFound','Case %s is not present in the approved case register.',char(selectedCase.case_id));
    end
    selected.methanol_component_equivalent_kg_day = throughputKgDay;
    selected.operating_hours_per_day = operatingHoursPerDay;
    if isfield(selected,'units')
        selected.units.methanol_component_equivalent_kg_day = 'kg/day';
        selected.units.operating_hours_per_day = 'h/day';
    end
    if isfield(selected,'case_id')
        selected.case_id = [char(selected.case_id) '-GUI-' runId];
    end
    selected.provenance_class = 'USER_SELECTED_GUI_INPUT_ON_REFERENCE_OR_SCREENING_CASE';
    modelInput.case_data = selected;
    meta.case_id = char(selected.case_id);
    meta.case_register_id = char(selectedCase.case_id);
    meta.assumptions = struct('case_source_ids',{selected.source_ids}, ...
        'case_provenance_class',char(selected.provenance_class), ...
        'R01_conversion_fraction',selected.assumptions.R01_conversion_fraction, ...
        'R01_conversion_status',char(selected.assumptions.R01_conversion_status), ...
        'R02_extent_kmol_day',selected.assumptions.R02_extent_kmol_day, ...
        'R02_extent_status',char(selected.assumptions.R02_extent_status), ...
        'operating_state',selected.operating_state, ...
        'physical_operating_conditions','TBD / BLOCKED; no plant setpoints are assigned');

    options = struct('run_id',runId,'material_tolerance',1e-8, ...
        'allow_reference_only',true,'allow_screening_only',true, ...
        'allow_solver_execution',false,'overwrite_outputs',false);
    R.input = input_validation(modelInput,struct('scope','gui_selected_case'),options);
    if strcmp(R.input.status,'FAILED')
        R.status = 'RUN_FAILED';
        R.validation = energy008.make_result('validation_checks','NOT_RUN', ...
            struct('reason','Input validation failed; downstream modules were not executed.'),'N/A',modelInput,{}, {},struct(),struct());
        meta.status = 'RUN_FAILED';
        meta.calculation_status = 'FAILED_INPUT_VALIDATION';
        meta.errors = R.input.errors;
        meta.run_finished_local = datestr(now,'yyyy-mm-ddTHH:MM:SS.FFF');
        meta.exports = {'gui_run_metadata.json'};
        saveGuiRun(R,meta,runDirectory,reportDirectory);
        writeRunLogs(meta);
        return;
    end

    R.properties = property_models(modelInput,struct('property_request','all_benchmark'),options);
    R.material = material_balance(modelInput,struct('case_id',modelInput.case_data.case_id),options);
    R.energy = energy_balance(modelInput,struct('material_result',R.material,'property_result',R.properties),options);
    R.entropy = entropy_exergy(modelInput,struct(),options);
    R.reactor = reactor_calculation(modelInput,struct(),options);
    R.recycle = recycle_solver(modelInput,struct(),options);

    if hasMaterialFlows(R.material)
        R.equipment = equipment_sizing(modelInput,struct('energy_result',R.energy,'material_result',R.material),options);
        R.utilities = utilities_model(modelInput,struct('material_result',R.material),options);
        R.control = control_logic(modelInput,struct('material_result',R.material),options);
    else
        unavailable = {'Material reference calculation is not available for the selected case.'};
        R.equipment = blockedResult('equipment_sizing',modelInput,unavailable);
        R.utilities = blockedResult('utilities_model',modelInput,unavailable);
        R.control = blockedResult('control_logic',modelInput,unavailable);
    end
    R.environmental = environmental_kpis(modelInput,struct(),options);
    R.economics = economics(modelInput,struct(),options);
    R.scenarios = scenario_runner(modelInput,struct('control_result',R.control),options);

    % Sensitivity plan is versioned around the Prompt 17 50 t/day Route C basis.
    % It is evaluated on that registered basis, independently of the selected case.
    sensitivityModel = modelInput;
    base50 = findCase(modelInput,'C-BIOCO2-REH2-ALK-REF-50TPD');
    if ~isempty(base50)
        sensitivityModel.case_data = base50;
    end
    R.sensitivity = sensitivity_optimisation(sensitivityModel,struct(),options);

    isFixtureCase = strcmp(char(selected.route_id),'Route C') && ...
        strcmp(char(selected.scenario_type),'STOICHIOMETRIC_REFERENCE') && ...
        abs(throughputKgDay-50000)<=1e-9 && ...
        strcmp(char(selectedCase.case_id),'C-BIOCO2-REH2-ALK-REF-50TPD');
    if isFixtureCase && hasMaterialFlows(R.material) && isfield(R.energy,'value') && isfield(R.equipment,'value')
        R.validation = validation_checks(modelInput,struct('material_result',R.material, ...
            'energy_result',R.energy,'entropy_result',R.entropy, ...
            'utilities_result',R.utilities,'property_result',R.properties, ...
            'equipment_result',R.equipment),options);
    else
        R.validation = energy008.make_result('validation_checks','NOT_RUN', ...
            struct('reason','The Prompt 17 numerical fixture applies only to the Route C 50 t/day ideal stoichiometric base case. This selected case is outside that fixture scope.'), ...
            'N/A',modelInput,{'Fixture regression was not run because the selected case is outside its frozen basis.'},{},struct(),struct());
    end

    moduleWarnings = collectWarnings(R);
    meta.warnings = [meta.warnings(:)',moduleWarnings(:)'];
    failedModules = failedModuleNames(R);
    if ~isempty(failedModules)
        R.status = 'RUN_FAILED';
        meta.status = 'RUN_FAILED';
        meta.calculation_status = 'FAILED_ENGINE_MODULE';
        meta.failure_module_ids = failedModules;
        for fm = 1:numel(failedModules)
            q = R.(failedModules{fm});
            if isfield(q,'errors') && ~isempty(q.errors)
                meta.errors = [meta.errors(:)',q.errors(:)']; %#ok<AGROW>
            end
        end
    elseif ~hasMaterialFlows(R.material)
        R.status = 'BLOCKED_SELECTED_CASE';
        meta.status = 'BLOCKED_SELECTED_CASE';
        meta.calculation_status = 'BLOCKED_NO_SUPPORTED_MATERIAL_MODEL';
    else
        R.status = 'REFERENCE_RUN_COMPLETE_WITH_PHYSICAL_BLOCKERS';
        meta.status = 'COMPLETED_WITH_BLOCKED_PHYSICAL_CALCULATIONS';
        meta.calculation_status = 'REFERENCE_OR_SCREENING_CALCULATIONS_COMPLETE';
        meta.warnings = [meta.warnings,{'Only reference and bounded screening calculations were executed. The physical plant model is not validated; Prompt 21 independent verification and validation remain required.'}];
    end

    % Export only actual engine outputs. reporting_plots owns its table and plot exports.
    R.reporting = reporting_plots(modelInput,struct('results',R,'output_directory',reportDirectory),options);
    if strcmp(R.reporting.status,'FAILED')
        R.status = 'RUN_FAILED';
        meta.status = 'RUN_FAILED';
        meta.calculation_status = 'FAILED_REPORT_EXPORT';
        meta.errors = R.reporting.errors;
    else
        meta.exports = R.reporting.value.files;
        supplementary = writeSupplementaryExports(R,reportDirectory);
        meta.exports = [meta.exports,supplementary,{'gui_run_metadata.json'}];
    end

    meta.module_statuses = collectStatuses(R);
    meta.run_finished_local = datestr(now,'yyyy-mm-ddTHH:MM:SS.FFF');
    meta.physical_flowsheet_validated = false;
    meta.prompt21_validation_required = true;
    saveGuiRun(R,meta,runDirectory,reportDirectory);
    writeRunLogs(meta);
catch ME
    R.status = 'RUN_FAILED';
    meta.status = 'RUN_FAILED';
    meta.calculation_status = 'FAILED_EXCEPTION';
    meta.run_finished_local = datestr(now,'yyyy-mm-ddTHH:MM:SS.FFF');
    meta.errors = {struct('identifier',ME.identifier,'message',ME.message)};
    try
        saveGuiRun(R,meta,runDirectory,reportDirectory);
        writeRunLogs(meta);
    catch logME
        warning('ENERGY008:GUIRunLogFailure','Could not complete GUI run logging: %s',logME.message);
    end
end
end

function c = findCase(modelInput,caseId)
c = [];
if isfield(modelInput,'case_data') && strcmp(char(modelInput.case_data.case_id),char(caseId))
    c = modelInput.case_data;
    return;
end
if isfield(modelInput,'cases')
    for k=1:numel(modelInput.cases)
        if strcmp(char(modelInput.cases(k).case_id),char(caseId))
            c = modelInput.cases(k);
            return;
        end
    end
end
end

function tf = hasMaterialFlows(material)
tf = isstruct(material) && isfield(material,'status') && ...
    any(strcmp(material.status,{'REFERENCE_ONLY','SCREENING_ONLY','CALCULATED'})) && ...
    isfield(material,'value') && isfield(material.value,'mass_flows') && ...
    isfield(material.value,'tables');
end

function result = blockedResult(moduleId,modelInput,blockers)
result = energy008.make_result(moduleId,'BLOCKED',struct('blockers',{blockers}), ...
    'N/A',modelInput,blockers,{},struct(),struct());
end

function ensureDirectory(p)
if exist(p,'dir')~=7
    [ok,msg] = mkdir(p);
    if ~ok, error('ENERGY008:GUIDirectoryCreateFailed','Cannot create %s: %s',p,msg); end
end
end

function id = createRunId(outputRoot)
ensureDirectory(outputRoot);
base = datestr(now,'yyyymmddTHHMMSSFFF');
for k=1:999
    id = sprintf('GUI-%s-%03d',base,k);
    candidate = fullfile(outputRoot,id);
    if exist(candidate,'file')~=2 && exist(candidate,'dir')~=7
        return;
    end
end
error('ENERGY008:GUIRunIdExhausted','Could not allocate a unique GUI run ID.');
end

function tf = withinRoot(root,candidate)
[ok1,a] = fileattrib(root); [ok2,b] = fileattrib(candidate);
if ~ok1 || ~ok2, tf=false; return; end
r=char(a.Name); c=char(b.Name); prefix=[r filesep];
if ispc, tf=strcmpi(c,r)||strncmpi(c,prefix,numel(prefix));
else, tf=strcmp(c,r)||strncmp(c,prefix,numel(prefix)); end
end

function statuses = collectStatuses(R)
statuses = struct();
fields = fieldnames(R);
for k=1:numel(fields)
    value = R.(fields{k});
    if isstruct(value) && isscalar(value) && isfield(value,'status')
        statuses.(fields{k}) = char(value.status);
    end
end
end

function names = failedModuleNames(R)
names = {};
fields = fieldnames(R);
for k=1:numel(fields)
    value = R.(fields{k});
    if isstruct(value) && isscalar(value) && isfield(value,'status') && ...
            strcmp(char(value.status),'FAILED')
        names{end+1} = fields{k}; %#ok<AGROW>
    end
end
end

function warnings = collectWarnings(R)
warnings = {};
fields = fieldnames(R);
for k=1:numel(fields)
    value = R.(fields{k});
    if ~isstruct(value) || ~isscalar(value) || ~isfield(value,'module_id') || ...
            ~isfield(value,'warnings') || isempty(value.warnings)
        continue;
    end
    items = value.warnings;
    if ischar(items), items = {items}; end
    if isstring(items), items = cellstr(items(:)); end
    if ~iscell(items), continue; end
    for j=1:numel(items)
        warnings{end+1} = [char(value.module_id) ': ' char(items{j})]; %#ok<AGROW>
    end
end
end

function files = writeSupplementaryExports(R,reportDirectory)
files = {};
if isfield(R,'equipment') && isfield(R.equipment,'value') && isfield(R.equipment.value,'HX_example')
    hx=R.equipment.value.HX_example; pump=R.equipment.value.W201_pump_example;
    item={'HX-A01 illustrative heat-exchanger calculation';'W-201 illustrative water-pump calculation'};
    metric={'Area';'Shaft power'};
    value=[hx.area_m2;pump.shaft_power_kW];
    units={'m2';'kW'};
    provenance={'ASSUMED_SCREENING_INPUTS';'ASSUMED_SCREENING_INPUTS'};
    status={'SCREENING_ONLY_NOT_A_PLANT_DATASHEET';'SCREENING_ONLY_NOT_A_VENDOR_RATING'};
    T=table(item,metric,value,units,provenance,status, ...
        'VariableNames',{'Equipment_Item','Metric','Value','Units','Provenance','Status'});
    writeTableNoOverwrite(T,fullfile(reportDirectory,'equipment_screening_examples.csv'));
    files{end+1}='equipment_screening_examples.csv';
end
if isfield(R,'energy') && isfield(R.energy,'value') && isfield(R.energy.value,'reaction_reference')
    e=R.energy.value; x=e.reaction_reference; u=e.reaction_reference_uncertainty;
    metric={'R-01 standard-state reaction enthalpy rate';'E-01 thermoneutral reference rate'; ...
        'Integrated NET-01 standard-state rate';'CO2 pure ideal-gas sensible reference'; ...
        'Methanol pure-component latent reference'};
    value=[x.R01_rate_GJ_day;x.E01_rate_GJ_day;x.net_rate_GJ_day; ...
        e.co2_sensible_heating.duty_kW;e.methanol_latent_reference.duty_kW];
    units={'GJ/day';'GJ/day';'GJ/day';'kW';'kW'};
    provenance={'SOURCED_THERMOCHEMISTRY_REFERENCE';'SOURCED_THERMOCHEMISTRY_REFERENCE'; ...
        'DERIVED_STANDARD_STATE_IDENTITY';'SOURCED_PURE_COMPONENT_CORRELATION'; ...
        'SOURCED_PURE_COMPONENT_CORRELATION'};
    status={'REFERENCE_ONLY_NOT_REACTOR_DUTY';'REFERENCE_ONLY_NOT_ELECTRICITY'; ...
        'REFERENCE_ONLY_NOT_PLANT_ENERGY';'SCREENING_ONLY_NOT_PROCESS_HEATER_DUTY'; ...
        'SCREENING_ONLY_NOT_DISTILLATION_DUTY'};
    T=table(metric,value,units,provenance,status,'VariableNames', ...
        {'Metric','Value','Units','Provenance','Status'});
    writeTableNoOverwrite(T,fullfile(reportDirectory,'energy_reference_summary.csv'));
    files{end+1}='energy_reference_summary.csv';
end
end

function writeTableNoOverwrite(T,p)
if exist(p,'file')==2, error('ENERGY008:GUIExportOverwrite','Refusing to overwrite %s.',p); end
writetable(T,p);
end

function saveGuiRun(R,meta,runDirectory,reportDirectory)
metaPath = fullfile(runDirectory,'gui_run_metadata.json');
writeTextNoOverwrite(metaPath,jsonencode(meta));
if exist(reportDirectory,'dir')==7
    reportMetaPath = fullfile(reportDirectory,'gui_run_metadata.json');
    if exist(reportMetaPath,'file')~=2
        writeTextNoOverwrite(reportMetaPath,jsonencode(meta));
    end
end
end

function writeRunLogs(meta)
if ~isfield(meta,'log_json') || isempty(meta.log_json), return; end
jsonText = jsonencode(meta);
writeTextNoOverwrite(meta.log_json,jsonText);
lines = {['ENERGY-008 GUI run: ' char(meta.run_id)], ...
    ['Status: ' char(meta.status)], ...
    ['Calculation: ' char(meta.calculation_status)], ...
    ['Case: ' char(meta.case_id)], ...
    ['Timestamp: ' char(meta.timestamp_local)], ...
    ['MATLAB: ' char(meta.matlab_version)], ...
    ['Model version: ' char(meta.model_version)], ...
    ['Data version: ' char(meta.data_version)]};
if isfield(meta,'errors')
    for k=1:numel(meta.errors)
        if isstruct(meta.errors{k})
            lines{end+1} = ['ERROR ' char(meta.errors{k}.identifier) ': ' char(meta.errors{k}.message)]; %#ok<AGROW>
        else
            lines{end+1} = ['ERROR: ' char(meta.errors{k})]; %#ok<AGROW>
        end
    end
end
if isfield(meta,'warnings')
    for k=1:numel(meta.warnings)
        lines{end+1} = ['WARNING: ' char(meta.warnings{k})]; %#ok<AGROW>
    end
end
writeTextNoOverwrite(meta.log_text,strjoin(lines,sprintf('\n')));
if isfield(meta,'run_directory') && exist(meta.run_directory,'dir')==7
    writeTextNoOverwrite(fullfile(meta.run_directory,'run_log.json'),jsonText);
    writeTextNoOverwrite(fullfile(meta.run_directory,'run_log.txt'),strjoin(lines,sprintf('\n')));
end
end

function writeTextNoOverwrite(path,text)
if exist(path,'file')==2, error('ENERGY008:GUIExportOverwrite','Refusing to overwrite %s.',path); end
fid=fopen(path,'w');
if fid<0, error('ENERGY008:GUIExportOpenFailed','Cannot open %s for writing.',path); end
cleanup=onCleanup(@()fclose(fid));
fwrite(fid,text,'char');
fprintf(fid,'\n');
clear cleanup;
end
