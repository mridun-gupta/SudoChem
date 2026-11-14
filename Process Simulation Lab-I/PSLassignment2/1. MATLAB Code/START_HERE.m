% ENERGY-008 top-level package launcher.
% The original runtime project root is this folder; source code is kept in MATLAB/.
ENERGY008_PACKAGE_DIR = fileparts(mfilename('fullpath'));
run(fullfile(ENERGY008_PACKAGE_DIR, 'MATLAB', 'START_HERE.m'));
