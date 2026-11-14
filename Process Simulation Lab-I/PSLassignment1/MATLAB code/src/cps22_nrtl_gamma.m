function [gamma, lnGamma, detail] = cps22_nrtl_gamma(x, T_K, cfg)
% Binary/multicomponent NRTL activity coefficients with tau_ij=a_ij+b_ij/T.
% Parameter convention, source and high-temperature limitation are stored in JSON.
x = x(:);
n = numel(cfg.components);
if numel(x) ~= n || any(~isfinite(x)) || any(x < 0) || abs(sum(x)-1) > 1e-8
    error('CPS22:InvalidLiquidComposition', 'Liquid composition must be finite, nonnegative and normalized.');
end
if any(x == 0)
    % The standard equation permits boundary compositions; tiny positive floor is
    % used only in logarithm/denominator protection, without renormalizing input.
    xEval = max(x, 1e-14); xEval = xEval / sum(xEval);
else
    xEval = x;
end
nrtl = cfg.model.nrtl;
tau = nrtl.a_ij + nrtl.b_ij_K ./ T_K;
G = exp(-nrtl.alpha_ij .* tau);
lnGamma = zeros(n,1);
for i = 1:n
    term1 = 0; term2 = 0;
    den_i = sum(xEval .* G(:,i));
    for j = 1:n
        term1 = term1 + xEval(j) * tau(j,i) * G(j,i) / den_i;
        den_j = sum(xEval .* G(:,j));
        weighted_tau_j = sum(xEval .* tau(:,j) .* G(:,j)) / den_j;
        term2 = term2 + (xEval(j) * G(i,j) / den_j) * (tau(i,j) - weighted_tau_j);
    end
    lnGamma(i) = term1 + term2;
end
gamma = exp(lnGamma);
if any(~isfinite(gamma)) || any(gamma <= 0)
    error('CPS22:InvalidActivityCoefficient', 'NRTL returned nonpositive or nonfinite activity coefficient.');
end
detail = struct('tau',tau,'G',G,'parameter_status',nrtl.status);
end
