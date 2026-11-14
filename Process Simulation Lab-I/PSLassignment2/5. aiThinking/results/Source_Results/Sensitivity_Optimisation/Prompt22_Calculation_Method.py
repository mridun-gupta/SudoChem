#!/usr/bin/env python3
"""
ENERGY-008 Prompt 22 independent screening calculations.

This script reproduces the closed-form OAT and LHS screening dataset.
It does NOT call the MATLAB engine or implement a physical methanol process model.
Requirements: Python 3, NumPy. No external network is accessed.
"""
from __future__ import annotations
import csv
import json
import math
import os
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parent
REPRO = ROOT / "Reproducibility"
REPRO.mkdir(exist_ok=True)

MW_MEOH = 32.0419
MW_CO2 = 44.0095
MW_H2 = 2.01588
MW_H2O = 18.01528
MW_O2 = 31.9988
BASE_TPD = 50.0
BASE_SEC = 55.0
BASE_TARIFF = 5.0
BASE_CI = 0.40
BASE_RATIO = 3.0
BASE_PURITY = 0.995
BASE_WATER_L_KG = 50.0
BASE_UPTIME = 300.0 / 365.0
CO2_DUTY_KW = 168.8542898861549
HX_U = 100.0
HX_LMTD = 30.0
RHO = 997.0
G = 9.80665
PUMP_HEAD_M = 50.0
PUMP_EFF = 0.70
N = 1000
SEED = 20261102

def calc(throughput_tpd=BASE_TPD, sec=BASE_SEC, tariff=BASE_TARIFF,
         ci=BASE_CI, uptime=BASE_UPTIME, ratio=BASE_RATIO,
         purity=BASE_PURITY, water_l_kg=BASE_WATER_L_KG):
    meoh_kmol_d = throughput_tpd * 1000.0 / MW_MEOH
    co2_kmol_d = meoh_kmol_d
    h2_kmol_d = ratio * meoh_kmol_d
    h2_kg_d = h2_kmol_d * MW_H2
    h2_kg_per_kg_meoh = ratio * MW_H2 / MW_MEOH
    specific_kwh_kg = h2_kg_per_kg_meoh * sec
    power_kwh_d = h2_kg_d * sec
    op_days = uptime * 365.0
    water_m3_d = h2_kg_d * water_l_kg / 1000.0
    return {
        "MeOH_kmol_day": meoh_kmol_d,
        "CO2_kmol_day": co2_kmol_d,
        "CO2_kg_day": co2_kmol_d * MW_CO2,
        "CO2_total_dry_gas_kmol_day": co2_kmol_d / purity,
        "H2_kmol_day": h2_kmol_d,
        "H2_kg_day": h2_kg_d,
        "DI_water_stoich_kg_day": h2_kmol_d * MW_H2O,
        "O2_kg_day": h2_kmol_d / 2.0 * MW_O2,
        "reaction_water_kg_day": meoh_kmol_d * MW_H2O,
        "specific_power_kWh_kgMeOH": specific_kwh_kg,
        "specific_power_kWh_tMeOH": specific_kwh_kg * 1000.0,
        "electrolyser_power_MW": power_kwh_d / 24.0 / 1000.0,
        "electricity_cost_INR_kgMeOH": specific_kwh_kg * tariff,
        "electricity_emissions_kgCO2e_kgMeOH": specific_kwh_kg * ci,
        "water_total_m3_day": water_m3_d,
        "annual_operating_days": op_days,
        "annual_methanol_t": throughput_tpd * op_days,
        "annual_electricity_GWh": power_kwh_d * op_days / 1e6,
        "annual_electricity_cost_INR": power_kwh_d * op_days * tariff,
        "annual_electricity_emissions_tCO2e": power_kwh_d * op_days * ci / 1000.0,
        "annual_total_water_m3": water_m3_d * op_days,
    }

def write_csv(path: Path, rows):
    if not rows:
        return
    with path.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)

def rankdata_no_ties(values):
    # All LHS samples are continuous and ties are practically absent.
    x = np.asarray(values)
    order = np.argsort(x, kind="mergesort")
    ranks = np.empty(len(x), dtype=float)
    ranks[order] = np.arange(1, len(x) + 1, dtype=float)
    return ranks

def run_lhs():
    ranges = {
        "Throughput_tpd": (45.0, 55.0),
        "ALK_SEC_kWh_kgH2": (48.0, 55.0),
        "Electricity_tariff_INR_kWh": (3.0, 8.0),
        "Electricity_CI_kgCO2e_kWh": (0.05, 0.80),
        "Annual_uptime_fraction": (0.80, 0.95),
        "Fresh_H2_CO2_ratio": (3.0, 3.30),
        "Total_water_intensity_L_kgH2": (30.0, 70.0),
        "CO2_dry_purity_molfrac": (0.990, 1.000),
    }
    rng = np.random.default_rng(SEED)
    inputs = {}
    for name, (lo, hi) in ranges.items():
        u = (np.arange(N) + rng.random(N)) / N
        rng.shuffle(u)
        inputs[name] = lo + u * (hi - lo)

    rows = []
    for i in range(N):
        m = calc(
            throughput_tpd=inputs["Throughput_tpd"][i],
            sec=inputs["ALK_SEC_kWh_kgH2"][i],
            tariff=inputs["Electricity_tariff_INR_kWh"][i],
            ci=inputs["Electricity_CI_kgCO2e_kWh"][i],
            uptime=inputs["Annual_uptime_fraction"][i],
            ratio=inputs["Fresh_H2_CO2_ratio"][i],
            purity=inputs["CO2_dry_purity_molfrac"][i],
            water_l_kg=inputs["Total_water_intensity_L_kgH2"][i],
        )
        row = {"Sample_ID": f"LHS-{i+1:04d}"}
        row.update({k: float(v[i]) for k, v in inputs.items()})
        row.update({
            "Specific_electricity_kWh_kgMeOH": m["specific_power_kWh_kgMeOH"],
            "Electricity_cost_INR_kgMeOH": m["electricity_cost_INR_kgMeOH"],
            "Electricity_emissions_kgCO2e_kgMeOH": m["electricity_emissions_kgCO2e_kgMeOH"],
            "Electrolyser_power_MW": m["electrolyser_power_MW"],
            "Annual_methanol_t": m["annual_methanol_t"],
            "Annual_electricity_GWh": m["annual_electricity_GWh"],
            "Annual_electricity_cost_INR_million": m["annual_electricity_cost_INR"] / 1e6,
            "Total_water_m3_day": m["water_total_m3_day"],
            "Annual_total_water_m3": m["annual_total_water_m3"],
            "CO2_total_dry_gas_kmol_day": m["CO2_total_dry_gas_kmol_day"],
            "Status": "SCREENING ONLY - assumed input ranges; no physical solver",
        })
        rows.append(row)

    output_metrics = [
        "Specific_electricity_kWh_kgMeOH",
        "Electricity_cost_INR_kgMeOH",
        "Electricity_emissions_kgCO2e_kgMeOH",
        "Electrolyser_power_MW",
        "Annual_methanol_t",
        "Annual_electricity_GWh",
        "Annual_electricity_cost_INR_million",
        "Total_water_m3_day",
        "Annual_total_water_m3",
        "CO2_total_dry_gas_kmol_day",
    ]
    summary = []
    for metric in output_metrics:
        a = np.array([r[metric] for r in rows], dtype=float)
        summary.append({
            "Metric": metric,
            "P05": float(np.quantile(a, 0.05)),
            "P50": float(np.quantile(a, 0.50)),
            "P95": float(np.quantile(a, 0.95)),
            "Minimum_sample": float(a.min()),
            "Maximum_sample": float(a.max()),
            "Sample_count": N,
            "Interpretation": "Conditional scenario quantiles under assumed independent uniform inputs; not empirical confidence/prediction intervals.",
        })

    ranking = []
    for out in [
        "Specific_electricity_kWh_kgMeOH",
        "Electricity_cost_INR_kgMeOH",
        "Electricity_emissions_kgCO2e_kgMeOH",
        "Annual_electricity_GWh",
        "Total_water_m3_day",
    ]:
        yr = rankdata_no_ties([r[out] for r in rows])
        for inp in ranges:
            xr = rankdata_no_ties(inputs[inp])
            rho = float(np.corrcoef(xr, yr)[0, 1])
            ranking.append({
                "Output_metric": out,
                "Input_variable": inp,
                "Spearman_rho": rho,
                "Interpretation": "Rank association within designed screening sample, not causal/process sensitivity.",
            })

    cost = np.array([r["Electricity_cost_INR_kgMeOH"] for r in rows])
    emissions = np.array([r["Electricity_emissions_kgCO2e_kgMeOH"] for r in rows])
    order = np.argsort(cost)
    pareto = []
    best_em = float("inf")
    for idx in order:
        if emissions[idx] < best_em - 1e-12:
            best_em = emissions[idx]
            r = rows[idx]
            pareto.append({
                "Sample_ID": r["Sample_ID"],
                "Electricity_cost_INR_kgMeOH": r["Electricity_cost_INR_kgMeOH"],
                "Electricity_emissions_kgCO2e_kgMeOH": r["Electricity_emissions_kgCO2e_kgMeOH"],
                "Specific_electricity_kWh_kgMeOH": r["Specific_electricity_kWh_kgMeOH"],
                "SEC_kWh_kgH2": r["ALK_SEC_kWh_kgH2"],
                "Tariff_INR_kWh": r["Electricity_tariff_INR_kWh"],
                "CI_kgCO2e_kWh": r["Electricity_CI_kgCO2e_kWh"],
                "H2_CO2_ratio": r["Fresh_H2_CO2_ratio"],
                "Throughput_tpd": r["Throughput_tpd"],
                "Status": "SCREENING ONLY - no physical design feasibility",
            })

    write_csv(REPRO / "LHS_samples.csv", rows)
    write_csv(REPRO / "LHS_output_intervals.csv", summary)
    write_csv(REPRO / "LHS_rank_associations.csv", ranking)
    write_csv(REPRO / "LHS_pareto_screen.csv", pareto)
    return ranges, rows, summary, ranking, pareto

def main():
    base = calc()
    ranges, rows, summary, ranking, pareto = run_lhs()
    checks = {
        "base_meoh_kmol_day": base["MeOH_kmol_day"],
        "base_co2_kg_day": base["CO2_kg_day"],
        "base_h2_kg_day": base["H2_kg_day"],
        "base_specific_electricity_kWh_kgMeOH": base["specific_power_kWh_kgMeOH"],
        "lhs_sample_count": len(rows),
        "lhs_dimension_count": len(ranges),
        "pareto_sampled_nondominated_count": len(pareto),
        "seed": SEED,
        "status": "SCREENING ONLY; no physical solver or MATLAB runtime",
    }
    with (REPRO / "reproducibility_summary.json").open("w", encoding="utf-8") as f:
        json.dump(checks, f, indent=2)
    print(json.dumps(checks, indent=2))

if __name__ == "__main__":
    main()
