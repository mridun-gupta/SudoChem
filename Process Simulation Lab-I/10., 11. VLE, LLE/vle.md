# Process Simulation Laboratory-I

## Objective

Determine the liquid and vapour compositions of a binary mixture of isobutene + hydrogen sulphide at 25 degC (298.15 K) and 5 bar using the 3-suffix Margules model and safeguarded Newton-Raphson method.

---

# Problem Data

| Parameter | Value | Unit |
|---|---:|---|
| Temperature, `T` | 298.15 | K |
| Pressure, `P` | 5.00 | bar |
| Gas constant, `R` | 8.314462618 | J/mol.K |
| Margules parameter, `D` | 4640 | J/mol |
| Margules parameter, `E` | -1700 | J/mol |

Components:

1. Isobutene
2. Hydrogen sulphide

---

## Antoine Constants

```text
              A          B         C
Isobutene     8.9179     2032.76   -33.15
H2S           9.4838     1768.69   -26.06
```

The code calculates saturation pressure using:

```text
log10(Psat[kPa]) = A - B/(T + C)
```

The resulting pressure is converted from kPa to bar.

---

# Governing Equations

## 3-Suffix Margules Model

For component 1, isobutene:

```text
ln(gamma1) =
[(D + 3E)x2^2 - 4D x2^3] / (RT)
```

For component 2, hydrogen sulphide:

```text
ln(gamma2) =
[(D - 3E)x1^2 + 4D x1^3] / (RT)
```

where:

```text
x1 + x2 = 1
```

## Vapour-Liquid Equilibrium

For an ideal vapour phase:

```text
yi P = xi gamma_i Psat_i
```

Therefore:

```text
Ki = gamma_i Psat_i / P
```

The bubble-point equation used by the program is:

```text
f(x1) = 1 - [x1 K1 + x2 K2] = 0
```

## Newton-Raphson Method

The Newton-Raphson update is:

```text
x1,new = x1 - f/(df/dx1)
```

The derivative used in the MATLAB program is:

```text
df/dx1 =
-K1 + K2
- x1(dK1/dx1)
- x2(dK2/dx1)
```

The derivative of the activity-coefficient contribution is evaluated analytically in the MATLAB function.

## Physical-Domain Safeguard

A normal Newton step can produce a value outside:

```text
0 <= x1 <= 1
```

The program therefore maintains a physical bracket `[xlo,xhi]`.

If the Newton estimate is outside the bracket or is not finite, the program uses:

```text
x1,new = (xlo + xhi)/2
```

This keeps the calculated liquid composition physically meaningful.

---

# Process Flow Chart

```text
                         ┌─────────────────────────────┐
                         │            START            │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │      Enter input data       │
                         │       T, P, D, E, R         │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │ Calculate saturation        │
                         │ pressures from Antoine      │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │ Set initial liquid           │
                         │ composition x1 = 0.60       │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │ Calculate gamma1, gamma2,   │
                         │ K1, K2 and residual f       │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │ Calculate df/dx1 and make   │
                         │ Newton-Raphson estimate     │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                              ┌─────────────────────┐
                              │ Is x1,new inside    │
                              │ the physical range? │
                              └─────────┬───────────┘
                                   YES  │  NO
                                        │
                         ┌──────────────┘ └───────────────┐
                         ▼                                ▼
              ┌─────────────────────┐       ┌─────────────────────┐
              │ Accept Newton step  │       │ Use bracket midpoint│
              └──────────┬──────────┘       └──────────┬──────────┘
                         │                             │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                              ┌─────────────────────┐
                              │    Converged?       │
                              └─────────┬───────────┘
                                   NO  │  YES
                                       │
                         ┌─────────────┘ └─────────────┐
                         ▼                             ▼
              ┌─────────────────────┐      ┌─────────────────────┐
              │ Update x1 and repeat│      │ Calculate final     │
              └─────────────────────┘      │ y1 and y2          │
                                             └──────────┬──────────┘
                                                        │
                                                        ▼
                                             ┌─────────────────────┐
                                             │ Check sum(y) = 1    │
                                             └──────────┬──────────┘
                                                        │
                                                        ▼
                                             ┌─────────────────────┐
                                             │          END        │
                                             └─────────────────────┘
```

---

# Expected Intermediate Results

At `T = 298.15 K` and `P = 5 bar`:

```text
Psat(isobutene) = 0.1766475210 bar
Psat(H2S)       = 9.6252960961 bar
```

The calculation converges approximately to:

```text
x1 = 0.9999944784
x2 = 0.0000055216

gamma1 = 1.0000000000
gamma2 = 90755.4659

K1 = 0.0353295042
K2 = 174709.6464

y1 = 0.0353295042
y2 = 0.9646704958
```

The calculated vapour compositions satisfy:

```text
y1 + y2 ≈ 1
```

---

# One Handwritten Iteration

```text
Initial x1
   ↓
x2 = 1 - x1
   ↓
gamma1, gamma2
   ↓
K1, K2
   ↓
f(x1)
   ↓
df/dx1
   ↓
Newton-Raphson update
   ↓
Physical-domain check
   ↓
x1,new
```

---

# Running Instructions

The shared `.m` file is self-contained and requires no user inputs or intervention. All data and parameters are predefined in the MATLAB script as per the problem statement.

---

# Final Checks

The following conditions should be satisfied:

```text
x1 + x2 = 1
```

```text
y1 + y2 = 1
```

```text
f(x1) ≈ 0
```

and:

```text
yi = xi gamma_i Psat_i / P
```

---

# Author

Mridun Gupta (J24IMT624)

IMT.CE, 2024

Process Simulation Laboratory-I