function value = get_option(s,name,defaultValue)
%GET_OPTION Return a named struct option or its explicit default.
value=defaultValue;
if isstruct(s) && isfield(s,name) && ~isempty(s.(name)), value=s.(name); end
end
