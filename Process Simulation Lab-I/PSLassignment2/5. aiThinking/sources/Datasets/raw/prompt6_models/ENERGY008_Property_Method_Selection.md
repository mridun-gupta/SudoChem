# ENERGY-008 Property-Method Selection

**Document:** ENERGY008-PM-0.1  
**Model/data revision:** `ENERGY008-MODEL-0.1.0` / `ENERGY008-DATA-0.1.0`  
**Date:** 1 November 2026  
**Working route:** Route C, biogenic CO₂ + renewable electrolytic H₂, ALK reference  
**Approval status:** Provisional. The Prompt 2 route gate is not evidenced as formally approved; Prompt 3 Rev 0.1-DRAFT is not frozen at G3.

---

## 1. Decision summary

The model method is divided by physical regime rather than forcing one property method onto every unit operation.

| Domain | Governing candidate | Why this is the lead candidate | Current decision status |
|---|---|---|---|
| High-pressure synthesis gas and flash vapour | Peng–Robinson 1978 (PR78), classical van der Waals one-fluid mixing, temperature-dependent \(k_{ij}(T)\) | Used in a validated methanol-synthesis miniplant loop model with condenser, flash, recycle and purge; source publishes fitted pair parameters for a subset of relevant pairs | **Provisional; full mixture is blocked** because several active binary pairs are missing and the source's miniplant operating envelope does not cover the draft 250 °C / 70 bar point |
| High-pressure chemical/phase-equilibrium cross-check | Modified Soave–Redlich–Kwong (SRK) | Published simultaneous phase and chemical equilibrium approach for high-pressure methanol synthesis, checked against packed-bed experiments | Alternative/cross-check; coefficients and exact parameter set must be retrieved and benchmarked |
| Low-pressure crude methanol purification | \(\gamma-\phi\) formulation with Wilson liquid activity coefficients; NRTL is a regression alternative | NIST ThermoML methanol–water data at 95.3 kPa and several sub-atmospheric pressures were represented well by Wilson | Provisional and pressure-limited; no fitted Wilson/NRTL parameters are present in Prompt 5 data |
| Water/steam utilities | IAPWS-IF97; IAPWS transport releases for viscosity/conductivity when implemented | Authoritative water/steam formulation | Source selected; numerical runtime evaluation not yet performed |
| Pure-fluid reference thermochemistry | NIST Chemistry WebBook / NIST-JANAF Shomate functions within their intervals | Already curated in `ENERGY008-DATA-0.1.0` | Frozen reference subset only; phase/state limitations apply |
| ALK electrolyte and stack | Vendor-calibrated electrochemical polarisation/performance map with Faraday balance | Captures cell voltage, load response, Faradaic efficiency and BOP loads without inventing a single efficiency | Model structure selected; vendor inputs blocked |
| Methanol/water/high-pressure polar liquid alternative | CPA or sPC-SAFT association EOS | Methanol and water are associating compounds; association EOS can represent hydrogen bonding | Research alternative only; association and binary parameters unavailable |

**The selected property-method family is not yet a validated property package.** In particular, PR78 cannot be executed for the full synthesis-loop mixture until every active binary interaction parameter has a source or a documented regression and the model passes validation tests. Missing parameters are null/blocked, never silently set to zero.

## 2. Route, design-point and data controls

Route C is carried forward as the modelling working route because the Prompt 2 route-comparison report recommends biogenic CO₂ + renewable electrolytic H₂. The route report also states that the route has a hard feasibility dependency on a continuous, traceable biogenic CO₂ source. The Prompt 3 design-basis workbook explicitly says the route gate response was not recorded and G3 is not frozen. This document therefore does not represent route approval.

The draft design-point values are:

- Synthesis pressure: 7 MPa(a) (70 bar(a)), `ASSUMED_WITHIN_LITERATURE_RANGE`.
- Synthesis temperature: 250 °C (523.15 K), `ASSUMED_WITHIN_LITERATURE_RANGE`.
- Fresh-feed stoichiometric anchor: H₂/CO₂ = 3 mol/mol, not the reactor-loop operating ratio.
- Illustrative production capacity: 50 t/day, not an approved plant capacity.

No EOS/kinetic validity statement below converts those assumptions into industrial facts.

Prompt 5 froze only a narrow pure-component reference subset. It explicitly blocked multicomponent EOS, binary parameters, methanol–water VLE, state-dependent transport properties and a kinetic parameter set. Thus the property-method choices below are **method selection and data requirements**, not calculation outputs.

## 3. High-pressure synthesis gas: PR78 lead candidate

### 3.1 Equation of state and mixing rule

Use the Peng–Robinson cubic equation as the initial process EOS candidate:

\[
P = \frac{RT}{v-b_m} -
\frac{a_m}{v(v+b_m)+b_m(v-b_m)}
\]

with the classical van der Waals one-fluid mixing rule:

\[
a_m = \sum_i\sum_j x_i x_j a_{ij}, \qquad
a_{ij}=(1-k_{ij})\sqrt{a_i a_j}
\]

\[
b_m=\sum_i x_i b_i
\]

For the published miniplant parameterisation, the binary interaction coefficient is a second-order temperature polynomial:

\[
k_{ij}(T)=k_{ij,0}+k_{ij,T}T+k_{ij,T2}T^2,\qquad k_{ij}=k_{ji}
\]

Pure-component \(a_i(T)\) and \(b_i\) are generated from \(T_c\), \(P_c\), acentric factor and the selected PR alpha function. Use absolute pressure and consistent SI units.

### 3.2 Published candidate binary coefficients

Nestler et al. (2022) report the following temperature-dependent PR interaction coefficients for selected pairs in their methanol-synthesis miniplant model:

| Pair | \(k_{ij,0}\) | \(k_{ij,T}\), K⁻¹ | \(k_{ij,T2}\), K⁻² |
|---|---:|---:|---:|
| MeOH–H₂O | 0.1789 | −1.435×10⁻³ | 2.011×10⁻⁶ |
| CO₂–MeOH | −0.1057 | 4.790×10⁻⁴ | 1.420×10⁻⁷ |
| CO₂–H₂O | −0.9317 | 4.051×10⁻³ | −4.489×10⁻⁶ |
| CO–MeOH | −0.6376 | 1.852×10⁻³ | −1.247×10⁻⁶ |
| H₂–MeOH | −1.5004 | 4.309×10⁻³ | −8.118×10⁻⁷ |
| N₂–MeOH | −0.5040 | 9.193×10⁻⁴ | 9.388×10⁻⁷ |

Source: Nestler et al., *Experimental Validation of Methanol Synthesis from Steel Mill Gases Using a Miniplant Setup*, 2022, DOI [10.1002/cite.202200022](https://doi.org/10.1002/cite.202200022). The article describes a two-bed adiabatic/quench miniplant at 51 bar(a); the experimental campaign includes reactor inlet temperatures of 171.8–219.8 °C for the first bed and 180.7–228.1 °C for the second bed. It reports that other pairs without experimental VLE data were set to zero in that study. **ENERGY-008 will not copy that zero assumption.**

### 3.3 Binary-pair gap and range check

The six parameter pairs above are candidate source records only. They do not form a complete parameter matrix for the Route C stream set. A full flash/phase-stability calculation may require, at minimum, measured or regressed parameters for:

- CO₂–H₂ at synthesis temperature;
- CO₂–CO;
- H₂–CO;
- H₂–H₂O;
- CO–H₂O;
- H₂O–MeOH at the selected separator/column conditions;
- any additional measured source contaminants (N₂, CH₄, Ar, H₂S and others).

No absent pair is assigned \(k_{ij}=0\). The PR parameter set reported by Nestler et al. was used in a 51-bar steel-gas miniplant, not demonstrated at the ENERGY-008 draft 70 bar and 250 °C. Therefore:

1. retain the published values only as source-attributed candidate coefficients;
2. verify the underlying VLE source datasets and each fitted pair;
3. obtain or regress every missing pair;
4. benchmark fugacity coefficients, compressibility and phase split against independent data at the relevant temperature/pressure;
5. do not run the complete Route C EOS flash until this gate is passed.

For CO₂–H₂, experimental PR modelling data are available from 218.15–303.15 K and pressures up to approximately 15 MPa. Those data are relevant to cold compression/separation conditions, not to the 523 K reactor. They must not be extrapolated to reactor temperature without additional evidence.

## 4. SRK alternative for high-pressure phase and chemical equilibrium

A 2012 high-pressure methanol-synthesis study developed a modified SRK approach for simultaneous phase and chemical equilibrium. The method explicitly considered a possible condensed phase and dew-point calculations, with a stated study basis at 20 MPa and 463–553 K. It compared equilibrium predictions to packed-bed methanol-synthesis experiments and reported agreement for equilibrium conversion and gas composition.

This is a relevant thermodynamic cross-check because the temperature range includes the draft 523.15 K point. Its pressure basis (20 MPa) differs from the draft 7 MPa point, and its exact binary coefficients and parameter set have not been transferred into the ENERGY-008 data package. It is therefore an **alternative to benchmark**, not the governing EOS at this stage.

Reference: van Bennekom, J. G., Winkelman, J. G. M., Venderbosch, R. H., Nieland, S. D. G. B. and Heeres, H. J. (2012), “Modeling and Experimental Studies on Phase and Chemical Equilibria in High-Pressure Methanol Synthesis,” *Industrial & Engineering Chemistry Research*. DOI [10.1021/ie3017362](https://doi.org/10.1021/ie3017362).

## 5. Methanol–water liquid phase: Wilson \(\gamma-\phi\) lead candidate

For a low-pressure methanol purification column, use a \(\gamma-\phi\) formulation:

\[
y_i\phi_i^V P =
x_i\gamma_i P_i^{sat}\phi_i^{sat}
\exp\left[\frac{v_i^L(P-P_i^{sat})}{RT}\right]
\]

At sufficiently low pressure, the vapour fugacity and Poynting corrections may be simplified only after a numerical check supports that approximation. The liquid nonideality must remain represented by an activity-coefficient model.

The NIST ThermoML record for Soujanya, Satyavathi and Vittal Prasad (2010) reports methanol–water VLE at 95.3 kPa and sub-atmospheric pressures of 15.19, 29.38, 42.66, 56.03 and 67.38 kPa. The record states that the Wilson model represented the liquid-composition/temperature relationship well. The ThermoML record identifies 66 data points for the methanol–water boiling-temperature dataset.

**Lead candidate:** Wilson activity coefficients, with the parameters regressed from the actual ThermoML x-y-T/P data before use.  
**Alternative:** NRTL fitted to the same dataset and compared using residuals and independent validation data.  
**Blocked condition:** Prompt 3 does not define the column pressure; the Wilson parameters have not been numerically extracted/fitted in Prompt 5. Do not use an atmospheric/sub-atmospheric fit at arbitrary elevated pressure.

Reference: Soujanya et al. (2010), *Experimental (vapour + liquid) equilibrium data of (methanol + water), (water + glycerol) and (methanol + glycerol) systems at atmospheric and sub-atmospheric pressures*, DOI [10.1016/j.jct.2009.11.020](https://doi.org/10.1016/j.jct.2009.11.020); NIST ThermoML record: [https://trc.nist.gov/ThermoML/10.1016/j.jct.2009.11.020.html](https://trc.nist.gov/ThermoML/10.1016/j.jct.2009.11.020.html).

## 6. Association-EOS alternative for polar liquid systems

Methanol and water exhibit hydrogen bonding. CPA and sPC-SAFT association equations of state are literature-supported alternatives for methanol/water-containing liquid and multiphase systems. A comparative study reports that two-site association schemes performed better than three-site schemes for the examined methanol-containing systems, with overall similar CPA and sPC-SAFT performance.

This does not authorise a parameter-free CPA/PC-SAFT model. The pure-component association parameters, cross-association combining rules and binary interaction parameters are absent from the frozen data version. Keep CPA/sPC-SAFT as a future high-pressure polar-mixture alternative if the PR/SRK package cannot reproduce available phase data.

Reference: *Phase equilibria modeling of methanol-containing systems with the CPA and sPC-SAFT equations of state*, Fluid Phase Equilibria (2009), [publisher page](https://www.sciencedirect.com/science/article/pii/S0378381209004312).

## 7. Pure-component and water/steam methods

| Component/property | Selected source method | Limitation |
|---|---|---|
| CO₂, H₂, CO, H₂O, O₂, N₂ gas \(C_p(T)\) | NIST-JANAF / NIST WebBook Shomate functions in `ENERGY008-DATA-0.1.0` | Ideal-gas reference functions only; not a high-pressure mixture enthalpy model |
| Methanol gas \(C_p(T)\) | NIST WebBook gas-phase tabular values | Not a fitted correlation; do not interpolate without a declared method and uncertainty |
| Water/steam thermodynamics | IAPWS-IF97 | Water/steam only; does not supply methanol–water VLE |
| Water viscosity/thermal conductivity | Appropriate IAPWS transport formulations when implemented | No Prompt 5 numerical evaluation was executed |
| Pure-fluid critical metadata | CoolProp 8.0.0 model metadata | Retain as EOS metadata; validate selected model before using in a multicomponent EOS |

Do not mix a liquid-methanol formation enthalpy with a gas-phase methanol/water reactor reaction. The Prompt 5 value of −131.820 kJ/mol for CO₂ + 3H₂ → CH₃OH(l) + H₂O(l) is a 298.15 K reference reaction with liquid products. It is not the heat release for the 250 °C reactor gas-state reaction.

## 8. Electrolyser constitutive model

Use an alkaline-electrolyser model with:

1. Faraday-law H₂ and O₂ production;
2. a cell polarisation relation \(V_{cell}=E_{rev}+\eta_{act,a}+\eta_{act,c}+\eta_{ohm}+\eta_{conc}\);
3. separate stack DC, rectifier and balance-of-plant electrical loads;
4. a vendor performance map over load, temperature, pressure and product purity;
5. a separate water-treatment/reject ledger;
6. a separate O₂ quality/crossover and safe-handling specification.

A constant kWh/kg H₂ may be used only as a clearly identified system-level empirical approximation if the scope requires a rough screening case. The governing design model should use the supplier map once available. No efficiency, voltage, ramp rate, minimum load, degradation or gas purity is assigned in this document.

## 9. Validation and model-selection gates

Before the PR or SRK package is released for model calculations:

- complete the active binary-pair matrix without zero-filling;
- test pure-component vapour pressure, density and compressibility where applicable;
- reproduce the source VLE/PVT datasets used to fit the binary parameters;
- compare PR against modified SRK for dew/bubble and chemical-equilibrium predictions;
- test phase stability for the CO₂/H₂/CO/MeOH/H₂O mixture across the actual reactor, condenser and separator envelope;
- record residuals, uncertainty and extrapolation for every pair.

Before releasing Wilson/NRTL for distillation:

- retrieve the ThermoML data and retain its points/uncertainty;
- regress Wilson and NRTL parameters to the same data;
- validate against an independent methanol–water VLE dataset at the chosen pressure;
- freeze the column pressure and check model validity there.

---

## References used for model-method selection

1. Mbatha, S. et al. (2023). “Development of an Improved Kinetic Model for CO₂ Hydrogenation to Methanol.” *Catalysts* 13(10), 1349. DOI: [10.3390/catal13101349](https://doi.org/10.3390/catal13101349).
2. van Schagen, T. N., Keestra, H. and Brilman, D. W. F. (2025). “Improved kinetic model for methanol synthesis with Cu/ZnO/Al₂O₃ catalysts based on an extensive state-of-the-art dataset.” *Chemical Engineering Journal* 507, 159953. DOI: [10.1016/j.cej.2025.159953](https://doi.org/10.1016/j.cej.2025.159953).
3. Nestler, F. et al. (2022). “Experimental Validation of Methanol Synthesis from Steel Mill Gases Using a Miniplant Setup.” *Chemie Ingenieur Technik* 94, 1466–1475. DOI: [10.1002/cite.202200022](https://doi.org/10.1002/cite.202200022).
4. “Modeling and Experimental Studies on Phase and Chemical Equilibria in High-Pressure Methanol Synthesis.” *Industrial & Engineering Chemistry Research* (2012). DOI: [10.1021/ie3017362](https://doi.org/10.1021/ie3017362).
5. Soujanya, J., Satyavathi, B. and Vittal Prasad, T. E. (2010). “Experimental (vapour + liquid) equilibrium data of (methanol + water), (water + glycerol) and (methanol + glycerol) systems at atmospheric and sub-atmospheric pressures.” *Journal of Chemical Thermodynamics* 42, 621–624. DOI: [10.1016/j.jct.2009.11.020](https://doi.org/10.1016/j.jct.2009.11.020).
6. NIST ThermoML record for the 2010 methanol–water VLE dataset: [https://trc.nist.gov/ThermoML/10.1016/j.jct.2009.11.020.html](https://trc.nist.gov/ThermoML/10.1016/j.jct.2009.11.020.html).
7. NIST Chemistry WebBook SRD 69: [https://webbook.nist.gov/chemistry/](https://webbook.nist.gov/chemistry/).
8. NIST-JANAF Thermochemical Tables SRD 13: [https://janaf.nist.gov/](https://janaf.nist.gov/).
9. IAPWS IF97 R7-97(2012): [https://iapws.org/technical-guidance/release/IF97-Rev](https://iapws.org/technical-guidance/release/IF97-Rev).
10. Elmaihy, A. et al. (2024). “Thermodynamic modeling of alkaline water electrolyzer and assessment of reported cell voltages correlations at low temperature and atmospheric pressure: Critical review.” *Journal of Energy Storage*. DOI: [10.1016/j.est.2024.112674](https://doi.org/10.1016/j.est.2024.112674).
11. “A review of alkaline electrolyzer technology modeling and applications for decision-making optimization in energy systems.” *Renewable and Sustainable Energy Reviews* (2025), 224, 116005. DOI: [10.1016/j.rser.2025.116005](https://doi.org/10.1016/j.rser.2025.116005).
