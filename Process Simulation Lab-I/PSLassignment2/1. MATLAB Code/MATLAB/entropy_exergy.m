function result = entropy_exergy(modelInput,request,options)
%ENTROPY_EXERGY Enforce sign diagnostics and explicit plant entropy/exergy blockers.
% No stream entropy, S_gen, exergy destruction or plant closure is fabricated.
narginchk(3,3);
if isfield(request,'entropy_generation_kW_K') && ~isempty(request.entropy_generation_kW_K)
    sgen=request.entropy_generation_kW_K;
    if ~isnumeric(sgen) || any(~isfinite(sgen(:)))
        msg='Entropy-generation diagnostic input must be finite numeric data.';
        result=energy008.make_result('entropy_exergy','FAILED',struct(), 'kW/K',modelInput,{}, {msg},struct(),struct()); return;
    end
    if any(sgen(:)<0)
        msg='Negative entropy generation is a diagnostic failure; it must not be clipped to zero.';
        d=energy008.diagnostic('THERMO-NEGATIVE-SGEN','ERROR','entropy_exergy',msg,struct('S_gen_kW_K',sgen),{}, ...
            'Check property reference states, stream directions, heat-transfer sign conventions and boundary completeness.');
        result=energy008.make_result('entropy_exergy','FAILED',struct('supplied_S_gen_kW_K',sgen),'kW/K',modelInput,{msg},{msg},struct(),struct());
        result.diagnostics=d; return;
    end
end
blockers={ ...
 'Plant entropy generation is BLOCKED: validated stream entropies, heat-transfer boundary data and physical stream states are incomplete.'; ...
 'Plant exergy destruction is BLOCKED: stream exergy, chemical exergy and approved dead-state environment are incomplete.'; ...
 'No plant entropy/exergy closure can be calculated from the Prompt 17 ideal reaction-block fixture.'};
values=struct('plant_entropy_generation',struct('status','BLOCKED','value',[],'units','kW/K'), ...
    'plant_exergy_destruction',struct('status','BLOCKED','value',[],'units','kW'), ...
    'entropy_closure',struct('status','BLOCKED','value',[]),'exergy_closure',struct('status','BLOCKED','value',[]));
d=energy008.diagnostic('THERMO-PLANT-BOUNDARY-INCOMPLETE','WARNING','entropy_exergy',strjoin(blockers,' '),struct(), ...
    {'ENERGY008-DATA-0.1.0','ENERGY008-PFD-001','ENERGY-REFERENCE-0.1.0'}, ...
    'Populate validated physical stream states and entropy/exergy property methods, select a reference environment, then independently close the balance.');
result=energy008.make_result('entropy_exergy','BLOCKED',values,struct('entropy','kW/K','exergy','kW'),modelInput,blockers,{},struct(), ...
    struct('source_ids',{{'ENERGY-REFERENCE-0.1.0','ENERGY008-DATA-0.1.0'}}));
result.diagnostics=d;
end
