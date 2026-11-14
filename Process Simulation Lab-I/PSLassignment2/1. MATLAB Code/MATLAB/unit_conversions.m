function value = unit_conversions(request)
%UNIT_CONVERSIONS Explicit SI-compatible import/export conversions.
% All values are numeric and finite. Conversion names declare both units.
% Supported: kg/day<->kg/s, mol/s<->kmol/day, t/day<->kg/day, kg/day->kg/h,
% kg/h->m3/s, m3/h->m3/s. Unsupported units fail closed.
narginchk(1,1);
if ~isfield(request,'conversion') || ~isfield(request,'value')
    error('ENERGY008:UnitConversionRequest','Request requires conversion and value fields.');
end
x=request.value;
if ~isnumeric(x) || any(~isfinite(x(:)))
    error('ENERGY008:UnitConversionInput','Unit conversion input must be finite numeric data.');
end
switch char(request.conversion)
    case 't_day_to_kg_day'
        value=x*1000;
    case 'kg_day_to_t_day'
        value=x/1000;
    case 'kg_day_to_kg_s'
        value=x/86400;
    case 'kg_s_to_kg_day'
        value=x*86400;
    case 'mol_s_to_kmol_day'
        value=x*86400/1000;
    case 'kmol_day_to_mol_s'
        value=x*1000/86400;
    case 'kg_day_to_kg_h'
        value=x/24;
    case 'kg_h_to_m3_s'
        if ~isfield(request,'density_kg_m3') || ~isscalar(request.density_kg_m3) || ...
                ~isfinite(request.density_kg_m3) || request.density_kg_m3<=0
            error('ENERGY008:DensityRequired','kg/h to m3/s conversion requires positive density_kg_m3.');
        end
        value=x/3600/request.density_kg_m3;
    case 'm3_h_to_m3_s'
        value=x/3600;
    otherwise
        error('ENERGY008:UnitConversionUnsupported','Unsupported conversion: %s',char(request.conversion));
end
end
