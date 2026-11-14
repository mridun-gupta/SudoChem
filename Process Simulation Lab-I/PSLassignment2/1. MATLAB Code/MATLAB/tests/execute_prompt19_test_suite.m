function report = execute_prompt19_test_suite(projectRoot)
%RUN_PROMPT19_TESTS Execute Prompt 19 unit/regression tests without a test toolbox.
% Usage: report = run_prompt19_tests(projectRoot). Run after START_HERE has added MATLAB/.
if nargin<1 || isempty(projectRoot)
    f=mfilename('fullpath'); projectRoot=fileparts(fileparts(fileparts(f)));
end
cfg=jsondecode(fileread(fullfile(projectRoot,'MATLAB','project_config.json')));
model=load_model_inputs(projectRoot,cfg,'TEST-RUN');
opts=struct('run_id','TEST-RUN','allow_reference_only',true,'allow_screening_only',true);
checks={};
try
 v=input_validation(model,struct(),opts); assert(strcmp(v.status,'CALCULATED')); checks{end+1}='input_validation';
 p=property_models(model,struct('property_request','all_benchmark'),opts); assert(strcmp(p.status,'CALCULATED')); checks{end+1}='property_models';
 m=material_balance(model,struct(),opts); assert(strcmp(m.status,'REFERENCE_ONLY')); checks{end+1}='material_balance';
 % Nonzero R-02 remains a stoichiometric unit check only. Matrix-derived
 % electrolysis extent must close H2 and preserve C/H/O and mass accounting.
 r02Model=model; r02Model.case_data.assumptions.R02_extent_kmol_day=10;
 r02Material=material_balance(r02Model,struct(),opts);
 assert(strcmp(r02Material.status,'REFERENCE_ONLY'));
 assert(r02Material.value.SI_flows.molar_flows_mol_s.H2_from_electrolyser>0);
 assert(abs(r02Material.value.SI_flows.molar_flows_mol_s.H2_from_electrolyser- ...
     r02Material.value.SI_flows.molar_flows_mol_s.H2)<1e-10);
 assert(r02Material.value.SI_flows.molar_flows_mol_s.CO>0);
 assert(max(abs([r02Material.value.element_residual_kmol_atoms_day.C, ...
     r02Material.value.element_residual_kmol_atoms_day.H,r02Material.value.element_residual_kmol_atoms_day.O]))<1e-8);
 checks{end+1}='R02_nonzero_extent_stoichiometric_balance';
 % Scale the R-01 reaction vector by two. This equivalent reaction basis must
 % halve the extent while preserving all physical species rates, proving the
 % material module reads coefficients from the versioned matrix.
 scaledModel=model; jR01=find(strcmp(scaledModel.reaction_network.reaction_order,'R-01'),1);
 scaledModel.reaction_network.stoichiometric_matrix_products_positive(:,jR01)= ...
     2*scaledModel.reaction_network.stoichiometric_matrix_products_positive(:,jR01);
 scaledMaterial=material_balance(scaledModel,struct(),opts);
 assert(strcmp(scaledMaterial.status,'REFERENCE_ONLY'));
 assert(abs(scaledMaterial.value.reaction_extents_SI_mol_s.R01- ...
     0.5*m.value.reaction_extents_SI_mol_s.R01)<1e-12);
 assert(abs(scaledMaterial.value.SI_flows.mass_flows_kg_s.CO2_kg_s- ...
     m.value.SI_flows.mass_flows_kg_s.CO2_kg_s)<1e-12);
 checks{end+1}='reaction_matrix_coefficients_data_driven';
 e=energy_balance(model,struct('material_result',m,'property_result',p),opts); assert(strcmp(e.status,'SCREENING_ONLY'));
 assert(strcmp(e.value.reaction_reference_uncertainty.status,'SOURCE_PROPAGATED_SCREENING'));
 assert(e.value.reaction_reference_uncertainty.net_rate_sigma_GJ_day>0); checks{end+1}='energy_balance_with_source_uncertainty';
 ex=entropy_exergy(model,struct(),opts); assert(strcmp(ex.status,'BLOCKED')); checks{end+1}='entropy_exergy_blocker';
 es=equipment_sizing(model,struct('material_result',m,'energy_result',e),opts); assert(strcmp(es.status,'SCREENING_ONLY')); checks{end+1}='equipment_sizing';
 u=utilities_model(model,struct('material_result',m),opts); assert(strcmp(u.status,'BLOCKED')); checks{end+1}='utilities_blockers';
 cl=control_logic(model,struct('material_result',m),opts); assert(strcmp(cl.status,'SCREENING_ONLY')); checks{end+1}='control_logic';
 ec=economics(model,struct(),opts); assert(strcmp(ec.status,'BLOCKED')); checks{end+1}='economics_blocker';
 sr=scenario_runner(model,struct(),opts); assert(strcmp(sr.status,'SCREENING_ONLY'));
 T=sr.value.scenario_table; assert(height(T)==numel(model.cases)+2);
 iA=find(strcmp(T.Route_ID,'Route A'),1); iB=find(strcmp(T.Route_ID,'Route B'),1);
 iC=find(strcmp(T.Scenario_Type,'TURNDOWN_SCREENING'),1); iD=find(strcmp(T.Scenario_Type,'DISTURBANCE_SCREENING'),1);
 assert(~isempty(iA)&&strcmp(T.Status{iA},'REFERENCE_ONLY'));
 assert(~isempty(iB)&&strcmp(T.Status{iB},'BLOCKED'));
 assert(~isempty(iC)&&strcmp(T.Status{iC},'SCREENING_ONLY'));
 assert(~isempty(iD)&&strcmp(T.Status{iD},'SCREENING_ONLY'));
 iBase=find(strcmp(T.Case_ID,model.case_data.case_id),1);
 assert(~isempty(iBase)&&strcmp(T.Energy_Reference_Status{iBase},'SCREENING_ONLY'));
 assert(abs(T.R01_Reference_Rate_GJ_day(iC)/T.R01_Reference_Rate_GJ_day(iBase)-0.5)<1e-10);
 checks{end+1}='scenario_execution_and_reference_energy_scaling';
 se=sensitivity_optimisation(model,struct(),opts); assert(strcmp(se.status,'SCREENING_ONLY'));
 ST=se.value.stoichiometric_sensitivity; assert(isequal(ST.Methanol_t_day(:),[45;50;55]));
 assert(abs(ST.CO2_lower_bound_kg_day(1)/ST.CO2_lower_bound_kg_day(2)-0.9)<1e-10);
 assert(abs(ST.CO2_lower_bound_kg_day(3)/ST.CO2_lower_bound_kg_day(2)-1.1)<1e-10);
 checks{end+1}='versioned_sensitivity_plan_and_matrix_based_recalculation';
 conv=unit_conversions(struct('conversion','kg_day_to_kg_h','value',240)); assert(abs(conv-10)<1e-12);
 mSI=unit_conversions(struct('conversion','kg_day_to_kg_s','value',86400));
 assert(abs(mSI-1)<1e-12); assert(abs(unit_conversions(struct('conversion','kg_s_to_kg_day','value',mSI))-86400)<1e-9);
 assert(unit_conversions(struct('conversion','t_day_to_kg_day','value',1))==1000);
 assert(unit_conversions(struct('conversion','kg_day_to_t_day','value',1000))==1);
 nSI=unit_conversions(struct('conversion','kmol_day_to_mol_s','value',86.4));
 assert(abs(nSI-1)<1e-12); assert(abs(unit_conversions(struct('conversion','mol_s_to_kmol_day','value',nSI))-86.4)<1e-12);
 checks{end+1}='si_import_export_unit_conversions';
 map=@(x)0.5*x+1; rec=recycle_solver(model,struct('solver_scope','SYNTHETIC_UNIT_TEST','map_function',map,'initial_guess',0,'tolerance',1e-8,'maximum_iterations',100),opts); assert(strcmp(rec.status,'CALCULATED')&&abs(rec.value.solution-2)<1e-7); checks{end+1}='synthetic_recycle_contraction';
 ode=@(x,y)-y; odeResult=pfr_integrator(model,struct('ode_function',ode,'coordinate_span',[0 1],'initial_state',1,'positive_state_indices',1,'relative_tolerance',1e-4,'absolute_tolerance',1e-7,'maximum_refinements',10),opts); assert(strcmp(odeResult.status,'CALCULATED')&&abs(odeResult.value.final_state-exp(-1))<2e-4); checks{end+1}='synthetic_pfr_integrator';
 er=reactor_calculation(model,struct(),opts); assert(strcmp(er.status,'BLOCKED')); checks{end+1}='physical_pfr_gate_blocked';
 recBlocked=recycle_solver(model,struct(),opts); assert(strcmp(recBlocked.status,'BLOCKED'));
 assert(isempty(recBlocked.value.physical_recycle_value)); checks{end+1}='physical_recycle_gate_blocked';
 env=environmental_kpis(model,struct(),opts); assert(strcmp(env.status,'BLOCKED'));
 assert(strcmp(env.value.metrics.ghg_intensity.status,'BLOCKED')); checks{end+1}='environmental_mrv_gate_blocked';
 % Synthetic, fully sourced measurement record exercises SI environmental KPI arithmetic.
 meas=struct('measured_electricity_kWh_day',1000,'electricity_emission_factor_kgCO2e_per_kWh',0.5, ...
   'direct_non_biogenic_GHG_kgCO2e_day',100,'methanol_saleable_kg_day',2000, ...
   'water_withdrawal_m3_day',10,'water_discharge_m3_day',2,'solid_waste_kg_day',100, ...
   'renewable_electricity_fraction',0.9,'biogenic_CO2_chain_of_custody','VERIFIED', ...
   'ghg_mrv_method_version','SYNTHETIC-MRV-TEST','measurement_period_start','2026-01-01', ...
   'measurement_period_end','2026-12-31','provenance_class','SYNTHETIC_UNIT_TEST');
 meas.units=struct('measured_electricity_kWh_day','kWh/day','electricity_emission_factor_kgCO2e_per_kWh','kg CO2e/kWh', ...
   'direct_non_biogenic_GHG_kgCO2e_day','kg CO2e/day','methanol_saleable_kg_day','kg/day', ...
   'water_withdrawal_m3_day','m3/day','water_discharge_m3_day','m3/day','solid_waste_kg_day','kg/day', ...
   'renewable_electricity_fraction','fraction');
 sf=energy008.cellstr_safe(model.environmental_basis.required_source_map_fields); sm=struct();
 for kk=1:numel(sf), sm.(sf{kk})=['SYNTHETIC-ENV-' sf{kk}]; end
 meas.source_map=sm; envCalc=environmental_kpis(model,struct('measurements',meas),opts);
 assert(strcmp(envCalc.status,'SCREENING_ONLY'));
 assert(abs(envCalc.value.metrics.ghg_intensity.value-0.3)<1e-12);
 assert(abs(envCalc.value.metrics.net_water_intensity.value-4.0)<1e-12);
 assert(abs(envCalc.value.metrics.solid_waste_intensity.value-50.0)<1e-12);
 checks{end+1}='synthetic_environmental_kpi_calculation';
 % Water intensity has its own provenance gate; missing unrelated GHG sources
 % must not prevent a complete water meter record from being evaluated.
 waterOnly=struct('water_withdrawal_m3_day',10,'water_discharge_m3_day',2, ...
   'methanol_saleable_kg_day',2000,'measurement_period_start','2026-01-01', ...
   'measurement_period_end','2026-12-31','provenance_class','SYNTHETIC_UNIT_TEST');
 waterOnly.units=struct('water_withdrawal_m3_day','m3/day','water_discharge_m3_day','m3/day', ...
   'methanol_saleable_kg_day','kg/day');
 waterOnly.source_map=struct('water_withdrawal_m3_day','SYNTHETIC-WATER-IN', ...
   'water_discharge_m3_day','SYNTHETIC-WATER-OUT','methanol_saleable_kg_day','SYNTHETIC-MEOH');
 waterOnlyResult=environmental_kpis(model,struct('measurements',waterOnly),opts);
 assert(strcmp(waterOnlyResult.value.metrics.net_water_intensity.status,'SCREENING_ONLY'));
 assert(strcmp(waterOnlyResult.value.metrics.ghg_intensity.status,'BLOCKED'));
 assert(abs(waterOnlyResult.value.metrics.net_water_intensity.value-4.0)<1e-12);
 checks{end+1}='independent_environmental_metric_source_gates';
 % Synthetic cost record exercises quote escalation, OPEX, CRF and source uncertainty.
 cost=struct('currency','INR','reference_year',2026);
 cost.quote_items=struct('equipment_id','E-SYN-01','bare_equipment_quote_INR',1e6,'quote_year',2024, ...
   'escalation_index_at_quote',100,'escalation_index_at_reference_year',110,'location_factor',1.1, ...
   'installation_factor',1.5,'contingency_fraction',0.1,'uncertainty_fraction',0.1,'currency','INR','source_id','SYNTHETIC-QUOTE');
 o=struct('electricity_kWh_year',100000,'electricity_tariff_INR_kWh',8,'electricity_uncertainty_fraction',0.1, ...
   'water_m3_year',1000,'water_tariff_INR_m3',20,'water_uncertainty_fraction',0.1, ...
   'steam_t_year',100,'steam_tariff_INR_t',1500,'steam_uncertainty_fraction',0.1, ...
   'chemicals_INR_year',100000,'chemicals_uncertainty_fraction',0.1,'labour_INR_year',200000, ...
   'labour_uncertainty_fraction',0.1,'maintenance_fraction_installed_CAPEX',0.05, ...
   'maintenance_uncertainty_fraction',0.1,'waste_t_year',10,'waste_tariff_INR_t',500, ...
   'waste_uncertainty_fraction',0.1,'saleable_methanol_t_year',15000,'discount_rate_fraction',0.1,'plant_life_years',20);
 odf={'electricity_kWh_year','electricity_tariff_INR_kWh','electricity_uncertainty_fraction', ...
   'water_m3_year','water_tariff_INR_m3','water_uncertainty_fraction','steam_t_year','steam_tariff_INR_t', ...
   'steam_uncertainty_fraction','chemicals_INR_year','chemicals_uncertainty_fraction','labour_INR_year', ...
   'labour_uncertainty_fraction','maintenance_fraction_installed_CAPEX','maintenance_uncertainty_fraction', ...
   'waste_t_year','waste_tariff_INR_t','waste_uncertainty_fraction','saleable_methanol_t_year', ...
   'discount_rate_fraction','plant_life_years'}; os=struct();
 for kk=1:numel(odf), os.(odf{kk})=['SYNTHETIC-COST-' odf{kk}]; end
 o.source_map=os; cost.annual_cost_drivers=o;
 ecCalc=economics(model,struct('cost_estimate',cost),opts);
 assert(strcmp(ecCalc.status,'SCREENING_ONLY'));
 assert(ecCalc.value.CAPEX_INR>0 && ecCalc.value.OPEX_INR_per_year>0 && ecCalc.value.levelised_cost_INR_per_t_MeOH>0);
 assert(strcmp(ecCalc.value.cost_uncertainty.status,'SOURCE_PROPAGATED_SCREENING'));
 checks{end+1}='synthetic_cost_model_calculation';
 va=validation_checks(model,struct('material_result',m,'energy_result',e,'property_result',p,'equipment_result',es),opts); assert(strcmp(va.status,'PASS_WITH_BLOCKED_PHYSICAL_GATES')); checks{end+1}='fixture_regression';
 % Explicit negative-flow and missing-kij/negative-Sgen gates.
 bad=model; bad.case_data.methanol_component_equivalent_kg_day=-1; iv=input_validation(bad,struct(),opts); assert(strcmp(iv.status,'FAILED')); checks{end+1}='negative_throughput_rejected';
 badUnits=model; badUnits.case_data.units.methanol_component_equivalent_kg_day='t/day'; ivUnits=input_validation(badUnits,struct(),opts); assert(strcmp(ivUnits.status,'FAILED')); checks{end+1}='case_unit_mismatch_rejected';
 badVersion=model; badVersion.case_data.property_data_version='ENERGY008-DATA-9.9.9'; ivVersion=input_validation(badVersion,struct(),opts); assert(strcmp(ivVersion.status,'FAILED')); checks{end+1}='case_version_mismatch_rejected';
 pr=property_models(model,struct('property_request','pr78_mixture'),opts); assert(strcmp(pr.status,'BLOCKED')); checks{end+1}='missing_kij_blocked';
 unsupported=property_models(model,struct('property_request','water_viscosity'),opts); assert(strcmp(unsupported.status,'BLOCKED')); checks{end+1}='unsupported_property_fails_closed';
 neg=entropy_exergy(model,struct('entropy_generation_kW_K',-0.1),opts); assert(strcmp(neg.status,'FAILED')); checks{end+1}='negative_sgen_diagnostic';
 badDist=model; badDist.disturbance.available_power_fraction=1.5; badDisturbance=control_logic(badDist,struct('material_result',m),opts); assert(strcmp(badDisturbance.status,'FAILED')); checks{end+1}='invalid_DB059_fraction_rejected';
 badDate=waterOnly; badDate.measurement_period_start='2026-13-40'; badDateResult=environmental_kpis(model,struct('measurements',badDate),opts); assert(strcmp(badDateResult.status,'FAILED')); checks{end+1}='invalid_environmental_period_rejected';
 report=struct('status','PASS','test_count',numel(checks),'passed',{checks},'runtime',version,'run_time_local',datestr(now,'yyyy-mm-ddTHH:MM:SS'));
catch ME
 report=struct('status','FAIL','test_count',numel(checks),'passed',{checks},'error_identifier',ME.identifier,'error_message',ME.message,'runtime',version);
 rethrow(ME);
end
fprintf('ENERGY-008 Prompt 19 tests: %s (%d checks)\n',report.status,report.test_count);
end
