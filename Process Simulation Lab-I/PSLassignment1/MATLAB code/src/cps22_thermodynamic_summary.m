function T = cps22_thermodynamic_summary(ref, cfg)
% Component-wise NRTL/SRK fugacity-property diagnostic evaluated on reference x/y.
% This table is explicitly a residual diagnostic at an empirical tie-line, not a
% target-model prediction. It is useful for regression tests of property modules.
component=string({cfg.components.name}).';
n=numel(cfg.components); x=NaN(n,1); y=x; Psat=x; gamma=x; phiV=x; phiSat=x;
poynting=x; fL=x; fV=x; logResidual=x; vliq=x; Z=NaN;
status=repmat("BLOCKED_NO_REFERENCE_TIELINE",n,1); err="";
if isfield(ref,'status') && strcmp(ref.status,'TWO_PHASE_REFERENCE_INTERPOLATION')
    try
        q=cps22_gamma_phi(ref.T_K,ref.P_Pa,ref.x,ref.y,cfg);
        x=q.x; y=q.y; Psat=q.Psat_Pa; gamma=q.gamma; phiV=q.phi_vapor;
        phiSat=q.phi_saturated_pure; poynting=q.poynting_factor;
        fL=q.fugacity_liquid_Pa; fV=q.fugacity_vapor_Pa;
        logResidual=q.log_fugacity_residual; vliq=q.liquid_molar_volume_m3_mol; Z=q.Z_vapor;
        status=repmat("REFERENCE_TIELINE_FUGACITY_DIAGNOSTIC_NOT_TARGET_PREDICTION",n,1);
    catch ME
        err=string(ME.identifier)+": "+string(ME.message);
        status=repmat("BLOCKED_PROPERTY_EVALUATION_FAILED",n,1);
    end
end
T=table(component,x,y,Psat,gamma,phiV,repmat(Z,n,1),phiSat,vliq,poynting,fL,fV,logResidual,status, ...
    'VariableNames',{'component','x_liquid','y_vapor','Psat_Pa','gamma_NRTL','phi_vapor_SRK', ...
    'Z_vapor_SRK','phi_saturated_pure_SRK','liquid_molar_volume_m3_mol_Rackett','Poynting_factor', ...
    'fugacity_liquid_Pa','fugacity_vapor_Pa','log_fugacity_residual','status'});
if strlength(err)>0
    % Store the exact failure reason in the status field instead of hiding a property failure.
    T.status=repmat("BLOCKED_PROPERTY_EVALUATION_FAILED: "+err,height(T),1);
end
end
