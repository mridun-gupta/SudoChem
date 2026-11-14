function result = material_balance(modelInput,request,options)
%MATERIAL_BALANCE Compute the declared reaction-block reference in SI units.
% Internal basis: mol/s, kg/s, kg/mol. Fixture/presentation units are exported
% separately as kmol/day and kg/day. This is not the 55-stream plant balance.
narginchk(3,3);
c=modelInput.case_data; warnings={}; errors={};
if strcmp(c.case_status,'BLOCKED')
    msg=strjoin(c.blockers,' ');
    result=energy008.make_result('material_balance','BLOCKED',struct('case_id',c.case_id,'blockers',{c.blockers}),'N/A',modelInput,{msg},{},struct(),struct('source_ids',{c.source_ids}));
    result.diagnostics=energy008.diagnostic('CASE-ROUTE-BLOCKED','WARNING','material_balance',msg,struct('case_id',c.case_id),c.source_ids,'Supply validated route-specific feed and reaction model data before enabling this route.');
    return;
end
if ~any(strcmp(c.route_id,{'Route C','Route A'}))
    msg='The selected scenario is not a CO2-hydrogenation stoichiometric reference supported by the current independent network.';
    result=energy008.make_result('material_balance','BLOCKED',struct('case_id',c.case_id,'blockers',{{msg}}),'N/A',modelInput,{msg},{},struct(),struct('source_ids',{c.source_ids}));
    result.diagnostics=energy008.diagnostic('REACTION-NETWORK-UNAVAILABLE','WARNING','material_balance',msg,struct('case_id',c.case_id),c.source_ids,'Implement and validate the route-specific network only after source-backed feed and kinetic data are available.'); return;
end
if ~any(strcmp(c.scenario_type,{'STOICHIOMETRIC_REFERENCE','TURNDOWN_SCREENING'}))
    msg='Scenario type is outside the implemented stoichiometric reference boundary.';
    result=energy008.make_result('material_balance','BLOCKED',struct('case_id',c.case_id,'blockers',{{msg}}),'N/A',modelInput,{msg},{},struct(),struct('source_ids',{c.source_ids})); return;
end
try
    % Import molecular weights as kg/mol. Register values are kg/kmol and are
    % divided by 1000 only at this data boundary.
    props=modelInput.properties.components; mw_kg_mol=struct();
    for k=1:numel(props)
        key=regexprep(char(props(k).formula),'[^A-Za-z0-9]','');
        if ~isfinite(props(k).molecular_weight_kg_kmol) || props(k).molecular_weight_kg_kmol<=0
            error('ENERGY008:InvalidMolecularWeight','Component %s has invalid MW.',props(k).component_id);
        end
        mw_kg_mol.(key)=props(k).molecular_weight_kg_kmol/1000;
    end

    % Read the product-positive stoichiometric matrix and IDs from the
    % controlled reaction register. Reaction coefficients are never repeated
    % as numeric literals in the calculation layer.
    net=modelInput.reaction_network;
    N=net.stoichiometric_matrix_products_positive;
    species=energy008.cellstr_safe(net.species_order);
    reactionIds=energy008.cellstr_safe(net.reaction_order);
    if size(N,1)~=numel(species) || size(N,2)~=numel(reactionIds)
        error('ENERGY008:StoichiometryShape','Stoichiometric matrix dimensions do not match species/reaction registers.');
    end
    iCO2=find(strcmp(species,'CO2'),1); iH2=find(strcmp(species,'H2'),1);
    iCO=find(strcmp(species,'CO'),1); iMeOH=find(strcmp(species,'CH3OH'),1);
    iH2O=find(strcmp(species,'H2O'),1); iO2=find(strcmp(species,'O2'),1);
    jR01=find(strcmp(reactionIds,'R-01'),1); jR02=find(strcmp(reactionIds,'R-02'),1);
    jE01=find(strcmp(reactionIds,'E-01'),1);
    indexCells={iCO2,iH2,iCO,iMeOH,iH2O,iO2,jR01,jR02,jE01};
    if any(cellfun(@isempty,indexCells))
        error('ENERGY008:StoichiometryIdentityMissing','Reaction matrix must explicitly declare CO2, H2, CO, CH3OH, H2O, O2 and R-01/R-02/E-01.');
    end
    indices=cell2mat(indexCells);
    if any(indices<=0)
        error('ENERGY008:StoichiometryIdentityMissing','Reaction matrix must explicitly declare CO2, H2, CO, CH3OH, H2O, O2 and R-01/R-02/E-01.');
    end

    % Input throughput is kg/day in the versioned case JSON. Convert at the
    % boundary to kg/s; convert MW kg/kmol to kg/mol once above.
    mMeOH_kg_s=unit_conversions(struct('conversion','kg_day_to_kg_s', ...
        'value',c.methanol_component_equivalent_kg_day));
    nMeOH_target_mol_s=mMeOH_kg_s/mw_kg_mol.CH3OH;
    nR02_mol_s=unit_conversions(struct('conversion','kmol_day_to_mol_s', ...
        'value',c.assumptions.R02_extent_kmol_day));
    nuMeOH_R01=N(iMeOH,jR01);
    nuH2_E01=N(iH2,jE01);
    if nuMeOH_R01<=0 || nuH2_E01<=0
        error('ENERGY008:ReactionStoichInvalid','R-01 must produce methanol and E-01 must produce hydrogen for this reference calculation.');
    end
    nR01_mol_s=nMeOH_target_mol_s/nuMeOH_R01;
    % The electrolyser extent is derived by closing its H2 supply against
    % the H2 consumption from the declared synthesis reactions.
    h2ConsumedPerR01=-N(iH2,jR01)*nR01_mol_s;
    h2ConsumedPerR02=-N(iH2,jR02)*nR02_mol_s;
    nE01_mol_s=(h2ConsumedPerR01+h2ConsumedPerR02)/nuH2_E01;
    extents_mol_s=zeros(numel(reactionIds),1);
    extents_mol_s(jR01)=nR01_mol_s;
    extents_mol_s(jR02)=nR02_mol_s;
    extents_mol_s(jE01)=nE01_mol_s;
    if any(~isfinite(extents_mol_s)) || any(extents_mol_s<0)
        error('ENERGY008:ReactionExtentInvalid','Reaction extents must be finite and nonnegative in mol/s.');
    end

    % Per-reaction species contribution is in mol/s. Positive and negative
    % parts provide gross production and consumption at the block interfaces.
    reactionSpecies_mol_s=bsxfun(@times,N,reshape(extents_mol_s,1,[]));
    net_mol_s=sum(reactionSpecies_mol_s,2);
    grossProduced_mol_s=sum(max(reactionSpecies_mol_s,0),2);
    grossConsumed_mol_s=sum(max(-reactionSpecies_mol_s,0),2);
    nCO2_mol_s=grossConsumed_mol_s(iCO2);
    nH2_mol_s=grossConsumed_mol_s(iH2);
    nCO_mol_s=grossProduced_mol_s(iCO);
    nMeOH_mol_s=grossProduced_mol_s(iMeOH);
    nRxnWater_mol_s=grossProduced_mol_s(iH2O);
    nElectrolyserWater_mol_s=grossConsumed_mol_s(iH2O);
    nH2FromElectrolyser_mol_s=grossProduced_mol_s(iH2);
    nO2_mol_s=grossProduced_mol_s(iO2);
    nNetWater_mol_s=nElectrolyserWater_mol_s-nRxnWater_mol_s;
    if abs(nH2FromElectrolyser_mol_s-nH2_mol_s)>1e-10*max(1,nH2_mol_s)
        error('ENERGY008:HydrogenSubsystemClosure','Electrolyser H2 production does not match synthesis H2 consumption.');
    end
    if abs(nMeOH_mol_s-nMeOH_target_mol_s)>1e-10*max(1,nMeOH_target_mol_s)
        error('ENERGY008:MethanolTargetClosure','Declared reaction network does not reproduce the methanol component-equivalent target.');
    end

    massSI=struct('CH3OH_kg_s',nMeOH_mol_s*mw_kg_mol.CH3OH, ...
        'CO2_kg_s',nCO2_mol_s*mw_kg_mol.CO2, ...
        'H2_kg_s',nH2_mol_s*mw_kg_mol.H2, ...
        'CO_kg_s',nCO_mol_s*mw_kg_mol.CO, ...
        'reaction_water_kg_s',nRxnWater_mol_s*mw_kg_mol.H2O, ...
        'electrolyser_water_kg_s',nElectrolyserWater_mol_s*mw_kg_mol.H2O, ...
        'net_water_kg_s',nNetWater_mol_s*mw_kg_mol.H2O, ...
        'O2_kg_s',nO2_mol_s*mw_kg_mol.O2);
    inMass_kg_s=massSI.CO2_kg_s+massSI.net_water_kg_s;
    outMass_kg_s=massSI.CH3OH_kg_s+massSI.CO_kg_s+massSI.O2_kg_s;
    massResidual_kg_s=inMass_kg_s-outMass_kg_s;

    % Element rates are atom-mol/s. Convert exported residuals to kmol atoms/day.
    A=modelInput.reaction_network.element_matrix_rows_C_H_O;
    elementResidual_mol_s=A*net_mol_s;
    labels={'C','H','O'}; elem=struct();
    for k=1:3
        elem.(labels{k})=unit_conversions(struct('conversion','mol_s_to_kmol_day','value',elementResidual_mol_s(k)));
    end
    mass=struct(); siNames=fieldnames(massSI);
    for k=1:numel(siNames)
        f=siNames{k}; outName=strrep(f,'_kg_s','_kg_day');
        mass.(outName)=unit_conversions(struct('conversion','kg_s_to_kg_day','value',massSI.(f)));
    end
    nDay=struct();
    nDay.CH3OH=unit_conversions(struct('conversion','mol_s_to_kmol_day','value',nMeOH_mol_s));
    nDay.CO2=unit_conversions(struct('conversion','mol_s_to_kmol_day','value',nCO2_mol_s));
    nDay.H2=unit_conversions(struct('conversion','mol_s_to_kmol_day','value',nH2_mol_s));
    nDay.CO=unit_conversions(struct('conversion','mol_s_to_kmol_day','value',nCO_mol_s));
    nDay.H2O_reaction=unit_conversions(struct('conversion','mol_s_to_kmol_day','value',nRxnWater_mol_s));
    nDay.H2O_electrolyser=unit_conversions(struct('conversion','mol_s_to_kmol_day','value',nElectrolyserWater_mol_s));
    nDay.H2O_net=unit_conversions(struct('conversion','mol_s_to_kmol_day','value',nNetWater_mol_s));
    nDay.O2=unit_conversions(struct('conversion','mol_s_to_kmol_day','value',nO2_mol_s));
    inMass_kg_day=unit_conversions(struct('conversion','kg_s_to_kg_day','value',inMass_kg_s));
    outMass_kg_day=unit_conversions(struct('conversion','kg_s_to_kg_day','value',outMass_kg_s));
    massResidual_kg_day=unit_conversions(struct('conversion','kg_s_to_kg_day','value',massResidual_kg_s));
    elementResidual_kmol_atoms_day=[elem.C;elem.H;elem.O];

    flowSpecies={'CH3OH';'CO2';'H2';'CO';'H2O_reaction';'H2O_electrolyser';'H2O_net';'O2'};
    molarVals=[nDay.CH3OH;nDay.CO2;nDay.H2;nDay.CO;nDay.H2O_reaction;nDay.H2O_electrolyser;nDay.H2O_net;nDay.O2];
    massVals=[mass.CH3OH_kg_day;mass.CO2_kg_day;mass.H2_kg_day;mass.CO_kg_day; ...
        mass.reaction_water_kg_day;mass.electrolyser_water_kg_day;mass.net_water_kg_day;mass.O2_kg_day];
    flowTable=table(flowSpecies,molarVals,massVals,'VariableNames',{'ComponentOrLedger','Flow_kmol_day','Flow_kg_day'});
    atomTable=table(labels(:),elementResidual_kmol_atoms_day,'VariableNames',{'Element','Residual_kmol_atoms_day'});
    speciesKmolDay=unit_conversions(struct('conversion','mol_s_to_kmol_day','value',net_mol_s));
    speciesTable=table(species(:),speciesKmolDay(:),'VariableNames',{'Species','Net_Species_Rate_kmol_day'});

    values=struct('case_id',c.case_id,'route_id',c.route_id,'status',c.case_status, ...
        'basis',struct('methanol_component_equivalent_kg_day',c.methanol_component_equivalent_kg_day, ...
        'methanol_component_equivalent_kg_s',mMeOH_kg_s,'hours_per_day',c.operating_hours_per_day), ...
        'reaction_extents_SI_mol_s',struct('R01',nR01_mol_s,'R02',nR02_mol_s,'E01',nE01_mol_s), ...
        'reaction_contribution_mol_s',reactionSpecies_mol_s,'reaction_order',{reactionIds},'species_order',{species}, ...
        'reaction_extents_kmol_day',struct('R01',unit_conversions(struct('conversion','mol_s_to_kmol_day','value',nR01_mol_s)), ...
        'R02',unit_conversions(struct('conversion','mol_s_to_kmol_day','value',nR02_mol_s)), ...
        'E01',unit_conversions(struct('conversion','mol_s_to_kmol_day','value',nE01_mol_s))), ...
        'SI_flows',struct('molar_flows_mol_s',struct('CH3OH',nMeOH_mol_s,'CO2',nCO2_mol_s,'H2',nH2_mol_s, ...
        'CO',nCO_mol_s,'H2O_reaction',nRxnWater_mol_s,'H2O_electrolyser',nElectrolyserWater_mol_s, ...
        'H2O_net',nNetWater_mol_s,'O2',nO2_mol_s,'H2_from_electrolyser',nH2FromElectrolyser_mol_s), ...
        'mass_flows_kg_s',massSI,'net_species_mol_s',net_mol_s, ...
        'mass_balance',struct('input_kg_s',inMass_kg_s,'output_kg_s',outMass_kg_s,'residual_input_minus_output_kg_s',massResidual_kg_s), ...
        'element_residual_mol_atoms_s',elementResidual_mol_s), ...
        'molar_flows',struct('methanol_kmol_day',nDay.CH3OH,'co2_kmol_day',nDay.CO2,'h2_kmol_day',nDay.H2, ...
        'co_kmol_day',nDay.CO,'reaction_water_kmol_day',nDay.H2O_reaction,'electrolyser_water_kmol_day',nDay.H2O_electrolyser, ...
        'net_water_kmol_day',nDay.H2O_net,'oxygen_kmol_day',nDay.O2), ...
        'mass_flows',mass,'mass_balance',struct('input_kg_day',inMass_kg_day,'output_kg_day',outMass_kg_day, ...
        'residual_input_minus_output_kg_day',massResidual_kg_day), ...
        'element_residual_kmol_atoms_day',elem, ...
        'ideal_reference_kpis',struct('co2_conversion_fraction',1.0,'h2_conversion_fraction',1.0, ...
        'carbon_selectivity_to_methanol_fraction',nR01_mol_s/max(nR01_mol_s+nR02_mol_s,eps), ...
        'methanol_yield_mol_per_mol_CO2',nR01_mol_s/max(nCO2_mol_s,eps), ...
        'methanol_mass_fraction_in_ideal_product',1.0,'methanol_mole_fraction_in_ideal_product',1.0), ...
        'integrated_net_species_rates_kmol_day',struct('CO2_kmol_day',unit_conversions(struct('conversion','mol_s_to_kmol_day','value',net_mol_s(iCO2))), ...
        'H2_kmol_day',unit_conversions(struct('conversion','mol_s_to_kmol_day','value',net_mol_s(iH2))), ...
        'CO_kmol_day',unit_conversions(struct('conversion','mol_s_to_kmol_day','value',net_mol_s(iCO))), ...
        'CH3OH_kmol_day',unit_conversions(struct('conversion','mol_s_to_kmol_day','value',net_mol_s(iMeOH))), ...
        'H2O_kmol_day',unit_conversions(struct('conversion','mol_s_to_kmol_day','value',net_mol_s(iH2O))), ...
        'O2_kmol_day',unit_conversions(struct('conversion','mol_s_to_kmol_day','value',net_mol_s(iO2)))), ...
        'tables',struct('component_flows',flowTable,'element_closure',atomTable,'net_species_stoichiometry',speciesTable), ...
        'physical_recycle',struct('stream_id','S-209','status','BLOCKED_NOT_COMPUTED','value',[],'reason','No validated PR78 flash, composition, inert assay or recycle convergence basis.'), ...
        'physical_purge',struct('stream_id','S-207','status','BLOCKED_NOT_COMPUTED','value',[],'reason','No validated inert balance, purge criterion or recycle model.'));

    if abs(nR02_mol_s)<=eps
        warnings{end+1}='R-02=0 is the Prompt 17 limiting reference assumption, not a real-reactor prediction.'; %#ok<AGROW>
    else
        warnings{end+1}='Nonzero R-02 extent is an explicit stoichiometric test/reference input only; this is not a real-reactor prediction.'; %#ok<AGROW>
    end
    warnings{end+1}='S-209 recycle and S-207 purge are BLOCKED_NOT_COMPUTED, not zero.'; %#ok<AGROW>
    warnings{end+1}='55 physical stream states/compositions and all plant-wide closure calculations remain unavailable.'; %#ok<AGROW>
    if strcmp(c.scenario_type,'TURNDOWN_SCREENING'), status='SCREENING_ONLY'; else, status='REFERENCE_ONLY'; end
    if max(abs(elementResidual_mol_s))>tolElementMolS(modelInput)
        error('ENERGY008:ElementBalanceFailure','Elemental closure exceeds the SI-scaled tolerance.');
    end
    residuals=struct('mass_residual_kg_s',massResidual_kg_s,'mass_residual_kg_day',massResidual_kg_day, ...
        'max_abs_element_residual_mol_atoms_s',max(abs(elementResidual_mol_s)), ...
        'max_abs_element_residual_kmol_atoms_day',max(abs(elementResidual_kmol_atoms_day)), ...
        'element_tolerance_mol_atoms_s',tolElementMolS(modelInput));
catch ME
    errors={struct('identifier',ME.identifier,'message',ME.message)};
    values=struct(); status='FAILED'; residuals=struct();
end
result=energy008.make_result('material_balance',status,values, ...
    struct('internal_mass_flow','kg/s','internal_molar_flow','mol/s','export_molar_flow','kmol/day','export_mass_flow','kg/day'), ...
    modelInput,warnings,errors,residuals,struct('reaction_network_version',modelInput.versions.reaction_network,'source_ids',{c.source_ids}));
if ~isempty(errors), result.diagnostics=energy008.diagnostic(errors{1}.identifier,'ERROR','material_balance',errors{1}.message,struct('case_id',c.case_id),c.source_ids,'Correct the case or reaction matrix; do not force closure.'); end
end
function t=tolElementMolS(modelInput)
% Prompt 17 tolerance was given in kmol atom/day; convert to mol atom/s.
t=unit_conversions(struct('conversion','kmol_day_to_mol_s', ...
    'value',modelInput.fixture.acceptance_tolerances.element_balance_abs_kmol_atoms_day));
end
