# CPS-22 Equation and Method Details — Phase 2

## 1. Basis and status conventions

Internal units: K, Pa, mol/s, J/mol, W, m, kg/m3. External reference data are retained in kPa and kmol/h columns in the reference dataset. Source values are kept separately from assumptions and model diagnostics.

Status labels used by the CSV files:
- `REFERENCE_INTERPOLATION_BENCHMARK`: derived from published experimental T-x-y points.
- `CALCULATED_APPROXIMATION` / `SCREENING_ONLY`: arithmetic carried out, but physical property correlation is preliminary.
- `DIAGNOSTIC_ONLY`: tests model/formulation without accepting the result as process-valid.
- `REJECTED_NONCONVERGED`, `NOT_ACCEPTED`, `BLOCKED_*`: acceptance criterion not met, or required input/method not available.

## 2. NRTL liquid activity coefficients

The parameter convention examined is the Aspen/VLE-IG convention
\[\tau_{ij}(T)=a_{ij}+b_{ij}/T,\qquad G_{ij}=\exp(-\alpha_{ij}\tau_{ij}).\]
For a binary mixture, the standard NRTL activity-coefficient expression is
\[\ln\gamma_i=\frac{\sum_j x_j\tau_{ji}G_{ji}}{\sum_k x_kG_{ki}}+\sum_j\frac{x_jG_{ij}}{\sum_kx_kG_{kj}}\left(\tau_{ij}-\frac{\sum_m x_m\tau_{mj}G_{mj}}{\sum_kx_kG_{kj}}\right).\]
The candidate parameter set was sourced as a literature reproduction of Aspen Plus VLE-IG: a12=-0.8009; b12=246.18 K; a21=3.4578; b21=-586.0809 K; alpha12=alpha21=0.3. Its validity/fit base is low-pressure VLE; do not extrapolate it to roughly 445 K without validation. Pure-component limit gamma_i -> 1 as x_i -> 1 is a required unit test.

## 3. SRK vapour-phase properties

Classical Soave–Redlich–Kwong:
\[P=\frac{RT}{v-b}-\frac{a\alpha}{v(v+b)}.\]
\[m_i=0.480+1.574\omega_i-0.176\omega_i^2,\quad \alpha_i=[1+m_i(1-\sqrt{T/T_{c,i}})]^2.\]
\[a_i=0.42747R^2T_{c,i}^2\alpha_i/P_{c,i},\quad b_i=0.08664RT_{c,i}/P_{c,i}.\]
Classical van der Waals one-fluid mixing rules:
\[a_m=\sum_i\sum_jy_iy_j\sqrt{a_i a_j}(1-k_{ij}),\quad b_m=\sum_i y_ib_i.\]
Dimensionless terms are A=a_mP/(R^2T^2) and B=b_mP/(RT), with cubic
\[Z^3-Z^2+(A-B-B^2)Z-AB=0.\]
For the vapour-phase diagnostic the largest real root with Z>B is selected. Record all real roots; a flash solver must choose the phase-appropriate root and verify stability. Fugacity coefficient:
\[\ln\phi_i=\frac{b_i}{b_m}(Z-1)-\ln(Z-B)-\frac{A}{B}\left(\frac{2\sum_jy_ja_{ij}}{a_m}-\frac{b_i}{b_m}\right)\ln(1+B/Z).\]
The initial k_ij=0 is diagnostic only. The regression test reached its imposed k_ij bound and is not accepted.

## 4. Gamma-phi fugacity equation with high-pressure corrections

Component equilibrium requires f_i^L=f_i^V. The selected reference-state structure is
\[y_i\phi_i^VP=x_i\gamma_iP_i^{sat}\phi_i^{sat}\exp\left[\frac{v_i^L(P-P_i^{sat})}{RT}\right].\]
The terms are:
- \(\phi_i^V\): mixture vapour fugacity coefficient from SRK.
- \(\gamma_i\): liquid activity coefficient from NRTL.
- \(P_i^{sat}\): pure component saturation pressure from the relevant Antoine set.
- \(\phi_i^{sat}\): pure-component saturated-vapour fugacity coefficient from the selected EOS at \(T,P_i^{sat}\).
- Exponential: liquid Poynting correction, using an estimated pure-liquid molar volume.

The residual used in diagnosis is the log ratio of right/left fugacities (as implemented):
\[r_i=\ln\left[\frac{y_i\phi_i^VP}{x_i\gamma_iP_i^{sat}\phi_i^{sat}\exp(v_i^L(P-P_i^{sat})/(RT))}\right].\]
Acceptance requires all component residuals below tolerance, normalization, material closure, phase feasibility and an appropriate stability classification. The Poynting factor uses a modified-Rackett approximation, which should be replaced or independently validated; liquid-volume estimates are not treated as high-quality density results.

## 5. Isothermal flash constraints

For overall composition z, vapour fraction beta and normalized liquid/vapour compositions x,y:
\[z_i=(1-\beta)x_i+\beta y_i,\quad \sum_i x_i=\sum_i y_i=1,\quad 0\le \beta\le1.\]
For an N-component system, a solver can use N component log-fugacity equalities, N-1 independent component balances, and N-1 independent coordinates each for x and y plus beta. Use transformed variables or bounded coordinates; do not clip nonphysical composition after solving.

The empirical benchmark instead uses measured Table 6 tie-line points interpolated in temperature and the lever rule. It is intentionally independent of NRTL-SRK. Empirical interpolation provides a benchmark for composition and phase-flow logic, but not proof that the NRTL-SRK implementation is valid.

## 6. Material balance and closure definitions

Total balance: \(F=L+V\).
Component balance: \(Fz_i=Lx_i+Vy_i\).
Absolute closure: \(\epsilon_i=Fz_i-(Lx_i+Vy_i)\).
Relative closure: \(\epsilon_{i,rel}=\epsilon_i/(Fz_i)\) where denominator is safely nonzero; for components near zero report absolute residual only. Since L/V were calculated from beta, zero component closure is algebraic and must not be confused with model verification.

## 7. Energy-balance method required before calculating duty

With work positive out of the control volume under the assignment convention:
\[F\bar h_{in}+\dot Q=L\bar h_L+V\bar h_V+\dot W.\]
For provisional baseline, \(\dot W=0\) is an assumption. Implement enthalpy as a consistent combination of ideal-gas component enthalpy, SRK residual enthalpy, liquid/reference enthalpy, NRTL excess enthalpy, and pressure correction on a single datum. Because this Phase 2 diagnostic lacks an accepted, valid NRTL temperature dependence and a verified mixture enthalpy implementation, duty is `NA/BLOCKED`; no energy closure is claimed.

## 8. Souders–Brown screening equations

\[v_{allow}=K_S\sqrt{(\rho_L-\rho_V)/\rho_V},\quad A_{gas}=\dot V_V/v_{allow},\quad D_{hyd}=\sqrt{4A_{gas}/\pi}.\]
Liquid hold-up: \(V_{hold}=\dot V_Lt_{res}\), liquid depth approximation \(h_L=V_{hold}/(\pi D^2/4)\). The K factor, densities, residence time and geometry must be documented. A typical K value from GPSA is for comparison/preliminary sizing only; final K and droplet-removal design depend on pressure, phase properties, mist eliminator and service. This is a process-screening calculation, not mechanical pressure-vessel design or code compliance.

## 9. Sensitivity metrics

For each sweep, hold all non-varied conditions fixed. Feasibility/status values are preserved; do not connect infeasible values as valid continuous results. Five studies are retained in the CSV:
- T sweep at 1500 kPa using measured T-x-y branch interpolation.
- P change from 1500 to 2000 kPa at fixed T0 and z=0.5, using the measured bubble boundary to classify phase state.
- Feed z sweep using the base tie-line.
- Feed flow sweep, showing linear outlet-flow scaling at fixed T/P/z.
- SRK k_ij residual sweep, explicitly diagnostic because the NRTL parameter set is outside its valid range.

## 10. Alternative model / reference comparison

The 2021 source reports azeotropic benchmark values at 1500 kPa: experiment x=y=0.857, T=440.70 K; PRSV x=y=0.883, T=441.09 K; PRSV-Wong-Sandler x=y=0.864, T=440.83 K. Phase 2 computes absolute and relative deviations directly from these published values. These are literature-reported model outputs, not independent implementations in this project. They provide an alternative formulation comparison at the azeotrope only; they do not replace pointwise T-x-y validation.
