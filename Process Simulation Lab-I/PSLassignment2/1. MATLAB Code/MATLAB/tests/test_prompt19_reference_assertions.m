% Direct script assertions. Requires START_HERE to have run once or add MATLAB folder explicitly.
thisFile=mfilename('fullpath'); projectRoot=fileparts(fileparts(fileparts(thisFile)));
addpath(fullfile(projectRoot,'MATLAB'),'-begin');
report=run_prompt19_tests(projectRoot);
assert(strcmp(report.status,'PASS'));
