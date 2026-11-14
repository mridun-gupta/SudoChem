%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To determine the bubble-point temperature and equilibrium vapour
%      composition of a quaternary cyclohexane-benzene-toluene-n-heptane
%      liquid mixture at 1 bar using an ideal vapour phase and a
%      non-ideal liquid phase modelled by the UNIQUAC equation.
%
% Author: Mridun Gupta
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
close all;

format short g;
format compact;

%% ----------------------- GIVEN DATA --------------------------------------

% System conditions
Tguess = 360;               % K, initial temperature guess
P = 1;                      % bar

% Component order
% 1 - Cyclohexane
% 2 - Benzene
% 3 - Toluene
% 4 - n-Heptane
component = {'Cyclohexane'; 'Benzene'; 'Toluene'; 'n-Heptane'};

% Given liquid-phase mole fractions
x = [0.40 0.20 0.25 0.15];

% Number of components
n = length(x);

% UNIQUAC coordination number
z = 10;

%% ------------------- VALIDATION OF INPUTS ---------------------------------

if abs(sum(x) - 1) > 1e-12
    error('Liquid mole fractions must sum to 1.');
end

if any(x <= 0)
    error('All liquid mole fractions must be positive.');
end

if P <= 0
    error('Pressure must be positive.');
end

%% ----------------------- PURE-COMPONENT DATA ------------------------------

% Antoine equation:
%
% log10(Psat) = A - B/(T + C)
%
% T in K and Psat in bar.

A = [4.13983  4.72583  4.07827  4.02832];
B = [1316.554 1660.652 1343.943 1268.636];
C = [-35.581 -1.461 -53.773 -56.199];

%% ----------------------- UNIQUAC PARAMETERS -------------------------------

% Structural parameters
r = [4.0464 3.1878 3.9228 5.1700];
q = [3.2400 2.4000 2.9680 4.4000];

%% ----------------------- INTERACTION PARAMETERS ---------------------------

% Five binary pairs are represented using:
%
% tau_ij = exp[-(Delta_u_ij/R)/T]
%
% Delta_u_ij/R values are in K.
%
% Component order:
% 1 - Cyclohexane
% 2 - Benzene
% 3 - Toluene
% 4 - n-Heptane

uOverR = zeros(n,n);

% Cyclohexane <-> Benzene
uOverR(1,2) =  69.48;
uOverR(2,1) = -16.69;

% Cyclohexane <-> Toluene
uOverR(1,3) =  83.67;
uOverR(3,1) = -44.04;

% Benzene <-> Toluene
uOverR(2,3) = -220.57;
uOverR(3,2) = 330.69;

% Benzene <-> n-Heptane
uOverR(2,4) = -32.03;
uOverR(4,2) =  87.50;

% Toluene <-> n-Heptane
uOverR(3,4) = -72.96;
uOverR(4,3) = 108.24;

% Cyclohexane <-> n-Heptane:
% ln(tau_41) = a41 + b41/T
% ln(tau_14) = a14 + b14/T

a41 = -0.8744;
b41 =  90.41;

a14 =  0.6985;
b14 = -80.76;

%% ------------------- IDEAL-LIQUID STARTING ESTIMATE -----------------------

% For the first estimate, temporarily assume gamma_i = 1:
%
% Sum(x_i * Psat_i) = P

T0 = idealBubbleTemperature(x,P,A,B,C);

fprintf('\n==============================================================\n');
fprintf('IDEAL-LIQUID STARTING ESTIMATE\n');
fprintf('==============================================================\n');

fprintf('\nInitial temperature estimate = %.6f K\n',T0);
fprintf('Initial temperature estimate = %.6f degC\n',T0 - 273.15);

Psat0 = saturationPressures(T0,A,B,C);

fprintf('\nSaturation pressures at initial temperature [bar]:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},Psat0(i));
end

fprintf('\nIdeal bubble-pressure sum:\n');
fprintf('Sum(x_i Psat_i) = %.8f bar\n',sum(x .* Psat0));

%% ----------------------- UNIQUAC CALCULATION ------------------------------

[gamma0,phi0,theta0,l0,lnGammaC0,lnGammaR0,tau0] = ...
    uniquacGamma(x,T0,r,q,z,uOverR,a41,b41,a14,b14);

F0 = bubbleResidual(T0,x,P,r,q,z,...
    uOverR,a41,b41,a14,b14,A,B,C);

fprintf('\n==============================================================\n');
fprintf('ONE UNIQUAC ITERATION FOR HAND CALCULATION\n');
fprintf('==============================================================\n');

fprintf('\nVolume fractions phi_i:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},phi0(i));
end

fprintf('\nArea fractions theta_i:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},theta0(i));
end

fprintf('\nl_i values:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},l0(i));
end

fprintf('\nUNIQUAC tau matrix at T0:\n');
disp(tau0);

fprintf('\nCombinatorial contribution ln(gamma_i^C):\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},lnGammaC0(i));
end

fprintf('\nResidual contribution ln(gamma_i^R):\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},lnGammaR0(i));
end

fprintf('\nActivity coefficients gamma_i:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},gamma0(i));
end

fprintf('\nCorrected bubble residual at T0:\n');
fprintf('F(T0) = Sum(x_i gamma_i Psat_i) - P\n');
fprintf('F(T0) = %.8f bar\n',F0);

%% ----------------------- ONE NEWTON ITERATION -----------------------------

% Numerical derivative for the one-iteration hand-calculation analogue.

dT = 0.01;

Fplus = bubbleResidual(T0+dT,x,P,r,q,z,...
    uOverR,a41,b41,a14,b14,A,B,C);

Fminus = bubbleResidual(T0-dT,x,P,r,q,z,...
    uOverR,a41,b41,a14,b14,A,B,C);

dF_dT = (Fplus-Fminus)/(2*dT);

if ~isscalar(dF_dT)
    error('Internal error: dF/dT must be scalar.');
end

T1 = T0 - F0/dF_dT;

fprintf('\ndF/dT = %.8f bar/K\n',dF_dT);
fprintf('One-iteration temperature = %.6f K\n',T1);
fprintf('One-iteration temperature = %.6f degC\n',T1-273.15);

%% ----------------------- FULL CONVERGED SOLUTION -------------------------

% Final scalar root:
%
% F(T) = Sum(x_i gamma_i Psat_i) - P = 0

bubbleResidualFinal = @(T) bubbleResidual(T,x,P,r,q,z,...
    uOverR,a41,b41,a14,b14,A,B,C);

TB = fzero(bubbleResidualFinal,[350 370]);

if ~isscalar(TB)
    error('Internal error: bubble-point temperature must be scalar.');
end

[gamma,phi,theta,l,lnGammaC,lnGammaR,tau] = ...
    uniquacGamma(x,TB,r,q,z,uOverR,a41,b41,a14,b14);

Psat = saturationPressures(TB,A,B,C);

% Ideal-vapour / UNIQUAC-liquid equilibrium:
%
% y_i P = x_i gamma_i Psat_i

y = x .* gamma .* Psat / P;

%% --------------------------- RESULTS -------------------------------------

fprintf('\n==============================================================\n');
fprintf('                 BUBBLE POINT RESULTS\n');
fprintf('==============================================================\n');

fprintf('\nBubble-point temperature = %.8f K\n',TB);
fprintf('Bubble-point temperature = %.8f degC\n',TB-273.15);
fprintf('Pressure                = %.8f bar\n',P);

fprintf('\nFinal activity coefficients:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},gamma(i));
end

fprintf('\nFinal saturation pressures [bar]:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},Psat(i));
end

fprintf('\nEquilibrium vapour composition:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},y(i));
end

fprintf('\nComposition check:\n');
fprintf('Sum(y_i) = %.12f\n',sum(y));

fprintf('\nBubble-point equation check:\n');
fprintf('Sum(x_i gamma_i Psat_i) = %.12f bar\n',...
    sum(x .* gamma .* Psat));

fprintf('Residual = %.12e bar\n',...
    bubbleResidualFinal(TB));

ResultTable = table( ...
    component, ...
    x', ...
    r', ...
    q', ...
    phi', ...
    theta', ...
    l', ...
    gamma', ...
    Psat', ...
    y', ...
    'VariableNames', ...
    {'Component','LiquidMoleFraction','r','q','VolumeFraction',...
     'AreaFraction','l','ActivityCoefficient','Psat_bar',...
     'VapourMoleFraction'});

fprintf('\nResult table:\n');
disp(ResultTable);

fprintf('==============================================================\n');

%% ============================== FUNCTIONS ================================

function T = idealBubbleTemperature(x,P,A,B,C)
%IDEALBUBBLETEMPERATURE Solves the ideal-liquid bubble equation.

    f = @(T) sum(x .* 10.^(A-B./(T+C))) - P;

    Tlow = 350;
    Thigh = 370;

    Flow = f(Tlow);
    Fhigh = f(Thigh);

    if Flow*Fhigh > 0
        error('Ideal bubble-point root is not bracketed.');
    end

    for k = 1:150

        Tmid = (Tlow+Thigh)/2;
        Fmid = f(Tmid);

        if abs(Fmid) < 1e-12 || abs(Thigh-Tlow) < 1e-10
            T = Tmid;
            return;
        end

        if Flow*Fmid <= 0
            Thigh = Tmid;
            Fhigh = Fmid;
        else
            Tlow = Tmid;
            Flow = Fmid;
        end
    end

    T = (Tlow+Thigh)/2;
end

function value = bubbleResidual(T,x,P,r,q,z,...
    uOverR,a41,b41,a14,b14,A,B,C)
%BUBBLERESIDUAL Returns the scalar bubble-point residual.

    gamma = uniquacGamma(x,T,r,q,z,uOverR,a41,b41,a14,b14);

    Psat = saturationPressures(T,A,B,C);

    value = sum(x .* gamma .* Psat) - P;

    value = double(value);

    if ~isscalar(value)
        error('Bubble residual must be scalar.');
    end
end

function Psat = saturationPressures(T,A,B,C)
%SATURATIONPRESSURES Returns saturation pressures in bar.

    Psat = 10.^(A-B./(T+C));
    Psat = reshape(Psat,1,[]);
end

function [gamma,phi,theta,l,lnGammaC,lnGammaR,tau] = ...
    uniquacGamma(x,T,r,q,z,uOverR,a41,b41,a14,b14)
%UNIQUACGAMMA Calculates UNIQUAC activity coefficients.

    x = reshape(x,1,[]);
    r = reshape(r,1,[]);
    q = reshape(q,1,[]);

    n = length(x);

    phi = (x .* r) / sum(x .* r);
    theta = (x .* q) / sum(x .* q);

    l = (z/2) .* (r-q) - (r-1);

    tau = zeros(n);

    for i = 1:n
        for j = 1:n

            if i == j

                tau(i,j) = 1;

            elseif i == 1 && j == 4

                tau(i,j) = exp(a14 + b14/T);

            elseif i == 4 && j == 1

                tau(i,j) = exp(a41 + b41/T);

            else

                tau(i,j) = exp(-uOverR(i,j)/T);

            end
        end
    end

    %% ----------------------- COMBINATORIAL CONTRIBUTION ------------------

    sum_xl = sum(x .* l);

    lnGammaC = zeros(1,n);

    for i = 1:n

        lnGammaC(i) = ...
            log(phi(i)/x(i)) ...
            + (z/2)*q(i)*log(theta(i)/phi(i)) ...
            + l(i) ...
            - (phi(i)/x(i))*sum_xl;

    end

    %% ----------------------- RESIDUAL CONTRIBUTION -----------------------

    lnGammaR = zeros(1,n);

    denominator = theta * tau;

    for i = 1:n

        firstSum = 0;

        for j = 1:n
            firstSum = firstSum + theta(j)*tau(j,i);
        end

        secondSum = 0;

        for j = 1:n
            secondSum = secondSum + ...
                theta(j)*tau(i,j)/denominator(j);
        end

        lnGammaR(i) = q(i) * ...
            (1-log(firstSum)-secondSum);

    end

    %% ----------------------- TOTAL ACTIVITY COEFFICIENT ------------------

    gamma = exp(lnGammaC + lnGammaR);

end
