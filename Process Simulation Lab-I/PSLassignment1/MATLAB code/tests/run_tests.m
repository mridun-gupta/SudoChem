function run_tests()
% CPS-22 R4 regression suite. Run START_HERE.m or CPS22_Launcher('tests').
projectRoot=fileparts(fileparts(mfilename('fullpath')));
addpath(projectRoot,'-begin'); addpath(fullfile(projectRoot,'src'),'-begin');
cd(projectRoot); rehash path;
clear cps22_activate_project cps22_load_config cps22_read_reference_data
cps22_activate_project(projectRoot);
cfg=cps22_load_config(fullfile(projectRoot,'data','default_case.json'));
v=cps22_validate_config(cfg); assert(v.valid,'Default config failed basic input validation.');
D=cps22_read_reference_data(cfg.paths.reference_data_abs);
assert(height(D)==207,'Unexpected expanded canonical reference data row count.');
assert(strcmpi(cfg.paths.reference_data_abs,fullfile(projectRoot,'data','CPS22_reference_vle_expanded.csv')), ...
    'A non-canonical/legacy CSV path was selected.');
[g1,~,~]=cps22_nrtl_gamma([1;0],cfg.conditions.temperature_K,cfg);
[g2,~,~]=cps22_nrtl_gamma([0;1],cfg.conditions.temperature_K,cfg);
assert(abs(g1(1)-1)<1e-8 && abs(g2(2)-1)<1e-8,'NRTL pure-component limiting behaviour failed.');
assert(all(isfinite(g1))&&all(g1>0)&&all(isfinite(g2))&&all(g2>0),'NRTL boundary values must be finite and positive.');
srk=cps22_srk_phi(cfg.conditions.temperature_K,cfg.conditions.pressure_Pa,[0.55;0.45],cfg);
assert(isfinite(srk.Z)&&srk.Z>srk.B&&all(isfinite(srk.phi))&&all(srk.phi>0),'SRK vapor property check failed.');
r=cps22_reference_flash(cfg,cfg.paths.reference_data_abs);
assert(strcmp(r.status,'TWO_PHASE_REFERENCE_INTERPOLATION'),'Expected a two-phase reference interpolation at the base case; got %s.',r.status);
assert(abs(r.T_K-445.1253289473684)<1e-6,'Base reference temperature changed.');
assert(abs(r.beta-0.6980459983)<5e-4,'Reference vapour fraction changed beyond source interpolation tolerance.');
b=cps22_material_balance(r,cfg);
assert(abs(b.total_closure_mol_s)<1e-10 && b.max_abs_component_closure_mol_s<1e-8,'Material balance closure failed.');
f=cps22_flash_tp(cfg.conditions.temperature_K,cfg.conditions.pressure_Pa,cfg.feed.z,cfg);
assert(strcmp(f.model_acceptance,'NOT_ACCEPTED_PARAMETER_SET'),'Candidate model acceptance label was changed.');
e=cps22_energy_balance(r,cfg); u=cps22_utilities(e,cfg); eq=cps22_equipment_screen(r,cfg); cost=cps22_economics(eq,u,cfg);
assert(startsWith(e.status,'BLOCKED')&&startsWith(u.status,'BLOCKED')&&startsWith(cost.status,'BLOCKED'), ...
    'Unsupported energy/utilities/cost must remain blocked.');
S=cps22_run_sensitivities(cfg,cfg.paths.reference_data_abs); assert(numel(unique(S.study_id))==5,'Expected five sensitivity groups.');
test_reference_data_header_variants(); test_package_integrity(); test_gamma_phi_input_validation(); test_configuration_integrity();
fprintf('\nAll CPS-22 R4 regression tests passed. This checks software/data plumbing, not predictive model validity.\n');
end
