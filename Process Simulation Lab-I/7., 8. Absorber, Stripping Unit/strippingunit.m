%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To design a counter-current stripping column for the recovery of
%      ammonia from a liquid stream and to determine the theoretical stages,
%      column area, HTU, NTU and stripping tower height using the
%      McCabe-Thiele and HTU-NTU methods.
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

% Liquid compositions
% xb -> Liquid inlet NH3 mole fraction
% xa -> Liquid outlet NH3 mole fraction
xb = 0.70;
xa = 0.20;

% Gas compositions
% yb -> Gas outlet NH3 mole fraction
% ya -> Gas inlet NH3 mole fraction
yb = 0.60;
ya = 0.00;

% Operating conditions
F = 100;                    % Feed flow rate, kg/h
T = 300;                    % Operating temperature, K
P = 0.7;                    % Operating pressure, bar
D = 1;                      % Column diameter, m

% Liquid flow rate and volumetric liquid-phase mass-transfer coefficient
L = 100;                    % Liquid flow rate, kg/h
Kxa = 20;                   % Volumetric liquid-phase coefficient, as supplied

% VLE data
x_data = [ ...
    0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00];

y_data = [ ...
    0.10 0.20 0.35 0.50 0.60 0.70 0.80 0.90 0.95 0.98];

%% ----------------------- VALIDATION OF INPUTS ----------------------------

if any([xb xa yb ya] < 0) || any([xb xa yb ya] > 1)
    error('All mole fractions must lie between 0 and 1.');
end

if xb <= xa
    error('For the supplied stripper specification, xb must be greater than xa.');
end

if yb <= ya
    error('For the supplied stripper specification, yb must be greater than ya.');
end

if D <= 0 || L <= 0 || Kxa <= 0
    error('D, L and Kxa must be positive.');
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

Area = pi*(D/2)^2;

%% ----------------------- OPERATING LINE ---------------------------------

% Operating line:
% y = m*x + c
m = (yb - ya)/(xb - xa);
c = ya - m*xa;

%% ----------------------- MCBABE-THIELE STAGE CALCULATION ---------------

% Start at the upper stripping-column specification point (xb, yb).
% Move horizontally to the equilibrium curve and vertically to the
% operating line until xa is reached.
x_current = xb;
y_current = yb;

N_complete = 0;
N_theoretical = NaN;

% Staircase coordinates for plotting
x_stage = xb;
y_stage = yb;

maxStages = 1000;

while N_complete < maxStages

    % Solve y_current = y_eq(x) for equilibrium liquid composition.
    polynomial = [Aeq Beq Ceq (Deq - y_current)];
    roots_eq = roots(polynomial);

    real_roots = real(roots_eq(abs(imag(roots_eq)) < 1e-8));
    valid_roots = real_roots(real_roots >= 0 & real_roots <= 1);

    if isempty(valid_roots)
        error('No physical equilibrium root was found during stage calculation.');
    end

    % Select the equilibrium root closest to the current liquid composition.
    [~, index] = min(abs(valid_roots - x_current));
    x_star = valid_roots(index);

    % Move vertically to operating line.
    y_next = m*x_star + c;

    % Final fractional stage
    if x_star <= xa
        fraction = (x_current - xa)/(x_current - x_star);
        N_theoretical = N_complete + fraction;

        x_stage(end+1) = x_star; %#ok<SAGROW>
        y_stage(end+1) = y_current; %#ok<SAGROW>
        x_stage(end+1) = x_star; %#ok<SAGROW>
        y_stage(end+1) = y_next; %#ok<SAGROW>
        break;
    end

    % Complete theoretical stage
    N_complete = N_complete + 1;

    x_stage(end+1) = x_star; %#ok<SAGROW>
    y_stage(end+1) = y_current; %#ok<SAGROW>
    x_stage(end+1) = x_star; %#ok<SAGROW>
    y_stage(end+1) = y_next; %#ok<SAGROW>

    x_current = x_star;
    y_current = y_next;
end

if isnan(N_theoretical)
    error('Maximum stage count reached without reaching the specified liquid outlet composition.');
end

%% ----------------------- HTU CALCULATION --------------------------------

% HTU based on liquid flow rate and Kxa as given in the assignment.
HTU = L/(Kxa*Area);

%% ----------------------- NTU CALCULATION --------------------------------

% For stripping, liquid-phase driving force is taken as:
% driving force = x - x_star
%
% Integrate from xa to xb so that the NTU is positive.
x = linspace(xa, xb, 2000);
x_star = zeros(size(x));

for i = 1:length(x)

    % Operating-line gas composition
    y_i = m*x(i) + c;

    % Equilibrium relation:
    % y_i = Aeq*x_star^3 + Beq*x_star^2 + Ceq*x_star + Deq
    polynomial = [Aeq Beq Ceq (Deq - y_i)];
    roots_eq = roots(polynomial);

    real_roots = real(roots_eq(abs(imag(roots_eq)) < 1e-7));
    valid_roots = real_roots(real_roots >= 0 & real_roots <= 1);

    if isempty(valid_roots)
        error('No physical equilibrium root found during NTU calculation.');
    end

    [~, index] = min(abs(valid_roots - x(i)));
    x_star(i) = valid_roots(index);
end

driving_force = x - x_star;

if any(driving_force <= 0)
    error('Non-positive liquid-phase driving force encountered during NTU integration.');
end

NTU = trapz(x, 1./driving_force);

%% ----------------------- TOWER HEIGHT -----------------------------------

Z = HTU*NTU;

%% --------------------------- RESULTS -------------------------------------

disp('==============================================================')
disp('                NH3 STRIPPING RESULTS')
disp('==============================================================')

fprintf('\nTemperature               = %.2f K\n', T);
fprintf('Pressure                  = %.2f bar\n', P);
fprintf('Column diameter           = %.2f m\n', D);
fprintf('Column area               = %.6f m^2\n', Area);

fprintf('\nVLE cubic coefficients:\n');
fprintf('Aeq = %.9f\n', Aeq);
fprintf('Beq = %.9f\n', Beq);
fprintf('Ceq = %.9f\n', Ceq);
fprintf('Deq = %.9f\n', Deq);

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

figure('Name','Assignment 8 - NH3 Stripping','NumberTitle','off');
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
title('McCabe-Thiele Construction for NH_3 Stripping');
legend('Equilibrium curve','Operating line','Diagonal','Stage construction', ...
       'Specification points','Location','best');