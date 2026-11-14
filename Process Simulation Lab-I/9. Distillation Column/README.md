# Distillation Column Problem

## Objective

To determine the number of theoretical stages anf the feed plate location for the separation of ethanol-water mixture by continous distillation using the McCabe-Thiele method.

---

# Operating Conditions

| Parameter | Value | Unit |
|---|---:|---|
| Feed flow rate, `F` | 100 | kg/h |
| Temperature, `T` | 365 | K |
| Pressure, `P` | 1 | bar |
| Liquid fraction in feed, `q` | 0.60 | - |
| Distillate composition, `xD` | 0.90 | - |
| Bottoms composition, `xB` | 0.10 | - |
| Reflux ratio, `RD` | 2.00 | R/D |
| Feed composition, `xF` | 0.50 | - |

# Antoine Constants

```text
A = 12.2917
B = 3803.98
C = -41.68
```

The code calculates saturation pressure using:

```text
Psat = exp(A - B/(T + C))
```

and uses the equilibrium relation:

```text
y_eq = x*Psat/P
```

---

# Theory

## q-Line / Feed Line

```text
y = m_F*x + c_F

m_F = -q/(1-q)
c_F = xF/(1-q)
```

For the given data points:

```text
m_F = -1.5
c_F = 1.25
```

## Rectifying Line

```text
y = m_R*x + c_R

m_R = RD/(RD+1)
c_R = xD/(RD+1)
```

For `RD = 2`:

```text
m_R = 0.6666667
c_R = 0.3000000
```

## Feed / Rectifying Intersection

Solve the two straight-line equations simultaneously:

```text
m_F*x + c_F = m_R*x + c_R
```

The code calculates the intersection with a 2-by-2 linear system.

## Stripping Line

The stripping line passes through the bottoms operating point and the feed/rectifying intersection:

```text
y = m_B*x + c_B
```

with the bottoms equilibrium point determined from:

```text
y_B,eq = xB*Psat/P
```

## McCabe-Thiele Construction

At each stage, the equilibrium relation is inverted to obtain the liquid composition corresponding to the current vapour composition:

```text
x_eq = y*P/Psat
```

The appropriate operating line is then used to calculate the next vapour composition. The program repeats this staircase construction and records the stage coordinates.

## Number of Stages

The stage count is obtained by repeating the equilibrium/operating-line construction until the specified bottoms composition is reached. A maximum iteration count and a pinch check are included to prevent an endless numerical loop.

---

# Expected Intermediate Results

At `T = 365 K` and `P = 1 bar`:

```text
Psat = 1.69270566 bar
```

Feed/rectifying intersection:

```text
x_F,int = 0.4384615
y_F,int = 0.5923077
```

The corresponding operating-line parameters are approximately:

```text
Feed line:       y = -1.5 x + 1.25
Rectifying line: y =  0.666667 x + 0.30
```

The stripping line generated from the Antoine equilibrium relation is approximately:

```text
y = 1.249882 x + 0.044282
```

---

# Program Flow Chart

```text
                         ┌─────────────────────────────┐
                         │            START            │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │      Enter input data       │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │ Calculate saturation        │
                         │ pressure from Antoine       │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │     Calculate feed line     │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │  Calculate rectifying line  │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │      Find intersection      │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │    Calculate stripping line │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │    McCabe-Thiele stepping   │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │     Determine feed plate    │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │  Determine total theoretical│
                         │           stages            │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │       Display results       │
                         └──────────────┬──────────────┘
                                        │
                                        ▼
                         ┌─────────────────────────────┐
                         │             END             │
                         └─────────────────────────────┘
```

---

# Running Instructions

The shared .m file is self-contained and requires no user inputs or intervention. All data and parameters are predefined in the MATLAB script as per the provided problem statement.

---

# Author

Mridun Gupta (J24IMT624)

IMT.CE, 2024

Process Simulation Laboratory-I