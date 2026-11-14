function d = diagnostic(code,severity,module,message,context,inputIds,remediation)
%DIAGNOSTIC Canonical machine-readable diagnostic record.
if nargin<7, remediation='Review the cited inputs and module gate.'; end
if nargin<6, inputIds={}; end
if nargin<5, context=struct(); end
if ischar(inputIds) || isstring(inputIds), inputIds=cellstr(inputIds); end
if isempty(inputIds), inputIds={}; end
 d=struct('code',char(code),'severity',char(severity),'module',char(module), ...
   'message',char(message),'context',context,'input_ids',{inputIds}, ...
   'remediation',char(remediation),'timestamp',datestr(now,'yyyy-mm-ddTHH:MM:SS'));
end
