# CPS-22 Design Basis Register and Decisions

**Version:** Phase 1 baseline, 26 October 2026  
**Basis authority:** CPS-22 assignment PDF and Phase 1 instruction file

## 1. Status labels

- **Specified:** explicitly stated in the assignment or source publication.
- **Proposed:** selected for the project with a written rationale.
- **Assumed:** temporary engineering value or convention that needs a feasibility check.
- **TBD:** not yet supported by adequate data; must be resolved before implementation.
- **Calculated later:** derived from the selected thermodynamic/engineering model in Phase 2 or later.

## 2. Selected reference system

| Item | Phase 1 decision | Status / evidence |
|---|---|---|
| Mixture | Ethanol (1) + water (2) | Proposed benchmark because measured VLE exists at 100, 1500 and 2000 kPa |
| Main reference | Marrero-Pérez et al. (2021), DOI 10.1021/acs.jced.0c00686 | Experimental T–x–y data, high-pressure consistency tests, CC BY 4.0 article |
| Target property model | NRTL liquid activity coefficients + SRK vapour fugacity coefficients | Specified by project title / Phase 1 instructions |
| Pressure correction | Saturation fugacity coefficient and liquid Poynting factor included in the high-pressure formulation | Required model-design decision; approximation to be tested |
| Alternative model | PRSV with Wong–Sandler mixing rule | Proposed benchmark alternative reported for the same mixture in the reference paper |
| Phase boundary | Feed heater plus one equilibrium flash separator | Assumed representative baseline because no process arrangement is provided |
| Chemical reaction | None | Assumption for the physical separation benchmark |
| Recycle / additional stages | None in the baseline | Assumption; not part of a single-flash benchmark |
| Process objective | Establish VLE and calculate phase split, compositions, duties, balances, and preliminary separator loads | Proposed; no product purity/recovery target supplied |
| Process scale | 100 kmol/h feed | Assumed scaling basis, not experimental |
| Feed composition | z_ethanol = 0.50; z_water = 0.50 | Assumed test composition, not experimental |
| Separator pressure | 1.500 MPa | Proposed because it matches the reference experimental pressure |
| Separator temperature | Initially set to midpoint of model-calculated bubble and dew temperatures for P = 1.5 MPa, z_ethanol = 0.50 | Calculated later; must verify a two-phase interval |
| Feed temperature | Initial convention T_feed = T_separator − 20 K | Assumed; test feed phase with the selected property method |
| Feed pressure | Equals separator pressure in first test case | Assumed; no pressure-drop/compression calculation |
| Pressure drop | Zero in baseline | Assumption, revisit for detailed equipment design |
| Shaft work | Zero in baseline process boundary | Assumption; no compressor or pump in the first case |
| Heat duty | Calculated from feed/outlet enthalpies under the selected energy-balance convention | Calculated later |
| Utility | Generic heating duty first; utility medium/conditions selected only after target temperature and site assumptions are set | TBD |
| Vessel design | Preliminary gas–liquid separator, Souders–Brown as screening method plus liquid hold-up/residence-time check | Proposed method; KS and residence time require sourced design assumptions |
| Economics | Screening-level only; provisional basis USD 2025 pending source/cost-index confirmation | Assumed accounting basis; no costs are populated in Phase 1 |
| Internal units | SI: K, Pa, mol/s, J/mol, W, m, m², m³, kg/m³ | Required convention |
| GUI | MATLAB App Designer or equivalent supported MATLAB GUI; calculation engine remains separate | Assignment requirement |
| Python migration | Preserve neutral data structures and independent model/solver APIs for NumPy/SciPy/pandas/matplotlib | Assignment requirement |

## 3. Reference dataset and intended use

The 2021 article reports:
- Experimental T–x–y data at 100 kPa, 1500 kPa and 2000 kPa.
- The 1500 and 2000 kPa datasets are accompanied by high-pressure consistency treatment.
- Minimum azeotropes are reported at (x1 = y1 = 0.899, T = 351.39 K, 100 kPa), (x1 = y1 = 0.857, T = 440.70 K, 1500 kPa), and (x1 = y1 = 0.850, T = 453.83 K, 2000 kPa.

The azeotropic values are useful reference checks only at the published conditions. They are not the operating point of the proposed process test case. The measured Table 6 data should be transcribed with every reported value and units, rounded only as printed, plus the source table/row. The experimental values and the paper's model predictions must be stored in separate fields.

**Initial split proposal:**
- NRTL source/parameter fitting: use a traceable NRTL ethanol–water parameter source or regression on a separate low-pressure training dataset.
- SRK binary interaction parameter: prefer a literature value if a convention-matched source is found; otherwise regress using a declared training subset from the 1500 kPa data and record the objective function.
- High-pressure validation: reserve the 2000 kPa measured points for untouched comparison.
- Low-pressure check: use the 100 kPa measured data for limiting/model checks, avoiding reuse if it was used for NRTL fitting.
- Independence caveat: the primary high-pressure calibration and validation subsets come from the same publication if this split is followed. Phase 2 should look for an independent high-pressure measurement source before final validation acceptance.

## 4. Required property-data requirements

### Pure-component data
For both components, collect and freeze source-backed values for:
- Molecular weight.
- Critical temperature and pressure.
- Acentric factor.
- Vapour-pressure correlation and exact equation form, coefficients, units, and validity interval.
- Ideal-gas heat-capacity/enthalpy correlation.
- Liquid heat capacity, liquid molar volume/density, and enthalpy reference.
- Any required viscosity, thermal conductivity, surface tension, and transport properties for the selected equipment correlations.

NIST Chemistry WebBook links:
- Ethanol: https://webbook.nist.gov/cgi/cbook.cgi?ID=C64175&Mask=27F
- Water: https://webbook.nist.gov/cgi/cbook.cgi?Name=water&cTG=on&cTP=on

Candidate Antoine equations from the NIST pages use `log10(P/bar) = A − B/(T + C)` with T in K:
- Ethanol, 364.8–513.91 K: A = 4.92531, B = 1432.526, C = −61.819 (Ambrose, Sprake et al., 1975, coefficients calculated by NIST from author data).
- Water, 379–573 K: A = 3.55959, B = 643.748, C = −198.043 (Liu and Lindsay, 1970, coefficients calculated by NIST from author data).

Use these only inside their stated temperature ranges. The source contains other ranges; Phase 2 must not accidentally combine a coefficient set with the wrong range or pressure unit. Antoine should be benchmarked against the literature's measured pure-component vapour-pressure data and should not be extrapolated beyond the documented range without a separate model.

### NRTL parameter requirements
For ethanol–water, the literature includes NRTL parameter sets, but the parameter convention and data source must be verified before use. One published table reports values associated with Aspen Plus VLE-IG; another 2024 study analyses NRTL fits across different ethanol–water experimental data sets. Treat these as candidate sources until the exact `tau_ij(T)` definition, signs, units, alpha, temperature range, and data basis are checked. Keep the published set and any regression result as separate records.

### SRK requirements
Collect `Tc`, `Pc`, `omega`, the alpha function, binary `k_ij`, and the mixing-rule convention. The baseline alpha function is the classical Soave form. A `k_ij = 0` value may be used as a diagnostic initial guess only, not silently labelled a validated parameter. Any regressed `k_ij` must report confidence/uncertainty and which data were fitted.

### Enthalpy requirements
A single consistent property method must be used for:
- Pure-component ideal-gas enthalpy/heat capacity.
- SRK residual vapour enthalpy.
- Liquid-phase pure-component/reference enthalpy and pressure correction.
- NRTL excess enthalpy from the temperature dependence of excess Gibbs energy, where applicable.
- Mixture reference-state alignment across both phases.

If the NRTL parameterisation has no defensible temperature dependence, the excess-enthalpy treatment may be inadequate for a meaningful energy balance. Do not report a precise duty before this is resolved.

## 5. Process boundary and balances

The provisional control volume includes inlet feed conditioning/heating and a single equilibrium separator. Its outlets are a vapour stream and a liquid stream when a two-phase state is thermodynamically feasible. No reaction, recycle, external work, or pressure drop is included initially.

Total balance: `F = L + V`.
Component balances: `F z_i = L x_i + V y_i` for every component.
Normalisation: `sum(x_i) = sum(y_i) = sum(z_i) = 1`.
Energy balance under the assignment's convention: `F h_in + Q_dot = L h_L + V h_V + W_dot`; define the work sign convention explicitly and set `W_dot = 0` for the provisional base case.
Closure reports: component and total molar residuals, relative closure errors, energy residual, and relative energy error with denominators that remain well behaved near zero.

## 6. Equipment, utility, and cost basis

### Separator sizing
Use thermodynamic outlet phase rates and densities at actual T/P to calculate actual volumetric flows. Souders–Brown is a preliminary screening correlation, not a guarantee of separation efficiency. A 2015 PetroSkills/John M. Campbell tutorial explains its assumptions, the dependence of the sizing constant on pressure, fluid properties and geometry, and its limitation in quantifying liquid carryover. Record the selected `K_S`, droplet/mist eliminator assumption, cross-sectional gas area fraction, liquid residence time, geometry, pressure design basis and all margins. Validate that the correlation is being used inside its applicable domain.

### Utilities
Start with heat duty in W/kW. Translate this to utility consumption only after specifying utility inlet/outlet conditions, latent/sensible enthalpy basis, temperature approach, and efficiency. Do not claim a steam or cooling-water consumption without its specific enthalpy data and operating conditions. Compression/pumping is zero only under the baseline assumption; add it if pressure changes are later introduced.

### Economics
For screening only, use a provisional cost basis of USD 2025. Phase 2 must select a cited equipment-cost correlation, cost index and source-year pair, equipment material/pressure factors, installation factors, scaling exponent and currency conversion method. If an Indian project basis is needed, add INR conversion with an official dated exchange-rate source as a transparent separate step. OPEX includes the calculated utilities and any evidenced consumables; none should be invented. Report cost ranges and confidence labels rather than false precision.

## 7. Design-basis change control

Any change to mixture, process configuration, standard state, NRTL parameter convention, SRK mixing rule, validation split, enthalpy reference, units, equipment method or cost basis must be entered in the assumptions/change register with:
1. prior value/convention,
2. new value/convention,
3. reason and source,
4. affected modules and regression/validation results,
5. approval/status,
6. version and date.
