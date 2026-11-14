# CPS-22 Open Issues, Risks and Decisions

**Status date:** 26 October 2026. An item marked open is not a completed calculation.

## 1. Critical decisions before Phase 2 can freeze the model

| ID | Issue | Consequence if unresolved | Recommended action | Priority |
|---|---|---|---|---|
| OI-01 | No project-specific components/feed/process conditions in assignment | No unique physical process or expected operating point can be claimed | Retain ethanol–water as a documented benchmark and single flash as an explicit provisional baseline; ask instructor/project owner if an actual mixture/process exists | Critical |
| OI-02 | NRTL parameter conventions may differ between sources | Wrong sign/units/formula can produce plausible but invalid activity coefficients | Capture source's exact `tau_ij(T)` form, alpha, units, fitting set and T range; reproduce a source example before integration | Critical |
| OI-03 | SRK binary interaction parameter for ethanol–water is not yet approved | Vapour fugacity predictions may be poor; parameter may be confounded with NRTL fit | Search for a convention-matched published parameter; otherwise fit only a defined training subset and report uncertainty | Critical |
| OI-04 | High-pressure gamma–phi standard state and Poynting term | Omission can bias high-pressure VLE | Implement saturation fugacity and Poynting correction; compare constant-liquid-volume and integrated-volume corrections | Critical |
| OI-05 | Enthalpy consistency is not yet specified | Energy duty can be numerically precise but physically inconsistent | Resolve NRTL T-dependence and liquid/vapour enthalpy reference before reporting any duty | Critical |
| OI-06 | Validation independence | Reusing fitted points overstates validation | Keep raw data source and train/holdout flags; seek an independent experimental publication for the final check | High |
| OI-07 | High-pressure parameter validity range | An extrapolated property model may be used outside evidence | Document all T/P/composition ranges; flag every out-of-range point and prevent silent extrapolation | High |
| OI-08 | Phase-stability/single-phase classification approach | Solver failure can be misreported as a physical one-phase result | Select and implement a suitable bubble/dew and/or tangent-plane stability method; test near phase boundaries | Critical |
| OI-09 | Equipment details (KS, residence time, geometry, mist removal) absent | Separator dimensions lack design credibility | Choose sourced method and assumptions after phase load/density estimates | High |
| OI-10 | Utility temperature and efficiency absent | Duty cannot be converted credibly to steam/cooling-water consumption | Record supply/return conditions and temperature approach; keep duty distinct from utility consumption | Medium |
| OI-11 | Cost source, currency, index, material/pressure factors absent | CAPEX/OPEX cannot be considered reliable | Propose USD 2025 screening basis, then select sourced correlation/index and report uncertainty; adapt currency only as a documented conversion | High |
| OI-12 | Assignment's report headings are numbered 8–21 | Risk of accidental report structure deviation | Preserve supplied numbering/order; annotate numbering discrepancy in report planning notes | Medium |
| OI-13 | MATLAB toolbox/release availability unknown | GUI or solver may fail on target machine | Record MATLAB release and toolbox dependencies; test from a clean session; provide portable solver path | High |
| OI-14 | Density/viscosity/surface-tension needs depend on equipment method | Missing physical properties can block sizing | Select correlation first; collect only needed properties with validity and provenance | Medium |

## 2. Principal model risks

- **Parameter identifiability:** fitting multiple NRTL energy parameters and SRK `k_ij` against the same limited data can overfit. Use distinct sources/subsets and publish parameter confidence.
- **Ethanol–water association/polarity:** classical SRK vapour-phase predictions can be limited for polar associating mixtures. The target model is required, but comparison with PRSV–WS (and PC-SAFT if fully sourced) is necessary.
- **Azeotropy and phase boundaries:** a routine that assumes a simple monotonic K-value ordering may fail near the azeotrope. Ensure root and phase feasibility checks are composition-aware.
- **High-pressure correction:** constant liquid molar volume may be acceptable for initial screening but must be verified against an integrated pressure correction or trusted reference.
- **Heat of mixing:** incomplete NRTL temperature dependence can distort excess enthalpy and duty. Do not use a VLE-only parameter set as an automatically validated energy model.
- **Reference-data rounding/uncertainty:** compare like-for-like measured quantities and report data precision. Avoid reporting more significant figures than measurements support.
- **Equipment scale-up:** Souders–Brown constants and liquid residence times are empirical/design choices; dimensions are preliminary, not mechanically certified pressure-vessel design.
- **Cost precision:** correlations and index updates produce screening estimates only. No vendor quote, detailed mechanical design or site utility tariff is included.

## 3. Change-control rule

Changes must be documented with prior decision, new decision, reason/source, affected functions, impact on model fit/validation, evidence, date/version, and approval state. Never overwrite published data or parameter sets with regressed values without preserving the original.
