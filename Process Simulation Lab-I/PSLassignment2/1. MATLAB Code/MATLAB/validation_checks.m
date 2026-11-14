function result = validation_checks(modelInput,request,options)
%VALIDATION_CHECKS Verify calculated outputs against frozen Prompt 17 regression fixture.
narginchk(3,3);
material=energy008.get_option(request,'material_result',struct());
energy=energy008.get_option(request,'energy_result',struct());
props=energy008.get_option(request,'property_result',struct());
equip=energy008.get_option(request,'equipment_result',struct());
entropy=energy008.get_option(request,'entropy_result',struct());
utilities=energy008.get_option(request,'utilities_result',struct());
if ~isfield(entropy,'value'), entropy=entropy_exergy(modelInput,struct(),options); end
if ~isfield(utilities,'value'), utilities=utilities_model(modelInput,struct('material_result',material),options); end
if ~isfield(material,'value') || ~isfield(energy,'value') || ~isfield(props,'value') || ~isfield(equip,'value')
    msg='Regression validation requires material, energy, property and equipment module results.';
    result=energy008.make_result('validation_checks','BLOCKED',struct('blockers',{{msg}}),'N/A',modelInput,{msg},{},struct(),struct()); return;
end
f=modelInput.fixture; e=f.expected_outputs; tol=f.acceptance_tolerances;
checks={};
checks=addNum(checks,'TC-01',material.value.molar_flows.methanol_kmol_day,e.methanol_kmol_day,tol.molar_flow_abs_kmol_day,'kmol/day');
checks=addNum(checks,'TC-02',material.value.mass_flows.CO2_kg_day,e.co2_kg_day,tol.mass_flow_abs_kg_day,'kg/day');
checks=addNum(checks,'TC-03',material.value.mass_flows.H2_kg_day,e.h2_kg_day,tol.mass_flow_abs_kg_day,'kg/day');
checks=addNum(checks,'TC-04',material.value.mass_flows.electrolyser_water_kg_day,e.electrolyser_water_kg_day,tol.mass_flow_abs_kg_day,'kg/day');
checks=addNum(checks,'TC-05',material.value.mass_flows.O2_kg_day,e.oxygen_kg_day,tol.mass_flow_abs_kg_day,'kg/day');
checks=addNum(checks,'TC-06',max(abs([material.value.element_residual_kmol_atoms_day.C,material.value.element_residual_kmol_atoms_day.H,material.value.element_residual_kmol_atoms_day.O])),0,tol.element_balance_abs_kmol_atoms_day,'kmol-atoms/day');
checks=addNum(checks,'TC-07',material.value.mass_balance.residual_input_minus_output_kg_day,e.mass_balance_residual_kg_day,tol.mass_residual_abs_kg_day,'kg/day');
checks=addNum(checks,'TC-08',energy.value.reaction_reference.net_delta_h_kJ_mol_MeOH,e.net_kJ_mol_MeOH,tol.reaction_enthalpy_identity_abs_kJ_mol,'kJ/mol');
checks=addNum(checks,'TC-09',props.value.co2_sensible.duty_kW,e.co2_ideal_gas_sensible_duty_kW,tol.CO2_sensible_duty_abs_kW,'kW');
checks=addNum(checks,'TC-10',props.value.methanol_latent.duty_kW,e.methanol_latent_reference_duty_kW,tol.methanol_latent_duty_abs_kW,'kW');
checks=addNum(checks,'TC-11',equip.value.HX_example.area_m2,e.illustrative_exchanger_area_m2,tol.HX_area_abs_m2,'m2');
checks=addNum(checks,'TC-12',equip.value.W201_pump_example.shaft_power_kW,e.W201_pump_shaft_power_kW,tol.pump_power_abs_kW,'kW');
% TC-13..TC-18 are executable semantic assertions, not hard-coded expected statuses.
opts=struct('run_id',modelInput.run_id);
bad=modelInput; bad.case_data.methanol_component_equivalent_kg_day=-1;
badFlow=input_validation(bad,struct('scope','negative_flow_test'),opts);
checks=addGate(checks,'TC-13','NEGATIVE_FLOW_REJECTION',strcmp(badFlow.status,'FAILED'), ...
    'Negative throughput was passed to input_validation and must be rejected as FAILED.');
missingKij=property_models(modelInput,struct('property_request','pr78_mixture'),opts);
checks=addGate(checks,'TC-14','MISSING_EOS_KIJ',strcmp(missingKij.status,'BLOCKED') && ...
    isfield(missingKij.value,'value') && isempty(missingKij.value.value), ...
    'A PR78 mixture request must return BLOCKED with a null property value while active kij pairs are missing.');
recycleStatus='INVALID'; purgeStatus='INVALID';
if isfield(material.value,'physical_recycle'), recycleStatus=material.value.physical_recycle.status; end
if isfield(material.value,'physical_purge'), purgeStatus=material.value.physical_purge.status; end
checks=addGate(checks,'TC-15','S209_RECYCLE',strcmp(recycleStatus,'BLOCKED_NOT_COMPUTED'), ...
    'The material-balance output must keep physical S-209 recycle null and BLOCKED_NOT_COMPUTED.');
checks=addGate(checks,'TC-16','S207_PURGE',strcmp(purgeStatus,'BLOCKED_NOT_COMPUTED'), ...
    'The material-balance output must keep physical S-207 purge null and BLOCKED_NOT_COMPUTED.');
negativeSgen=entropy_exergy(modelInput,struct('entropy_generation_kW_K',-1e-6),opts);
checks=addGate(checks,'TC-17','NEGATIVE_ENTROPY_GENERATION',strcmp(negativeSgen.status,'FAILED') && ...
    isfield(negativeSgen,'diagnostics') && ~isempty(negativeSgen.diagnostics), ...
    'A negative supplied entropy-generation rate must produce a FAILED diagnostic, never be clipped.');
plantBlocked=isfield(energy.value,'plant_energy_closure') && ...
    strcmp(energy.value.plant_energy_closure.status,'BLOCKED') && ...
    isfield(energy.value,'reactor_cooling_duty') && strcmp(energy.value.reactor_cooling_duty.status,'BLOCKED') && ...
    isfield(material.value,'physical_recycle') && isempty(material.value.physical_recycle.value) && ...
    isfield(entropy.value,'plant_entropy_generation') && strcmp(entropy.value.plant_entropy_generation.status,'BLOCKED') && ...
    isfield(entropy.value,'plant_exergy_destruction') && strcmp(entropy.value.plant_exergy_destruction.status,'BLOCKED') && ...
    isfield(entropy.value,'entropy_closure') && strcmp(entropy.value.entropy_closure.status,'BLOCKED') && ...
    isfield(entropy.value,'exergy_closure') && strcmp(entropy.value.exergy_closure.status,'BLOCKED') && ...
    isfield(utilities.value,'electricity') && strcmp(utilities.value.electricity.status,'BLOCKED') && ...
    isfield(utilities.value,'cooling_and_steam') && strcmp(utilities.value.cooling_and_steam.status,'BLOCKED');
checks=addGate(checks,'TC-18','PLANT_ENERGY_ENTROPY_EXERGY_AND_UTILITY_GATES',plantBlocked, ...
    'Plant energy/entropy/exergy closures, reactor duty, actual utilities and physical recycle must remain explicitly blocked/null.');
ids=cellfun(@(x)x.test_id,checks,'UniformOutput',false);
passNum=cellfun(@(x)strcmp(x.status,'PASS'),checks);
numFails=sum(~passNum);
% Build explicit flat table with uniform scalar/text columns.
testId=cellfun(@(x)x.test_id,checks,'UniformOutput',false)';
name=cellfun(@(x)x.name,checks,'UniformOutput',false)';
observed=cellfun(@(x)x.observed,checks,'UniformOutput',false)';
expected=cellfun(@(x)x.expected,checks,'UniformOutput',false)';
tolerance=cellfun(@(x)x.tolerance,checks,'UniformOutput',false)';
units=cellfun(@(x)x.units,checks,'UniformOutput',false)';
status=cellfun(@(x)x.status,checks,'UniformOutput',false)';
note=cellfun(@(x)x.note,checks,'UniformOutput',false)';
T=table(testId,name,observed,expected,tolerance,units,status,note,'VariableNames',{'Test_ID','Test_Name','Observed','Expected','Tolerance','Units','Status','Note'});
statusOut='PASS_WITH_BLOCKED_PHYSICAL_GATES';
if numFails>0, statusOut='FAILED'; end
values=struct('test_table',T,'test_count',height(T),'numeric_test_count',12,'numeric_failures',numFails, ...
    'gate_test_count',6,'gate_failures',sum(~passNum(13:18)),'fixture_id',f.fixture_id, ...
    'physical_flowsheet_validated',false,'prompt21_validation_required',true);
result=energy008.make_result('validation_checks',statusOut,values,'test records',modelInput, ...
 {'Passing hand-calculation fixture verifies only the reference arithmetic. It does not validate the physical plant model.'}, {}, ...
 struct('numeric_test_failures',numFails),struct('source_ids',{{f.fixture_id,'ENERGY008-MAN-001'}}));
end
function c=addNum(c,id,obs,expv,tol,units)
pass=isfinite(obs) && abs(obs-expv)<=tol;
if pass, st='PASS'; else, st='FAIL'; end
c{end+1}=struct('test_id',id,'name','Numeric regression','observed',num2str(obs,17),'expected',num2str(expv,17), ...
    'tolerance',num2str(tol,6),'units',units,'status',st,'note','Absolute difference checked against unrounded fixture value.');
end
function c=addGate(c,id,name,passed,note)
if passed, st='PASS'; observed='EXPECTED_GATE_CONFIRMED'; else, st='FAIL'; observed='GATE_NOT_CONFIRMED'; end
c{end+1}=struct('test_id',id,'name',name,'observed',observed,'expected','PASS','tolerance','Exact','units','N/A','status',st,'note',note);
end
