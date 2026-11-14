function main_industrial()
% CPS-22 R4 detailed calculation-register workflow. No hand-entered paths.
root=fileparts(mfilename('fullpath'));
addpath(root,'-begin'); addpath(fullfile(root,'src'),'-begin'); cd(root); rehash path;
clear cps22_load_config cps22_read_reference_data cps22_reference_flash
cps22_activate_project(root);
cfg=cps22_load_config(fullfile(root,'data','default_case.json'));
ref=cps22_reference_flash(cfg,cfg.paths.reference_data_abs);
if ~isfinite(ref.beta) || ~all(isfinite(ref.x)) || ~all(isfinite(ref.y))
    error('CPS22:NoReferencePhaseSplit','Reference interpolation returned status %s. See result warning and reference temperature/composition range.',ref.status);
end
T=cfg.conditions.temperature_K; P=cfg.conditions.pressure_Pa; F=cfg.feed.flow_kmol_h; z=cfg.feed.z(:)';
x1=ref.x(1); y1=ref.y(1); beta=ref.beta; L=ref.L_kmol_h; V=ref.V_kmol_h; x=ref.x(:)'; y=ref.y(:)';
R=cfg.constants.R_J_mol_K; MW=[cfg.components.MW_kg_mol];
Ps=[cps22_psat_nist(1,T),cps22_psat_nist(2,T)];
[lnG,gamma]=cps22_nrtl_candidate(x,T,cfg.model.nrtl.a_ij,cfg.model.nrtl.b_ij_K,cfg.model.nrtl.alpha_ij);
srkV=cps22_srk_industrial(y,T,P,cfg.components,cfg.model.srk.kij_matrix(1,2));
srkE=cps22_srk_industrial([1,0],T,Ps(1),cfg.components,0); srkW=cps22_srk_industrial([0,1],T,Ps(2),cfg.components,0);
vLcomp=[7.19087e-5,2.41893e-5]; poy=exp(vLcomp .* (P-Ps) ./ (R*T));
fL=x.*gamma.*Ps.*[srkE.phi(1),srkW.phi(2)].*poy(:)'; fV=y.*srkV.phi*P; residual=log(fV./fL);
feed=F*z; liq=L*x; vap=V*y; massFeed=feed.*(MW*1000); massL=liq.*(MW*1000); massV=vap.*(MW*1000);
outdir=fullfile(root,'results','industrial'); if ~exist(outdir,'dir'),mkdir(outdir);end
base=table(T,P,F,z(1),x1,y1,beta,L,V,lnG(1),lnG(2),gamma(1),gamma(2),srkV.Z,srkV.phi(1),srkV.phi(2),residual(1),residual(2),sum(massFeed),sum(massL),sum(massV),sum(massFeed)-sum(massL)-sum(massV), ...
 'VariableNames',{'T_K','P_Pa','F_kmol_h','z_EtOH','x_EtOH','y_EtOH','beta_reference','L_kmol_h','V_kmol_h','lnGamma_EtOH','lnGamma_Water','gamma_EtOH','gamma_Water','Z_vapour_SRK_diagnostic','phi_EtOH_SRK','phi_Water_SRK','lnFugacityResidual_EtOH','lnFugacityResidual_Water','FeedMass_kg_h','LiquidMass_kg_h','VapourMass_kg_h','MassClosure_kg_h'});
writetable(base,fullfile(outdir,'industrial_base_case.csv'));
manual=cps22_manual_calculation_book(T,P,F,z,x,y,beta,L,V,Ps,gamma,srkV,residual,massFeed,massL,massV);
writetable(manual,fullfile(outdir,'manual_calculation_register.csv'));
fprintf('CPS-22 R4 empirical reference fixture generated. Rows used: %d.\n',ref.data_rows_used);
fprintf('Maximum absolute ln-fugacity residual=%.6g; acceptance criterion=1e-6.\n',max(abs(residual)));
fprintf('This is a diagnostic calculation, not an accepted predictive model. Results: %s\n',outdir);
end
