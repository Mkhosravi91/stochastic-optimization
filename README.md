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

In this project, we identify—for each product—the optimal “surplus” quantity S<sub>i</sub> to add to its nominal forecast D<sub>i</sub>, so as to maximize expected profit under demand uncertainty. Rather than sampling absolute demand directly, we sample a variance multiplier from a Burr12 distribution and compute realized demand.


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


1. **Two-Stage Stochastic Formulation**  
   • In the first stage, the decision variable (surplus), represents the surplus quantity added to product i nominal forecast Dᵢ and the the second stage variables are sales/shortages, once demand realizes.  
   • The key constraints are related to capacity, macro-target, and group substitution.  
   • Expected profit is maximized, but because demand is random, we approximate it using scenarios.

2. **Scenario Generation (Monte Carlo on Variance)**  
   • Demand is not sampled directly. Instead, for each product <code>i</code>, a variance factor is drawn from a Burr12 distribution. The realized demand for product <code>i</code> under scenario <code>sc</code> is calculated as:</p>
<pre>
~D<sub>i,sc</sub> = D<sub>i</sub> × demandVar<sub>i,sc</sub>
</pre> 
   • Using the Python notebook <code>KMEANS.ipynb</code>, 10 000 values of <code>~D<sub>i,sc</sub></code> are generated for each product. These values are saved to <code>data/input_demands.xlsx</code> (sheet “All_Scenarios”).</p>

4. **Scenario Reduction**  
   • Explain why 10 000 scenarios in GAMS is too large.  
   • Describe that you feed those 10 000 rows into a K-Means clustering routine (in Python), cluster into \(K \approx 200\) (or whatever number) centroids, and record each centroid plus its weight (proportion of original scenarios).  
   • Note that the output is `gams/reduced_scenarios.xlsx` with columns `[Scenario, D_P1, D_P2, …, D_Pn, Weight]`.

5. **Putting Everything Together**  
   • Summarize the pipeline:  
     1. Run `notebooks/KMEANS.ipynb` → produces `data/input_demands.xlsx` (10 000 draws) and then `gams/reduced_scenarios.xlsx` (K cluster representatives + weights).  
     2. Navigate to the `gams/` folder, run `gams surplus.gms lo=2`.  
     3. `surplus.gms` uses GDXXRW to import `D(i,sc)` and `p(sc)` from `reduced_scenarios.xlsx`, solves the deterministic equivalent SAA, and writes `gams/surplus_output.xlsx`.  
   • Point the reader to “Usage” or “Inspect Results” to see how to open that final Excel.

---
