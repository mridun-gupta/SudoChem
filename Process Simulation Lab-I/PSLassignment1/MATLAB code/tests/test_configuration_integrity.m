function test_configuration_integrity()
% Phase 4 regression tests for fixed component order and binary interaction conventions.
projectRoot=fileparts(fileparts(mfilename('fullpath'))); addpath(genpath(fullfile(projectRoot,'src')));
loadCfg=@() cps22_load_config(fullfile(projectRoot,'data','default_case.json'));
cfg=loadCfg(); report=cps22_validate_config(cfg); assert(report.valid,'Default configuration should remain valid.');
cfg=loadCfg(); cfg.components(1).name='Water'; cfg.components(2).name='Ethanol';
assertInvalidConfig(cfg,'Reordered components must be rejected unless all indexed data are deliberately reordered.');
cfg=loadCfg(); cfg.model.srk.kij_matrix(1,2)=0.1;
assertInvalidConfig(cfg,'Asymmetric kij matrix must be rejected.');
cfg=loadCfg(); cfg.model.srk.kij_matrix(1,1)=0.1;
assertInvalidConfig(cfg,'Nonzero kij diagonal must be rejected.');
cfg=loadCfg(); cfg.model.nrtl.a_ij(1,1)=0.1;
assertInvalidConfig(cfg,'Nonzero NRTL self-interaction diagonal must be rejected.');
cfg=loadCfg(); cfg.saturation_correlations(1).component='Water';
assertInvalidConfig(cfg,'Misordered saturation correlations must be rejected.');
fprintf('CPS-22 configuration integrity regression tests passed.\n');
end
function assertInvalidConfig(cfg,message)
report=cps22_validate_config(cfg);
assert(~report.valid,message);
end
