# Dockerizing the FruitCropXL surrogate service

Models are **baked into the image** — no MLflow/MinIO network access or
credentials needed at container runtime. This means the deferred
Kubernetes deployment can also skip any MinIO secret wiring for this
service later.

## One-time setup (per model update)

Run this on `aklppb40` (or anywhere with network access to MLflow/MinIO)
to pull the current `@champion` models down to plain local directories:

```bash
python export_models.py
```

This creates `docker_models/light/` and `docker_models/water/`. Rename/move
that folder to `models/` inside your Docker build context:

```bash
mv docker_models models
```

Re-run this whenever you promote a new `@champion` in MLflow and want the
image to pick it up, then rebuild.

## Build context layout expected by the Dockerfile

```
.
├── Dockerfile
├── .dockerignore
├── requirements-serve.txt
├── main.py
├── solar.py
├── static/
│   └── index.html
└── models/
    ├── light/     ← from export_models.py
    └── water/     ← from export_models.py
```

## Build & run locally (e.g. on your Mac, before shipping to aklppb40)

```bash
docker compose up --build
```

Then open http://localhost:8000.

## Build & run on aklppb40 (no compose needed)

```bash
docker build -t fruitcropxl-surrogate:v3.2.0 .
docker run -d --name plant-surrogate -p 8000:8000 --restart unless-stopped \
    fruitcropxl-surrogate:v3.2.0
```

Swap this in for the current `nohup uvicorn ... &` process — kill the old
one (`lsof -i :8000` as usual to find the real PID) and let the container
take port 8000 instead.

## What got trimmed vs. `pyproject.toml`

`requirements-serve.txt` is a hand-picked subset — `main.py` only imports
`numpy`, `pandas`, `mlflow`, `fastapi`/`pydantic`/`uvicorn`, and the local
`solar.py`. Training-time dependencies your full Poetry environment
carries (`torch`, `scikit-activeml`, `plotly`, `seaborn`, `boto3`) are
**not** in the serving image — they're unused at runtime and `torch`
alone would add a large chunk of image size for nothing.

## Confirmed dependency scope

`solar.py` was checked — it only imports `math` from the standard
library, so `requirements-serve.txt` needs nothing added for it.

## Note on `configure_mlflow_env()` in `main.py`

That function hardcodes dummy MinIO credentials into `os.environ` on
every startup. With models baked in and loaded from a local path, this
function's output is never actually used (local-path loading doesn't
touch MinIO), so it's harmless here — but worth knowing it's there if
you ever reuse this container image pattern for a service that *does*
need live registry access.
