function CPS22_Launcher(mode)
% CPS22 R4 launcher. It is anchored to this file, never searches other projects.
if nargin<1 || isempty(mode), mode='standard'; end
mode=lower(strtrim(char(string(mode))));
projectRoot=fileparts(mfilename('fullpath'));
% Add this release before calling any project resolver; then change Current Folder
% so MATLAB cannot prefer an older main.m from the user's previous copy.
addpath(projectRoot,'-begin'); addpath(fullfile(projectRoot,'src'),'-begin'); addpath(fullfile(projectRoot,'gui'),'-begin');
cd(projectRoot); rehash path;
clear main main_industrial run_tests cps22_gui cps22_read_reference_data cps22_load_config
P=cps22_activate_project(projectRoot);
% Ensure entrypoints are resolved from the project the user actually opened.
clear main main_industrial run_tests cps22_gui
assertFunction('main',P.main_file);
if strcmp(mode,'menu')
    choice=menu('CPS-22 R4 | NRTL-SRK High-Pressure Separation', ...
        'Run standard calculations','Run detailed calculation workbook','Open GUI','Run tests','Diagnose files','Cancel');
    switch choice
        case 1, mode='standard'; case 2, mode='industrial'; case 3, mode='gui'; case 4, mode='tests'; case 5, mode='diagnose'; otherwise, disp('Cancelled.'); return;
    end
end
switch mode
    case {'standard','main'}
        main();
    case {'industrial','detailed'}
        main_industrial();
    case {'gui','interface'}
        cps22_gui();
    case {'tests','test'}
        run_tests();
    case {'diagnose','diagnostics'}
        fprintf('\nFunction resolution check:\n');
        fprintf('main: %s\n',which('main'));
        fprintf('cps22_read_reference_data: %s\n',which('cps22_read_reference_data'));
        fprintf('cps22_load_config: %s\n',which('cps22_load_config'));
        disp(P.discovery);
    otherwise
        error('CPS22:UnknownLaunchMode','Unknown mode "%s". Use standard, industrial, gui, tests, or diagnose.',mode);
end
end
function assertFunction(name,expected)
actual=which(name); [~,a]=fileattrib(actual); if isfield(a,'Name'),actual=a.Name;end
[~,e]=fileattrib(expected); if isfield(e,'Name'),expected=e.Name;end
if ~strcmpi(actual,expected), error('CPS22:StaleEntryPoint','MATLAB found %s at %s; expected %s. Use START_HERE from the R4 folder.',name,actual,expected); end
end
