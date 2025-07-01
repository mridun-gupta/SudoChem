## 📁 About This Folder

This section of the `SudoChem` repository archives **all graded assignment Jupyter notebooks** — built during *Semester 2* under the *Engineering Applications of Digital Computers* course of the**Integrated Masters of Technology in Chemical Technology** program at **Institute of Chemical Technology, Mumbai – Marathwada Campus, Jalna (MarJ, in short)**.

These aren’t just submissions. They’re **numerical explorations**, **ODE/PDE experiments**, and **Excel-powered insights** — built with Python, logic, and just enough caffeine.

> 📌 For non-assignment practice notebooks, check the [`notebooks/`](../notebooks/) folder.

---

## 📑 Assignments Overview

### `Assignment 1: Python Foundations`

- 🧾 **Topics:** Loops, conditionals, plotting, lists, string operations
- ⚙️ **Highlights:**
  - Traffic light simulator
  - Number guessing game
  - Grocery billing system with discounts
  - Basic plotting and vowel counting
- 🛠️ **Tools:** `matplotlib`, `random`
- ✅ **Skills Gained:** Input/output handling, control structures, basic data visualization

---

### `Assignment 2: ODE Solvers (Runge-Kutta)`

- 🧾 **Topics:** RK2 (Heun & Midpoint), Classical RK4, Custom RK4
- ⚙️ **Problems Solved:** Differential equations like
  - `dy/dx = x² + y`, `dy/dx = (y + cos(x))/(x + 1)`
- 📊 **Outputs:** Tables of `x, y, k1, k2…` and solution plots
- 🛠️ **Tools:** `numpy`, `matplotlib`
- ✅ **Skills Gained:** Precision control, iterative thinking, RK method trade-offs

---

### `Assignment 3: Wave Equation (FDM)`

- 🧾 **Topics:** Explicit finite difference for ∂²u/∂t² = 16∂²u/∂x²
- ⚙️ **Setup:**
  - Initial: `u(x,0) = cos(x)`, ∂u/∂t = 0
  - Boundary: `u(0,t) = u(2π,t) = 0`
- 📊 **Outputs:** Tabulated `u(x,t)` values at discrete points
- 🛠️ **Tools:** `numpy`, `pandas`
- ✅ **Skills Gained:** Discretization, PDE solvers, tabular data management

---

### `Assignment 4: Heat Equation (Crank-Nicolson)`

- 🧾 **Topics:** Implicit PDE solving via Crank-Nicolson
- ⚙️ **Equation:** `∂u/∂t = ∂²u/∂x²`
  - IC: `u(x,0) = 100x(1-x)`
  - BC: `u(0,t) = u(1,t) = 0`
- 📊 **Outputs:**
  - Tabulated `u` values
  - 2D and 3D plots (`u` vs. `x,t`)
- 🛠️ **Tools:** `numpy`, `matplotlib`, `pandas`
- ✅ **Skills Gained:** Stability-focused PDE solving, 3D plotting, matrix systems

---

### `Assignment 5: Advanced Methods & Visualization`

- 🧾 **Topics:**
  - Factorial computation (looping techniques)
  - Newton-Raphson (Van der Waals equation)
  - RK4 for nonlinear ODE
  - Animated 3D surface plots
- 📊 **Outputs:** Tables, plots, and rotating surface animations
- 🛠️ **Tools:** `tabulate`, `numpy`, `matplotlib`
- ✅ **Skills Gained:** Scientific computing, equation modeling, dynamic plotting

---

## `Excel Assignments`

### 🧾 Sheet: 14-05-2025
- **Grading System:** Weighted scores from assignments & exams
- **BMI Calculator:** Computes BMI for 10 entries
- **Fibonacci Series:** Generates 1500 terms to analyze golden ratio behavior

### 🧾 Sheet: 02-06-2025
- **Temperature-Time Table:** Records time vs. temperature rise
- **Suggestions:** Plot trendline and visualize the rise

- 📈 **Tools:** Microsoft Excel
- ✅ **Skills Gained:** Data structuring, formula application, basic visualization

---

## ⚙️ Technical Notes

- 🐍 **Python:** Most notebooks run on `Python 3.13.2`, with one on `3.11.3`
- 📦 **Libraries:**
  - `numpy`, `pandas`, `matplotlib`, `tabulate`, `random`
- 📄 **Excel:** Uses formulas like `SUM`, `AVERAGE`, BMI calculations, and dynamic cell referencing
- 🔁 **Versioning:** Assignment files are stable; updates are logged in future commits

---

## 🎓 Academic Reflection

These assignments reflect a hands-on journey through:

- 🧮 Numerical methods and their engineering relevance
- 🧑‍💻 Core Python programming
- 📊 Excel for real-world data crunching
- 📈 Visualization that makes math visible

> This isn’t just coursework. It’s a coded chronicle of problem-solving, debugging, and growing one loop at a time.

---

## 📝 License & Attribution (Read `NOTICE` for More Details)

This repository is licensed under the **GNU General Public License v3.0 (GPLv3)** and contains code authored and maintained by **Mridun Gupta**.

You are free to:
- ✅ Use, modify, and distribute the code
- ✅ Remix it for academic, personal, or research purposes

As long as you:
- 🔁 License any derivative works under **GPLv3** (keep it open-source)
- 🧾 Give **proper attribution** to the original author
- 📄 Include the original **LICENSE** file in any distribution

```
(C) 2025 Mridun Gupta
 * Email: gmridun@gmail.com
 * LinkedIn: https://www.linkedin.com/in/mridungupta
 * GitHub: https://github.com/mridun-gupta
```

> See [LICENSE](../LICENSE) and [NOTICE](../NOTICE) for full terms.

---

*“When equations start making sense in code — you’re finally engineering in two languages.”*

— *Mridun Gupta (@mridun-gupta)*
