function Psat_Pa = cps22_antoine_psat(T_K, cfg) %#ok<INUSD>
% CPS22_ANTOINE_PSAT Piecewise NIST Chemistry WebBook SRD 69 Antoine data.
% Convention: log10(Psat/bar) = A - B/(T/K + C/K); output Pa.
% Correlations are selected only inside their published temperature ranges.
% This is pure-component saturation pressure, not mixture VLE validation.
if ~isscalar(T_K) || ~isfinite(T_K) || T_K <= 0
    error('CPS22:InvalidTemperature','T must be a finite positive scalar in K.');
end
% Columns: Tmin_K, Tmax_K, A, B_K, C_K. Ethanol NIST WebBook.
EtOH = [273.00 351.70 5.37229 1670.409 -40.191; ...
        292.77 366.63 5.24677 1598.673 -46.424; ...
        364.80 513.91 4.92531 1432.526 -61.819];
% Water NIST WebBook SRD 69.
H2O = [273 303 5.40221 1838.675 -31.737; ...
       304 333 5.20389 1733.926 -39.485; ...
       334 363 5.07680 1659.793 -45.854; ...
       344 373 5.08354 1663.125 -45.622; ...
       379 573 3.55959 643.748 -198.043];
Psat_Pa = nan(2,1);
Psat_Pa(1) = selectAntoine(EtOH,T_K,'ethanol');
Psat_Pa(2) = selectAntoine(H2O,T_K,'water');
end
function P = selectAntoine(tbl,T,name)
valid=find(T>=tbl(:,1) & T<=tbl(:,2));
if isempty(valid)
    ranges=sprintf('[%.2f, %.2f] K; ',tbl(:,1:2)');
    error('CPS22:AntoineOutOfRange','No NIST Antoine segment for %s at %.4f K. Published segments: %s',name,T,ranges);
end
% Choose the narrowest valid segment when literature ranges overlap.
width=tbl(valid,2)-tbl(valid,1); [~,j]=min(width); q=tbl(valid(j),:);
pbar=10^(q(3)-q(4)/(T+q(5))); P=pbar*1e5;
if ~isfinite(P)||P<=0, error('CPS22:InvalidPsat','NIST Antoine evaluation returned nonphysical pressure.'); end
end
