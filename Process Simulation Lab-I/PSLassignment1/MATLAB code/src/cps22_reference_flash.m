function result = cps22_reference_flash(cfg, dataFile)
% CPS22_REFERENCE_FLASH Empirical reference interpolation; never an NRTL-SRK prediction.
if nargin<2 || isempty(dataFile)
    if isfield(cfg,'paths') && isfield(cfg.paths,'reference_data_abs')
        dataFile=cfg.paths.reference_data_abs;
    else
        error('CPS22:MissingReferenceDataPath','Use the canonical project-configured reference data path.');
    end
end
D=cps22_read_reference_data(dataFile);
P_kPa=cfg.conditions.pressure_Pa/1000;
mask=abs(D.pressure_kPa-P_kPa)<max(1e-6,1e-9*abs(P_kPa)) & strcmpi(strtrim(D.data_type),"experimental_measurement");
sub=D(mask,:);
if height(sub)<3
    available=unique(D.pressure_kPa);
    error('CPS22:ReferencePressureUnavailable', ...
        'No adequate experimental rows at %.6g kPa. Isobars in canonical dataset: %s kPa.',P_kPa,strjoin(string(available.'),', '));
end
z=cfg.feed.z(1); T=cfg.conditions.temperature_K;
Tb=boundaryTemperature(sub.x_ethanol_mole_fraction,sub.temperature_K,z);
Td=boundaryTemperature(sub.y_ethanol_mole_fraction,sub.temperature_K,z);
result=struct('method','EXPERIMENTAL_REFERENCE_INTERPOLATION_NOT_NRTL_SRK', ...
    'status','UNSET','T_K',T,'P_Pa',cfg.conditions.pressure_Pa,'P_kPa',P_kPa, ...
    'F_kmol_h',cfg.feed.flow_kmol_h,'z',cfg.feed.z(:),'bubble_temperature_K',Tb,'dew_temperature_K',Td, ...
    'x',[NaN;NaN],'y',[NaN;NaN],'beta',NaN,'L_kmol_h',NaN,'V_kmol_h',NaN, ...
    'warnings',strings(0,1),'data_rows_used',height(sub),'data_file',char(dataFile));
if T < min(sub.temperature_K) || T > max(sub.temperature_K)
    result.status='REFERENCE_INTERPOLATION_OUT_OF_TEMPERATURE_RANGE';
    result.warnings(end+1)="Requested temperature is outside the measured isobar range; no extrapolation performed."; return
end
[x1,y1,okTie]=interpolateTieLineAtT(sub,T,z);
if ~okTie || ~isfinite(x1) || ~isfinite(y1)
    result.status='REFERENCE_INTERPOLATION_FAILED';
    result.warnings(end+1)="No adjacent measured tie-line interval brackets this temperature/composition; no extrapolation performed."; return
end
result.x=[x1;1-x1]; result.y=[y1;1-y1];
lo=min(x1,y1); hi=max(x1,y1);
if abs(y1-x1)<1e-12
    result.status='DEGENERATE_TIE_LINE'; result.warnings(end+1)="Liquid and vapour compositions coincide; lever rule is undefined."; return
elseif z < lo-1e-8 || z > hi+1e-8
    if y1 > x1
        if z < lo, result.status='SINGLE_LIQUID_OUTSIDE_TIE_LINE'; result.beta=0; else, result.status='SINGLE_VAPOUR_OUTSIDE_TIE_LINE'; result.beta=1; end
    else
        if z < lo, result.status='SINGLE_VAPOUR_OUTSIDE_TIE_LINE'; result.beta=1; else, result.status='SINGLE_LIQUID_OUTSIDE_TIE_LINE'; result.beta=0; end
    end
else
    result.status='TWO_PHASE_REFERENCE_INTERPOLATION';
    result.beta=(z-x1)/(y1-x1);
    if result.beta < -1e-8 || result.beta > 1+1e-8
        result.status='REFERENCE_LEVER_RULE_INFEASIBLE'; result.beta=NaN;
        result.warnings(end+1)="Lever-rule phase fraction falls outside [0,1]."; return
    end
    result.beta=max(0,min(1,result.beta));
end
result.L_kmol_h=(1-result.beta)*result.F_kmol_h;
result.V_kmol_h=result.beta*result.F_kmol_h;
result.warnings(end+1)="Empirical interpolation is a reference fixture only; not target-model validation.";
end

function tb=boundaryTemperature(comp,T,z)
% Average repeated composition points before interpolation to avoid duplicate-x warnings.
comp=comp(:); T=T(:); ok=isfinite(comp)&isfinite(T); comp=comp(ok); T=T(ok);
if isempty(comp) || z<min(comp) || z>max(comp), tb=NaN; return; end
[u,~,g]=unique(comp); av=accumarray(g,T,[],@mean);
if numel(u)<2, tb=NaN; else, tb=interp1(u,av,z,'linear',NaN); end
end

function [xBest,yBest,ok]=interpolateTieLineAtT(sub,T,z)
% Interpolate only adjacent measured records. Multiple branches are scored using the feed composition.
Tvals=sub.temperature_K(:); xvals=sub.x_ethanol_mole_fraction(:); yvals=sub.y_ethanol_mole_fraction(:);
candX=[]; candY=[]; score=[]; tolT=1e-9;
for j=1:numel(Tvals)-1
    t1=Tvals(j); t2=Tvals(j+1);
    if abs(t2-t1)<=tolT, continue; end
    if T>=min(t1,t2)-tolT && T<=max(t1,t2)+tolT
        f=(T-t1)/(t2-t1); f=max(0,min(1,f));
        xc=xvals(j)+f*(xvals(j+1)-xvals(j)); yc=yvals(j)+f*(yvals(j+1)-yvals(j));
        if ~isfinite(xc)||~isfinite(yc), continue; end
        lo=min(xc,yc); hi=max(xc,yc);
        if z>=lo-1e-8 && z<=hi+1e-8, sc=1e-6*abs(z-0.5*(xc+yc)); else, sc=min(abs(z-xc),abs(z-yc))+1; end
        candX(end+1,1)=xc; candY(end+1,1)=yc; score(end+1,1)=sc; %#ok<AGROW>
    end
end
if isempty(score), xBest=NaN; yBest=NaN; ok=false; return; end
[~,k]=min(score); xBest=candX(k); yBest=candY(k); ok=true;
end
