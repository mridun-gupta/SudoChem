# Rotary Dryer Design using MATLAB

## Aim

To design an adiabatic rotary dryer using MATLAB by determining the required dryer diameter and length for drying a heat-sensitive solid under the specific operating condition.

---

# Assumptions

- Steady-state operation.
- Drying air behaves as an ideal gas.
- Specific heat capacities remain constant throughout the process.
- Heat losses to the surroundings are neglected.
- Moisture removal occurs at the wet-bulb (evaporation) temperature.
- Thermophysical properties are obtained from standard psychrometric (humidity) charts where required.
- Gas mass velocity remains constant throughout the dryer.
- Overall heat transfer coefficient is assumed constant.

---

# Variables

## Input Variables

| Variable      | Description                            | Unit                  |
|---------------|----------------------------------------|-----------------------|
| cps           | Specific heat of dry solid             | kcal/kg·°F            |
| cpv           | Specific heat of water vapour          | kcal/kg·°F            |
| cpl           | Specific heat of liquid water          | kcal/kg·°F            |
| xa            | Initial moisture content               | kg water/kg dry solid |
| xb            | Final moisture content                 | kg water/kg dry solid |
| tsb           | Final solid temperature                | °F                    |
| tsa           | Initial solid temperature              | °F                    |
| tha           | Outlet hot air temperature             | °F                    |
| thb           | Inlet hot air temperature              | °F                    |
| tw            | Wet-bulb (evaporation) temperature     | °F                    |
| tva           | Water vapour temperature               | °F                    |
| ms            | Dry solid feed rate                    | kg/h                  |
| lambda        | Latent heat of vaporization            | kcal/kg               |
| G             | Gas mass velocity                      | kg/h·ft²              |
| delta_T_bar   | Log Mean Temperature Difference (LMTD) | °F                    |
| Hb            | Inlet air humidity                     | kg water/kg dry air   |
| Cshb          | Humid heat of inlet air                | kcal/kg dry air·°F    |

---

## Output Variables

| Variable      | Description                     | Unit                |
|---------------|---------------------------------|---------------------|
| qt            | Total heat duty                 | kcal/h              |
| Nt            | Number of Transfer Units        | -                   |
| mg            | Dry air flow rate               | kg dry air/h        |
| Ha            | Outlet air humidity             | kg water/kg dry air |
| mv            | Moisture evaporated             | kg/h                |
| D             | Dryer diameter                  | ft                  |
| L             | Dryer length                    | ft                  |
| delta_T_bar   | Log Mean Temperature Difference | °F                  |

---

# Equations Used

## Number of Transfer Units

```text
Nt = ln[(thb − tw)/(tha − tw)]
```

---

## Heat Duty

```text
qt = ms × [ cps(tsb − tsa)
          + xa·cpl(tw − tsa)
          + (xa − xb)λ
          + xb·cpl(tsb − tw)
          + (xa − xb)cpv(tva − tw) ]
```

---

## Dry Air Requirement

```text
mg = qt / [(1 + Hb) × Cshb × (thb − tha)]
```

---

## Moisture Evaporated

```text
mv = ms × (xa − xb)
```

---

## Outlet Air Humidity

```text
Ha = Hb + (mv / mg)
```

---

## Dryer Diameter

```text
D = √[4mg / (πG)]
```

---

## Dryer Length

```text
L = qt / [0.125 × π × D × G^0.67 × delta_T_bar]
```

---

# Calculation Procedure

1. Initialize all process and design parameters.
2. Obtain thermophysical properties and humidity data from standard psychrometric charts.
3. Calculate the Number of Transfer Units (Nt).
4. Verify that **1.5 < Nt < 2.5** for satisfactory dryer operation.
5. Compute total heat duty.
6. Determine dry air flow rate.
7. Calculate moisture evaporated.
8. Compute outlet air humidity.
9. Determine dryer diameter.
10. Determine dryer length.
11. Display all results.
12. Plot and compare design parameters.

---

# Program Flowchart

```text
START
  │
  ▼
Initialize the inputs
  │
  ▼
Calculate Tmf from humidity chart
  │
  ▼
Verify Nt realtion
  │
  ▼
Calculate qt from equation
  │
  ▼
Substitute the value of qt to calculaton mg
  │
  ▼
Calculate the outlet humidity
  │
  ▼
Substitute all the values required to calculate length and diameter
  │
  ▼
END
```

---

# Output

The program computes:

* Total Heat Duty (qt)
* Number of Transfer Units (Nt)
* Dry Air Flow Rate (mg)
* Moisture Evaporated (mv)
* Outlet Air Humidity (Ha)
* Dryer Diameter (D)
* Dryer Length (L)
* Log Mean Temperature Difference (L.M.T.D.)

---

# Running Instructions

The shared .m file is self-contained and requires no user inputs or intervention. All design parameters are predefined in the MATLAB script as per the provided problem statement.

# Author

Mridun Gupta (J24IMT624)

IMT.CE, 2024

Process Simulation Laboratory-I