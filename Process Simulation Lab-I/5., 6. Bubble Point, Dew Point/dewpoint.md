# Dew Point Problem

## Objective

To determine the **dew-point temperature** and **equilibrium liquid composition** of a quaternary vapour mixture containing cyclohexane, benzene, toluene and n-heptane at **1 bar** using an **ideal vapour phase** and a **non-ideal liquid phase modelled by UNIQUAC**.

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

Given vapour composition:

| Component | Mole fraction `y` |
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

At the dew point:

```text
Sum_i [y_i P/(gamma_i Psat_i)] = 1
```

The equilibrium liquid composition is:

```text
x_i = y_i P/(gamma_i Psat_i)
```

Because `gamma_i` depends on the liquid composition, the dew-point calculation requires an inner liquid-composition iteration.

The final result must satisfy:

```text
Sum_i(x_i) = 1
```

The result is independently checked using:

```text
y_i(check) = x_i gamma_i Psat_i / P
```

and:

```text
Sum_i(y_i(check)) = 1
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
Sum_i[y_i P/Psat_i] = 1
```

This gives the initial dew-point temperature.

## Step 2: Calculate first liquid composition

Using the ideal approximation:

```text
x_i = y_i P/Psat_i
```

Normalize the resulting liquid composition.

## Step 3: Calculate UNIQUAC activity coefficients

At the current liquid composition calculate:

```text
phi_i
theta_i
l_i
tau_ij
ln(gamma_i^C)
ln(gamma_i^R)
gamma_i
```

## Step 4: Correct the liquid composition

Define:

```text
x_i(raw) = y_i P/(gamma_i Psat_i)
```

Normalize:

```text
x_i(new) = x_i(raw)/Sum_i[x_i(raw)]
```

Repeat the inner liquid-composition iteration until convergence.

## Step 5: Corrected dew equation

Define:

```text
S(T) = Sum_i[y_i P/(gamma_i Psat_i)]
```

The dew point satisfies:

```text
F(T) = S(T) - 1 = 0
```

## Step 6: Perform one Newton iteration

```text
T_(1) = T_(0) - (S(T_(0))-1)/(dS/dT)
```

The derivative is evaluated numerically in the MATLAB program.

## Step 7: Fully converge

The final dew-point temperature is obtained using a scalar bisection procedure between 350 K and 380 K.

Bisection is used deliberately so that the outer temperature equation always returns a scalar residual.

## Step 8: Calculate final liquid composition

At the converged temperature and liquid-phase activity coefficients:

```text
x_i = y_i P/(gamma_i Psat_i)
```

The final liquid composition is normalized and re-evaluated with UNIQUAC.

Finally verify:

```text
Sum_i(x_i) = 1
```

and:

```text
y_i(check) = x_i gamma_i Psat_i/P
```

---

# Expected Results

Using the literature data embedded in `dewpoint.m`, the result should be approximately:

```text
T_D ≈ 364.6 K

T_D ≈ 91.4 °C
```

The equilibrium liquid composition is richer in less volatile components, particularly Toulene.

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
                    │ Enter P, y, r, q, z and       │
                    │ UNIQUAC interaction data      │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Validate y and pressure       │
                    │ Sum(y) = 1, y > 0             │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Solve ideal starting equation │
                    │ Sum(y_i P/Psat_i) = 1         │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Calculate initial liquid x    │
                    │ x_i=y_i P/Psat_i              │
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
                    │ Update liquid composition     │
                    │ x_i=y_i P/(gamma_i Psat_i)    │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Inner composition converged?  │
                    └──────────────┬────────────────┘
                                   │
                              No ───┘
                                   │
                                   ▼
                    ┌───────────────────────────────┐
                    │ Calculate scalar dew residual │
                    │ F(T)=S(T)-1                  │
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
                    │ Solve full dew-point equation │
                    │ using scalar bisection        │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Calculate final liquid x and  │
                    │ UNIQUAC activity coefficients │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Check Sum(x)=1 and reproduce  │
                    │ specified vapour composition  │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │ Display tables and results    │
                    └───────────────┬───────────────┘
                                    │
                                    ▼
                    ┌───────────────────────────────┐
                    │              END              │
                    └───────────────────────────────┘
```

---

# Running Instructions

The `.m` file is self-contained and requires no user inputs or intervention. All data and parameters are predefined in the MATLAB script as per the corrected problem statement.

Keep the following files in the same MATLAB working directory:

```text
dewpoint_final.m
README_Dew_Point.md
```

Run:

```matlab
dewpoint_final
```

No additional data files are required.

The program prints:

1. Ideal starting temperature.
2. Saturation pressures.
3. Initial ideal liquid composition.
4. UNIQUAC intermediate quantities.
5. One UNIQUAC composition iteration.
6. One Newton temperature iteration.
7. Final dew-point temperature.
8. Final liquid composition.
9. Final activity coefficients.
10. Saturation pressures at the final temperature.
11. Independent VLE check.
12. Final MATLAB result table.

---

# References

A additional .zip attachment is shared via e-mail having a EndNote library, referred .pdf, and web links and additional .docx with detailed references.

---

# Author

Mridun Gupta

Process Simulation Laboratory-I
