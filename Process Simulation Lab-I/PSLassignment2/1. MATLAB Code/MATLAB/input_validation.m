function result = input_validation(modelInput,request,options)
%INPUT_VALIDATION Validate case, schema, stoichiometry, units and provenance.
% Case-file throughput arrives in kg/day; calculation modules convert to SI
% kg/s and mol/s at import boundaries. Pressure, where supplied, is Pa absolute; T is K.
narginchk(3,3); %#ok<NASGU>
errors={}; warnings={}; diags=struct([]); checks=struct();
try
    requiredTop={'versions','case_data','properties','reaction_network','fixture'};
    for k=1:numel(requiredTop)
        if ~isfield(modelInput,requiredTop{k}), error('ENERGY008:ModelFieldMissing','modelInput.%s is required.',requiredTop{k}); end
    end
    c=modelInput.case_data;
    requiredCase={'schema_id','case_id','case_version','scenario_type','route_id','case_status','methanol_component_equivalent_kg_day','operating_hours_per_day','assumptions','operating_state','design_basis_version','model_version','reaction_network_version','property_data_version','source_ids','provenance_class','units'};
    for k=1:numel(requiredCase)
        if ~isfield(c,requiredCase{k}), error('ENERGY008:CaseFieldMissing','Case field %s is required.',requiredCase{k}); end
    end
    if ~strcmp(char(c.schema_id),'ENERGY008-CASE-0.1.0'), error('ENERGY008:CaseSchemaUnsupported','Unsupported case schema_id.'); end
    if ~isnumeric(c.methanol_component_equivalent_kg_day) || ~isscalar(c.methanol_component_equivalent_kg_day) || ...
            ~isfinite(c.methanol_component_equivalent_kg_day) || c.methanol_component_equivalent_kg_day<=0
        error('ENERGY008:InvalidThroughput','Methanol component-equivalent basis must be a positive finite kg/day value.');
    end
    if ~isnumeric(c.operating_hours_per_day) || ~isscalar(c.operating_hours_per_day) || ...
            ~isfinite(c.operating_hours_per_day) || c.operating_hours_per_day<=0 || c.operating_hours_per_day>24
        error('ENERGY008:OperatingHoursInvalid','operating_hours_per_day must be a positive finite value no greater than 24 h/day.');
    end
    unitChecks={'methanol_component_equivalent_kg_day','kg/day';'operating_hours_per_day','h/day'; ...
        'assumptions.R02_extent_kmol_day','kmol/day';'assumptions.R01_conversion_fraction','fraction'; ...
        'assumptions.fresh_CO2_to_MeOH_molar_ratio','mol/mol';'assumptions.fresh_H2_to_MeOH_molar_ratio','mol/mol'; ...
        'assumptions.electrolysis_H2_to_H2O_molar_ratio','mol/mol';'assumptions.electrolysis_O2_to_H2_molar_ratio','mol/mol'; ...
        'operating_state.temperature_K','K';'operating_state.pressure_MPa_abs','MPa(a)'};
    for uu=1:size(unitChecks,1)
        pathName=unitChecks{uu,1}; unitKey=strrep(pathName,'.','_');
        if ~isfield(c.units,unitKey)
            error('ENERGY008:CaseUnitMissing','Missing unit declaration for %s.',pathName);
        end
        if ~strcmp(char(c.units.(unitKey)),unitChecks{uu,2})
            error('ENERGY008:CaseUnitMismatch','%s must declare unit %s.',pathName,unitChecks{uu,2});
        end
    end
    versionChecks={'model_version','model';'reaction_network_version','reaction_network';'property_data_version','property_data';'design_basis_version','design_basis'};
    for vv=1:size(versionChecks,1)
        f=versionChecks{vv,1}; v=versionChecks{vv,2};
        if ~strcmp(char(c.(f)),char(modelInput.versions.(v)))
            error('ENERGY008:CaseVersionMismatch','Case %s declares %s=%s, but loaded project version is %s.',c.case_id,f,char(c.(f)),char(modelInput.versions.(v)));
        end
    end
    if isempty(c.source_ids) || isempty(c.provenance_class) || isempty(c.design_basis_version)
        error('ENERGY008:CaseProvenanceMissing','Case requires source_ids, provenance_class and design_basis_version.');
    end
    components=modelInput.properties.components;
    ids={components.component_id};
    if numel(unique(ids))~=numel(ids), error('ENERGY008:DuplicateComponentId','Component IDs are not unique.'); end
    for k=1:numel(components)
        q=components(k);
        if ~isfield(q,'molecular_weight_kg_kmol') || ~isfinite(q.molecular_weight_kg_kmol) || q.molecular_weight_kg_kmol<=0
            error('ENERGY008:InvalidMolecularWeight','Component %s has an invalid molecular weight.',q.component_id);
        end
        if ~isfield(q,'source_id') || isempty(q.source_id) || ~isfield(q,'provenance_class') || isempty(q.provenance_class)
            error('ENERGY008:MissingProvenance','Component %s requires source_id and provenance_class.',q.component_id);
        end
    end
    rids=energy008.cellstr_safe(modelInput.reaction_network.reaction_order);
    if numel(unique(rids))~=numel(rids), error('ENERGY008:DuplicateReactionId','Reaction IDs are not unique.'); end
    networkComponents=energy008.cellstr_safe(modelInput.reaction_network.component_ids);
    species=energy008.cellstr_safe(modelInput.reaction_network.species_order);
    if numel(networkComponents)~=numel(species) || numel(unique(networkComponents))~=numel(networkComponents)
        error('ENERGY008:ReactionComponentMapInvalid','Each reaction species must map to exactly one unique component ID.');
    end
    if ~all(ismember(networkComponents,ids)), error('ENERGY008:ReactionComponentMissing','Reaction network references component IDs absent from the property data.'); end
    expectedA=zeros(3,numel(species)); elementNames={'C','H','O'};
    for k=1:numel(networkComponents)
        idx=find(strcmp(ids,networkComponents{k}),1);
        if isempty(idx) || ~isfield(components(idx),'elements'), error('ENERGY008:ElementalIdentityMissing','Component %s lacks elemental identity.',networkComponents{k}); end
        formula=regexprep(char(components(idx).formula),'[^A-Za-z0-9]','');
        speciesFormula=regexprep(char(species{k}),'[^A-Za-z0-9]','');
        if ~strcmp(formula,speciesFormula), error('ENERGY008:SpeciesComponentMismatch','Species %s maps to a component with formula %s.',species{k},formula); end
        for ee=1:numel(elementNames)
            if ~isfield(components(idx).elements,elementNames{ee}), error('ENERGY008:ElementalIdentityMissing','Component %s lacks element %s.',networkComponents{k},elementNames{ee}); end
            expectedA(ee,k)=components(idx).elements.(elementNames{ee});
        end
    end
    if ~isequal(size(expectedA),size(modelInput.reaction_network.element_matrix_rows_C_H_O)) || ...
            any(expectedA(:)~=modelInput.reaction_network.element_matrix_rows_C_H_O(:))
        error('ENERGY008:ElementMatrixPropertyMismatch','Reaction element matrix is inconsistent with source property component identities.');
    end
    allowedStatuses={'CALCULATED','REFERENCE_ONLY','SCREENING_ONLY','BLOCKED','FAILED','NOT_RUN'};
    if ~any(strcmp(c.case_status,{'REFERENCE_ONLY','SCREENING_ONLY','BLOCKED'}))
        error('ENERGY008:CaseStatusInvalid','Default case status must be REFERENCE_ONLY, SCREENING_ONLY or BLOCKED.');
    end
    if ~isfield(c.assumptions,'R02_extent_kmol_day') || ~isnumeric(c.assumptions.R02_extent_kmol_day) || ...
            ~isscalar(c.assumptions.R02_extent_kmol_day) || ~isfinite(c.assumptions.R02_extent_kmol_day) || c.assumptions.R02_extent_kmol_day<0
        error('ENERGY008:InvalidReactionExtent','R-02 reference extent must be a finite nonnegative scalar in kmol/day.');
    end
    if ~isfield(c.assumptions,'R02_extent_reason') || isempty(c.assumptions.R02_extent_reason) || ...
            ~isfield(c.assumptions,'R02_extent_status') || ~strcmp(c.assumptions.R02_extent_status,'REFERENCE_BLOCK_ASSUMPTION_ONLY')
        error('ENERGY008:ReactionAssumptionProvenanceMissing','R-02 extent requires the declared reference-only status and reason.');
    end
    % Cross-check case stoichiometric assumptions against the loaded reaction
    % matrix instead of repeating reaction coefficients as code constants.
    N=modelInput.reaction_network.stoichiometric_matrix_products_positive;
    iCO2=find(strcmp(species,'CO2'),1); iH2=find(strcmp(species,'H2'),1);
    iMeOH=find(strcmp(species,'CH3OH'),1); iH2O=find(strcmp(species,'H2O'),1); iO2=find(strcmp(species,'O2'),1);
    jR01=find(strcmp(rids,'R-01'),1); jE01=find(strcmp(rids,'E-01'),1);
    stoichIndex={iCO2,iH2,iMeOH,iH2O,iO2,jR01,jE01};
    if any(cellfun(@isempty,stoichIndex))
        error('ENERGY008:StoichiometryIdentityMissing','Stoichiometric reference validation requires CO2/H2/CH3OH/H2O/O2 and R-01/E-01.');
    end
    if N(iMeOH,jR01)<=0 || N(iCO2,jR01)>=0 || N(iH2,jR01)>=0 || ...
            N(iH2,jE01)<=0 || N(iH2O,jE01)>=0 || N(iO2,jE01)<=0
        error('ENERGY008:StoichiometricReferenceReactionInvalid','R-01/E-01 coefficient signs are incompatible with the declared reference chemistry.');
    end
    ratiosFromNetwork=[-N(iCO2,jR01)/N(iMeOH,jR01),-N(iH2,jR01)/N(iMeOH,jR01), ...
        N(iH2,jE01)/-N(iH2O,jE01),N(iO2,jE01)/N(iH2,jE01)];
    ratiosFromCase=[c.assumptions.fresh_CO2_to_MeOH_molar_ratio,c.assumptions.fresh_H2_to_MeOH_molar_ratio, ...
        c.assumptions.electrolysis_H2_to_H2O_molar_ratio,c.assumptions.electrolysis_O2_to_H2_molar_ratio];
    if any(~isfinite(ratiosFromCase)) || any(~isfinite(ratiosFromNetwork)) || ...
            any(abs(ratiosFromCase-ratiosFromNetwork)>1e-12) || c.assumptions.R01_conversion_fraction~=1
        error('ENERGY008:StoichiometricReferenceAssumptionMismatch','Case stoichiometric ratios do not match the loaded reaction matrix or the ideal full-conversion reference assumption.');
    end
    if ~isfield(modelInput.properties,'correlations') || ~isfield(modelInput.properties.correlations,'shomate_CO2_ideal_gas') || ~isfield(modelInput.properties.correlations,'methanol_latent_heat')
        error('ENERGY008:PropertyCorrelationMissing','Required benchmark pure-component correlations are missing.');
    end
    N=modelInput.reaction_network.stoichiometric_matrix_products_positive;
    A=modelInput.reaction_network.element_matrix_rows_C_H_O;
    if ~isequal(size(N),[numel(modelInput.reaction_network.species_order),numel(modelInput.reaction_network.reaction_order)])
        error('ENERGY008:StoichiometricMatrixShape','Stoichiometric matrix dimensions do not match species and reaction lists.');
    end
    elemResidual=A*N;
    maxElem=max(abs(elemResidual(:)));
    if maxElem>1e-12, error('ENERGY008:ReactionElementImbalance','Reaction network violates elemental conservation; maximum |A*N|=%g.',maxElem); end
    if rank(N)~=modelInput.reaction_network.rank, error('ENERGY008:ReactionRankMismatch','Declared reaction rank does not match numerical stoichiometric rank.'); end
    if isfield(c,'operating_state') && strcmp(c.operating_state.data_status,'BLOCKED')
        warnings{end+1}='Physical process-state temperature and pressure are intentionally blocked; reference-only calculations may proceed.'; %#ok<AGROW>
    end
    if strcmp(c.case_status,'BLOCKED')
        warnings{end+1}='Selected scenario is explicitly BLOCKED; no process material calculation will be attempted.'; %#ok<AGROW>
    end
    checks.case_id=c.case_id; checks.throughput_kg_day=c.methanol_component_equivalent_kg_day;
    checks.component_count=numel(components); checks.reaction_count=size(N,2);
    checks.max_element_matrix_residual=maxElem; checks.reaction_rank=rank(N);
    checks.unit_system='SI_INTERNAL'; checks.provenance_complete=true;
    checks.schema_version=modelInput.versions.schema; checks.property_data_version=modelInput.versions.property_data;
    status='CALCULATED';
catch ME
    errors{end+1}=struct('identifier',ME.identifier,'message',ME.message); %#ok<AGROW>
    diags=energy008.diagnostic(ME.identifier,'ERROR','input_validation',ME.message,struct(),{}, ...
        'Correct the cited case/schema/source input. Do not coerce invalid values to zero.');
    status='FAILED'; checks=struct();
end
result=energy008.make_result('input_validation',status,checks,'dimensionless / declared input units',modelInput,warnings,errors,struct(),struct('source_ids',{{'ENERGY008-SCHEMA-0.1.0','ENERGY008-RXN-0.1.0'}}));
result.diagnostics=diags;
end
