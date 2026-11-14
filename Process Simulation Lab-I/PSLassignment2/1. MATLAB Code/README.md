# ENERGY-008 MATLAB Project Package

This folder is the extracted MATLAB project root. The executable source remains in the nested `MATLAB/` directory so its existing project configuration and relative-path contracts are preserved. The sibling top-level folder `thinking/` contains the engineering calculations, research, reports, results and evidence repository.

## Launch

1. Extract the complete ZIP without separating the two top-level folders.
2. Open and run `MATLAB/START_HERE.m` (the convenience launcher in this folder). It delegates to the controlled source entry point at `MATLAB/MATLAB/START_HERE.m`.
3. After startup completes, run `app = run_gui;` from the MATLAB Command Window.
4. Run the available tests with:

```matlab
run(fullfile(ENERGY008_PROJECT_ROOT, 'MATLAB', 'tests', 'run_startup_smoke_test.m'))
run_prompt19_tests(ENERGY008_PROJECT_ROOT)
```

The project marker `.energy008-root`, root-level `data/`, `outputs/`, `logs/`, `flowcharts/`, `tests/`, and source folder `MATLAB/` are required by the original root-relative startup contract. Do not move them independently.

**Runtime status:** MATLAB/Octave startup, GUI launch, MATLAB tests and MATLAB/Python parity remain NOT RUN in the build environment. Python migration test records and static source checks are retained as evidence, not as MATLAB execution evidence.
