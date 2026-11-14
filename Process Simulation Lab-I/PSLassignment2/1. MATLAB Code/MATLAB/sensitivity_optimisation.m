function result = sensitivity_optimisation(modelInput,request,options)
%SENSITIVITY_OPTIMISATION Execute versioned ideal-reference throughput sensitivity.
% Throughputs are read from the project-controlled sensitivity plan unless a
% caller supplies a separately sourced override. Each point is recalculated
% by material_balance(), which reads the reaction coefficients from the
% versioned reaction matrix. Nonlinear plant optimisation remains BLOCKED.
narginchk(3,3);
plan=energy008.get_option(modelInput,'sensitivity_plan',struct());
if ~isstruct(plan) || ~isfield(plan,'throughputs_t_day') || ~isfield(plan,'units') || ...
        ~isfield(plan.units,'throughputs_t_day') || ~strcmp(char(plan.units.throughputs_t_day),'t/day') || ...
        ~isfield(plan,'source_id') || isempty(plan.source_id) || ...
        ~isfield(plan,'provenance_class') || isempty(plan.provenance_class)
    msg='A versioned, source-attributed sensitivity_plan with throughputs_t_day and explicit t/day units is required.';
    result=energy008.make_result('sensitivity_optimisation','BLOCKED',struct('blockers',{{msg}}),'N/A',modelInput,{msg},{},struct(),struct()); return;
end
throughputs=plan.throughputs_t_day;
if ~isnumeric(throughputs) || isempty(throughputs) || any(~isfinite(throughputs(:))) || any(throughputs(:)<=0)
    msg='Versioned sensitivity-plan throughput values must be a nonempty vector of positive finite t/day values.';
    result=energy008.make_result('sensitivity_optimisation','FAILED',struct(), 't/day',modelInput,{}, {msg},struct(),struct('source_ids',{{plan.source_id}})); return;
end
if isfield(request,'throughputs_t_day')
    override=energy008.get_option(request,'throughputs_t_day',[]);
    if ~isfield(request,'source_id') || isempty(request.source_id) || ...
            ~isfield(request,'provenance_class') || isempty(request.provenance_class) || ...
            ~isfield(request,'units') || ~strcmp(char(request.units),'t/day')
        msg='Sensitivity overrides require source_id, provenance_class and units="t/day".';
        result=energy008.make_result('sensitivity_optimisation','FAILED',struct(), 't/day',modelInput,{}, {msg},struct(),struct()); return;
    end
    if ~isnumeric(override) || isempty(override) || any(~isfinite(override(:))) || any(override(:)<=0)
        msg='Sensitivity override throughputs must be positive finite t/day values.';
        result=energy008.make_result('sensitivity_optimisation','FAILED',struct(), 't/day',modelInput,{}, {msg},struct(),struct('source_ids',{{request.source_id}})); return;
    end
    throughputs=override;
    sensitivitySource=char(request.source_id);
else
    sensitivitySource=char(plan.source_id);
end
if ~isfield(modelInput,'case_data') || ~isfield(modelInput.case_data,'assumptions') || ...
        ~isfield(modelInput.case_data,'methanol_component_equivalent_kg_day')
    msg='Default case throughput and R-02 reference assumption are required to scale the sensitivity cases.';
    result=energy008.make_result('sensitivity_optimisation','BLOCKED',struct('blockers',{{msg}}),'N/A',modelInput,{msg},{},struct(),struct()); return;
end
baseCase=modelInput.case_data;
baseRate_t_day=baseCase.methanol_component_equivalent_kg_day/1000;
if ~isfinite(baseRate_t_day) || baseRate_t_day<=0
    msg='Base case throughput is invalid for sensitivity scaling.';
    result=energy008.make_result('sensitivity_optimisation','FAILED',struct(), 't/day',modelInput,{}, {msg},struct(),struct()); return;
end
r02Base=baseCase.assumptions.R02_extent_kmol_day;
rows=numel(throughputs);
meoh_t_day=zeros(rows,1); meoh_kmol_day=zeros(rows,1); co2_kg_day=zeros(rows,1);
h2_kg_day=zeros(rows,1); water_kg_day=zeros(rows,1); oxygen_kg_day=zeros(rows,1);
runStatus=cell(rows,1); caseIds=cell(rows,1); maxElementResidual=zeros(rows,1);
for k=1:rows
    cModel=modelInput;
    cModel.case_data.methanol_component_equivalent_kg_day=unit_conversions( ...
        struct('conversion','t_day_to_kg_day','value',throughputs(k)));
    cModel.case_data.assumptions.R02_extent_kmol_day=r02Base*(throughputs(k)/baseRate_t_day);
    cModel.case_data.case_id=sprintf('%s-SENS-%02d',char(baseCase.case_id),k);
    cModel.case_data.case_version=energy008.get_option(baseCase,'case_version','0.1.0');
    caseIds{k}=cModel.case_data.case_id;
    iv=input_validation(cModel,struct('scope','throughput_sensitivity_point'),options);
    if ~strcmp(iv.status,'CALCULATED')
        msg=sprintf('Sensitivity point %g t/day failed case/schema validation.',throughputs(k));
        result=energy008.make_result('sensitivity_optimisation','FAILED', ...
            struct('failed_case_id',caseIds{k},'input_validation',iv,'reason',msg),'N/A',modelInput,{msg},{}, ...
            iv.residuals,struct('source_ids',{{sensitivitySource,plan.source_id}})); return;
    end
    mb=material_balance(cModel,struct('sensitivity_plan_id',plan.plan_id),options);
    if any(strcmp(mb.status,{'BLOCKED','FAILED','NOT_RUN'})) || ~isfield(mb,'value') || ~isfield(mb.value,'mass_flows')
        msg=sprintf('Sensitivity point %g t/day did not calculate: %s.',throughputs(k),mb.status);
        result=energy008.make_result('sensitivity_optimisation',mb.status, ...
            struct('failed_case_id',caseIds{k},'failed_result',mb,'reason',msg),'N/A',modelInput,{msg},{}, ...
            mb.residuals,struct('source_ids',{{sensitivitySource,plan.source_id}})); return;
    end
    v=mb.value;
    meoh_t_day(k)=throughputs(k);
    meoh_kmol_day(k)=v.molar_flows.methanol_kmol_day;
    co2_kg_day(k)=v.mass_flows.CO2_kg_day;
    h2_kg_day(k)=v.mass_flows.H2_kg_day;
    water_kg_day(k)=v.mass_flows.electrolyser_water_kg_day;
    oxygen_kg_day(k)=v.mass_flows.O2_kg_day;
    runStatus{k}=mb.status;
    maxElementResidual(k)=mb.residuals.max_abs_element_residual_kmol_atoms_day;
end
T=table(meoh_t_day,meoh_kmol_day,co2_kg_day,h2_kg_day,water_kg_day,oxygen_kg_day,runStatus,caseIds,maxElementResidual, ...
    'VariableNames',{'Methanol_t_day','Methanol_kmol_day','CO2_lower_bound_kg_day','H2_lower_bound_kg_day', ...
    'Electrolyser_DI_water_kg_day','O2_theoretical_kg_day','Calculation_Status','Case_ID','Max_Element_Residual_kmol_atoms_day'});
values=struct('sensitivity_plan_id',plan.plan_id,'sensitivity_plan_version',plan.plan_version, ...
    'throughputs_t_day',throughputs(:),'sensitivity_source_id',sensitivitySource, ...
    'stoichiometric_sensitivity',T,'optimisation',struct('status','BLOCKED','optimum',[], ...
    'reason','No validated nonlinear plant model, operating constraints, site utility inputs or economic objective is available.'), ...
    'sensitivity_scope','Each throughput point is recalculated by the versioned stoichiometric material module. This is ideal-reference flow scaling only, not plant performance sensitivity, capacity feasibility or optimisation.');
result=energy008.make_result('sensitivity_optimisation','SCREENING_ONLY',values, ...
    struct('input_throughput','t/day','internal_material_flows','kg/s; mol/s','export','t/day; kg/day; kmol/day'), ...
    modelInput,{'Throughput sensitivity is reference arithmetic only; actual process response and optimisation remain blocked.'}, {}, ...
    struct('max_element_residual_kmol_atoms_day',max(maxElementResidual)), ...
    struct('source_ids',{{sensitivitySource,plan.source_id,'ENERGY008-RXN-0.1.0','ENERGY008-HAND-BASE-C-01'}}));
end
