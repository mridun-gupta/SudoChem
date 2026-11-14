function vL_m3_mol = cps22_rackett_volume(T_K, cfg)
% Modified-Rackett approximation used only for Poynting and screening duties.
% It is not a replacement for source-verified density data.
Tc = [cfg.components.Tc_K].'; Pc = [cfg.components.Pc_Pa].'; omega = [cfg.components.omega].';
if any(T_K >= Tc)
    error('CPS22:RackettOutOfRange', 'Rackett liquid-volume approximation requires T below each component Tc.');
end
Zra = 0.29056 - 0.08775 .* omega;
Tr = T_K ./ Tc;
vL_m3_mol = cfg.constants.R_J_mol_K .* Tc ./ Pc .* Zra .^ (1 + (1 - Tr).^(2/7));
if any(~isfinite(vL_m3_mol)) || any(vL_m3_mol <= 0)
    error('CPS22:InvalidLiquidVolume', 'Liquid-volume approximation returned nonphysical value.');
end
end
