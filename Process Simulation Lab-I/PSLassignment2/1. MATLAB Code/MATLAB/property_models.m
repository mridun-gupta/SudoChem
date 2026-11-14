function result = property_models(modelInput,request,options)
%PROPERTY_MODELS Evaluate only source-supported pure-component reference models.
% Requests: 'all_benchmark', 'co2_sensible', 'methanol_latent', 'mw_table',
% or 'pr78_mixture'/'methanol_water_vle' to receive an explicit BLOCKED status.
narginchk(3,3);
requested=energy008.get_option(request,'property_request','all_benchmark');
values=struct(); warnings={}; errors={}; status='CALCULATED';
try
    p=modelInput.properties;
    if any(strcmpi(requested,{'pr78_mixture','pr78_flash','mixture_fugacity'}))
        d=energy008.diagnostic('PROP-PR78-KIJ-MISSING','WARNING','property_models', ...
            'PR78 synthesis-loop mixture evaluation is blocked because the active binary kij matrix is incomplete.', ...
            struct('domain','PR78_FULL_SYNTHESIS_MIXTURE'),{'ENERGY008-DATA-0.1.0'}, ...
            'Obtain/regress every active binary pair and validate fugacity/phase behaviour against independent data. Missing kij must not be set to zero.');
        values=struct('domain','PR78_FULL_SYNTHESIS_MIXTURE','data_status','BLOCKED','value',[],'blockers',{{d.message}});
        result=energy008.make_result('property_models','BLOCKED',values,'N/A',modelInput,{d.message},{},struct(),struct('source_ids',{{'ENERGY008-DATA-0.1.0'}}));
        result.diagnostics=d; return;
    elseif any(strcmpi(requested,{'wilson','nrtl','methanol_water_vle','distillation_flash'}))
        msg='Methanol-water VLE is blocked: no fitted/validated Wilson or NRTL parameters at an approved column pressure.';
        d=energy008.diagnostic('PROP-MEOH-WATER-VLE-MISSING','WARNING','property_models',msg,struct(),{'ENERGY008-DATA-0.1.0'}, ...
            'Retrieve the source VLE points, regress candidate parameters, freeze column pressure and independently validate the fit.');
        result=energy008.make_result('property_models','BLOCKED',struct('domain','METHANOL_WATER_VLE','data_status','BLOCKED','value',[]),'N/A',modelInput,{msg},{},struct(),struct('source_ids',{{'ENERGY008-DATA-0.1.0'}}));
        result.diagnostics=d; return;
    elseif ~any(strcmpi(requested,{'all_benchmark','co2_sensible','methanol_latent','mw_table'}))
        msg=sprintf('Property request "%s" is not implemented in the curated ENERGY008-DATA-0.1.0 model layer.',char(requested));
        d=energy008.diagnostic('PROP-REQUEST-UNSUPPORTED','WARNING','property_models',msg, ...
            struct('requested_property',char(requested)),{'ENERGY008-DATA-0.1.0'}, ...
            'Add a source-backed property record, unit/validity schema and independent validation before implementing this request.');
        result=energy008.make_result('property_models','BLOCKED',struct('domain',char(requested),'data_status','BLOCKED','value',[]), ...
            'N/A',modelInput,{msg},{},struct(),struct('source_ids',{{'ENERGY008-DATA-0.1.0'}}));
        result.diagnostics=d; return;
    end
    % Component MWs are read from the versioned reference data object, never hard-coded here.
    mw=struct();
    for k=1:numel(p.components)
        key=regexprep(char(p.components(k).formula),'[^A-Za-z0-9]','');
        mw.(key)=p.components(k).molecular_weight_kg_kmol;
    end
    values.molecular_weights_kg_kmol=mw;
    values.molecular_weight_sources={p.components.source_id};
    values.blocked_property_domains=p.blocked_property_domains;
    values.molecular_weight_provenance={p.components.provenance_class};
    if any(strcmpi(requested,{'all_benchmark','co2_sensible'}))
        s=p.correlations.shomate_CO2_ideal_gas;
        benchmark=p.benchmark_conditions;
        T1=energy008.get_option(request,'co2_T1_K',benchmark.co2_shomate_temperature_start_K);
        T2=energy008.get_option(request,'co2_T2_K',benchmark.co2_shomate_temperature_end_K);
        if T1<s.temperature_min_K || T2>s.temperature_max_K || T2<=T1
            error('ENERGY008:PropertyOutOfRange','CO2 Shomate integral requires %g <= T1 < T2 <= %g K; received T1=%g K T2=%g K.',s.temperature_min_K,s.temperature_max_K,T1,T2);
        end
        dh=shomateH(s,T2)-shomateH(s,T1); % kJ/mol
        nMeOH=modelInput.case_data.methanol_component_equivalent_kg_day/mw.CH3OH;
        nDot=unit_conversions(struct('conversion','kmol_day_to_mol_s','value',nMeOH)); % mol/s
        qkW=nDot*dh; % (mol/s)*(kJ/mol)=kJ/s=kW
        values.co2_sensible=struct('correlation_id',s.correlation_id,'T1_K',T1,'T2_K',T2, ...
            'delta_h_kJ_mol',dh,'molar_flow_mol_s',nDot,'duty_kW',qkW, ...
            'validity_K',[s.temperature_min_K s.temperature_max_K], ...
            'status','SCREENING_ONLY','source_id',s.source_id,'provenance_class',s.provenance_class);
    end
    if any(strcmpi(requested,{'all_benchmark','methanol_latent'}))
        s=p.correlations.methanol_latent_heat;
        T=energy008.get_option(request,'methanol_saturation_T_K',p.benchmark_conditions.methanol_latent_temperature_K);
        if T<s.temperature_min_K || T>s.temperature_max_K
            error('ENERGY008:PropertyOutOfRange','Methanol latent correlation only valid from %g to %g K; received %g K.',s.temperature_min_K,s.temperature_max_K,T);
        end
        Tr=T/s.critical_temperature_K;
        dhv=s.A_kJ_mol*exp(-s.alpha*Tr)*(1-Tr)^s.beta;
        nMeOH=modelInput.case_data.methanol_component_equivalent_kg_day/mw.CH3OH;
        nDot=unit_conversions(struct('conversion','kmol_day_to_mol_s','value',nMeOH));
        qkW=nDot*dhv;
        values.methanol_latent=struct('correlation_id',s.correlation_id,'T_K',T,'Tr',Tr, ...
            'delta_hvap_kJ_mol',dhv,'molar_flow_mol_s',nDot,'duty_kW',qkW, ...
            'validity_K',[s.temperature_min_K s.temperature_max_K], ...
            'status','SCREENING_ONLY','source_id',s.source_id,'provenance_class',s.provenance_class);
    end
    warnings{end+1}='Pure-component reference correlations are not a validated high-pressure process mixture property package.'; %#ok<AGROW>
    warnings{end+1}='Liquid-product standard-state reaction enthalpy and pure methanol latent heat must not be re-labelled as reactor or distillation duties.'; %#ok<AGROW>
catch ME
    errors{end+1}=struct('identifier',ME.identifier,'message',ME.message); %#ok<AGROW>
    status='FAILED';
end
result=energy008.make_result('property_models',status,values,struct('molecular_weight','kg/kmol','delta_h','kJ/mol','duty','kW'),modelInput,warnings,errors,struct(), ...
    struct('property_data_version',p.property_data_version,'source_ids',{{'PROP-0001','PROP-0002','PROP-0003','DB-019','PROP-0006','SHOMATE-04','DHVAP-MEOH-01'}}));
end
function h=shomateH(s,T)
t=T/1000;
h=s.A*t+s.B*t^2/2+s.C*t^3/3+s.D*t^4/4-s.E/t; % Difference constant cancels.
end
