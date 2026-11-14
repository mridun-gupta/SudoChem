%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To determine the vapour-liquid equilibrium composition of a binary
%      mixture of isobutene and hydrogen sulphide at 25 degC and 5 bar
%      using the 3-suffix Margules activity-coefficient model and the
%      Newton-Raphson method, with a physical range safeguard for the
%      liquid mole fraction.
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

% System conditions
T_C = 25;                    % Temperature, degC
T = T_C + 273.15;            % Temperature, K
P = 5.0;                     % Pressure, bar
R = 8.314462618;              % J/(mol.K)

% 3-suffix Margules parameters
D = 4640;                     % J/mol
E = -1700;                    % J/mol

% Antoine constants:
% log10(Psat[kPa]) = A - B/(T + C)
A = [8.9179, 9.4838];
B = [2032.76, 1768.69];
C = [-33.15, -26.06];

%% ----------------------- SATURATION PRESSURE -----------------------------

Psat_kPa = 10.^(A - B./(T + C));
Psat_bar = Psat_kPa/100.0;

%% ----------------------- NEWTON-RAPHSON ----------------------------------

% Initial liquid mole fraction of isobutene
x1 = 0.60;

% Physical bracket
xlo = 0.0;
xhi = 1.0;

tol = 1e-8;
maxIter = 100;

fprintf('==============================================================\n');
fprintf('              PROCESS SIMULATION LAB-I : VLE\n');
fprintf('==============================================================\n\n');

fprintf('Temperature = %.2f K\n', T);
fprintf('Pressure    = %.4f bar\n', P);
fprintf('Psat(1)     = %.8f bar\n', Psat_bar(1));
fprintf('Psat(2)     = %.8f bar\n\n', Psat_bar(2));

fprintf('Iter        x1             f              df/dx1          x1,new       method\n');

for n = 1:maxIter

    [gamma1,gamma2,K1,K2,f,df] = vle_equations( ...
        x1,T,P,Psat_bar(1),Psat_bar(2),D,E,R);

    xnew = x1 - f/df;
    method = 'NR';

    % Safeguard the Newton step.
    if ~isfinite(xnew) || xnew <= xlo || xnew >= xhi
        xnew = (xlo + xhi)/2;
        method = 'BISECT-SAFE';
    end

    fprintf('%3d   %12.8f  %14.6e  %14.6e  %12.8f  %s\n', ...
        n,x1,f,df,xnew,method);

    % Update the physical bracket using the sign of the residual.
    if f > 0
        xhi = x1;
    else
        xlo = x1;
    end

    if abs(f) < tol
        break;
    end

    if abs(xnew-x1) < 1e-10
        x1 = xnew;
        break;
    end

    x1 = xnew;
end

%% ----------------------- FINAL VLE RESULT -------------------------------

x1_final = x1;
x2_final = 1-x1_final;

[gamma1,gamma2,K1,K2,f,df] = vle_equations( ...
    x1_final,T,P,Psat_bar(1),Psat_bar(2),D,E,R);

y1 = K1*x1_final;
y2 = K2*x2_final;

fprintf('\n==============================================================\n');
fprintf('                    VLE FINAL RESULT\n');
fprintf('==============================================================\n');

fprintf('x1  = %.10f\n',x1_final);
fprintf('x2  = %.10f\n',x2_final);
fprintf('gamma1 = %.10f\n',gamma1);
fprintf('gamma2 = %.10f\n',gamma2);
fprintf('K1 = %.10f\n',K1);
fprintf('K2 = %.10f\n',K2);
fprintf('y1  = %.10f\n',y1);
fprintf('y2  = %.10f\n',y2);
fprintf('sum(x) = %.10f\n',x1_final+x2_final);
fprintf('sum(y) = %.10f\n',y1+y2);
fprintf('Residual = %.6e\n',f);

fprintf('==============================================================\n');

%% ----------------------- LOCAL FUNCTION ----------------------------------

function [gamma1,gamma2,K1,K2,f,df] = ...
    vle_equations(x1,T,P,Psat1,Psat2,D,E,R)

x2 = 1-x1;

% 3-suffix Margules equations
lnGamma1 = ((D+3*E)*x2^2 - 4*D*x2^3)/(R*T);
lnGamma2 = ((D-3*E)*x1^2 + 4*D*x1^3)/(R*T);

gamma1 = exp(lnGamma1);
gamma2 = exp(lnGamma2);

% Equilibrium ratios
K1 = Psat1*gamma1/P;
K2 = Psat2*gamma2/P;

% Bubble-point residual
f = 1 - (x1*K1 + x2*K2);

% Analytical derivative used for Newton-Raphson
dlnK1 = (-2*(D+3*E)*x2 + 12*D*x2^2)/(R*T);
dlnK2 = ( 2*(D-3*E)*x1 + 12*D*x1^2)/(R*T);

dK1 = K1*dlnK1;
dK2 = K2*dlnK2;

df = -K1 + K2 - x1*dK1 - x2*dK2;

end