%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To determine the theoretical stages up to the feed plate, feed plate
%      location and total theoretical stages for the separation of an
%      ethanol-water mixture by continuous distillation using the
%      McCabe-Thiele method and Antoine equation for VLE.
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

% Feed and operating conditions
F = 100;                    % Feed flow rate, kg/h
T = 365;                    % Feed/operating temperature, K
P = 1;                      % Operating pressure, bar
q = 0.60;                   % Liquid fraction in feed

% Product specifications
xD = 0.90;                  % Distillate mole fraction
xB = 0.10;                  % Bottoms mole fraction
xF = 0.50;                  % Feed mole fraction
RD = 2.00;                  % Reflux ratio, R/D

% Antoine constants supplied in the assignment
% ln(Psat) = A - B/(T + C)
A = 12.2917;
B = 3803.98;
C = -41.68;

%% ----------------------- VALIDATION OF INPUTS ----------------------------

if q <= 0 || q >= 1
    error('q must lie strictly between 0 and 1.');
end

if any([xD xB xF] < 0) || any([xD xB xF] > 1)
    error('All compositions must lie between 0 and 1.');
end

if xD <= xF || xF <= xB
    error('The required ordering xD > xF > xB is not satisfied.');
end

if P <= 0 || F <= 0
    error('Pressure and feed flow rate must be positive.');
end

if RD < 0
    error('Reflux ratio must be non-negative.');
end

%% ----------------------- SATURATION PRESSURE ----------------------------

% Antoine equation in natural-log form
Psat = exp(A - B/(T + C));

%% ----------------------- FEED LINE --------------------------------------

% q-line:
% y = m_F*x + c_F
m_F = -q/(1-q);
c_F = xF/(1-q);

%% ----------------------- RECTIFYING LINE --------------------------------

% Rectifying line:
% y = m_R*x + c_R
m_R = RD/(RD + 1);
c_R = xD/(RD + 1);

%% ----------------------- FEED/RECTIFYING INTERSECTION -------------------

% Solve:
% m_F*x + c_F = m_R*x + c_R
M = [m_F -1; m_R -1];
Cvec = [-c_F; -c_R];

XY = M\Cvec;
x_F = XY(1);
y_F = XY(2);

%% ----------------------- STRIPPING LINE ---------------------------------

% Equilibrium point corresponding to bottoms composition
% y_B,eq = xB*Psat/P
Y_B_eq = xB*Psat/P;

% Stripping line passes through (xB, Y_B_eq) and (x_F, y_F)
m_B = (y_F - Y_B_eq)/(x_F - xB);
c_B = Y_B_eq - m_B*xB;

%% ----------------------- MCBABE-THIELE STAGE CALCULATION ---------------

% The equilibrium relation from the supplied Antoine equation is:
% y_eq = x*Psat/P
%
% Starting point is (xD, xD). For each stage, move horizontally to the
% equilibrium line, then vertically to the appropriate operating line.

x_current = xD;
y_current = xD;

N_complete = 0;
N_up_to_feed = NaN;
N_total = NaN;
feedplate = NaN;

x_stage = xD;
y_stage = xD;

maxStages = 500;

for stage = 1:maxStages

    % Invert the Antoine equilibrium relation y = x*Psat/P
    x_eq = y_current*P/Psat;

    if x_eq < 0 || x_eq > 1
        error('Equilibrium composition left the physical range 0 <= x <= 1.');
    end

    % Select rectifying or stripping operating line based on x-position.
    if x_eq >= x_F
        y_next = m_R*x_eq + c_R;
        section = 'Rectifying'; %#ok<NASGU>
    else
        if isnan(feedplate)
            % The first stage entering the stripping section is the feed
            % plate boundary for this graphical construction.
            feedplate = N_complete + 1;
        end
        y_next = m_B*x_eq + c_B;
        section = 'Stripping'; %#ok<NASGU>
    end

    % Store staircase coordinates
    x_stage(end+1) = x_eq; %#ok<SAGROW>
    y_stage(end+1) = y_current; %#ok<SAGROW>
    x_stage(end+1) = x_eq; %#ok<SAGROW>
    y_stage(end+1) = y_next; %#ok<SAGROW>

    % Count the completed stage
    N_complete = N_complete + 1;

    % Record the stage count at feed-section transition.
    if isnan(N_up_to_feed) && x_eq < x_F
        N_up_to_feed = N_complete;
    end

    % Bottoms target reached
    if x_eq <= xB
        N_total = N_complete;
        break;
    end

    % Detect the limiting/pinch condition near the bottoms point.
    if x_eq > xB && abs(x_eq - xB) < 1e-7 && abs(y_next - Y_B_eq) < 1e-7
        N_total = Inf;
        break;
    end

    x_current = x_eq; %#ok<NASGU>
    y_current = y_next;
end

% If the loop reached its limit, report that the specification is not
% reached with a finite number of theoretical stages under the supplied
% Antoine equilibrium model.
if isnan(N_total)
    N_total = Inf;
end

%% ----------------------- OUTPUT SUMMARY ---------------------------------

disp('==============================================================')
disp('         ETHANOL-WATER DISTILLATION RESULTS')
disp('==============================================================')

fprintf('\nFeed flow rate             = %.2f kg/h\n', F);
fprintf('Temperature                = %.2f K\n', T);
fprintf('Pressure                   = %.2f bar\n', P);
fprintf('Feed liquid fraction, q   = %.4f\n', q);
fprintf('Distillate composition, xD= %.4f\n', xD);
fprintf('Bottoms composition, xB   = %.4f\n', xB);
fprintf('Feed composition, xF      = %.4f\n', xF);
fprintf('Reflux ratio, R/D          = %.4f\n', RD);

fprintf('\nAntoine saturation pressure:\n');
fprintf('Psat = %.9f bar\n', Psat);

fprintf('\nFeed line:\n');
fprintf('m_F = %.6f\n', m_F);
fprintf('c_F = %.6f\n', c_F);

fprintf('\nRectifying line:\n');
fprintf('m_R = %.6f\n', m_R);
fprintf('c_R = %.6f\n', c_R);

fprintf('\nFeed/rectifying intersection:\n');
fprintf('x_F,int = %.6f\n', x_F);
fprintf('y_F,int = %.6f\n', y_F);

fprintf('\nStripping line:\n');
fprintf('m_B = %.6f\n', m_B);
fprintf('c_B = %.6f\n', c_B);

if isfinite(N_up_to_feed)
    fprintf('\nStages up to feed transition = %.6f\n', N_up_to_feed);
else
    fprintf('\nStages up to feed transition = not reached\n');
end

if isfinite(feedplate)
    fprintf('Feed plate location         = %d\n', round(feedplate));
else
    fprintf('Feed plate location         = not reached\n');
end

if isfinite(N_total)
    fprintf('Total theoretical stages    = %.6f\n', N_total);
else
    fprintf('Total theoretical stages    = INFINITE / PINCH\n');
end

disp('==============================================================')

%% --------------------------- MCBABE-THIELE PLOT --------------------------

x_plot = linspace(0, 1, 500);
y_eq_plot = x_plot*Psat/P;
y_R_plot = m_R*x_plot + c_R;
y_B_plot = m_B*x_plot + c_B;
y_q_plot = m_F*x_plot + c_F;

figure('Name','Assignment 9 - Ethanol-Water Distillation','NumberTitle','off');
plot(x_plot, y_eq_plot, 'LineWidth', 1.5);
hold on;
plot(x_plot, y_R_plot, 'LineWidth', 1.5);
plot(x_plot, y_B_plot, 'LineWidth', 1.5);
plot(x_plot, y_q_plot, 'LineWidth', 1.2);
plot([0 1], [0 1], '--', 'LineWidth', 1.0);
plot(x_stage, y_stage, '-k', 'LineWidth', 1.0);
plot([xB xD], [Y_B_eq xD], 'ko', 'MarkerFaceColor', 'k');
plot(x_F, y_F, 'ks', 'MarkerFaceColor', 'k');
hold off;

grid on;
xlim([0 1]);
ylim([0 1.2]);
xlabel('Liquid composition, x');
ylabel('Vapour composition, y');
title('McCabe-Thiele Diagram for Ethanol-Water Distillation');
legend('Equilibrium curve','Rectifying line','Stripping line','q-line', ...
       'Diagonal','Stage construction','End points','Feed intersection', ...
       'Location','best');