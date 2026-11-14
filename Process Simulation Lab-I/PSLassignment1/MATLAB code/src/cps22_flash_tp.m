function result = cps22_flash_tp(T_K, P_Pa, z, cfg)
% Diagnostic isothermal TP flash solver for the candidate NRTL-SRK gamma-phi model.
% Uses multi-start fminsearch on logistic-transformed [x_ethanol,y_ethanol,beta].
% No result is called an accepted engineering prediction unless parameters and
% model acceptance have separately been established. Phase stability is not solved.
z=z(:); result=struct('status','NOT_RUN','model_acceptance','NOT_ACCEPTED_PARAMETER_SET', ...
    'solver_exit_flag',false,'x',[NaN;NaN],'y',[NaN;NaN],'beta',NaN, ...
    'residuals',NaN(3,1),'log_fugacity_residuals',[NaN;NaN], ...
    'max_abs_log_fugacity_residual',NaN,'abs_ethanol_balance_residual',NaN, ...
    'objective',NaN,'iterations',0,'function_evaluations',0,'warnings',strings(0,1),'message','');
if numel(z)~=2 || any(z<0) || any(z>1) || abs(sum(z)-1)>1e-8
    result.status='INVALID_INPUT'; result.message='z must be a normalized binary composition.'; return
end
try
    vcfg=cfg; vcfg.conditions.temperature_K=T_K; vcfg.conditions.pressure_Pa=P_Pa; v=cps22_validate_config(vcfg);
    if ~v.valid
        result.status='INVALID_INPUT'; result.message=strjoin(v.errors,' '); return
    end
catch ME
    result.status='INVALID_INPUT'; result.message=ME.message; return
end
% Multi-start initial estimates are heuristics, not prescribed phase compositions.
initial=[0.20 0.50 0.50; 0.35 0.60 0.65; 0.45 0.70 0.35; 0.10 0.80 0.80];
opts=optimset('Display','off','MaxIter',cfg.solver.max_iterations_per_start, ...
    'MaxFunEvals',cfg.solver.max_function_evaluations_per_start,'TolX',1e-8,'TolFun',1e-12);
bestF=Inf; bestU=[]; bestExit=-1; bestOutput=struct('iterations',0,'funcCount',0);
for k=1:size(initial,1)
    u0=log(initial(k,:)./(1-initial(k,:)));
    try
        [u,fval,exitflag,output]=fminsearch(@(q) objective(q,T_K,P_Pa,z,cfg),u0,opts);
        if isfinite(fval) && fval<bestF
            bestF=fval; bestU=u; bestExit=exitflag; bestOutput=output;
        end
    catch ME
        result.warnings(end+1)=string(ME.message);
    end
end
if isempty(bestU) || bestF >= 1e11
    result.status='THERMODYNAMIC_EVALUATION_FAILED'; result.message='No start produced a valid thermodynamic residual evaluation.'; return
end
try
    [res,x1,y1,beta,detail]=evaluate(bestU,T_K,P_Pa,z,cfg);
catch ME
    result.status='THERMODYNAMIC_EVALUATION_FAILED'; result.message=ME.message; return
end
result.x=[x1;1-x1]; result.y=[y1;1-y1]; result.beta=beta;
result.residuals=res; result.log_fugacity_residuals=res(1:2);
result.max_abs_log_fugacity_residual=max(abs(res(1:2)));
result.abs_ethanol_balance_residual=abs(res(3)); result.objective=bestF;
result.solver_exit_flag=bestExit>0; result.iterations=bestOutput.iterations;
result.function_evaluations=bestOutput.funcCount; result.thermodynamics=detail;
if result.max_abs_log_fugacity_residual <= cfg.solver.fugacity_tolerance && ...
        result.abs_ethanol_balance_residual <= cfg.solver.material_tolerance && ...
        beta > cfg.solver.minimum_phase_fraction && beta < 1-cfg.solver.minimum_phase_fraction
    result.status='NUMERICAL_RESIDUALS_PASS_STABILITY_NOT_CHECKED';
    result.message='Residual tests pass, but global phase stability and parameter validation are not established.';
elseif beta <= cfg.solver.minimum_phase_fraction || beta >= 1-cfg.solver.minimum_phase_fraction
    result.status='BOUNDARY_OR_SINGLE_PHASE_UNRESOLVED';
    result.message='Optimizer approached a phase-fraction boundary; no single-phase stability conclusion is implied.';
else
    result.status='NONCONVERGED_RESIDUALS_FAIL';
    result.message='Solver exit status is insufficient: residual acceptance criteria are not satisfied.';
end
if ~cfg.model.parameters_accepted
    result.warnings(end+1)="Candidate NRTL parameters and SRK kij are not accepted for predictive use.";
end
result.warnings(end+1)="Global phase-stability testing is not implemented; do not interpret this result as a validated flash prediction.";
end

function f=objective(u,T,P,z,cfg)
try
    r=evaluate(u,T,P,z,cfg);
    if any(~isfinite(r)), f=1e12; else, f=sum(r(:).^2); end
catch
    f=1e12 + 1e-6*sum(min(abs(u(:)),100).^2);
end
end

function [r,x1,y1,beta,detail]=evaluate(u,T,P,z,cfg)
sig=@(v) 1./(1+exp(-max(-25,min(25,v(:)))));
p=sig(u); x1=p(1); y1=p(2); beta=p(3);
thermo=cps22_gamma_phi(T,P,[x1;1-x1],[y1;1-y1],cfg);
mb=z(1)-(1-beta)*x1-beta*y1;
r=[thermo.log_fugacity_residual(:); mb];
if nargout>4, detail=thermo; end
end
