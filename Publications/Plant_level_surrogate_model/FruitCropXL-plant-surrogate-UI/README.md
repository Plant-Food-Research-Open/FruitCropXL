# FruitCropXL Surrogate Model

Fast, interactive ML surrogates for an apple tree functional-structural
plant model. Two MLP pipelines replace a computationally expensive
mechanistic simulator with millisecond predictions, served behind a
FastAPI backend and a browser UI with live sliders, response sweeps,
and CSV/met-file batch prediction.

Developed at [Plant & Food Research](https://www.plantandfood.com/) in
collaboration with Victoria University of Wellington, for both internal
research use and academic publication (*In Silico Plants*).

## Models

| Model | Features | Targets | R² (mean) |
|---|---|---|---|
| **Light** | 8 (environmental/canopy) | `fabsPAR`, `fPAR_1` | 0.986 |
| **Water** | 15 (environmental + hydraulic params) | `waterFlux_optimized`, `xylemWaterPotential`, `intWaterPotential_1–4` | 0.968 |

Both models are `scikit-learn` `Pipeline`s (`StandardScaler → MultiOutputRegressor(MLPRegressor)`),
tracked in [MLflow](https://mlflow.org/) with `@champion` aliases and a
MinIO artifact backend. A single artifact per model means no manual
scaling is needed at inference time.

Solar geometry (elevation, azimuth, sunrise/sunset) is computed with
[Spencer (1971)](https://www.mail-archive.com/sundial@uni-koeln.de/msg01050.html)
equations in `solar.py`, a dependency-free reimplementation credited to
Chris Van Houtte.

## Features

- **Live prediction UI** — adjustable sliders for every model input, updating predictions in real time
- **Response sweeps** — vary one input across its trained range while holding the rest fixed, see the effect on every output
- **Batch prediction** — upload a feature CSV, or a raw met-station CSV (auto-parsed into model-ready rows via `solar.py`, with slider values filling in anything not derivable from the met file)
- **Sunrise/sunset-aware zeroing** — radiation and diffuse-light features are physically zeroed outside daylight hours when driven from met data
- **Publication-ready figure pages** — stripped-down single-model views (`index_w.html`, `index_l.html`) for generating clean paper screenshots, with human-readable parameter labels and inline definitions for the water model's hydraulic parameters

## API

```
GET  /                          → UI (static/index.html)
GET  /api/meta                  → feature ranges + target names for both models
POST /api/predict/light         → single-point light prediction
POST /api/predict/water         → single-point water prediction
POST /api/sweep/light           → sweep one light feature across its range
POST /api/sweep/water           → sweep one water feature across its range
POST /api/predict_batch/light   → batch light prediction from list of rows
POST /api/predict_batch/water   → batch water prediction from list of rows
POST /api/parse_met             → parse a met CSV into model-ready rows
```

## Running it

### With Docker (recommended)

Models are baked into the image at build time — the container needs no
MLflow/MinIO network access or credentials to run.

```bash
# one-time: pull the current @champion models locally (needs MLflow/MinIO access)
python export_models.py
mv docker_models models

# build + run
docker compose up --build
```

Then open http://localhost:8000. See [`DOCKER_README.md`](DOCKER_README.md)
for the full build/run workflow, including how to verify the models are
genuinely baked into the image rather than fetched at runtime.

### Without Docker

Requires Python 3.10 and [Poetry](https://python-poetry.org/):

```bash
poetry install
poetry run uvicorn main:app --host 0.0.0.0 --port 8000
```

This path loads models live from the MLflow registry (`LIGHT_MODEL_URI` /
`WATER_MODEL_URI` env vars, defaulting to `models:/...@champion`), so it
needs network access to your MLflow + MinIO endpoints.

## Repository layout

```
.
├── main.py                  # FastAPI backend
├── solar.py                 # Solar position (Spencer 1971), no dependencies
├── static/
│   ├── index.html            # main interactive app (light + water tabs)
│   ├── index_w.html           # water-only figure page (for paper screenshots)
│   └── index_l.html           # light-only figure page (for paper screenshots)
├── export_models.py         # one-time script: MLflow → local model dirs
├── Dockerfile
├── docker-compose.yml
├── requirements-serve.txt   # trimmed runtime deps (excludes training-only libs)
├── pyproject.toml           # full dev/training environment (Poetry)
└── DOCKER_README.md
```

## Tech stack

FastAPI · scikit-learn · MLflow · MinIO · Chart.js · vanilla JS/HTML/CSS

## Authors

- Junhao Huang — Victoria University of Wellington
- James Bristow, Chris Van Houtte, Anand Rampadarath — Plant & Food Research
