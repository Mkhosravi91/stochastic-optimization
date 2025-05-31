## Methodology / How It Works

### 1. Two‐Stage Stochastic Formulation
We model surplus allocation as a two‐stage stochastic program with sets:
- \(I\) = set of products (index \(i\)).  
- \(J\) = set of substitutability groups (index \(j\)); each product \(i\) belongs to exactly one group \(j(i)\).  
- \(SC\) = set of demand scenarios (index \(sc\), \(\lvert SC\rvert = K\)).

#### First Stage (Here‐and‐Now)
Decide a nonnegative surplus quantity \(S_{i}\) to add on top of each product’s nominal forecast \(D_{i}\). These \(S_{i}\) must satisfy:

1. **Capacity Limit**  
   \[
   D_{i} \;+\; S_{i} \;\;\le\;\; \text{Cap}_{i},
   \quad
   \forall\,i\in I.
   \]

2. **Macro‐Target Surplus**  
   \[
   \sum_{\,i\in I} S_{\,i}
   \;\;\le\;\; \text{MTP} 
   \;\times\; 
   \sum_{\,i\in I} D_{\,i},
   \]
   where \(\text{MTP}\) is the user‐specified macro‐target percentage (e.g., 0.10–0.50).

3. **Group‐Level Lower Bound**  
   For every substitutability group \(j\in J\):
   \[
   \sum_{\substack{i\in I:\\j(i)=j}} S_{\,i}
   \;\;\ge\;\; \text{LB}_{\,j},
   \]
   where \(\text{LB}_{\,j}\) is a user‐defined minimum total surplus for group \(j\).

#### Second Stage (Recourse under Realized Demand)
Once random demand realizes, we compute actual sales, excess inventory, shortages, and substitution flows. Each product’s realized demand under scenario \(sc\) is denoted \(D_{i,\,sc}\). In practice,
\[
D_{i,\,sc} \;=\; D_{i} \;\times\; \text{demandVar}_{i,\,sc},
\]
where \(\text{demandVar}_{i,\,sc}\) is drawn from product \(i\)’s Burr12 distribution (determined by its “demand‐variance group”). Because \(D_{i,\,sc}\) is uncertain, we maximize expected profit over all scenarios.

The GAMS model (`surplus.gms`) solves a deterministic equivalent by replacing the expectation with a weighted sum over \(K\) scenarios (Sample Average Approximation). In other words:
\[
\max_{\,\{S,A,U,L,O'\}} \;\sum_{sc\in SC} p_{sc}\,\Bigl[\text{profit under scenario }sc\Bigr],
\]
where \(p_{sc}\) is the probability weight of scenario \(sc\).

---

### 2. Scenario Generation (Monte Carlo on Variance)
Instead of sampling absolute demand directly, we sample a **variance multiplier** from a Burr12 distribution and then multiply by each product’s forecast \(D_{i}\). The steps (implemented in `notebooks/KMEANS.ipynb`) are:

1. **Load Product Data**  
   - For each product \(i\in I\), retrieve:
     - Nominal forecast \(D_{i}\).  
     - Its demand‐variance group index \(g(i)\in \{1,\dots,\lvert J\rvert\}\).  
     - The Burr12 parameters \((c_{g},\,d_{g},\,\mathrm{loc}_g,\,\mathrm{scale}_g)\) for group \(g\).  

2. **Draw 10 000 Variance Samples per Product**  
   ```python
   from scipy.stats import burr12
   import pandas as pd

   # Suppose df_params has columns: ['product', 'forecast', 'c','d','loc','scale']
   n_products = len(df_params)
   n_scenarios = 10_000
   demands = pd.DataFrame(index=range(1, n_scenarios+1),
                          columns=[f"D_{i}" for i in df_params['product']])

   for idx, row in df_params.iterrows():
       i = row['product']        # e.g., "P1"
       D_i = row['forecast']     # nominal demand
       c, d, loc, scale = row['c'], row['d'], row['loc'], row['scale']

       variances = burr12.rvs(c=c, d=d, loc=loc, scale=scale, size=n_scenarios)
       demands[f"D_{i}"] = D_i * variances

   demands.insert(0, "Scenario_ID", range(1, n_scenarios+1))
   demands.to_excel("data/input_demands.xlsx", sheet_name="All_Scenarios", index=False)
