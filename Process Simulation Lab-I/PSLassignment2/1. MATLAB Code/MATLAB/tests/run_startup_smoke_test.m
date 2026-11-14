% Prompt 19/20 startup smoke test. Run this script from the MATLAB Editor.
% It verifies relocated root discovery and manifest integrity only; it does not
% run process calculations. The MATLAB runtime test suite is a separate step.
ENERGY008_SMOKE_ENTRY=mfilename('fullpath');
if isempty(ENERGY008_SMOKE_ENTRY), error('ENERGY008:SmokeEntryMissing','Cannot determine smoke-test path.'); end
ENERGY008_SMOKE_DIR=fileparts(ENERGY008_SMOKE_ENTRY);
ENERGY008_SMOKE_ROOT=fileparts(fileparts(ENERGY008_SMOKE_DIR));
ENERGY008_SMOKE_START=fullfile(ENERGY008_SMOKE_ROOT,'MATLAB','START_HERE.m');
if exist(ENERGY008_SMOKE_START,'file')~=2, error('ENERGY008:SmokeStartMissing','START_HERE.m not found.'); end
ENERGY008_SMOKE_ORIGINAL=pwd;
cd(tempdir);
try
    run(ENERGY008_SMOKE_START);
    assert(strcmp(ENERGY008_RUN.status,'STARTUP_READY'));
    assert(strcmp(ENERGY008_RUN.calculation_status,'NOT_RUN'));
    assert(strcmp(ENERGY008_RUN.data_integrity,'SHA256_VERIFIED'));
    assert(strcmp(ENERGY008_PROJECT_ROOT,ENERGY008_SMOKE_ROOT));
catch ME
    cd(ENERGY008_SMOKE_ORIGINAL); rethrow(ME);
end
cd(ENERGY008_SMOKE_ORIGINAL);
fprintf('ENERGY-008 startup smoke test PASS (startup/data integrity only; calculations NOT RUN).\n');
