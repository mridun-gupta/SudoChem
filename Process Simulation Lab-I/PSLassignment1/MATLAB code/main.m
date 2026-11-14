function main
% CPS-22 main entry point: open the continuous-input GUI.
root=fileparts(mfilename('fullpath')); addpath(root,'-begin'); addpath(fullfile(root,'src'),'-begin'); addpath(fullfile(root,'gui'),'-begin'); cd(root); rehash path;
cps22_gui();
end
