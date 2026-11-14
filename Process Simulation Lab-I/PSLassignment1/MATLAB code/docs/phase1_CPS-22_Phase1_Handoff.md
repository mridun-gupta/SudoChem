# CPS-22 Phase 1 Handoff to Phase 2

**Prepared:** 26 October 2026  
**Handoff state:** Ready for Phase 2 analysis with explicit unresolved items  
**Primary assignment:** `1. Problem State(20261026-082927).pdf`  
**Phase instructions:** `Pasted text(20261026-082930).txt`

## 1. Phase 1 decisions

1. Preserve the complete assignment scope: hybrid gamma–phi high-pressure VLE, NRTL liquid phase, SRK vapour phase, equilibrium/process solver, balances, equipment, utilities, economic screening, at least five independent sensitivity studies, flowcharts, modular MATLAB code/GUI, validation, documentation and Python migration.
2. Use ethanol–water as the proposed benchmark because Marrero-Pérez et al. (2021) publishes experimental VLE at 100, 1500 and 2000 kPa, reports high-pressure consistency checks, and is open access.
3. Define a representative single equilibrium flash separator with feed heating as an explicit assumed baseline. Use 100 kmol/h and z_ethanol = 0.50 only as an illustrative process scale/composition. These are not values from the experimental dataset or assignment.
4. Use 1.500 MPa as the initial process-test pressure because it matches a source measurement pressure. Derive initial separator temperature from a verified bubble/dew interval instead of inventing a target temperature. Verify that the default feed state is physically valid.
5. Implement the complete high-pressure gamma–phi relation including pure saturated-vapour fugacity and a liquid Poynting correction. Test rather than silently omit the correction.
6. Select PRSV–WS as the primary alternative formulation for benchmarking; keep PC-SAFT as a secondary option if data and implementation are supportable.
7. Use measured reference data for validation, with a declared fit/holdout split. A proposed 1500 kPa fit / 2000 kPa holdout uses different pressure conditions from the same paper; Phase 2 should seek another independent experimental source to improve publication-level independence.
8. Keep units internally SI and preserve the assignment's 8–21 technical-report topic numbering/order.
9. Do not claim any Phase 2–5 numerical results, executable MATLAB files, GUI, validation scores, vessel dimensions, utilities or cost estimates from this handoff.

## 2. Data provenance

Primary high-pressure VLE reference:
- Marrero-Pérez et al. (2021), “High-Pressure Phase Equilibria in an Ethanol/Water Binary System: Experimental Data and Modeling,” *Journal of Chemical & Engineering Data* 66(2), 928–946. DOI: `10.1021/acs.jced.0c00686`. DOI URL: https://doi.org/10.1021/acs.jced.0c00686
- Reported measured pressure levels: 100, 1500 and 2000 kPa.
- The measured T–x–y values should be transcribed and identified separately from model predictions in the paper.

Other source families:
- NRTL original formulation: Renon and Prausnitz (1968), DOI `10.1002/aic.690140124`.
- NIST Thermodynamics Research Center NRTL implementation notes: https://trc.nist.gov/TDE/TDE_Help/NRTL-AC-Model.htm
- NIST Chemistry WebBook pure-component data and Antoine equations: ethanol https://webbook.nist.gov/cgi/cbook.cgi?ID=C64175&Mask=27F ; water https://webbook.nist.gov/cgi/cbook.cgi?Name=water&cTG=on&cTP=on
- SRK original paper: Soave (1972), DOI `10.1016/0009-2509(72)80096-4`.
- Ethanol–water NRTL candidate parameter source: Teles et al. / article titled “Control Structures Evaluation for a Salt Extractive Distillation Pilot Plant: Application to Bio-Ethanol Dehydration,” *Energies* 10(9), 1276 (2017), DOI `10.3390/en10091276`; use only after exact convention and parameter context are verified.
- NRTL data-selection/regression study: “Effect of Variation between Different Experimental VLE Data Sets on Thermodynamic Model and Separation Predictions: NRTL Correlation of the Ethanol + Water System,” DOI `10.1021/acs.iecr.4c00484`.
- Preliminary separator method: PetroSkills / John M. Campbell, “Gas-Liquid Separators Sizing Parameter” (September 2015), https://www.jmcampbell.com/tip-of-the-month/wp-content/uploads/2015/09/Sep_2015_Gas-Liquid-Separators-Sizing-Parameter-MM083015.pdf
- Costing method: a recognized chemical engineering design text and/or documented cost-correlation source will be selected in Phase 2. Cost index, currency, material factors and scaling range are not yet populated.

## 3. Critical items Phase 2 must resolve

- Confirm the intended mixture and process if the instructor/project owner has a system other than the proposed benchmark.
- Download/transcribe all measured T–x–y points and metadata; preserve publication/table/row, pressure, uncertainty/rounding and licensing provenance.
- Freeze the precise NRTL parameter equation and directional conventions; reproduce a literature value/example independently.
- Obtain/fit SRK binary interaction parameters under a documented objective and training subset.
- Decide the high-pressure standard state, saturated-vapour fugacity calculation and Poynting integral/approximation.
- Freeze the enthalpy model, reference state and treatment of NRTL excess enthalpy.
- Demonstrate phase feasibility at the proposed default test basis before accepting it.
- Select numerical solver, scaled residuals, tolerances, restart logic and phase-stability criteria.
- Select separator sizing assumptions, utility conditions and cost correlation/index.
- Find an independent experimental validation set if feasible, and reserve it untouched.

## 4. Files included

- `CPS-22_Project_Charter.md`
- `CPS-22_Requirements_Matrix.xlsx`
- `CPS-22_Design_Basis.md`
- `CPS-22_Input_and_Property_Register.xlsx`
- `CPS-22_Source_Register.xlsx`
- `CPS-22_Assumptions_and_Uncertainty_Register.xlsx`
- `CPS-22_Model_and_Equation_Register.md`
- `CPS-22_Solver_and_Verification_Plan.md`
- `CPS-22_Architecture_and_Deliverables.md`
- `CPS-22_Open_Issues.md`
- `CPS-22_Phase1_Handoff.md`

`CPS-22_Phase1_Handoff.zip` contains the complete folder for transfer and archival.

## 5. Instructions to Phase 2

Start with the property/source register and open-issues register. Reconcile the NRTL parameter convention and obtain the raw measured reference table before writing the solver. Keep each raw source, converted input and fitted parameter set separately versioned. Do not start a full process simulation until the high-pressure standard state, data ranges, enthalpy method and phase-state test are settled.

The first Phase 2 deliverable should be a **frozen technical design basis and parameter/data pack** plus an equation-by-equation derivation. The next deliverable should be an independently checked thermodynamic calculation notebook/script that reproduces at least one published reference point before MATLAB architecture work accelerates.
