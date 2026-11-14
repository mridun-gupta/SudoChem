function result = reactor_calculation(modelInput,request,options)
%REACTOR_CALCULATION Enforce the source/catalyst/kinetic gate before any PFR run.
% The generic pfr_integrator is available separately; no CZA kinetic constants,
% catalyst formulation or reactor hardware are present in DATA-0.1.0.
narginchk(3,3); %#ok<NASGU>
kinetic=energy008.get_option(modelInput.properties,'kinetic_model',struct('status','BLOCKED'));
if ~isfield(kinetic,'status') || ~strcmp(char(kinetic.status),'AVAILABLE')
    reason='R-301 PFR prediction is blocked: no source-matched kinetic parameter set, approved catalyst formulation, pressure/temperature validity validation, or reactor heat-transfer/hydraulic model is supplied.';
    values=struct('equipment_id','R-301','model_class','1-D pseudo-homogeneous non-isothermal PFR', ...
        'status','BLOCKED','outlet_state',[],'conversion',[],'catalyst_mass_kg',[], ...
        'kinetic_model_status',energy008.get_option(kinetic,'status','BLOCKED'), ...
        'blockers',{{reason,'The literature model candidates in Prompt 6 are method-selection records only; parameter values are not imported as a validated rate expression.'}});
    d=energy008.diagnostic('REACTOR-KINETICS-MISSING','WARNING','reactor_calculation',reason, ...
        struct('equipment_id','R-301','model_class',values.model_class),{'ENERGY008-MODEL-0.1.0','ENERGY008-DATA-0.1.0'}, ...
        'Confirm catalyst grade/formulation, obtain exact rate equation and parameter covariance, reproduce source data, and validate the model across the approved operating envelope.');
    result=energy008.make_result('reactor_calculation','BLOCKED',values,'mol/s; K; Pa; kg_cat',modelInput,{reason},{},struct(), ...
        struct('source_ids',{{'ENERGY008_Model_Assumptions_and_Validity.md','ENERGY008_Property_Method_Selection.md'}}));
    result.diagnostics=d; return;
end
% A future kinetic model must be delivered as an explicit source-validated ODE
% callback; the current project data intentionally do not enable this branch.
if ~isfield(request,'pfr_request') || ~isstruct(request.pfr_request) || ...
        ~isfield(request.pfr_request,'ode_function') || ~isa(request.pfr_request.ode_function,'function_handle')
    msg='Kinetic gate says AVAILABLE, but no validated pfr_request with an ODE callback was supplied.';
    result=energy008.make_result('reactor_calculation','BLOCKED',struct('blockers',{{msg}}),'N/A',modelInput,{msg},{},struct(),struct()); return;
end
p=pfr_integrator(modelInput,request.pfr_request,options);
values=struct('equipment_id','R-301','model_class','1-D pseudo-homogeneous non-isothermal PFR','integration_result',p.value, ...
    'status',p.status,'kinetic_model_id',energy008.get_option(kinetic,'model_id','UNSPECIFIED'));
result=energy008.make_result('reactor_calculation',p.status,values,'caller-declared; kg_cat coordinate',modelInput,p.warnings,p.errors,p.residuals,p.provenance);
result.diagnostics=p.diagnostics;
end
