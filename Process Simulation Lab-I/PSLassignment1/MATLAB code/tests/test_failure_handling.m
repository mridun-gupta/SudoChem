function test_failure_handling()
% Check that malformed inputs are rejected instead of silently normalized.
projectRoot=fileparts(fileparts(mfilename('fullpath'))); addpath(genpath(fullfile(projectRoot,'src')));
cfg=cps22_load_config(fullfile(projectRoot,'data','default_case.json'));
cfg.feed.z=[0.6;0.6]; v=cps22_validate_config(cfg); assert(~v.valid);
cfg=cps22_load_config(fullfile(projectRoot,'data','default_case.json'));
cfg.conditions.temperature_K=350; v=cps22_validate_config(cfg); assert(~v.valid,'Antoine range mismatch must be caught.');
fprintf('CPS-22 failure-handling tests passed.\n');
end
