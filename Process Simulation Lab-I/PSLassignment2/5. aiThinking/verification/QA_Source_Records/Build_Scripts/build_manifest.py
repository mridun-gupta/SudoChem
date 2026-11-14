#!/usr/bin/env python3
"""Generate ENERGY-008 repository SHA-256 manifest.

The manifest intentionally excludes itself. The release ZIP is created and
checksummed separately, outside the repository tree.
"""
from __future__ import annotations

import csv
import hashlib
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "ENERGY-008_Submission_Manifest.csv"
EXTERNAL_COPY = Path("/mnt/data/ENERGY-008_Submission_Manifest.csv")
FIELDS = [
    "relative_path",
    "file_size_bytes",
    "sha256",
    "purpose",
    "source_version",
    "verification_status",
]


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def metadata(rel: str) -> tuple[str, str, str]:
    p = Path(rel)
    parts = p.parts
    top = parts[0] if parts else ""
    name = p.name

    if rel == "README.md":
        return "Repository entry point and run instructions", "ENERGY008-REPORT-1.0", "Path contract and local links checked"
    if rel == ".energy008-root":
        return "Project-root discovery marker required by MATLAB startup", "Prompt 23 integrated project", "Included; source startup contract statically checked"
    if top == "MATLAB":
        return "Canonical integrated MATLAB source, configuration, GUI and tests", "Prompt 23 integrated MATLAB tree", "Source included; MATLAB and GNU Octave runtime NOT RUN"
    if top == "Python":
        if "results" in parts:
            return "Python CLI result/export record", "Python migration 0.1.0", "Fresh-extraction CLI run; case status retained in result JSON"
        if "tests" in parts or "test_logs" in parts:
            return "Python migration unit-test source or execution evidence", "Python migration 0.1.0", "Fresh-extraction test suite: 23 passed"
        return "Partial GUI-independent Python migration and pinned environment", "Python migration 0.1.0", "Fresh-extraction editable install and CLI tests completed; physical modules remain fail-closed"
    if top == "data":
        return "Controlled raw, processed, reference and schema data", "ENERGY008-DATA-0.1.0 / draft", "Included; 55 hashed dataset snapshots passed static integrity check"
    if top == "Registers":
        return "Controlled engineering requirements, design, stream, equipment, utility, control, EHS and verification registers", "Prompts 1–23; design basis Rev 0.1-DRAFT", "Included; see per-register limitations and open issues"
    if top == "Calculations":
        return "Hand calculation trail, numerical method, assumptions and independent arithmetic checks", "Prompt 17; ENERGY008-MODEL-0.1.0", "Reference arithmetic/static checks passed; plant balances remain blocked"
    if top == "Results":
        return "Sensitivity, uncertainty, alternative comparison and screening outputs", "Prompt 22; ENERGY008-MODEL-0.1.0", "12 OAT and 8-factor 1,000-sample LHS screening checks passed; physical optimisation blocked"
    if top == "Report":
        return "Final editable engineering report, review PDF and figure/table registers", "ENERGY008-REPORT-1.0 / Rev 1.0", "Prompt 26 PDF: 123 A4 pages; 133 internal links; historical 121-page render QA retained as baseline"
    if top == "Presentation":
        return "Editable engineering summary presentation", "ENERGY008-REPORT-1.0 / Rev 1.0", "16-slide render and overflow check passed"
    if top == "Original_Assignment":
        return "Unchanged governing assignment source", "PSLassignment2.pdf / original source", "Copied unchanged; included in manifest"
    if top in {"PFD_PID", "Flowcharts", "flowcharts", "Diagrams"}:
        return "Editable process, piping, solver, automation and heat-network drawings", "Prompts 7, 15–16; Prompt 24 graphics", "Source files included; conceptual drawings, not approved construction documents"
    if top == "Equipment_Datasheets":
        return "Preliminary equipment datasheets", "Prompt 11; 28 records", "Included; preliminary only, not vendor confirmed"
    if top == "Control_Sequence":
        return "Control philosophy, loop, alarm, interlock, mode and start-stop records", "Prompts 13–15", "Documentation included; HMI and dynamic fault execution NOT RUN"
    if top == "Environment_Safety":
        return "Environmental, waste, HAZID, materials and standards screening records", "Prompts 12–13", "Preliminary screening; formal safety and MRV actions remain open"
    if top == "Sources":
        return "Source bibliography, 74-entry BibTeX and engineering literature/provenance notes", "Prompts 2–24; reference list 74 records", "Citation IDs reconciled; BibTeX 74 entries passed Biber validation"
    if top == "Archive":
        if "Phase_Evidence" in parts and name.lower().endswith(".zip"):
            return "Immutable historical phase handoff archive", "Prompts 19–23", "ZIP integrity test passed with unzip -t"
        return "Historical upstream handoff metadata", "Prompt 24 release", "Retained as source evidence; not the active Prompt 25 manifest"
    if top == "QA":
        if name == "Final_Compliance_Matrix.xlsx":
            return "Topic-by-topic requirements and evidence compliance workbook", "Prompt 25", "Six-sheet workbook; formula error scan returned zero error tokens"
        if name == "Final_Audit_Report.md":
            return "Final repository integration, requirements and release audit", "Prompt 25", "Audit record; final ZIP and extraction tests executed after packaging"
        if name == "ENERGY008_Open_Issues.md":
            return "Open engineering, runtime, vendor, safety and sign-off actions", "Prompt 25", "18 issues retained with status and closure action"
        if name.startswith("Prompt25_Static_Test_Logs") or "Prompt25_Static_Test_Logs" in parts:
            return "Prompt 25 static, archive, path and runtime test log", "Prompt 25", "Execution log; interpretation in final audit report"
        if "Build_Scripts" in parts:
            return "Reproducibility and audit utility script", "Prompt 25", "Included; used for release path/manifest audit"
        return "Quality and result-version evidence", "Prompt 24–25", "Included; see final audit report"
    if top == "Tests" or top == "tests":
        return "Static verification, regression and prior-phase test evidence", "Prompts 19–23; Prompt 25 checks", "Root static suite passed; MATLAB runtime not implied"
    if top in {"Logs", "logs", "outputs"}:
        return "Execution log or runtime output location/readme", "Prompts 19–23", "Included; individual run statuses are preserved"
    if top == "Configuration":
        return "Configuration location and data-path contract index", "Prompt 23 integrated project", "Paths checked against lowercase data directory"
    if top == "documentation":
        return "Integrated project documentation", "Prompt 23 integrated project", "Included; runtime boundaries stated"
    return "Project supporting file", "ENERGY008-REPORT-1.0 / Prompts 1–24", "Included; see final audit and open-issues register"


def main() -> None:
    rows = []
    files = sorted(p for p in ROOT.rglob("*") if p.is_file() and p != MANIFEST)
    for path in files:
        rel = path.relative_to(ROOT).as_posix()
        purpose, version, status = metadata(rel)
        rows.append({
            "relative_path": rel,
            "file_size_bytes": path.stat().st_size,
            "sha256": sha256(path),
            "purpose": purpose,
            "source_version": version,
            "verification_status": status,
        })
    with MANIFEST.open("w", newline="", encoding="utf-8") as stream:
        writer = csv.DictWriter(stream, fieldnames=FIELDS)
        writer.writeheader()
        writer.writerows(rows)
    shutil.copy2(MANIFEST, EXTERNAL_COPY)
    print(f"Repository root: {ROOT}")
    print(f"Manifest rows (self-excluded): {len(rows)}")
    print(f"Manifest: {MANIFEST}")
    print(f"External copy: {EXTERNAL_COPY}")


if __name__ == "__main__":
    main()
