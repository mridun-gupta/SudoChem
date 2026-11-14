function result = scenario_runner(modelInput,request,options)
%SCENARIO_RUNNER Execute declared route cases and DB-059 screening event.
% Route A is a common-core stoichiometric comparator; Route B is BLOCKED;
% Route C turndown is linear stoichiometric screening, not dynamic validation.
% For executable C/A cases, reference enthalpy rates are recalculated from
% that scenario's own mol/s flows. Actual process duties remain blocked.
narginchk(3,3);
allCases=modelInput.cases;
allCases(end+1)=modelInput.case_data; % include the default Route C base reference
rows=cell(0,17); details=struct([]); warnings={};
for k=1:numel(allCases)
    caseModel=modelInput;
    caseModel.case_data=allCases(k);
    c=caseModel.case_data;
    iv=input_validation(caseModel,struct('scope','scenario_case'),options);
    if strcmp(iv.status,'FAILED')
        material=iv; energy=struct('status','BLOCKED','value',struct('blockers',{{'Material input validation failed.'}}));
        validationStatus='FAILED';
    else
        validationStatus=iv.status;
        material=material_balance(caseModel,struct('case_id',c.case_id),options);
        if any(strcmp(material.status,{'BLOCKED','FAILED'}))
            energy=struct('status','BLOCKED','value',struct('blockers',{{'Scenario material calculation is unavailable.'}}));
        else
            props=property_models(caseModel,struct('property_request','all_benchmark'),options);
            energy=energy_balance(caseModel,struct('material_result',material,'property_result',props),options);
        end
    end
    meoh=NaN; co2=NaN; h2=NaN; water=NaN; o2=NaN;
    if isfield(material,'value') && isfield(material.value,'mass_flows')
        meoh=material.value.mass_flows.CH3OH_kg_day;
        co2=material.value.mass_flows.CO2_kg_day;
        h2=material.value.mass_flows.H2_kg_day;
        water=material.value.mass_flows.electrolyser_water_kg_day;
        o2=material.value.mass_flows.O2_kg_day;
    end
    r01=NaN; e01=NaN; co2Sensible=NaN; meohLatent=NaN;
    if isfield(energy,'value') && isfield(energy.value,'reaction_reference')
        r01=energy.value.reaction_reference.R01_rate_GJ_day;
        e01=energy.value.reaction_reference.E01_rate_GJ_day;
        co2Sensible=energy.value.co2_sensible_heating.duty_kW;
        meohLatent=energy.value.methanol_latent_reference.duty_kW;
    end
    rows(end+1,:)={c.case_id,c.route_id,c.scenario_type,material.status,validationStatus,energy.status, ...
        c.methanol_component_equivalent_kg_day,meoh,co2,h2,water,o2,r01,e01,co2Sensible,meohLatent,NaN}; %#ok<AGROW>
    item=struct('case_id',c.case_id,'route_id',c.route_id,'status',material.status, ...
        'validation_status',validationStatus,'energy_reference_status',energy.status, ...
        'blockers',{energy008.cellstr_safe(c.blockers)});
    if isempty(details), details=item; else, details(end+1)=item; end %#ok<AGROW>
    warnings=[warnings,iv.warnings,material.warnings,energy.warnings]; %#ok<AGROW>
end

% The disturbance is explicitly evaluated by control_logic, not by a dynamic model.
control=energy008.get_option(request,'control_result',struct());
if ~isfield(control,'status')
    baseModel=modelInput;
    baseMat=material_balance(baseModel,struct('case_id',baseModel.case_data.case_id),options);
    control=control_logic(baseModel,struct('material_result',baseMat),options);
end
d=modelInput.disturbance;
detail=struct('case_id',d.case_id,'route_id','Route C','scenario_type','DISTURBANCE_SCREENING', ...
    'status',control.status,'validation_status','NOT_APPLICABLE','energy_reference_status','NOT_APPLICABLE', ...
    'blockers',{energy008.cellstr_safe(d.limitations)});
if isempty(details), details=detail; else, details(end+1)=detail; end %#ok<AGROW>
dH2=NaN;
if isfield(control,'value') && isfield(control.value,'screening_h2_deficit_kg')
    dH2=control.value.screening_h2_deficit_kg;
end
rows(end+1,:)={d.case_id,'Route C','DISTURBANCE_SCREENING',control.status,'NOT_APPLICABLE','NOT_APPLICABLE', ...
    modelInput.case_data.methanol_component_equivalent_kg_day,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,dH2}; %#ok<AGROW>
T=cell2table(rows,'VariableNames',{'Case_ID','Route_ID','Scenario_Type','Status','Input_Validation_Status', ...
    'Energy_Reference_Status','Target_Methanol_Component_Equivalent_kg_day','Methanol_kg_day','CO2_kg_day','H2_kg_day', ...
    'Electrolyser_Water_kg_day','O2_kg_day','R01_Reference_Rate_GJ_day','E01_Thermoneutral_Reference_GJ_day', ...
    'CO2_Sensible_Reference_kW','Methanol_Latent_Reference_kW','DB059_H2_Deficit_kg_per_event'});
values=struct('scenario_table',T,'details',details, ...
    'disturbance',struct('case_id',d.case_id,'status',control.status,'H2_deficit_kg_per_event',dH2, ...
    'dynamic_simulation_status','BLOCKED','reason','No OEM electrolyser ramp/minimum-load map, H2 buffer inventory or synthesis turndown dynamics.'), ...
    'interpretation','Route A shares the ideal CO2-hydrogenation stoichiometric core only; Route B stays BLOCKED; Route C turndown and DB-059 are screening calculations only. Reference enthalpy rates are not equipment duties.');
result=energy008.make_result('scenario_runner','SCREENING_ONLY',values,'kg/day; GJ/day reference; kW reference; kg/event', ...
    modelInput,[warnings,{'The scenario table is not a validated side-by-side plant performance comparison.'}],{},struct(), ...
    struct('source_ids',{{'ENERGY008_Base_and_Alternative_Cases.csv','DB-013','DB-059','ENERGY008-HAND-BASE-C-01'}}));
end
