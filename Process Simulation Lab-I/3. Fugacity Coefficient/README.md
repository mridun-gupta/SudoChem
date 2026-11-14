# Peng-Robinson Equation of State

## Objective

To estimate the fugacity coefficient and fugacity of an equimolar methane-ethane gas mixture using the Peng-Robinson Equation of State (PR EOS).

Operating Conditions

Temperature : 345 K

Pressure : 1 bar

Composition

Methane : 0.5

Ethane : 0.5

---

## Theory

The Peng-Robinson Equation of State is

P = RT/(V-b) - a/[V(V+b)+b(V-b)]

where

a = 0.45724 (R²Tc²/Pc) α

b = 0.07780 (RTc/Pc)

α = [1+m(1-√Tr)]²

m = 0.37464 + 1.54226ω − 0.26992ω²

For mixtures, classical van der Waals mixing rules are used

am = ΣΣ yi yj √(ai aj)(1-kij)

bm = Σ yi bi

For this project

Binary interaction parameter

kij = 0

---

## Expected Results

Since the pressure is only 1 bar,

The gas behaves almost ideally.

Expected values

Compressibility factor (Z)
approximately 1.000

Fugacity coefficient of methane
approximately 0.999 to 1.001

Fugacity coefficient of ethane
approximately 0.995 to 1.005

Fugacity of methane
approximately 0.5 bar

Fugacity of ethane
approximately 0.5 bar

Small deviations are acceptable.

---

## Methodology

The program follows the following procedure:

1. Define system conditions and gas composition.
2. Define critical properties and acentric factors of methane and ethane.
3. Calculate reduced temperature.
4. Calculate the Peng-Robinson `m` parameter.
5. Calculate the temperature-dependent `alpha` parameter.
6. Calculate pure-component PR EOS parameters `aᵢ` and `bᵢ`.
7. Apply the van der Waals one-fluid mixing rules.
8. Calculate mixture parameters `aₘ` and `bₘ`.
9. Calculate dimensionless PR EOS parameters `A` and `B`.
10. Solve the cubic PR EOS for the compressibility factor `Z`.
11. Select the largest real root as the vapor-phase root.
12. Calculate the fugacity coefficient of each component.
13. Calculate the partial fugacity of methane and ethane.
14. Display the results in a MATLAB table.

---

## Input Variables

### System Inputs

| Variable | Description              |      Value | Unit          |
| -------- | ------------------------ | ---------: | ------------- |
| `R`      | Universal gas constant   | 0.08314472 | bar·L/(mol·K) |
| `T`      | System temperature       |        345 | K             |
| `P`      | System pressure          |          1 | bar           |
| `y`      | Gas-phase mole fractions |  [0.5 0.5] | mol/mol       |

### Component Properties

The component order used throughout the program is:

```text
1 → Methane
2 → Ethane
```

| Variable | Description          | Methane | Ethane | Unit |
| -------- | -------------------- | ------: | -----: | ---- |
| `Tc`     | Critical temperature |  190.56 | 305.32 | K    |
| `Pc`     | Critical pressure    |   45.99 |  48.72 | bar  |
| `omega`  | Acentric factor      |   0.011 |  0.099 | -    |

### Binary Interaction Parameter

```matlab
kij = zeros(n);
```

The binary interaction parameter is assumed to be `kij = 0` for all component pairs.

---

## Derived / Intermediate Variables

The following variables are calculated during the program.

| Variable        | Description                                           |
| --------------- | ----------------------------------------------------- |
| `n`             | Number of components                                  |
| `Tr`            | Reduced temperature of each component                 |
| `m`             | Soave/Peng-Robinson parameter                         |
| `alpha`         | Temperature correction factor                         |
| `a`             | Pure-component attraction parameter                   |
| `b`             | Pure-component co-volume parameter                    |
| `am`            | Mixture attraction parameter                          |
| `bm`            | Mixture co-volume parameter                           |
| `A`             | Dimensionless mixture attraction parameter            |
| `B`             | Dimensionless mixture co-volume parameter             |
| `coeff`         | Coefficients of the cubic PR EOS                      |
| `Zroots`        | All roots of the cubic equation                       |
| `Zreal`         | Real roots of the cubic equation                      |
| `Z`             | Vapor-phase compressibility factor                    |
| `sumTerm`       | Component interaction summation term                  |
| `term1`–`term5` | Individual terms in the fugacity coefficient equation |
| `lnphi`         | Natural logarithm of fugacity coefficient             |
| `phi`           | Fugacity coefficient                                  |
| `f`             | Partial fugacity                                      |

---

# Output Variables

The program displays the following results.

| Output                | Description                     | Unit          |
| --------------------- | ------------------------------- | ------------- |
| `T`                   | System temperature              | K             |
| `P`                   | System pressure                 | bar           |
| `Z`                   | Compressibility factor          | Dimensionless |
| `MoleFraction`        | Mole fraction of each component | mol/mol       |
| `FugacityCoefficient` | Fugacity coefficient, `φᵢ`      | Dimensionless |
| `Fugacity_bar`        | Partial fugacity, `fᵢ`          | bar           |

The final MATLAB table has the form:

```text
Component    MoleFraction    FugacityCoefficient    Fugacity_bar
_________    ____________    ___________________    ____________

Methane          0.5                 φ₁                  f₁
Ethane           0.5                 φ₂                  f₂
```

---

# Program Flow Chart

```text
                         ┌───────────────┐
                         │     START     │
                         └───────┬───────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │ Clear MATLAB workspace │
                    │ and set output format  │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ Enter system conditions│
                    │ T, P, y and R          │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ Enter pure-component   │
                    │ Tc, Pc and omega       │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ Calculate Tr, m, alpha │
                    │ a and b for each       │
                    │ component              │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ Set binary interaction │
                    │ parameter kij = 0      │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ Apply mixing rules     │
                    │ Calculate am and bm    │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ Calculate dimensionless│
                    │ parameters A and B     │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ Form cubic PR EOS      │
                    │ and solve for Z roots  │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ Select real roots      │
                    │ and choose largest Z   │
                    │ as vapor root          │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ Calculate φᵢ for each │
                    │ component              │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ Calculate fugacity     │
                    │ fᵢ = φᵢ yᵢ P          │
                    └───────────┬────────────┘
                                │
                                ▼
                    ┌────────────────────────┐
                    │ Display Z, φᵢ and fᵢ  │
                    └───────────┬────────────┘
                                │
                                ▼
                         ┌───────────────┐
                         │      END      │
                         └───────────────┘
```

---

# Running Instructions

The shared .m file is self-contained and requires no user inputs or intervention. All parameters are predefined in the MATLAB script as per the provided problem statement.

---

# Assumptions

The following assumptions are used:

1. The mixture is in the **vapor phase**.

2. The gas mixture is at **equilibrium**.

3. The **Peng-Robinson EOS** adequately represents the real-gas behavior.

4. The binary interaction parameter is assumed to be:

   [
   k_{ij}=0
   ]

5. The mixture follows the conventional **van der Waals one-fluid mixing rules**.

6. The largest real root of the cubic PR EOS is selected as the vapor-phase compressibility factor.

7. Critical properties and acentric factors are treated as constant input properties.

8. Pressure is expressed in bar and the gas constant is therefore:

   [
   R=0.08314472 {bar·L/(mol·K)}
   ]

---

# Key Equations Summary

| Quantity             | Equation                                           |
| -------------------- | -------------------------------------------------- |
| Reduced temperature  | (T_r=T/T_c)                                        |
| PR `m` parameter     | (m=0.37464+1.54226\omega-0.26992\omega^2)          |
| Alpha                | (\alpha=[1+m(1-\sqrt{T_r})]^2)                     |
| Attraction parameter | (a=0.45724R^2T_c^2\alpha/P_c)                      |
| Co-volume parameter  | (b=0.07780RT_c/P_c)                                |
| Mixture attraction   | (a_m=\sum_i\sum_j y_i y_j\sqrt{a_i a_j}(1-k_{ij})) |
| Mixture co-volume    | (b_m=\sum_i y_i b_i)                               |
| Dimensionless `A`    | (A=a_mP/(R^2T^2))                                  |
| Dimensionless `B`    | (B=b_mP/(RT))                                      |
| Fugacity             | (f_i=\phi_i y_iP)                                  |

---

# Author

Mridun Gupta (J24IMT624)

IMT.CE, 2024

Process Simulation Laboratory-I