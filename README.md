# fs-2025-equiv-replication

Replication archive for Doorley, Duggan, Kakoulidou and Roantree (2025), "Equivalisation (Once Again)". Fiscal Studies, 2026 (June) DOI: 10.1111/1475-5890.70025


Raw microdata are restricted-access and must be applied for separately at https://issda.ucd.ie/dataverse/hbs (ISSDA 0022-00, Household Budget Survey DIP files, 1987–2015). Once obtained, extract the data files into `Data/rawdata/` in this repository (gitignored).

---

## Repository structure

```
fs-2025-equiv-replication/
├── Master.do                # Top-level entry point: runs all three parts in sequence
├── Cleaning files/          # Year-specific data cleaning scripts
│   ├── engel_clean1987.do
│   ├── engel_clean1994.do
│   ├── engel_clean1999.do
│   ├── engel_clean2004.do
│   ├── engel_clean2009.do
│   └── engel_clean2015.do
│
├── Prices/                  # Price indices (base year 2011) used to deflate expenditure
│   ├── prices_YYYY_base_2011.xlsx   # Annual commodity price indices (one per HBS wave)
│   ├── prices_pooled_base_2011.xlsx # Pooled price index
│   ├── quarterly_prices_pooled_base_2011.xlsx
│   └── CPM02.20240322231856.csv     # CSO CPI series (base Dec 2023=100)
│
├── Scales/                  # OLS/kernel scale estimation sub-files (called from Master.do)
│   ├── 1_Data.do            # Loads raw HBS data, merges price series, saves analysis file
│   ├── 2_Vars.do            # Constructs expenditure shares and ancillary variables
│   ├── 3_Summ_stats.do      # Summary statistics
│   ├── 4_Graphs.do          # Descriptive graphs
│   ├── 5_Engel.do           # Engel method (food/clothing/housing budget shares)
│   ├── 6_Rothbarth.do       # Rothbarth method (adult-good budget shares)
│   ├── 7_(QU)AIDS.do        # AIDS / QUAIDS demand system (single-equation)
│   └── Buhmann_et_al.do     # Buhmann et al. parametric and two-parameter scales
│
├── Scales 3SLS/             # 3SLS demand-system estimation sub-files (called from Master.do)
│   ├── 2_vars.do            # Constructs demand-system variables and budget shares
│   ├── 3_firststage.do      # First-stage regressions for instrumenting total expenditure
│   └── 4_estimation.do      # Estimates AIDS/QUAIDS system via nlsur (3SLS)
│
└── poverty rates/
    ├── 0_set_scales.do                 # Defines estimated scale matrices (adult and child)
    ├── 1_plot_scales.do                # Plots estimated scale values over time (colour + greyscale);
    │                                   # greyscale versions also exported as figure1a/1b.png
    └── 2_calc_plot_poverty_results.do  # Applies scales to compute poverty rates,
                                        # Gini coefficients, and income-rank comparisons
```

Gitignored folders (created automatically on first run, not committed):
- `Data/rawdata/` — raw HBS microdata
- `Data/moddata/` — intermediate `.dta` files
- `Results/tables/` — output tables
- `Results/graphs/` — output figures

---

## How to replicate

### Step 1 – Obtain and place the data

Apply for the HBS Datafile (ISSDA 0022-00) at https://issda.ucd.ie/dataverse/hbs. The six waves used are 1987, 1994, 1999, 2004, 2009, and 2015.

Once access is granted, extract the raw `.dta` files into `Data/rawdata/` within this repository. The cleaning scripts expect the following subfolder structure (matching the ISSDA download layout):

```
Data/rawdata/
├── 0022-01_HBS_1987/0022-01_HBS_1987_Data/0022-01_HBS_1987.dta
├── 0022-02_HBS_1994/...
├── 0022-03_HBS_1999/...
├── 0022-04_HBS_2004/...
├── 0022-05_HBS_2009/...
└── 0022-06_HBS_2015/...
```

`Data/` is listed in `.gitignore` so raw data files will not be committed to the repository.

### Step 2 – Run the replication

Open `Master.do` and set the `repo` global to your local path. All other paths are derived from it automatically.

Then run `Master.do`. It executes three parts in sequence:

**Part 1 – OLS/kernel scale estimation** loops over all six HBS waves and estimates:
- Engel scales (food, clothing, housing budget shares)
- Rothbarth scales (adult-good budget shares)
- AIDS/QUAIDS scales (single-equation demand system)
- Buhmann et al. parametric scales

Setting `run_ker = 1` in `Master.do` re-runs kernel regressions (slow; `ker_reps` controls bootstrap repetitions).

**Part 2 – 3SLS scale estimation** instruments total expenditure with household disposable income and estimates the AIDS/QUAIDS demand system via `nlsur`. It uses the cleaned analysis files (`HBS_YYYY_analysis.dta`) produced in Part 1.

**Part 3 – Poverty rates and inequality figures** runs three files in sequence:
- `0_set_scales.do` defines the estimated adult and child scale matrices
- `1_plot_scales.do` plots scale values over time in both colour and greyscale; greyscale versions are also saved as `figure1a.png` and `figure1b.png` in `Results/graphs/`
- `2_calc_plot_poverty_results.do` deflates income to January 2023 prices, applies all estimated scales (plus standard alternatives: modified OECD, CSO national, square-root, per-capita), computes at-risk-of-poverty rates and Gini coefficients under each scale with both contemporaneous and fixed (1987/2015) scales, and produces income-rank comparison plots (Spearman ρ, Kendall τ). Figures are exported to `Results/graphs/`.
