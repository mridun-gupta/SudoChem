%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process Simulation Laboratory-I
%
% Aim: To estimate the equilibrium vapor pressure of a hypothetical
%      subliming compound A by equating the vapor fugacity from the
%      Peng-Robinson equation of state to the solid fugacity with a
%      Poynting correction, and to compare the result with Psub.
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

T = 350.0;                    % K, system temperature
Tc = 508.1;                   % K, critical temperature
Pc = 4.60e6;                  % Pa, critical pressure
omega = 0.307;                % acentric factor
Vs = 4.00e-5;                 % m^3/mol, solid molar volume
R = 8.314462618;              % J/(mol K)

% Search interval supplied in the problem: 0.1 to 500 kPa.
Pmin_data = 0.1e3;            % Pa
Pmax_data = 500e3;            % Pa

%% ----------------------- SUBLIMATION PRESSURE ----------------------------

% Given correlation: ln(Psub/bar) = 12.00 - 4500/T.
Psub_bar = exp(12.00 - 4500.0/T);
Psub = Psub_bar*1.0e5;        % Pa, using 1 bar = 1.0e5 Pa

%% ----------------------- PENG-ROBINSON PARAMETERS ------------------------

% Peng-Robinson pure-component parameters.
a = 0.45724*R^2*Tc^2/Pc;
b = 0.07780*R*Tc/Pc;
kappa = 0.37464 + 1.54226*omega - 0.26992*omega^2;
alpha = (1 + kappa*(1-sqrt(T/Tc)))^2;
aT = a*alpha;

%% ----------------------- SOLVE FUGACITY EQUALITY ------------------------

% Equilibrium condition: f_v = f_s.
% f_v = phi_v*P
% f_s = Psub*exp[Vs*(P-Psub)/(R*T)]
% Residual = ln(f_v/f_s) = 0.
residual = @(P) equilibriumResidual(P,T,Vs,R,Psub,aT,b);

% Initial bracket follows the classroom template. The fallback scans a
% logarithmic grid within the user-supplied pressure-search interval.
Plo = max(Pmin_data,0.10*Psub);
Phi = Pmax_data;
glo = residual(Plo);
ghi = residual(Phi);

if isfinite(glo) && isfinite(ghi) && glo*ghi < 0
    P_eq = fzero(residual,[Plo Phi]);
else
    % Robust fallback: locate a sign-changing interval on a log pressure grid.
    Pgrid = logspace(log10(Pmin_data),log10(Pmax_data),500);
    ggrid = nan(size(Pgrid));
    for i = 1:numel(Pgrid)
        ggrid(i) = residual(Pgrid(i));
    end

    idx = find(isfinite(ggrid(1:end-1)) & ...
               isfinite(ggrid(2:end)) & ...
               ggrid(1:end-1).*ggrid(2:end) < 0,1,'first');

    if isempty(idx)
        error(['No sign-changing interval was found in the pressure range. ' ...
               'Check the property data and residual function.']);
    end

    P_eq = fzero(residual,[Pgrid(idx),Pgrid(idx+1)]);
end

%% ----------------------- FINAL FUGACITY CALCULATIONS ---------------------

[phiV,Zv,A,B] = prFugacityCoefficient(P_eq,T,aT,b,R);
fV = phiV*P_eq;
poyntingFactor = exp(Vs*(P_eq-Psub)/(R*T));
fS = Psub*poyntingFactor;
finalResidual = log(fV/fS);

% Ideal-vapor estimate and relative pressure difference.
P_ideal = Psub;
relativeDifference = 100*(P_eq-P_ideal)/P_ideal;

%% ----------------------- DISPLAY RESULTS ---------------------------------

fprintf('==============================================================\n');
fprintf('          PROCESS SIMULATION LABORATORY-I : SVE\n');
fprintf('==============================================================\n\n');

fprintf('System temperature, T = %.3f K\n',T);
fprintf('Critical temperature, Tc = %.3f K\n',Tc);
fprintf('Critical pressure, Pc = %.3f MPa\n',Pc/1e6);
fprintf('Acentric factor, omega = %.6f\n',omega);
fprintf('Solid molar volume, Vs = %.6e m^3/mol\n\n',Vs);

fprintf('Sublimation pressure, Psub = %.6f bar\n',Psub_bar);
fprintf('Sublimation pressure, Psub = %.6f kPa\n\n',Psub/1000);

fprintf('Peng-Robinson parameters:\n');
fprintf('a      = %.9e\n',a);
fprintf('b      = %.9e m^3/mol\n',b);
fprintf('kappa  = %.9f\n',kappa);
fprintf('alpha  = %.9f\n',alpha);
fprintf('aT     = %.9e\n\n',aT);

fprintf('Equilibrium vapor pressure, P_eq = %.6f Pa\n',P_eq);
fprintf('Equilibrium vapor pressure, P_eq = %.6f kPa\n',P_eq/1000);
fprintf('Vapor compressibility factor, Z = %.9f\n',Zv);
fprintf('Vapor fugacity coefficient, phi_v = %.9f\n',phiV);
fprintf('Dimensionless PR parameters: A = %.9e, B = %.9e\n\n',A,B);

fprintf('Vapor fugacity, f_v = phi_v*P = %.6f Pa\n',fV);
fprintf('Solid fugacity, f_s = %.6f Pa\n',fS);
fprintf('Poynting correction factor = %.10f\n',poyntingFactor);
fprintf('Final ln(f_v/f_s) residual = %.3e\n\n',finalResidual);

fprintf('Ideal-vapor pressure estimate, Psub = %.6f kPa\n',P_ideal/1000);
fprintf('Pressure difference, P_eq - Psub = %.6f kPa\n', ...
        (P_eq-Psub)/1000);
fprintf('Difference relative to Psub = %.6f %%\n',relativeDifference);
fprintf('==============================================================\n');

%% ----------------------- EQUILIBRIUM RESIDUAL PLOT -----------------------

P_plot = logspace(log10(Pmin_data),log10(Pmax_data),500);
res_plot = nan(size(P_plot));
for i = 1:numel(P_plot)
    res_plot(i) = residual(P_plot(i));
end

figure('Name','Solid-Vapor Equilibrium Residual','NumberTitle','off');
semilogx(P_plot/1000,res_plot,'LineWidth',1.5);
hold on;
plot([min(P_plot),max(P_plot)]/1000,[0 0],'k--');
plot(P_eq/1000,finalResidual,'ro','MarkerFaceColor','r');
grid on;
xlabel('Pressure, P (kPa)');
ylabel('ln(f_v/f_s)');
title('Solid-Vapor Equilibrium Using Peng-Robinson EOS');
legend('Equilibrium residual','Zero residual','Calculated root', ...
       'Location','best');
hold off;

%% ----------------------- FINAL CHECKS ------------------------------------

if P_eq < Pmin_data || P_eq > Pmax_data
    warning('The equilibrium pressure is outside the specified search interval.');
end
if phiV <= 0 || ~isfinite(phiV)
    warning('The vapor fugacity coefficient is not physically usable.');
end
if abs(finalResidual) > 1e-7
    warning('The final fugacity equality residual is larger than expected.');
end

%% ----------------------- LOCAL PENG-ROBINSON FUNCTIONS -------------------

function residual = equilibriumResidual(P,T,Vs,R,Psub,aT,b)

% Return ln(f_v/f_s). The equilibrium root is where this residual is zero.
[phiV,~,~,~] = prFugacityCoefficient(P,T,aT,b,R);
fV = phiV*P;
fS = Psub*exp(Vs*(P-Psub)/(R*T));
residual = log(fV/fS);

end

function [phiV,Zv,A,B] = prFugacityCoefficient(P,T,aT,b,R)

% Peng-Robinson EOS dimensionless parameters.
A = aT*P/(R^2*T^2);
B = b*P/(R*T);

% Cubic equation in compressibility factor Z:
% Z^3 -(1-B)Z^2 +(A-3B^2-2B)Z -(AB-B^2-B^3) = 0.
coeff = [1, -(1-B), A-3*B^2-2*B, -(A*B-B^2-B^3)];
Zroots = roots(coeff);
realRoots = real(Zroots(abs(imag(Zroots)) < 1e-8));

if isempty(realRoots)
    error('Peng-Robinson cubic has no real compressibility root.');
end

% Use the vapor root, i.e. the largest real compressibility root.
Zv = max(realRoots);
if Zv <= B
    error('Invalid Peng-Robinson root: Z must be greater than B.');
end

sqrt2 = sqrt(2);
lnPhi = Zv - 1 - log(Zv-B) ...
    - A/(2*sqrt2*B)*log((Zv+(1+sqrt2)*B)/(Zv+(1-sqrt2)*B));
phiV = exp(lnPhi);

end
