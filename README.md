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

1. **Clone the repo into a folder of your choice (e.g. “stoch-opt”):**
```bash
git clone https://github.com/Mkhosravi91/stochastic-optimization.git stoch-opt
cd stoch-opt/gams
gams surplus.gms lo=2  
```
---
## Methodology / How It Works


### **Two-Stage Stochastic Formulation**  
   • In the first stage, the decision variable (surplus), represents the surplus quantity added to product i nominal forecast Dᵢ and the the second stage variables are sales/shortages, once demand realizes.  
   • The key constraints are related to capacity, macro-target, and group substitution.  
   • Expected profit is maximized, but because demand is random, we approximate it using scenarios.

### **Scenario Generation (Monte Carlo on Variance)**  
   • Demand is not sampled directly. Instead, for each product <code>i</code>, a variance factor is drawn from a Burr12 distribution. The realized demand for product <code>i</code> under scenario <code>sc</code> is calculated as:</p>
<pre>
D̃<sub>i,sc</sub> = D<sub>i</sub> × demandVar<sub>i,sc</sub>
</pre> 
   • Using the Python notebook <code>KMEANS.ipynb</code>, 10 000 values of <code>D̃<sub>i,sc</sub></code> are generated for each product. These values are saved to <code>input_demands.xlsx</code>.</p>

### **Scenario Reduction**  
   •A GAMS SAA with 10 000 scenarios is computationally intractable. To reduce the problem size, the 10 000 × |I| demand matrix is processed using K-Means clustering in Python. The 10 000 points are clustered into <strong>K ≈ 1000</strong> centroids, and each centroid’s weight is calculated as (cluster size) / 10 000. The resulting representative demands and their weights are saved for the GAMS model.




### **Putting Everything Together**  
   • Summarize the pipeline:  
     1. To run the model, place the K-Means output file (`input_demands.xlsx`) in the same folder as `surplus.gms`. Then, from a terminal opened in that folder, execute:
        surplus.gms lo=2.  
     2. GAMS will import `input_demands.xlsx`, solve the deterministic-equivalent SAA, and write the results to `surplus_output.xlsx` in the same directory. Open `surplus_output.xlsx` to view the optimal surplus 
        decisions and scenario-by-scenario recourse metrics.


---
