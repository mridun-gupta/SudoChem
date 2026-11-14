%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To estimate the fugacity coefficient and fugacity of a mixuture.
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

% Universal Gas Constant
R = 0.08314472;          % bar.L/(mol.K)

% System Conditions
T = 345;                 % K
P = 1;                   % bar

% Mole Fractions (Equimolar Mixture)
y = [0.5 0.5];

% Number of Components
n = length(y);

%% -------------------- PURE COMPONENT DATA --------------------------------
% Component Order:
% 1 - Methane
% 2 - Ethane

Tc = [190.56 305.32];        % Critical Temperature (K)
Pc = [45.99 48.72];          % Critical Pressure (bar)
omega = [0.011 0.099];       % Acentric Factor

%% ---------------------- PR EOS PARAMETERS --------------------------------

% Allocate memory
Tr = zeros(1,n);
m = zeros(1,n);
alpha = zeros(1,n);
a = zeros(1,n);
b = zeros(1,n);

for i = 1:n

    % Reduced Temperature
    Tr(i) = T/Tc(i);

    % Soave parameter
    m(i) = 0.37464 ...
          + 1.54226*omega(i) ...
          - 0.26992*omega(i)^2;

    % Alpha parameter
    alpha(i) = (1 + m(i)*(1-sqrt(Tr(i))))^2;

    % PR attraction parameter
    a(i) = 0.45724 * R^2 * Tc(i)^2 ...
          * alpha(i) / Pc(i);

    % PR co-volume parameter
    b(i) = 0.07780 * R * Tc(i) / Pc(i);

end

%% ----------------- BINARY INTERACTION PARAMETERS -------------------------

% Assuming kij = 0

kij = zeros(n);

%% ---------------------- MIXING RULES -------------------------------------

am = 0;

for i = 1:n
    for j = 1:n

        am = am + y(i)*y(j)* ...
            sqrt(a(i)*a(j))*(1-kij(i,j));

    end
end

bm = sum(y.*b);

%% ------------------ DIMENSIONLESS PARAMETERS -----------------------------

A = am*P/(R^2*T^2);
B = bm*P/(R*T);

%% ------------------- COMPRESSIBILITY FACTOR ------------------------------

% Cubic Equation:
%
% Z^3 -(1-B)Z^2 +(A-3B^2-2B)Z -(AB-B^2-B^3)=0

coeff = [ ...
    1 ...
   -(1-B) ...
    (A-3*B^2-2*B) ...
   -(A*B-B^2-B^3)];

Zroots = roots(coeff);

% Keep only real roots
Zreal = Zroots(abs(imag(Zroots))<1e-8);

% Vapor root = largest root
Z = max(real(Zreal));

%% ---------------- FUGACITY COEFFICIENTS ----------------------------------

phi = zeros(1,n);

for i = 1:n

    % Summation term
    sumTerm = 0;

    for j = 1:n

        sumTerm = sumTerm + ...
            y(j)*sqrt(a(i)*a(j))*(1-kij(i,j));

    end

    term1 = (b(i)/bm)*(Z-1);

    term2 = -log(Z-B);

    term3 = A/(2*sqrt(2)*B);

    term4 = (2*sumTerm/am)-(b(i)/bm);

    term5 = log((Z+(1+sqrt(2))*B)/...
               (Z+(1-sqrt(2))*B));

    lnphi = term1 + term2 - term3*term4*term5;

    phi(i) = exp(lnphi);

end

%% ----------------------- FUGACITY ----------------------------------------

% Partial Fugacity
f = phi .* y * P;

%% ------------------------- RESULTS ---------------------------------------

disp('===========================================================')
disp('        Peng-Robinson Equation of State Results')
disp('===========================================================')

fprintf('\nTemperature          = %.2f K\n',T);
fprintf('Pressure             = %.2f bar\n',P);

fprintf('\nCompressibility Factor (Z) = %.6f\n',Z);

disp(' ')

component = {'Methane';'Ethane'};

ResultTable = table(component,...
                    y',...
                    phi',...
                    f',...
          'VariableNames',...
          {'Component','MoleFraction','FugacityCoefficient','Fugacity_bar'});

disp(ResultTable)

disp('===========================================================')