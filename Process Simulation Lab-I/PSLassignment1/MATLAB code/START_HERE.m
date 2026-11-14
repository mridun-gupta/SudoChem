function START_HERE
% CPS-22 one-click start. Opens the continuous-input GUI.
root=fileparts(mfilename('fullpath')); addpath(root,'-begin'); addpath(fullfile(root,'src'),'-begin'); addpath(fullfile(root,'gui'),'-begin'); cd(root); rehash path;
CPS22_Launcher('gui');
end
