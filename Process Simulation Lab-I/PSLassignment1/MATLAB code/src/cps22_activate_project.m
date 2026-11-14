function P = cps22_activate_project(projectRoot)
% CPS22_ACTIVATE_PROJECT Pin MATLAB to the complete R4 root and canonical data.
if nargin<1 || isempty(projectRoot), here=fileparts(mfilename('fullpath')); projectRoot=fileparts(here); end
projectRoot=char(string(projectRoot));
if ~isfolder(projectRoot), error('CPS22:ProjectFolderMissing','Project folder not found: %s',projectRoot); end
P=cps22_find_project_files(projectRoot);
cd(P.root); % Current Folder takes precedence over old duplicate copies on the path.
addpath(P.root,'-begin'); addpath(P.src_dir,'-begin');
if isfolder(P.gui_dir), addpath(P.gui_dir,'-begin'); end
if isfolder(P.tests_dir), addpath(P.tests_dir,'-begin'); end
rehash path;
% Drop cached copies from prior extracted folders.
clear cps22_load_config cps22_read_reference_data cps22_reference_flash cps22_run_sensitivities
clear cps22_make_plots cps22_find_project_files cps22_model_comparison cps22_validate_config
assertResolved('cps22_read_reference_data',fullfile(P.src_dir,'cps22_read_reference_data.m'));
assertResolved('cps22_load_config',fullfile(P.src_dir,'cps22_load_config.m'));
D=cps22_read_reference_data(P.reference_data);
if height(D)~=207, error('CPS22:UnexpectedReferenceRowCount','Expanded canonical data must have 207 records, found %d: %s',height(D),P.reference_data); end
p=unique(round(D.pressure_kPa,6)); expected=[100;101;300;500;700;1500;2000];
if ~isequal(sort(p(:)),expected), error('CPS22:UnexpectedReferenceIsobars','Expected ingested isobars [100 101 300 500 700 1500 2000] kPa; found %s.',mat2str(p(:)')); end
fprintf('CPS-22 R4 project activated:\n  %s\n',P.root);
fprintf('Configuration: %s\nCanonical reference CSV: %s\n',P.config_file,P.reference_data);
fprintf('CSV schema check: PASS | rows=%d | columns=%d | isobars=%s kPa\n',height(D),width(D),strjoin(string(p(:)'),', '));
end
function assertResolved(functionName,expectedPath)
actual=which(functionName); if isempty(actual), error('CPS22:FunctionNotOnPath','Required function not found: %s',functionName); end
[ok,a]=fileattrib(actual); if ok,actual=a.Name;end
[ok,e]=fileattrib(expectedPath); if ok,expectedPath=e.Name;end
if ~strcmpi(actual,expectedPath)
    error('CPS22:StaleFunctionOnPath','MATLAB resolved %s from %s but R4 requires %s. Close MATLAB and open START_HERE.m from the newly extracted R4 folder.',functionName,actual,expectedPath);
end
end
