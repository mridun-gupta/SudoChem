# ENERGY-008 MATLAB Project (Prompts 18-20)

**Project:** ENERGY-008 Green Methanol Process Model  
**Version:** 0.3.0-prompt19-engine-prompt20-gui  
**Status:** Route C is provisional; G3 design basis is not frozen. Reference/screening calculation source and GUI are implemented; MATLAB runtime and physical validation remain NOT RUN.

## Start here

1. Extract the entire `ENERGY-008_Submission` repository folder to any location. Do not extract or run the `MATLAB/` subfolder by itself: the root `.energy008-root` marker and lowercase `data/` directory are part of the project contract.
2. For startup/data-integrity preflight, open `MATLAB/START_HERE.m` in MATLAB and run it. `main.m` only validates configuration/manifest integrity and creates startup logs; it does not execute calculations.
3. For the desktop engineering GUI, open the `MATLAB/` folder in MATLAB and run `app = run_gui;`. The launcher verifies the marker/config and adds only `MATLAB/` plus the explicitly declared `MATLAB/gui/` folder. GUI callbacks delegate to `gui_run_engine.m` and the calculation modules.
4. Run `MATLAB/tests/run_startup_smoke_test.m` and `run_prompt19_tests(ENERGY008_PROJECT_ROOT)` in MATLAB after startup. These tests are prepared but have not been executed in the build environment.

No root/data discovery depends on `pwd`, no `genpath` is used, and `pathdef.m` is not modified. Output runs use unique directories and no-overwrite guards.

## Current execution boundary

The Prompt 19 modules provide ideal stoichiometric reference calculations and bounded pure-component/screening identities. Route B biomass syngas remains blocked; Route C turndown is linear arithmetic screening only; DB-059 is a linear H2 shortfall estimate only. No plant-wide physical 55-stream flow solution exists.

PR78 mixture fugacity/flash, methanol-water VLE, catalyst-matched PFR kinetics, physical recycle/purge, plant energy/entropy/exergy closure, actual compressor/electrolyser/utility performance, measured environmental KPIs and site-based CAPEX/OPEX remain blocked. The automation/HMI layer is offline/read-only and is not a live DCS/PLC/SIS/FGS or safety application.

## Verification status

Python static checks and independent arithmetic checks can be run from the repository root with `python tests/check_project_static.py`, `python tests/check_gui_static.py` and `python tests/check_prompt19_regression.py`. They do not parse or execute MATLAB. The MATLAB unit suite defines direct checks but is NOT RUN. The GUI has not been launched in MATLAB; target-release compatibility, UI behavior, actual exports and screenshots are NOT RUN. See `docs/RUNTIME_TEST_STATUS.md`, `docs/GUI_User_Guide.md` and `docs/Prompt21_GUI_Handoff.md`.
