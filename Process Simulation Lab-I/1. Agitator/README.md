# Agitator Design and Scale-Up using MATLAB

## Aim

To design 1 m³ mechanically agitated vessel/tank system with initial volume scaled to 10 m³, with a flat six-blade disk turbine under turbulent flow conditions, and determine the corresponding power consumption of the agitated tank system.

---

# Assumptions

- Fluid is Water

    Density (ρ) = 1000 kg/m³

    Viscosity (μ) = 0.001 Pa.s

- Turbulent Flow

    Reynolds Number = 10000

- Power Number

    Np = 6

- Geometric Similarity

- Scale-up criterion: Equal rate of mass transfer

    N2 = N1 * (1/R)^n , n = 2/3

---

# Variables

## Input Variables

| Variable | Description | Unit |
|-----------|------------|------|
| rho | Density | kg/m³ |
| mu | Dynamic Viscosity | Pa.s |
| Np | Power Number | - |
| V1 | Initial Volume | m³ |
| V2 | Scaled Volume | m³ |

---

## Tank Geometry

| Variable | Description |
|-----------|-------------|
| Dt | Tank Diameter |
| H | Liquid Height |
| J | Baffle Width |

---

## Impeller Geometry

| Variable | Description |
|-----------|-------------|
| Da | Impeller Diameter |
| W | Blade Width |
| L | Blade Length |
| E | Bottom Clearance |

---

## Operating Variables

| Variable | Description |
|-----------|-------------|
| Re | Reynolds Number |
| N | Rotational Speed |
| P | Power Consumption |

---

## Scale-up Variable

| Variable | Description |
|-----------|-------------|
| R | Linear Scale Ratio |

---

# Equations Used

## Tank Diameter

Dt = (4V/π)^(1/3)

---

## Impeller Diameter

Da = 0.3 Dt

---

## Blade Width

W = 0.2 Da

---

## Blade Length

L = 0.25 Da

---

## Clearance

E = 0.33 Da

---

## Reynolds Number

Re = ρ . N . Da² / μ

Rearranged

N = Re . μ / (ρ . Da²)

---

## Power

P = Np . ρ . N³ . D⁵

---

## Scale Ratio

R = (V₂/V₁)^(1/3)

---

# Calculation Procedure

1. Define fluid properties.
2. Define initial vessel volume.
3. Calculate tank dimensions.
4. Calculate impeller dimensions.
5. Assume Reynolds Number = 10000.
6. Compute rotational speed.
7. Compute power consumption.
8. Compute scale ratio.
9. Scale all dimensions.
10. Maintain Reynolds Number.
11. Calculate new rotational speed.
12. Calculate scaled power.
13. Display results.
14. Plot power comparison.

---

# Program Flowchart

```text
START
  │
  ▼
Input Data
  │
  ▼
Tank Design
  │
  ▼
Impeller Design
  │
  ▼
Assume Reynolds Number
  │
  ▼
Calculate Rotational Speed
  │
  ▼
Calculate Power
  │
  ▼
Scale Geometry
  │
  ▼
Maintain Reynolds Number
  │
  ▼
Calculate New Speed
  │
  ▼
Calculate New Power
  │
  ▼
Display Results
  │
  ▼
Plot Graph
  │
  ▼
END
```

---

# Output

The program computes:

- Tank Dimensions
- Impeller Dimensions
- Reynolds Number
- Rotational Speed (rev/s and rpm)
- Power Consumption
- Scale Ratio
- Scaled Dimensions
- Scaled Rotational Speed
- Scaled Power Consumption

---

# Running Instructions

The shared .m file is self-contained and requires no user inputs or intervention. All design parameters are predefined in the MATLAB script as per the provided problem statement.

---

# Author

Mridun Gupta (J24IMT624)
IMT.CE, 2024
Process Simulation Laboratory-I