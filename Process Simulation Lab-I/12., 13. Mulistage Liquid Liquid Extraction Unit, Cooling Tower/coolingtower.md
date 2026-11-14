# Process Simulation Laboratory-I

## Objective

Determine the required packing height of a countercurrent water-cooling tower using the air-water equilibrium enthalpy data, the operating line, the height of a transfer unit (HTU), and the number of transfer units (NTU).

---

## Problem Data

### Flow rates and water temperatures

| Parameter | Symbol | Value | Unit |
|---|---|---:|---|
| Gas mass velocity | `G` | 1.356 | kg dry air/(s m²) |
| Liquid mass velocity | `L` | 1.356 | kg water/(s m²) |
| Cold-water temperature | `T1` | 29.4 | °C |
| Hot-water temperature | `T2` | 43.3 | °C |
| Entering-air dry-bulb temperature | `TG1` | 29.4 | °C |
| Entering-air wet-bulb temperature | `Twb1` | 23.9 | °C |
| Entering-air humidity ratio | `H1` | 0.0165 | kg water/kg dry air |

### Transfer and physical properties

| Parameter | Symbol | Value | Unit |
|---|---|---:|---|
| Gas-side mass-transfer coefficient | `kGa` | 1.207 × 10⁻⁷ | kgmol/(s m³ Pa) |
| Total pressure | `P_total` | 1.013 × 10⁵ | Pa |
| Molecular weight of dry air | `MB` | 29 | kg/kgmol |
| Heat capacity of water | `cL` | 4.187 × 10³ | J/(kg K) |
| Given coefficient ratio | `hLa_over_kGaMBP` | 4.187 × 10⁴ | J/(kg K) |

The input-air humidity ratio is taken from the psychrometric chart for the stated entering-air dry-bulb and wet-bulb temperatures.

### Saturated air-water equilibrium data

| Liquid temperature, `T_liq` (°C) | Enthalpy, `Hy` (J/kg dry air) |
|---:|---:|
| 15.6 | 43.68 × 10³ |
| 26.7 | 84.0 × 10³ |
| 29.4 | 97.2 × 10³ |
| 32.2 | 112.1 × 10³ |
| 35.0 | 128.9 × 10³ |
| 37.8 | 148.2 × 10³ |
| 40.6 | 172.1 × 10³ |
| 43.3 | 197.2 × 10³ |
| 46.1 | 224.5 × 10³ |
| 60.0 | 461.5 × 10³ |

---

## Governing Equations

### 1. Equilibrium enthalpy relation

The script converts the equilibrium-table temperatures to Kelvin and fits:

```matlab
P_eq = polyfit(T, Hy, 2);
a2 = P_eq(1);
a1 = P_eq(2);
a0 = P_eq(3);
```

The fitted relationship is:

```matlab
Hy = a2*T^2 + a1*T + a0;
```

where `T` is in Kelvin and `Hy` is in J/kg dry air. The coefficient order matters because MATLAB returns polynomial coefficients from highest to lowest order.

### 2. Entering-air enthalpy

The moist-air enthalpy relation used in the code is:

```matlab
Hy = (1.005 + 1.88*H)*(1000*T) + 2.501e6*H;
```

where `T` is in °C, `H` is the humidity ratio in kg water/kg dry air, and `Hy` is in J/kg dry air.

Using `H1 = 0.0165` and `T1 = 29.4 °C`:

```matlab
Hy1 = (1.005 + 1.88*0.0165)*(1000*29.4) ...
      + 2.501e6*0.0165;
```

```matlab
Hy1 = 71.7255e3; % J/kg dry air
```

### 3. Overall heat balance

```matlab
G*(Hy2 - Hy1) = L*cL*(T2 - T1);
```

Rearranging:

```matlab
Hy2 = Hy1 + (L/G)*cL*(T2 - T1);
```

Substitution gives approximately:

```matlab
Hy2 = 129.9248e3; % J/kg dry air
```

### 4. Operating line

The operating line is fitted through the two endpoint values using a first-order polynomial:

```matlab
P1 = polyfit([TL1 TL2], [Hy1 Hy2], 1);
intercept = P1(2);
slope = P1(1);
```

The linear relation is:

```matlab
Hy = intercept + slope*T;
```

where `TL1` and `TL2` are in Kelvin so they use the same temperature basis as the equilibrium fit.

### 5. Height of a transfer unit (HTU)

```matlab
HTU = G/(MB*kGa*P_total);
```

Substituting the supplied values:

```matlab
HTU = 1.356/(29*1.207e-7*1.013e5);
```

```matlab
HTU = 3.82424; % m
```

### 6. Number of transfer units (NTU)

The supplied graphical staircase readings are used as pairs of bulk-gas enthalpy `Hy` and corresponding interface/equilibrium enthalpy `Hyi`:

| `Hy` (J/kg dry air) | `Hyi` (J/kg dry air) | `Hyi - Hy` (J/kg dry air) | `1/(Hyi-Hy)` |
|---:|---:|---:|---:|
| 71.7 × 10³ | 94.4 × 10³ | 22.7 × 10³ | 4.41 × 10⁻⁵ |
| 83.5 × 10³ | 108.4 × 10³ | 24.9 × 10³ | 4.02 × 10⁻⁵ |
| 94.9 × 10³ | 124.4 × 10³ | 29.5 × 10³ | 3.39 × 10⁻⁵ |
| 106.5 × 10³ | 141.8 × 10³ | 35.3 × 10³ | 2.83 × 10⁻⁵ |
| 118.4 × 10³ | 162.1 × 10³ | 43.7 × 10³ | 2.29 × 10⁻⁵ |
| 129.9 × 10³ | 184.7 × 10³ | 54.8 × 10³ | 1.85 × 10⁻⁵ |

The program calculates the reciprocal driving force and integrates it using the trapezoidal rule:

```matlab
driving_force = Hyi_stair - Hy_stair;
dN_dHy = 1./driving_force;
NTU = trapz(Hy_stair, dN_dHy);
```

This numerically evaluates the area under the `1/(Hyi-Hy)` versus `Hy` curve:

```matlab
NTU = integral(dHy/(Hyi - Hy));
```

```matlab
NTU = 1.82113;
```

### 7. Required packing height

```matlab
Z = HTU*NTU;
```

Therefore:

```matlab
Z = 3.82424*1.82113; % m
```

The calculation gives approximately **6.96 m** using the tabulated rounded staircase values. The conventional textbook result based on graphical readings is approximately **6.98 m**.

---

## Process Flow Chart

```text
                         START
                           |
                           v
              Enter equilibrium T_liq and Hy data
                           |
                           v
                 Convert T_liq from °C to K
                           |
                           v
                Fit equilibrium relation with polyfit
                           |
                           v
                 Calculate entering-air enthalpy Hy1
                           |
                           v
                Apply overall heat balance to find Hy2
                           |
                           v
                   Fit the operating line
                           |
                           v
                      Calculate HTU
                           |
                           v
               Enter graphical staircase values Hy,Hyi
                           |
                           v
             Calculate the enthalpy driving force Hyi-Hy
                           |
                           v
          Integrate reciprocal driving force to determine NTU
                           |
                           v
                     Calculate Z = HTU*NTU
                           |
                           v
                 Display results and plot diagram
                           |
                           v
                           END
```

---

## Expected Results

```matlab
Hy1 = 71725.488;  % J/kg dry air
Hy2 = 129924.788; % J/kg dry air
HTU = 3.824239;   % m
NTU = 1.821129;
Z   = 6.964430;   % m
```

The expected reported packing height is approximately `6.96 m`, commonly rounded to `6.98 m` when the graphical staircase readings are used with their original precision.

---

# Running Instructions

The shared `.m` file is self-contained and requires no user inputs or intervention. All data and parameters are predefined in the MATLAB script as per the provided problem statement.

---

## Final Checks

- `Hy1` and `Hy2` must be finite enthalpy values.
- Every driving force `Hyi-Hy` must be positive.
- HTU and NTU must be positive.
- The calculated packing height must satisfy `Z = HTU*NTU`.
- Temperatures used in the equilibrium polynomial and operating line are both in Kelvin; enthalpy calculations using the moist-air equation use degree Celsius as specified in the equation.

---

# Author

Mridun Gupta (J24IMT624)

IMT.CE, 2024

Process Simulation Laboratory-I