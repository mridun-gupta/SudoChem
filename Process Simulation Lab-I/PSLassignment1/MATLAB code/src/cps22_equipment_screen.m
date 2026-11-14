function out = cps22_equipment_screen(ref, cfg)
% Preliminary Souders-Brown separator screen based on empirical reference split.
% Not a pressure-vessel mechanical design and not an accepted model prediction.
out=struct('status','BLOCKED','basis_status',ref.status,'vapour_volumetric_flow_m3_s',NaN, ...
    'liquid_volumetric_flow_m3_s',NaN,'rho_vapour_kg_m3',NaN,'rho_liquid_kg_m3',NaN, ...
    'allowable_superficial_velocity_m_s',NaN,'gas_area_m2',NaN,'hydraulic_diameter_m',NaN, ...
    'liquid_hold_up_m3',NaN,'approx_liquid_depth_m',NaN,'K_s_m_s',cfg.equipment.souders_brown_K_m_s, ...
    'residence_time_s',cfg.equipment.residence_time_s, ...
    'warning','Screening only; K-factor, densities, geometry, nozzle design and code design need independent verification.');
if ~strcmp(ref.status,'TWO_PHASE_REFERENCE_INTERPOLATION')
    out.status='BLOCKED_NOT_TWO_PHASE_REFERENCE'; return
end
T=ref.T_K; P=ref.P_Pa; R=cfg.constants.R_J_mol_K;
try
    y=ref.y(:); x=ref.x(:); nV=ref.V_kmol_h*1000/3600; nL=ref.L_kmol_h*1000/3600;
    eos=cps22_srk_phi(T,P,y,cfg); Z=eos.Z;
    MW=[cfg.components.MW_kg_mol].'; MWvap=y.'*MW; MWliq=x.'*MW;
    qV=nV*Z*R*T/P;
    vPure=cps22_rackett_volume(T,cfg); vMix=x.'*vPure;
    rhoV=P*MWvap/(Z*R*T); rhoL=MWliq/vMix; qL=nL*vMix;
    if rhoL<=rhoV || rhoV<=0 || qV<0 || qL<0
        out.status='BLOCKED_NONPHYSICAL_SCREENING_PROPERTIES'; return
    end
    vAllow=cfg.equipment.souders_brown_K_m_s*sqrt((rhoL-rhoV)/rhoV);
    A=qV/vAllow; D=sqrt(4*A/pi); holdUp=qL*cfg.equipment.residence_time_s;
    h=holdUp/A;
    out.status='SCREENING_ONLY'; out.vapour_volumetric_flow_m3_s=qV;
    out.liquid_volumetric_flow_m3_s=qL; out.rho_vapour_kg_m3=rhoV; out.rho_liquid_kg_m3=rhoL;
    out.allowable_superficial_velocity_m_s=vAllow; out.gas_area_m2=A; out.hydraulic_diameter_m=D;
    out.liquid_hold_up_m3=holdUp; out.approx_liquid_depth_m=h;
catch ME
    out.status='BLOCKED_PROPERTY_CALCULATION'; out.warning=string(ME.message)+" "+out.warning;
end
end
