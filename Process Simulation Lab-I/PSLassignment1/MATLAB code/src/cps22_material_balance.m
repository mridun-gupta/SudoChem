function out = cps22_material_balance(ref, cfg)
% Calculate total/component flow closure in SI (mol/s) from a reference or solver result.
F=cfg.feed.flow_kmol_h*1000/3600;
out=struct('status','CALCULATED','F_mol_s',F,'L_mol_s',NaN,'V_mol_s',NaN, ...
    'total_closure_mol_s',NaN,'component_closure_mol_s',[NaN;NaN], ...
    'component_relative_closure',[NaN;NaN],'max_abs_component_closure_mol_s',NaN, ...
    'normalized_compositions',false,'source_status',ref.status);
if ~isfield(ref,'beta') || ~isfinite(ref.beta) || ref.beta<0 || ref.beta>1
    out.status='BLOCKED_INVALID_PHASE_SPLIT'; return
end
beta=ref.beta; out.L_mol_s=F*(1-beta); out.V_mol_s=F*beta;
if beta<=1e-12
    x=cfg.feed.z(:); y=[NaN;NaN];
elseif beta>=1-1e-12
    x=[NaN;NaN]; y=cfg.feed.z(:);
else
    x=ref.x(:); y=ref.y(:);
end
if any(~isfinite(x)) || any(~isfinite(y))
    if beta<=1e-12
        compOut=out.L_mol_s*x;
    elseif beta>=1-1e-12
        compOut=out.V_mol_s*y;
    else
        out.status='BLOCKED_MISSING_COMPOSITIONS'; return
    end
    out.component_closure_mol_s=F*cfg.feed.z(:)-compOut;
else
    out.component_closure_mol_s=F*cfg.feed.z(:)-(out.L_mol_s*x+out.V_mol_s*y);
end
out.total_closure_mol_s=F-out.L_mol_s-out.V_mol_s;
den=F*cfg.feed.z(:); rel=NaN(size(den)); safe=abs(den)>1e-12; rel(safe)=out.component_closure_mol_s(safe)./den(safe);
out.component_relative_closure=rel;
out.max_abs_component_closure_mol_s=max(abs(out.component_closure_mol_s));
out.normalized_compositions=abs(sum(cfg.feed.z(:))-1)<=1e-8;
if abs(out.total_closure_mol_s)>1e-9 || out.max_abs_component_closure_mol_s>1e-8
    out.status='CLOSURE_FAILED';
end
end
