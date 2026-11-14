%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To design an adiabatic rotary dryer using MATLAB by determining the
% required dryer diameter and length for drying a heat-sensitive solid
% under specific operating condition.
%
% Author: Mridun Gupta (IMT.CE, 2024)
%
% Roll Number: J24IMT624
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
close all;

%% ------------------------------------------------------------------------
% INPUT DATA
%% ------------------------------------------------------------------------

% Specific Heat Capacities
cps = 0.52;                 % Specific heat of dry solid
cpv = 0.45;                 % Specific heat of water vapour
cpl = 1.00;                 % Specific heat of liquid water

% Moisture Content
xa = 0.15;                  % Initial moisture content (kg water/kg dry solid)
xb = 0.0025;                % Final moisture content (kg water/kg dry solid)

% Temperature Data
tsa = 80;                   % Initial solid temperature
tsb = 125;                  % Final solid temperature
tv  = 96.98;                % Evaporation temperature of water
tva = 137;                  % Water vapour temperature
thb = 300;                  % Inlet hot air temperature
tha = 137;                  % Outlet hot air temperature

% Feed Data
ms = 2800;                  % Dry solid feed rate
lambda  = 2.260;            % Latent heat of vaporization

% Air Properties
Hb   = 0.01;                % Inlet air humidity
Cshb = 0.245;               % Humid heat of inlet air

% Design Parameters
G = 700;                    % Gas mass velocity
delta_T_bar = 100.37;       % Log mean temperature difference

%% ------------------------------------------------------------------------
% HEAT DUTY CALCULATION
%% ------------------------------------------------------------------------

qt = ms * ( ...
    cps * (tsb - tsa) ...
    + xa * cpl * (tv - tsa) ...
    + (xa - xb) * lambda ...
    + xb * cpl * (tsb - tv) ...
    + (xa - xb) * cpv * (tva - tv) ...
    );

%% ------------------------------------------------------------------------
% NUMBER OF TRANSFER UNITS
%% ------------------------------------------------------------------------

Nt = log((thb - tv) / (tha - tv));

%% ------------------------------------------------------------------------
% DRY AIR REQUIREMENT
%% ------------------------------------------------------------------------

mg = qt / ((1 + Hb) * Cshb * (thb - tha));

%% ------------------------------------------------------------------------
% MOISTURE BALANCE
%% ------------------------------------------------------------------------

mv = ms * (xa - xb);

Ha = Hb + (mv / mg);

%% ------------------------------------------------------------------------
% DRYER DIMENSION CALCULATION
%% ------------------------------------------------------------------------

D = sqrt((4 * mg) / (pi * G));

L = qt / (0.125 * pi * D * (G^0.67) * delta_T_bar);

%% ------------------------------------------------------------------------
% DISPLAY RESULTS
%% ------------------------------------------------------------------------

fprintf('\n');
fprintf('=====================================================\n');
fprintf('           ROTARY DRYER DESIGN RESULTS\n');
fprintf('=====================================================\n');

fprintf('\nHeat Duty Calculation\n');
fprintf('-----------------------------------------------------\n');
fprintf('Total Heat Duty (qt)              = %.3f\n', qt);
fprintf('Number of Transfer Units (NT)     = %.3f\n', Nt);

fprintf('\nAir Requirement\n');
fprintf('-----------------------------------------------------\n');
fprintf('Dry Air Flow Rate (mg)            = %.3f\n', mg);

fprintf('\nMoisture Balance\n');
fprintf('-----------------------------------------------------\n');
fprintf('Moisture Evaporated (mv)          = %.3f\n', mv);
fprintf('Outlet Air Humidity (Ha)          = %.5f\n', Ha);

fprintf('\nDryer Dimensions\n');
fprintf('-----------------------------------------------------\n');
fprintf('Dryer Diameter (D)                = %.3f ft\n', D);
fprintf('Dryer Length (L)                  = %.3f ft\n', L);

fprintf('\n=====================================================\n');
fprintf('Design Calculation Completed Successfully.\n');
fprintf('=====================================================\n');

%% ------------------------------------------------------------------------
% BAR CHART
%% ------------------------------------------------------------------------

figure;

values = [qt Nt mg mv D L];

bar(values);

set(gca,'XTickLabel',{'Heat Duty','Number of Transfer Units','Dry Air','Moisture','Diameter','Length'});

ylabel('Calculated Value');

title('Rotary Dryer Design Parameters');

grid on;