function test_package_integrity()
% Verify required R4 files and runtime resolution before scientific calculations.
root=fileparts(fileparts(mfilename('fullpath')));
required={ 'CPS22_PROJECT_VERSION.txt','main.m','START_HERE.m','CPS22_Launcher.m', ...
 'data/default_case.json','data/CPS22_reference_vle_expanded.csv','src/cps22_read_reference_data.m', ...
 'src/cps22_load_config.m','src/cps22_reference_flash.m','validation/phase2_model_comparison_reference.csv'};
for k=1:numel(required), assert(isfile(fullfile(root,required{k})),'Required package file missing: %s',required{k}); end
P=cps22_find_project_files(root); assert(strcmpi(P.root,root),'Project discovery selected a different directory.');
assert(contains(which('cps22_read_reference_data'),fullfile(root,'src')),'Data reader resolves from outside R4.');
fprintf('R4 package-integrity checks passed.\n');
end
