# Python/Open-Source Migration Map

| MATLAB component | Python mapping | Portability notes |
|---|---|---|
| JSON configuration (`jsondecode`) | `json` | Keep keys and units identical |
| `readtable` / `writetable` | `pandas.read_csv` / `DataFrame.to_csv` | Keep explicit status strings and NaNs |
| NRTL matrix operations | NumPy | Preserve NRTL index convention and units |
| SRK cubic roots | `numpy.roots` | Test root reality thresholds and root sorting |
| `fminsearch` | `scipy.optimize.minimize(method="Nelder-Mead")` | Explicitly map max iterations, function calls and tolerances |
| Reference interpolation | `numpy.interp` or `scipy.interpolate.interp1d` | Add hard range checks; never extrapolate silently |
| Tests and assertions | `pytest` | Carry all Phase 4 fixture and failure tests |
| Plots | Matplotlib | Preserve axes units, provenance and statuses |
| GUI | PySide6/Tkinter or notebook interface | Keep GUI as a consumer of the same engine API |

No production Python port is included in Phase 3. Migration requires independent cross-platform numerical tests.
