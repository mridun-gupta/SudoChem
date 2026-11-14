%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To determine the liquid-liquid equilibrium composition of a ternary
%      benzene + toluene + water system at 345 K and 1 bar using the
%      UNIQUAC activity-coefficient model and the Rachford-Rice equation,
%      with the phase function calculated using the bisection method.
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

T = 345.0;                    % K
P = 1.0;                      % bar

% UNIQUAC structural parameters
r = [2.5755 3.1878 2.7694];
q = [2.5880 2.6340 2.4000];

% Components:
% 1 = Benzene
% 2 = Toluene
% 3 = Water

% The supplied interaction matrix is used directly as tau_ij.
tau = [ ...
    1.000 1.216 0.203;
    0.617 1.000 0.048;
    0.838 0.612 1.000];

% Fixed random numbers used to make the five calculations reproducible.
randData = [ ...
    0.04057113 0.48922081 0.62063136 0.93756455 0.11081636 0.72109201;
    0.38509336 0.25933210 0.56744907 0.16888821 0.51703134 0.70957934;
    0.88794248 0.49237007 0.31752391 0.43830970 0.22357983 0.16000201;
    0.24494812 0.10129541 0.38828695 0.84007831 0.65317463 0.17400825;
    0.68929575 0.44612981 0.26133101 0.07452112 0.08904598 0.36789993];

nTie = size(randData,1);

fprintf('==============================================================\n');
fprintf('              PROCESS SIMULATION LAB-I : LLE\n');
fprintf('==============================================================\n\n');

fprintf('Temperature = %.2f K\n',T);
fprintf('Pressure    = %.2f bar\n',P);
fprintf('Components  = Benzene + Toluene + Water\n\n');

fprintf(['Tie   z1       z2       z3       Ext1     Ext2     Ext3     ' ...
         'Raf1     Raf2     Raf3     psi       L_aq/F    Iter\n']);

results = zeros(nTie,12);

for t = 1:nTie

    a = randData(t,1:3);
    b = randData(t,4:6);

    % Organic-rich initial guess: Extract
    ext0 = normalize3([a(1)+0.5, a(2)+0.3, 0.02*a(3)]);

    % Aqueous-rich initial guess: Raffinate
    raf0 = normalize3([0.03*b(1), 0.03*b(2), b(3)+0.5]);

    [ext_final,raf_final,psi,z,gamma_ext,gamma_raf,K,outerIter] = ...
        rachfordriceLLE(ext0,raf0,r,q,tau);

    % psi = extract/feed fraction.
    % Therefore L_aq/F = 1 - psi.
    L_aq_F = 1-psi;

    results(t,:) = [z ext_final raf_final psi L_aq_F outerIter];

    fprintf('%3d  %7.4f  %7.4f  %7.4f  %7.4f  %7.4f  %7.4f  %7.4f  %7.4f  %7.4f  %8.5f  %8.5f  %3d\n', ...
        t,z(1),z(2),z(3),ext_final(1),ext_final(2),ext_final(3), ...
        raf_final(1),raf_final(2),raf_final(3),psi,L_aq_F,outerIter);

    fprintf('  gamma Extract   = [%.6f %.6f %.6f]\n',gamma_ext);
    fprintf('  gamma Raffinate = [%.6f %.6f %.6f]\n',gamma_raf);
    fprintf('  K               = [%.6e %.6e %.6e]\n\n',K);
end

fprintf('==============================================================\n');
fprintf('Extract = organic-rich phase\n');
fprintf('Raffinate = aqueous-rich phase\n');
fprintf('psi = Extract/F\n');
fprintf('L_aq/F = 1 - psi\n');
fprintf('==============================================================\n');

%% ----------------------- LOCAL FUNCTIONS ---------------------------------

function [ext_final,raf_final,psi,z,gamma_ext,gamma_raf,K,outerIter] = ...
    rachfordriceLLE(ext0,raf0,r,q,tau)

% ext = organic-rich phase
% raf = aqueous-rich phase
% K_i = gamma_i,aq / gamma_i,org

ext = normalize3(ext0);
raf = normalize3(raf0);

% The feed point is selected from the initial phase pair and kept fixed.
z = normalize3((ext+raf)/2);

tol = 1e-3;
maxOuter = 200;

for outerIter = 1:maxOuter

    % UNIQUAC activity coefficients
    gamma_ext = uniquac_call(ext,r,q,tau);
    gamma_raf = uniquac_call(raf,r,q,tau);

    % Force row-vector orientation before Rachford-Rice operations.
    ext = ext(:).';
    raf = raf(:).';
    z = z(:).';
    gamma_ext = gamma_ext(:).';
    gamma_raf = gamma_raf(:).';

    K = (gamma_raf ./ gamma_ext);
    K = K(:).';

    % Rachford-Rice equation
    RR = @(psi) sum((K-1).*z ./ (1+(K-1).*psi));

    psi0 = 0;
    psi1 = 1;

    f0 = RR(psi0);
    f1 = RR(psi1);

    % The important error fix:
    % f0 and f1 are now guaranteed to be scalar values.
    if ~isscalar(f0) || ~isscalar(f1)
        error('Rachford-Rice residual must be scalar. Check vector dimensions.');
    end

    if f0*f1 > 0
        error(['No Rachford-Rice root in [0,1] for this phase pair. ' ...
               'Change the initial random phase compositions.']);
    end

    % Bisection of Rachford-Rice equation
    for b = 1:200

        psi_half = (psi0+psi1)/2;
        fhalf = RR(psi_half);

        if abs(fhalf) < 1e-10 || abs(psi1-psi0) < 1e-10
            break;
        end

        if f0*fhalf < 0
            psi1 = psi_half;
            f1 = fhalf;
        else
            psi0 = psi_half;
            f0 = fhalf;
        end
    end

    psi = (psi0+psi1)/2;

    % Rachford-Rice phase update
    raf_new = z ./ (1+(K-1).*psi);
    ext_new = K .* raf_new;

    raf_new = normalize3(raf_new);
    ext_new = normalize3(ext_new);

    if norm(abs(raf_new-raf)) < tol && ...
       norm(abs(ext_new-ext)) < tol

        ext_final = ext_new;
        raf_final = raf_new;

        gamma_ext = uniquac_call(ext_final,r,q,tau);
        gamma_raf = uniquac_call(raf_final,r,q,tau);

        gamma_ext = gamma_ext(:).';
        gamma_raf = gamma_raf(:).';

        K = gamma_raf ./ gamma_ext;
        K = K(:).';

        return;
    end

    ext = ext_new;
    raf = raf_new;
end

error('LLE outer iteration did not converge within the maximum iterations.');

end

function gamma = uniquac_call(x,r,q,tau)

% Force all vectors to row vectors.
x = x(:).';
r = r(:).';
q = q(:).';

x = normalize3(x);

% UNIQUAC volume and area fractions
phi = (x.*r) / sum(x.*r);
theta = (x.*q) / sum(x.*q);

% Combinatorial contribution
l = 5*(r-q) - (r-1);

lnGammaC = log(phi./x) + 5*q.*log(theta./phi) ...
           + l - (phi./x)*sum(x.*l);

% Residual contribution
%
% S(j) = sum(i) theta(i)*tau(i,j)
S = theta*tau;

% term(i) = sum(j) theta(j)*tau(i,j)/S(j)
%
% The explicit loop is intentional. It prevents MATLAB implicit
% expansion from producing a 3-by-3 matrix.
term = zeros(1,3);

for i = 1:3
    for j = 1:3
        term(i) = term(i) + theta(j)*tau(i,j)/S(j);
    end
end

lnGammaR = q .* (1 - log(S) - term);

lnGamma = lnGammaC + lnGammaR;
gamma = exp(lnGamma);

% Always return a row vector.
gamma = gamma(:).';

end

function x = normalize3(x)

x = x(:).';
x = max(x,1e-14);
x = x/sum(x);

end