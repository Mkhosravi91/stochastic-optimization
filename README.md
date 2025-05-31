# Surplus‐Allocation Stochastic Optimization

A two‐stage stochastic programming model (implemented in GAMS) to determine the optimal surplus quantity for each product’s demand forecast. Demand uncertainty is modeled via Burr12‐based variance multipliers, scenarios are clustered with K-Means, and the resulting Sample Average Approximation (SAA) is solved in GAMS.

---

## Table of Contents
1. [Overview](#overview)  
2. [File Structure](#file-structure)  
3. [Prerequisites](#prerequisites)  
4. [Installation & Setup](#installation--setup)  
5. [Methodology / How It Works](#methodology--how-it-works)  
   1. [Two-Stage Stochastic Formulation](#two-stage-stochastic-formulation)  
   2. [Scenario Generation (Monte Carlo on Variance)](#scenario-generation-monte-carlo-on-variance)  
   3. [Scenario Reduction](#scenario-reduction)  
   4. [Putting Everything Together](#putting-everything-together)  
6. [Mathematical Formulation](#mathematical-formulation)  
7. [Usage](#usage)  
8. [Author](#author)  

---

## Overview

In this project, we seek to identify—for each product—the optimal “surplus” quantity \(S_i\) to add to its nominal forecast \(D_i\), so as to maximize expected profit margins under demand uncertainty. Rather than sampling absolute demand directly, we sample a **variance multiplier** \(\mathrm{demandVar}_{i,sc}\) from a Burr12 distribution and compute realized demand:

\[
\tilde{D}_{i,sc} \;=\; D_i \;\times\; \mathrm{demandVar}_{i,sc}.
\]

We generate 10 000 such scenarios per product, reduce them via K-Means clustering to \(K\approx200\) representative scenarios (with associated weights), and then solve the deterministic equivalent SAA model in GAMS (`surplus.gms`). The final output is an Excel file containing optimal surplus decisions and scenario‐by‐scenario recourse metrics.

---

## File Structure


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
