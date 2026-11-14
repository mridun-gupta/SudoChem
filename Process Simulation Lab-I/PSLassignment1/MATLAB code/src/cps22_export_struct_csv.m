function cps22_export_struct_csv(s, filePath)
% Export a scalar diagnostic structure to a key/value CSV.
% Numeric arrays are emitted with mat2str, which preserves NaN/Inf/complex roots.
if ~isstruct(s) || ~isscalar(s), error('CPS22:ExpectedScalarStruct','Input must be a scalar struct.'); end
fields=fieldnames(s); vals=strings(numel(fields),1);
for i=1:numel(fields)
    v=s.(fields{i});
    if isnumeric(v)
        if isscalar(v)
            if isfinite(v) && isreal(v), vals(i)=string(sprintf('%.15g',v)); else, vals(i)=string(mat2str(v,15)); end
        else
            vals(i)=string(mat2str(v,15));
        end
    elseif islogical(v) && isscalar(v)
        vals(i)=string(v);
    elseif ischar(v)
        vals(i)=string(v);
    elseif isstring(v)
        vals(i)=join(v(:)," | ");
    elseif isstruct(v)
        try, vals(i)=string(jsonencode(v)); catch, vals(i)=string(strtrim(evalc('disp(v)'))); end
    else
        try, vals(i)=string(jsonencode(v)); catch, vals(i)=string(strtrim(evalc('disp(v)'))); end
    end
end
T=table(string(fields),vals,'VariableNames',{'field','value'}); writetable(T,filePath);
end
