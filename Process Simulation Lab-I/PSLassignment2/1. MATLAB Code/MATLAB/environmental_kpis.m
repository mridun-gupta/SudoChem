function result = environmental_kpis(modelInput,request,options)
%ENVIRONMENTAL_KPIS Calculate traceable plant-gate KPIs when measured data exist.
% Meter/register inputs are imported in declared reporting units, converted to
% SI rates (W, kg/s, m3/s), and only then reduced to reported intensity KPIs.
% No emission factor, renewable share, source credit or wastewater quality is defaulted.
narginchk(3,3); %#ok<NASGU>
inputs=energy008.get_option(request,'measurements',modelInput.environmental_basis.inputs);
expectedUnits=modelInput.environmental_basis.required_units;
sourceFields=energy008.cellstr_safe(modelInput.environmental_basis.required_source_map_fields);
sourceMap=energy008.get_option(inputs,'source_map',struct());
unitMap=energy008.get_option(inputs,'units',struct());
if ~isstruct(sourceMap), sourceMap=struct(); end
if ~isstruct(unitMap), unitMap=struct(); end
sourceIds={};
% Collect available IDs for audit output. Missing source IDs are checked per KPI,
% so a complete water meter record does not depend on unrelated GHG evidence.
for k=1:numel(sourceFields)
    f=sourceFields{k};
    if isfield(sourceMap,f) && ~isempty(sourceMap.(f)) && ...
            (ischar(sourceMap.(f)) || (isstring(sourceMap.(f))&&isscalar(sourceMap.(f)))) && ~isempty(strtrim(char(sourceMap.(f))))
        sourceIds{end+1}=char(sourceMap.(f)); %#ok<AGROW>
    end
end
prov=char(energy008.get_option(inputs,'provenance_class',''));
commonMeta={};
if isempty(prov), commonMeta{end+1}='provenance_class'; end
periodStart=char(energy008.get_option(inputs,'measurement_period_start',''));
periodEnd=char(energy008.get_option(inputs,'measurement_period_end',''));
if isempty(periodStart), commonMeta{end+1}='measurement_period_start'; end
if isempty(periodEnd), commonMeta{end+1}='measurement_period_end'; end
if (~isempty(periodStart) && ~validISODate(periodStart)) || (~isempty(periodEnd) && ~validISODate(periodEnd))
    msg='Measurement period dates must be valid calendar dates in ISO yyyy-mm-dd form.';
    result=energy008.make_result('environmental_kpis','FAILED',struct(), 'date interval',modelInput,{}, {msg},struct(),struct('source_ids',{sourceIds}));
    result.diagnostics=energy008.diagnostic('ENV-PERIOD-FORMAT-INVALID','ERROR','environmental_kpis',msg, ...
        struct('measurement_period_start',periodStart,'measurement_period_end',periodEnd),sourceIds,'Correct the measurement period dates.'); return;
end
if ~isempty(periodStart) && ~isempty(periodEnd) && datenum(periodEnd,'yyyy-mm-dd')<datenum(periodStart,'yyyy-mm-dd')
    msg='Measurement period end precedes start.';
    result=energy008.make_result('environmental_kpis','FAILED',struct(), 'date interval',modelInput,{}, {msg},struct(),struct('source_ids',{sourceIds}));
    result.diagnostics=energy008.diagnostic('ENV-PERIOD-ORDER-INVALID','ERROR','environmental_kpis',msg, ...
        struct('measurement_period_start',periodStart,'measurement_period_end',periodEnd),sourceIds,'Correct the measurement period ordering.'); return;
end

% Unit mismatches are FAILED, not silently converted or treated as missing.
unitErrors={}; expectedNames=fieldnames(expectedUnits);
for k=1:numel(expectedNames)
    f=expectedNames{k};
    if isfield(inputs,f) && ~isempty(inputs.(f))
        if ~isfield(unitMap,f) || ~strcmp(char(unitMap.(f)),char(expectedUnits.(f)))
            unitErrors{end+1}=sprintf('%s must declare unit exactly "%s".',f,expectedUnits.(f)); %#ok<AGROW>
        end
    end
end
if ~isempty(unitErrors)
    msg=strjoin(unitErrors,' ');
    result=energy008.make_result('environmental_kpis','FAILED',struct('unit_errors',{unitErrors}),'N/A',modelInput,{}, {msg},struct(),struct('source_ids',{sourceIds}));
    result.diagnostics=energy008.diagnostic('ENV-UNIT-MISMATCH','ERROR','environmental_kpis',msg,struct(),sourceIds,'Correct the measurement unit metadata or provide an explicitly supported conversion at import.'); return;
end

metrics=struct('ghg_intensity',struct('status','BLOCKED','value',[],'units','kg CO2e/kg MeOH'), ...
    'net_water_intensity',struct('status','BLOCKED','value',[],'units','m3/t MeOH'), ...
    'solid_waste_intensity',struct('status','BLOCKED','value',[],'units','kg/t MeOH'));
blockers={}; warnings={};
ghgFields={'measured_electricity_kWh_day','electricity_emission_factor_kgCO2e_per_kWh', ...
    'direct_non_biogenic_GHG_kgCO2e_day','methanol_saleable_kg_day'};
ghgSourceFields={'measured_electricity_kWh_day','electricity_emission_factor_kgCO2e_per_kWh', ...
    'direct_non_biogenic_GHG_kgCO2e_day','methanol_saleable_kg_day'};
ghgMissing=[missingNumeric(inputs,ghgFields),commonMeta,missingSourceMap(sourceMap,ghgSourceFields)];
if isempty(ghgMissing)
    if any([inputs.measured_electricity_kWh_day,inputs.electricity_emission_factor_kgCO2e_per_kWh, ...
            inputs.direct_non_biogenic_GHG_kgCO2e_day]<0) || inputs.methanol_saleable_kg_day<=0
        msg='Environmental energy, emissions and product rates must be nonnegative with positive saleable methanol.';
        result=energy008.make_result('environmental_kpis','FAILED',struct(), 'declared environmental units',modelInput,{}, {msg},struct(),struct('source_ids',{sourceIds}));
        result.diagnostics=energy008.diagnostic('ENV-INPUT-INVALID','ERROR','environmental_kpis',msg,struct(),sourceIds,'Correct negative or infeasible meter inputs.'); return;
    end
    % kWh/day -> W; kg/day -> kg/s. GHG intensity is a ratio of SI mass rates.
    P_electric_W=inputs.measured_electricity_kWh_day*3.6e6/86400;
    electricityGHG_kg_s=(P_electric_W/3.6e6)*inputs.electricity_emission_factor_kgCO2e_per_kWh;
    directGHG_kg_s=inputs.direct_non_biogenic_GHG_kgCO2e_day/86400;
    meoh_kg_s=inputs.methanol_saleable_kg_day/86400;
    totalGHG_kg_s=electricityGHG_kg_s+directGHG_kg_s;
    ghgIntensity=totalGHG_kg_s/meoh_kg_s;
    electricityGHG_kg_day=electricityGHG_kg_s*86400;
    totalGHG_kg_day=totalGHG_kg_s*86400;
    metrics.ghg_intensity=struct('status','SCREENING_ONLY','value',ghgIntensity,'units','kg CO2e/kg MeOH', ...
        'electricity_component_kgCO2e_day',electricityGHG_kg_day, ...
        'direct_non_biogenic_component_kgCO2e_day',directGHG_kg_s*86400, ...
        'total_non_biogenic_GHG_kgCO2e_day',totalGHG_kg_day, ...
        'internal_power_W',P_electric_W,'internal_GHG_rate_kg_s',totalGHG_kg_s, ...
        'internal_methanol_rate_kg_s',meoh_kg_s, ...
        'equation','[(electricity_W/3.6e6)*EF + direct_GHG_kg_s]/saleable_MeOH_kg_s');
else
    blockers{end+1}=['GHG intensity blocked; missing/invalid input or traceability metadata: ' strjoin(ghgMissing,', ')]; %#ok<AGROW>
end

% Water is a separate gate and may be reported if its two meters are complete.
waterFields={'water_withdrawal_m3_day','water_discharge_m3_day','methanol_saleable_kg_day'};
waterSourceFields={'water_withdrawal_m3_day','water_discharge_m3_day','methanol_saleable_kg_day'};
waterMissing=[missingNumeric(inputs,waterFields),commonMeta,missingSourceMap(sourceMap,waterSourceFields)];
if isempty(waterMissing)
    if inputs.water_withdrawal_m3_day<0 || inputs.water_discharge_m3_day<0 || inputs.methanol_saleable_kg_day<=0
        msg='Water rates must be nonnegative and methanol product rate must be positive.';
        result=energy008.make_result('environmental_kpis','FAILED',struct(), 'm3/t MeOH',modelInput,{}, {msg},struct(),struct('source_ids',{sourceIds}));
        result.diagnostics=energy008.diagnostic('ENV-WATER-NEGATIVE','ERROR','environmental_kpis',msg,struct(),sourceIds,'Correct water meter inputs.'); return;
    end
    withdrawal_m3_s=inputs.water_withdrawal_m3_day/86400;
    discharge_m3_s=inputs.water_discharge_m3_day/86400;
    meoh_t_s=(inputs.methanol_saleable_kg_day/86400)/1000;
    netWater_m3_s=withdrawal_m3_s-discharge_m3_s;
    if netWater_m3_s<0
        msg='Water discharge cannot exceed withdrawal for this net-withdrawal KPI boundary.';
        result=energy008.make_result('environmental_kpis','FAILED',struct(), 'm3/t MeOH',modelInput,{}, {msg},struct(),struct('source_ids',{sourceIds}));
        result.diagnostics=energy008.diagnostic('ENV-WATER-CLOSURE-INVALID','ERROR','environmental_kpis',msg,struct(),sourceIds,'Reconcile meters and the water reuse boundary.'); return;
    end
    metrics.net_water_intensity=struct('status','SCREENING_ONLY','value',netWater_m3_s/meoh_t_s, ...
        'units','m3/t MeOH','withdrawal_m3_day',withdrawal_m3_s*86400, ...
        'discharge_m3_day',discharge_m3_s*86400,'net_withdrawal_m3_day',netWater_m3_s*86400, ...
        'internal_net_withdrawal_m3_s',netWater_m3_s,'equation','(withdrawal_m3_s - discharge_m3_s)/saleable_MeOH_t_s');
else
    blockers{end+1}=['Net water intensity blocked; missing/invalid input or traceability metadata: ' strjoin(waterMissing,', ')]; %#ok<AGROW>
end

wasteFields={'solid_waste_kg_day','methanol_saleable_kg_day'};
wasteSourceFields={'solid_waste_kg_day','methanol_saleable_kg_day'};
wasteMissing=[missingNumeric(inputs,wasteFields),commonMeta,missingSourceMap(sourceMap,wasteSourceFields)];
if isempty(wasteMissing)
    if inputs.solid_waste_kg_day<0 || inputs.methanol_saleable_kg_day<=0
        msg='Solid waste must be nonnegative and methanol product rate must be positive.';
        result=energy008.make_result('environmental_kpis','FAILED',struct(), 'kg/t MeOH',modelInput,{}, {msg},struct(),struct('source_ids',{sourceIds}));
        result.diagnostics=energy008.diagnostic('ENV-WASTE-NEGATIVE','ERROR','environmental_kpis',msg,struct(),sourceIds,'Correct solid waste and production meter inputs.'); return;
    end
    waste_kg_s=inputs.solid_waste_kg_day/86400;
    meoh_t_s=(inputs.methanol_saleable_kg_day/86400)/1000;
    metrics.solid_waste_intensity=struct('status','SCREENING_ONLY','value',waste_kg_s/meoh_t_s, ...
        'units','kg/t MeOH','solid_waste_kg_day',waste_kg_s*86400, ...
        'internal_solid_waste_rate_kg_s',waste_kg_s,'equation','solid_waste_kg_s/saleable_MeOH_t_s');
else
    blockers{end+1}=['Solid-waste intensity blocked; missing/invalid input or traceability metadata: ' strjoin(wasteMissing,', ')]; %#ok<AGROW>
end

% Numerical ceiling comparison is not certification. Full source-chain/MRV evidence is required.
claimFields={'renewable_electricity_fraction','biogenic_CO2_chain_of_custody','ghg_mrv_method_version'};
claimMissing=commonMeta;
claimMissing=[claimMissing,missingSourceMap(sourceMap,sourceFields)];
for k=1:numel(claimFields)
    f=claimFields{k}; if ~isfield(inputs,f) || isempty(inputs.(f)), claimMissing{end+1}=f; end %#ok<AGROW>
end
chain=energy008.get_option(inputs,'biogenic_CO2_chain_of_custody','');
chainVerified=(islogical(chain)&&isscalar(chain)&&chain) || ...
    (ischar(chain)&&any(strcmpi(strtrim(chain),{'VERIFIED','TRACEABLE','TRUE'}))) || ...
    (isstring(chain)&&isscalar(chain)&&any(strcmpi(strtrim(char(chain)),{'VERIFIED','TRACEABLE','TRUE'})));
if ~isempty(chain) && ~chainVerified, claimMissing{end+1}='biogenic_CO2_chain_of_custody_not_verified'; end
f=energy008.get_option(inputs,'renewable_electricity_fraction',[]);
if ~isempty(f) && (~isnumeric(f)||~isscalar(f)||~isfinite(f)||f<0||f>1)
    msg='renewable_electricity_fraction must be numeric and within [0,1].';
    result=energy008.make_result('environmental_kpis','FAILED',struct(), 'fraction',modelInput,{}, {msg},struct(),struct('source_ids',{sourceIds})); return;
end
limit=energy008.get_option(modelInput.environmental_basis,'reference_limits',struct());
limitValue=energy008.get_option(limit,'non_biogenic_GHG_max_kgCO2e_per_kg_MeOH',[]);
claim=struct('status','BLOCKED','ceiling_kgCO2e_per_kg_MeOH',limitValue, ...
    'reason','Green claim requires complete current MRV methodology, renewable electricity evidence and carbon chain-of-custody evidence.');
if isempty(claimMissing) && isnumeric(limitValue) && isscalar(limitValue) && ~isempty(metrics.ghg_intensity.value)
    claim.status='SCREENING_ONLY'; claim.claim_passes_numerical_ceiling=(metrics.ghg_intensity.value<=limitValue);
    claim.reason='Numerical comparison only; independent MRV verification and source eligibility review remain necessary.';
else
    blockers{end+1}=['Green-methanol claim blocked; missing: ' strjoin(claimMissing,', ')]; %#ok<AGROW>
end
if any(structfun(@(x) strcmp(x.status,'SCREENING_ONLY'),metrics)), overall='SCREENING_ONLY'; else, overall='BLOCKED'; end
metricNames={'Non-biogenic GHG intensity';'Net water intensity';'Solid waste intensity'};
metricValues=[valueOrNaN(metrics.ghg_intensity);valueOrNaN(metrics.net_water_intensity);valueOrNaN(metrics.solid_waste_intensity)];
metricUnits={'kg CO2e/kg MeOH';'m3/t MeOH';'kg/t MeOH'};
metricStatuses={metrics.ghg_intensity.status;metrics.net_water_intensity.status;metrics.solid_waste_intensity.status};
kpiTable=table(metricNames,metricValues,metricUnits,metricStatuses,'VariableNames',{'KPI','Value','Units','Status'});
values=struct('metrics',metrics,'kpi_table',kpiTable,'green_methanol_claim',claim, ...
    'claim_missing_fields',{claimMissing},'input_record',inputs,'source_map',sourceMap,'units',unitMap, ...
    'source_ids',{unique(sourceIds)},'provenance_class',prov, ...
    'measurement_period_start',periodStart,'measurement_period_end',periodEnd, ...
    'regulatory_reference_source_id',energy008.get_option(limit,'source_id','DB-057'), ...
    'blockers',{blockers},'boundary_note','Plant-gate calculation only. Upstream source allocation, renewable attributes and downstream carbon fate must be separately documented.');
if ~isempty(blockers), warnings=blockers; end
basisSources=energy008.cellstr_safe(energy008.get_option(modelInput.environmental_basis,'source_ids',{}));
allSources=[sourceIds(:)' basisSources(:)'];
result=energy008.make_result('environmental_kpis',overall,values, ...
    struct('ghg','kg CO2e/kg MeOH','water','m3/t MeOH','waste','kg/t MeOH'),modelInput,warnings,{},struct(), ...
    struct('source_ids',{unique(allSources)}));
end

function missing=missingNumeric(inputs,fields)
missing={};
for k=1:numel(fields)
    f=fields{k};
    if ~isfield(inputs,f) || isempty(inputs.(f)) || ~isnumeric(inputs.(f)) || ~isscalar(inputs.(f)) || ~isfinite(inputs.(f))
        missing{end+1}=f; %#ok<AGROW>
    end
end
end
function v=valueOrNaN(s)
if isfield(s,'value') && isnumeric(s.value) && isscalar(s.value) && ~isempty(s.value), v=s.value; else, v=NaN; end
end

function missing=missingSourceMap(sourceMap,fields)
missing={};
for k=1:numel(fields)
    f=fields{k};
    if ~isfield(sourceMap,f) || isempty(sourceMap.(f)) || ...
            ~(ischar(sourceMap.(f)) || (isstring(sourceMap.(f))&&isscalar(sourceMap.(f)))) || isempty(strtrim(char(sourceMap.(f))))
        missing{end+1}=['source_map.' f]; %#ok<AGROW>
    end
end
end

function tf=validISODate(value)
tf=false;
if isempty(regexp(value,'^\d{4}-\d{2}-\d{2}$','once')), return; end
try
    d=datenum(value,'yyyy-mm-dd');
    tf=strcmp(datestr(d,'yyyy-mm-dd'),value);
catch
    tf=false;
end
end
