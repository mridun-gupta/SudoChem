function result = reporting_plots(modelInput,request,options)
%REPORTING_PLOTS Export actual run results, statuses, diagnostics and tables.
% Outputs are written only to a unique MATLAB/results/<run_id> directory.
narginchk(3,3);
R=request.results; outDir=char(request.output_directory); files={}; warnings={}; optionalFailures={};
try
    if exist(outDir,'dir')~=7, error('ENERGY008:ReportDirectoryMissing','Unique run report directory must already exist: %s',outDir); end
    if isfield(R.material,'value') && isfield(R.material.value,'tables')
        writeTable(R.material.value.tables.component_flows,fullfile(outDir,'material_reference_flows.csv')); files{end+1}='material_reference_flows.csv';
        writeTable(R.material.value.tables.element_closure,fullfile(outDir,'element_closure.csv')); files{end+1}='element_closure.csv';
        writeTable(R.material.value.tables.net_species_stoichiometry,fullfile(outDir,'reaction_species_balance.csv')); files{end+1}='reaction_species_balance.csv';
    end
    if isfield(R.sensitivity,'value') && isfield(R.sensitivity.value,'stoichiometric_sensitivity')
        writeTable(R.sensitivity.value.stoichiometric_sensitivity,fullfile(outDir,'throughput_sensitivity.csv')); files{end+1}='throughput_sensitivity.csv';
    end
    if isfield(R.scenarios,'value') && isfield(R.scenarios.value,'scenario_table')
        writeTable(R.scenarios.value.scenario_table,fullfile(outDir,'scenario_status.csv')); files{end+1}='scenario_status.csv';
    end
    if isfield(R.validation,'value') && isfield(R.validation.value,'test_table')
        writeTable(R.validation.value.test_table,fullfile(outDir,'fixture_test_results.csv')); files{end+1}='fixture_test_results.csv';
    end
    if isfield(R.equipment,'value') && isfield(R.equipment.value,'datasheet_register')
        writeTable(R.equipment.value.datasheet_register,fullfile(outDir,'equipment_datasheet_register.csv')); files{end+1}='equipment_datasheet_register.csv';
    end
    if isfield(R.utilities,'value') && isfield(R.utilities.value,'utility_register')
        writeTable(R.utilities.value.utility_register,fullfile(outDir,'utility_register.csv')); files{end+1}='utility_register.csv';
    end
    if isfield(R.environmental,'value') && isfield(R.environmental.value,'kpi_table')
        writeTable(R.environmental.value.kpi_table,fullfile(outDir,'environmental_kpis.csv')); files{end+1}='environmental_kpis.csv';
    end
    % One row per engine module; all blockers/errors/warnings remain in the JSON diagnostic file.
    moduleNames=fieldnames(R); moduleNames=moduleNames(~strcmp(moduleNames,'status'));
    moduleIds={}; moduleStatus={}; warningCounts=[]; errorCounts=[];
    for k=1:numel(moduleNames)
        q=R.(moduleNames{k});
        if isstruct(q)&&isscalar(q)&&isfield(q,'status')&&ischar(q.status)
            moduleIds{end+1,1}=moduleNames{k}; %#ok<AGROW>
            moduleStatus{end+1,1}=q.status; %#ok<AGROW>
            warningCounts(end+1,1)=numel(q.warnings); %#ok<AGROW>
            errorCounts(end+1,1)=numel(q.errors); %#ok<AGROW>
        end
    end
    statusTable=table(moduleIds,moduleStatus,warningCounts,errorCounts, ...
        'VariableNames',{'Module','Status','Warning_Count','Error_Count'});
    writeTable(statusTable,fullfile(outDir,'module_status.csv')); files{end+1}='module_status.csv';

    % Optional multi-sheet XLSX. CSV is authoritative if the spreadsheet writer fails.
    try
        xlsxPath=fullfile(outDir,'reference_engine_results.xlsx'); assertNewFile(xlsxPath);
        if isfield(R.material,'value')&&isfield(R.material.value,'tables')
            writetable(R.material.value.tables.component_flows,xlsxPath,'Sheet','MaterialFlows');
            writetable(R.material.value.tables.element_closure,xlsxPath,'Sheet','ElementClosure');
            writetable(R.material.value.tables.net_species_stoichiometry,xlsxPath,'Sheet','Stoichiometry');
        end
        if isfield(R.validation,'value')&&isfield(R.validation.value,'test_table')
            writetable(R.validation.value.test_table,xlsxPath,'Sheet','FixtureTests');
        end
        if isfield(R.scenarios,'value')&&isfield(R.scenarios.value,'scenario_table')
            writetable(R.scenarios.value.scenario_table,xlsxPath,'Sheet','Scenarios');
        end
        writetable(statusTable,xlsxPath,'Sheet','ModuleStatus');
        if isfield(R.sensitivity,'value')&&isfield(R.sensitivity.value,'stoichiometric_sensitivity')
            writetable(R.sensitivity.value.stoichiometric_sensitivity,xlsxPath,'Sheet','Sensitivity');
        end
        if isfield(R.environmental,'value')&&isfield(R.environmental.value,'kpi_table')
            writetable(R.environmental.value.kpi_table,xlsxPath,'Sheet','EnvironmentalKPIs');
        end
        files{end+1}='reference_engine_results.xlsx';
    catch XLSXME
        optionalFailures{end+1}=['Optional XLSX export not created: ' XLSXME.message]; %#ok<AGROW>
    end

    % Optional figure, isolated from the required tabular/JSON exports.
    try
        if isfield(R.material,'value')&&isfield(R.material.value,'tables')
            T=R.material.value.tables.component_flows;
            fig=figure('Visible','off','Color','w'); clean=onCleanup(@()close(fig));
            bar(categorical(T.ComponentOrLedger),T.Flow_kg_day);
            ylabel('kg/day'); title('ENERGY-008 stoichiometric reference component/ledger flows'); grid on;
            pngPath=fullfile(outDir,'reference_mass_flows.png'); assertNewFile(pngPath);
            print(fig,pngPath,'-dpng','-r150'); clear clean; files{end+1}='reference_mass_flows.png';
        end
    catch PNGME
        optionalFailures{end+1}=['Optional PNG export not created: ' PNGME.message]; %#ok<AGROW>
    end
    warnings=optionalFailures;
    summary=struct('project_id','ENERGY-008','run_id',modelInput.run_id,'case_id',modelInput.case_data.case_id, ...
        'case_status',modelInput.case_data.case_status,'model_versions',modelInput.versions, ...
        'source_files',modelInput.source_files,'source_hashes',modelInput.source_hashes, ...
        'module_statuses',moduleStatusStruct(R),'material_reference',summaryMaterial(R.material), ...
        'energy_reference',summaryEnergy(R.energy),'equipment_screening',summaryEquipment(R.equipment), ...
        'control_screening',summaryControl(R.control),'scenario_interpretation',R.scenarios.value.interpretation, ...
        'important_limitations',{{'S-209 recycle and S-207 purge are BLOCKED_NOT_COMPUTED.', ...
        'R-301 PFR kinetics, PR78 flash, methanol-water VLE, physical stream properties and distillation remain BLOCKED.', ...
        'Plant energy, entropy/exergy, actual utilities, environmental MRV, and CAPEX/OPEX/LCOM remain BLOCKED where inputs are missing.', ...
        'This is not a validated process model. Prompt 21 independent verification and validation remain required.'}}, ...
        'runtime_verification','MATLAB_RUNTIME_EXECUTED_AT_REPORT_GENERATION', ...
        'matlab_version',version,'matlab_release',version('-release'),'computer',computer, ...
        'physical_flowsheet_validated',false,'prompt21_validation_required',true, ...
        'export_files',{[files,{'run_summary.json','module_diagnostics.json'}]});
    summaryPath=fullfile(outDir,'run_summary.json'); writeText(summaryPath,jsonencode(summary)); files{end+1}='run_summary.json';
    diagnostics=struct('run_id',modelInput.run_id,'module_records',collectModuleRecords(R), ...
        'optional_export_failures',{optionalFailures},'physical_flowsheet_validated',false, ...
        'prompt21_validation_required',true);
    diagPath=fullfile(outDir,'module_diagnostics.json'); writeText(diagPath,jsonencode(diagnostics)); files{end+1}='module_diagnostics.json';
    values=struct('output_directory',outDir,'files',{files},'summary_json',summaryPath, ...
        'diagnostics_json',diagPath,'optional_export_failures',{optionalFailures});
    result=energy008.make_result('reporting_plots','CALCULATED',values,'file paths',modelInput,warnings,{},struct(), ...
        struct('source_ids',{{modelInput.fixture.fixture_id}}));
catch ME
    err=struct('identifier',ME.identifier,'message',ME.message);
    result=energy008.make_result('reporting_plots','FAILED',struct('output_directory',outDir),'N/A',modelInput,{}, {err},struct(),struct());
    result.diagnostics=energy008.diagnostic(ME.identifier,'ERROR','reporting_plots',ME.message, ...
        struct('output_directory',outDir),{},'Check write permissions and ensure no prior run directory is reused.');
end
end
function s=moduleStatusStruct(R)
n=fieldnames(R); s=struct();
for k=1:numel(n)
    x=R.(n{k}); if isstruct(x)&&isscalar(x)&&isfield(x,'status')&&ischar(x.status), s.(n{k})=x.status; end
end
end
function D=collectModuleRecords(R)
n=fieldnames(R); D=struct([]);
for k=1:numel(n)
    x=R.(n{k});
    if isstruct(x)&&isscalar(x)&&isfield(x,'module_id')
        q=struct('module_id',x.module_id,'status',x.status,'warnings',{x.warnings}, ...
            'errors',{x.errors},'failure_codes',{x.failure_codes},'diagnostics',x.diagnostics, ...
            'input_versions',x.input_versions,'provenance',x.provenance,'residuals',x.residuals);
        if isempty(D),D=q;else,D(end+1)=q;end %#ok<AGROW>
    end
end
end
function writeTable(T,p)
assertNewFile(p);
if ~istable(T), error('ENERGY008:ExportNotTable','Expected a MATLAB table for export: %s',p); end
writetable(T,p);
end
function writeText(p,t)
assertNewFile(p); f=fopen(p,'w'); if f<0,error('ENERGY008:ExportOpenFailed','Cannot write %s.',p);end
cl=onCleanup(@()fclose(f)); fwrite(f,t,'char'); fprintf(f,'\n'); clear cl;
end
function assertNewFile(p)
if exist(p,'file')==2,error('ENERGY008:ExportOverwrite','Refusing to overwrite existing result file: %s',p);end
end
function s=summaryMaterial(r)
s=struct('status',r.status);
if isfield(r,'value')&&isfield(r.value,'mass_flows'),s.mass_flows=r.value.mass_flows;s.molar_flows=r.value.molar_flows;s.mass_balance=r.value.mass_balance;s.element_residual_kmol_atoms_day=r.value.element_residual_kmol_atoms_day;end
end
function s=summaryEnergy(r)
s=struct('status',r.status);
if isfield(r,'value')&&isfield(r.value,'reaction_reference'),s.reaction_reference=r.value.reaction_reference;s.plant_energy_closure=r.value.plant_energy_closure;s.CO2_sensible_kW=r.value.co2_sensible_heating.duty_kW;s.methanol_latent_kW=r.value.methanol_latent_reference.duty_kW;end
end
function s=summaryEquipment(r)
s=struct('status',r.status);
if isfield(r,'value')&&isfield(r.value,'HX_example'),s.HX_area_m2=r.value.HX_example.area_m2;s.W201_pump_power_kW=r.value.W201_pump_example.shaft_power_kW;end
end
function s=summaryControl(r)
s=struct('status',r.status);
if isfield(r,'value')&&isfield(r.value,'screening_h2_deficit_kg'),s.DB059_H2_deficit_kg=r.value.screening_h2_deficit_kg;end
end
function tf=withinRoot(root,candidate)
[ok1,a]=fileattrib(root);[ok2,b]=fileattrib(candidate);if ok1,root=char(a.Name);end;if ok2,candidate=char(b.Name);end
pre=[root filesep];if ispc,tf=strcmpi(candidate,root)||strncmpi(candidate,pre,numel(pre));else,tf=strcmp(candidate,root)||strncmp(candidate,pre,numel(pre));end
end
