%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To estimate the number of theoretical stages and the tower height
%      for NH3 absorption in a counter-current gas absorption column using
%      cubic VLE data and the HTU-NTU method.
%
% Author: Mridun Gupta, (IMT.CE, 2024)
%
% Roll Number: J24IMT624
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
close all;

format short g;
format compact;

%% ----------------------- GIVEN DATA --------------------------------------

% Gas compositions
% ya -> Gas outlet NH3 mole fraction
% yb -> Gas inlet NH3 mole fraction
yb = 0.80;
ya = 0.10;

% Liquid compositions
% xb -> Liquid outlet NH3 mole fraction
% xa -> Liquid inlet NH3 mole fraction
xb = 0.70;
xa = 0.20;

% Operating conditions
F = 100;                    % Gas feed flow rate, kg/h
T = 300;                    % Operating temperature, K
P = 1;                      % Operating pressure, bar
D = 1;                      % Column diameter, m

% Volumetric gas-phase mass-transfer coefficient
Kya = 20;                   % kmol/(m^3 h), as supplied in assignment

% Molecular weights
MW_NH3 = 17.03;             % kg/kmol
MW_CO2 = 44.01;             % kg/kmol

% VLE data for NH3-CO2 system
x_data = [ ...
    0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00];

y_data = [ ...
    0.01 0.05 0.10 0.17 0.26 0.36 0.47 0.60 0.74 0.90];

%% ----------------------- VALIDATION OF INPUTS ----------------------------

if any([xb xa yb ya] < 0) || any([xb xa yb ya] > 1)
    error('All mole fractions must lie between 0 and 1.');
end

if xb <= xa
    error('For the supplied absorber specification, xb must be greater than xa.');
end

if yb <= ya
    error('For the supplied absorber specification, yb must be greater than ya.');
end

if D <= 0 || F <= 0 || Kya <= 0
    error('F, D and Kya must be positive.');
end

%% ----------------------- VLE CURVE FIT ----------------------------------

% Cubic equilibrium relation:
% y_eq = Aeq*x^3 + Beq*x^2 + Ceq*x + Deq
VLE = polyfit(x_data, y_data, 3);

Aeq = VLE(1);
Beq = VLE(2);
Ceq = VLE(3);
Deq = VLE(4);

%% ----------------------- COLUMN AREA ------------------------------------

% Column cross-sectional area
Area = pi*(D/2)^2;

%% ----------------------- MOLECULAR WEIGHTS ------------------------------

% Average molecular weights of gas at inlet and outlet
MW_in  = yb*MW_NH3 + (1-yb)*MW_CO2;
MW_out = ya*MW_NH3 + (1-ya)*MW_CO2;
MW_avg = (MW_in + MW_out)/2;

% Gas molar flow rate
% kg/h divided by kg/kmol gives kmol/h
G = F/MW_avg;

%% ----------------------- OPERATING LINE ---------------------------------

% Operating line:
% y = m*x + c
m = (yb - ya)/(xb - xa);
c = ya - m*xa;

%% ----------------------- MCBABE-THIELE STAGE CALCULATION ---------------

% Start from the gas outlet / liquid inlet point (xa, ya).
% Move horizontally to the equilibrium curve and then vertically to the
% operating line until the gas inlet composition yb is reached.
y_current = ya;
x_current = xa;

N_complete = 0;
N_theoretical = NaN;

% Staircase coordinates for plotting
x_stage = xa;
y_stage = ya;

maxStages = 1000;

while N_complete < maxStages

    % Solve y_current = y_eq(x) for the equilibrium liquid composition.
    polynomial = [Aeq Beq Ceq (Deq - y_current)];
    roots_eq = roots(polynomial);

    real_roots = real(roots_eq(abs(imag(roots_eq)) < 1e-8));
    valid_roots = real_roots(real_roots >= 0 & real_roots <= 1);

    if isempty(valid_roots)
        error('No physical equilibrium root was found during stage calculation.');
    end

    % Select the root closest to the current liquid composition.
    [~, index] = min(abs(valid_roots - x_current));
    x_eq = valid_roots(index);

    % Move vertically to the operating line.
    y_next = m*x_eq + c;

    % Final fractional stage
    if y_next >= yb
        fraction = (yb - y_current)/(y_next - y_current);
        N_theoretical = N_complete + fraction;

        x_stage(end+1) = x_eq; %#ok<SAGROW>
        y_stage(end+1) = y_current; %#ok<SAGROW>
        x_stage(end+1) = x_eq; %#ok<SAGROW>
        y_stage(end+1) = yb; %#ok<SAGROW>
        break;
    end

    % Complete theoretical stage
    N_complete = N_complete + 1;

    x_stage(end+1) = x_eq; %#ok<SAGROW>
    y_stage(end+1) = y_current; %#ok<SAGROW>
    x_stage(end+1) = x_eq; %#ok<SAGROW>
    y_stage(end+1) = y_next; %#ok<SAGROW>

    x_current = x_eq;
    y_current = y_next;
end

if isnan(N_theoretical)
    error('Maximum stage count reached without reaching the specified gas inlet composition.');
end

%% ----------------------- HTU CALCULATION --------------------------------

% Gas-phase HTU:
% HTU = G/(Kya*Area)
HTU = G/(Kya*Area);

%% ----------------------- NTU CALCULATION --------------------------------

% Integrate using gas-phase driving force:
% Driving force = y - y_eq

y = linspace(ya, yb, 2000);
x = (y - c)/m;

% Keep the integration domain within the VLE data range.
if any(x < min(x_data)-1e-10) || any(x > max(x_data)+1e-10)
    error('Operating line leaves the VLE composition range during NTU calculation.');
end

y_eq = Aeq*x.^3 + Beq*x.^2 + Ceq*x + Deq;
driving_force = y - y_eq;

if any(driving_force <= 0)
    error('Non-positive gas-phase driving force encountered during NTU integration.');
end

NTU = trapz(y, 1./driving_force);

%% ----------------------- TOWER HEIGHT -----------------------------------

% Tower height
Z = HTU*NTU;

%% --------------------------- RESULTS -------------------------------------

disp('==============================================================')
disp('              NH3 ABSORPTION: HTU-NTU RESULTS')
disp('==============================================================')

fprintf('\nOperating temperature     = %.2f K\n', T);
fprintf('Operating pressure        = %.2f bar\n', P);
fprintf('Column diameter           = %.2f m\n', D);
fprintf('Column area               = %.6f m^2\n', Area);

fprintf('\nVLE cubic coefficients:\n');
fprintf('Aeq = %.9f\n', Aeq);
fprintf('Beq = %.9f\n', Beq);
fprintf('Ceq = %.9f\n', Ceq);
fprintf('Deq = %.9f\n', Deq);

fprintf('\nGas molecular weights:\n');
fprintf('MW_in  = %.6f kg/kmol\n', MW_in);
fprintf('MW_out = %.6f kg/kmol\n', MW_out);
fprintf('MW_avg = %.6f kg/kmol\n', MW_avg);
fprintf('G      = %.6f kmol/h\n', G);

fprintf('\nOperating line:\n');
fprintf('y = %.6f x + %.6f\n', m, c);

fprintf('\nMass-transfer results:\n');
fprintf('HTU = %.6f m\n', HTU);
fprintf('NTU = %.6f\n', NTU);
fprintf('Tower height, Z = %.6f m\n', Z);
fprintf('Theoretical stages = %.6f\n', N_theoretical);

disp('==============================================================')

%% --------------------------- MCBABE-THIELE PLOT --------------------------

x_plot = linspace(0, 1, 500);
y_eq_plot = Aeq*x_plot.^3 + Beq*x_plot.^2 + Ceq*x_plot + Deq;
y_op_plot = m*x_plot + c;

figure('Name','Assignment 7 - NH3 Absorption','NumberTitle','off');
plot(x_plot, y_eq_plot, 'LineWidth', 1.5);
hold on;
plot(x_plot, y_op_plot, 'LineWidth', 1.5);
plot([0 1], [0 1], '--', 'LineWidth', 1.0);
plot(x_stage, y_stage, '-k', 'LineWidth', 1.0);
plot([xa xb], [ya yb], 'ko', 'MarkerFaceColor', 'k');
hold off;

grid on;
xlim([0 1]);
ylim([0 1]);
xlabel('Liquid NH_3 mole fraction, x');
ylabel('Gas NH_3 mole fraction, y');
title('McCabe-Thiele Construction for NH_3 Absorption');
legend('Equilibrium curve','Operating line','Diagonal','Stage construction', ...
       'Specification points','Location','best');
