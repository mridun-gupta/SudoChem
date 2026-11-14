function T = cps22_model_comparison(referenceCsv)
% Import the Phase 2 literature-reported azeotrope comparison without relabeling
% literature model outputs as an independent implementation.
if nargin < 1 || isempty(referenceCsv)
    projectRoot=fileparts(fileparts(mfilename('fullpath')));
    referenceCsv=fullfile(projectRoot,'validation','phase2_model_comparison_reference.csv');
end
if ~isfile(referenceCsv), error('CPS22:MissingModelComparison','Reference model comparison CSV not found.'); end
T=readtable(referenceCsv);
T.implementation_status=repmat("LITERATURE_REPORTED_NOT_RECOMPUTED",height(T),1);
T.acceptance_note=repmat("Not an independent PRSV/PRSV-WS implementation; target NRTL-SRK remains not accepted.",height(T),1);
end
