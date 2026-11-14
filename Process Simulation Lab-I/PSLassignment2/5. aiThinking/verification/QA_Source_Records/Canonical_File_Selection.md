# ENERGY-008 canonical file selection

**Selection basis:** the Prompt 24 final handoff (`ENERGY008-REPORT-1.0`, evidence cutoff 2026-11-02) is the authoritative release record. No calculations have been recreated or re-keyed in this integration.

## Canonical active trees

- `MATLAB/` is copied from the Prompt 23 integrated MATLAB source snapshot (original source retained in the phase archive). This is the latest integrated MATLAB source containing the updated startup/configuration contract and GUI source.
- `Python/` is copied from the Prompt 23 integrated Python migration snapshot (original source retained in the phase archive). It is the staged GUI-independent migration and carries its own lock, tests, actual run outputs, test logs and documentation.
- `Report/`, `Presentation/`, `Registers/`, `Sources/Bibliography/`, `Equipment_Datasheets/`, the reorganised `PFD_PID/`, `Flowcharts/` and `Diagrams/` source material, and `QA/Result_Version.json` are taken from the Prompt 24 release.

## Superseded snapshots

Loose Prompt 19 MATLAB and Prompt 20 GUI source trees are not duplicated into the active project because they are superseded by the integrated Prompt 23 tree. Their original phase ZIPs remain in `Archive/Phase_Evidence/` (`ENERGY008_MATLAB_Prompt19.zip` and `ENERGY008_MATLAB_Prompt20_GUI.zip`). No original source file was modified or deleted from the upstream handoff.

## Historical and transient exclusions

- Prompt 24 render-preview montages and page-render working directories are excluded as temporary QA outputs; the final report/PDF, figure/table registers and final QA record are retained.
- The unrelated CPS-01 report is excluded. It was only a visual/structural reference and contains unrelated engineering values.
- The previous Prompt 24 manifest is retained as `Archive/Prompt24_Manifest.csv`; this Prompt 25 manifest is freshly generated after final repository assembly.
- Duplicate copies of identical source registers are not replicated into additional arbitrary folders. The project-specific MATLAB/Python input files and controlled source copies under `data/` retain their original relative-path requirements.
