function P_Pa=cps22_psat_nist(component_index,T_K)
% NIST SRD 69 Antoine expressions, pressure output Pa.
% component_index=1 ethanol, 2 water. Returns NaN outside source range.
if component_index==1
    A=4.92531; B=1432.526; C=-61.819; Tmin=364.8; Tmax=513.91;
elseif component_index==2
    A=3.55959; B=643.748; C=-198.043; Tmin=379.0; Tmax=573.0;
else, error('CPS22:UnknownComponent','Index must be 1 ethanol or 2 water.'); end
if T_K<Tmin||T_K>Tmax, P_Pa=NaN; return; end
P_Pa=10^(A-B/(T_K+C))*1e5;
end
