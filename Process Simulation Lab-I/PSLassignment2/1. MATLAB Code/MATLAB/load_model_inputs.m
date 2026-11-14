function modelInput = load_model_inputs(projectRoot,cfg,runId)
%LOAD_MODEL_INPUTS Load versioned input JSON with root/allowed-root validation.
% Paths are explicit project-relative config entries; no discovery or pwd use.
required={'case_file','property_data_file','reaction_network_file','fixture_file','case_files','disturbance_file', ...
 'equipment_register_file','utility_register_file','cost_basis_file','environmental_basis_file','sensitivity_plan_file'};
for k=1:numel(required)
    if ~isfield(cfg.paths,required{k}), error('ENERGY008:ConfigFieldMissing','project_config.paths.%s is required.',required{k}); end
end
allowed=energy008.cellstr_safe(cfg.paths.data_roots);
modelInput=struct(); modelInput.project_root=projectRoot; modelInput.run_id=runId;
modelInput.versions=struct('project',cfg.project_version,'design_basis',cfg.design_basis_version, ...
    'pfd',cfg.pfd_version,'model',cfg.model_version,'reaction_network',cfg.reaction_network_version, ...
    'property_data',cfg.property_data_version,'schema',cfg.schema_version,'fixture',cfg.benchmark_fixture_id, ...
    'sensitivity_plan',cfg.sensitivity_plan_version);
modelInput.case_data=readProjectJSON(projectRoot,cfg.paths.case_file,allowed,'ENERGY008-CASE-0.1.0');
modelInput.properties=readProjectJSON(projectRoot,cfg.paths.property_data_file,allowed,'ENERGY008-PROPERTY-MODEL-DATA-0.1.0');
modelInput.reaction_network=readProjectJSON(projectRoot,cfg.paths.reaction_network_file,allowed,'ENERGY008-REACTION-NETWORK-0.1.0');
modelInput.fixture=readProjectJSON(projectRoot,cfg.paths.fixture_file,allowed,[]);
caseFiles=energy008.cellstr_safe(cfg.paths.case_files); modelInput.cases=struct([]);
for k=1:numel(caseFiles)
    c=readProjectJSON(projectRoot,caseFiles{k},allowed,'ENERGY008-CASE-0.1.0');
    if isempty(modelInput.cases), modelInput.cases=c; else, modelInput.cases(end+1)=c; end %#ok<AGROW>
end
modelInput.disturbance=readProjectJSON(projectRoot,cfg.paths.disturbance_file,allowed,'ENERGY008-DISTURBANCE-CASE-0.1.0');
modelInput.equipment_register=readProjectJSON(projectRoot,cfg.paths.equipment_register_file,allowed,'ENERGY008-EQUIPMENT-REGISTER-0.1.0');
modelInput.utility_register=readProjectJSON(projectRoot,cfg.paths.utility_register_file,allowed,'ENERGY008-UTILITY-REGISTER-0.1.0');
modelInput.cost_basis=readProjectJSON(projectRoot,cfg.paths.cost_basis_file,allowed,'ENERGY008-COST-BASIS-0.1.0');
modelInput.environmental_basis=readProjectJSON(projectRoot,cfg.paths.environmental_basis_file,allowed,'ENERGY008-ENVIRONMENTAL-BASIS-0.1.0');
modelInput.sensitivity_plan=readProjectJSON(projectRoot,cfg.paths.sensitivity_plan_file,allowed,'ENERGY008-SENSITIVITY-PLAN-0.1.0');
if ~strcmp(char(modelInput.sensitivity_plan.plan_version),char(modelInput.versions.sensitivity_plan))
    error('ENERGY008:SensitivityPlanVersionMismatch','Loaded sensitivity plan version does not match project configuration.');
end
modelInput.source_files=struct('property_data',cfg.paths.property_data_file,'reaction_network',cfg.paths.reaction_network_file, ...
    'default_case',cfg.paths.case_file,'fixture',cfg.paths.fixture_file,'disturbance',cfg.paths.disturbance_file, ...
    'equipment_register',cfg.paths.equipment_register_file,'utility_register',cfg.paths.utility_register_file, ...
    'cost_basis',cfg.paths.cost_basis_file,'environmental_basis',cfg.paths.environmental_basis_file, ...
    'sensitivity_plan',cfg.paths.sensitivity_plan_file);
end
function data=readProjectJSON(root,relativePath,allowedRoots,expectedSchema)
rel=strrep(char(relativePath),char(92),'/'); parts=strsplit(rel,'/');
if isempty(rel) || rel(1)=='/' || ~isempty(regexp(rel,'^[A-Za-z]:','once')) || any(strcmp(parts,'..'))
    error('ENERGY008:UnsafeInputPath','Configured input path must be project-relative with no parent traversal: %s',rel);
end
p=fullfile(root,rel);
if exist(p,'file')~=2, error('ENERGY008:InputFileMissing','Configured input file does not exist: %s',p); end
[okF,aF]=fileattrib(p); if ~okF, error('ENERGY008:InputPathResolution','Could not canonicalise input path: %s',p); end
candidate=char(aF.Name); inside=false;
for k=1:numel(allowedRoots)
    rootPath=fullfile(root,allowedRoots{k}); [okR,aR]=fileattrib(rootPath); if ~okR, continue; end
    r=char(aR.Name); prefix=[r filesep];
    if ispc, hit=strcmpi(candidate,r)||strncmpi(candidate,prefix,numel(prefix)); else, hit=strcmp(candidate,r)||strncmp(candidate,prefix,numel(prefix)); end
    if hit, inside=true; break; end
end
if ~inside, error('ENERGY008:InputOutsideAllowedRoots','Configured JSON input is outside configured data roots: %s',candidate); end
data=energy008.load_json(candidate,expectedSchema);
end
