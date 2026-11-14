# Process Simulation Laboratory-I

---

## Objective

Determine the number of theoretical stages required to reduce the nicotine mass fraction in the water-rich phase from `0.0100` to `0.0010` during countercurrent extraction using kerosene.

---

## Problem Data

| Parameter | Symbol | Value | Unit |
|---|---|---:|---|
| Water-solution flow rate | `L_0` | 100 | kg/h |
| Kerosene-solution flow rate | `V_n` | 200 | kg/h |
| Nicotine fraction in entering water | `x_0` | 0.0100 | mass fraction |
| Nicotine fraction in entering kerosene | `y_n1` | 0.0005 | mass fraction |
| Required nicotine fraction in exiting water | `x_n` | 0.0010 | mass fraction |

### Equilibrium data

| `x` | `y` |
|---:|---:|
| 0.0001010 | 0.000806 |
| 0.0024600 | 0.001959 |
| 0.0050000 | 0.004540 |
| 0.0074600 | 0.006820 |
| 0.0098800 | 0.009040 |
| 0.0202000 | 0.018500 |

Here, `x` is the nicotine mass fraction in the water-rich phase and `y` is the nicotine mass fraction in the kerosene-rich phase.

---

## Governing Equations

### 1. Equilibrium-line fit

The experimental equilibrium data are fitted by a second-order polynomial:

```matlab
PF = polyfit(x, y, 2);
A2 = PF(1);
A1 = PF(2);
A0 = PF(3);
```

The fitted form is:

```matlab
y = A2*x^2 + A1*x + A0;
```

For the provided data, the approximate coefficients are:

```text
A2 = 3.81364661
A1 = 0.82121939
A0 = 0.000394683819
```

### 2. Solute-free carrier flow rates

```matlab
L_prime = L_0*(1 - x_0);
V_prime = V_n*(1 - y_n1);
```

Thus:

```text
L' = 99.0000 kg/h
V' = 199.9000 kg/h
```

### 3. Solute-free concentrations

```matlab
X = x./(1 - x);
Y = y./(1 - y);
```

The known concentrations are:

```matlab
X_0 = x_0/(1 - x_0);
X_n = x_n/(1 - x_n);
Y_n1 = y_n1/(1 - y_n1);
```

### 4. Overall solute balance

```matlab
L_prime*(X_0 - X_n) = V_prime*(Y_1 - Y_n1);
```

Rearranging:

```matlab
Y_1 = Y_n1 + (L_prime/V_prime)*(X_0 - X_n);
```

Convert the solute-free concentration back to a mass fraction:

```matlab
y_1 = Y_1/(1 + Y_1);
```

For the supplied data, `y_1` is approximately `0.00498206`.

### 5. Operating line

The operating line joins the points `(x_n, y_n1)` and `(x_0, y_1)`. Its coefficients are obtained using:

```matlab
OL_1 = [x_n x_0];
OL_2 = [y_n1 y_1];
PF_1 = polyfit(OL_1, OL_2, 1);
B1 = PF_1(1);
B0 = PF_1(2);
```

Therefore:

```matlab
y = B1*x + B0;
```

Approximate values are:

```text
B1 = 0.49800698
B0 = 1.99302441e-6
```

### 6. Stage stepping

The MATLAB stage calculation preserves the expression and calculation sequence shown in the instructor's classroom reference code:

```matlab
x_new = A2*(y_current^2) + A1*y_current + A0;
y_new = B1*x_new + B0;
```

If `y_new` is greater than `y_n1`, the program updates `y_current` and calculates the next stage. The process stops once:

```matlab
y_new <= y_n1
```

---

## Process Flow Chart

```text
                         START
                           |
                           v
              Enter flow rates and compositions
                           |
                           v
                 Enter equilibrium x-y data
                           |
                           v
               Fit equilibrium line: polyfit
                           |
                           v
           Calculate solute-free flow rates L' and V'
                           |
                           v
          Apply overall balance to calculate Y1 and y1
                           |
                           v
                 Fit the operating line
                           |
                           v
                  Initialize stage counter
                           |
                           v
               Calculate x_new from current y
                           |
                           v
                 Calculate y_new on line
                           |
                           v
                   Is y_new <= y_n1?
                    /             \
                  Yes              No
                   |                |
                   v                v
             Stop stepping     Update y_current,
                               increment stage
                                    |
                                    +------ repeat
                   |
                   v
         Display stage count and plot lines
                   |
                   v
                  END
```

---

## Expected Results

```text
Solute-free water flow, L'       = 99.000000 kg/h
Solute-free kerosene flow, V'    = 199.900000 kg/h
Top extract composition, y_1     ≈ 0.00498206
Operating-line slope, B1         ≈ 0.49800698
Operating-line intercept, B0     ≈ 1.9930e-6
Number_of_Stages                 = 4 theoretical stages
```

### Stage calculations

| Stage | `y(current)` | `x(new)` | `y(new)` |
|---:|---:|---:|---:|
| 1 | 0.00498206 | 0.00458071 | 0.00228322 |
| 2 | 0.00228322 | 0.00228959 | 0.00114222 |
| 3 | 0.00114222 | 0.00133768 | 0.00066816 |
| 4 | 0.00066816 | 0.00094510 | 0.00047266 |

Since the fourth calculated `y(new)` is lower than or equal to `y_n1 = 0.0005`, the program stops at four theoretical stages.

---

# Running Instructions

The shared `.m` file is self-contained and requires no user inputs or intervention. All data and parameters are predefined in the MATLAB script as per the provided problem statement.

---

## Final Checks

- The calculated solute-free flow rates should be positive.
- All input mass fractions must lie between 0 and 1.
- The overall material-balance calculation must return a finite `y_1`.
- The stage loop must terminate at the specified exit-composition threshold.

---

# Author

Mridun Gupta (J24IMT624)

IMT.CE, 2024

Process Simulation Laboratory-I