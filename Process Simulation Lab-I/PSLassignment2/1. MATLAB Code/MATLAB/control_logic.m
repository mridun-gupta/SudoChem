function result = control_logic(modelInput,request,options)
%CONTROL_LOGIC Provide SI-based DB-059 power-shortfall screening arithmetic.
% This is not an electrolyser dynamic, H2-buffer or synthesis-loop simulation.
narginchk(3,3);
material=energy008.get_option(request,'material_result',struct());
if ~isfield(material,'value') || ~isfield(material.value,'SI_flows')
    msg='DB-059 screening requires the SI reference hydrogen molar flow.';
    result=energy008.make_result('control_logic','BLOCKED',struct('blockers',{{msg}}),'N/A',modelInput,{msg},{},struct(),struct()); return;
end
d=modelInput.disturbance;
if ~strcmp(d.case_id,'DB-059-POWER-SHORTFALL-50PCT-2H')
    msg='The supplied disturbance is not the frozen DB-059 power-shortfall case.';
    result=energy008.make_result('control_logic','BLOCKED',struct('blockers',{{msg}}),'N/A',modelInput,{msg},{},struct(),struct()); return;
end
if ~isfield(d,'units') || ~isfield(d.units,'available_power_fraction') || ...
        ~strcmp(char(d.units.available_power_fraction),'fraction') || ~isfield(d.units,'duration_h') || ...
        ~strcmp(char(d.units.duration_h),'h') || ...
        ~isnumeric(d.available_power_fraction) || ~isscalar(d.available_power_fraction) || ...
        ~isfinite(d.available_power_fraction) || d.available_power_fraction<0 || d.available_power_fraction>1 || ...
        ~isnumeric(d.duration_h) || ~isscalar(d.duration_h) || ~isfinite(d.duration_h) || d.duration_h<=0 || ...
        ~isfield(d,'source_id') || isempty(d.source_id)
    msg='DB-059 requires a sourced available-power fraction in [0,1], positive finite duration_h and source_id.';
    result=energy008.make_result('control_logic','FAILED',struct('input_record',d),'N/A',modelInput,{}, {msg},struct(),struct());
    result.diagnostics=energy008.diagnostic('DB059-INPUT-INVALID','ERROR','control_logic',msg,struct(),{}, ...
        'Correct the explicit disturbance record; no negative or non-finite duration/output assumptions are accepted.'); return;
end
% Find source-backed H2 MW and calculate mass rate in kg/s.
p=modelInput.properties.components; iH=find(strcmp({p.formula},'H2'),1);
if isempty(iH) || ~isfinite(p(iH).molecular_weight_kg_kmol) || p(iH).molecular_weight_kg_kmol<=0
    msg='A source-backed H2 molecular weight in the property register is required for DB-059.';
    result=energy008.make_result('control_logic','BLOCKED',struct('blockers',{{msg}}),'N/A',modelInput,{msg},{},struct(),struct()); return;
end
MW_H2_kg_mol=p(iH).molecular_weight_kg_kmol/1000;
H2_mol_s=material.value.SI_flows.molar_flows_mol_s.H2;
H2_kg_s=H2_mol_s*MW_H2_kg_mol;
shortfallFraction=1-d.available_power_fraction;
duration_s=d.duration_h*3600;
deficit_kg=H2_kg_s*shortfallFraction*duration_s;
values=struct('disturbance_id',d.case_id,'available_power_fraction',d.available_power_fraction, ...
    'duration_s',duration_s,'nominal_h2_demand_kg_s',H2_kg_s, ...
    'nominal_h2_demand_kg_h',H2_kg_s*3600, ...
    'assumed_h2_output_fraction',d.available_power_fraction, ...
    'screening_h2_deficit_kg',deficit_kg,'buffer_size_kg',[], ...
    'status','SCREENING_ONLY','limitations',{d.limitations});
warnings=[d.limitations(:)'; {'DB-059 deficit is a stoichiometric linear-scaling arithmetic result, not an H2 buffer size, dynamic trajectory or trip setpoint.'}];
result=energy008.make_result('control_logic','SCREENING_ONLY',values,struct('internal_flow','kg/s','display_flow','kg/h','deficit','kg/event'),modelInput,warnings,{}, ...
    struct('H2_deficit_kg',deficit_kg),struct('source_ids',{{d.source_id,'DB-059',p(iH).source_id}}));
end
