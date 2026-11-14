# Stripping Unit Problem

## Objective

To design a stripping column for the recovery of ammonia from a liquid stream and determine:

- Number of theoretical stages,
- Location of plates,
- Height of stripping tower

---

# Operating Conditions

| Parameter | Value | Unit |
|---|---:|---|
| Feed flow rate, `F` | 100 | kg/h |
| Temperature, `T` | 300 | K |
| Pressure, `P` | 0.7 | bar |
| Column diameter, `D` | 1 | m |
| Liquid flow rate, `L` | 100 | kg/h |
| Volumetric liquid-phase coefficient, `Kxa` | 20 | as supplied |

# Component / Composition Data

| Variable | Meaning | Value |
|---|---|---:|
| `xb` | Liquid inlet NH3 mole fraction | 0.70 |
| `xa` | Liquid outlet NH3 mole fraction | 0.20 |
| `yb` | Gas outlet NH3 mole fraction | 0.60 |
| `ya` | Gas inlet NH3 mole fraction | 0.00 |

# Equilibrium Data

```text
x = [0.10 0.20 0.30 0.40 0.50 0.60 0.70 0.80 0.90 1.00]

y = [0.10 0.20 0.35 0.50 0.60 0.70 0.80 0.90 0.95 0.98]
```

A cubic regression is used:

```text
y_eq = A*x^3 + B*x^2 + C*x + D
```

The code fits the VLE data with `polyfit(...,3)` and stores the four polynomial coefficients.

---

# Theory

## Column Area

```text
Area = pi*D^2/4
```

## Operating Line

```text
y = m*x + c

m = (yb - ya)/(xb - xa)
c = ya - m*xa
```

For the specified compositions:

```text
m = 1.2
c = -0.24
```

## Equilibrium Relation

```text
y* = A*x^3 + B*x^2 + C*x + D
```

At each stage, the cubic equation is solved for the physically meaningful equilibrium liquid composition.

## McCabe-Thiele Method

The stage construction starts from the upper specification `(xb, yb)`. A horizontal move reaches the equilibrium curve, followed by a vertical move to the operating line. The procedure is repeated until `xa` is reached.

## HTU

```text
HTU = L/(Kxa*Area)
```

## NTU

For the liquid-phase stripping basis used in the cleaned code:

```text
Driving force = x - x*

NTU = integral[dx/(x-x*)]
```

The integration is performed from `xa` to `xb` so that the NTU is positive.

## Tower Height

```text
Z = HTU*NTU
```

---

# Expected Numerical Results

| Quantity | Expected value |
|---|---:|
| `Aeq` | -0.63908314 |
| `Beq` | 0.45979021 |
| `Ceq` | 1.19327894 |
| `Deq` | -0.03200000 |
| Operating-line slope, `m` | 1.200000 |
| Operating-line intercept, `c` | -0.240000 |
| Column area | 0.785398 m² |
| Theoretical stages | 2.60632 |
| `HTU` | 6.36620 m |
| `NTU` | 2.66704 |
| Tower height, `Z` | 16.9789 m |

---

# Program Flow Chart

```text
                         ┌─────────────────────────────┐
                         │            START            │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │      Enter input data       │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │       Enter VLE data        │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │     Fit cubic VLE curve     │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │   Calculate operating line  │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │      McCabe-Thiele steps    │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │    Determine plate/stages   │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │       Calculate column      │
                         │            area             │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │        Calculate HTU        │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │        Calculate NTU        │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │    Calculate tower height   │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │       Display results       │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │             END             │
                         └─────────────────────────────┘
```

---

# Running Instructions

The shared .m file is self-contained and requires no user inputs or intervention. All data and parameters are predefined in the MATLAB script as per the provided problem statement.

---

# Author

Mridun Gupta (J24IMT624)

IMT.CE, 2024

Process Simulation Laboratory-I
