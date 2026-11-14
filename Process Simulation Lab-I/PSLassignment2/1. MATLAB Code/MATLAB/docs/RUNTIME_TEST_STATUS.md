# Runtime Test Status

**Build environment:** MATLAB and GNU Octave are not installed or available in this container. MATLAB startup smoke tests and the MATLAB Prompt 19 test suite are therefore **NOT RUN**.

The following checks have been executed outside MATLAB: project static integrity, all 55 declared source-data hashes and formats, declared workbook-sheet and CSV-header contracts, JSON parsing, and independent Python arithmetic against the Prompt 17 fixture (50 checks). Project static integrity completed 98 checks across 55 manifest-declared datasets. These checks do not constitute MATLAB execution or Prompt 21 model validation.

## Target MATLAB runtime features

No minimum MATLAB release or add-on toolbox requirement is claimed verified. Prompt 19 uses core MATLAB JSON, tables, numerical operations and file I/O. The exact MATLAB release must be recorded when runtime testing is performed. SHA-256 integrity checks in `private/sha256_file.m` require a JVM-enabled MATLAB session. XLSX sheet validation requires `sheetnames` or the documented `xlsfinfo` fallback. Optional XLSX and PNG exports are attempted separately and cannot replace mandatory CSV/JSON outputs.

Run in a JVM-enabled MATLAB session after extracting the project:

```matlab
run('MATLAB/START_HERE.m')
run(fullfile(ENERGY008_PROJECT_ROOT, 'MATLAB', 'tests', 'run_startup_smoke_test.m'))
tests = run_prompt19_tests(ENERGY008_PROJECT_ROOT);
R = ENERGY008_RUN;
```

Record the exact MATLAB release, JVM status, workbook sheet-inspection function, toolbox availability, test count, run ID and exported results after execution. Do not describe the engine as validated until Prompt 21 is complete.
