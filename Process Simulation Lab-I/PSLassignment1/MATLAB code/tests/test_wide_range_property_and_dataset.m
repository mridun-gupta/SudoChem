function test_wide_range_property_and_dataset()
% Basic regression checks for piecewise NIST data and the experimental dataset.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(root,'-begin'); addpath(fullfile(root,'src'),'-begin');
cfg=cps22_load_config(fullfile(root,'data','default_case.json'));
D=cps22_read_reference_data(fullfile(root,'data','CPS22_reference_vle_expanded.csv'));
assert(height(D)==207,'Expected 207 bundled experimental VLE records.');
assert(isequal(sort(unique(round(D.pressure_kPa))),[100;101;300;500;700;1500;2000]),'Unexpected experimental isobars.');
for T=[300,350,400,445,500]
 try, ps=cps22_antoine_psat(T,cfg); assert(all(isfinite(ps)&ps>0)); catch ME
    if strcmp(ME.identifier,'CPS22:AntoineOutOfRange'), continue; else, rethrow(ME); end
 end
end
fprintf('Wide-range data/property checks passed (subject to NIST segment availability).\n');
end
