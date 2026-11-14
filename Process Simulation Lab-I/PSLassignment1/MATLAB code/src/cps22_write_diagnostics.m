function cps22_write_diagnostics(filePath, validation, flash, ref, balance, equipment, energy, utilities, economics)
% Write a human-readable run record; preserves known model and data limitations.
fid=fopen(filePath,'w'); if fid<0, error('CPS22:WriteFailed','Cannot write diagnostics file: %s',filePath); end
cleanup=onCleanup(@() fclose(fid));
fprintf(fid,'# CPS-22 MATLAB Run Diagnostics\n\n');
fprintf(fid,'Run timestamp: %s\n\n',char(datetime('now','Format','yyyy-MM-dd HH:mm:ss')));
fprintf(fid,'## Input validation\n\nValid: %s\n\n',string(validation.valid));
for i=1:numel(validation.warnings), fprintf(fid,'- Warning: %s\n',char(validation.warnings(i))); end
for i=1:numel(validation.errors), fprintf(fid,'- Error: %s\n',char(validation.errors(i))); end
fprintf(fid,'\n## Experimental reference interpolation\n\nStatus: `%s`\nTemperature: %.12g K\nPressure: %.12g Pa\nVapour fraction: %.12g\n', ...
    ref.status,ref.T_K,ref.P_Pa,ref.beta);
fprintf(fid,'Liquid ethanol x1: %.12g\nVapour ethanol y1: %.12g\nLiquid flow: %.12g kmol/h\nVapour flow: %.12g kmol/h\n\n', ...
    ref.x(1),ref.y(1),ref.L_kmol_h,ref.V_kmol_h);
fprintf(fid,'This is an interpolation fixture from experimental reference data, not an NRTL-SRK prediction.\n\n');
fprintf(fid,'## NRTL-SRK flash diagnostic\n\nStatus: `%s`\nModel acceptance: `%s`\nSolver exit flag: %d\nObjective: %.12g\nMaximum absolute log-fugacity residual: %.12g\nAbsolute ethanol balance residual: %.12g\nMessage: %s\n\n', ...
    flash.status,flash.model_acceptance,flash.solver_exit_flag,flash.objective, ...
    flash.max_abs_log_fugacity_residual,flash.abs_ethanol_balance_residual,flash.message);
for i=1:numel(flash.warnings), fprintf(fid,'- Warning: %s\n',char(flash.warnings(i))); end
fprintf(fid,'\n## Downstream module status\n\n');
fprintf(fid,'Material balance: `%s`; total closure %.12g mol/s; max component closure %.12g mol/s.\n\n', ...
    balance.status,balance.total_closure_mol_s,balance.max_abs_component_closure_mol_s);
fprintf(fid,'Equipment: `%s`; %s\n\n',equipment.status,equipment.warning);
fprintf(fid,'Energy: `%s`; %s\n\n',energy.status,energy.reason);
fprintf(fid,'Utilities: `%s`; %s\n\n',utilities.status,utilities.reason);
fprintf(fid,'Economics: `%s`; %s\n\n',economics.status,economics.reason);
fprintf(fid,'## Interpretation\n\n');
fprintf(fid,'The software distinguishes numerical execution from scientific acceptance. The candidate NRTL parameter set and SRK kij are not accepted for predictive high-pressure use; the global phase stability calculation is not implemented; enthalpy, utility and cost methods remain blocked. Do not use this run for final process design until those items are resolved.\n');
end
