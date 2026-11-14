function test_reference_data_header_variants()
% Regression test: CSV parsing must not depend on readtable's Var1...VarN inference.
projectRoot=fileparts(fileparts(mfilename('fullpath'))); canonical=fullfile(projectRoot,'data','CPS22_reference_vle_expanded.csv');
D=cps22_read_reference_data(canonical);
assert(height(D)==207,'Expanded canonical reference dataset row count changed.');
assert(all(ismember({'pressure_kPa','temperature_K','x_ethanol_mole_fraction','y_ethanol_mole_fraction'},D.Properties.VariableNames)), ...
    'Canonical variable names not produced.');
assert(isequal(sort(unique(round(D.pressure_kPa))),[100;101;300;500;700;1500;2000]),'Reference isobar set changed.');
% Also test aliases, leading comment, quoted fields and pressure/temperature conversion.
tmp=[tempname '.csv']; cleanup=onCleanup(@() deleteIfPresent(tmp));
fid=fopen(tmp,'wt'); assert(fid>0,'Could not create temporary CSV test file.');
fprintf(fid,'# temporary test file\nPressure (MPa),Temperature (C),x_ethanol,y_ethanol,data_type,source_id\n');
fprintf(fid,'0.1,80,0.20,0.30,experimental_measurement,"test, source"\n');
fprintf(fid,'0.1,81,0.25,0.35,experimental_measurement,test2\n');
fprintf(fid,'0.1,82,0.30,0.40,experimental_measurement,test3\n'); fclose(fid);
Q=cps22_read_reference_data(tmp);
assert(height(Q)==3 && abs(Q.pressure_kPa(1)-100)<1e-12,'MPa to kPa conversion failed.');
assert(abs(Q.temperature_K(1)-353.15)<1e-10,'Celsius to Kelvin conversion failed.');
assert(strcmp(Q.source_id(1),"test, source"),'Quoted comma parsing failed.');
% Malformed/unnamed Var1-style input must produce the intended helpful header error.
fid=fopen(tmp,'wt'); fprintf(fid,'Var1,Var2,Var3\n1,2,3\n4,5,6\n'); fclose(fid);
caught=false; try, cps22_read_reference_data(tmp); catch ME, caught=strcmp(ME.identifier,'CPS22:ReferenceHeaderNotFound'); end
assert(caught,'Malformed CSV should fail early with CPS22:ReferenceHeaderNotFound.');
clear cleanup;
fprintf('Reference-data parser regression tests passed.\n');
end
function deleteIfPresent(p), if isfile(p), delete(p); end, end
