#!/usr/bin/env python3
"""
Plot leaf-inspection diagnostics from a FruitCropXL scenario output folder.

Outputs:
  - leaf_area_timeseries.png
  - fw_fc_timeseries.png

Usage examples:
  python3 Model_visualization/plot_leaf_inspect.py --output-dir Model_output/dynamicApple_leafInspect
  python3 Model_visualization/plot_leaf_inspect.py --output-dir Model_output/dynamicApple_leafInspect --save-dir Model_output/dynamicApple_leafInspect/plots
"""

from __future__ import annotations

import argparse
import csv
import sys
from collections import OrderedDict
from pathlib import Path


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Plot leaf-area and fw/fc diagnostics.")
    p.add_argument(
        "--output-dir",
        required=True,
        help="Scenario output directory (e.g. Model_output/dynamicApple_leafInspect)",
    )
    p.add_argument(
        "--save-dir",
        default=None,
        help="Directory to save plots (default: <output-dir>/plots)",
    )
    return p.parse_args()


def require_matplotlib():
    try:
        import matplotlib

        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except Exception as exc:
        print("ERROR: matplotlib is required to generate plots:", exc, file=sys.stderr)
        sys.exit(2)
    return plt


def read_csv_rows(path: Path):
    with path.open("r", newline="") as f:
        reader = csv.DictReader(f)
        return list(reader)


def to_float(value, default=None):
    if value is None:
        return default
    try:
        if value == "":
            return default
        return float(value)
    except Exception:
        return default


def find_latest(output_dir: Path, pattern: str) -> Path | None:
    matches = sorted(output_dir.glob(pattern))
    return matches[-1] if matches else None


def series_from_rows(rows, key):
    vals = []
    for r in rows:
        vals.append(to_float(r.get(key), None))
    return vals


def plot_leaf_area(plt, plant_csv: Path | None, field_csv: Path | None, save_path: Path):
    fig, axes = plt.subplots(2, 1, figsize=(12, 8), sharex=False)
    fig.suptitle("Leaf Growth / Canopy Area Diagnostics")

    plotted_any = False

    if plant_csv and plant_csv.exists():
        plant_rows = read_csv_rows(plant_csv)
        x = list(range(len(plant_rows)))
        axes[0].plot(x, series_from_rows(plant_rows, "leafArea"), label="plant leafArea (m2/tree)")
        axes[0].plot(x, series_from_rows(plant_rows, "biomassLeaf"), label="plant biomassLeaf")
        axes[1].plot(x, series_from_rows(plant_rows, "leafNumber"), label="plant leafNumber")
        axes[1].plot(x, series_from_rows(plant_rows, "cumLAI_1"), label="cumLAI_1")
        axes[1].plot(x, series_from_rows(plant_rows, "cumLAI_2"), label="cumLAI_2")
        axes[1].plot(x, series_from_rows(plant_rows, "cumLAI_3"), label="cumLAI_3")
        axes[1].plot(x, series_from_rows(plant_rows, "cumLAI_4"), label="cumLAI_4")
        plotted_any = True

    if field_csv and field_csv.exists():
        field_rows = read_csv_rows(field_csv)
        x = list(range(len(field_rows)))
        axes[0].plot(x, series_from_rows(field_rows, "leafAreaPerPlant"), label="field leafAreaPerPlant (m2/tree)")
        axes[0].plot(x, series_from_rows(field_rows, "LAI"), label="field LAI")
        plotted_any = True

    if not plotted_any:
        plt.close(fig)
        return False

    axes[0].set_ylabel("Leaf area / biomass")
    axes[1].set_ylabel("Leaf count / cumLAI")
    axes[1].set_xlabel("Sequential output row")
    axes[0].grid(True, alpha=0.3)
    axes[1].grid(True, alpha=0.3)
    axes[0].legend(loc="best", fontsize=9)
    axes[1].legend(loc="best", fontsize=9)
    fig.tight_layout()
    fig.savefig(save_path, dpi=150)
    plt.close(fig)
    return True


def aggregate_debug_rows(debug_rows):
    # Aggregate per-step for growing leaves only, with a fallback to all rows if none are growing.
    groups = OrderedDict()
    for row in debug_rows:
        step_val = to_float(row.get("step"), None)
        if step_val is None:
            continue
        step = int(step_val)
        is_growing = int(to_float(row.get("isGrowing"), 0) or 0)
        entry = groups.get(step)
        if entry is None:
            entry = {
                "step": step,
                "n_all": 0,
                "n_growing": 0,
                "sum_fw_all": 0.0,
                "sum_fc_all": 0.0,
                "sum_dA_pot_all": 0.0,
                "sum_dA_w_all": 0.0,
                "sum_dA_final_all": 0.0,
                "sum_area_all": 0.0,
                "sum_fw_g": 0.0,
                "sum_fc_g": 0.0,
                "sum_dA_pot_g": 0.0,
                "sum_dA_w_g": 0.0,
                "sum_dA_final_g": 0.0,
                "sum_area_g": 0.0,
            }
            groups[step] = entry

        fw = to_float(row.get("fw"), 0.0) or 0.0
        fc = to_float(row.get("fc"), 0.0) or 0.0
        dA_pot = to_float(row.get("dA_pot"), 0.0) or 0.0
        dA_w = to_float(row.get("dA_w"), 0.0) or 0.0
        dA_final = to_float(row.get("dA_final"), 0.0) or 0.0
        area = to_float(row.get("area"), 0.0) or 0.0

        entry["n_all"] += 1
        entry["sum_fw_all"] += fw
        entry["sum_fc_all"] += fc
        entry["sum_dA_pot_all"] += dA_pot
        entry["sum_dA_w_all"] += dA_w
        entry["sum_dA_final_all"] += dA_final
        entry["sum_area_all"] += area

        if is_growing == 1:
            entry["n_growing"] += 1
            entry["sum_fw_g"] += fw
            entry["sum_fc_g"] += fc
            entry["sum_dA_pot_g"] += dA_pot
            entry["sum_dA_w_g"] += dA_w
            entry["sum_dA_final_g"] += dA_final
            entry["sum_area_g"] += area

    out = []
    for step in sorted(groups.keys()):
        g = groups[step]
        use_growing = g["n_growing"] > 0
        n = g["n_growing"] if use_growing else g["n_all"]
        if n <= 0:
            continue
        suffix = "_g" if use_growing else "_all"
        out.append(
            {
                "step": g["step"],
                "n_rows": g["n_all"],
                "n_growing": g["n_growing"],
                "fw_mean": g["sum_fw" + suffix] / n,
                "fc_mean": g["sum_fc" + suffix] / n,
                "dA_pot_mean": g["sum_dA_pot" + suffix] / n,
                "dA_w_mean": g["sum_dA_w" + suffix] / n,
                "dA_final_mean": g["sum_dA_final" + suffix] / n,
                "area_mean": g["sum_area" + suffix] / n,
            }
        )
    return out


def plot_fw_fc(plt, debug_csv: Path | None, save_path: Path):
    if not debug_csv or not debug_csv.exists():
        return False

    debug_rows = read_csv_rows(debug_csv)
    agg = aggregate_debug_rows(debug_rows)
    if not agg:
        return False

    x = [r["step"] for r in agg]
    fw = [r["fw_mean"] for r in agg]
    fc = [r["fc_mean"] for r in agg]
    dA_pot = [r["dA_pot_mean"] for r in agg]
    dA_w = [r["dA_w_mean"] for r in agg]
    dA_final = [r["dA_final_mean"] for r in agg]
    n_g = [r["n_growing"] for r in agg]

    fig, axes = plt.subplots(3, 1, figsize=(12, 10), sharex=True)
    fig.suptitle("Leaf Expansion Debug (Aggregated per sampled step)")

    axes[0].plot(x, fw, label="fw mean")
    axes[0].plot(x, fc, label="fc mean")
    axes[0].plot(x, [min(a, b) for a, b in zip(fw, fc)], label="min(fw,fc)")
    axes[0].set_ylabel("Limiter (-)")
    axes[0].set_ylim(-0.05, 1.05)
    axes[0].grid(True, alpha=0.3)
    axes[0].legend(loc="best")

    axes[1].plot(x, dA_pot, label="dA_pot mean")
    axes[1].plot(x, dA_w, label="dA_w mean")
    axes[1].plot(x, dA_final, label="dA_final mean")
    axes[1].set_ylabel("Area increment (m2/step)")
    axes[1].grid(True, alpha=0.3)
    axes[1].legend(loc="best")

    axes[2].plot(x, n_g, label="growing leaves sampled")
    axes[2].set_ylabel("Count")
    axes[2].set_xlabel("Simulation step")
    axes[2].grid(True, alpha=0.3)
    axes[2].legend(loc="best")

    fig.tight_layout()
    fig.savefig(save_path, dpi=150)
    plt.close(fig)
    return True


def main():
    args = parse_args()
    output_dir = Path(args.output_dir).resolve()
    if not output_dir.exists():
        print("ERROR: output directory not found:", output_dir, file=sys.stderr)
        sys.exit(1)

    save_dir = Path(args.save_dir).resolve() if args.save_dir else (output_dir / "plots")
    save_dir.mkdir(parents=True, exist_ok=True)

    plant_csv = find_latest(output_dir, "plant-level-*.csv")
    field_csv = find_latest(output_dir, "field-level-*.csv")
    debug_csv = output_dir / "debug" / "leafExpansion_debug.csv"

    print("Using output dir :", output_dir)
    print("Plant CSV       :", plant_csv if plant_csv else "not found")
    print("Field CSV       :", field_csv if field_csv else "not found")
    print("Leaf debug CSV  :", debug_csv if debug_csv.exists() else "not found")

    plt = require_matplotlib()

    leaf_area_png = save_dir / "leaf_area_timeseries.png"
    fw_fc_png = save_dir / "fw_fc_timeseries.png"

    ok_leaf = plot_leaf_area(plt, plant_csv, field_csv, leaf_area_png)
    ok_fwfc = plot_fw_fc(plt, debug_csv if debug_csv.exists() else None, fw_fc_png)

    if ok_leaf:
        print("Wrote:", leaf_area_png)
    else:
        print("Skipped leaf-area plot (required CSVs not found).")

    if ok_fwfc:
        print("Wrote:", fw_fc_png)
    else:
        print("Skipped fw/fc plot (leaf expansion debug CSV not found or empty).")


if __name__ == "__main__":
    main()
