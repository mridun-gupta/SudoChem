%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To estimate the activity coefficients of a ternary mixture at 345 K
%      and 1 bar using the UNIQUAC model and to calculate the azeotropic
%      composition of the mixture.
%
% Author: Mridun Gupta, (IMT.CE, 2024)
%
% Roll Number: J24IMT624
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;
close all;

format short g;
format compact;

%% ----------------------- GIVEN DATA --------------------------------------

% Universal Gas Constant
% u is supplied as an energy parameter. Therefore, use J/(mol.K).
R = 8.314;                 % J/(mol.K)

% System Conditions
T = 345;                   % K
P = 1;                     % bar

% Component order:
% 1 - Benzene
% 2 - Toluene
% 3 - Water
component = {'Benzene'; 'Toluene'; 'Water'};

% Given liquid-phase mole fractions
x = [0.2 0.3 0.5];

% Number of components
n = length(x);

% Coordination number
z = 10;

%% ----------------------- UNIQUAC PARAMETERS ------------------------------

% Volume parameters (r_i)
r = [2.5755 3.1878 2.7694];

% Area parameters (q_i)
q = [2.588 2.634 2.400];

% Given average interaction parameters u_ij
u = [ ...
    1.000  1.216  0.203;
    0.617  1.000  0.048;
    0.838  0.612  1.000...
    ];

%% ----------------------- VALIDATION OF INPUTS ----------------------------

if abs(sum(x) - 1) > 1e-12
    error('Mole fractions must sum to 1.');
end

if any(x <= 0)
    error('All mole fractions must be positive.');
end

%% ----------------------- VOLUME AND AREA FRACTIONS -----------------------

% Volume fraction:
% phi_i = x_i*r_i / sum(x_j*r_j)
phi = (x .* r) / sum(x .* r);

% Area fraction:
% theta_i = x_i*q_i / sum(x_j*q_j)
theta = (x .* q) / sum(x .* q);

%% ----------------------- UNIQUAC l_i PARAMETER ---------------------------

% l_i = z/2 * (r_i - q_i) - (r_i - 1)
l = (z/2) .* (r - q) - (r - 1);

%% ----------------------- INTERACTION MATRIX ------------------------------

% tau_ji = exp[-(u_ji - u_ii)/(R*T)]
%
% For each row i, u(i,i) is the reference interaction energy u_ii.
tau = zeros(n);

for i = 1:n
    for j = 1:n
        tau(i,j) = exp(-(u(i,j) - u(i,i))/(R*T));
    end
end

%% ----------------------- COMBINATORIAL CONTRIBUTION ----------------------

% ln(gamma_i^C) =
% ln(phi_i/x_i) + (z/2)q_i*ln(theta_i/phi_i)
% + l_i - (phi_i/x_i)*sum(x_j*l_j)

sum_xl = sum(x .* l);

lnGammaC = zeros(1,n);

for i = 1:n
    lnGammaC(i) = ...
        log(phi(i)/x(i)) ...
        + (z/2)*q(i)*log(theta(i)/phi(i)) ...
        + l(i) ...
        - (phi(i)/x(i))*sum_xl;
end

%% ----------------------- RESIDUAL CONTRIBUTION ---------------------------

% ln(gamma_i^R) =
% q_i [ 1 - ln(sum_j theta_j*tau_ji)
%       - sum_j {theta_j*tau_ij / sum_k(theta_k*tau_kj)} ]

lnGammaR = zeros(1,n);

% Denominator for each j:
% denominator(j) = sum_k theta_k*tau_kj
denominator = theta * tau;

for i = 1:n

    % First summation: sum_j theta_j*tau_ji
    firstSum = 0;

    for j = 1:n
        firstSum = firstSum + theta(j)*tau(j,i);
    end

    % Second summation
    secondSum = 0;

    for j = 1:n
        secondSum = secondSum + ...
            theta(j)*tau(i,j)/denominator(j);
    end

    lnGammaR(i) = q(i) * ...
        (1 - log(firstSum) - secondSum);

end

%% ----------------------- TOTAL ACTIVITY COEFFICIENT ----------------------

lnGamma = lnGammaC + lnGammaR;
gamma = exp(lnGamma);

%% ----------------------- AZEOTROPIC COMPOSITION --------------------------

% alpha_12 = gamma_1/gamma_2 = x_2/x_1
% alpha_13 = gamma_1/gamma_3 = x_3/x_1
%
% Therefore:
%
% x1,az = 1/(1+alpha12+alpha13)
% x2,az = alpha12*x1,az
% x3,az = alpha13*x1,az

alpha12 = gamma(1)/gamma(2);
alpha13 = gamma(1)/gamma(3);

xAzeo = [ ...
    1 ...
    alpha12 ...
    alpha13];

xAzeo = xAzeo / sum(xAzeo);

%% --------------------------- RESULTS -------------------------------------

disp('==============================================================')
disp('                 UNIQUAC MODEL RESULTS')
disp('==============================================================')

fprintf('\nTemperature                = %.2f K\n', T);
fprintf('Pressure                   = %.2f bar\n', P);
fprintf('Coordination number (z)   = %.2f\n', z);

fprintf('\n')

ResultTable = table( ...
    component, ...
    x', ...
    r', ...
    q', ...
    phi', ...
    theta', ...
    l', ...
    gamma', ...
    'VariableNames', ...
    {'Component','MoleFraction','r','q','VolumeFraction', ...
     'AreaFraction','l','ActivityCoefficient'});

disp(ResultTable)

fprintf('\nAzeotropic composition by assignment method:\n');
fprintf('Benzene  = %.6f\n', xAzeo(1));
fprintf('Toluene  = %.6f\n', xAzeo(2));
fprintf('Water    = %.6f\n', xAzeo(3));
disp('--------------------')
fprintf('Sum      = %.6f\n', sum(xAzeo));

fprintf('\nActivity-coefficient ratios:\n');
fprintf('alpha12 = gamma_Benzene/gamma_Toluene = %.6f\n', alpha12);
fprintf('alpha13 = gamma_Benzene/gamma_Water   = %.6f\n', alpha13);

disp('==============================================================')
