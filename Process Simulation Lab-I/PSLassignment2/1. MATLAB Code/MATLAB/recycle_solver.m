function result = recycle_solver(modelInput,request,options)
%RECYCLE_SOLVER Reusable damped fixed-point solver with bounds and diagnostics.
% The current physical S-209 recycle is BLOCKED. A generic callback map can
% be exercised only under solver_scope='SYNTHETIC_UNIT_TEST'; that result is
% a numerical unit test, never plant recycle evidence.
narginchk(3,3); %#ok<NASGU>
physicalGate='Physical S-209 recycle closure is blocked until validated PR78 flash properties, stream composition, inert assay, compressor boundary and purge criteria are available.';
if ~isfield(request,'map_function') || ~isa(request.map_function,'function_handle')
    value=struct('stream_id','S-209','physical_recycle_value',[], ...
        'status','BLOCKED_NOT_COMPUTED','reason',physicalGate,'iterations',0,'iteration_history',table());
    d=energy008.diagnostic('RECYCLE-PHYSICAL-DATA-MISSING','WARNING','recycle_solver',physicalGate,struct('stream_id','S-209'), ...
        {'ENERGY008-DATA-0.1.0','ENERGY008-PFD-001','S-209','S-207'}, ...
        'Complete the active EOS pair matrix, flash validation, inert assay, loop composition and purge design basis before enabling physical recycle.');
    result=energy008.make_result('recycle_solver','BLOCKED',value,'generic fixed-point state (not process rate)',modelInput,{physicalGate},{},struct(), ...
        struct('source_ids',{{'ENERGY008-NM-001','S-209','S-207'}})); result.diagnostics=d; return;
end
scope=energy008.get_option(request,'solver_scope','');
if ~strcmp(scope,'SYNTHETIC_UNIT_TEST')
    msg='Generic callback solver execution requires solver_scope=SYNTHETIC_UNIT_TEST. Physical process execution is separately gated.';
    result=energy008.make_result('recycle_solver','FAILED',struct(), 'N/A',modelInput,{}, {msg},struct(),struct());
    result.diagnostics=energy008.diagnostic('RECYCLE-SCOPE-INVALID','ERROR','recycle_solver',msg,struct(),{},'Use the generic solver only for an explicitly labelled synthetic unit test.'); return;
end
try
    map=request.map_function;
    x=request.initial_guess(:);
    if ~isnumeric(x) || isempty(x) || any(~isfinite(x)), error('ENERGY008:RecycleInitialGuess','initial_guess must be a nonempty finite numeric vector.'); end
    n=numel(x);
    lower=energy008.get_option(request,'lower_bounds',-inf(n,1)); lower=expandBound(lower,n,'lower_bounds');
    upper=energy008.get_option(request,'upper_bounds', inf(n,1)); upper=expandBound(upper,n,'upper_bounds');
    scale=energy008.get_option(request,'variable_scale',max(abs(x),1)); scale=expandBound(scale,n,'variable_scale');
    if any(lower>upper) || any(scale<=0), error('ENERGY008:RecycleBounds','Bounds must satisfy lower<=upper and scales must be positive.'); end
    if any(x<lower | x>upper), error('ENERGY008:RecycleInitialOutOfBounds','Initial iterate violates declared bounds.'); end
    relaxation=energy008.get_option(request,'relaxation_factor',0.5);
    tolerance=energy008.get_option(request,'tolerance',1e-8);
    maximum=energy008.get_option(request,'maximum_iterations',200);
    if ~isscalar(relaxation)||~isfinite(relaxation)||relaxation<=0||relaxation>1
        error('ENERGY008:RecycleRelaxationInvalid','relaxation_factor must lie in (0,1].');
    end
    if ~isscalar(tolerance)||~isfinite(tolerance)||tolerance<=0
        error('ENERGY008:RecycleToleranceInvalid','tolerance must be positive and finite.');
    end
    if ~isscalar(maximum)||~isfinite(maximum)||maximum<1||maximum~=floor(maximum)
        error('ENERGY008:RecycleIterationLimitInvalid','maximum_iterations must be a positive integer.');
    end
    xHistory=zeros(maximum+1,n); xHistory(1,:)=x'; residualNorm=nan(maximum,1); updateNorm=nan(maximum,1);
    converged=false; finalResidual=inf; failureReason='Maximum iteration count reached without satisfying scaled residual tolerance.';
    for it=1:maximum
        mapped=map(x);
        if ~isnumeric(mapped) || numel(mapped)~=n || any(~isfinite(mapped(:)))
            error('ENERGY008:RecycleMapInvalid','Map callback must return a finite numeric vector matching initial_guess size.');
        end
        mapped=mapped(:);
        if any(mapped<lower | mapped>upper)
            error('ENERGY008:RecycleMappedOutOfBounds','Mapped iterate violates declared lower/upper bounds at iteration %d.',it);
        end
        residual=mapped-x;
        scaledResidual=residual./scale;
        finalResidual=norm(scaledResidual,inf);
        next=x+relaxation*residual;
        scaledUpdate=(next-x)./scale;
        residualNorm(it)=finalResidual; updateNorm(it)=norm(scaledUpdate,inf);
        x=next; xHistory(it+1,:)=x';
        if finalResidual<=tolerance
            converged=true; failureReason=''; break;
        end
    end
    history=table((1:it)',residualNorm(1:it),updateNorm(1:it), ...
        'VariableNames',{'Iteration','Scaled_Residual_Infinity_Norm','Scaled_Update_Infinity_Norm'});
    if converged, status='CALCULATED'; else, status='FAILED'; end
    values=struct('solver_scope','SYNTHETIC_UNIT_TEST','solution',x,'solution_units', ...
        {energy008.get_option(request,'state_units',repmat({'dimensionless'},n,1))}, ...
        'iterations',it,'converged',converged,'scaled_residual_norm',finalResidual, ...
        'tolerance',tolerance,'relaxation_factor',relaxation,'iteration_history',history, ...
        'iterate_history',xHistory(1:it+1,:),'failure_reason',failureReason, ...
        'physical_recycle_status','BLOCKED_NOT_COMPUTED');
    warn={'Synthetic/generic convergence demonstrates solver arithmetic only; it is not evidence that S-209 process recycle converges.'};
    err={}; d=struct([]);
    if ~converged
        err={struct('identifier','ENERGY008:RecycleNotConverged','message',failureReason)};
        d=energy008.diagnostic('RECYCLE-NOT-CONVERGED','ERROR','recycle_solver',failureReason, ...
            struct('iterations',it,'scaled_residual_norm',finalResidual,'tolerance',tolerance),{}, ...
            'Review scaling, relaxation, initialisation and the model map. Do not accept a nonconverged iterate.');
    end
    result=energy008.make_result('recycle_solver',status,values,struct('residual','scaled dimensionless'), ...
        modelInput,warn,err,struct('scaled_residual_norm',finalResidual),struct('source_ids',{{'ENERGY008-NM-001'}}));
    result.diagnostics=d;
catch ME
    err=struct('identifier',ME.identifier,'message',ME.message);
    result=energy008.make_result('recycle_solver','FAILED',struct(), 'N/A',modelInput,{}, {err},struct(),struct());
    result.diagnostics=energy008.diagnostic(ME.identifier,'ERROR','recycle_solver',ME.message,struct(),{}, ...
        'Correct the solver request or map callback. Last accepted iterate is not a process result.');
end
end
function b=expandBound(b,n,name)
if ~isnumeric(b) || isempty(b) || any(~isfinite(b(:)) & ~isinf(b(:)))
    error('ENERGY008:RecycleBoundInvalid','%s must contain finite values or +/-Inf.',name);
end
if isscalar(b), b=repmat(b,n,1); else, b=b(:); end
if numel(b)~=n, error('ENERGY008:RecycleBoundShape','%s must be scalar or match the state vector.',name); end
end
