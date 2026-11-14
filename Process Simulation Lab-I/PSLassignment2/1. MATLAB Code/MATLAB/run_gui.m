function app = run_gui()
%RUN_GUI Launch the ENERGY-008 engineering calculation GUI.
% Resolve the project from this file, never from the caller's current folder.
entryFile = mfilename('fullpath');
if isempty(entryFile)
    error('ENERGY008:GUIEntryPathUnavailable', ...
        'MATLAB could not resolve run_gui.m. Run the function from the extracted project.');
end
cursor = fileparts(entryFile);
projectRoot = '';
while true
    marker = fullfile(cursor, '.energy008-root');
    configFile = fullfile(cursor, 'MATLAB', 'project_config.json');
    if exist(marker, 'file') == 2 && exist(configFile, 'file') == 2
        projectRoot = cursor;
        break;
    end
    parent = fileparts(cursor);
    if isempty(parent) || strcmp(parent, cursor)
        break;
    end
    cursor = parent;
end
if isempty(projectRoot)
    error('ENERGY008:GUIProjectRootNotFound', ...
        'Project marker and MATLAB/project_config.json were not found above run_gui.m.');
end

[okRoot, rootAttr] = fileattrib(projectRoot);
if ~okRoot
    error('ENERGY008:GUIProjectRootResolution', 'Could not canonicalise the project root.');
end
projectRoot = char(rootAttr.Name);
markerText = fileread(fullfile(projectRoot, '.energy008-root'));
if isempty(strfind(markerText, 'ENERGY008_PROJECT_ID=ENERGY-008')) %#ok<STREMP>
    error('ENERGY008:GUIMarkerInvalid', 'The project marker does not identify ENERGY-008.');
end

configFile = fullfile(projectRoot, 'MATLAB', 'project_config.json');
cfg = jsondecode(fileread(configFile));
if ~isfield(cfg, 'project_id') || ~strcmp(char(cfg.project_id), 'ENERGY-008')
    error('ENERGY008:GUIConfigProjectMismatch', 'project_config.json does not identify ENERGY-008.');
end
if ~isfield(cfg, 'paths') || ~isfield(cfg.paths, 'runtime_path_folders') || ...
        ~isfield(cfg.paths, 'gui_path_folders')
    error('ENERGY008:GUIPathPolicyMissing', ...
        'project_config.json must declare runtime_path_folders and gui_path_folders.');
end
runtimeFolders = energy008GuiCellstr(cfg.paths.runtime_path_folders);
if numel(runtimeFolders) ~= 1 || ~strcmp(runtimeFolders{1}, 'MATLAB')
    error('ENERGY008:GUIRuntimePathPolicy', ...
        'The runtime source path must remain exactly the declared MATLAB folder.');
end

% Add only the explicitly approved engine folder and this fixed GUI folder.
engineDir = fullfile(projectRoot, runtimeFolders{1});
[okEngine, engineAttr] = fileattrib(engineDir);
if ~okEngine || ~isWithin(projectRoot, char(engineAttr.Name))
    error('ENERGY008:GUIEnginePathInvalid', 'The engine folder is missing or outside the project root.');
end
addpath(char(engineAttr.Name), '-begin');

guiFolders = energy008GuiCellstr(cfg.paths.gui_path_folders);
if numel(guiFolders) ~= 1 || ~strcmp(guiFolders{1}, 'MATLAB/gui')
    error('ENERGY008:GUISourcePathPolicy', ...
        'Only the project-controlled MATLAB/gui folder may be added for the GUI.');
end
guiDir = fullfile(projectRoot, guiFolders{1});
[okGui, guiAttr] = fileattrib(guiDir);
if ~okGui || ~isWithin(projectRoot, char(guiAttr.Name))
    error('ENERGY008:GUISourcePathInvalid', 'The GUI folder is missing or outside the project root.');
end
addpath(char(guiAttr.Name), '-begin');

app = ENERGY008_App(projectRoot, cfg);
end

function values = energy008GuiCellstr(value)
if ischar(value)
    values = {value};
elseif isstring(value)
    values = cellstr(value(:));
elseif iscell(value)
    values = cell(size(value));
    for k = 1:numel(value)
        values{k} = char(value{k});
    end
else
    error('ENERGY008:GUIPathTypeInvalid', 'A configured path list must be a string or cell array of strings.');
end
end

function tf = isWithin(root, candidate)
[okR, aR] = fileattrib(root);
[okC, aC] = fileattrib(candidate);
if ~okR || ~okC
    tf = false;
    return;
end
r = char(aR.Name);
c = char(aC.Name);
prefix = [r filesep];
if ispc
    tf = strcmpi(c, r) || strncmpi(c, prefix, numel(prefix));
else
    tf = strcmp(c, r) || strncmp(c, prefix, numel(prefix));
end
end
