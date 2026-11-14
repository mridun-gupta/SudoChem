function P = cps22_find_project_files(startHint)
% CPS22_FIND_PROJECT_FILES Resolve only the project containing this source tree.
% R4 does not search unrelated sibling folders, which could select stale copies.
if nargin < 1 || isempty(startHint)
    here = fileparts(mfilename('fullpath'));
    root = fileparts(here);
else
    startHint = char(string(startHint));
    if isfile(startHint), startHint = fileparts(startHint); end
    if isfolder(startHint), root = startHint; else, root = fileparts(startHint); end
end
[root,ok] = canonicalExistingFolder(root);
if ~ok || ~isfile(fullfile(root,'CPS22_PROJECT_VERSION.txt')) || ...
        ~isfile(fullfile(root,'main.m')) || ~isfile(fullfile(root,'data','default_case.json')) || ...
        ~isfile(fullfile(root,'data','CPS22_reference_vle_expanded.csv')) || ...
        ~isfile(fullfile(root,'src','cps22_load_config.m'))
    error('CPS22:IncompleteProjectRoot', ...
        ['The current root is not a complete CPS-22 R4 project. Start START_HERE.m from the ' ...
         'extracted CPS-22_Industrial_MATLAB_R4 folder. Root checked: %s'], root);
end
P=struct(); P.root=root;
P.main_file=fullfile(root,'main.m');
P.launcher_file=fullfile(root,'CPS22_Launcher.m');
P.config_file=fullfile(root,'data','default_case.json');
P.reference_data=fullfile(root,'data','CPS22_reference_vle_expanded.csv');
P.legacy_compatibility_data=fullfile(root,'data','validation_reference_data.csv');
P.src_dir=fullfile(root,'src'); P.gui_dir=fullfile(root,'gui'); P.tests_dir=fullfile(root,'tests');
P.data_dir=fullfile(root,'data'); P.validation_dir=fullfile(root,'validation');
P.results_dir=fullfile(root,'results'); P.plot_dir=fullfile(P.results_dir,'plots');
P.model_comparison_data=fullfile(root,'validation','phase2_model_comparison_reference.csv');
P.property_register=fullfile(root,'data','CPS-22_NIST_and_Property_Register.csv');
P.source_register=fullfile(root,'data','CPS22_source_register.csv');
P.discovery=table(["project_root";"config_file";"canonical_reference_data"], ...
    [string(P.root);string(P.config_file);string(P.reference_data)], ...
    'VariableNames',{'resource','resolved_path'});
end
function [p,ok]=canonicalExistingFolder(p)
ok=isfolder(p); if ~ok, return; end
try, [~,a]=fileattrib(p); p=a.Name; catch, end
end
