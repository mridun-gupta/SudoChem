function data = load_json(path, expectedSchemaId)
%LOAD_JSON Load and validate a project-controlled JSON object.
if exist(path,'file')~=2
    error('ENERGY008:InputFileMissing','Required project input JSON is missing: %s',path);
end
try
    data=jsondecode(fileread(path));
catch ME
    error('ENERGY008:InputJSONInvalid','Cannot parse JSON file %s: %s',path,ME.message);
end
if ~isstruct(data) || ~isscalar(data)
    error('ENERGY008:InputJSONShape','Expected a top-level JSON object in %s.',path);
end
if nargin>=2 && ~isempty(expectedSchemaId)
    if ~isfield(data,'schema_id') || ~strcmp(char(data.schema_id),char(expectedSchemaId))
        error('ENERGY008:InputSchemaMismatch','Schema ID mismatch in %s. Expected %s.',path,expectedSchemaId);
    end
end
end
