%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To determine the equilibrium liquid mole fraction of a hypothetical
%      crystalline solute A in a binary A-S liquid using the UNIQUAC
%      activity-coefficient model and the solid-liquid equilibrium relation.
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

T = 298.15;                   % K, system temperature
TmA = 360.0;                  % K, melting temperature of solute A
dHfusA = 18000;               % J/mol, enthalpy of fusion of A
R = 8.314462618;              % J/(mol K)

% UNIQUAC structural parameters
rA = 2.50;
qA = 2.20;
rS = 1.40;
qS = 1.20;

% UNIQUAC interaction parameters at the specified temperature
% tau_ij is stored with row i and column j.
tauAS = 0.75;
tauSA = 1.35;
tau = [1.0  tauAS;
       tauSA 1.0];

% Standard UNIQUAC coordination number.
% The problem sheet introduces z but does not assign a value; z = 10 is used.
z = 10;

fprintf('==============================================================\n');
fprintf('          PROCESS SIMULATION LABORATORY-I : SLE\n');
fprintf('==============================================================\n\n');

fprintf('System temperature, T       = %.2f K\n',T);
fprintf('Solute melting temperature  = %.2f K\n',TmA);
fprintf('Enthalpy of fusion          = %.2f J/mol\n',dHfusA);
fprintf('UNIQUAC coordination number = %g\n\n',z);

%% ----------------------- SLE EQUILIBRIUM CONSTANT -----------------------

% Fusion-property relation, neglecting heat-capacity and pressure corrections:
% KSL = exp[-(dHfusA/R)*(1/T - 1/TmA)]
KSL = exp(-(dHfusA/R)*(1/T - 1/TmA));

%% ----------------------- SOLVE EQUILIBRIUM COMPOSITION -------------------

% At solid-liquid equilibrium: xA*gammaA = KSL.
% Solve in logarithmic form for numerical stability:
% ln(xA) + ln(gammaA) - ln(KSL) = 0.
F = @(xA) log(max(xA,realmin)) + ...
    log(uniquacGammaA(xA,rA,qA,rS,qS,z,tau)) - log(KSL);

xAeq = fzero(F,[1e-8 0.999999]);
xSeq = 1 - xAeq;

% Calculate the final UNIQUAC activity coefficients.
[gammaA,gamma] = uniquacGammaA(xAeq,rA,qA,rS,qS,z,tau);
gammaS = gamma(2);

% Ideal-liquid estimate: gammaA = 1, so xA_ideal = KSL.
xSideal = KSL;
Kcalc = xAeq*gammaA;
relError = abs((Kcalc-KSL)/KSL);
idealDeviation = 100*(xAeq-xSideal)/xSideal;

%% ----------------------- DISPLAY RESULTS ---------------------------------

fprintf('SLE equilibrium constant, KSL = %.10f\n',KSL);
fprintf('Equilibrium solute fraction, xA = %.10f\n',xAeq);
fprintf('Equilibrium solvent fraction, xS = %.10f\n',xSeq);
fprintf('UNIQUAC activity coefficient, gammaA = %.8f\n',gammaA);
fprintf('UNIQUAC activity coefficient, gammaS = %.8f\n',gammaS);
fprintf('Calculated xA*gammaA = %.10f\n',Kcalc);
fprintf('Relative SLE equilibrium residual = %.3e\n',relError);
fprintf('Ideal-liquid estimate, xA = KSL = %.10f\n',xSideal);
fprintf('Deviation from ideal-liquid estimate = %.6f %%\n',idealDeviation);

fprintf('\nFinal liquid composition:\n');
fprintf('xA + xS = %.10f\n',xAeq+xSeq);
fprintf('==============================================================\n');

%% ----------------------- EQUILIBRIUM RESIDUAL PLOT -----------------------

xPlot = linspace(1e-5,0.999,500);
FPlot = zeros(size(xPlot));
for i = 1:numel(xPlot)
    FPlot(i) = F(xPlot(i));
end

figure('Name','Solid-Liquid Equilibrium Residual','NumberTitle','off');
plot(xPlot,FPlot,'LineWidth',1.5);
hold on;
plot([min(xPlot),max(xPlot)],[0 0],'k--');
plot(xAeq,F(xAeq),'ro','MarkerFaceColor','r');
grid on;
xlabel('Liquid mole fraction of solute A, x_A');
ylabel('ln(x_A gamma_A / K_{SL})');
title('SLE Equilibrium Root Using UNIQUAC');
legend('Equilibrium residual','Zero residual','Calculated root', ...
       'Location','best');
hold off;

%% ----------------------- FINAL CHECKS ------------------------------------

if xAeq < 0 || xAeq > 1 || xSeq < 0 || xSeq > 1
    warning('A mole fraction is outside the physical range [0,1].');
end
if abs(xAeq+xSeq-1) > 1e-10
    warning('Liquid mole fractions do not sum to unity.');
end
if relError > 1e-7
    warning('The final SLE equilibrium residual is larger than expected.');
end

%% ----------------------- LOCAL UNIQUAC FUNCTION --------------------------

function [gammaA,gamma] = uniquacGammaA(xA,rA,qA,rS,qS,z,tau)

% Binary A-S UNIQUAC activity-coefficient calculation.
% The phase contains solute A and pseudocomponent solvent S.

xA = min(max(xA,1e-14),1-1e-14);
x = [xA,1-xA];
r = [rA,rS];
q = [qA,qS];

% UNIQUAC volume and surface fractions.
phi = (x.*r)/sum(x.*r);
theta = (x.*q)/sum(x.*q);

% Combinatorial contribution.
l = (z/2)*(r-q) - (r-1);
lnGammaC = log(phi./x) + (z/2)*q.*log(theta./phi) ...
           + l - (phi./x)*sum(x.*l);

% Residual contribution.
% S(j) = sum_i theta(i)*tau(i,j).
S = theta*tau;
term = zeros(1,2);
for i = 1:2
    term(i) = sum(theta.*tau(i,:)./S);
end
lnGammaR = q.*(1-log(S)-term);

lnGamma = lnGammaC + lnGammaR;
gamma = exp(lnGamma);
gammaA = gamma(1);

end
