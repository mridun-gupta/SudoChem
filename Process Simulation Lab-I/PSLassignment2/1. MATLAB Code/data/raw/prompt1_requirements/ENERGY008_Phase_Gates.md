# ENERGY-008 Stage-Gate Plan and Approval Points

**Control rule:** requirements approval precedes route selection; route approval precedes design-basis freeze. No engineering calculations or process selection are authorised by this requirements-baseline phase.

## Gate sequence

### G0: Source and assignment audit

- **Scope:** Complete extraction of PDF pp. 1-5 and Master Prompt; all 27 topics and nine acceptance bullets mapped; equation, loop-table and variable-dictionary content captured.
- **Approval point:** Gate 0 source extraction review; no engineering approval implied.
- **Entry/dependency:** Current phase
- **Required outputs:** Source audit record; baseline files
- **Exit/acceptance criterion:** All source pages reviewed; no omitted topic; source wording separated from recommendations.
- **Status:** Completed for source extraction
- **Hold rule:** No calculations, route selection or design basis freeze.

### G1: Requirements baseline approval

- **Scope:** Review R-01 to R-27, AC-01 to AC-09, mandatory minimums, issue/dependency register and assignment-vs-practice distinctions.
- **Approval point:** User approves requirements baseline and any corrections to interpretation/scope.
- **Entry/dependency:** After this requirements handoff
- **Required outputs:** Traceability workbook; extraction Markdown; open decisions CSV; phase-gates document
- **Exit/acceptance criterion:** User explicitly approves baseline or returns a list of changes; all disputed wording resolved against PDF.
- **Status:** Awaiting user review
- **Hold rule:** Do not start route selection or engineering calculations until requirements baseline is approved.

### G2: Process route and alternative selection

- **Scope:** Evaluate process-route candidates and define at least two alternatives against the approved scope, feed-source options, product grade requirements, utility integration, environmental boundary, evidence quality and feasibility.
- **Approval point:** User approves the selected production route and comparison case definitions.
- **Entry/dependency:** After G1 approval; separate Prompt 2 stage
- **Required outputs:** Route comparison report; source/data register; route block flow diagram; selected route decision record
- **Exit/acceptance criterion:** User selects/approves route and alternative comparison basis; key trade-offs and unresolved dependencies are visible.
- **Status:** Not started - intentionally held
- **Hold rule:** Do not freeze design basis before user route approval. No route is selected in this phase.

### G3: Design basis freeze

- **Scope:** Resolve or obtain approval for capacity, feed source/composition, product grade, location/boundary, operating hours, operating envelope, utility interfaces, emissions/environmental basis, cost basis and declared assumptions.
- **Approval point:** User approves design basis freeze, including every material assumption and known limitation.
- **Entry/dependency:** After G2; route approved
- **Required outputs:** Design Basis Register; assumptions register; input/provenance manifest; case definitions
- **Exit/acceptance criterion:** Every calculation-critical input is sourced or explicitly approved as an assumption; basis has revision and approval record.
- **Status:** Not started - route-dependent
- **Hold rule:** No mass/energy/exergy/equipment calculations using unapproved or invented basis values.

### G4: Data, property and model selection

- **Scope:** Select reaction, thermodynamic/property, phase/separation, hydraulic and other applicable models; establish data provenance, validity ranges and uncertainty.
- **Approval point:** User reviews material model/data choices where they materially affect route feasibility or key results.
- **Entry/dependency:** After G3
- **Required outputs:** Literature/data register; model selection report; equation and parameter register
- **Exit/acceptance criterion:** Models are appropriate to the selected route and range; parameter sources/units/validity/licence limits are recorded.
- **Status:** Not started
- **Hold rule:** Do not silently fill missing parameters or claim validity outside evidence.

### G5: Model formulation and numerical method

- **Scope:** Complete equation derivations, dimensional checks, process boundary/control volumes, solver/recycle logic, residual tolerances and solver flowchart.
- **Approval point:** User approves material model architecture and key calculation conventions.
- **Entry/dependency:** After G3-G4
- **Required outputs:** Equation register; numerical method note; solver flowchart; independent hand-calculation plan
- **Exit/acceptance criterion:** Equations, assumptions, units, initial/boundary conditions and convergence criteria are reviewable before full implementation.
- **Status:** Not started
- **Hold rule:** No implementation should conceal unresolved model choices or tolerances.

### G6: Core process model and preliminary equipment

- **Scope:** Complete stream/component balances, energy/entropy/exergy, recycle convergence and preliminary equipment calculations for base/alternative and operating cases.
- **Approval point:** Review key balances, closure, equipment sizing assumptions and preliminary results.
- **Entry/dependency:** After G5; uses approved G3 basis
- **Required outputs:** Source modules/calculation files; stream tables; balance closure; equipment calculations/datasheets
- **Exit/acceptance criterion:** All outputs have calculation trails and closure/plausibility checks; normal/turndown/upset cases are addressed.
- **Status:** Not started
- **Hold rule:** Do not call results final or certified; unresolved data gaps remain visible.

### G7: PFD/P&ID, controls, HMI and safeguards definition

- **Scope:** Develop PFD, P&ID-level sketch, instrument/loop register, HMI, modes/sequencing, alarm/interlock matrix and safe-state responses.
- **Approval point:** User reviews process/control architecture and critical safety-related assumptions.
- **Entry/dependency:** After G6 equipment and streams stabilise
- **Required outputs:** Drawings; loop/alarm/interlock registers; sequence diagram; GUI/HMI evidence
- **Exit/acceptance criterion:** All assignment fields are complete; basic control is separated from independent safety functions; no unsupported SIL claim.
- **Status:** Not started
- **Hold rule:** Do not claim safety integrity certification or bypass formal risk assessment.

### G8: Utilities, environment, economics and optimisation

- **Scope:** Quantify utility and waste balances, environmental results under approved boundary, CAPEX/OPEX screening, six-variable OAT sensitivity and a multivariable analysis.
- **Approval point:** User approves economic/environmental assumptions and reviews alternatives/operating-window recommendation.
- **Entry/dependency:** After G3, with G6/G7 outputs
- **Required outputs:** Utility/waste registers; environmental basis; CAPEX/OPEX model; sensitivity and scenario outputs
- **Exit/acceptance criterion:** Sources, currency/year, assumptions, ranges and constraints are transparent; at least six sensitivities and one multivariable method completed.
- **Status:** Not started
- **Hold rule:** No site tariffs or environmental reference factors invented; proxies are identified as such.

### G9: MATLAB GUI and verification release

- **Scope:** Complete 13 MATLAB modules, GUI tabs, data/GUI separation, at least three reproducible verification/regression cases and automation tests.
- **Approval point:** User reviews working GUI, run instructions, outputs and test-status matrix.
- **Entry/dependency:** Architecture may begin after G3/G5; release after G6-G8
- **Required outputs:** MATLAB source; GUI; README; test data/logs; verification matrix
- **Exit/acceptance criterion:** All module names and GUI tabs are present; test cases and expected/actual results recorded; unrun tests labelled NOT RUN.
- **Status:** Not started
- **Hold rule:** Do not claim tests or runtime success without actual execution.

### G10: Python migration, report and final package

- **Scope:** Complete Python/open-source migration mapping, parity/licence note, editable Word/PDF report, presentation, final evidence manifest and ZIP package.
- **Approval point:** User approves final report and package contents before handoff.
- **Entry/dependency:** After G9 and stable engineering evidence
- **Required outputs:** Python migration note/source; DOCX/PDF; presentation; manifest; ZIP; final compliance matrix
- **Exit/acceptance criterion:** Every Topic 25/26 deliverable and Acceptance Checklist item is mapped to a file/evidence; ZIP integrity/extraction checked if supplied.
- **Status:** Not started
- **Hold rule:** Do not draft results from planned calculations or conceal limitations.

## Approval record template

| Gate | Reviewer / approver | Decision | Date | Conditions / comments |
|---|---|---|---|---|
| G0 | User | Pending | | |
| G1 | User | Pending | | |
| G2 | User | Pending | | |
| G3 | User | Pending | | |
| G4 | User | Pending | | |
| G5 | User | Pending | | |
| G6 | User | Pending | | |
| G7 | User | Pending | | |
| G8 | User | Pending | | |
| G9 | User | Pending | | |
| G10 | User | Pending | | |

## Non-negotiable sequencing

1. The user reviews and approves the requirements baseline at G1.
2. Route candidates and alternative cases are then assessed in a separate phase. The user approves the production route at G2.
3. Only after G2 may the design-basis package be assembled for user approval at G3.
4. A calculation-critical input must be either sourced with provenance or explicitly marked and approved as an assumption. The absence of data is not permission to invent a plant, capacity, route, feed, product specification or tariff.
5. A gate remains on HOLD if any prerequisite has failed or its evidence is missing. Work can proceed only within the scope of an approved gate.

## Current decision

**Current state: G0 extraction complete; G1 awaiting user review.** Production route selection has not started. Design basis is not frozen. No process calculations, MATLAB code or final report have been produced.