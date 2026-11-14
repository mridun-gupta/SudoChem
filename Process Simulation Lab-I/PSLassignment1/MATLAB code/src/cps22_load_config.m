function cfg = cps22_load_config(configFile)
% CPS22_LOAD_CONFIG Load configuration and bind all paths to one project root.
% No absolute paths are stored in JSON. The canonical data filename is fixed
% for the standard R4 case so an old malformed CSV cannot be selected silently.
if nargin<1 || isempty(configFile)
    root=fileparts(fileparts(mfilename('fullpath')));
    configFile=fullfile(root,'data','default_case.json');
else
    configFile=char(string(configFile));
    if ~isfile(configFile)
        root=fileparts(fileparts(mfilename('fullpath')));
        candidate=fullfile(root,strrep(configFile,'/',filesep));
        if isfile(candidate), configFile=candidate; else, error('CPS22:MissingConfig','Config not found: %s',configFile); end
    end
    [ok,a]=fileattrib(configFile); if ok,configFile=a.Name;end
    root=fileparts(fileparts(configFile));
end
if ~isfile(fullfile(root,'CPS22_PROJECT_VERSION.txt'))
    error('CPS22:WrongProjectRoot','The selected configuration is not inside a complete R4 project: %s',configFile);
end
try
    cfg=jsondecode(fileread(configFile));
catch ME
    error('CPS22:InvalidConfigJSON','Cannot decode %s: %s',configFile,ME.message);
end
P=cps22_find_project_files(root);
cfg.paths.project_root=P.root; cfg.paths.config_file=P.config_file;
cfg.paths.reference_data_abs=P.reference_data;
cfg.paths.legacy_reference_data_abs=P.legacy_compatibility_data;
cfg.paths.results_dir_abs=P.results_dir; cfg.paths.plot_dir_abs=P.plot_dir;
cfg.paths.model_comparison_data_abs=P.model_comparison_data;
cfg.paths.property_register_abs=P.property_register; cfg.paths.source_register_abs=P.source_register;
cfg.paths.gui_dir_abs=P.gui_dir; cfg.paths.tests_dir_abs=P.tests_dir;
cfg.paths.discovery_summary=P.discovery;
if ~isfile(cfg.paths.reference_data_abs)
    error('CPS22:CanonicalReferenceMissing','Required file missing: %s',cfg.paths.reference_data_abs);
end
end
