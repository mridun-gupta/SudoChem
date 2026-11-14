function [catalog, warnings] = resolve_project_data(projectRoot, manifest, allowedRoots, allowedFormats, verifyHashes)
%RESOLVE_PROJECT_DATA Resolve manifest entries only inside configured data roots.
% Explicit path -> exact filename -> optional declared regex. Ambiguity is fatal.

catalog = struct([]);
warnings = {};
for k = 1:numel(manifest.datasets)
    ds = manifest.datasets(k);
    required = logical(ds.required);
    explicitPath = char(ds.explicit_path);
    exactName = char(ds.exact_filename);
    expectedFormat = ['.' lower(char(ds.format))];
    if ~any(strcmpi(allowedFormats, expectedFormat))
        error('ENERGY008:UnsupportedFormat', 'Dataset %s declares unsupported format %s. Allowed: %s', ...
            char(ds.dataset_id), expectedFormat, strjoin(allowedFormats, ', '));
    end

    resolved = '';
    % 1) Explicit manifest path. The path is always interpreted relative to project root.
    if ~isempty(explicitPath)
        p = resolveRootRelative(projectRoot, explicitPath);
        if exist(p, 'file') == 2
            if ~withinConfiguredRoots(projectRoot, p, allowedRoots)
                error('ENERGY008:DataOutsideAllowedRoots', 'Explicit data path is outside configured data roots: %s', p);
            end
            resolved = p;
        end
    end

    % 2) Exact filename search, only in configured roots.
    if isempty(resolved) && ~isempty(exactName)
        matches = {};
        for r = 1:numel(allowedRoots)
            rootPath = resolveRootRelative(projectRoot, char(allowedRoots{r}));
            found = recursiveFind(rootPath, rootPath, exactName, 'exact', '');
            matches = [matches, found]; %#ok<AGROW>
        end
        matches = unique(matches, 'stable');
        if numel(matches) > 1
            error('ENERGY008:DataAmbiguous', 'Dataset %s has multiple exact filename matches. Choose one and update the manifest:\n%s', ...
                char(ds.dataset_id), strjoin(matches, char(10)));
        elseif numel(matches) == 1
            resolved = matches{1};
        end
    end

    % 3) Optional, explicitly documented regex fallback. It must resolve exactly one file.
    if isempty(resolved) && isfield(ds, 'match_regex') && ~isempty(ds.match_regex)
        pattern = char(ds.match_regex);
        if ~isfield(ds, 'match_rule_description') || isempty(ds.match_rule_description)
            error('ENERGY008:UndocumentedMatchRule', 'Dataset %s declares regex matching without a documented rule.', char(ds.dataset_id));
        end
        matches = {};
        for r = 1:numel(allowedRoots)
            rootPath = resolveRootRelative(projectRoot, char(allowedRoots{r}));
            found = recursiveFind(rootPath, rootPath, '', 'regex', pattern);
            matches = [matches, found]; %#ok<AGROW>
        end
        matches = unique(matches, 'stable');
        if numel(matches) > 1
            error('ENERGY008:DataAmbiguous', 'Dataset %s regex matched multiple files. Choose one and update the manifest:\n%s', ...
                char(ds.dataset_id), strjoin(matches, char(10)));
        elseif numel(matches) == 1
            resolved = matches{1};
        end
    end

    if isempty(resolved)
        if required
            error('ENERGY008:DataMissing', 'Required dataset %s (%s) was not found. Checked explicit path, exact filename and any declared regex within: %s', ...
                char(ds.dataset_id), exactName, strjoin(toCellText(allowedRoots), ', '));
        else
            warnings{end+1} = sprintf('Optional dataset %s was not found.', char(ds.dataset_id)); %#ok<AGROW>
            continue;
        end
    end

    [~,~,ext] = fileparts(resolved);
    if ~strcmpi(ext, expectedFormat)
        error('ENERGY008:UnsupportedFormat', 'Dataset %s resolved to %s, but manifest declares %s.', char(ds.dataset_id), ext, expectedFormat);
    end
    if ~withinConfiguredRoots(projectRoot, resolved, allowedRoots)
        error('ENERGY008:DataOutsideAllowedRoots', 'Resolved file is outside configured data roots: %s', resolved);
    end
    actualHash = sha256_file(resolved);
    expectedHash = char(ds.expected_sha256);
    if verifyHashes && ~isempty(expectedHash) && ~strcmpi(actualHash, expectedHash)
        error('ENERGY008:HashMismatch', 'SHA-256 mismatch for %s. Expected %s; found %s. Restore the controlled source or revise the manifest under change control.', ...
            resolved, expectedHash, actualHash);
    end
    validateDeclaredSchema(resolved,expectedFormat,ds);

    item = struct('dataset_id',char(ds.dataset_id), 'logical_name',char(ds.logical_name), ...
        'resolved_path',resolved, 'format',expectedFormat, 'role',char(ds.role), ...
        'schema_id',char(ds.schema_id), 'source_version',char(ds.source_version), ...
        'sha256',actualHash, 'required',required, 'required_sheets',{toCellText(ds.required_sheets)});
    if isempty(catalog), catalog = item; else, catalog(end+1) = item; end %#ok<AGROW>
end
end

function found = recursiveFind(folder, allowedRoot, exactName, mode, pattern)
found = {};
if exist(folder, 'dir') ~= 7 || ~withinOneRoot(allowedRoot, folder), return; end
items = dir(folder);
for n=1:numel(items)
    name = items(n).name;
    if strcmp(name,'.') || strcmp(name,'..'), continue; end
    full = fullfile(folder,name);
    if items(n).isdir
        child = recursiveFind(full, allowedRoot, exactName, mode, pattern);
        found = [found, child]; %#ok<AGROW>
    else
        if strcmp(mode,'exact') && strcmp(name,exactName)
            found{end+1}=full; %#ok<AGROW>
        elseif strcmp(mode,'regex') && ~isempty(regexp(name,pattern,'once'))
            found{end+1}=full; %#ok<AGROW>
        end
    end
end
end

function tf = withinOneRoot(rootPath, candidate)
[okR, ar] = fileattrib(rootPath); if okR, r = char(ar.Name); else, r = rootPath; end
[okC, ac] = fileattrib(candidate); if okC, c = char(ac.Name); else, c = candidate; end
prefix = [r filesep];
if ispc, tf = strcmpi(c,r) || strncmpi(c,prefix,numel(prefix));
else, tf = strcmp(c,r) || strncmp(c,prefix,numel(prefix)); end
end

function values = toCellText(value)
if iscell(value)
    values = cell(size(value));
    for q=1:numel(value), values{q}=char(value{q}); end
elseif isstring(value)
    values=cellstr(value);
elseif ischar(value)
    values={value};
elseif isempty(value)
    values={};
else
    error('ENERGY008:ManifestTypeInvalid','Expected a string list in manifest.');
end
end

function tf = withinConfiguredRoots(projectRoot, candidate, allowedRoots)
tf = false;
[okC, ac] = fileattrib(candidate); if okC, c = char(ac.Name); else, c = candidate; end
for k=1:numel(allowedRoots)
    rootPath=resolveRootRelative(projectRoot,char(allowedRoots{k}));
    [okR,ar]=fileattrib(rootPath); if okR, r=char(ar.Name); else, r=rootPath; end
    prefix=[r filesep];
    if ispc
        hit=strcmpi(c,r) || strncmpi(c,prefix,numel(prefix));
    else
        hit=strcmp(c,r) || strncmp(c,prefix,numel(prefix));
    end
    if hit, tf=true; return; end
end
end

function p = resolveRootRelative(root, rel)
rel=strrep(char(rel),char(92),'/');
parts=strsplit(rel,'/');
if isempty(rel) || rel(1)=='/' || ~isempty(regexp(rel,'^[A-Za-z]:','once')) || any(strcmp(parts,'..'))
    error('ENERGY008:UnsafeRelativePath','Path must be project-relative and contain no parent traversal: %s',rel);
end
p=fullfile(root,rel);
end


function validateDeclaredSchema(path,format,ds)
% Validate the format-specific, project-declared structure without guessing.
fmt=lower(char(format));
if strcmp(fmt,'.json')
    try, obj=jsondecode(fileread(path)); catch ME
        error('ENERGY008:JSONInvalid','JSON dataset %s is invalid: %s',char(ds.dataset_id),ME.message);
    end
    if ~isstruct(obj) || ~isscalar(obj)
        error('ENERGY008:JSONRootInvalid','JSON dataset %s must be a top-level object.',char(ds.dataset_id));
    end
    expected=char(ds.schema_id);
    strict=strcmp(char(ds.role),'PROMPT19_ENGINE_INPUT') || strcmp(char(ds.logical_name),'benchmark_fixture_schema');
    if isfield(obj,'schema_id')
        if ~isempty(expected) && ~strcmp(char(obj.schema_id),expected)
            error('ENERGY008:JSONSchemaMismatch','JSON dataset %s declares schema_id %s; manifest expects %s.',char(ds.dataset_id),char(obj.schema_id),expected);
        end
    elseif strict
        error('ENERGY008:JSONSchemaMissing','JSON dataset %s must declare schema_id %s.',char(ds.dataset_id),expected);
    end
elseif strcmp(fmt,'.csv')
    expected=toCellText(ds.required_columns);
    if isempty(expected), error('ENERGY008:CSVSchemaMissing','CSV dataset %s must declare required_columns in the manifest.',char(ds.dataset_id)); end
    actual=readCsvHeader(path);
    if numel(unique(actual))~=numel(actual), error('ENERGY008:CSVDuplicateHeader','CSV dataset %s contains duplicate header names.',char(ds.dataset_id)); end
    absent=setdiff(expected,actual,'stable');
    if ~isempty(absent), error('ENERGY008:CSVRequiredColumnMissing','CSV dataset %s lacks declared columns: %s',char(ds.dataset_id),strjoin(absent,', ')); end
elseif strcmp(fmt,'.xlsx')
    expected=toCellText(ds.required_sheets);
    if isempty(expected), error('ENERGY008:XLSXSheetSchemaMissing','Workbook dataset %s must declare required_sheets.',char(ds.dataset_id)); end
    if exist('sheetnames','file')==2 || exist('sheetnames','builtin')==5
        actual=cellstr(sheetnames(path));
    elseif exist('xlsfinfo','file')==2
        [~,actual]=xlsfinfo(path);
        actual=toCellText(actual);
    else
        error('ENERGY008:XLSXInspectionUnavailable','Cannot inspect workbook sheets in this MATLAB release. Use a release with sheetnames or xlsfinfo; workbook %s was not accepted.',char(ds.dataset_id));
    end
    absent=setdiff(expected,actual,'stable');
    if ~isempty(absent), error('ENERGY008:XLSXSheetMissing','Workbook dataset %s lacks declared sheets: %s',char(ds.dataset_id),strjoin(absent,', ')); end
elseif any(strcmp(fmt,{'.drawio','.svg'}))
    raw=fileread(path);
    if strcmp(fmt,'.drawio') && isempty(regexp(raw,'<mxfile[ >]','once'))
        error('ENERGY008:DrawioRootInvalid','Editable diagram %s does not contain an mxfile root.',char(ds.dataset_id));
    elseif strcmp(fmt,'.svg') && isempty(regexp(raw,'<svg[ >]','once'))
        error('ENERGY008:SVGRootInvalid','SVG source %s does not contain an svg root.',char(ds.dataset_id));
    end
elseif strcmp(fmt,'.png')
    f=fopen(path,'rb'); if f<0, error('ENERGY008:PNGOpenFailed','Cannot read PNG dataset %s.',char(ds.dataset_id)); end
    c=onCleanup(@()fclose(f)); sig=fread(f,8,'*uint8')'; clear c;
    if ~isequal(sig,uint8([137 80 78 71 13 10 26 10]))
        error('ENERGY008:PNGSignatureInvalid','PNG dataset %s has an invalid PNG signature.',char(ds.dataset_id));
    end
elseif strcmp(fmt,'.dot')
    raw=fileread(path);
    if isempty(regexp(raw,'\b(?:di)?graph\b','once'))
        error('ENERGY008:DOTRootInvalid','DOT diagram %s lacks a graph/digraph declaration.',char(ds.dataset_id));
    end
end
end

function header=readCsvHeader(path)
f=fopen(path,'r'); if f<0, error('ENERGY008:CSVOpenFailed','Cannot open CSV %s.',path); end
cl=onCleanup(@()fclose(f)); line=fgetl(f); clear cl;
if ~ischar(line), error('ENERGY008:CSVHeaderMissing','CSV %s is empty.',path); end
header={}; token=''; inQuotes=false; k=1;
while k<=numel(line)
    ch=line(k);
    if ch=='"'
        if inQuotes && k<numel(line) && line(k+1)=='"'
            token=[token '"']; k=k+1; %#ok<AGROW>
        else
            inQuotes=~inQuotes;
        end
    elseif ch==',' && ~inQuotes
        header{end+1}=strtrim(token); token=''; %#ok<AGROW>
    else
        token=[token ch]; %#ok<AGROW>
    end
    k=k+1;
end
if inQuotes, error('ENERGY008:CSVHeaderMalformed','CSV %s header has an unmatched quote.',path); end
header{end+1}=strtrim(token);
end
