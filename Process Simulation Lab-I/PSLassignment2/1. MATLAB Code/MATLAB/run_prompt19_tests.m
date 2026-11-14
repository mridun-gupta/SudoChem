function report = run_prompt19_tests(projectRoot)
%RUN_PROMPT19_TESTS Run the controlled Prompt 19 tests without a toolbox.
% The test folder is added only for the duration of this call and removed
% afterwards. Normal project startup still adds only MATLAB/ to the path.
if nargin < 1 || isempty(projectRoot)
    if evalin('base','exist(''ENERGY008_PROJECT_ROOT'',''var'')')
        projectRoot = evalin('base','ENERGY008_PROJECT_ROOT');
    else
        here = mfilename('fullpath');
        projectRoot = fileparts(fileparts(here));
    end
end
testFolder = fullfile(projectRoot,'MATLAB','tests');
if exist(testFolder,'dir') ~= 7
    error('ENERGY008:TestFolderMissing','Controlled test folder is missing: %s',testFolder);
end
oldPath = path;
cleanup = onCleanup(@()path(oldPath));
addpath(testFolder,'-begin');
report = execute_prompt19_test_suite(projectRoot);
clear cleanup;
end
