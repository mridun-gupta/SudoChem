% ENERGY-008 reproducible startup entry point.
% Run this file from the MATLAB Editor or by its absolute path. Do not set pwd.

ENERGY008_ENTRY_FILE = mfilename('fullpath');
if isempty(ENERGY008_ENTRY_FILE)
    error('ENERGY008:EntryPathUnavailable', ...
        'MATLAB could not resolve START_HERE.m. Open this file from the project folder and run it.');
end
ENERGY008_ENTRY_DIR = fileparts(ENERGY008_ENTRY_FILE);
ENERGY008_PROJECT_ROOT = '';
ENERGY008_CURSOR = ENERGY008_ENTRY_DIR;

while true
    ENERGY008_MARKER = fullfile(ENERGY008_CURSOR, '.energy008-root');
    ENERGY008_CONFIG = fullfile(ENERGY008_CURSOR, 'MATLAB', 'project_config.json');
    if exist(ENERGY008_MARKER, 'file') == 2 && exist(ENERGY008_CONFIG, 'file') == 2
        ENERGY008_PROJECT_ROOT = ENERGY008_CURSOR;
        break;
    end
    ENERGY008_PARENT = fileparts(ENERGY008_CURSOR);
    if isempty(ENERGY008_PARENT) || strcmp(ENERGY008_PARENT, ENERGY008_CURSOR)
        break;
    end
    ENERGY008_CURSOR = ENERGY008_PARENT;
end

if isempty(ENERGY008_PROJECT_ROOT)
    error('ENERGY008:RootNotFound', ...
        ['Could not find the ENERGY-008 project marker and MATLAB/project_config.json ' ...
         'above the location of START_HERE.m. Extract the complete project folder and retry.']);
end
[ENERGY008_ROOT_CANONICAL_OK, ENERGY008_ROOT_CANONICAL_ATTR] = fileattrib(ENERGY008_PROJECT_ROOT);
if ~ENERGY008_ROOT_CANONICAL_OK
    error('ENERGY008:RootResolutionFailed', 'Could not canonicalise the detected project root.');
end
ENERGY008_PROJECT_ROOT = char(ENERGY008_ROOT_CANONICAL_ATTR.Name);

ENERGY008_MARKER_TEXT = fileread(fullfile(ENERGY008_PROJECT_ROOT, '.energy008-root'));
if isempty(strfind(ENERGY008_MARKER_TEXT, 'ENERGY008_PROJECT_ID=ENERGY-008')) %#ok<STREMP>
    error('ENERGY008:MarkerInvalid', 'Project marker does not identify ENERGY-008.');
end

try
    ENERGY008_CFG = jsondecode(fileread(ENERGY008_CONFIG));
catch ENERGY008_PARSE_ERROR
    error('ENERGY008:ConfigParseFailure', ...
        'Could not parse MATLAB/project_config.json. Restore valid JSON and retry. Details: %s', ENERGY008_PARSE_ERROR.message);
end
if ~isfield(ENERGY008_CFG, 'project_id') || ~strcmp(char(ENERGY008_CFG.project_id), 'ENERGY-008')
    error('ENERGY008:ConfigProjectMismatch', ...
        'project_config.json project_id must equal ENERGY-008.');
end
if ~isfield(ENERGY008_CFG, 'paths') || ~isfield(ENERGY008_CFG.paths, 'runtime_path_folders')
    error('ENERGY008:ConfigPathPolicyMissing', ...
        'project_config.json must declare paths.runtime_path_folders.');
end

% Only explicitly declared, root-contained source folders may be added.
ENERGY008_SOURCE_DIRS = ENERGY008_CFG.paths.runtime_path_folders;
if ischar(ENERGY008_SOURCE_DIRS)
    ENERGY008_SOURCE_DIRS = {ENERGY008_SOURCE_DIRS};
elseif isstring(ENERGY008_SOURCE_DIRS)
    ENERGY008_SOURCE_DIRS = cellstr(ENERGY008_SOURCE_DIRS);
elseif ~iscell(ENERGY008_SOURCE_DIRS)
    error('ENERGY008:ConfigTypeInvalid', 'paths.runtime_path_folders must be a string or string array.');
end
if numel(ENERGY008_SOURCE_DIRS) ~= 1 || ~strcmp(char(ENERGY008_SOURCE_DIRS{1}), 'MATLAB')
    error('ENERGY008:UnsafePathPolicy', ...
        'Prompt 18 permits exactly one runtime source directory: MATLAB.');
end
for ENERGY008_I = 1:numel(ENERGY008_SOURCE_DIRS)
    ENERGY008_REL = char(ENERGY008_SOURCE_DIRS{ENERGY008_I});
    if isempty(ENERGY008_REL) || any(strcmp(strsplit(strrep(ENERGY008_REL, char(92), '/'), '/'), '..')) ...
            || (~strcmp(ENERGY008_REL, 'MATLAB'))
        error('ENERGY008:UnsafePathEntry', ...
            'Only the declared MATLAB source directory is allowed in runtime_path_folders.');
    end
    ENERGY008_ABS = fullfile(ENERGY008_PROJECT_ROOT, ENERGY008_REL);
    if exist(ENERGY008_ABS, 'dir') ~= 7
        error('ENERGY008:SourceFolderMissing', 'Declared source folder is missing: %s', ENERGY008_ABS);
    end
    [ENERGY008_ROOT_OK, ENERGY008_ROOT_ATTR] = fileattrib(ENERGY008_PROJECT_ROOT);
    [ENERGY008_SOURCE_OK, ENERGY008_SOURCE_ATTR] = fileattrib(ENERGY008_ABS);
    if ~ENERGY008_ROOT_OK || ~ENERGY008_SOURCE_OK
        error('ENERGY008:SourceFolderResolutionFailed', 'Could not canonicalise the project root or source folder.');
    end
    ENERGY008_ROOT_CANONICAL = char(ENERGY008_ROOT_ATTR.Name);
    ENERGY008_SOURCE_CANONICAL = char(ENERGY008_SOURCE_ATTR.Name);
    ENERGY008_ROOT_PREFIX = [ENERGY008_ROOT_CANONICAL filesep];
    if ispc
        ENERGY008_SOURCE_INSIDE_ROOT = strncmpi(ENERGY008_SOURCE_CANONICAL, ENERGY008_ROOT_PREFIX, numel(ENERGY008_ROOT_PREFIX));
    else
        ENERGY008_SOURCE_INSIDE_ROOT = strncmp(ENERGY008_SOURCE_CANONICAL, ENERGY008_ROOT_PREFIX, numel(ENERGY008_ROOT_PREFIX));
    end
    if ~ENERGY008_SOURCE_INSIDE_ROOT
        error('ENERGY008:SourceFolderOutsideProject', 'Declared runtime source folder resolves outside the project root: %s', ENERGY008_ABS);
    end
    % Move this exact source folder to the top so an older same-named
    % main.m elsewhere on the user's path cannot shadow this project.
    addpath(ENERGY008_ABS, '-begin');
end

% main performs config/manifest checks, file discovery, hash verification and run logging.
ENERGY008_RUN = main(ENERGY008_PROJECT_ROOT, ENERGY008_CONFIG);
fprintf('\nENERGY-008 startup status: %s\n', ENERGY008_RUN.status);
fprintf('Project root: %s\n', ENERGY008_RUN.project_root);
fprintf('Run ID: %s\n', ENERGY008_RUN.run_id);
fprintf('Run log: %s\n', ENERGY008_RUN.log_json);
fprintf('Calculation status: %s (Prompt 19 implementation required)\n\n', ENERGY008_RUN.calculation_status);
