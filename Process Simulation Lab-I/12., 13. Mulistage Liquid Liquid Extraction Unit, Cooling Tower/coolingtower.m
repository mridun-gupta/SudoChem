%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To determine the required packing height of a countercurrent
%      water-cooling tower using equilibrium enthalpy data, the height of
%      a transfer unit (HTU), and the number of transfer units (NTU).
%
% Author: Mridun Gupta (IMT.CE, 2024)
%
% Roll Number: J24IMT624
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
close all;

format short g;
format compact;

%% ----------------------- EQUILIBRIUM DATA -------------------------------

% Saturated air-water equilibrium data
% T_liq is liquid temperature in degree Celsius.
% Hy is enthalpy in J/kg dry air.
T_liq = [15.6 26.7 29.4 32.2 35.0 37.8 40.6 43.3 46.1 60.0];
Hy = [43.68e3 84.0e3 97.2e3 112.1e3 128.9e3 ...
      148.2e3 172.1e3 197.2e3 224.5e3 461.5e3];

n = length(T_liq);

% Convert liquid temperatures to Kelvin for the fitted polynomial.
T = T_liq + 273.15;

%% ----------------------- GIVEN PROCESS DATA -----------------------------

G = 1.356;                    % kg dry air/(s m^2)
L = 1.356;                    % kg water/(s m^2)

T1 = 29.4;                    % deg C, cold-water temperature
T2 = 43.3;                    % deg C, hot-water temperature

TG1 = 29.4;                   % deg C, entering-air dry-bulb temperature
Twb1 = 23.9;                  % deg C, entering-air wet-bulb temperature
H1 = 0.0165;                  % kg water/kg dry air, from psychrometric chart

kGa = 1.207e-7;               % kgmol/(s m^3 Pa)
P_total = 1.013e5;            % Pa
MB = 29;                      % kg dry air/kgmol
cL = 4.187e3;                  % J/(kg K)

% Given coefficient ratio from the problem statement.
hLa_over_kGaMBP = 4.187e4;    % J/(kg K)

%% ----------------------- EQUILIBRIUM RELATION ---------------------------

% Fit Hy = a2*T^2 + a1*T + a0 using a second-order polynomial.
P_eq = polyfit(T,Hy,2);

a2 = P_eq(1);
a1 = P_eq(2);
a0 = P_eq(3);

%% ----------------------- INPUT/OUTPUT ENTHALPIES -------------------------

% Moist-air enthalpy relation, with T in degree Celsius:
% Hy = (1.005 + 1.88*H)*1000*T + H*2.501e6
Hy1 = (1.005 + 1.88*H1)*1000*T1 + H1*2.501e6;

% Overall heat balance:
% G*(Hy2-Hy1) = L*cL*(T2-T1)
Hy2 = Hy1 + (L/G)*cL*(T2-T1);

%% ----------------------- OPERATING LINE ---------------------------------

% The operating line passes through (TL1,Hy1) and (TL2,Hy2).
% Temperatures are converted to Kelvin to match the equilibrium fit.
TL1 = T1 + 273.15;
TL2 = T2 + 273.15;

P1 = polyfit([TL1 TL2],[Hy1 Hy2],1);
intercept = P1(2);
slope = P1(1);

%% ----------------------- HEIGHT OF TRANSFER UNIT ------------------------

% Gas-side height of a transfer unit:
% HTU = G/(MB*kGa*P_total)
HTU = G/(MB*kGa*P_total);

%% ----------------------- STAIRCASE / DRIVING-FORCE DATA -----------------

% Values below are the staircase/interface enthalpy readings for the
% supplied problem. Units are J/kg dry air.
Hy_stair = [71.7 83.5 94.9 106.5 118.4 129.9]*1e3;
Hyi_stair = [94.4 108.4 124.4 141.8 162.1 184.7]*1e3;

driving_force = Hyi_stair - Hy_stair;

% Reciprocal driving force for the NTU integration.
dN_dHy = 1./driving_force;

%% ----------------------- NUMBER OF TRANSFER UNITS -----------------------

% Integrate 1/(Hyi-Hy) with respect to bulk-gas enthalpy using trapz.
NTU = trapz(Hy_stair,dN_dHy);

%% ----------------------- REQUIRED PACKING HEIGHT ------------------------

Z = HTU*NTU;

%% ----------------------- DISPLAY RESULTS --------------------------------

fprintf('==============================================================\n');
fprintf('       PROCESS SIMULATION LABORATORY-I : COOLING TOWER\n');
fprintf('==============================================================\n\n');

fprintf('Number of equilibrium data points, n = %d\n',n);
fprintf('Entering-air dry-bulb temperature, TG1 = %.2f deg C\n',TG1);
fprintf('Entering-air wet-bulb temperature, Twb1 = %.2f deg C\n',Twb1);
fprintf('Entering-air humidity, H1 = %.6f kg water/kg dry air\n\n',H1);

fprintf('Input-air enthalpy, Hy1 = %.3f J/kg dry air\n',Hy1);
fprintf('Output-air enthalpy, Hy2 = %.3f J/kg dry air\n\n',Hy2);

fprintf('Equilibrium polynomial (T in K):\n');
fprintf('Hy = %.6e*T^2 + %.6e*T + %.6e\n\n',a2,a1,a0);

fprintf('Operating line:\n');
fprintf('Hy = %.6f*T(K) + %.6f\n\n',slope,intercept);

fprintf('Given hLa/(kGa*MB*P) = %.3f J/(kg K)\n',hLa_over_kGaMBP);
fprintf('HTU = %.6f m\n',HTU);

fprintf('\nStaircase and driving-force table:\n');
fprintf('Hy (J/kg)       Hyi (J/kg)      Hyi-Hy (J/kg)    1/(Hyi-Hy)\n');
for i = 1:length(Hy_stair)
    fprintf('%12.1f   %12.1f   %12.1f   %12.6e\n', ...
        Hy_stair(i),Hyi_stair(i),driving_force(i),dN_dHy(i));
end

fprintf('\nNTU = %.6f\n',NTU);
fprintf('Required packing height, Z = %.6f m\n',Z);
fprintf('Textbook rounded value (graphical readings) is approximately 6.98 m.\n');
fprintf('==============================================================\n');

%% ----------------------- ENTHALPY DIAGRAM -------------------------------

T_plot_K = linspace(min(T),max(T),500);
Hy_eq_plot = a0 + a1*T_plot_K + a2*T_plot_K.^2;
Hy_op_plot = intercept + slope*T_plot_K;

figure('Name','Countercurrent Cooling Tower Enthalpy Diagram', ...
       'NumberTitle','off');

plot(T_liq,Hy/1000,'LineWidth',1.5);
hold on;
plot(T_plot_K-273.15,Hy_op_plot/1000,'LineWidth',1.5);

% Bulk points associated with the enthalpy staircase.
T_bulk = [29.4 32.2 35.0 37.8 40.6 43.3];
plot(T_bulk,Hy_stair/1000,'ko','MarkerFaceColor','k');

% Approximate interface temperatures from the supplied equilibrium table.
T_interface = interp1(Hy,T_liq,Hyi_stair,'linear','extrap');
plot(T_interface,Hyi_stair/1000,'ks','MarkerFaceColor','w');

for i = 1:length(T_bulk)
    plot([T_bulk(i) T_interface(i)], ...
         [Hy_stair(i) Hyi_stair(i)]/1000,'k--','LineWidth',0.8);
end

grid on;
xlabel('Liquid temperature, T_L (deg C)');
ylabel('Gas enthalpy, H_y (kJ/kg dry air)');
title('Countercurrent Packed Water-Cooling Tower');
legend('Equilibrium data','Operating line','Bulk enthalpy points', ...
       'Interface enthalpy points','Driving-force construction', ...
       'Location','best');
hold off;

%% ----------------------- FINAL CHECKS -----------------------------------

if any(driving_force <= 0)
    warning('One or more enthalpy driving forces are non-positive.');
end

if HTU <= 0 || NTU <= 0 || Z <= 0
    warning('HTU, NTU, and packing height should all be positive.');
end
