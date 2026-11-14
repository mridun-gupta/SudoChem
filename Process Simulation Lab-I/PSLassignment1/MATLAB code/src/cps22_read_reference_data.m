function D = cps22_read_reference_data(dataFile)
% CPS22_READ_REFERENCE_DATA Read ethanol-water reference VLE CSV without readtable header inference.
% Canonical output fields:
%   source_id, source_table, pressure_Pa, pressure_kPa, temperature_K,
%   x_ethanol_mole_fraction, y_ethanol_mole_fraction,
%   x_water_mole_fraction, y_water_mole_fraction, data_type
%
% R4 intentionally parses the actual CSV header and records itself. This avoids
% release/locale-dependent VariableNamingRule behaviour that can create Var1...VarN.
% It does not turn experimental data into an NRTL-SRK prediction.

if nargin < 1 || isempty(dataFile)
    error('CPS22:MissingReferenceDataPath', 'No reference CSV was supplied. Use cfg.paths.reference_data_abs.');
end
dataFile = char(string(dataFile));
if ~isfile(dataFile)
    error('CPS22:MissingReferenceData', 'Required reference CSV not found: %s', dataFile);
end
rawText = fileread(dataFile);
rawText = strrep(rawText, char(65279), ''); % remove UTF-8 BOM if present
lines = regexp(rawText, '\r\n|\n|\r', 'split');

headerLine = 0; headerFields = {}; names = {};
for k = 1:numel(lines)
    line = strtrim(lines{k});
    if isempty(line) || startsWith(line, '#') || startsWith(line, '%'), continue; end
    fields = splitCsvRecord(line);
    normNames = cell(size(fields));
    for j = 1:numel(fields), normNames{j} = normaliseHeader(fields{j}); end
    if isCanonicalOrCompatibleHeader(normNames)
        headerLine = k; headerFields = fields; names = normNames; break;
    end
end
if headerLine == 0
    preview = lines(~cellfun(@(s) isempty(strtrim(s)), lines));
    preview = preview(1:min(4,numel(preview)));
    error('CPS22:ReferenceHeaderNotFound', ...
        ['The selected reference file has no recognisable CSV header: %s\n' ...
         'The R4 run uses the bundled canonical file: data/CPS22_reference_vle_expanded.csv.\n' ...
         'First non-empty lines:\n%s\n' ...
         'Do not use a legacy spreadsheet export that MATLAB imports as Var1, Var2, ... .'], ...
         dataFile, strjoin(preview, newline));
end
nCols = numel(headerFields);

% Required and optional field indices. Pressure units must be explicit.
iPa  = findHeader(names, {'pressurepa','ppa','pressurepascal','pressureabspa','pabspa'});
iKPa = findHeader(names, {'pressurekpa','pkpa','pressurekilopascal','pressurekilopascals','pressureabskpa','pabskpa'});
iMPa = findHeader(names, {'pressurempa','pmpa','pressuremegapascal','pressuremegapascals','pressureabsmpa'});
iBar = findHeader(names, {'pressurebar','pbar','pressurebara','pressurebarabs','pressureabsbar','pressurebarabsolute'});
iTK  = findHeader(names, {'temperaturek','tempk','temperaturekelvin','tk','tkelvin'});
iTC  = findHeader(names, {'temperaturec','tempc','temperaturecelsius','tcelsius'});
iT   = findHeader(names, {'temperature','temp'});
iX   = findHeader(names, {'xethanolmolefraction','xethanolmolefrac','xethanolmolfrac','xethanol','liquidethanolmolefraction','xliquidethanol','x1'});
iY   = findHeader(names, {'yethanolmolefraction','yethanolmolefrac','yethanolmolfrac','yethanol','vaporethanolmolefraction','vapourethanolmolefraction','y1'});
iXw  = findHeader(names, {'xwatermolefraction','xwatermolefrac','xwater','liquidwatermolefraction','x2'});
iYw  = findHeader(names, {'ywatermolefraction','ywatermolefrac','ywater','vaporwatermolefraction','vapourwatermolefraction','y2'});
iType= findHeader(names, {'datatype','dataclass','pointtype','recordtype','kind'});
iSid = findHeader(names, {'sourceid','source','datasetid','citationid'});
iTab = findHeader(names, {'sourcetable','tableid','tablenumber'});

if iPa==0 && iKPa==0 && iMPa==0 && iBar==0
    error('CPS22:ReferencePressureUnitUnknown','Header in %s has no explicit pressure unit. Headers: %s', dataFile, strjoin(headerFields, ', '));
end
if iTK==0 && iTC==0 && iT==0
    error('CPS22:ReferenceTemperatureColumnMissing','No temperature column in %s. Headers: %s', dataFile, strjoin(headerFields, ', '));
end
if iX==0 || iY==0
    error('CPS22:ReferenceCompositionColumnMissing','No ethanol x/y columns in %s. Headers: %s', dataFile, strjoin(headerFields, ', '));
end

records = cell(0,nCols);
for k = headerLine+1:numel(lines)
    line = strtrim(lines{k});
    if isempty(line) || startsWith(line, '#') || startsWith(line, '%'), continue; end
    row = splitCsvRecord(line);
    if isempty(row) || isRecognisedHeader(row), continue; end
    if numel(row) > nCols
        % Some source exporters omit quotes around a citation with commas.
        row = [row(1:nCols-1), {strjoin(row(nCols:end), ',')}];
    elseif numel(row) < nCols
        row(end+1:nCols) = {''};
    end
    records(end+1,:) = row(1:nCols); %#ok<AGROW>
end
if isempty(records)
    error('CPS22:EmptyReferenceData','CSV header found but no data records follow in %s.',dataFile);
end

% Parse pressure to kPa and Pa, checking both if supplied.
if iKPa > 0
    pressure_kPa = numericColumn(records, iKPa, headerFields{iKPa});
elseif iPa > 0
    pressure_kPa = numericColumn(records, iPa, headerFields{iPa}) ./ 1000;
elseif iMPa > 0
    pressure_kPa = numericColumn(records, iMPa, headerFields{iMPa}) .* 1000;
else
    pressure_kPa = numericColumn(records, iBar, headerFields{iBar}) .* 100;
end
pressure_Pa = pressure_kPa .* 1000;
if iPa > 0 && iKPa > 0
    pressurePaReported = numericColumn(records, iPa, headerFields{iPa});
    if any(abs(pressurePaReported-pressure_Pa) > max(1e-2, 1e-8*max(abs(pressure_Pa))))
        error('CPS22:PressureUnitConflict','pressure_Pa and pressure_kPa disagree in %s.', dataFile);
    end
end

if iTK > 0
    temperature_K = numericColumn(records, iTK, headerFields{iTK});
elseif iTC > 0
    temperature_K = numericColumn(records, iTC, headerFields{iTC}) + 273.15;
else
    t = numericColumn(records, iT, headerFields{iT});
    if median(t) < 150
        temperature_K = t + 273.15;
        warning('CPS22:AssumedTemperatureCelsius','Unqualified temperature column assumed Celsius by numeric range.');
    else
        temperature_K = t;
        warning('CPS22:AssumedTemperatureKelvin','Unqualified temperature column assumed Kelvin by numeric range.');
    end
end
xE = numericColumn(records, iX, headerFields{iX});
yE = numericColumn(records, iY, headerFields{iY});
if iXw > 0, xW = numericColumn(records,iXw,headerFields{iXw}); else, xW = 1-xE; end
if iYw > 0, yW = numericColumn(records,iYw,headerFields{iYw}); else, yW = 1-yE; end
n = size(records,1);
if iType > 0
    dataType = lower(strtrim(string(columnText(records,iType))));
else
    dataType = repmat("experimental_measurement",n,1);
    warning('CPS22:ReferenceDataTypeMissing','No data_type column; rows are tagged experimental_measurement because this is the designated reference dataset.');
end
if iSid > 0, sourceId = string(columnText(records,iSid)); else, sourceId = repmat("UNSPECIFIED_SOURCE",n,1); end
if iTab > 0, sourceTable = string(columnText(records,iTab)); else, sourceTable = repmat("UNSPECIFIED_TABLE",n,1); end

allNums = [pressure_Pa(:); pressure_kPa(:); temperature_K(:); xE(:); yE(:); xW(:); yW(:)];
if any(~isfinite(allNums)), error('CPS22:InvalidReferenceData','Non-finite required values in %s.',dataFile); end
if any(pressure_Pa<=0) || any(temperature_K<=0), error('CPS22:InvalidReferenceData','Pressure and temperature must be positive absolute values.'); end
if any([xE;xW;yE;yW] < 0 | [xE;xW;yE;yW] > 1), error('CPS22:InvalidReferenceComposition','Reference mole fractions must be in [0,1].'); end
if any(abs(xE+xW-1)>0.02) || any(abs(yE+yW-1)>0.02)
    error('CPS22:InvalidReferenceCompositionClosure','Reference binary compositions fail closure tolerance 0.02.');
end
D = table(sourceId(:),sourceTable(:),pressure_Pa(:),pressure_kPa(:),temperature_K(:), ...
    xE(:),yE(:),xW(:),yW(:),dataType(:), ...
    'VariableNames',{'source_id','source_table','pressure_Pa','pressure_kPa','temperature_K', ...
    'x_ethanol_mole_fraction','y_ethanol_mole_fraction','x_water_mole_fraction','y_water_mole_fraction','data_type'});
end

function tf = isCanonicalOrCompatibleHeader(names)
tf = findHeader(names,{'pressurepa','ppa','pressurepascal','pressurekpa','pkpa','pressurempa','pmpa','pressurebar','pbar'})>0 && ...
     findHeader(names,{'temperaturek','tempk','temperaturekelvin','temperaturec','tempc','temperature','temp'})>0 && ...
     findHeader(names,{'xethanolmolefraction','xethanolmolefrac','xethanolmolfrac','xethanol','liquidethanolmolefraction','xliquidethanol','x1'})>0 && ...
     findHeader(names,{'yethanolmolefraction','yethanolmolefrac','yethanolmolfrac','yethanol','vaporethanolmolefraction','vapourethanolmolefraction','y1'})>0;
end
function tf = isRecognisedHeader(fields)
if isempty(fields), tf=false; return; end
names=cell(size(fields)); for k=1:numel(fields), names{k}=normaliseHeader(fields{k}); end
tf=isCanonicalOrCompatibleHeader(names);
end
function idx=findHeader(names,aliases)
idx=find(ismember(names,aliases),1,'first'); if isempty(idx),idx=0;end
end
function name=normaliseHeader(name)
name=strrep(char(name),char(65279),'');
name=lower(regexprep(strtrim(name),'[^A-Za-z0-9]',''));
end
function vals=numericColumn(records,idx,label)
vals=nan(size(records,1),1);
for r=1:size(records,1), vals(r)=str2double(strtrim(records{r,idx})); end
if any(~isfinite(vals)), bad=find(~isfinite(vals),1,'first'); error('CPS22:InvalidReferenceColumn','Column "%s" has nonnumeric data at row %d.',label,bad); end
end
function vals=columnText(records,idx)
vals=cell(size(records,1),1); for r=1:size(records,1), vals{r}=records{r,idx}; end
end
function fields=splitCsvRecord(line)
% RFC-4180 single-line parser, including quoted commas and doubled quotes.
line=char(line); fields={}; field=''; inQuotes=false; i=1;
while i<=numel(line)
    c=line(i);
    if c=='"'
        if inQuotes && i<numel(line) && line(i+1)=='"'
            field=[field '"']; i=i+1; %#ok<AGROW>
        else
            inQuotes=~inQuotes;
        end
    elseif c==',' && ~inQuotes
        fields{end+1}=field; field=''; %#ok<AGROW>
    else
        field(end+1)=c; %#ok<AGROW>
    end
    i=i+1;
end
fields{end+1}=field;
end
