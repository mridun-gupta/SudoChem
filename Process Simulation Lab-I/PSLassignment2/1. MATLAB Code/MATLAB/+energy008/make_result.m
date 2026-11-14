function result = make_result(moduleId, status, value, units, modelInput, warnings, errors, residuals, provenance)
%MAKE_RESULT Build the common Prompt 19 ModuleResult contract.
if nargin < 9 || isempty(provenance), provenance = struct([]); end
if nargin < 8 || isempty(residuals), residuals = struct(); end
if nargin < 7 || isempty(errors), errors = {}; end
if nargin < 6 || isempty(warnings), warnings = {}; end
versions = struct();
if isstruct(modelInput) && isfield(modelInput,'versions'), versions = modelInput.versions; end
result = struct('module_id',char(moduleId),'status',char(status),'value',value, ...
    'units',units,'input_versions',versions,'residuals',residuals, ...
    'warnings',{warnings},'errors',{errors},'failure_codes',{{}}, ...
    'provenance',provenance,'diagnostics',struct([]), ...
    'run_metadata',struct('run_id',getOption(modelInput,'run_id','UNASSIGNED'), ...
    'timestamp_local',datestr(now,'yyyy-mm-ddTHH:MM:SS')));
end
function value = getOption(s, field, fallback)
value = fallback;
if isstruct(s) && isfield(s,field) && ~isempty(s.(field)), value=s.(field); end
end
