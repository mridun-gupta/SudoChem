# Process Simulation Laboratory-I

## Objective

Determine equilibrium compositons of the two liquid phases of benzene + toulene + water for 345K and 1bar using UNIQUAC.
(Bounded/nested bisection is used because unrestricted Newton-Raphson iterations can generated mole fractions outside the physical range).

---

# Problem Data

| Parameter | Value | Unit |
|---|---:|---|
| Temperature, `T` | 345 | K |
| Pressure, `P` | 1 | bar |

Components:

1. Benzene
2. Toluene
3. Water

---

## UNIQUAC Volume and Area Parameters

```text
r = [2.5755  3.1878  2.7694]
q = [2.5880  2.6340  2.4000]
```

## Interaction Matrix

The supplied matrix is entered directly as the UNIQUAC `tau` matrix:

```text
tau = [1.000  1.216  0.203
       0.617  1.000  0.048
       0.838  0.612  1.000]
```

---

# Governing Equations

## Mole-Fraction Constraint

For both liquid phases:

```text
x1 + x2 + x3 = 1
```

and:

```text
y1 + y2 + y3 = 1
```

where:

```text
x = organic-rich liquid phase
y = aqueous-rich liquid phase
```

## UNIQUAC Volume Fraction

```text
phi_i = x_i r_i / sum(x_j r_j)
```

## UNIQUAC Surface Fraction

```text
theta_i = x_i q_i / sum(x_j q_j)
```

## Combinatorial Contribution

The program uses:

```text
l_i = 5(r_i - q_i) - (r_i - 1)
```

and:

```text
ln(gamma_i^C) =
ln(phi_i/x_i)
+ 5 q_i ln(theta_i/phi_i)
+ l_i
- (phi_i/x_i) sum(x_j l_j)
```

## Residual Contribution

The program calculates:

```text
S_j = sum(theta_i tau_ij)
```

and:

```text
term_i = sum[theta_j tau_ij / S_j]
```

Therefore:

```text
ln(gamma_i^R) =
q_i [1 - ln(S_i) - term_i]
```

The total activity coefficient is:

```text
ln(gamma_i) =
ln(gamma_i^C) + ln(gamma_i^R)
```

and:

```text
gamma_i = exp(ln(gamma_i))
```

---

# Liquid-Liquid Equilibrium

At equilibrium:

```text
x_i gamma_i,org = y_i gamma_i,aq
```

Therefore the distribution coefficient is:

```text
K_i = gamma_i,aq / gamma_i,org
```

The two liquid phases are represented as:

```text
Extract   = organic-rich phase
Raffinate = aqueous-rich phase
```

---

# Rachford-Rice Phase Split

For feed composition `z_i`, the Rachford-Rice equation is:

```text
RR(psi) =
sum[(K_i - 1) z_i / {1 + (K_i - 1) psi}] = 0
```

The root is restricted to:

```text
0 <= psi <= 1
```

and is obtained using bisection.

The phase update is:

```text
x_i,new = z_i / [1 + (K_i - 1) psi]
```

and:

```text
y_i,new = K_i x_i,new
```

In the MATLAB program:

```text
psi = Extract/F
```

Therefore the aqueous-rich liquid/feed ratio is:

```text
L_aq/F = 1 - psi
```

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
                         │       T, P, r, q, tau       │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │ Normalize all composition   │
                         │ vectors as row vectors      │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │ Generate five reproducible  │
                         │ initial phase compositions  │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │ Calculate UNIQUAC gamma for │
                         │ organic and aqueous phases  │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │ Calculate K_i = gamma_aq /  │
                         │          gamma_org          │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │ Evaluate Rachford-Rice at   │
                         │ psi = 0 and psi = 1         │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                              ┌─────────────────────┐
                              │ Root bracketed in   │
                              │       [0,1]?        │
                              └─────────┬───────────┘
                                   YES │ NO
                                       │
                         ┌─────────────┘ └─────────────┐
                         ▼                             ▼
              ┌─────────────────────┐      ┌─────────────────────┐
              │ Rachford-Rice       │      │ Stop with no-root   │
              │ bisection           │      │ diagnostic          │
              └──────────┬──────────┘      └─────────────────────┘
                         │
                         ▼
              ┌────────────────────────────┐
              │ Calculate psi and update   │
              │ extract and raffinate      │
              └────────────┬───────────────┘
                           │
                           ▼
              ┌────────────────────────────┐
              │ Phase compositions         │
              │ converged?                 │
              └────────────┬───────────────┘
                       NO  │  YES
                           │
             ┌─────────────┘ └─────────────────┐
             ▼                                 ▼
   ┌─────────────────────┐          ┌────────────────────────┐
   │ Repeat UNIQUAC and  │          │ Calculate final gamma, │
   │ Rachford-Rice       │          │ K, psi and L_aq/F      │
   └─────────────────────┘          └────────────┬───────────┘
                                                 │
                                                 ▼
                                      ┌────────────────────────┐
                                      │ Save next tieline or   │
                                      │ finish after five      │
                                      └────────────┬───────────┘
                                                   │
                                                   ▼
                                      ┌────────────────────────┐
                                      │           END          │
                                      └────────────────────────┘
```

---

# Expected Results

## Tieline 1

```text
Feed z       = [0.21260227  0.29532878  0.49206895]

Extract      = [0.39610739  0.60094366  0.00294895]

Raffinate    = [0.04868071  0.02232894  0.92899035]

psi          = 0.47181627

L_aq/F       = 0.52818373
```

Approximate activity coefficients:

```text
gamma Extract   = [1.3046  1.1622  318.8]

gamma Raffinate = [10.6029  31.2391  1.0116]
```

## Tieline 2

```text
Extract      = [0.58668783  0.40740451  0.00590767]

Raffinate    = [0.06446157  0.01849618  0.91704225]

psi          = 0.46261896

L_aq/F       = 0.53738104
```

## Tieline 3

```text
Extract      = [0.61846559  0.37501411  0.00652030]

Raffinate    = [0.06716384  0.01767156  0.91516461]

psi          = 0.47137923

L_aq/F       = 0.52862077
```

## Tieline 4

```text
Extract      = [0.62690073  0.36640797  0.00669130]

Raffinate    = [0.06784291  0.01742703  0.91473007]

psi          = 0.48734319

L_aq/F       = 0.51265681
```

## Tieline 5

```text
Extract      = [0.59354292  0.40041994  0.00603714]

Raffinate    = [0.06500497  0.01831235  0.91668268]

psi          = 0.45917660

L_aq/F       = 0.54082340
```

---

# One Handwritten Iteration

```text
Initial extract and raffinate compositions
              ↓
Normalize phase compositions
              ↓
UNIQUAC phi and theta
              ↓
Combinatorial contribution
              ↓
Residual contribution
              ↓
gamma_org and gamma_aq
              ↓
K_i
              ↓
Rachford-Rice equation
              ↓
One bisection step for psi
              ↓
Update extract and raffinate
```

Rachford-Rice bisection step:

```text
psi_mid = (psi_low + psi_high)/2
```

Evaluate `RR(psi_mid)` and select the new interval.

---

# Running Instructions

The shared `.m` file is self-contained and requires no user inputs or intervention. All data and parameters are predefined in the MATLAB script as per the provided problem statement.

---

# Final Checks

For both liquid phases:

```text
sum(x) = 1
```

```text
sum(y) = 1
```

At equilibrium:

```text
x_i gamma_i,org ≈ y_i gamma_i,aq
```

For Rachford-Rice:

```text
RR(psi) ≈ 0
```

and:

```text
0 <= psi <= 1
```

All mole fractions must remain in the physical range:

```text
0 <= x_i <= 1
0 <= y_i <= 1
```

---

# Author

Mridun Gupta (J24IMT624)

IMT.CE, 2024

Process Simulation Laboratory-I