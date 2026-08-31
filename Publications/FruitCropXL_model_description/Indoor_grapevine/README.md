# GF HGU Optimising Indoor Cultivation
 
This project investigates the sensitivity of grapevine simulation outputs to various physiological and environmental input factors. We use both statistical and model-based approaches to identify which variables have the most impact on key plant traits such as harvest index, fruit dry weight, and biomass.
 
The dataset comes from full-factorial simulations using the fruitcropxl model, representing different vine types (spur and cane). We evaluate sensitivity using ANOVA F-tests and partial eta-squared (η²), with linear models capturing both main effects and interactions.
 
Key tools and methods:
 
- Linear modeling with statsmodels (Python) and lm() in R
- Sensitivity analysis using anova_lm() and custom visualisation
- Comparison against surrogate-based methods like Polynomial Chaos (chaos_sobol, chaos_ancova)
- Analysis across multiple target outputs
# Setup and installation
 
## Create Python environment
Clone the repo:
 
```
git clone git@github.com:PlantandFoodResearch/grapevine-indoor-optimisation.git
```
 
Install Poetry:
```
curl -sSL https://install.python-poetry.org | python3 -
```
 
Install dependencies:
 
```
poetry install
```
 
Activate the environment (or just prefix every command below with `poetry run`, which is what this README does):
```
poetry env activate
```
> `poetry shell` was removed from Poetry core as of 2.0 -- if you're on an older Poetry version you may still have it, but `poetry env activate` (or plain `poetry run <command>`) works regardless of version.
 
## Register Jupyter kernel (optional)
If you want to run the notebooks under `notebooks/`, you will need to register the new Poetry/Python environment with Jupyter.
 
This can be done by running the following command from within the cloned repository directory:
 
```
poetry run python -m ipykernel install --user --name "grapevine-indoor-optimisation"
```
You should then be able to select the `grapevine-indoor-optimisation` kernel when opening notebooks in Jupyter.
 
# Project structure
 
```
grapevine-indoor-optimisation/
├── pyproject.toml, poetry.lock        # dependencies
├── config.json                        # data paths, folders, filter -- see Configuration below
├── scripts/
│   ├── run_sensitivity_analysis.py    # data pipeline: raw sims -> per-simulation summary -> ANOVA
│   └── generate_figures.py            # plotting only: reads the CSVs above, draws Figure 6 / S1-S3
└── notebooks/models/grapevine/
    └── grapevine_sensitivity_analysis.ipynb   # thin wrapper: calls the two scripts, displays figures inline
```
 
The scripts are the source of truth -- they run standalone with no Jupyter dependency. The notebook exists to let you regenerate and view figures inline without leaving Jupyter; it imports and calls the same code.
 
# Configuration
 
Folders, paths, targets, and the treatment filter live in `config.json` at the repo root, not hard-coded in the script. `run_sensitivity_analysis.py` looks for `config.json` in this order and uses the first one it finds: next to the script, one directory up, then the current working directory. If none is found, it falls back to sensible built-in defaults.
 
Key fields:
 
| Field | Meaning |
|---|---|
| `base_path` | Root folder of the raw simulation output (e.g. `/output/FruitCropXL/HGU-sim/`) |
| `field_space_csv` | Path to the experiment-design metadata CSV, keyed by simulation `uuid` |
| `vine_folders` | Which subfolders under `base_path` belong to each vine type (`spur` / `cane`) |
| `cane_reconstruct_crop_loads` / `cane_known_good_crop_loads` | Which cane crop-load batches need metadata reconstructed vs. already have it from `field_space_csv` |
| `input_cols`, `plant_targets`, `fruit_targets` | Which columns are ANOVA inputs vs. outputs |
| `predictors` | The patsy formula (main effects + two-way interactions) used in the ANOVA |
| `filter` | The treatment filter applied before summarising each simulation |
| `apply_filter` | Set `false` to skip the filter entirely |
| `save_combined_csv` | Set `true` to also save the raw (pre-summary) combined dataframe |
 
To use a different config for a one-off run, pass `--config path/to/other_config.json`, or override individual values with `--base-path` / `--field-space-csv` without touching the file at all.
 
# Running the analysis
 
## Option A: from the command line (no Jupyter required)
 
Run the data pipeline once per vine type. Each run reads the raw simulation CSVs, applies the treatment filter, and writes the summarised + ANOVA CSVs to `outdir/<vine-type>/`:
 
```
poetry run python scripts/run_sensitivity_analysis.py --vine-type spur
poetry run python scripts/run_sensitivity_analysis.py --vine-type cane
```
 
Then generate Figure 6 and Supplementary Figures S1-S3 from those CSVs:
 
```
poetry run python scripts/generate_figures.py
```
 
Useful flags on `run_sensitivity_analysis.py`:
 
| Flag | Purpose |
|---|---|
| `--vine-type {spur,cane}` | Required. Which vine type to process. |
| `--outdir PATH` | Where to write output CSVs/plots. Defaults to `outdir/<vine-type>`. |
| `--config PATH` | Use a specific config file instead of auto-discovery. |
| `--base-path PATH` | Override `config['base_path']` for this run only. |
| `--field-space-csv PATH` | Override `config['field_space_csv']` for this run only. |
| `--no-filter` | Skip the treatment filter. |
| `--no-diagnostic-plot` | Skip saving the per-target top-5 F-value PNG (faster). |
| `--save-combined-csv` | Also save the raw combined dataframe before summarising. |
| `--verbose` | Print which simulations get dropped during summarising, and why. |
 
Run `poetry run python scripts/run_sensitivity_analysis.py --help` for the full list.
 
## Option B: from the notebook
 
Open `notebooks/models/grapevine/grapevine_sensitivity_analysis.ipynb` (using the `grapevine-indoor-optimisation` kernel registered above) and run it top to bottom. It imports `run_sensitivity_analysis` and `generate_figures` from `scripts/` and calls the same functions as Option A, displaying each figure inline as it's generated.
 
If you already have `outdir/spur` and `outdir/cane` populated from a previous run (e.g. checked into the repo), you can skip the pipeline cell and just re-run the figure cells to redraw from the existing CSVs.