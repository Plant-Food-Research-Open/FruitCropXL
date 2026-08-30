"""
Plant Surrogate Model — FastAPI backend (v3)
Serves predictions from two MLflow-registered Pipelines:
  - FruitCropXL-light-surrogate@champion  (8 features  → 2 targets)
  - FruitCropXL-water-surrogate@champion  (15 features → 6 targets)

Each Pipeline is StandardScaler → MultiOutputRegressor(MLPRegressor),
logged as a single artifact, so .predict() needs no scaler handling here.

Endpoints:
  GET  /                          → UI (static/index.html)
  GET  /api/meta                  → feature ranges + target names for both models
  POST /api/predict/light         → single-point light prediction
  POST /api/predict/water         → single-point water prediction
  POST /api/sweep/light           → sweep one light feature across its range
  POST /api/sweep/water           → sweep one water feature across its range
  POST /api/predict_batch/light   → batch light prediction from list of rows
  POST /api/predict_batch/water   → batch water prediction from list of rows
  POST /api/parse_met             → parse a met CSV into model-ready rows
"""

import io
import os
import numpy as np
import pandas as pd
import mlflow
import mlflow.sklearn
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel
from typing import Optional
from fastapi.middleware.cors import CORSMiddleware

from solar import solar_position, sunrise_sunset

# ── Config ────────────────────────────────────────────────────────────────────

MLFLOW_TRACKING_URI = os.environ.get(
    "MLFLOW_TRACKING_URI",
    "https://mlflow.mcp.k8s.dev.pfr.co.nz"
)
LIGHT_MODEL_URI = os.environ.get(
    "LIGHT_MODEL_URI",
    "models:/FruitCropXL-light-surrogate@champion"
)
WATER_MODEL_URI = os.environ.get(
    "WATER_MODEL_URI",
    "models:/FruitCropXL-water-surrogate@champion"
)

# ── Feature / target definitions ───────────────────────────────────────────────

LIGHT_FEATURE_ORDER = [
    'hourOfDay', 'rowOrientation', 'rowDistance',
    'azimuth', 'solarElevation', 'leafAreaPerPlant',
    'fDiffuseLight', 'incomingRadiation',
]

WATER_FEATURE_ORDER = [
    'hourOfDay', 'azimuth', 'solarElevation', 'leafAreaPerPlant',
    'fDiffuseLight', 'incomingRadiation',
    'Ta', 'rh', 'wind', 'soilWaterPotential',
    'P:eq1_b', 'P:phi_stem', 'P:Grmax_a', 'P:slope_Jmax', 'P:cx1',
]

LIGHT_TARGET_NAMES = ['fabsPAR', 'fPAR_1']

WATER_TARGET_NAMES = [
    'waterFlux_optimized', 'xylemWaterPotential',
    'intWaterPotential_1', 'intWaterPotential_2',
    'intWaterPotential_3', 'intWaterPotential_4',
]

LIGHT_FEATURE_RANGES = {
    'hourOfDay':         {'min': 9.0,    'max': 16.0,    'default': 12.5},
    'rowOrientation':    {'min': -23.0,  'max': 135.0,   'default': -19.6},
    'rowDistance':       {'min': 1.0,    'max': 3.0,     'default': 2.0},
    'azimuth':           {'min': 10.0,   'max': 359.0,   'default': 184.0},
    'solarElevation':    {'min': 8.0,    'max': 74.0,    'default': 58.0},
    'leafAreaPerPlant':  {'min': 7.0,    'max': 23.0,    'default': 20.8},
    'fDiffuseLight':     {'min': 0.0,    'max': 1.0,     'default': 0.84},
    'incomingRadiation': {'min': 217.0,  'max': 5073.0,  'default': 1162.0},
}

WATER_FEATURE_RANGES = {
    'hourOfDay':          {'min': 9.0,     'max': 16.0,    'default': 12.5},
    'azimuth':            {'min': 10.0,    'max': 359.0,   'default': 184.0},
    'solarElevation':     {'min': 8.0,     'max': 74.0,    'default': 58.0},
    'leafAreaPerPlant':   {'min': 7.0,     'max': 23.0,    'default': 20.8},
    'fDiffuseLight':      {'min': 0.0,     'max': 1.0,     'default': 0.84},
    'incomingRadiation':  {'min': 217.0,   'max': 5073.0,  'default': 1162.0},
    'Ta':                 {'min': 9.0,     'max': 30.1,    'default': 19.0},
    'rh':                 {'min': 0.31,    'max': 0.95,    'default': 0.755},
    'wind':               {'min': 0.9,     'max': 8.9,     'default': 4.0},
    'soilWaterPotential': {'min': -0.8,    'max': -0.077,  'default': -0.196},
    'P:eq1_b':            {'min': -2.0,    'max': -0.8,    'default': -1.39},
    'P:phi_stem':         {'min': -3.5,    'max': -1.5,    'default': -2.51},
    'P:Grmax_a':          {'min': 0.0006,  'max': 0.0021,  'default': 0.0013},
    'P:slope_Jmax':       {'min': 40.0,    'max': 80.0,    'default': 60.0},
    'P:cx1':              {'min': 0.9,     'max': 2.0,     'default': 1.4},
}

# Met-file-sourced features per model — exposed via /api/meta so the
# frontend knows which sliders to lock when a met file is loaded.
LIGHT_MET_FEATURES = ['hourOfDay', 'incomingRadiation', 'azimuth', 'solarElevation']
WATER_MET_FEATURES = ['hourOfDay', 'Ta', 'rh', 'wind', 'incomingRadiation',
                      'soilWaterPotential', 'azimuth', 'solarElevation']

# ── MLflow / MinIO env vars ───────────────────────────────────────────────────

def configure_mlflow_env():
    os.environ["MLFLOW_TRACKING_INSECURE_TLS"]           = "true"
    os.environ["MLFLOW_TRACKING_IGNORE_TLS_VERIFICATION"] = "true"
    os.environ["MLFLOW_ENABLE_PROXY_MULTIPART_UPLOAD"]    = "true"
    os.environ["AWS_ACCESS_KEY_ID"]                       = "user"
    os.environ["AWS_SECRET_ACCESS_KEY"]                   = "password"
    os.environ["MLFLOW_S3_ENDPOINT_URL"]                  = "https://minio-api.mcp.k8s.dev.pfr.co.nz"
    os.environ["AWS_SSL_VERIFY"]                          = "false"
    os.environ["AWS_CA_BUNDLE"]                           = ""
    os.environ["MLFLOW_S3_IGNORE_TLS"]                    = "true"

# ── Lifespan ──────────────────────────────────────────────────────────────────

light_model = None
water_model = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    global light_model, water_model
    configure_mlflow_env()
    mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)

    print(f"Loading light model: {LIGHT_MODEL_URI}")
    try:
        light_model = mlflow.sklearn.load_model(LIGHT_MODEL_URI)
        print(f"  ✓ Light model loaded: {type(light_model)}")
    except Exception as e:
        print(f"  ERROR: Failed to load light model — {e}")
        light_model = None

    print(f"Loading water model: {WATER_MODEL_URI}")
    try:
        water_model = mlflow.sklearn.load_model(WATER_MODEL_URI)
        print(f"  ✓ Water model loaded: {type(water_model)}")
    except Exception as e:
        print(f"  ERROR: Failed to load water model — {e}")
        water_model = None

    yield

# ── App ───────────────────────────────────────────────────────────────────────

app = FastAPI(title="Plant Surrogate Model API", version="3.2.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Schemas ───────────────────────────────────────────────────────────────────

class PredictRequest(BaseModel):
    inputs: dict[str, float]

class SweepRequest(BaseModel):
    inputs: dict[str, float]
    sweep_feature: str
    n_points: Optional[int] = 80
    # Daylight window for zeroing incomingRadiation/fDiffuseLight when
    # sweep_feature == 'hourOfDay'. Either pass sunrise_hr/sunset_hr directly
    # (manual single-point path), or lat/lon/day_of_year to derive them from
    # solar geometry (site-context path).
    sunrise_hr: Optional[float] = None
    sunset_hr: Optional[float] = None
    lat: Optional[float] = None
    lon: Optional[float] = None
    day_of_year: Optional[int] = None
    # When sweeping hourOfDay, sweep the full 0-24h range instead of the
    # model's trained [9,16] window. Points outside [9,16] are flagged via
    # outside_trained_range in the response — treat them as extrapolations.
    extend_hours: Optional[bool] = False

class BatchRequest(BaseModel):
    rows: list[dict]

class ParseMetResponse(BaseModel):
    """Parsed met file rows ready for batch prediction, plus metadata."""
    rows: list[dict]    # met-derived features only; frontend merges slider values
    row_count: int
    years: list[int]
    day_min: int
    day_max: int
    warnings: list[str]

# ── Helpers ───────────────────────────────────────────────────────────────────

def build_df(inputs: dict, feature_order: list, feature_ranges: dict) -> pd.DataFrame:
    row = [inputs.get(f, feature_ranges[f]['default']) for f in feature_order]
    return pd.DataFrame([row], columns=feature_order)

def resolve_sweep_daylight_window(req) -> tuple:
    """
    Resolve (sunrise_hr, sunset_hr) for a sweep request: prefer explicit
    sunrise_hr/sunset_hr (manual path), else derive from lat/lon/day_of_year
    (site-context path). Returns (None, None) if neither is available/resolvable.
    """
    if req.sunrise_hr is not None and req.sunset_hr is not None:
        return req.sunrise_hr, req.sunset_hr
    if req.lat is not None and req.lon is not None and req.day_of_year is not None:
        return sunrise_sunset(req.day_of_year, req.lat, req.lon)
    return None, None

# ── Routes ────────────────────────────────────────────────────────────────────

@app.get("/")
def root():
    return FileResponse("static/index.html")

@app.get("/api/meta")
def get_meta():
    return {
        "light": {
            "features":       LIGHT_FEATURE_ORDER,
            "feature_ranges": LIGHT_FEATURE_RANGES,
            "targets":        LIGHT_TARGET_NAMES,
            "met_features":   LIGHT_MET_FEATURES,
        },
        "water": {
            "features":       WATER_FEATURE_ORDER,
            "feature_ranges": WATER_FEATURE_RANGES,
            "targets":        WATER_TARGET_NAMES,
            "met_features":   WATER_MET_FEATURES,
        },
    }

@app.post("/api/predict/light")
def predict_light(req: PredictRequest):
    if light_model is None:
        raise HTTPException(status_code=503, detail="Light model not loaded")
    X = build_df(req.inputs, LIGHT_FEATURE_ORDER, LIGHT_FEATURE_RANGES)
    pred = light_model.predict(X)[0]
    return {"predictions": dict(zip(LIGHT_TARGET_NAMES, [round(float(v), 6) for v in pred]))}

@app.post("/api/predict/water")
def predict_water(req: PredictRequest):
    if water_model is None:
        raise HTTPException(status_code=503, detail="Water model not loaded")
    X = build_df(req.inputs, WATER_FEATURE_ORDER, WATER_FEATURE_RANGES)
    pred = water_model.predict(X)[0]
    return {"predictions": dict(zip(WATER_TARGET_NAMES, [round(float(v), 6) for v in pred]))}

@app.post("/api/sweep/light")
def sweep_light(req: SweepRequest):
    if light_model is None:
        raise HTTPException(status_code=503, detail="Light model not loaded")
    if req.sweep_feature not in LIGHT_FEATURE_RANGES:
        raise HTTPException(status_code=400, detail=f"Unknown light feature: {req.sweep_feature}")

    feat_range = LIGHT_FEATURE_RANGES[req.sweep_feature]
    trained_hour_min = LIGHT_FEATURE_RANGES['hourOfDay']['min']
    trained_hour_max = LIGHT_FEATURE_RANGES['hourOfDay']['max']
    extend_sweep_hours = req.sweep_feature == 'hourOfDay' and req.extend_hours
    if extend_sweep_hours:
        sweep_vals = np.linspace(0.0, 24.0, req.n_points)
    else:
        sweep_vals = np.linspace(feat_range['min'], feat_range['max'], req.n_points)

    sunrise_hr, sunset_hr = (None, None)
    use_solar_geometry = (
        req.sweep_feature == 'hourOfDay'
        and req.lat is not None and req.lon is not None and req.day_of_year is not None
    )
    if req.sweep_feature == 'hourOfDay':
        sunrise_hr, sunset_hr = resolve_sweep_daylight_window(req)

    rows = []
    outside_trained_range = []
    for v in sweep_vals:
        row_inputs = {f: req.inputs.get(f, LIGHT_FEATURE_RANGES[f]['default']) for f in LIGHT_FEATURE_ORDER}
        row_inputs[req.sweep_feature] = float(v)
        if use_solar_geometry:
            # Recompute the sun's actual position for this hour/day/site, rather
            # than holding azimuth/solarElevation pinned at their slider values.
            elev, az = solar_position(req.day_of_year, float(v), req.lat, req.lon)
            row_inputs['azimuth'] = az
            row_inputs['solarElevation'] = elev
        if sunrise_hr is not None and sunset_hr is not None and (float(v) < sunrise_hr or float(v) > sunset_hr):
            row_inputs['incomingRadiation'] = 0.0
            row_inputs['fDiffuseLight'] = 0.0
        rows.append([row_inputs[f] for f in LIGHT_FEATURE_ORDER])
        outside_trained_range.append(
            req.sweep_feature == 'hourOfDay' and (float(v) < trained_hour_min or float(v) > trained_hour_max)
        )

    X = pd.DataFrame(rows, columns=LIGHT_FEATURE_ORDER)
    preds = light_model.predict(X)

    return {
        "sweep_feature": req.sweep_feature,
        "sweep_values":  [round(float(v), 6) for v in sweep_vals],
        "outside_trained_range": outside_trained_range,
        "predictions": {
            t: [round(float(preds[i, j]), 6) for i in range(len(sweep_vals))]
            for j, t in enumerate(LIGHT_TARGET_NAMES)
        },
    }

@app.post("/api/sweep/water")
def sweep_water(req: SweepRequest):
    if water_model is None:
        raise HTTPException(status_code=503, detail="Water model not loaded")
    if req.sweep_feature not in WATER_FEATURE_RANGES:
        raise HTTPException(status_code=400, detail=f"Unknown water feature: {req.sweep_feature}")

    feat_range = WATER_FEATURE_RANGES[req.sweep_feature]
    trained_hour_min = LIGHT_FEATURE_RANGES['hourOfDay']['min']
    trained_hour_max = LIGHT_FEATURE_RANGES['hourOfDay']['max']
    extend_sweep_hours = req.sweep_feature == 'hourOfDay' and req.extend_hours
    if extend_sweep_hours:
        sweep_vals = np.linspace(0.0, 24.0, req.n_points)
    else:
        sweep_vals = np.linspace(feat_range['min'], feat_range['max'], req.n_points)

    sunrise_hr, sunset_hr = (None, None)
    use_solar_geometry = (
        req.sweep_feature == 'hourOfDay'
        and req.lat is not None and req.lon is not None and req.day_of_year is not None
    )
    if req.sweep_feature == 'hourOfDay':
        sunrise_hr, sunset_hr = resolve_sweep_daylight_window(req)

    rows = []
    outside_trained_range = []
    for v in sweep_vals:
        row_inputs = {f: req.inputs.get(f, WATER_FEATURE_RANGES[f]['default']) for f in WATER_FEATURE_ORDER}
        row_inputs[req.sweep_feature] = float(v)
        if use_solar_geometry:
            # Recompute the sun's actual position for this hour/day/site, rather
            # than holding azimuth/solarElevation pinned at their slider values.
            elev, az = solar_position(req.day_of_year, float(v), req.lat, req.lon)
            row_inputs['azimuth'] = az
            row_inputs['solarElevation'] = elev
        if sunrise_hr is not None and sunset_hr is not None and (float(v) < sunrise_hr or float(v) > sunset_hr):
            row_inputs['incomingRadiation'] = 0.0
            row_inputs['fDiffuseLight'] = 0.0
        rows.append([row_inputs[f] for f in WATER_FEATURE_ORDER])
        outside_trained_range.append(
            req.sweep_feature == 'hourOfDay' and (float(v) < trained_hour_min or float(v) > trained_hour_max)
        )

    X = pd.DataFrame(rows, columns=WATER_FEATURE_ORDER)
    preds = water_model.predict(X)

    return {
        "sweep_feature": req.sweep_feature,
        "sweep_values":  [round(float(v), 6) for v in sweep_vals],
        "outside_trained_range": outside_trained_range,
        "predictions": {
            t: [round(float(preds[i, j]), 6) for i in range(len(sweep_vals))]
            for j, t in enumerate(WATER_TARGET_NAMES)
        },
    }

# ── Batch endpoints ───────────────────────────────────────────────────────────

@app.post("/api/predict_batch/light")
def predict_batch_light(req: BatchRequest):
    """Batch light prediction — accepts a list of input row dicts, returns predictions for all rows."""
    if light_model is None:
        raise HTTPException(status_code=503, detail="Light model not loaded")
    df    = pd.DataFrame(req.rows)[LIGHT_FEATURE_ORDER]
    preds = light_model.predict(df)
    return {
        "rows": req.rows,
        "predictions": {
            t: [round(float(preds[i, j]), 6) for i in range(len(req.rows))]
            for j, t in enumerate(LIGHT_TARGET_NAMES)
        }
    }

@app.post("/api/predict_batch/water")
def predict_batch_water(req: BatchRequest):
    """Batch water prediction — accepts a list of input row dicts, returns predictions for all rows."""
    if water_model is None:
        raise HTTPException(status_code=503, detail="Water model not loaded")
    df    = pd.DataFrame(req.rows)[WATER_FEATURE_ORDER]
    preds = water_model.predict(df)
    return {
        "rows": req.rows,
        "predictions": {
            t: [round(float(preds[i, j]), 6) for i in range(len(req.rows))]
            for j, t in enumerate(WATER_TARGET_NAMES)
        }
    }

# ── Met file parsing ──────────────────────────────────────────────────────────

@app.post("/api/parse_met", response_model=ParseMetResponse)
async def parse_met(
    file:                 UploadFile      = File(...),
    lat:                  float           = Form(...),
    lon:                  float           = Form(...),
    day_min:              int             = Form(default=1),
    day_max:              int             = Form(default=366),
    sunrise_override_hr:  Optional[float] = Form(default=None),
    sunset_override_hr:   Optional[float] = Form(default=None),
    extend_hours:         bool            = Form(default=False),
):
    """
    Parse a climate met CSV and return rows mapped to model features.

    Met file columns used
    ---------------------
    hour                → hourOfDay
    temp                → Ta
    rh                  → rh  (0-1 expected; divided by 100 if >1.5 detected)
    totalRadiation      → incomingRadiation
    wind                → wind
    soilWater_potential → soilWaterPotential  (first comma-separated depth layer)
    day + hour + lat/lon → azimuth, solarElevation  (Spencer 1971 via solar.py)

    Rows with year == 1900 are excluded (known spurious sentinel).
    Rows outside [day_min, day_max] are excluded.

    By default, rows with hourOfDay outside the model's trained range
    [9, 16] are excluded — the model was only ever trained on that window,
    so predictions outside it are extrapolation. Passing extend_hours=True
    keeps those rows instead of dropping them; each is flagged
    outsideTrainedRange=True so the caller can warn that the prediction is
    an unreliable extrapolation, distinct from the (physically-justified)
    sunrise/sunset zeroing below.

    For each remaining row, sunrise/sunset (decimal hours) are computed
    from that row's day + lat/lon via solar.sunrise_sunset(), unless
    sunrise_override_hr/sunset_override_hr are supplied, in which case
    those fixed hours are used for every row instead. Rows whose hourOfDay
    falls outside [sunrise, sunset] are kept but have incomingRadiation and
    fDiffuseLight zeroed, and are flagged via beforeSunrise/afterSunset.

    The response rows contain only met-derived features. The frontend
    merges in slider values (fDiffuseLight, leafAreaPerPlant, rowOrientation,
    rowDistance, P:* params) before POSTing to /api/predict_batch/*.
    """
    warnings_out: list[str] = []

    # --- Read CSV ---
    content = await file.read()
    try:
        df = pd.read_csv(io.BytesIO(content))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Could not parse CSV: {e}")

    required_cols = {"year", "day", "hour", "temp", "rh",
                     "totalRadiation", "wind", "soilWater_potential"}
    missing = required_cols - set(df.columns)
    if missing:
        raise HTTPException(
            status_code=400,
            detail=f"Met file missing required columns: {sorted(missing)}"
        )

    # --- Filter spurious year=1900 rows ---
    n_before = len(df)
    df = df[df["year"] != 1900].copy()
    n_spurious = n_before - len(df)
    if n_spurious:
        warnings_out.append(f"Excluded {n_spurious} row(s) with year=1900.")

    # --- Apply day range filter ---
    df = df[(df["day"] >= day_min) & (df["day"] <= day_max)].copy()
    if df.empty:
        raise HTTPException(
            status_code=400,
            detail=f"No rows remain after filtering to day range {day_min}–{day_max}."
        )

    # --- hourOfDay vs. the model's trained range ---
    # Independent of physical daylight (see sunrise/sunset zeroing below).
    hour_min = LIGHT_FEATURE_RANGES['hourOfDay']['min']
    hour_max = LIGHT_FEATURE_RANGES['hourOfDay']['max']
    in_trained_range = (df["hour"] >= hour_min) & (df["hour"] <= hour_max)
    n_out_of_trained_range = int((~in_trained_range).sum())

    if extend_hours:
        # Keep out-of-range rows but flag them — predictions for these hours
        # are extrapolations beyond what the model was trained on.
        df["_outsideTrainedRange"] = ~in_trained_range
        if n_out_of_trained_range:
            warnings_out.append(
                f"{n_out_of_trained_range} row(s) have hourOfDay outside the model's "
                f"trained range [{hour_min}, {hour_max}] and are flagged outsideTrainedRange "
                f"— treat those predictions as unreliable extrapolations."
            )
    else:
        df = df[in_trained_range].copy()
        df["_outsideTrainedRange"] = False
        if n_out_of_trained_range:
            warnings_out.append(
                f"Excluded {n_out_of_trained_range} row(s) with hourOfDay outside "
                f"the model's trained range [{hour_min}, {hour_max}]."
            )
        if df.empty:
            raise HTTPException(
                status_code=400,
                detail=f"No rows remain after filtering hourOfDay to trained range [{hour_min}, {hour_max}]."
            )

    # --- RH normalisation ---
    if df["rh"].max() > 1.5:
        df["rh"] = df["rh"] / 100.0
        warnings_out.append("rh values appeared to be on a 0–100 scale; divided by 100.")

    # --- soilWaterPotential: first depth layer from comma-separated string ---
    def _first_swp(val):
        try:
            return float(str(val).split(",")[0])
        except (ValueError, AttributeError):
            return float("nan")

    df["soilWaterPotential"] = df["soilWater_potential"].apply(_first_swp)
    n_bad_swp = df["soilWaterPotential"].isna().sum()
    if n_bad_swp:
        warnings_out.append(
            f"{n_bad_swp} row(s) had unparseable soilWater_potential and were excluded."
        )
        df = df[df["soilWaterPotential"].notna()]

    # --- Solar geometry via Spencer (1971) ---
    use_override = sunrise_override_hr is not None and sunset_override_hr is not None
    elev_list, az_list, sunrise_list, sunset_list = [], [], [], []
    for _, row in df.iterrows():
        day_of_year = int(row["day"])
        elev, az = solar_position(
            day_of_year=day_of_year,
            hour_of_day=float(row["hour"]),
            lat_deg=lat,
            lon_deg=lon,
        )
        elev_list.append(elev)
        az_list.append(az)

        if use_override:
            sunrise_hr, sunset_hr = sunrise_override_hr, sunset_override_hr
        else:
            sunrise_hr, sunset_hr = sunrise_sunset(day_of_year, lat, lon)
            if sunrise_hr is None:
                # Polar day/night: no hour-angle solution. Fall back on this
                # row's own computed elevation to decide day vs. night.
                sunrise_hr, sunset_hr = (0.0, 24.0) if elev > 0 else (0.0, 0.0)
        sunrise_list.append(sunrise_hr)
        sunset_list.append(sunset_hr)

    df["solarElevation"] = elev_list
    df["azimuth"]        = az_list
    df["_sunriseHr"]     = sunrise_list
    df["_sunsetHr"]      = sunset_list

    # --- Assemble output rows ---
    rows_out = []
    n_zeroed = 0
    for _, row in df.iterrows():
        hour           = float(row["hour"])
        before_sunrise = hour < row["_sunriseHr"]
        after_sunset   = hour > row["_sunsetHr"]
        out_of_daylight = before_sunrise or after_sunset
        if out_of_daylight:
            n_zeroed += 1

        row_out = {
            "hourOfDay":          hour,
            "incomingRadiation":  0.0 if out_of_daylight else float(row["totalRadiation"]),
            "azimuth":            float(row["azimuth"]),
            "solarElevation":     float(row["solarElevation"]),
            "Ta":                 float(row["temp"]),
            "rh":                 float(row["rh"]),
            "wind":               float(row["wind"]),
            "soilWaterPotential": float(row["soilWaterPotential"]),
            # Passthrough for multi-day chart grouping in the frontend
            "year":               int(row["year"]),
            "day":                int(row["day"]),
            "beforeSunrise":      bool(before_sunrise),
            "afterSunset":        bool(after_sunset),
            "sunriseHr":          round(float(row["_sunriseHr"]), 3),
            "sunsetHr":           round(float(row["_sunsetHr"]), 3),
            "outsideTrainedRange": bool(row["_outsideTrainedRange"]),
        }
        if out_of_daylight:
            row_out["fDiffuseLight"] = 0.0
        rows_out.append(row_out)

    if n_zeroed:
        warnings_out.append(
            f"{n_zeroed} row(s) fell outside sunrise/sunset and had "
            f"incomingRadiation/fDiffuseLight set to 0 (flagged beforeSunrise/afterSunset)."
        )

    return ParseMetResponse(
        rows=rows_out,
        row_count=len(rows_out),
        years=sorted(int(y) for y in df["year"].unique()),
        day_min=int(df["day"].min()),
        day_max=int(df["day"].max()),
        warnings=warnings_out,
    )

# ── Static files ──────────────────────────────────────────────────────────────
app.mount("/static", StaticFiles(directory="static"), name="static")
