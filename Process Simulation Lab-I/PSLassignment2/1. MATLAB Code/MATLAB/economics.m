function result = economics(modelInput,request,options)
%ECONOMICS Source-gated installed-CAPEX, annual-OPEX and LCOM screening model.
% All costs are INR at one declared reference year. The module does not
% generate equipment correlations or tariffs; it only escalates dated quotes
% using supplied indices and computes a discounted-capital-recovery screen.
narginchk(3,3);
cost=energy008.get_option(request,'cost_estimate',modelInput.cost_basis.inputs.screening_cost_model);
blockers={}; errors={};
if ~isstruct(cost) || isempty(fieldnames(cost))
    blockers={'screening_cost_model input record is missing.'};
else
    if ~isfield(cost,'quote_items') || isempty(cost.quote_items), blockers{end+1}='dated equipment quote_items are missing.'; end
    if ~isfield(cost,'annual_cost_drivers') || ~isstruct(cost.annual_cost_drivers), blockers{end+1}='annual_cost_drivers record is missing.'; end
end
if isempty(blockers)
    q=cost.quote_items; o=cost.annual_cost_drivers;
    if ~isstruct(q) || isempty(q)
        blockers{end+1}='quote_items must be a nonempty struct array.';
    else
        qFields={'equipment_id','bare_equipment_quote_INR','quote_year','escalation_index_at_quote', ...
            'escalation_index_at_reference_year','location_factor','installation_factor','contingency_fraction','uncertainty_fraction','currency','source_id'};
        for k=1:numel(q)
            for j=1:numel(qFields)
                f=qFields{j}; if ~isfield(q(k),f) || isempty(q(k).(f)), blockers{end+1}=sprintf('quote_items(%d).%s is missing.',k,f); end %#ok<AGROW>
            end
        end
    end
    oFields={'electricity_kWh_year','electricity_tariff_INR_kWh','electricity_uncertainty_fraction', ...
        'water_m3_year','water_tariff_INR_m3','water_uncertainty_fraction', ...
        'steam_t_year','steam_tariff_INR_t','steam_uncertainty_fraction', ...
        'chemicals_INR_year','chemicals_uncertainty_fraction','labour_INR_year','labour_uncertainty_fraction', ...
        'maintenance_fraction_installed_CAPEX','maintenance_uncertainty_fraction', ...
        'waste_t_year','waste_tariff_INR_t','waste_uncertainty_fraction', ...
        'saleable_methanol_t_year','discount_rate_fraction','plant_life_years','source_map'};
    for j=1:numel(oFields)
        f=oFields{j}; if ~isfield(o,f) || isempty(o.(f)), blockers{end+1}=['annual_cost_drivers.' f ' is missing.']; end %#ok<AGROW>
    end
end
if ~isempty(blockers)
    values=struct('currency',modelInput.cost_basis.currency,'reference_year',modelInput.cost_basis.reference_year, ...
        'CAPEX_INR',[],'OPEX_INR_per_year',[],'annualised_CAPEX_INR_per_year',[], ...
        'levelised_cost_INR_per_t_MeOH',[],'cost_uncertainty',struct('status','BLOCKED','value',[]), ...
        'status','BLOCKED','blockers',{blockers},'input_record',cost);
    d=energy008.diagnostic('ECON-COST-DATA-MISSING','WARNING','economics',strjoin(blockers,' '),struct(), ...
        {'DB-060','DB-061','DB-062'},'Populate the versioned cost template with source-backed dated quotes, escalation indices, utility tariffs/consumptions, OPEX drivers, finance inputs and uncertainty fractions.');
    result=energy008.make_result('economics','BLOCKED',values,'INR; INR/year; INR/t methanol',modelInput,blockers,{},struct(), ...
        struct('source_ids',{{'DB-060','DB-061','DB-062'}})); result.diagnostics=d; return;
end
try
    refYear=modelInput.cost_basis.reference_year;
    if ~isfield(cost,'currency') || ~strcmp(char(cost.currency),'INR') || ...
            ~isfield(cost,'reference_year') || cost.reference_year~=refYear
        error('ENERGY008:CostBasisMismatch','Cost model currency/reference_year must match the approved project convention (INR, %g).',refYear);
    end
    % Escalated/installed quote values; every factor and source is explicit.
    capexItems=cell(numel(q),1); capexValues=zeros(numel(q),1); capexSigma=zeros(numel(q),1); quoteSources={};
    for k=1:numel(q)
        z=q(k);
        numericFields={'bare_equipment_quote_INR','quote_year','escalation_index_at_quote', ...
            'escalation_index_at_reference_year','location_factor','installation_factor','contingency_fraction','uncertainty_fraction'};
        for j=1:numel(numericFields)
            f=numericFields{j}; v=z.(f);
            if ~isnumeric(v)||~isscalar(v)||~isfinite(v), error('ENERGY008:CostQuoteInvalid','Quote %d field %s must be finite numeric.',k,f); end
        end
        if z.bare_equipment_quote_INR<=0||z.quote_year>refYear||z.escalation_index_at_quote<=0|| ...
                z.escalation_index_at_reference_year<=0||z.location_factor<=0||z.installation_factor<=0|| ...
                z.contingency_fraction<0||z.contingency_fraction>1||z.uncertainty_fraction<0||z.uncertainty_fraction>1
            error('ENERGY008:CostQuoteInfeasible','Quote %d has nonpositive, future-dated or out-of-range cost factors.',k);
        end
        if ~strcmp(char(z.currency),'INR')||isempty(z.source_id)||isempty(z.equipment_id)
            error('ENERGY008:CostQuoteProvenance','Quote %d must have INR currency, equipment_id and source_id.',k);
        end
        escalation=z.escalation_index_at_reference_year/z.escalation_index_at_quote;
        escalated=z.bare_equipment_quote_INR*escalation;
        installed=escalated*z.location_factor*z.installation_factor*(1+z.contingency_fraction);
        capexValues(k)=installed; capexSigma(k)=installed*z.uncertainty_fraction;
        capexItems{k}=struct('equipment_id',char(z.equipment_id),'bare_quote_INR',z.bare_equipment_quote_INR, ...
            'quote_year',z.quote_year,'escalation_factor',escalation,'location_factor',z.location_factor, ...
            'installation_factor',z.installation_factor,'contingency_fraction',z.contingency_fraction, ...
            'installed_CAPEX_INR',installed,'uncertainty_fraction',z.uncertainty_fraction,'source_id',char(z.source_id));
        quoteSources{end+1}=char(z.source_id); %#ok<AGROW>
    end
    CAPEX=sum(capexValues); CAPEX_sigma=sqrt(sum(capexSigma.^2));

    % All OPEX and finance inputs are source-mapped. No missing item defaults to zero.
    sourceMap=o.source_map; if ~isstruct(sourceMap), sourceMap=struct(); end
    costDriverNames={'electricity_kWh_year','electricity_tariff_INR_kWh','water_m3_year','water_tariff_INR_m3', ...
        'steam_t_year','steam_tariff_INR_t','chemicals_INR_year','labour_INR_year', ...
        'maintenance_fraction_installed_CAPEX','waste_t_year','waste_tariff_INR_t', ...
        'saleable_methanol_t_year','discount_rate_fraction','plant_life_years', ...
        'electricity_uncertainty_fraction','water_uncertainty_fraction','steam_uncertainty_fraction', ...
        'chemicals_uncertainty_fraction','labour_uncertainty_fraction','maintenance_uncertainty_fraction', ...
        'waste_uncertainty_fraction'};
    costSources={};
    for j=1:numel(costDriverNames)
        f=costDriverNames{j}; if ~isfield(sourceMap,f)||isempty(sourceMap.(f))||~ischar(sourceMap.(f))
            error('ENERGY008:CostDriverSourceMissing','annual_cost_drivers.source_map.%s is required.',f);
        end
        costSources{end+1}=char(sourceMap.(f)); %#ok<AGROW>
    end
    % Check each numeric driver and uncertainty fraction.
    allNumeric={'electricity_kWh_year','electricity_tariff_INR_kWh','water_m3_year','water_tariff_INR_m3', ...
        'steam_t_year','steam_tariff_INR_t','chemicals_INR_year','labour_INR_year', ...
        'maintenance_fraction_installed_CAPEX','waste_t_year','waste_tariff_INR_t', ...
        'saleable_methanol_t_year','discount_rate_fraction','plant_life_years', ...
        'electricity_uncertainty_fraction','water_uncertainty_fraction', ...
        'steam_uncertainty_fraction','chemicals_uncertainty_fraction','labour_uncertainty_fraction', ...
        'maintenance_uncertainty_fraction','waste_uncertainty_fraction'};
    for j=1:numel(allNumeric)
        f=allNumeric{j}; v=o.(f);
        if ~isnumeric(v)||~isscalar(v)||~isfinite(v)
            error('ENERGY008:CostDriverInvalid','annual_cost_drivers.%s must be a finite numeric value.',f);
        end
    end
    nonnegative={'electricity_kWh_year','electricity_tariff_INR_kWh','water_m3_year','water_tariff_INR_m3', ...
        'steam_t_year','steam_tariff_INR_t','chemicals_INR_year','labour_INR_year','maintenance_fraction_installed_CAPEX', ...
        'waste_t_year','waste_tariff_INR_t'};
    for j=1:numel(nonnegative)
        if o.(nonnegative{j})<0, error('ENERGY008:CostDriverNegative','annual_cost_drivers.%s cannot be negative.',nonnegative{j}); end
    end
    uncertaintyFields={'electricity_uncertainty_fraction','water_uncertainty_fraction','steam_uncertainty_fraction', ...
        'chemicals_uncertainty_fraction','labour_uncertainty_fraction','maintenance_uncertainty_fraction','waste_uncertainty_fraction'};
    for j=1:numel(uncertaintyFields)
        f=uncertaintyFields{j}; if o.(f)<0||o.(f)>1, error('ENERGY008:CostUncertaintyRange','%s must lie in [0,1].',f); end
    end
    if o.saleable_methanol_t_year<=0||o.discount_rate_fraction<0||o.discount_rate_fraction>1|| ...
            o.plant_life_years<1||o.plant_life_years~=floor(o.plant_life_years)
        error('ENERGY008:FinanceBasisInvalid','Saleable output must be positive; discount rate in [0,1]; plant life a positive integer.');
    end
    % Individual annual cost terms, INR/year.
    O_electricity=o.electricity_kWh_year*o.electricity_tariff_INR_kWh;
    O_water=o.water_m3_year*o.water_tariff_INR_m3;
    O_steam=o.steam_t_year*o.steam_tariff_INR_t;
    O_chemicals=o.chemicals_INR_year;
    O_labour=o.labour_INR_year;
    O_maintenance=CAPEX*o.maintenance_fraction_installed_CAPEX;
    O_waste=o.waste_t_year*o.waste_tariff_INR_t;
    opexComponents=[O_electricity,O_water,O_steam,O_chemicals,O_labour,O_maintenance,O_waste];
    OPEX=sum(opexComponents);
    u=[o.electricity_uncertainty_fraction,o.water_uncertainty_fraction,o.steam_uncertainty_fraction, ...
        o.chemicals_uncertainty_fraction,o.labour_uncertainty_fraction,o.maintenance_uncertainty_fraction,o.waste_uncertainty_fraction];
    OPEX_sigma=sqrt(sum((opexComponents.*u).^2)+(o.maintenance_fraction_installed_CAPEX*CAPEX_sigma)^2);
    if o.discount_rate_fraction==0, CRF=1/o.plant_life_years; else
        CRF=o.discount_rate_fraction*(1+o.discount_rate_fraction)^o.plant_life_years/ ...
            ((1+o.discount_rate_fraction)^o.plant_life_years-1);
    end
    annualisedCAPEX=CAPEX*CRF;
    LCOM=(annualisedCAPEX+OPEX)/o.saleable_methanol_t_year;
    LCOM_sigma=sqrt((CRF*CAPEX_sigma)^2+OPEX_sigma^2)/o.saleable_methanol_t_year;
    capexTable=table(cellfun(@(x)x.equipment_id,capexItems,'UniformOutput',false),capexValues,capexSigma, ...
        'VariableNames',{'Equipment_ID','Installed_CAPEX_INR_Reference_Year','Source_Uncertainty_INR'});
    opexNames={'Electricity';'Water';'Steam';'Chemicals';'Labour';'Maintenance';'Waste'};
    opexTable=table(opexNames,opexComponents(:),u(:),'VariableNames',{'Cost_Component','INR_per_year','Uncertainty_Fraction'});
    sourceIds=unique([quoteSources,costSources]);
    values=struct('currency','INR','reference_year',refYear,'status','SCREENING_ONLY', ...
        'CAPEX_INR',CAPEX,'CAPEX_source_uncertainty_INR',CAPEX_sigma, ...
        'OPEX_INR_per_year',OPEX,'OPEX_source_uncertainty_INR_per_year',OPEX_sigma, ...
        'annualised_CAPEX_INR_per_year',annualisedCAPEX,'capital_recovery_factor',CRF, ...
        'annual_saleable_methanol_t',o.saleable_methanol_t_year, ...
        'levelised_cost_INR_per_t_MeOH',LCOM,'levelised_cost_source_uncertainty_INR_per_t',LCOM_sigma, ...
        'capex_items',capexTable,'opex_breakdown',opexTable,'cost_uncertainty', ...
        struct('status','SOURCE_PROPAGATED_SCREENING','CAPEX_INR',CAPEX_sigma,'OPEX_INR_per_year',OPEX_sigma, ...
        'LCOM_INR_per_t',LCOM_sigma,'method','Root-sum-square of supplied independent fractional source uncertainties; not a statistical confidence interval.'), ...
        'source_ids',{sourceIds},'limitations',{{'Screening estimate only; no Prompt 21 validation or independent cost-estimate audit.','All cost inputs, quote years, escalation and uncertainties are supplied by the project source records.'}});
    warning={'Cost result is SCREENING_ONLY and depends on source-supplied quote, factor, tariff and finance data.'; ...
        'LCOM uses a capital-recovery-factor annualisation; it is not an audited discounted cash-flow model.'};
    result=energy008.make_result('economics','SCREENING_ONLY',values, ...
        struct('CAPEX','INR at reference year','OPEX','INR/year','LCOM','INR/t methanol'),modelInput,warning,{}, ...
        struct('CAPEX_uncertainty_INR',CAPEX_sigma,'OPEX_uncertainty_INR_year',OPEX_sigma,'LCOM_uncertainty_INR_t',LCOM_sigma), ...
        struct('source_ids',{sourceIds}));
catch ME
    err=struct('identifier',ME.identifier,'message',ME.message);
    result=energy008.make_result('economics','FAILED',struct('input_record',cost),'N/A',modelInput,{}, {err},struct(),struct());
    result.diagnostics=energy008.diagnostic(ME.identifier,'ERROR','economics',ME.message,struct(),{}, ...
        'Correct the dated cost quote, factor, source-map, tariff or finance input. No failed estimate is exported as a result.');
end
end
