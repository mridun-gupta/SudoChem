function result = pfr_integrator(modelInput,request,options)
%PFR_INTEGRATOR Adaptive-refinement RK4 integrator in catalyst-mass coordinate.
% ODE callbacks are caller-supplied and must carry their own physical model
% provenance. This generic integrator does not embed or invent kinetics.
narginchk(3,3); %#ok<NASGU>
try
    required={'ode_function','coordinate_span','initial_state'};
    for k=1:numel(required)
        if ~isfield(request,required{k}), error('ENERGY008:PFRRequestMissing','PFR request requires %s.',required{k}); end
    end
    if ~isa(request.ode_function,'function_handle'), error('ENERGY008:PFRODEInvalid','ode_function must be a function handle.'); end
    span=request.coordinate_span(:)'; y0=request.initial_state(:);
    if numel(span)~=2 || any(~isfinite(span)) || span(2)<=span(1) || isempty(y0) || any(~isfinite(y0))
        error('ENERGY008:PFRInitialStateInvalid','coordinate_span must be increasing and initial_state finite.');
    end
    relativeTol=energy008.get_option(request,'relative_tolerance',1e-7);
    absoluteTol=energy008.get_option(request,'absolute_tolerance',1e-9);
    initialSteps=energy008.get_option(request,'initial_step_count',20);
    maxRefine=energy008.get_option(request,'maximum_refinements',8);
    if any([relativeTol absoluteTol]<=0) || any(~isfinite([relativeTol absoluteTol])) || ...
            initialSteps<1 || initialSteps~=floor(initialSteps) || maxRefine<1 || maxRefine~=floor(maxRefine)
        error('ENERGY008:PFRToleranceInvalid','Tolerances must be positive; step/refinement counts positive integers.');
    end
    positiveIdx=energy008.get_option(request,'positive_state_indices',[]);
    if any(positiveIdx<1 | positiveIdx>numel(y0) | positiveIdx~=floor(positiveIdx))
        error('ENERGY008:PFRPositiveIndexInvalid','positive_state_indices must be valid state-vector indices.');
    end
    coarseSteps=initialSteps; historyRows={}; accepted=false; finalError=inf;
    for refinement=1:maxRefine
        [~,coarse]=integrateRK4(request.ode_function,span,y0,coarseSteps);
        fineSteps=2*coarseSteps;
        [xFine,yFine]=integrateRK4(request.ode_function,span,y0,fineSteps);
        scale=absoluteTol+relativeTol.*max(abs(coarse(end,:)),abs(yFine(end,:)));
        finalError=max(abs(yFine(end,:)-coarse(end,:))./scale);
        if ~isempty(positiveIdx) && any(any(yFine(:,positiveIdx)<=0))
            error('ENERGY008:PFRNonpositiveState','A positive-state variable became nonpositive at refinement %d.',refinement);
        end
        historyRows(end+1,:)={refinement,coarseSteps,fineSteps,finalError}; %#ok<AGROW>
        if finalError<=1, accepted=true; break; end
        coarseSteps=fineSteps;
    end
    hist=cell2table(historyRows,'VariableNames',{'Refinement','Coarse_Steps','Fine_Steps','Scaled_Step_Doubling_Error'});
    if accepted, status='CALCULATED'; reason=''; else, status='FAILED'; reason='Maximum step refinements reached before step-doubling error met tolerance.'; end
    values=struct('coordinate',xFine(:),'state',yFine,'final_state',yFine(end,:), ...
        'steps',fineSteps,'refinement_history',hist,'scaled_error_estimate',finalError, ...
        'tolerances',struct('relative',relativeTol,'absolute',absoluteTol), ...
        'coordinate_units',energy008.get_option(request,'coordinate_units','kg_cat'), ...
        'state_units',{energy008.cellstr_safe(energy008.get_option(request,'state_units',repmat({'unspecified'},numel(y0),1)))}, ...
        'status',status,'failure_reason',reason,'integration_method','classical RK4 with step-doubling refinement');
    err={}; d=struct([]); warn={'Integrator result is only as valid as the caller-supplied ODE and its source-validated kinetic/thermodynamic model.'};
    if ~accepted
        err={struct('identifier','ENERGY008:PFRRefinementFailed','message',reason)};
        d=energy008.diagnostic('PFR-REFINEMENT-FAILED','ERROR','pfr_integrator',reason,struct('scaled_error_estimate',finalError),{}, ...
            'Increase maximum refinements or review stiffness/model validity; do not label the final iterate converged.');
    end
    result=energy008.make_result('pfr_integrator',status,values,struct('coordinate',values.coordinate_units,'state','caller-declared'), ...
        modelInput,warn,err,struct('scaled_step_doubling_error',finalError), ...
        struct('source_ids',{energy008.cellstr_safe(energy008.get_option(request,'source_ids',{}))}));
    result.diagnostics=d;
catch ME
    err=struct('identifier',ME.identifier,'message',ME.message);
    result=energy008.make_result('pfr_integrator','FAILED',struct(),'N/A',modelInput,{}, {err},struct(),struct());
    result.diagnostics=energy008.diagnostic(ME.identifier,'ERROR','pfr_integrator',ME.message,struct(),{}, ...
        'Correct the state vector, coordinate span, units, or ODE callback.');
end
end
function [x,Y]=integrateRK4(fun,span,y0,n)
x=linspace(span(1),span(2),n+1)'; h=(span(2)-span(1))/n;
Y=zeros(n+1,numel(y0)); Y(1,:)=y0(:)';
for k=1:n
    y=Y(k,:)'; xk=x(k);
    k1=derivative(fun,xk,y); k2=derivative(fun,xk+h/2,y+h*k1/2);
    k3=derivative(fun,xk+h/2,y+h*k2/2); k4=derivative(fun,xk+h,y+h*k3);
    yn=y+(h/6)*(k1+2*k2+2*k3+k4);
    if any(~isfinite(yn)), error('ENERGY008:PFRNonfiniteState','PFR state became non-finite at coordinate %g.',x(k+1)); end
    Y(k+1,:)=yn(:)';
end
end
function dy=derivative(fun,x,y)
dy=fun(x,y);
if ~isnumeric(dy)||numel(dy)~=numel(y)||any(~isfinite(dy(:)))
    error('ENERGY008:PFRODEOutputInvalid','ODE callback must return a finite numeric derivative vector matching the state vector.');
end
dy=dy(:);
end
