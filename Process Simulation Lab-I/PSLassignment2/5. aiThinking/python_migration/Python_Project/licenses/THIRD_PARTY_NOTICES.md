# Third-party notices, licences and data provenance

**Environment pins:** see `requirements.lock` (CPython 3.13.5, Linux x86_64 test environment).  
**Distribution scope:** this project ZIP contains ENERGY-008 source/data plus documentation. It does not vendor the third-party Python package source or binaries; they are installed by pip into the user's environment. The notices below identify the exact pinned dependencies and the upstream licence families. When redistributing an installed environment or binary, retain the exact licence files from the pinned wheels, including vendored components.

## Project source licence status

The ENERGY-008 Python migration files are project-authored engineering software. This deliverable does not assign a new OSI/open-source licence or grant independent redistribution rights for the project source. Confirm the project owner's intended licence before public redistribution.

## Runtime, build and test dependencies in `requirements.lock`

| Package | Pinned version | Licence / notice family | Upstream project / licence source |
|---|---:|---|---|
| NumPy | 2.3.5 | BSD 3-Clause / modified BSD; wheel may bundle separately licensed numerical libraries | https://numpy.org/doc/stable/license.html |
| SciPy | 1.17.0 | BSD 3-Clause | https://github.com/scipy/scipy/blob/main/LICENSE.txt |
| pandas | 2.2.3 | BSD 3-Clause | https://pandas.pydata.org/docs/getting_started/overview.html |
| Matplotlib | 3.10.8 | Matplotlib licence based on PSF licence; project uses BSD-compatible code and preserves per-component notices | https://matplotlib.org/stable/project/license.html |
| pytest | 9.0.2 | MIT | https://github.com/pytest-dev/pytest/blob/main/LICENSE |
| setuptools | 82.0.1 | MIT | https://github.com/pypa/setuptools/blob/main/LICENSE |
| contourpy | 1.3.3 | BSD 3-Clause | https://github.com/contourpy/contourpy |
| cycler | 0.12.1 | BSD 3-Clause | https://github.com/matplotlib/cycler |
| fonttools | 4.63.0 | MIT | https://github.com/fonttools/fonttools |
| iniconfig | 2.3.0 | MIT | https://github.com/pytest-dev/iniconfig |
| kiwisolver | 1.5.0 | Modified BSD | https://github.com/nucleic/kiwi |
| packaging | 25.0 | Apache-2.0 / BSD licence notices as included in its distribution metadata | https://github.com/pypa/packaging |
| Pillow | 12.3.0 | MIT-CMU | https://github.com/python-pillow/Pillow |
| pluggy | 1.6.0 | MIT | https://github.com/pytest-dev/pluggy |
| Pygments | 2.20.0 | BSD 2-Clause | https://github.com/pygments/pygments |
| pyparsing | 3.3.2 | MIT | https://github.com/pyparsing/pyparsing |
| python-dateutil | 2.9.0.post0 | Dual BSD / Apache licence notices | https://github.com/dateutil/dateutil |
| pytz | 2026.2 | MIT | https://pypi.org/project/pytz/ |
| six | 1.17.0 | MIT | https://github.com/benjaminp/six |
| tzdata | 2026.2 | Apache-2.0 | https://github.com/python/tzdata |

### Important wheel-level notices

- NumPy binary wheels can bundle OpenBLAS, LAPACK and the GCC Fortran runtime. Their licence notices are distinct from NumPy's main BSD licence and are carried in the wheel metadata/files. The GCC runtime carries GPL-3.0-or-later with the GCC Runtime Library Exception where present. See the NumPy licence page for the precise wheel contents.
- Matplotlib distributions include third-party font, image, and plotting assets with their own notices. Retain the wheel's `licenses/` or bundled licence files when redistributing an installed application.
- The licence families above are a summary, not a replacement for the full notices shipped with each pinned wheel. Recheck exact metadata and transitive packages whenever the lock changes.

## Evaluated but NOT installed / bundled

| Package | Version reviewed | Capability relevance | Licence / distribution posture | Decision |
|---|---|---|---|---|
| CoolProp | 8.0.0 documentation | Pure-fluid and mixture thermophysical properties, water IF97 and cubic EOS options | MIT per upstream repository; retain notices if adopted | Optional property adapter after mixture/model validation; not included |
| Cantera | 3.2.0 documentation | Gas/surface thermodynamics, kinetics, transport and reactor networks | BSD 3-Clause | Mechanism-gated kinetics candidate; not included |
| BioSTEAM | 2.x / upstream 2.54.0 metadata | Process simulation, unit ops, TEA/LCA, uncertainty and biorefinery workflows | Current LICENSE text identifies University of Illinois/NCSA terms, while setup metadata advertises an MIT license field and UIUC/NCSA classifier. Resolve exact release/licence discrepancy before adoption or redistribution. | Possible later Route B work; not included |
| DWSIM | 10.2.12 | External process simulator with thermodynamic packages, unit operations and CAPE-OPEN support | Open-source desktop/core GPL-3.0; separately published DTL LGPL-3.0 | External independent simulator only; not embedded or bundled |
| NIST REFPROP | Not installed | Reference thermophysical property database | Proprietary/commercial licensing applies; requires user's lawful separate licence | Not included, not redistributed, not a dependency |

## ENERGY-008 data provenance

The JSON cases, reaction network, property records, equipment/utility registers, cost/environmental templates, sensitivity plan and Prompt 17 frozen benchmark fixture are copied from the controlled ENERGY-008 MATLAB project. `data/source_manifest.json` records original relative source path, copied path, SHA-256 of the copied file and source file, and a per-file hash-match flag. At package generation all 13 records resolved and matched.

Source IDs and provenance classifications within the JSON are retained. Property correlations/values refer to their original sources (including NIST Chemistry WebBook/JANAF Shomate data and the Prompt 17 manual-calculation report). This migration does not re-license those external data. No complete or restricted property database is included.

## Equation and code provenance

The Python equations were newly authored against the ENERGY-008 equation register, versioned JSON data and the independent Prompt 17 hand-calculation fixture. They are not a mechanical copy of the MATLAB source. No external package has been silently substituted for PR78, methanol-water VLE, catalyst kinetics or physical recycle models.
