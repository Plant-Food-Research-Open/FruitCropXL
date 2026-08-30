# ── Build stage ──────────────────────────────────────────────────────────────
# Installs Python deps into an isolated prefix so the runtime stage never
# needs pip/build tooling at all.
FROM python:3.10-slim AS builder

WORKDIR /install

COPY requirements-serve.txt .
RUN pip install --no-cache-dir --prefix=/install/deps -r requirements-serve.txt

# ── Runtime stage ────────────────────────────────────────────────────────────
FROM python:3.10-slim AS runtime

# Non-root user — good practice generally, and required by most k8s
# PodSecurity policies if/when this moves to the deferred k8s deployment.
RUN useradd --create-home --uid 1000 appuser

WORKDIR /app

# Installed packages from the build stage
COPY --from=builder /install/deps /usr/local

# App code
COPY main.py solar.py ./
COPY static/index.html static/index.html

# Baked-in champion models (produced by export_models.py — see that
# script's docstring for how to regenerate these).
#   models/light/  and  models/water/  — each an MLflow "local model"
#   directory (MLmodel + model artifact), loadable fully offline.
COPY models/ models/

# Point the app at the local baked-in models instead of the MLflow
# registry. Override at `docker run` time if you ever want to point
# back at the live registry instead (e.g. -e LIGHT_MODEL_URI=models:/...).
ENV LIGHT_MODEL_URI=/app/models/light \
    WATER_MODEL_URI=/app/models/water \
    PYTHONUNBUFFERED=1

RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

# /api/meta only succeeds once both models are loaded in the lifespan
# hook, so it doubles as a "the app is actually ready" healthcheck.
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request,sys; \
    sys.exit(0 if urllib.request.urlopen('http://localhost:8000/api/meta', timeout=3).status == 200 else 1)"

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
