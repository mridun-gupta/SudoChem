%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To determine the number of theoretical stages required for the
%      countercurrent liquid-liquid extraction of nicotine from water
%      using kerosene, using equilibrium and operating-line correlations.
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

%% ----------------------- GIVEN DATA --------------------------------------

% Total water-solution flow rate entering the extractor
L_0 = 100;                    % kg/h

% Total kerosene-solution flow rate entering the extractor
V_n = 200;                    % kg/h

% Nicotine mass fraction in the entering water solution
x_0 = 0.0100;

% Nicotine mass fraction in the entering kerosene solution
y_n1 = 0.0005;

% Required nicotine mass fraction in the exiting water solution
x_n = 0.0010;

% Experimental equilibrium data
% x = nicotine mass fraction in the water-rich phase
% y = nicotine mass fraction in the kerosene-rich phase
x = [0.0001010 0.0024600 0.0050000 0.0074600 0.0098800 0.0202000];
y = [0.000806  0.001959  0.004540  0.006820  0.009040  0.018500];

fprintf('==============================================================\n');
fprintf('       PROCESS SIMULATION LABORATORY-I : LLE\n');
fprintf('==============================================================\n\n');

fprintf('Water-solution flow rate, L_0 = %.4f kg/h\n',L_0);
fprintf('Kerosene-solution flow rate, V_n = %.4f kg/h\n',V_n);
fprintf('Entering water composition, x_0 = %.6f\n',x_0);
fprintf('Entering kerosene composition, y_n1 = %.6f\n',y_n1);
fprintf('Required exiting water composition, x_n = %.6f\n\n',x_n);

%% ----------------------- EQUILIBRIUM LINE -------------------------------

% Fit the equilibrium data with a second-order polynomial:
% y = A2*x^2 + A1*x + A0
PF = polyfit(x,y,2);

A2 = PF(1);
A1 = PF(2);
A0 = PF(3);

%% ----------------------- MATERIAL BALANCE -------------------------------

% Solute-free carrier flow rates
L_dash = L_0*(1-x_0);
V_dash = V_n*(1-y_n1);

% Solute-free concentrations
X_0 = x_0/(1-x_0);
X_n = x_n/(1-x_n);
Y_n1 = y_n1/(1-y_n1);

% Overall solute balance:
% L'(X_0-X_n) = V'(Y_1-Y_n1)
Y_1 = Y_n1 + (L_dash/V_dash)*(X_0-X_n);

y_1 = Y_1/(1+Y_1);

%% ----------------------- OPERATING LINE ---------------------------------

% The operating line passes through (x_n,y_n1) and (x_0,y_1).
OL_1 = [x_n x_0];
OL_2 = [y_n1 y_1];
PF_1 = polyfit(OL_1,OL_2,1);

B1 = PF_1(1);
B0 = PF_1(2);

%% ----------------------- STAGE CALCULATION ------------------------------

% This stepping expression follows the variable sequence and calculation
% form shown in the instructor's classroom reference code.
N = 1;
y_current = y_1;

stage_no = [];
stage_y = [];
stage_x = [];
stage_y_new = [];

while true

    % Equilibrium step used in the instructor's classroom algorithm
    x_new = A2*(y_current^2) + A1*y_current + A0;

    % Operating-line step
    y_new = B1*x_new + B0;

    stage_no(end+1,1) = N; %#ok<SAGROW>
    stage_y(end+1,1) = y_current; %#ok<SAGROW>
    stage_x(end+1,1) = x_new; %#ok<SAGROW>
    stage_y_new(end+1,1) = y_new; %#ok<SAGROW>

    % Stop when the new value reaches or falls below the entering
    % kerosene composition.
    if y_new <= y_n1
        break;
    end

    y_current = y_new;
    N = N + 1;

    if N > 100
        error('Stage calculation exceeded 100 stages. Check the input data.');
    end
end

Number_of_Stages = N;

%% ----------------------- DISPLAY RESULTS --------------------------------

fprintf('Equilibrium polynomial:\n');
fprintf('y = %.10f*x^2 + %.10f*x + %.10f\n\n',A2,A1,A0);

fprintf('Solute-free carrier flow rates:\n');
fprintf('L'' = %.6f kg/h\n',L_dash);
fprintf('V'' = %.6f kg/h\n\n',V_dash);

fprintf('Solute-free concentrations:\n');
fprintf('X_0 = %.10f\n',X_0);
fprintf('X_n = %.10f\n',X_n);
fprintf('Y_n1 = %.10f\n',Y_n1);
fprintf('Y_1 = %.10f\n',Y_1);
fprintf('Top extract composition, y_1 = %.10f\n\n',y_1);

fprintf('Operating line:\n');
fprintf('y = %.10f*x + %.10e\n\n',B1,B0);

fprintf('Stage-by-stage calculation:\n');
fprintf('Stage      y(current)      x(new)          y(new)\n');
for i = 1:numel(stage_no)
    fprintf('%3d       %12.8f   %12.8f   %12.8f\n', ...
        stage_no(i),stage_y(i),stage_x(i),stage_y_new(i));
end

fprintf('\nNumber_of_Stages = %d theoretical stages\n',Number_of_Stages);
fprintf('==============================================================\n');

%% ----------------------- PLOT -------------------------------------------

x_plot = linspace(0,max(x_0,max(x))*1.05,500);
y_eq_plot = A2*x_plot.^2 + A1*x_plot + A0;
y_op_plot = B1*x_plot + B0;

figure('Name','Multistage Liquid-Liquid Extraction','NumberTitle','off');
plot(x_plot,y_eq_plot,'LineWidth',1.5);
hold on;
plot(x_plot,y_op_plot,'LineWidth',1.5);

% Display the successive calculated stage points.
plot(stage_x,stage_y,'ko-','LineWidth',1.1,'MarkerFaceColor','k');
plot(stage_x,stage_y_new,'ks--','LineWidth',1.1,'MarkerFaceColor','w');
plot(x_0,y_1,'kd','MarkerFaceColor','k');
plot(x_n,y_n1,'kp','MarkerFaceColor','w');

grid on;
xlabel('x: nicotine mass fraction in water-rich phase');
ylabel('y: nicotine mass fraction in kerosene-rich phase');
title('Multistage Liquid-Liquid Extraction');
legend('Equilibrium fit','Operating line','Current stage values', ...
       'Next stage values','(x_0,y_1)','(x_n,y_{n1})', ...
       'Location','best');
hold off;
