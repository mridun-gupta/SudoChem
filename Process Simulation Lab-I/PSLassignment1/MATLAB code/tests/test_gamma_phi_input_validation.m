function test_gamma_phi_input_validation()
% Phase 4 regression tests for finite/bounded gamma-phi inputs.
projectRoot=fileparts(fileparts(mfilename('fullpath'))); addpath(genpath(fullfile(projectRoot,'src')));
cfg=cps22_load_config(fullfile(projectRoot,'data','default_case.json'));
checkError(@() cps22_gamma_phi(NaN,cfg.conditions.pressure_Pa,[0.4;0.6],[0.5;0.5],cfg),'CPS22:InvalidThermodynamicState');
checkError(@() cps22_gamma_phi(cfg.conditions.temperature_K,0,[0.4;0.6],[0.5;0.5],cfg),'CPS22:InvalidThermodynamicState');
checkError(@() cps22_gamma_phi(cfg.conditions.temperature_K,cfg.conditions.pressure_Pa,[NaN;1],[0.5;0.5],cfg),'CPS22:InvalidPhaseComposition');
checkError(@() cps22_gamma_phi(cfg.conditions.temperature_K,cfg.conditions.pressure_Pa,[-0.1;1.1],[0.5;0.5],cfg),'CPS22:InvalidPhaseComposition');
checkError(@() cps22_gamma_phi(cfg.conditions.temperature_K,cfg.conditions.pressure_Pa,[0.4;0.5],[0.5;0.5],cfg),'CPS22:InvalidPhaseComposition');
fprintf('CPS-22 gamma-phi input validation regression tests passed.\n');
end
function checkError(f,expectedId)
seen=false;
try, f(); catch ME, seen=true; assert(strcmp(ME.identifier,expectedId), ...
        'Expected error %s, got %s.', expectedId, ME.identifier); end
assert(seen,'Expected error %s was not raised.',expectedId);
end
