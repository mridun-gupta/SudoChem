function c = cellstr_safe(v)
if isempty(v), c={}; elseif iscell(v), c=cellfun(@char,v,'UniformOutput',false); elseif isstring(v), c=cellstr(v); elseif ischar(v), c={v}; else, error('ENERGY008:TypeError','Expected text or a text list.'); end
end
