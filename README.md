# Surplus‐Allocation Stochastic Optimization

A two‐stage stochastic programming model (implemented in GAMS) to determine the optimal surplus quantity for each product’s demand forecast. Demand uncertainty is modeled via Burr12‐based variance multipliers, scenarios are clustered with K-Means, and the resulting Sample Average Approximation (SAA) is solved in GAMS.

---

## Table of Contents
1. [Overview](#overview)   
2. [Prerequisites](#prerequisites)  
3. [Installation & Setup](#installation--setup)  
4. [Methodology / How It Works](#methodology--how-it-works)  
   1. [Two-Stage Stochastic Formulation](#two-stage-stochastic-formulation)  
   2. [Scenario Generation (Monte Carlo on Variance)](#scenario-generation-monte-carlo-on-variance)  
   3. [Scenario Reduction](#scenario-reduction)  
   4. [Putting Everything Together](#putting-everything-together)  
5. [Mathematical Formulation](#mathematical-formulation)  
6. [Usage](#usage)  
 

---

## Overview

In this project, we identify—for each product—the optimal “surplus” quantity \(S_i\) to add to its nominal forecast \(D_i\), so as to maximize expected profit under demand uncertainty. Rather than sampling absolute demand directly, we sample a variance multiplier from a Burr12 distribution and compute realized demand.


We generate 10 000 such scenarios per product, reduce them via K-Means clustering to K ≈ 1000 representative scenarios (with associated weights), and then solve the deterministic-equivalent SAA model in GAMS (`surplus.gms`). The final output is an Excel file containing optimal surplus decisions and scenario-by-scenario recourse metrics.


---


## Prerequisites

- **GAMS 36.1+** installed and on your system PATH.  
- **Python 3.8+** with the following packages (listed in `requirements.txt`):  
  - `pandas`  
  - `numpy`  
  - `scikit-learn`  
  - `scipy`  
  - `openpyxl`  
- **git** for version control.  

> It’s recommended to use a Python virtual environment to isolate dependencies.

---

## Installation & Setup

1. **Clone this repository**  
   ```bash
   git clone https://github.com/YourUsername/my-gams-project.git
   cd my-gams-project
---
## Methodology / How It Works

_Use this heading to explain your overall approach in words before diving into the detailed math._ In other words, here you give a non-technical (or lightly technical) overview:

1. **Two-Stage Stochastic Formulation**  
   • Describe what “first stage” means (choose surplus \(S_i\)), and what “second stage” means (compute sales/shortages once demand realizes).  
   • Explain the key constraints (capacity, macro-target, group substitution).  
   • Mention that expected profit is maximized, but since demand is random, we approximate via scenarios.

2. **Scenario Generation (Monte Carlo on Variance)**  
   • Explain that you don’t sample demand directly— you sample a variance factor from a Burr12 distribution for each product.  
   • Show that realized demand \(\tilde{D}_{i,sc} = D_i \times \text{demandVar}_{i,sc}\).  
   • Say “we draw 10 000 such \(\tilde{D}_{i,sc}\) values per product in `KMEANS.ipynb` and save them to `data/input_demands.xlsx`.”

3. **Scenario Reduction**  
   • Explain why 10 000 scenarios in GAMS is too large.  
   • Describe that you feed those 10 000 rows into a K-Means clustering routine (in Python), cluster into \(K \approx 200\) (or whatever number) centroids, and record each centroid plus its weight (proportion of original scenarios).  
   • Note that the output is `gams/reduced_scenarios.xlsx` with columns `[Scenario, D_P1, D_P2, …, D_Pn, Weight]`.

4. **Putting Everything Together**  
   • Summarize the pipeline:  
     1. Run `notebooks/KMEANS.ipynb` → produces `data/input_demands.xlsx` (10 000 draws) and then `gams/reduced_scenarios.xlsx` (K cluster representatives + weights).  
     2. Navigate to the `gams/` folder, run `gams surplus.gms lo=2`.  
     3. `surplus.gms` uses GDXXRW to import `D(i,sc)` and `p(sc)` from `reduced_scenarios.xlsx`, solves the deterministic equivalent SAA, and writes `gams/surplus_output.xlsx`.  
   • Point the reader to “Usage” or “Inspect Results” to see how to open that final Excel.

---
