# ENERGY-008 Numerical Methods, Solver Architecture and Acceptance Standard

**Document ID:** ENERGY008-NM-001  
**Revision:** 0.1-DRAFT  
**Date:** 1 November 2026  
**Route:** Route C working basis: biogenic CO2 + renewable electrolytic H2, pressurised alkaline electrolysis reference  
**PFD:** ENERGY008-PFD-001 Rev 0.1-DRAFT  
**Model:** ENERGY008-MODEL-0.1.0  
**Reaction network:** ENERGY008-RXN-0.1.0  
**Property data:** ENERGY008-DATA-0.1.0  
**Balance reference:** BALANCE-REFERENCE-0.1.0  
**Energy reference:** ENERGY-REFERENCE-0.1.0  
**Status:** Numerical-methods specification and test-fixture baseline. Not a validated process simulation, frozen design basis or operating instruction.

> **Design-status constraint.** Route C remains a working configuration; G3 is not frozen. Prompt 8 has only ideal reaction-block/stoichiometric reference calculations. The physical 55-stream plant balance and S-209 recycle were not solved. Prompt 9 contains standard-state reaction-energy references, not a plant energy balance. Prompt 10 contains a reference entropy/exergy basis, not plant entropy generation or exergy closure. The numerical architecture below therefore distinguishes defined methods from blocked calculations. A blocked calculation must remain blocked and carry a machine-readable reason; it must never be replaced by an unrecorded default.

---

## 1. Purpose and implementation contract

This document defines the intended calculation sequence, mathematical model classes, numerical solvers, residuals, scaling, acceptance tests, exception handling and dynamic-model boundary for Prompt 16 and the Prompt 17 handoff.

The implementation is expected to be reproducible and auditable. Every run shall record:

- model, reaction-network, property-data and design-basis versions;
- source file, source row/record, value, unit, provenance class and approval state for every independent input;
- solver, solver version, tolerances, bounds, initialisation, relaxation/line-search settings and iteration counts;
- all residuals, diagnostics, warnings, failure codes and recovery attempts;
- the status of each output: `CALCULATED`, `REFERENCE_ONLY`, `SCREENING_ONLY`, `BLOCKED`, `FAILED` or `NOT_RUN`;
- unrounded machine values and display-rounded values separately.

A numerical solver success flag is necessary but not sufficient. An output is accepted only after conservation, thermodynamic, physical-bound, dimensional, energy/exergy and independent validation checks have passed. No balancing stream, zero binary interaction parameter, generic kinetic parameter, default property, fictitious pressure drop or hidden convergence fallback is permitted.

### 1.1 Status vocabulary

| Status | Meaning | Reporting rule |
|---|---|---|
| CALCULATED | Inputs complete and all specified physical/numerical gates pass | May be reported with uncertainty and traceability |
| REFERENCE_ONLY | Algebraic/standard-state benchmark only | Must carry basis and exclusions; not a plant prediction |
| SCREENING_ONLY | Approximation supported for a limited comparison | Label assumptions and validity range on every output |
| BLOCKED | Required input/property/vendor/model is absent or unvalidated | Preserve null result and explicit blocking reason |
| FAILED | A numerical or physical acceptance gate failed | Preserve last iterate and diagnostics; no accepted result |
| NOT_RUN | Calculation intentionally not executed | Must not be represented as converged or zero |

---

## 2. Process model classification and calculation dependencies

The full ENERGY-008 model is a **hybrid, nonlinear, recycle-coupled process system**. It is not one monolithic equation or one single solver.

| Model block | Mathematical class | Coupling | Intended solution method | Current status |
|---|---|---|---|---|
| Stoichiometric network and element matrix | Linear algebra / exact integer algebra | Independent reaction extents | Exact rank, null-space and atom-balance checks; linear solve for a fully specified reaction-block case | Structure frozen; ideal reference only |
| Front-end CO2 conditioning | Algebraic component balances plus package maps | Sequential with K-101 and mixer | Component-removal/recovery equations, then supplier map | Blocked by source assay and technology/vendor map |
| ALK electrolyser | Algebraic electrochemical balance; optional dynamic ODE | Coupled to power, H2 buffer and synthesis demand | Faraday law plus vendor voltage/performance map; bounded interpolation only inside guarantee | Structure defined; numerical map missing |
| High-pressure synthesis properties | Nonlinear algebraic EOS | Nested inside PFR, flash and compressor states | PR78 phi-phi candidate, stability check and fugacity evaluation; SRK independent cross-check | Blocked: incomplete kij and property validation |
| Reactor kinetics and PFR | Nonlinear ODE in catalyst mass plus local algebraic site equations | Coupled to T, P, composition, fugacity and heat removal | Stiff IVP integration (BDF/Radau) with algebraic kinetic subproblem | Model form provisional; catalyst-matched parameters absent |
| E-302 / V-301 phase split | Nonlinear algebraic flash | Coupled to reactor outlet enthalpy and recycle | TP/PH flash with component balances, fugacity equality, normalisation and phase stability | Blocked: EOS/enthalpy inputs incomplete |
| Recycle / purge loop | Outer nonlinear fixed point or simultaneous nonlinear system | S-209 tear vector includes components, not only total flow | Damped fixed point as baseline; Newton/Anderson only after verified Jacobian/contraction behaviour | No physical iteration executed |
| Distillation T-401 | Large nonlinear algebraic MESH system | Coupled to feed flash, reflux/product/bottoms and heat utilities | Simultaneous Newton/trust-region with Wilson gamma-phi lead and NRTL comparator | Blocked: VLE parameters and feed composition absent |
| Heat integration | Algebraic energy cascade / LP or MILP if discrete choices added | Coupled to unit duties, temperature intervals and utilities | Composite curves, pinch cascade, then constrained network/utility optimisation | Blocked: stream states and duties absent; HX-301 only a candidate |
| Energy / entropy / exergy | Algebraic control-volume balances | Sequential after stream states and work/heat are solved | Signed balances with explicit accumulation and residual closure | Plant calculations blocked |
| Equipment sizing | Algebraic correlations and constrained sizing optimisation | Downstream of solved flow/duty/property cases | Equipment-specific equations and feasibility checks; vendor maps where available | Mostly blocked by unsolved duties and equipment data |
| Economics and environmental KPIs | Algebraic aggregation and scenario analysis | Downstream of utilities, yields, costs and emission factors | Consistent boundary aggregation; scenario/sensitivity analysis | Blocked by site, tariffs, GHG factors and plant balances |
| Automation / sequence model | Discrete state machine; hybrid when coupled to continuous plant states | Events, permissives, alarms, interlocks, timer placeholders | Deterministic state-transition logic; event-driven dynamic simulation only when data justify it | Qualitative sequence defined; dynamic parameters open |

### 2.1 Sequential and iterated calculations

**Sequential outer workflow:** design/data validation → pure-component and mixture property readiness → stoichiometry and feed basis → front-end and electrolyser component rates → synthesis reactor → effluent cooling/flash → liquid and gas split → distillation and offsites → plant stream balances → energy → entropy/exergy → equipment → utilities/environment → economics → controls/sensitivity/KPIs.

**Nested calculations:**

1. EOS property calculations are called repeatedly by the reactor kinetics, reactor energy/pressure-drop calculation, compressor state calculation and high-pressure flash.
2. Kinetic surface-site equations are solved at each PFR integration point using the exact source rate expression and its original pressure/fugacity convention.
3. The PFR is integrated from inlet to outlet in catalyst-mass coordinate. The outlet passes to E-302/V-301.
4. The V-301 gas outlet is split between purge and recycle. The recycle compressor and mixer return S-209 to the PFR inlet. This is the outer recycle closure.
5. Distillation MESH is a separate inner nonlinear solve, connected to V-302 and E-401/E-402 duties.
6. Energy and exergy balances are downstream of converged stream states. A heat-integration candidate cannot create a duty or change stream states without a new, coupled solve.

### 2.2 Variable classification

**Independent inputs:** feed assays, boundary flow/pressure/temperature, approved product target, catalyst and vendor parameters, utility supply conditions, equipment geometry, dead-state reference and economic factors.

**Algebraic unknowns:** component stream flows, reaction extents, flash vapour fraction and phase compositions, EOS roots/fugacity coefficients, adsorption-site coverages, compressor discharge states, MESH stage temperatures/pressures/compositions, purge rate and utility duties.

**PFR dependent variables:** component molar flows \(F_i(W_{cat})\), gas/catalyst temperature \(T_g(W_{cat})\), absolute pressure \(P(W_{cat})\), and optional coolant state when hardware data are available.

**Potential dynamic states (only in a later validated extension):** vessel and line component inventories, reactor/catalyst/fluid thermal inventory, column/reflux/bottoms inventories, H2-buffer inventory, electrolyser stack thermal state, controller integral states, valve/compressor states and discrete automation state ID.

---

## 3. Source model equations and solution procedures

### 3.1 Reaction network and stoichiometric checks

Use the three independent columns in `ENERGY008_Reaction_Network.xlsx`:

- R-01: \(CO_2 + 3H_2 \rightleftharpoons CH_3OH + H_2O\)
- R-02: \(CO_2 + H_2 \rightleftharpoons CO + H_2O\) (RWGS)
- E-01: \(2H_2O \rightarrow 2H_2 + O_2\) (ALK electrolysis subsystem)

The exact reaction-matrix rank is 3 and \(A\nu=0\) for C/H/O. The apparent CO-hydrogenation vector is dependent on R-01 and R-02 and must not be added as an independent extent unless the reaction network and catalyst model are deliberately revised and revalidated.

For a reaction-block reference calculation:

\[
\mathbf F_{out}=\mathbf F_{in}+\nu\,\boldsymbol\xi
\]

Subject to:

\[
\mathbf A\nu=\mathbf 0, \qquad F_i\geq 0
\]

For a complete flowsheet, each unit/component balance is:

\[
\sum F_{i,in}-\sum F_{i,out}+\sum_j \nu_{ij}\dot\xi_j=0
\]

The program shall reject reaction extents that make any species flow negative, violate atom balances or double-count a dependent reaction. Extents must be bounded by reactant availability and the selected kinetic/equilibrium or conversion model. No positive extent is to be guessed merely to obtain a result.

### 3.2 High-pressure gas properties and equilibrium checks

The lead process EOS candidate is PR78 with classical van der Waals one-fluid mixing and temperature-dependent binary interaction parameters. Modified SRK is a comparison model, not an automatic fallback. Each mixture evaluation must:

1. validate composition, pressure and temperature against data coverage;
2. confirm every active pair has source-backed or regressed \(k_{ij}(T)\);
3. solve the EOS cubic and select physically admissible roots using a phase-stability test;
4. calculate fugacity coefficients and fugacities with consistent units and standard state;
5. check composition normalisation, positive compressibility/volume and finite derivatives;
6. record the EOS root, phase and all residuals.

For equilibrium consistency checks:

\[
\ln K_j(T)=-\frac{\Delta_rG_j^\circ(T)}{RT},\qquad
\ln Q_j=\sum_i\nu_{ij}\ln(f_i/f^\circ)
\]

\[
r_{eq,j}=\ln Q_j-\ln K_j(T)
\]

The equilibrium residual is a thermodynamic consistency test or limiting bound, not a replacement for the finite-rate PFR. Current numeric \(K_j(T)\) is blocked by incomplete phase-consistent thermochemical data and EOS validation.

**Hard property gate:** missing active \(k_{ij}\), phase-specific formation data, liquid enthalpy, or an invalid root causes `BLOCKED` or `FAILED`. Do not set a missing \(k_{ij}\) to zero and do not silently use ideal gas at the synthesis pressure.

### 3.3 LHHW kinetics and packed-bed PFR

The provisional reactor model is a 1-D pseudo-homogeneous, non-isothermal packed-bed PFR:

\[
\frac{dF_i}{dW_{cat}}=\sum_j\nu_{ij}r_j
\]

The kinetic structure is source-specific LHHW. The MOD model is conditional on confirming the catalyst as Cu/ZnO/Al2O3/MgO and retrieving its exact parameter table. The CZA alternative requires the source-specific seven-parameter formulation and its validity limitations. No rate constant, adsorption constant, activation energy, catalyst productivity or effectiveness factor is invented.

At each integration point, solve the source-defined adsorption/site-balance algebraic equations, evaluate the original rate expression and check that each rate has the correct units and sign convention. A source kinetic expression based on partial pressure must not be converted to fugacity without refitting/revalidation.

The total-enthalpy form for the reactor energy balance is:

\[
\frac{d}{dW_{cat}}\left(\sum_i F_i h_i(T,P,y)\right)=-q'_{removed}
\]

\[
q'_{removed}=Ua'_{cat}(T_g-T_c)
\]

Do not add a separate \(-r_j\Delta H_{r,j}\) term when formation enthalpies are already included in \(h_i\). The alternative sensible-enthalpy plus explicit reaction-heat form is permissible only if it excludes formation enthalpies from the sensible terms.

Use an adaptive stiff IVP integrator (BDF or Radau) in catalyst mass. Enforce positive absolute pressure, temperature inside the validated kinetic/property envelope, finite nonnegative component flows and bounded site fractions. Couple Ergun pressure drop only after pellet diameter, bed voidage, geometry, flow, density and viscosity are available. Evaluate Weisz-Prater and Mears checks before treating intrinsic rates as reactor-scale rates.

**Current execution status:** PFR differential structure defined, numerical solution blocked until catalyst match/parameters, complete PR78 mixture properties, thermal boundary and pressure-drop inputs are available.

### 3.4 ALK electrolyser

The stack-level Faraday material rates are:

\[
\dot n_{H_2}=\frac{N_{cell}\eta_F I}{2F},\qquad
\dot n_{O_2}=\frac{N_{cell}\eta_F I}{4F}
\]

\[
V_{cell}=E_{rev}+\eta_{act,a}+\eta_{act,c}+\eta_{ohm}+\eta_{conc}
\]

\[
P_{DC,stack}=N_{cell}IV_{cell},\qquad
P_{AC,system}=P_{DC,stack}/\eta_{rectifier}+P_{BOP}
\]

Use either this electrochemical model with source-backed parameters or the vendor system map \(P=f(\dot m_{H2},T,P,load)\), with explicit stack, rectifier, balance-of-plant and compressor boundaries. Interpolate only within the vendor guaranteed map. Extrapolation, negative current/load, gas crossover above OEM acceptance or water outside OEM quality is a failure/permissive block, not a clipped value.

### 3.5 Flash, recycle and purge

The high-pressure condenser/separator uses a \(\phi-\phi\) flash with component balances, phase-fugacity equality, composition normalisation and energy balance. Apply stability testing before accepting a two-phase solution. A no-flash, single-phase or two-phase outcome is determined by the validated model, not forced by a guessed vapour fraction.

The outer loop tear is **S-209**, a component molar-flow vector including CO2, H2, CO, methanol, water and measured inerts. Do not converge on total flow alone. The current Prompt 8 proposed protocol is retained:

- update: \(R^{k+1}=G(R^k)\);
- under-relaxation: \(R^{k+1}_{relaxed}=R^k+\lambda(G(R^k)-R^k)\), with proposed \(\lambda=0.3\);
- scaled residual:

\[
r_R=\max_i\frac{|G_i(R^k)-R_i^k|}{\max(|G_i(R^k)|,F_{scale,i},\epsilon_{scale})}
\]

- proposed tolerance: \(r_R\leq10^{-8}\);
- proposed maximum: 500 iterations;
- initial seed: zero component vector is a **numerical initial guess only**, not a plant assumption.

Retain raw and relaxed vectors, each component residual, purge flow/composition and iteration history. If residuals oscillate or grow, reduce relaxation within a logged bounded range and retry from the last admissible iterate. Anderson acceleration or Newton-Krylov may be introduced only after derivative/Jacobian and stability tests. If 500 iterations are exceeded, emit `E_RECYCLE_MAX`, status `FAILED`, preserve last iterate, and do not export a converged stream table. The physical recycle solver was not run in Prompt 8 because the process model was blocked.

Purge is solved from measured inert ingress and an approved maximum loop-inert constraint, subject to H2/CO2 recovery and U-501 disposal constraints. No fixed purge fraction is allowed until feed assay, flash and off-gas limits are resolved.

### 3.6 Methanol-water distillation

T-401 is modelled as equilibrium-stage MESH equations with gamma-phi phase equilibrium. Wilson is the lead liquid activity model; NRTL is an independent comparator. Do not run the column until column pressure, valid Wilson/NRTL parameters, feed composition, trace impurity partition data and product specification are available.

Use a simultaneous Newton/trust-region solver with physically scaled stage variables. Unknowns include stage temperature, liquid/vapour compositions, flow rates and duties as appropriate. Residuals include component material balances, equilibrium relations, summation, energy balances and boundary specifications. Apply line search/step bounds to maintain positive compositions, temperature/pressure limits and phase consistency. A failed MESH solve is not repaired by silently changing stage count, reflux or pressure.

### 3.7 Heat integration and utility duties

All unit duties use one enthalpy datum (298.15 K, 0.1 MPa(a) for the current reference basis), explicit phases and a single sign convention: heat/work positive into the control volume. The complete steady balance is:

\[
\dot Q+\dot W_{shaft,in}+\dot W_{el,in}+\sum_{in}\dot n_i h_i-\sum_{out}\dot n_i h_i=\frac{dE_{CV}}{dt}
\]

At steady state set the accumulation term to zero only for a solved stationary control volume. The plant is not currently solved steady state. The total enthalpy flow approach already contains heat of reaction when formation enthalpies are included; never add it a second time.

For exchanger preliminary calculations:

\[
Q=UA F\Delta T_{lm}
\]

Only calculate area after valid inlet/outlet states, U, correction factor, fouling basis and pressure-drop constraints exist. For heat integration, construct hot/cold composite curves with a selected and approved minimum approach temperature, calculate the heat cascade/pinch, then evaluate a feasible network including bypass/start-up flexibility. HX-301 is the only currently identified process-process heat recovery candidate; no duty or recovery credit is calculated.

### 3.8 Entropy, exergy and KPI accounting

Entropy balance, with heat positive into the control volume and mass inlet positive:

\[
\frac{dS_{CV}}{dt}=\sum_k\frac{\dot Q_k}{T_{b,k}}+\sum_{in}\dot n_i s_i-\sum_{out}\dot n_i s_i+\dot S_{gen}
\]

Calculate \(\dot S_{gen}\) from the full balance. It must not be assumed positive by construction or clipped to zero. A significantly negative value is a diagnostic failure indicating sign, state, property or boundary inconsistency.

Physical flow exergy:

\[
b_{ph}=(h-h_0)-T_0(s-s_0)+V^2/2+gz
\]

\[
\dot E_D=T_0\dot S_{gen}\geq0
\]

Use the current reproducible reference state \(T_0=298.15\ K\), \(P_0=0.100\ MPa(a)\) for reference-only thermochemistry. It is not a site-specific Indian ambient state. Chemical exergy remains excluded because the chemical dead-state composition is not assigned. The Prompt 10 record confirms that plant stream entropy, physical/chemical exergy, exergy destruction and full closure are not calculated.

KPI aggregation must preserve a declared denominator and boundary. Keep HHV and LHV separate. Specific electrical energy, water intensity, carbon efficiency, H2 utilisation, product recovery, emissions intensity and exergy efficiency remain blocked until the relevant stream/utility and accounting data are solved. Never convert a missing term to zero.

---

## 4. Numerical initialisation, scaling and convergence standards

The numerical limits below are **proposed calculation QA settings**, not process setpoints, equipment design limits or protective trip values. They must be confirmed during software verification and model validation. They do not override measurement uncertainty or model uncertainty.

### 4.1 Scaling

- Store all calculations internally in SI units. Convert at file boundaries only.
- Scale component-flow variables by a declared positive reference scale \(F_{scale,i}\), based on a specified design case or validated feed basis. Retain component-specific scales so trace inerts are not hidden by major H2 flow.
- Scale pressure by \(P_{scale}\), temperature by \(T_{scale}\), duties by \(Q_{scale}\), and inventories by their validated nominal scale.
- Use logarithmic variables for strictly positive quantities only where the variable cannot legitimately be zero; retain explicit zero-flow handling for absent species.
- Scale equilibrium residuals as dimensionless log fugacity residuals; scale energy residuals by \(\max(|Q_{in}|,|Q_{out}|,Q_{scale})\).
- Preserve both dimensional and scaled residuals in logs.

### 4.2 Initial guesses and bounds

1. Start from a stoichiometric limiting/reference solution only when clearly labelled `REFERENCE_ONLY`; do not inject it into a physical loop as a measured flow.
2. Start S-209 recycle with the documented zero vector as a numerical seed. Use the first physically admissible unit-map output as the initial mapped tear; all component flows must be nonnegative.
3. Initialise flash vapour fraction from a valid stability test or a bracketed phase check, not an arbitrary fixed 0.5. Bound vapour fraction to [0,1], compositions to [0,1] with normalisation and nonnegative phase flows.
4. Initialise PFR state from a fully specified inlet stream. State pressure absolute and positive, temperature inside kinetic/property validity, species molar flows nonnegative, and site fractions between 0 and 1 with site sum equal to 1 for each site family.
5. Initialise MESH stage values from a converged thermodynamic estimate or validated design specification. Do not manufacture reflux ratio, feed stage or column pressure.
6. Enforce engineering bounds from approved equipment/vendor data, not literature envelopes or draft screening values. If a required bound is missing, the affected calculation remains blocked.

### 4.3 Proposed numerical tolerances

| Solve / check | Proposed acceptance | Limit / iteration setting | Qualification |
|---|---:|---:|---|
| Stoichiometric rank / atom balance | Exact integer arithmetic; \(A\nu=0\) exactly | Deterministic | Already verified for C/H/O reaction structure |
| Reaction-block component balance | Maximum scaled component residual \(\leq10^{-8}\) | Linear solve / bounded extent | Does not constitute plant closure |
| Elemental closure at process level | Maximum scaled C/H/O residual \(\leq10^{-10}\) | Trace species tracked separately when assayed | Numerical criterion only; analytical uncertainty also reported |
| PR/SRK flash | Component residual \(\leq10^{-8}\); log-fugacity equality \(\leq10^{-8}\); sum fractions residual \(\leq10^{-10}\) | 100 nonlinear iterations proposed | Only after EOS parameters and phase-stability validation |
| PFR integration | Relative error \(10^{-6}\); scaled absolute error \(10^{-9}\) | Adaptive BDF/Radau; proposed 20,000 accepted-step cap | Numerical settings require grid/tolerance refinement test |
| Recycle S-209 | Maximum component scaled residual \(\leq10^{-8}\) | 500 iterations; \(\lambda=0.3\) starting relaxation | Retains Prompt 8 proposed baseline; no physical iteration run |
| MESH distillation | Scaled material/equilibrium residual \(\leq10^{-8}\); energy residual \(\leq10^{-6}\) | 100 Newton/trust-region iterations proposed | Blocked until Wilson/NRTL and column basis are validated |
| Unit/plant energy closure | Relative closure \(\leq10^{-4}\) proposed | No forced correction | Plant closure blocked; report all omitted terms and uncertainty |
| Entropy generation | \(\dot S_{gen}\geq-10^{-8}S_{scale}\) diagnostic floor | No clipping | Any material negative value is a failed balance |
| Exergy closure | Relative closure \(\leq10^{-4}\) proposed; \(\dot E_D\geq0\) | No forced correction | Plant calculation blocked; chemical exergy excluded currently |
| Heat-exchanger / equipment feasibility | Positive finite area/volume/power and all constraints satisfied | Correlation-specific | No generic U, efficiency, pressure drop or design margin |
| Optimisation | Feasible point plus scaled KKT residual \(\leq10^{-6}\) proposed | Multi-start/trust-region; iteration cap recorded | No optimisation accepted before process model and constraints close |

### 4.4 Outer recycle recovery rules

- First attempt: fixed \(\lambda=0.3\) with the S-209 component vector and 500-iteration cap.
- If residual decreases monotonically, continue with the same settings.
- If residual oscillates or grows for consecutive iterations, reduce \(\lambda\) by a recorded factor and restart from the last admissible point. Do not exceed configured minimum/maximum relaxation values.
- If the property flash or unit model fails at any iteration, the recycle iteration is aborted and the inner failure code is returned. Do not extrapolate a bad flash result.
- Optional Anderson acceleration may be enabled only in a separate tested solver configuration, with an admissibility line search and an auditable comparison to the baseline fixed-point result.
- A final recycle pass must recompute every unit with the accepted S-209 vector and rerun the full material/element/energy residual checks. A small tear residual alone does not prove closure.

---

## 5. Missing data, nonphysical states and failure handling

### 5.1 Missing or invalid property data

- Missing PR78 binary interaction parameter: `BLOCKED`, code `E_EOS_KIJ_MISSING`; do not substitute zero.
- Phase/temperature/pressure outside validated property range: `BLOCKED` or `FAILED` according to whether data can be obtained; do not extrapolate without a documented validation study.
- Liquid methanol or methanol-water mixture enthalpy absent: block heat duty, flash/degassing and MESH calculations requiring that property.
- Wilson/NRTL parameters not regressed at selected pressure: block column solve.
- Missing pure component property: block dependent calculations, retain unaffected independent blocks.
- Supplier map point absent or outside guaranteed envelope: reject interpolation/extrapolation and flag vendor data action.

### 5.2 Nonphysical or inconsistent states

- Negative flow, negative holdup, negative absolute pressure, invalid temperature, nonpositive density or compressibility, nonfinite value or NaN: hard failure, never clamp to zero.
- Composition sum outside tolerance: reject and trace the source/normalisation; do not renormalise a materially invalid composition.
- Negative reaction extent is valid only if reverse reaction is explicitly represented by the kinetic/thermodynamic model and the selected sign convention; otherwise reject it.
- Site coverage outside [0,1] or site balance not closed: fail the local kinetic solve.
- Invalid phase fractions, nonpositive liquid/vapour component flow or failed phase stability: fail flash; do not force a split.
- A PFR trajectory crossing outside the validated catalyst/property envelope terminates the integration and records the axial location and state.

### 5.3 Closure diagnostics

**Material:** report species, total mass and C/H/O residuals separately. Preserve the known small reference-block mass residual arising from rounded source molecular weights (approximately -0.062418 kg/day on the existing ideal reference). Do not insert a balancing stream or mislabel it as process loss.

**Energy:** preserve the sign convention and the heat-of-reaction accounting method. The full-enthalpy method includes formation enthalpy; the sensible-only method may include a single reaction term. The two methods must never be combined. If energy residual exceeds the proposed tolerance, report the missing boundary terms, reference-state mismatch and source/property uncertainty.

**Entropy/exergy:** a negative entropy generation result is a diagnostic. Confirm stream directions, heat-transfer boundary temperatures, state properties, accumulation and sign conventions. Do not replace negative values with zero. If the discrepancy remains outside the tolerance band, status is `FAILED`. Do not calculate exergy destruction using \(T_0\dot S_{gen}\) from an invalid entropy balance.

**Equipment:** if required area, duty, flow, power, pressure drop, NPSH, residence time or material condition is infeasible or missing, return `INFEASIBLE` or `BLOCKED` and state the binding constraint. Do not resize or add parallel equipment automatically without an approved scenario.

### 5.4 Error and diagnostic record

Every exception shall record: error code, model block, equipment/stream/reaction ID, iteration or axial/stage index, input snapshot, scaled and dimensional residuals, active bounds, solver return code, last admissible iterate, recovery action, final status and whether downstream outputs were suppressed.

Recommended codes are defined in the `Failure Codes` sheet of the companion workbook, including `E_DATA_MISSING`, `E_UNIT`, `E_NONFINITE`, `E_NEG_FLOW`, `E_EOS_KIJ_MISSING`, `E_PHASE_STABILITY`, `E_KINETICS_UNMATCHED`, `E_PFR_FAIL`, `E_INVALID_EXTENT`, `E_FLASH_FAIL`, `E_RECYCLE_MAX`, `E_MESH_FAIL`, `E_ENERGY_CLOSURE`, `E_SGEN_NEG`, `E_EXERGY_CLOSURE`, `E_SIZING_INFEASIBLE`, `E_OPT_NOFEAS`, `E_DYNAMIC_STIFF` and `E_COMM_STALE`.

---

## 6. Heat integration, optimisation and KPI aggregation

### 6.1 Heat integration method

1. Build stream list only from solved, phase-aware stream states and validated duties.
2. Separate hot/cold process streams from utility streams; do not treat cooling-water circulation as net water consumption.
3. Use approved \(\Delta T_{min}\) and temperature intervals to construct shifted hot/cold composite curves.
4. Perform heat cascade and identify pinch, minimum hot utility and minimum cold utility.
5. Generate feasible heat-exchanger matches with area, pressure-drop, fouling, control/bypass and start-up checks.
6. Verify the energy cascade and plant boundary closure. No heat is counted twice and no HX-301 recovery credit is claimed until calculated and validated.

### 6.2 Optimisation

Optimisation is downstream of a validated flowsheet and equipment/utility model. The objective may later be minimum total annualised cost, electricity use, GHG intensity or a defined multi-objective trade-off. Constraints include material/element closure, product specification, pressure/temperature limits, equipment capacities, minimum stable loads, compressor surge margin, electrolyser map, vent/off-gas capacity, utility availability and environmental constraints.

Use bounded SQP or trust-region methods with scaled variables, a feasible initial point, multiple starts and explicit constraint residuals. A result is not an accepted optimum unless the objective is finite, all process constraints are met, scaled KKT residuals meet the declared criterion, and an independent reevaluation passes all mass/energy/property and design checks. A solver's `success=True` alone is not sufficient. If no feasible point exists, report `NO_FEASIBLE_SOLUTION` with active constraints and do not silently relax limits.

### 6.3 KPI aggregation

Aggregate only from accepted underlying outputs with the correct system boundary. Include provenance and status for every KPI. Keep electrical energy, thermal energy, feed chemical energy and HHV/LHV values separated. Keep gate-to-gate emissions separate from life-cycle factors. The site, electricity emissions factors, PPA/renewable accounting evidence, tariffs, water source and off-gas treatment are currently open; their dependent KPIs remain `BLOCKED`.

---

## 7. Dynamic and hybrid model boundary

The first numerical model is steady state. Prompt 15 sequences are qualitative state/logic narratives; they are not a dynamic process simulation. A dynamic extension is authorised only after equipment holdups, thermal masses, package maps, valve/compressor response, control settings, disturbance profiles and safe-state logic are available.

### 7.1 Candidate continuous states

- component inventories in V-101, V-301, V-302, V-401, TK-401 and W-501 as applicable;
- reactor gas/catalyst temperature and pressure profile or a validated reduced-order bed state;
- column/reflux drum/bottoms inventories and thermal states;
- H2 buffer inventory, pressure and temperature once buffer type/volume are selected;
- ELY stack thermal state, gas-separator inventories and pressure differential once vendor model is supplied;
- compressor speed/driver and valve actuator states only if their dynamic maps are required.

### 7.2 Candidate discrete states and controller states

- automation state ID and sub-state/step number;
- ESD/FGS latch and first-out cause;
- permissive, interlock and package-ready bits with quality/timestamp;
- controller mode (manual/auto/cascade/remote), setpoint source and output tracking;
- maintenance bypass/override state with authorisation, expiry and audit record.

### 7.3 Integration and event handling

- Use an adaptive stiff ODE method (BDF or Radau) when thermal/holdup time constants differ materially. Use an event locator for trips, level/pressure/temperature bounds, analyser quality transitions and sequence-state guards.
- Do not prescribe a fixed process time step until the fastest relevant equipment/controller response and the physical time constants are known. Choose the maximum integration step by time-constant and event-resolution studies; verify by time-step refinement.
- For PLC/DCS simulation, use an event-driven discrete state machine. Controller sample periods, scan times, output update rates and actuator travel speeds are vendor/project inputs and remain symbolic until approved. Do not invent `T_UTIL_STABLE`, `T_ANALYSER_VALID`, `T_RECYCLE_STABLE`, `RAMP_H2_UP`, `MIN_ELY_LOAD` or other Prompt 15 placeholders.
- Disturbance injection uses a time-stamped piecewise input profile with explicit amplitude, duration and event start. DB-059 is an assumed available-power profile at 50% of nominal for 2 h. It is not a measured renewable event and cannot be interpreted as a linear electrolyser output change without the vendor map.
- At event boundaries, apply state transitions in deterministic priority order: independent protection/ESD, package trip, BPCS constraint/turndown, product-quality hold, operator request. Resolve simultaneous events using approved cause/effect priority, not source-code ordering by accident.
- Detect event chatter and zero-time transition loops; apply a configured minimum transition dwell only where justified by the approved sequence, otherwise fail with `E_EVENT_CHATTER`.

### 7.4 Quantified screening disturbance carried from Prompt 15

DB-059 assumes available power is 50% of nominal for 2 h. At the illustrative 50,000 kg/day methanol component-equivalent, using the Prompt 15 molecular weights (32.04 kg/kmol MeOH, 2.016 kg/kmol H2) and 3 mol H2 per mol MeOH:

\[
\dot m_{H_2}=\frac{50,000}{32.04}\times3\times2.016/24
=393.258\;kg/h
\]

If H2 generation were assumed to fall linearly to 50% of nominal for the complete 2 h:

\[
\Delta m_{H_2}=393.258\times(1-0.5)\times2=393.258\;kg
\]

This is a conditional stoichiometric screening deficit only. It is not H2 buffer size, storage capacity, guaranteed ride-through or evidence that the synthesis loop is dynamically stable. It excludes Faradaic efficiency, stack voltage, BOP loads, minimum load, ramp limits, crossover/purity behaviour, compression, buffer pressure limits, recycle/purge and reactor dynamics. The Prompt 8 ideal reference uses a slightly different rounded methanol molecular weight (32.0419 kg/kmol); the software must pin the molecular-weight source/version used by each case instead of silently mixing the two conventions.

---

## 8. Automation state and sequence logic for numerical coupling

Prompt 15 uses the sequence IDs and Prompt 14 cause/effect references. Its state table reuses `ST-90` for both the reactor-stable path and ESD in separate parts of the narrative. To avoid an implementation collision, this Prompt 16 baseline normalises the identifiers below. The detailed state definitions remain conceptually the same; this is an ID correction, not a changed safety action.

| Normalised state | State name | Key guard / transition |
|---|---|---|
| ST-000 | OFF | Start request → ST-010; ESD demand → ST-900 |
| ST-010 | PRE-START REVIEW | Authorised work scope, handback, document revision and permits complete → ST-020 |
| ST-020 | UTILITIES & PROTECTION READY | Required U-001/002/003/004/005/006/009, UPS, DCS, ESD, FGS, U-501 and W-501 proven → ST-030 |
| ST-030 | ISOLATION / INERTING / INTEGRITY HOLD | Approved site/OEM test package, segregated gas paths, O2 analyser and leak-test certificate complete → ST-040 |
| ST-040 | PACKAGE READY | W-201, ELY-201, CO2 and H2 packages ready; water quality and package signals valid → ST-050 |
| ST-050 | CATALYST / REACTOR CONDITIONING HOLD | Catalyst vendor procedure, heat-removal path and reactor instrumentation released → ST-060 |
| ST-060 | CONDITIONED H2 / CO2 AVAILABLE | Composition, purity, moisture, pressure and package map valid → ST-070 |
| ST-070 | RECYCLE / PRESSURE ESTABLISHED | K-301 vendor start complete, anti-surge healthy, V-301 protection and U-501 available → ST-080 |
| ST-080 | CONTROLLED REACTANT ADMISSION / REACTOR STABILISE | Feed ratio and analyser permissives valid; cooling and reactor protection healthy → ST-090 |
| ST-090 | SEPARATION / CRUDE HANDLING | E-302/V-301 stable, V-302 and T-401 ready → ST-100 |
| ST-100 | DISTILLATION / PRODUCT QUALITY STABILISE | E-401/E-402/V-401 stable; quality authority release → ST-110 |
| ST-110 | NORMAL OPERATION | Constraint → ST-111; normal stop → ST-120; ESD → ST-900; off-spec product → ST-920 |
| ST-111 | TURNDOWN | Stable feasible minimum case recovered → ST-110; infeasible sustained constraint → ST-120; ESD → ST-900 |
| ST-120 | CONTROLLED SHUTDOWN | Validated shutdown checklist/energy-inventory state complete → ST-130; ESD → ST-900 |
| ST-130 | SHUTDOWN VERIFIED | New authorised start → ST-010; maintenance entry requires separate isolation/LOTO certificate |
| ST-900 | ESD LATCHED / SAFE-STATE DEMAND | No automatic restart; cause cleared and authorised reset → ST-910 |
| ST-910 | TRIP INVESTIGATION / RESTART HOLD | First-out review, inspection, gas testing, package checks, functional testing and restart review complete → ST-010 only |
| ST-920 | PRODUCT QUALITY HOLD | Product transfer blocked; quality authority release plus process stable → ST-100; ESD → ST-900 |

**Mode layer:** OFF, MAINTENANCE, MANUAL and AUTOMATIC are controller/asset modes, not substitutes for the sequence state. Manual mode cannot bypass ESD, independent package protection, anti-surge, FGS or safety permissives. Maintenance bypasses require authorised impairment control, key/role protection, time-bounded bypass records and compensating measures defined by the site safety lifecycle.

**Global rule:** a qualified ESD, fire/gas or safety-package demand from any active state transitions to ST-900. Power recovery, communications restoration, analyser recovery or detector reset does not restart the process. Reset only clears the latch to ST-910; a new start request and full permissive sequence are required.

---

## 9. Required code modules and file interfaces

The Prompt 16 code structure shall be modular and align with the three flowcharts:

| Module | Responsibility | Principal inputs | Principal outputs |
|---|---|---|---|
| `config_schema` | Versioned schemas, units, case definitions and provenance | YAML/JSON input manifests | Validated typed configuration, schema report |
| `data_gate` | Completeness, approvals, range and source checks | Design basis, assays, vendor/property data | Blocker list and data-quality status |
| `stoich_network` | Stoichiometric matrix, rank, extents and element invariants | Reaction network | Reaction reference and atom-balance report |
| `properties_pure` | Pure-component data and range checking | Frozen property register | Pure-property values and validity flags |
| `properties_eos` | PR78/SRK, fugacity, roots and stability | Composition, T, P, kij | EOS states, fugacities and diagnostics |
| `kinetics_lhhw` | Source-matched kinetics and surface-site equations | Catalyst, composition, T, fugacity/partial pressures, parameter set | Reaction rates and local residuals |
| `reactor_pfr` | PFR integration, energy and pressure drop | Feed state, catalyst mass, coolant/geometry | Axial profiles and reactor outlet |
| `electrolyser_alk` | Faraday and vendor-map reconciliation | Power, current, T, P, water quality, vendor map | H2/O2/water/power/heat and quality status |
| `separation_flash` | E-302/V-301 phase split | Feed state, EOS, cooling duty | Vapour/liquid compositions and flow |
| `recycle_solver` | S-209 tear-stream iteration and purge solution | Unit models, tear seed, purge constraint | Converged recycle or diagnostic failure |
| `distillation_mesh` | T-401 equilibrium-stage model | Crude feed, validated VLE, column specification | Product/bottoms/reflux and duties |
| `energy_balance` | Unit and plant energy accounting | Flow/property/duty data | Closure, duties and utility loads |
| `entropy_exergy` | Entropy/exergy control-volume balances | Stream states and reference environment | Sgen, physical exergy, Ed and closure |
| `equipment_sizing` | Equipment equations and feasibility checks | Solved design cases | Preliminary sizes, limits and gaps |
| `utilities_environment` | Electricity, water, hot/cold utility and emissions boundaries | U-001..U-010, site factors | Utility and environmental balances |
| `economics` | CAPEX/OPEX/LCOM/NPV scenario aggregation | Approved cost/finance assumptions | Economic KPIs with source status |
| `controls_state_machine` | Sequence states, permissives and interlock logic | Prompt 14 C&E, Prompt 15 modes and time-series events | State/event log, command requests, latched fault state |
| `sensitivity_optimisation` | Sensitivity, feasible optimisation and uncertainty | Accepted model and constraints | Ranked drivers, feasible optimum or no-solution report |
| `kpi_report_export` | Data lineage, reports, charts and result status | Accepted outputs | CSV/XLSX/MD/JSON report bundle |

Each module shall expose a typed result object with `status`, `value`, `units`, `input_versions`, `residuals`, `warnings`, `failure_codes` and `provenance`. Downstream modules must refuse required inputs whose status is `BLOCKED`, `FAILED` or `NOT_RUN`.

---

## 10. Validation and test fixture baseline for Prompt 17

The companion `ENERGY008_Convergence_and_Failure_Standards.xlsx` contains the proposed tolerance register, convergence gates, failure-code catalogue, dynamic/automation parameters and machine-readable test fixtures. At minimum, Prompt 17 shall implement:

1. exact reaction rank and C/H/O conservation;
2. ideal reaction-block component and mass closure, retaining the rounded molecular-weight residual;
3. negative-flow and invalid-extent rejection;
4. missing-PR-kij block and out-of-range property block;
5. phase-stability and flash residual tests;
6. a synthetic contraction-map recycle unit test only (not process convergence evidence);
7. physical S-209 recycle status remaining `NOT_RUN_BLOCKED` until a validated process model exists;
8. PFR integration tolerance-refinement and positivity checks once source kinetic data are added;
9. MESH material/equilibrium/energy residual and independent VLE validation;
10. energy-balance no-double-counting regression test;
11. entropy-generation negative diagnostic and exergy sign/closure tests;
12. equipment sizing feasibility and units checks;
13. DB-059 50% power for 2 h arithmetic and explicit vendor-dynamic data blocker;
14. state-machine ESD latching, no-auto-restart, reset-to-hold and product quality hold tests;
15. event priority and communication-loss fail-safe/hold tests.

The Prompt 8 package previously reported nine passing unit tests for ideal reaction-block references and a synthetic fixed-point solver. Those are useful numerical unit tests, but they do not validate the physical flowsheet, PFR, EOS/flash, recycle, distillation or dynamic response.

---

## 11. Prompt 17 handoff and frozen-definition boundary

Prompt 16 freezes the **algorithm structure, proposed numerical QA parameters, exception semantics, module boundaries, normalised sequence IDs and required test fixtures** for software implementation. It does not freeze the process design basis, numeric process setpoints, alarm/trip limits, mechanical ratings, catalyst kinetics, EOS parameters, vendor maps or site utility conditions.

Prompt 17 shall:

- implement the module interfaces in Section 9;
- create the unit tests and test fixture IDs in the companion workbook;
- implement data-gate and explicit blocked-state propagation before enabling dependent solvers;
- reproduce the Prompt 8 reference reaction blocks with the recorded rounded molecular-weight residual;
- keep all plant-level recycle/energy/exergy/dynamic cases blocked until their required data pass validation;
- archive run configuration, residuals, versions and failure logs for every test and case.

**No claim is made that the physical green-methanol plant model is numerically solved or validated at this stage.**
