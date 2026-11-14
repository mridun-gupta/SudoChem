# UNIQUAC Activity Coefficient and Azeotropic Composition

## Objective

To estimate the activity coefficients of the ternary benzene-toluene-water
mixture at **345 K and 1 bar** using the **UNIQUAC model** and to calculate
the azeotropic composition.

The assignment sheet provides the ternary composition, UNIQUAC `r` and `q`
parameters, the `u` interaction matrix, `T = 345 K`, and `P = 1 bar`. The
UNIQUAC formulation uses the combinatorial and residual contributions.

---

# Operating Conditions

| Parameter | Value | Unit |
|---|---:|---|
| Temperature, `T` | 345 | K |
| Pressure, `P` | 1 | bar g|
| Coordination number, `z` | 10 | - |
| Gas constant, `R` | 8.314462618 | J/(mol.K) |

---

# Component Data

Component order:

```text
1 -> Benzene
2 -> Toluene
3 -> Water
```

| Component | Mole fraction `x` | Volume parameter `r` | Area parameter `q` |
|---|---:|---:|---:|
| Benzene | 0.2 | 2.5755 | 2.5880 |
| Toluene | 0.3 | 3.1878 | 2.6340 |
| Water | 0.5 | 2.7694 | 2.4000 |

---

# Interaction Data

```text
u = [
    1.000    1.216    0.203
    0.617    1.000    0.048
    0.838    0.612    1.000
    ]
```

---

# Theory

The UNIQUAC model is:

```text
ln(gamma_i) = ln(gamma_i^C) + ln(gamma_i^R)
```

## Volume fraction

```text
phi_i = x_i*r_i / sum_j(x_j*r_j)
```

## Area fraction

```text
theta_i = x_i*q_i / sum_j(x_j*q_j)
```

## Structural parameter

```text
l_i = (z/2)(r_i - q_i) - (r_i - 1)
```

## Combinatorial contribution

```text
ln(gamma_i^C) =
    ln(phi_i/x_i)
    + (z/2)q_i ln(theta_i/phi_i)
    + l_i
    - (phi_i/x_i) sum_j(x_j*l_j)
```

## Interaction parameter

```text
tau_ij = exp[-(u_ij - u_ii)/(R*T)]
```

## Residual contribution

```text
ln(gamma_i^R) =
q_i [
    1
    - ln(sum_j(theta_j*tau_ji))
    - sum_j {
        theta_j*tau_ij /
        sum_k(theta_k*tau_kj)
      }
]
```

## Total activity coefficient

```text
gamma_i = exp(ln(gamma_i^C) + ln(gamma_i^R))
```

---

# Expected Intermediate Results

The calculation gives approximately:

## Volume fractions

```text
Benzene = 0.180348
Toluene = 0.334837
Water   = 0.484815
```

## Area fractions

```text
Benzene = 0.206396
Toluene = 0.315097
Water   = 0.478507
```

## `l_i` values

```text
Benzene = -1.6380
Toluene =  0.5812
Water   =  0.0776
```

## `tau` matrix

Approximately:

```text
    1.000000    0.999925    1.000278
    1.000134    1.000000    1.000332
    1.000057    1.000135    1.000000
```

---

# Expected Activity Coefficients

| Component | Activity coefficient `gamma_i` |
|---|---:|
| Benzene | **1.113245** |
| Toluene | **1.018379** |
| Water | **1.000301** |

---

# Azeotropic Composition

```text
alpha_12 = gamma_1/gamma_2 = x_2/x_1
alpha_13 = gamma_1/gamma_3 = x_3/x_1
```

Therefore:

```text
x_2 = alpha_12*x_1
x_3 = alpha_13*x_1
```

and:

```text
x_1 + x_2 + x_3 = 1
```

The MATLAB program calculates:

```text
alpha_12 = gamma_1/gamma_2
alpha_13 = gamma_1/gamma_3
```

and then:

```text
xAzeo = [1 alpha_12 alpha_13]
xAzeo = xAzeo/sum(xAzeo)
```

Expected result:

| Component | Azeotropic mole fraction |
|---|---:|
| Benzene | **0.311909** |
| Toluene | **0.340964** |
| Water | **0.347126** |

The values may display as approximately:

```text
Benzene = 0.3119
Toluene = 0.3410
Water   = 0.3471
```

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
                        │ Enter T, P, x, r, q, u and z  │
                        └───────────────┬───────────────┘
                                        │
                                        ▼
                        ┌───────────────────────────────┐
                        │ Validate input data           │
                        │ Σx = 1, x > 0, r > 0, q > 0   │
                        └───────────────┬───────────────┘
                                        │
                                        ▼
                        ┌───────────────────────────────┐
                        │ Convert u → tau               │
                        │ tau_ij = exp[-(u_ij-u_ii)/RT] │
                        └───────────────┬───────────────┘
                                        │
                                        ▼
                        ┌───────────────────────────────┐
                        │ Calculate volume fractions    │
                        │ phi_i                         │
                        └───────────────┬───────────────┘
                                        │
                                        ▼
                        ┌───────────────────────────────┐
                        │ Calculate area fractions      │
                        │ theta_i                       │
                        └───────────────┬───────────────┘
                                        │
                                        ▼
                        ┌───────────────────────────────┐
                        │ Calculate l_i                 │
                        └───────────────┬───────────────┘
                                        │
                                        ▼
                        ┌───────────────────────────────┐
                        │ Calculate combinatorial       │
                        │ ln(gamma_i^C)                 │
                        └───────────────┬───────────────┘
                                        │
                                        ▼
                        ┌───────────────────────────────┐
                        │ Calculate residual            │
                        │ ln(gamma_i^R)                 │
                        └───────────────┬───────────────┘
                                        │
                                        ▼
                        ┌───────────────────────────────┐
                        │ Combine contributions         │
                        │ ln(gamma_i) = C + R           │
                        └───────────────┬───────────────┘
                                        │
                                        ▼
                        ┌───────────────────────────────┐
                        │ Calculate gamma_i             │
                        └───────────────┬───────────────┘
                                        │
                                        ▼
                        ┌───────────────────────────────┐
                        │ Calculate activity            │
                        │ a_i = gamma_i*x_i             │
                        └───────────────┬───────────────┘
                                        │
                                        ▼
                        ┌───────────────────────────────┐
                        │ Calculate alpha_12 and        │
                        │ alpha_13                      │
                        └───────────────┬───────────────┘
                                        │
                                        ▼
                        ┌───────────────────────────────┐
                        │ Calculate azeotropic          │
                        │ composition                   │
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

The shared .m file is self-contained and requires no user inputs or intervention. All parameters are predefined in the MATLAB script as per the provided problem statement.

---

# Author

Mridun Gupta (J24IMT624)

IMT.CE, 2024

Process Simulation Laboratory-I