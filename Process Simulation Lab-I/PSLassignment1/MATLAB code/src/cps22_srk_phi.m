function out = cps22_srk_phi(T_K, P_Pa, composition, cfg, kijOverride)
% Classical SRK EOS, Soave alpha function and vdW one-fluid mixing rules.
% Returns all real cubic roots and selects the largest admissible vapor root Z>B.
if nargin < 5, kijOverride = []; end
composition = composition(:); n = numel(cfg.components);
if numel(composition) ~= n || any(~isfinite(composition)) || any(composition < 0) || abs(sum(composition)-1) > 1e-8
    error('CPS22:InvalidVaporComposition', 'Vapor composition must be finite, nonnegative and normalized.');
end
if P_Pa <= 0 || T_K <= 0 || ~isfinite(P_Pa) || ~isfinite(T_K)
    error('CPS22:InvalidTP', 'SRK requires finite T>0 K and P>0 Pa.');
end
R = cfg.constants.R_J_mol_K;
Tc = [cfg.components.Tc_K].'; Pc = [cfg.components.Pc_Pa].'; omega = [cfg.components.omega].';
m = 0.480 + 1.574.*omega - 0.176.*omega.^2;
alpha = (1 + m.*(1 - sqrt(T_K./Tc))).^2;
ai = 0.42747 .* R.^2 .* Tc.^2 .* alpha ./ Pc;
bi = 0.08664 .* R .* Tc ./ Pc;
if isempty(kijOverride)
    kij = cfg.model.srk.kij_matrix;
else
    if ~isscalar(kijOverride) || ~isfinite(kijOverride)
        error('CPS22:InvalidKijOverride', 'kij override must be a finite scalar.');
    end
    kij = zeros(n); kij(1,2) = kijOverride; kij(2,1) = kijOverride;
end
aij = sqrt(ai * ai.') .* (1-kij);
am = composition.' * aij * composition;
bm = composition.' * bi;
A = am * P_Pa / (R^2 * T_K^2);
B = bm * P_Pa / (R * T_K);
if am <= 0 || bm <= 0 || B <= 0 || ~isfinite(A) || ~isfinite(B)
    error('CPS22:InvalidSRKMixture', 'SRK mixing produced invalid A/B or mixture parameters.');
end
coeff = [1, -1, A-B-B^2, -A*B];
allRoots = roots(coeff);
rootTol = 1e-8 * max(1, max(abs(allRoots)));
realMask = abs(imag(allRoots)) <= rootTol;
realRoots = sort(real(allRoots(realMask)));
eligible = realRoots(realRoots > B + 1e-10);
if isempty(eligible)
    error('CPS22:NoAdmissibleSRKRoot', 'SRK cubic has no admissible real root above B.');
end
Z = eligible(end); % vapor root; liquid phase requires its own phase/stability treatment.
lnPhi = (bi./bm).*(Z-1) - log(Z-B) - (A/B).*(2.*(aij*composition)./am - bi./bm).*log(1+B/Z);
phi = exp(lnPhi);
if any(~isfinite(phi)) || any(phi <= 0)
    error('CPS22:InvalidFugacityCoefficient', 'SRK fugacity coefficient is nonphysical.');
end
out = struct('Z',Z,'A',A,'B',B,'am_Pa_m6_mol2',am,'bm_m3_mol',bm, ...
    'ai',ai,'bi',bi,'aij',aij,'all_roots',allRoots,'real_roots',realRoots, ...
    'lnphi',lnPhi,'phi',phi,'kij_matrix',kij,'root_basis','largest real root with Z>B; vapor calculation only');
end
