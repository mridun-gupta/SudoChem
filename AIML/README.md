# 🤖 Digital Computation in Emerging Areas (AI/ML/DA)

> **Program:** *Integrated Masters of Technology in Chemical Technology*
> **Institution:** *Institute of Chemical Technology, Mumbai – Marathwada Campus, Jalna (MarJ, in short)*
> **Semester:** *4*

This folder contains explorations, experiments, and assignments related to **Artificial Intelligence**, **Machine Learning**, and **Data Analytics**. It's a sandbox for implementing algorithms, testing models, and understanding computational approaches to solving complex problems.

---

## 📂 Folder Structure

```
AIML/
├── data/                        # Input/output data files (Excel, CSV, etc.)
├── datasets/                    # Instructor-provided master datasets
├── J24IMT624/                   # End-semester exam submission — MIC90 ML modeling
│   ├── input/                   #   Normalised MIC90 dataset
│   └── output/                  #   Predictions & results (Sheet1 + Workbook runs)
├── internal_exam/               # Internal exam notebook + datasets
├── decision_tree/               # Decision tree demo + kyphosis dataset
├── K_means_clustering/          # K-means clustering demo
├── k_nearest_neighbours/        # k-NN classifier + classified data
├── logistic_regression/         # Logistic regression + titanic dataset
├── NLP_Demo/                    # NLP spam classifier + SMS corpus
├── Recommender/                 # Movie recommender + MovieLens data
├── Support_vector_machines/     # SVM demo
├── *.ipynb                      # Topic notebooks (see below)
└── README.md                    # This file
```

## 📔 Notebooks

Contains Jupyter notebooks (.ipynb) exploring Python fundamentals, data manipulation, machine learning, and computational methods.

**Fundamentals (in order):**
1. `pythonDemo.ipynb` / `Python_demo.ipynb` — Python basics review
2. `pythonAssignment.ipynb` — Python assignment/coursework
3. `numpyDemo.ipynb` / `numpy_demo.ipynb` — NumPy array operations
4. `pandasDemo.ipynb` / `pandas_demo.ipynb` — Pandas data structures
5. `pandas_operations.ipynb` — Advanced pandas operations
6. `importingData.ipynb` / `importing_data.ipynb` — Data import workflows
7. `sum_digits_prime.ipynb` — Practice problem

**Data visualization:**
- `Data_visualization_matplotlib.ipynb` — Matplotlib charts
- `data_visualization_seaborn.ipynb` — Seaborn statistical plots

**Machine learning:**
- `Linear_regression.ipynb` — Linear regression on USA housing
- `logistic_regression/` — Logistic regression (titanic dataset)
- `decision_tree/` — Decision tree classifier (kyphosis)
- `Support_vector_machines/` — SVM classifier
- `k_nearest_neighbours/` — k-NN classifier
- `K_means_clustering/` — K-means clustering
- `NLP_Demo/` — SMS spam detection (NLP)
- `Recommender/` — Movie recommendation system

## 📊 Data

- `data/` — early-semester input/output workfiles (`input.xlsx`, `output_1.xlsx`, `output_2.xlsx`)
- `datasets/` — instructor-provided master datasets (kyphosis, titanic, SMS spam, MovieLens, USA housing, tip)
- Topic subfolders carry the dataset each demo uses; loose files at root (`datafile.xlsx`, `tip.csv`, `USA_Housing.csv`, `ouput_excel*.xlsx`) support their sibling notebooks.

## 🎓 `J24IMT624/`

End-semester exam submission — **MIC90 ML modeling**: two notebook variants (`Sheet1`, `Workbook`) predicting MIC90 from a normalised dataset, with `input/` and `output/` artifacts kept for reproducibility.

---

> Part of [**SudoChem**](https://github.com/mridun-gupta/SudoChem) — Experimental Code Lab for Chemical Engineering

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

*“Data whispers secrets. Algorithms amplify them. Machine learning is learning to listen.”*

— *Mridun Gupta (@mridun-gupta)*