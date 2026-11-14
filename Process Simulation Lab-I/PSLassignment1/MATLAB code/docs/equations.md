# Implemented Equations and Model Notes

## NRTL

The JSON convention is `tau_ij = a_ij + b_ij_K/T_K`, `G_ij = exp(-alpha_ij*tau_ij)`. `cps22_nrtl_gamma` evaluates the standard NRTL expression component-by-component and returns `gamma`, `lnGamma`, and intermediate `tau/G` matrices. The parameter set is a candidate low-pressure set and is explicitly **not accepted** at the selected high-temperature/high-pressure state.

## SRK

`m_i = 0.480 + 1.574 omega_i - 0.176 omega_i^2`; `alpha_i = [1+m_i(1-sqrt(T/Tc_i))]^2`; `a_i=0.42747 R^2 Tc_i^2 alpha_i/Pc_i`; `b_i=0.08664 R Tc_i/Pc_i`. Mixing rules: `a_m=sum_i sum_j q_i q_j sqrt(a_i a_j)(1-k_ij)` and `b_m=sum_i q_i b_i`. Cubic: `Z^3-Z^2+(A-B-B^2)Z-AB=0`, where `A=a_m P/(R^2 T^2)`, `B=b_m P/(RT)`. The largest real root with `Z>B` is used for vapour calculations, while all roots are retained. No liquid phase stability/root selection is claimed.

## Gamma-phi equilibrium

`f_i^V = y_i phi_i^V P`; `f_i^L = x_i gamma_i Psat_i phi_i^sat exp[v_i^L(P-Psat_i)/(RT)]`. `cps22_gamma_phi` returns `ln(f_i^V/f_i^L)` for each component. `phi_i^sat` is calculated from the pure component SRK EOS at `Psat_i`; the Poynting factor uses a modified-Rackett liquid molar volume approximation.

## Flash unknowns and residuals

Unknown vector is the logistic-transformed `u=[logit(x_1), logit(y_1), logit(beta)]`; the physical variables remain in (0,1). Residual vector: both component log-fugacity ratios and the ethanol component balance `z_1 - (1-beta)x_1-beta*y_1`. A multi-start `fminsearch` minimises the sum of squared dimensionless residuals. It is considered numerically converged only if each log-fugacity residual is below `1e-6` and the ethanol balance residual below `1e-8`, with a non-boundary phase fraction. These are software tolerances, not proof of thermodynamic validity. The model is still marked not accepted, and phase stability is not checked.

## Reference interpolation

`cps22_reference_flash` reads experimental Table 6 rows at an available measured pressure, interpolates bubble and dew temperatures against composition, then x/y against temperature without extrapolating outside measured ranges. A lever-rule phase split is calculated only when the overall composition lies between the interpolated tie-line compositions and the temperature is within the two-phase envelope. This calculation is kept separate from the NRTL-SRK solver.

## Balances

Total molar balance: `F=L+V`. Component balance: `F z_i = L x_i + V y_i`. SI flow basis is mol/s. Algebraic closure of an empirical lever-rule fixture is not evidence of predictive model accuracy.

## Blocked modules

Energy duty is not reported until a consistent ideal-gas, SRK residual, liquid/reference and NRTL excess enthalpy method is implemented with a common datum. Utility consumption requires a duty and utility conditions. CAPEX/OPEX requires documented cost correlations, indices and utility costs. The modules therefore return explicit blocked status values.

## Component-wise diagnostic export

`cps22_thermodynamic_summary` exports NRTL gamma, SRK vapor phi/Z, pure saturated-vapor phi, Psat, Poynting factor, liquid/vapor fugacities and log-fugacity residuals for the empirical reference tie-line. The row status explicitly states `REFERENCE_TIELINE_FUGACITY_DIAGNOSTIC_NOT_TARGET_PREDICTION`.
