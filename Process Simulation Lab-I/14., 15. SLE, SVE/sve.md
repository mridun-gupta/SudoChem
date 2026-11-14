# Process Simulation Laboratory-I

## Objective

Estimate the equilibrium vapor pressure of a hypothetical subliming compound A at 350 K by equating the vapor fugacity calculated using the Peng-Robinson equation of state to the solid fugacity with a Poynting correction. Compare the result with the ideal-vapor estimate `P = Psub` and quantify the effect of vapor nonideality.

---

## Problem Data

| Parameter | Symbol | Value | Unit |
|---|---|---:|---|
| System temperature | `T` | 350 | K |
| Critical temperature | `Tc` | 508.1 | K |
| Critical pressure | `Pc` | 4.60 × 10⁶ | Pa |
| Acentric factor | `omega` | 0.307 | dimensionless |
| Solid molar volume | `Vs` | 4.00 × 10⁻⁵ | m³/mol |
| Gas constant | `R` | 8.314462618 | J/(mol K) |
| Pressure search interval | `P` | 0.1 to 500 | kPa |

The sublimation pressure correlation supplied in the problem is:

```text
ln(Psub/bar) = 12.00 - 4500/T
```

---

## Governing Equations

### 1. Sublimation pressure

```matlab
Psub_bar = exp(12.00 - 4500.0/T);
Psub = Psub_bar*1.0e5;
```

At `T = 350 K`:

```text
Psub = 0.4243728457 bar
Psub = 42.43728457 kPa
```

### 2. Peng-Robinson parameters

```matlab
a = 0.45724*R^2*Tc^2/Pc;
b = 0.07780*R*Tc/Pc;
kappa = 0.37464 + 1.54226*omega - 0.26992*omega^2;
alpha = (1 + kappa*(1 - sqrt(T/Tc)))^2;
aT = a*alpha;
```

The dimensionless parameters at pressure `P` are:

```text
A = aT*P/(R^2*T^2)
B = b*P/(R*T)
```

The compressibility factor satisfies:

```text
Z^3 -(1-B)Z^2 +(A-3B^2-2B)Z -(A*B-B^2-B^3) = 0
```

The vapor root is the largest real root of this cubic.

### 3. Vapor fugacity coefficient

The Peng-Robinson vapor fugacity coefficient is calculated from:

```text
ln(phi_v) = Z - 1 - ln(Z-B)
            - A/[2*sqrt(2)*B]
              * ln[(Z+(1+sqrt(2))*B)/(Z+(1-sqrt(2))*B)]
```

The vapor fugacity is:

```text
f_v = phi_v*P
```

### 4. Solid fugacity and Poynting correction

```text
f_s = Psub*exp[Vs*(P-Psub)/(R*T)]
```

The exponential term is the Poynting correction for the pressure difference between `P` and the reference sublimation pressure `Psub`.

### 5. Equilibrium pressure

At solid-vapor equilibrium:

```text
f_v = f_s
```

The program solves the logarithmic residual:

```text
F(P) = ln(f_v/f_s) = 0
```

If the initial endpoints do not bracket a root, the code scans a logarithmic pressure grid over the specified interval of 0.1 to 500 kPa and then solves over a sign-changing interval.

### 6. Ideal-vapor comparison

For the ideal-vapor approximation, `phi_v = 1` and the small solid pressure correction is neglected, giving:

```text
P_ideal = Psub
```

The percentage pressure difference is calculated as:

```text
100*(P_eq - Psub)/Psub
```

---

## Process Flow Chart

```text
                         START
                           |
                           v
                  Enter T, Tc, Pc, omega, Vs and R
                           |
                           v
                  Calculate sublimation pressure Psub
                           |
                           v
                Calculate Peng-Robinson parameters
                           |
                           v
                     Select trial pressure P
                           |
                           v
              Calculate A and B and solve the PR cubic
                           |
                           v
               Select the largest real root for Z
                           |
                           v
                 Calculate vapor fugacity coefficient
                           |
                           v
             Calculate vapor fugacity fv and solid fugacity fs
                           |
                           v
                  Evaluate ln(fv/fs)
                           |
                           v
                 Find pressure where residual is zero
                           |
                           v
             Compare equilibrium pressure with Psub and report
                           |
                           v
                           END
```

---

## Expected Results

```text
Sublimation pressure, Psub       = 42.43728457 kPa
Equilibrium pressure, P_eq       = 42.89260555 kPa
Vapor compressibility factor, Z  = 0.9892894563
Vapor fugacity coefficient, phi  = 0.9893908198
Vapor fugacity, f_v              = 42437.55017 Pa
Solid fugacity, f_s              = 42437.55017 Pa
Poynting correction factor       = 1.0000062586
ln(f_v/f_s) residual             approximately 0
P_eq - Psub                      = 0.45532098 kPa
Relative pressure difference     = 1.07292676 %
```

The equilibrium pressure is approximately `42.89 kPa`, which is about `1.07%` greater than the ideal-vapor reference pressure. The vapor fugacity coefficient is below unity, indicating a modest vapor-phase nonideality under the specified model. The Poynting correction is very close to unity for these data.

---

## Running Instructions

The shared `.m` file is self-contained and requires no user inputs or intervention. All data and parameters are predefined in the MATLAB script as per the provided problem statement.

---

## Final Checks

- The calculated pressure is within the specified interval of 0.1 to 500 kPa.
- The selected compressibility root is the largest real Peng-Robinson root.
- The vapor fugacity coefficient is positive and finite.
- `f_v` and `f_s` agree at the calculated equilibrium pressure.
- `ln(f_v/f_s)` is close to zero.
- The reported percentage difference is referenced to `Psub`.

---

# Author

Mridun Gupta (J24IMT624)

IMT.CE, 2024

Process Simulation Laboratory-I