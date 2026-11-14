function out = cps22_gamma_phi(T_K, P_Pa, x, y, cfg, kijOverride)
% Evaluate high-pressure gamma-phi component fugacity balance diagnostics.
% f_i^V = y_i*phi_i^V*P
% f_i^L = x_i*gamma_i*Psat_i*phi_i^sat*exp[v_i^L(P-Psat_i)/(RT)]
% Liquid molar volume is modified-Rackett approximate; this is a diagnostic model.
if nargin < 6, kijOverride = []; end
x=x(:); y=y(:);
if ~isscalar(T_K) || ~isfinite(T_K) || T_K <= 0 || ...
        ~isscalar(P_Pa) || ~isfinite(P_Pa) || P_Pa <= 0
    error('CPS22:InvalidThermodynamicState', ...
        'Gamma-phi evaluation requires finite scalar T>0 K and P>0 Pa.');
end
if numel(x)~=2 || numel(y)~=2 || any(~isfinite(x)) || any(~isfinite(y)) || ...
        any(x<0) || any(x>1) || any(y<0) || any(y>1) || ...
        abs(sum(x)-1)>1e-8 || abs(sum(y)-1)>1e-8
    error('CPS22:InvalidPhaseComposition', ...
        'x and y must be finite, bounded, normalized binary compositions.');
end
R=cfg.constants.R_J_mol_K;
Psat = cps22_antoine_psat(T_K,cfg);
[gamma,lnGamma,nrtlDetail] = cps22_nrtl_gamma(x,T_K,cfg);
vL = cps22_rackett_volume(T_K,cfg);
if isempty(kijOverride)
    vap=cps22_srk_phi(T_K,P_Pa,y,cfg);
else
    vap=cps22_srk_phi(T_K,P_Pa,y,cfg,kijOverride);
end
phiSat=zeros(2,1); satRoots=zeros(2,1);
for i=1:2
    pure=zeros(2,1); pure(i)=1;
    if isempty(kijOverride), sat=cps22_srk_phi(T_K,Psat(i),pure,cfg);
    else, sat=cps22_srk_phi(T_K,Psat(i),pure,cfg,kijOverride); end
    phiSat(i)=sat.phi(i); satRoots(i)=sat.Z;
end
poynting = exp(vL.*(P_Pa-Psat)./(R*T_K));
fV = y .* vap.phi .* P_Pa;
fL = x .* gamma .* Psat .* phiSat .* poynting;
resid = log(fV ./ fL);
out=struct('T_K',T_K,'P_Pa',P_Pa,'x',x,'y',y,'Psat_Pa',Psat, ...
    'gamma',gamma,'lnGamma',lnGamma,'phi_vapor',vap.phi,'Z_vapor',vap.Z, ...
    'phi_saturated_pure',phiSat,'Z_saturated_pure',satRoots,'liquid_molar_volume_m3_mol',vL, ...
    'poynting_factor',poynting,'fugacity_vapor_Pa',fV,'fugacity_liquid_Pa',fL, ...
    'log_fugacity_residual',resid,'nrtl_detail',nrtlDetail,'srk_detail',vap, ...
    'reference_state','gamma-phi with pure saturated-vapor phi and liquid Poynting factor');
end
