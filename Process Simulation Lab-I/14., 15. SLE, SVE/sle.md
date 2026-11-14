# Process Simulation Laboratory-I

## Objective

Determine the equilibrium liquid mole fraction of a hypothetical crystalline solute A in a binary A-S liquid solution at 298.15 K, using the UNIQUAC activity-coefficient model and the solid-liquid equilibrium relation.

---

## Problem Data

| Parameter | Symbol | Value | Unit |
|---|---|---:|---|
| System temperature | `T` | 298.15 | K |
| Solute melting temperature | `TmA` | 360.0 | K |
| Enthalpy of fusion of A | `dHfusA` | 18,000 | J/mol |
| Gas constant | `R` | 8.314462618 | J/(mol K) |
| Solute structural parameter | `rA` | 2.50 | dimensionless |
| Solute structural parameter | `qA` | 2.20 | dimensionless |
| Solvent structural parameter | `rS` | 1.40 | dimensionless |
| Solvent structural parameter | `qS` | 1.20 | dimensionless |
| UNIQUAC interaction parameter | `tauAS` | 0.75 | dimensionless |
| UNIQUAC interaction parameter | `tauSA` | 1.35 | dimensionless |

The binary solvent components B and C in the problem statement are represented as a single pseudocomponent S. The interaction matrix is entered directly as `tau_ij`, with row `i` and column `j`.

The problem introduces the UNIQUAC coordination number `z` but does not specify a value. The standard value `z = 10` is assumed in the MATLAB calculation.

---

## Governing Equations

### 1. Solid-liquid equilibrium constant

Neglecting heat-capacity and pressure corrections, the fusion-property relation is:

```text
KSL = exp[-(dHfusA/R)*(1/T - 1/TmA)]
```

Substitution gives:

```text
KSL = exp[-(18000/8.314462618)*(1/298.15 - 1/360.0)]
KSL = 0.2872218268
```

At equilibrium:

```text
xA*gammaA = KSL
```

### 2. UNIQUAC volume and surface fractions

For `x = [xA, xS]`, where `xS = 1 - xA`:

```text
phi_i   = x_i*r_i / sum(x_j*r_j)
theta_i = x_i*q_i / sum(x_j*q_j)
```

### 3. Combinatorial contribution

```text
l_i = (z/2)*(r_i - q_i) - (r_i - 1)
```

```text
ln(gamma_i^C) = ln(phi_i/x_i)
             + (z/2)*q_i*ln(theta_i/phi_i)
             + l_i - (phi_i/x_i)*sum(x_j*l_j)
```

### 4. Residual contribution

```text
S_j = sum_i(theta_i*tau_ij)
term_i = sum_j(theta_j*tau_ij/S_j)
```

```text
ln(gamma_i^R) = q_i*[1 - ln(S_i) - term_i]
ln(gamma_i)   = ln(gamma_i^C) + ln(gamma_i^R)
gamma_i       = exp(ln(gamma_i))
```

### 5. Numerical solution

The equilibrium equation is solved in logarithmic form:

```text
F(xA) = ln(xA) + ln(gammaA) - ln(KSL) = 0
```

The MATLAB function `fzero` finds the root over the physical interval `0 < xA < 1`.

For an ideal liquid, `gammaA = 1`, so the ideal estimate is:

```text
xA_ideal = KSL = 0.2872218268
```

---

## Process Flow Chart

```text
                         START
                           |
                           v
              Enter T, TmA, dHfusA, R, r, q and tau
                           |
                           v
                 Calculate solid-liquid KSL
                           |
                           v
             Assume trial liquid composition xA and xS
                           |
                           v
              Calculate UNIQUAC phi and theta fractions
                           |
                           v
              Calculate combinatorial and residual terms
                           |
                           v
                    Calculate gammaA
                           |
                           v
                   Evaluate F(xA)
                           |
                           v
                 Solve F(xA) = 0 using fzero
                           |
                           v
          Calculate xS, gammaA, ideal estimate and residual
                           |
                           v
                  Display result and plot
                           |
                           v
                           END
```

---

## Expected Results

```text
KSL                         = 0.2872218268
Equilibrium solute fraction = 0.3201696032
Equilibrium solvent fraction= 0.6798303968
UNIQUAC gammaA              = 0.89709274
UNIQUAC gammaS              = 0.96512461
xA*gammaA                   = 0.2872218268
Relative SLE residual       < 1e-7
Ideal-liquid estimate xA    = 0.2872218268
Deviation from ideal estimate = 11.4712 %
```

At the calculated equilibrium composition, the approximate UNIQUAC fractions and contributions are:

```text
phi   = [0.45681437  0.54318563]
theta = [0.46335167  0.53664833]
ln(gammaA^C) = -0.07025723
ln(gammaA^R) = -0.03833880
ln(gammaA)   = -0.10859603
```

---

## Running Instructions

The shared `.m` file is self-contained and requires no user inputs or intervention. All data and parameters are predefined in the MATLAB script as per the provided problem statement.

---

## Final Checks

- `0 < xA < 1` and `0 < xS < 1`.
- `xA + xS = 1`.
- The calculated equilibrium satisfies `xA*gammaA = KSL` within numerical tolerance.
- The relative equilibrium residual should be close to zero.
- The ideal-liquid estimate assumes `gammaA = 1`; it is not the UNIQUAC result.

---

# Author

Mridun Gupta (J24IMT624)

IMT.CE, 2024

Process Simulation Laboratory-I