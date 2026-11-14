# Bubble Point Problem

## Objective

To determine the **bubble-point temperature** and **equilibrium vapour composition** of a quaternary liquid mixture containing cyclohexane, benzene, toluene and n-heptane at **1 bar** using an **ideal vapour phase** and a **non-ideal liquid phase modelled by UNIQUAC**.

The correct problem specification used for this experiment is:

- Vapour phase: ideal
- Liquid phase: non-ideal
- Liquid-phase activity coefficients: UNIQUAC modelled
- Pressure: 1 bar
- Poynting correction: neglected

---

# Operating Conditions

| Parameter | Value | Unit |
|---|---:|---|
| Pressure, `P` | 1 | bar |
| Coordination number, `z` | 10 | - |
| Vapour fugacity coefficient, `phi^V` | 1 | - |

---

# Component Data

Component order:

```text
1 -> Cyclohexane
2 -> Benzene
3 -> Toluene
4 -> n-Heptane
```

Given liquid composition:

| Component | Mole fraction `x` |
|---|---:|
| Cyclohexane | 0.40 |
| Benzene | 0.20 |
| Toluene | 0.25 |
| n-Heptane | 0.15 |

UNIQUAC structural parameters used:

| Component | `r` | `q` |
|---|---:|---:|
| Cyclohexane | 4.0464 | 3.2400 |
| Benzene | 3.1878 | 2.4000 |
| Toluene | 3.9228 | 2.9680 |
| n-Heptane | 5.1700 | 4.4000 |

---

# Theory

## Vapour-Liquid Equilibrium

For an ideal vapour and non-ideal liquid:

```text
y_i P = x_i gamma_i Psat_i
```

At the bubble point:

```text
Sum_i (x_i gamma_i Psat_i) = P
```

The equilibrium vapour composition is:

```text
y_i = x_i gamma_i Psat_i / P
```

The final result must satisfy:

```text
Sum_i(y_i) = 1
```

---

## UNIQUAC Model

### Volume fraction

```text
phi_i = x_i*r_i / Sum_j(x_j*r_j)
```

### Area fraction

```text
theta_i = x_i*q_i / Sum_j(x_j*q_j)
```

### Structural parameter

```text
l_i = (z/2)(r_i - q_i) - (r_i - 1)
```

### Combinatorial part of contribution

```text
ln(gamma_i^C) =
    ln(phi_i/x_i)
    + (z/2)q_i ln(theta_i/phi_i)
    + l_i
    - (phi_i/x_i) Sum_j(x_j*l_j)
```

### Interaction parameter

For the literature interaction-energy parameters:

```text
tau_ij = exp[-(Delta_u_ij/R)/T]
```

For cyclohexane/n-heptane the temperature-dependent correlation is:

```text
ln(tau_41) = a41 + b41/T
ln(tau_14) = a14 + b14/T
```

### Residual part of contribution

```text
ln(gamma_i^R) =
q_i [
    1
    - ln(Sum_j(theta_j*tau_ji))
    - Sum_j {
        theta_j*tau_ij /
        Sum_k(theta_k*tau_kj)
      }
]
```

### Total activity coefficient

```text
ln(gamma_i) = ln(gamma_i^C) + ln(gamma_i^R)

gamma_i = exp(ln(gamma_i))
```

---

# Pure-Component Vapour Pressure

The program uses:

```text
log10(Psat/bar) = A - B/(T + C)
```

with `T` in Kelvin (K).

| Component | A | B | C |
|---|---:|---:|---:|
| Cyclohexane | 4.13983 | 1316.554 | -35.581 |
| Benzene | 4.72583 | 1660.652 | -1.461 |
| Toluene | 4.07827 | 1343.943 | -53.773 |
| n-Heptane | 4.02832 | 1268.636 | -56.199 |

Source: NIST Chemistry WebBook, SRD 69, Antoine coefficients.

---

# Interaction Data

| Pair | `Delta_u_ij/R` (K) | `Delta_u_ji/R` (K) |
|---|---:|---:|
| Cyclohexane / Benzene | 69.48 | -16.69 |
| Cyclohexane / Toluene | 83.67 | -44.04 |
| Benzene / Toluene | -220.57 | 330.69 |
| Benzene / n-Heptane | -32.03 | 87.50 |
| Toluene / n-Heptane | -72.96 | 108.24 |

Cyclohexane / n-Heptane:

```text
a41 = -0.8744
b41 =  90.41 K

a14 =  0.6985
b14 = -80.76 K
```

Source: Brazilian Journal of Chemical Engineering, pp. 307-317, 2002, 19(3). ISSN: 0104-6632.

---

# Numerical Method

## Step 1: Ideal-liquid starting estimate

Set:

```text
gamma_i = 1
```

and solve:

```text
Sum_i(x_i Psat_i) = P
```

This gives the initial bubble-point temperature.

## Step 2: Calculate UNIQUAC activity coefficients

At the initial temperature calculate:

```text
phi_i
theta_i
l_i
tau_ij
ln(gamma_i^C)
ln(gamma_i^R)
gamma_i
```

## Step 3: Correct the bubble equation

Define:

```text
F(T) = Sum_i(x_i gamma_i Psat_i) - P
```

## Step 4: Perform one Newton iteration

```text
T_(1) = T_(0) - F(T_(0))/(dF/dT)
```

## Step 5: Fully converge

The final bubble-point temperature is obtained by solving:

```text
F(T) = 0
```

using MATLAB `fzero`.

## Step 6: Calculate vapour composition

```text
y_i = x_i gamma_i Psat_i / P
```

Finally verify:

```text
Sum_i(y_i) = 1
```

---

# Expected Results

Using the literature data embedded in `bubble_point.m`, the result should be approximately:

```text
Bubble-point temperature
T_B ≈ 359.4 K
T_B ≈ 86.3 °C
```

The equilibrium vapour is richer in the more volatile components, particularly cyclohexane and benzene.

---

# Program Flow Chart

```text
                    ┌───────────────────────────────┐
                    │            START              │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Clear MATLAB workspace        │
                    │ and command window            │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Enter P, x, r, q, z and       │
                    │ UNIQUAC interaction data      │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Validate x and pressure       │
                    │ Sum(x) = 1, x > 0             │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Solve ideal starting equation │
                    │ Sum(x_i Psat_i) = P           │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Calculate UNIQUAC             │
                    │ phi, theta, l and tau         │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Calculate gamma_i^C and       │
                    │ gamma_i^R                     │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Calculate gamma_i             │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Perform one Newton iteration  │
                    │ for handwritten solution      │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Solve full bubble-point       │
                    │ equation F(T) = 0             │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Calculate equilibrium y_i     │
                    │ y_i=x_i gamma_i Psat_i/P      │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Check Sum(y_i) = 1            │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Display tables and results    │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │             END               │
                    └───────────────────────────────┘
```

---

# Running Instructions

The shared .m file is self-contained and requires no user inputs or intervention. All data and parameters are predefined in the MATLAB script as per the provided problem statement.

---

# References

A additional .zip attachment is shared via e-mail having a EndNote library, referred .pdf, and web links and additional .docx with detailed references.

---

# Author

Mridun Gupta (J24IMT624)

IMT.CE, 2024

Process Simulation Laboratory-I