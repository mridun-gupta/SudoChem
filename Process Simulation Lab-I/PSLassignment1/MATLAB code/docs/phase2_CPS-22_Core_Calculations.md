# CPS-22 Core Calculations — Phase 2

**Run date:** 26 October 2026  
**Status:** Partial technical execution; reference-data calculations are reproducible, but the NRTL–SRK parameter/model acceptance gate is **not passed**.  
**Reference data:** Susial Badajoz et al. (2021), Table 6, DOI [10.1021/acs.jced.0c00686](https://doi.org/10.1021/acs.jced.0c00686).

## Calculation 1 — Empirical bubble/dew bounds and selected benchmark temperature

**Purpose.** Establish the approved Phase 1 operating temperature without inventing a model answer. Feed composition is z_ethanol=0.50; pressure is 1500 kPa; feed rate is 100 kmol/h (assumed scale).

**Bubble interpolation at x=z=0.50** using published Table 6 points (x=0.475, T=443.7 K) and (x=0.515, T=443.2 K):

\[T_b=443.7+\frac{0.500-0.475}{0.515-0.475}(443.2-443.7)= 443.3875\;\mathrm{K}.\]

**Dew interpolation at y=z=0.50** using (y=0.483, T=447.4 K) and (y=0.502, T=446.8 K):

\[T_d=447.4+\frac{0.500-0.483}{0.502-0.483}(446.8-447.4)=446.8632\;\mathrm{K}.\]

**Chosen midpoint:**

\[T_0=(T_b+T_d)/2=445.125329\;\mathrm{K}= 171.975\;^\circ\mathrm{C}.\]

This is a calculation-basis choice grounded in measured T-x-y data, not a measured experiment point.

## Calculation 2 — Interpolate the experimental tie-line at T0

Use adjacent Table 6 points at 1500 kPa: (x=0.366, y=0.537, T=445.5 K) and (x=0.402, y=0.555, T=444.9 K).

\[x_1(T_0)=0.366+\frac{445.5-T_0}{445.5-444.9}(0.402-0.366)=0.38848026.\]
\[y_1(T_0)=0.537+\frac{445.5-T_0}{445.5-444.9}(0.555-0.537)=0.54824013.\]

Water fractions are x2=1-x1=0.61151974; y2=1-y1=0.45175987. The estimated vapour fraction follows the lever rule:

\[\beta=\frac{z_1-x_1}{y_1-x_1}=\frac{0.500000-0.38848026}{0.54824013-0.38848026}=0.69804600.\]

For F=100 kmol/h:
\[V=F\beta=69.80460\;\mathrm{kmol/h},\quad L=F(1-\beta)=30.19540\;\mathrm{kmol/h}.\]

This is an empirical-reference interpolation benchmark. It must not be labelled an NRTL–SRK prediction.

## Calculation 3 — Material balances

Ethanol inlet: \(Fz_1=100(0.5)=50.000000\) kmol/h.

Ethanol outlets:
- Liquid: \(Lx_1=11.730317\) kmol/h.
- Vapour: \(Vy_1=38.269683\) kmol/h.
- Closure: \(50.000000-(11.730317+38.269683)=0\) kmol/h (up to floating-point precision).

Water inlet: \(Fz_2=50.000000\) kmol/h.

Water outlets:
- Liquid: \(Lx_2=18.465083\) kmol/h.
- Vapour: \(Vy_2=31.534917\) kmol/h.
- Closure: \(50.000000-(18.465083+31.534917)=0\) kmol/h (up to floating-point precision).

Total flow: \(F-(L+V)=100-(30.19540017+69.80459983)=0\) kmol/h. These closures are expected because L/V were derived from the lever rule; they are not an independent validation of the property model.

## Calculation 4 — NRTL–SRK model diagnostic

### NRTL candidate set

The secondary published table sourced to Aspen Plus VLE-IG gives \(\tau_{12}=a_{12}+b_{12}/T\), \(\tau_{21}=a_{21}+b_{21}/T\), with \(a_{12}=-0.8009\), \(b_{12}=246.18\;K\), \(a_{21}=3.4578\), \(b_{21}=-586.0809\;K\), and \(\alpha=0.3\). The associated low-pressure data basis is not validated at the selected 445 K operating temperature. This parameter set is a diagnostic candidate only.

### SRK

Classical Soave alpha function:

\[m_i=0.480+1.574\omega_i-0.176\omega_i^2,\quad \alpha_i=[1+m_i(1-\sqrt{T/T_{c,i}})]^2.\]

\[a_i=0.42747\frac{R^2T_{c,i}^2}{P_{c,i}}\alpha_i,\quad b_i=0.08664\frac{RT_{c,i}}{P_{c,i}}.\]

Quadratic mixing: \(a_m=\sum_i\sum_j y_i y_j\sqrt{a_i a_j}(1-k_{ij})\), \(b_m=\sum_i y_i b_i\). The largest admissible real root is used for the diagnostic vapour phase; the other roots are retained in the output.

### Coupled equilibrium residual

\[r_i=\ln\left[\frac{y_i\phi_i^V P}{x_i\gamma_i P_i^{sat}\phi_i^{sat}\exp(v_i^L(P-P_i^{sat})/(RT))}\right].\]

At the empirically interpolated tie-line, the candidate parameter set gives:
- ethanol log-fugacity residual: -0.018797;
- water log-fugacity residual: -0.118559.

These are too large to accept the empirical tie-line as a model-consistent result under this parameter set.

### High-pressure parameter regression attempt

A least-squares diagnostic fit was attempted on the 1500 kPa rows by fitting \(a_{12},b_{12},a_{21},b_{21},k_{12}\), with \(\alpha=0.3\) fixed. The SRK binary interaction parameter reached the imposed upper bound \(k_{12}=0.2000\). Training RMS of the 64 component log-fugacity residuals was 0.04086, maximum absolute residual 0.16286; on the held pressure data at 2000 kPa, RMS was 0.14344, maximum 0.35975. This does not constitute a successful validation. The fit is not accepted because it is bound-limited, parameter identifiability is poor in this narrow temperature interval, and the held-pressure residual remains high.

The default NRTL/SRK flash solver returned a nominal solver exit flag but left maximum component log-fugacity residual 0.06120 and scaled component balance residual 0.00711. Consequently it is recorded as `NON_CONVERGED` for engineering acceptance even though the numerical library's exit flag was true. The regression-trial flash also is not accepted because the parameter fit fails the model-acceptance gate.

## Calculation 5 — Preliminary separator sizing screen

Use the empirical reference split only to produce screening loads. The density estimates are weakly supported: vapour density uses SRK Z at measured y with diagnostic \(k_{ij}=0\); liquid volume uses composition-weighted modified-Rackett pure-component volumes (ideal volume mixing). Neither is a validated mixture-density prediction.

Vapour mixture molecular weight = 0.033395 kg/mol; liquid mixture molecular weight = 0.028913 kg/mol. Screening values:
- \(Z_V=0.878732\), \(\rho_V=15.403\;kg/m^3\);
- \(\bar V_L=4.27273534e-05\;m^3/mol\), \(\rho_L=676.695\;kg/m^3\);
- vapour volumetric flow = 0.042040 m3/s;
- liquid volumetric flow = 0.00035838 m3/s.

With provisional Souders–Brown K=0.11 m/s (typical vertical flow to mesh screen value),
\[v_{max}=K\sqrt{(\rho_L-\rho_V)/\rho_V}=0.7208\;m/s,\]
\[A_{gas}=\dot V_V/v_{max}=0.05833\;m^2,\quad D_{hyd}=\sqrt{4A/\pi}=0.2725\;m.\]

Round-up screening diameter selected: D=0.30 m; cross-sectional area=0.07069 m2. For 3 min liquid hold-up, \(V_{hold}=\dot V_L(180)=0.06451\;m^3\), corresponding liquid depth of 0.913 m at D=0.30 m. The screening superficial gas velocity is 0.595 m/s; allowable/actual velocity ratio is 1.212. This is not a final separator design: K pressure dependency, droplet size/carryover, inlet device, disengagement height, surge, nozzle sizing, minimum practical dimensions and vessel mechanical design remain unresolved.

## Calculation 6 — Energy, utilities, CAPEX/OPEX

Energy closure is **not calculated**. Required equation for the provisional control volume:

\[F\bar h_{in}+\dot Q= L\bar h_L+V\bar h_V+\dot W,\qquad \dot W=0\;\text{by assumption}.\]

The enthalpy model must consistently combine ideal-gas enthalpies, SRK residual enthalpies, liquid/reference enthalpies, NRTL excess enthalpy and the same datum for all streams. The selected NRTL parameters do not have defensible temperature dependence in this range and the model has failed the high-pressure VLE diagnostic; therefore a numerical duty would be false precision. Utility consumption and annual utility OPEX depend on this duty and are left explicitly uncomputed. The cost basis remains provisional USD 2025; numeric CAPEX is not calculated because the cost correlation, pressure/material factors, cost index and a final equipment design are not frozen.

## Calculation 7 — Five sensitivity studies

1. **Temperature:** vary T over the measured two-phase branch at 1.5 MPa and z=0.5; interpolate Table 6 x/y; calculate beta and phase flow. See `CPS-22_Sensitivity_Results.csv` and Figure 2.
2. **Pressure:** hold T=T0 and z=0.5. At 1.5 MPa the state is in the measured two-phase interval; at 2.0 MPa, T0 is below the measured-data-derived bubble point T_b(z=0.5)=456.625 K, so classify as single liquid. Intermediate pressures are not interpolated because no high-pressure reference data are supplied there.
3. **Feed composition:** at T0/P0, vary z; lever-rule flash is feasible only when x(T0) <= z <= y(T0). Outside the tie-line, the reference-based phase classification becomes single liquid or single vapour.
4. **Feed flow:** vary 50-150 kmol/h at fixed T/P/z; empirical equilibrium split remains constant and outlet phase rates scale linearly.
5. **SRK binary interaction parameter:** vary k_ij from -0.10 to 0.20 and record training and held-pressure log-fugacity residuals using the candidate NRTL set. This is a model diagnostic only because the NRTL set is out-of-range and the residual does not pass acceptance; see Figure 5.

## Main conclusions

- The empirical reference interpolation and material-balance benchmark are reproducible.
- The experimental table itself provides two-phase/bubble/dew benchmarks at the selected pressure.
- The current published low-pressure NRTL parameter candidate cannot be accepted at about 445 K.
- Fitting NRTL and SRK parameters to one pressure did not produce a defensible fit and did not predict the held pressure satisfactorily.
- Preliminary vessel loading calculations are screening-only.
- Energy duty, utilities, numeric CAPEX/OPEX and a valid target-model comparison remain open until the property model/enthalpy basis is resolved.
