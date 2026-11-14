%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To determine the dew-point temperature and equilibrium liquid
%      composition of a quaternary cyclohexane-benzene-toluene-n-heptane
%      vapour mixture at 1 bar using an ideal vapour phase and a
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
Tguess = 365;               % K, initial temperature guess
P = 1;                      % bar

% Component order
% 1 - Cyclohexane
% 2 - Benzene
% 3 - Toluene
% 4 - n-Heptane
component = {'Cyclohexane'; 'Benzene'; 'Toluene'; 'n-Heptane'};

% Given vapour-phase mole fractions
y = [0.40 0.20 0.25 0.15];

% Number of components
n = length(y);

% UNIQUAC coordination number
z = 10;

%% ------------------- VALIDATION OF INPUTS ---------------------------------

if abs(sum(y) - 1) > 1e-12
    error('Vapour mole fractions must sum to 1.');
end

if any(y <= 0)
    error('All vapour mole fractions must be positive.');
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
% Sum[y_i * P / Psat_i] = 1

T0 = idealDewTemperature(y,P,A,B,C);

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

% First liquid composition from ideal dew equation
x0 = y .* P ./ Psat0;
x0 = x0 / sum(x0);

fprintf('\nInitial ideal liquid composition:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},x0(i));
end

fprintf('Sum(x0) = %.12f\n',sum(x0));

%% ----------------------- UNIQUAC CALCULATION ------------------------------

[gamma0,phi0,theta0,l0,lnGammaC0,lnGammaR0,tau0] = ...
    uniquacGamma(x0,T0,r,q,z,uOverR,a41,b41,a14,b14);

xRaw0 = y .* P ./ (gamma0 .* Psat0);
S0 = sum(xRaw0);
x1 = xRaw0 / S0;

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

fprintf('\nCorrected dew scalar at T0:\n');
fprintf('S(T0) = Sum[y_i P/(gamma_i Psat_i)]\n');
fprintf('S(T0) = %.8f\n',S0);

fprintf('\nUpdated liquid composition after one UNIQUAC step:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},x1(i));
end
fprintf('Sum(x1) = %.12f\n',sum(x1));

%% ----------------------- ONE NEWTON ITERATION -----------------------------

dT = 0.01;

Splus = dewScalar(T0+dT,y,P,r,q,z,...
    uOverR,a41,b41,a14,b14,A,B,C);

Sminus = dewScalar(T0-dT,y,P,r,q,z,...
    uOverR,a41,b41,a14,b14,A,B,C);

dS_dT = (Splus - Sminus)/(2*dT);

if ~isscalar(dS_dT)
    error('Internal error: dS/dT is not scalar.');
end

T1 = T0 - (S0 - 1)/dS_dT;

fprintf('\ndS/dT = %.8f 1/K\n',dS_dT);
fprintf('One-iteration temperature = %.6f K\n',T1);
fprintf('One-iteration temperature = %.6f degC\n',T1 - 273.15);

%% ----------------------- FULL CONVERGED SOLUTION -------------------------

% Scalar bisection is used for the outer temperature equation:
%
% F(T) = Sum[y_i P/(gamma_i Psat_i)] - 1 = 0

Tlow = 350;
Thigh = 380;

Flow = dewResidual(Tlow,y,P,r,q,z,...
    uOverR,a41,b41,a14,b14,A,B,C);

Fhigh = dewResidual(Thigh,y,P,r,q,z,...
    uOverR,a41,b41,a14,b14,A,B,C);

if Flow*Fhigh > 0
    error('Dew-point root is not bracketed between 350 K and 380 K.');
end

tolT = 1e-10;
tolF = 1e-12;
maxIter = 200;

for k = 1:maxIter

    Tmid = (Tlow+Thigh)/2;

    Fmid = dewResidual(Tmid,y,P,r,q,z,...
        uOverR,a41,b41,a14,b14,A,B,C);

    if ~isscalar(Fmid)
        error('Dew residual must be scalar.');
    end

    if abs(Fmid) < tolF || abs(Thigh-Tlow) < tolT
        TD = Tmid;
        break;
    end

    if Flow*Fmid <= 0
        Thigh = Tmid;
        Fhigh = Fmid;
    else
        Tlow = Tmid;
        Flow = Fmid;
    end
end

if ~exist('TD','var')
    error('Dew-point temperature iteration did not converge.');
end

%% --------------------------- RESULTS -------------------------------------

[x,gamma,phi,theta,l,lnGammaC,lnGammaR,tau,S] = ...
    dewState(TD,y,P,r,q,z,uOverR,a41,b41,a14,b14,A,B,C);

Psat = saturationPressures(TD,A,B,C);

% Ideal-vapour / UNIQUAC-liquid equilibrium:
%
% y_i P = x_i gamma_i Psat_i

yCheck = x .* gamma .* Psat / P;

fprintf('\n==============================================================\n');
fprintf('                 DEW POINT RESULTS\n');
fprintf('==============================================================\n');

fprintf('\nDew-point temperature = %.8f K\n',TD);
fprintf('Dew-point temperature = %.8f degC\n',TD-273.15);
fprintf('Pressure              = %.8f bar\n',P);

fprintf('\nFinal activity coefficients:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},gamma(i));
end

fprintf('\nFinal saturation pressures [bar]:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},Psat(i));
end

fprintf('\nEquilibrium liquid composition:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},x(i));
end

fprintf('\nComposition check:\n');
fprintf('Sum(x_i) = %.12f\n',sum(x));

fprintf('\nIndependent vapour-composition check:\n');
for i = 1:n
    fprintf('%-15s %.8f\n',component{i},yCheck(i));
end

fprintf('Sum(y_i(check)) = %.12f\n',sum(yCheck));

fprintf('\nDew-point equation check:\n');
fprintf('Sum[y_i P/(gamma_i Psat_i)] = %.12f\n',S);
fprintf('Residual = %.12e\n',S-1);

ResultTable = table( ...
    component, ...
    y', ...
    x', ...
    r', ...
    q', ...
    phi', ...
    theta', ...
    l', ...
    gamma', ...
    Psat', ...
    yCheck', ...
    'VariableNames', ...
    {'Component','VapourMoleFraction','LiquidMoleFraction','r','q',...
     'VolumeFraction','AreaFraction','l','ActivityCoefficient',...
     'Psat_bar','VapourCheck'});

fprintf('\nResult table:\n');
disp(ResultTable);

fprintf('==============================================================\n');

%% ============================== FUNCTIONS ================================

function T = idealDewTemperature(y,P,A,B,C)

    f = @(T) sum(y .* P ./ (10.^(A-B./(T+C)))) - 1;

    low = 350;
    high = 380;

    Flow = f(low);
    Fhigh = f(high);

    if Flow*Fhigh > 0
        error('Ideal dew-point root is not bracketed.');
    end

    for k = 1:150

        Tmid = (low+high)/2;
        Fmid = f(Tmid);

        if abs(Fmid) < 1e-12 || abs(high-low) < 1e-10
            T = Tmid;
            return;
        end

        if Flow*Fmid <= 0
            high = Tmid;
            Fhigh = Fmid;
        else
            low = Tmid;
            Flow = Fmid;
        end

    end

    T = (low+high)/2;

end

function value = dewResidual(T,y,P,r,q,z,...
    uOverR,a41,b41,a14,b14,A,B,C)

    S = dewScalar(T,y,P,r,q,z,...
        uOverR,a41,b41,a14,b14,A,B,C);

    value = S - 1;

    if ~isscalar(value)
        error('Dew residual must be scalar.');
    end

end

function S = dewScalar(T,y,P,r,q,z,...
    uOverR,a41,b41,a14,b14,A,B,C)

    [~,~,~,~,~,~,~,~,S] = dewState(T,y,P,r,q,z,...
        uOverR,a41,b41,a14,b14,A,B,C);

    S = double(S);

    if ~isscalar(S)
        error('Dew scalar must be scalar.');
    end

end

function [x,gamma,phi,theta,l,lnGammaC,lnGammaR,tau,S] = ...
    dewState(T,y,P,r,q,z,uOverR,a41,b41,a14,b14,A,B,C)

    Psat = saturationPressures(T,A,B,C);

    % Initial ideal liquid composition
    x = y .* P ./ Psat;
    x = x / sum(x);

    maxIter = 1000;
    tol = 1e-12;
    damping = 0.5;

    for k = 1:maxIter

        [gamma,phi,theta,l,lnGammaC,lnGammaR,tau] = ...
            uniquacGamma(x,T,r,q,z,uOverR,a41,b41,a14,b14);

        xRaw = y .* P ./ (gamma .* Psat);
        S = sum(xRaw);

        xNew = xRaw / S;

        % Damped fixed-point update
        xNew = damping*xNew + (1-damping)*x;

        if max(abs(xNew-x)) < tol

            x = xNew;

            [gamma,phi,theta,l,lnGammaC,lnGammaR,tau] = ...
                uniquacGamma(x,T,r,q,z,uOverR,a41,b41,a14,b14);

            xRaw = y .* P ./ (gamma .* Psat);
            S = sum(xRaw);

            return;
        end

        x = xNew;
    end

    error('Inner liquid-composition iteration did not converge.');

end

function Psat = saturationPressures(T,A,B,C)

    Psat = 10.^(A-B./(T+C));
    Psat = reshape(Psat,1,[]);

end

function [gamma,phi,theta,l,lnGammaC,lnGammaR,tau] = ...
    uniquacGamma(x,T,r,q,z,uOverR,a41,b41,a14,b14)

    x = reshape(x,1,[]);
    r = reshape(r,1,[]);
    q = reshape(q,1,[]);

    n = length(x);

    % Volume fraction
    phi = (x .* r) / sum(x .* r);

    % Area fraction
    theta = (x .* q) / sum(x .* q);

    % Structural parameter
    l = (z/2) .* (r-q) - (r-1);

    % Temperature-dependent interaction matrix
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

    sum_x_l = sum(x .* l);

    lnGammaC = zeros(1,n);

    for i = 1:n

        lnGammaC(i) = ...
            log(phi(i)/x(i)) ...
            + (z/2)*q(i)*log(theta(i)/phi(i)) ...
            + l(i) ...
            - (phi(i)/x(i))*sum_x_l;

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

    lnGamma = lnGammaC + lnGammaR;
    gamma = exp(lnGamma);

end
