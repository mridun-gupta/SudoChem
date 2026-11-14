function run_gui()
% R4 GUI launcher with project-root resolution anchored to this file.
projectRoot=fileparts(mfilename('fullpath'));
addpath(projectRoot,'-begin'); addpath(fullfile(projectRoot,'src'),'-begin');
cd(projectRoot); rehash path;
clear cps22_gui cps22_load_config cps22_read_reference_data
cps22_activate_project(projectRoot);
cps22_gui();
end
