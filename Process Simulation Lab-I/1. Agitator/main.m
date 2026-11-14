%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To design 1 m³ mechanically agitated vessel/tank system with initial
% volume scaled to 10 m³, with a flat six-blade disk turbine under
% turbulent flow conditions, and determine the corresponding power
% consumption of the agitated tank system.
%
% Author: Mridun Gupta, (IMT.CE, 2024)
%
% Roll Number: J24IMT624
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
close all;

%% -----------------------------
% INPUT DATA
%% -----------------------------

rho = 1000;                         % Fluid density (kg/m^3)
mu = 0.001;                         % Dynamic viscosity (Pa.s)
Np = 6;                             % Power number (from N_Re vs. N_P plot)
Re = 1e4;                           % Assumed turbulent Reynolds Number, remained constant)
n = 2/3;                            % Considered Equal rate of mass transfer

%% -----------------------------
% TANK DESIGN
%% -----------------------------

V1 = 1;                             % Tank volume (m^3)
Dt1 = (4*V1/pi)^(1/3);              % Tank diameter (m)
H1 = Dt1;                           % Liquid height
J1 = Dt1 * 1/12;                    % Baffle Width

%% -----------------------------
% IMPELLER DIMENSIONS
%% -----------------------------

Da1 = Dt1 * 0.3;                    % Impeller diameter
W1 = Da1 * 0.2;                     % Blade width
L1 = Da1 * 0.25;                    % Blade length
E1 = Dt1 * 0.33;                    % Clearance from bottom

%% -----------------------------
% POWER CALCULATION
%% -----------------------------

N1 = Re*mu/(rho*Da1^2);             % Rotational speed (rev/s)
P1 = Np*rho*N1^3*Da1^5;             % Power consumption (W)

%% -----------------------------
% SCALE-UP TO 10 m^3
%% -----------------------------

V2 = 10;

R = (V2/V1)^(1/3);                  % Scale Ratio

H2 = R * H1;
Dt2 = R * Dt1;
Da2 = R * Da1;
W2 = R * W1;
L2 = R * L1;
E2 = R * E1;
J2 = R * J1;

N2 = N1*(1/R)^n;
P2 = Np*rho*N2^3*Da2^5;

%% -----------------------------
% DISPLAY RESULTS
%% -----------------------------

fprintf('\n');
fprintf('=========================================\n');
fprintf('      AGITATOR DESIGN RESULTS\n');
fprintf('=========================================\n');

fprintf('Scaled Ratio               = %.3f m\n',R);
fprintf('Assumed Reynolds Number    = %.2e\n',Re);

fprintf('\nOriginal Tank (1 m^3)\n');
fprintf('-------------------------\n');
fprintf('Tank Diameter      = %.3f m\n',Dt1);
fprintf('Liquid Height      = %.3f m\n',H1);
fprintf('Impeller Diameter  = %.3f m\n',Da1);
fprintf('Blade Width        = %.3f m\n',W1);
fprintf('Blade Length       = %.3f m\n',L1);
fprintf('Clearance          = %.3f m\n',E1);
fprintf('Baffle Width       = %.3f m\n',J1);
fprintf('Rotational Speed   = %.3f m\n',N1);
fprintf('Power Consumption  = %.2f W\n',P1);

fprintf('\nScaled Tank (10 m^3)\n');
fprintf('-------------------------\n');
fprintf('Tank Diameter      = %.3f m\n',Dt2);
fprintf('Liquid Height      = %.3f m\n',H2);
fprintf('Impeller Diameter  = %.3f m\n',Da2);
fprintf('Blade Width        = %.3f m\n',W2);
fprintf('Blade Length       = %.3f m\n',L2);
fprintf('Clearance          = %.3f m\n',E2);
fprintf('Baffle Width       = %.3f m\n',J2);
fprintf('Rotational Speed   = %.3f m\n',N2);
fprintf('Power Consumption  = %.2f W\n',P2);

fprintf('\n=========================================\n');

%% -----------------------------
% BAR CHART
%% -----------------------------

figure;

bar([P1 P2]);

set(gca,'XTickLabel',{'Model/Initial','Prototype/Scaled'});

ylabel('Power (W)');

title('Power Consumption Comparison');

grid on;