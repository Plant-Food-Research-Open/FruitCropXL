#!/usr/bin/env python3
"""

It reads raw per-simulation CSVs, reconstructs missing cane_40/cane_50 metadata,
applies the treatment filter, collapses each simulation's daily time series
to one summary row, and runs the ANOVA/F-value sensitivity analysis.

It writes the three CSVs that generate_figures.py (the plotting-only script
from the same repo) reads back in:
    <outdir>/daily_timeseries_with_treatment.csv
    <outdir>/per_simulation_df_with_treatment.csv
    <outdir>/f_values_sensitivity_analysis_results_with_inputs.csv

CONFIGURATION
-------------
Folders, paths, targets and the treatment filter live in config.json
(see --config below), not hard-coded in this file. CLI flags override
individual config values for one-off runs.

USAGE
-----
    python run_sensitivity_analysis.py --vine-type spur
    python run_sensitivity_analysis.py --vine-type cane --outdir outdir/cane
    python run_sensitivity_analysis.py --vine-type spur --config my_config.json
    python run_sensitivity_analysis.py --vine-type cane --base-path /some/other/path

Requires: pandas, numpy, matplotlib, statsmodels
"""

from __future__ import annotations

import argparse
import copy
import json
import os
from glob import glob
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import statsmodels.api as sm
from statsmodels.formula.api import ols

# ---------------------------------------------------------------------------
# Defaults (used if no --config file is given, and as a base that a config
# file's values are merged into)
# ---------------------------------------------------------------------------
DEFAULT_CONFIG = {
    "base_path": "/output/FruitCropXL/HGU-sim/",
    "field_space_csv": "field-space_total.csv",
    "vine_folders": {
        "spur": ["spur_70", "spur_50", "spur_90", "spur_110"],
        "cane": ["cane_20", "cane_30", "cane_40", "cane_50"],
    },
    "cane_reconstruct_crop_loads": [320, 400],
    "cane_known_good_crop_loads": [160, 240],
    "input_cols": ["Ta", "cca", "totalFruitNumber", "incomingRadiation", "leafArea"],
    "plant_targets": [
        "biomassPlant",
        "biomassFruit",
        "biomassInternode",
        "internodeNSC",
        "fraction_fruitUnloading",
        "fraction_structuralRootUnloading",
        "fraction_internodeUnloading",
        "phloemSugarConcentration",
        "harvest_index",
    ],
    "fruit_targets": ["meanFruitDW", "meanFruitSc"],
    "predictors": "(cca + totalFruitNumber + leafArea + Ta + incomingRadiation)**2",
    "filter": {
        "Tmax": [25, 30],
        "Tmin": [15, 20],
        "cca": [400, 650, 900, 1200],
        "inputPAR": [400, 600, 1000, 1200],
        "ENDING_LEAF_NUMBER": [3, 6, 9, 12],
    },
    "apply_filter": True,
    "save_combined_csv": False,
}

mpl.rcParams.update(
    {
        "font.family": "serif",
        "font.size": 11,
        "axes.labelsize": 11,
        "axes.titlesize": 11,
        "legend.fontsize": 9,
        "xtick.labelsize": 9,
        "ytick.labelsize": 9,
        "axes.linewidth": 0.8,
        "figure.dpi": 150,
    }
)


# ---------------------------------------------------------------------------
# 1. Raw data ingestion
# ---------------------------------------------------------------------------
def extract_factors(folder_str: str) -> pd.Series:
    parts = folder_str.split("_")
    vine_type = parts[1]  # e.g. 'spur' or 'cane'
    return pd.Series([vine_type], index=["vineType"])


def load_raw_data(base_path, folders, field_space_csv):
    """Walk `folders` under `base_path`, join plant-level + mean-fruit CSVs
    per subfolder, daily-average them, and merge in field_space_csv metadata
    by uuid. Returns (big_df, spur_df, cane_df)."""
    combine_all_daily_average = []

    for folder in folders:
        folder_path = os.path.join(base_path, folder)
        subfolders = [d for d in glob(os.path.join(folder_path, "*")) if os.path.isdir(d)]

        for subfolder in subfolders:
            plant_csv_files = glob(os.path.join(subfolder, "plant-level-*.csv"))
            fruit_csv_files = glob(os.path.join(subfolder, "mean-fruit-*.csv"))
            if not plant_csv_files or not fruit_csv_files:
                continue

            df_plant = pd.read_csv(plant_csv_files[0])
            df_fruit = pd.read_csv(fruit_csv_files[0])

            day_temp = df_plant[df_plant["hourOfDay"].between(7, 20)]["Ta"].mean()
            night_temp = df_plant[~df_plant["hourOfDay"].between(7, 20)]["Ta"].mean()
            df_plant["harvest_index"] = df_plant["biomassFruit"] / df_plant["biomassPlant"]

            if np.isnan(day_temp) or np.isnan(night_temp):
                continue

            df_fruit_cleaned = df_fruit[df_fruit.columns.difference(df_plant.columns)]
            combined_df = df_plant.join(df_fruit_cleaned)
            combined_df["year"] = combined_df["year"].astype("category")
            combined_df = combined_df.drop(columns=["hourOfDay", "timestamp"])

            daily_avg_df = combined_df.groupby("dayOfYear", as_index=False).mean(numeric_only=True)
            daily_avg_df["dayTemperature"] = day_temp
            daily_avg_df["nightTemperature"] = night_temp
            daily_avg_df["folder"] = os.path.basename(subfolder)
            cols = ["folder"] + [c for c in daily_avg_df.columns if c != "folder"]
            daily_avg_df = daily_avg_df[cols]
            combine_all_daily_average.append(daily_avg_df)

    if not combine_all_daily_average:
        raise RuntimeError(
            f"No simulation data found under '{base_path}' for folders {folders}. "
            "Check --base-path / config['base_path'] and vine_folders."
        )

    big_df = pd.concat(combine_all_daily_average, axis=0, ignore_index=True)

    field_space_total_df = pd.read_csv(field_space_csv)
    big_df["uuid"] = big_df["folder"].str.extract(
        r"([0-9a-f]{8}_[0-9a-f]{4}_[0-9a-f]{4}_[0-9a-f]{4}_[0-9a-f]{12})"
    )
    big_df["uuid"] = big_df["uuid"].str.replace("_", "-", regex=False)
    big_df = field_space_total_df.merge(big_df, on="uuid", how="right")
    big_df = big_df.drop(columns=["cca_x"]).rename(columns={"cca_y": "cca"})
    big_df[["vineType"]] = big_df["folder"].apply(extract_factors)

    spur_df = big_df[big_df["vineType"] == "spur"].copy()
    cane_df = big_df[big_df["vineType"] == "cane"].copy()
    return big_df, spur_df, cane_df


# ---------------------------------------------------------------------------
# 2. Cane metadata reconstruction
# ---------------------------------------------------------------------------
def reconstruct_cane_metadata(cane_df, high_crop_loads=(320, 400), known_good_crop_loads=(160, 240)):
    """Reconstruct Tmax, Tmin, inputPAR and ENDING_LEAF_NUMBER for cane
    crop-load batches missing from field_space_csv, then recombine with the
    batches that already had complete metadata."""
    cane_high = cane_df[cane_df["totalFruitNumber"].isin(high_crop_loads)].copy()

    if cane_high.empty:
        # Nothing to reconstruct -- field_space_csv already covers everything.
        return cane_df[cane_df["totalFruitNumber"].isin(known_good_crop_loads)].copy()

    def infer_tmax(day_temp):
        return 25 if day_temp < 26 else 30

    def infer_tmin(night_temp):
        return 15 if night_temp < 19 else 20

    cane_high["Tmax"] = cane_high["dayTemperature"].apply(infer_tmax)
    cane_high["Tmin"] = cane_high["nightTemperature"].apply(infer_tmin)

    def infer_inputpar(mean_rad):
        if mean_rad < 340:
            return 400
        elif mean_rad < 550:
            return 600
        elif mean_rad < 765:
            return 1000
        else:
            return 1200

    uuid_par = cane_high.groupby("uuid")["incomingRadiation"].mean().apply(infer_inputpar)
    cane_high["inputPAR"] = cane_high["uuid"].map(uuid_par)

    final_leaf_high = (
        cane_high.sort_values(["uuid", "dayOfYear"]).groupby("uuid")["leafNumber"].last() / 8
    )
    cane_high["ENDING_LEAF_NUMBER"] = cane_high["uuid"].map(final_leaf_high)

    cane_known_good = cane_df[cane_df["totalFruitNumber"].isin(known_good_crop_loads)].copy()
    return pd.concat([cane_known_good, cane_high], ignore_index=True)


# ---------------------------------------------------------------------------
# 3. Per-simulation summarisation
# ---------------------------------------------------------------------------
def make_summarise_all_days(targets, input_cols, verbose=False):
    pct_change_cols = {"biomassPlant", "biomassFruit", "biomassInternode", "internodeNSC"}
    mean_cols = {
        "fraction_fruitUnloading",
        "fraction_structuralRootUnloading",
        "fraction_internodeUnloading",
        "phloemSugarConcentration",
    }
    final_value_cols = {"harvest_index", "meanFruitSc", "meanFruitDW"}

    def summarise_all_days(group):
        first = group.iloc[0]
        last = group.iloc[-1]
        delta_days = last["dayOfYear"] - first["dayOfYear"]

        if first["dayOfYear"] == 0:
            if verbose:
                print("Removed (first dayOfYear is 0):", group.name)
            return None
        if last["dayOfYear"] < 70:
            if verbose:
                print("Removed (last dayOfYear < 70):", group.name)
            return None
        if delta_days == 0:
            if verbose:
                print("Removed (no time difference):", group.name)
            return None

        result_dict = {}
        for col in targets:
            if col in pct_change_cols:
                initial_value = first[col]
                final_value = last[col]
                if pd.isna(initial_value) or initial_value == 0:
                    if verbose:
                        print(f"Removed ({col} initial is NaN or 0):", group.name)
                    return None
                result_dict[col] = (final_value - initial_value) / initial_value * 100
                result_dict[f"{col}_final"] = final_value
            elif col in mean_cols:
                result_dict[col] = group[col].mean()
            elif col in final_value_cols:
                result_dict[col] = group.iloc[-1][col]

        for col in input_cols + ["Tmax", "Tmin"]:
            result_dict[col] = group[col].mean()
        result_dict["ENDING_LEAF_NUMBER"] = group["ENDING_LEAF_NUMBER"].iloc[0]
        result_dict["vineType"] = group["vineType"].iloc[0]
        return pd.Series(result_dict)

    return summarise_all_days


def apply_filter_and_summarise(combined_df, filter_dict, apply_filter, targets, input_cols, outdir, verbose=False):
    if apply_filter:
        for col, values in filter_dict.items():
            combined_df = combined_df[combined_df[col].isin(values)]

    combined_df.to_csv(os.path.join(outdir, "daily_timeseries_with_treatment.csv"), index=False)

    df_sorted = combined_df.sort_values(by=["uuid", "dayOfYear"])
    summarise_fn = make_summarise_all_days(targets, input_cols, verbose=verbose)
    per_simulation_df = df_sorted.groupby("uuid").apply(summarise_fn)
    per_simulation_df = per_simulation_df.dropna(how="all").reset_index()
    per_simulation_df.to_csv(os.path.join(outdir, "per_simulation_df_with_treatment.csv"), index=False)
    return per_simulation_df


# ---------------------------------------------------------------------------
# 4. ANOVA / F-value sensitivity analysis
# ---------------------------------------------------------------------------
def run_anova(per_simulation_df, targets, predictors, outdir, vine_type, make_diagnostic_plot=True):
    all_anova_tables = []
    models = {}

    if make_diagnostic_plot:
        ncols = 2
        nrows = (len(targets) + 1) // ncols
        fig, axes = plt.subplots(nrows=nrows, ncols=ncols, figsize=(12, 3 * nrows))
        axes = axes.flatten()

    for i, target in enumerate(targets):
        formula = f"{target} ~ {predictors}"
        model = ols(formula, data=per_simulation_df).fit()
        models[target] = model

        anova_table = sm.stats.anova_lm(model, typ=2).reset_index()
        anova_table["Partial_Eta2"] = anova_table["F"] * anova_table["df"] / (
            anova_table["F"] * anova_table["df"] + model.df_resid
        )
        anova_table = anova_table[anova_table["index"] != "Residual"]
        anova_table["Target"] = target
        top5 = anova_table.sort_values("F", ascending=False).head(5)
        all_anova_tables.append(top5)

        if make_diagnostic_plot:
            ax = axes[i]
            bars = ax.barh(top5["index"], top5["F"], color="skyblue")
            ax.set_title(target, fontsize=12, pad=10)
            ax.invert_yaxis()
            ax.set_xlabel("F-value", fontsize=10)
            for bar, eta2 in zip(bars, top5["Partial_Eta2"]):
                width = bar.get_width()
                ax.text(
                    width * 1.02,
                    bar.get_y() + bar.get_height() / 2,
                    f"eta_p2 = {eta2:.3f}",
                    va="center",
                    ha="left",
                    fontsize=9,
                    color="black",
                )

    combined_anova = pd.concat(all_anova_tables, ignore_index=True)
    combined_anova = combined_anova.sort_values(["Target", "F"], ascending=[True, False])
    combined_anova = combined_anova[["Target", "index", "df", "F", "PR(>F)", "Partial_Eta2"]]
    combined_anova.to_csv(
        os.path.join(outdir, "f_values_sensitivity_analysis_results_with_inputs.csv"), index=False
    )

    if make_diagnostic_plot:
        for j in range(len(targets), len(axes)):
            fig.delaxes(axes[j])
        plt.tight_layout()
        plt.suptitle(f"Top 5 Sensitivity Factors (ANOVA F-values) for {vine_type}", y=1.02, fontsize=16)
        fig.savefig(os.path.join(outdir, f"f_values_final_result_{vine_type}.png"), dpi=300, bbox_inches="tight")
        plt.close(fig)

    return combined_anova, models


# ---------------------------------------------------------------------------
# Config loading
# ---------------------------------------------------------------------------
def find_default_config() -> str | None:
    """If --config isn't given, look for config.json next to this script,
    then in the current working directory, in that order. Returns the path
    found, or None to fall back to the built-in DEFAULT_CONFIG."""
    script_dir = Path(__file__).resolve().parent
    candidates = [script_dir / "config.json", script_dir.parent / "config.json", Path("config.json")]
    for candidate in candidates:
        if candidate.is_file():
            return str(candidate)
    return None


def load_config(config_path: str | None) -> tuple[dict, str | None]:
    """Returns (config, path_actually_used). path_actually_used is None if
    running on the built-in DEFAULT_CONFIG with nothing found on disk."""
    if not config_path:
        config_path = find_default_config()

    cfg = copy.deepcopy(DEFAULT_CONFIG)
    if config_path:
        with open(config_path) as f:
            user_cfg = json.load(f)
        cfg.update(user_cfg)  # top-level keys in the user config fully replace the defaults
    return cfg, config_path


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
def build_arg_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Run the grapevine sensitivity-analysis data pipeline for one vine type.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--vine-type", choices=["spur", "cane"], required=True)
    parser.add_argument("--outdir", default=None, help="Defaults to outdir/<vine-type>")
    parser.add_argument(
        "--config",
        default=None,
        help=(
            "Path to a JSON config file. If omitted, auto-discovers config.json "
            "next to this script, one directory up (repo root), or in the cwd, "
            "in that order; falls back to built-in defaults if none is found."
        ),
    )
    parser.add_argument("--base-path", default=None, help="Override config['base_path']")
    parser.add_argument("--field-space-csv", default=None, help="Override config['field_space_csv']")
    parser.add_argument("--no-filter", action="store_true", help="Skip the treatment filter")
    parser.add_argument("--no-diagnostic-plot", action="store_true", help="Skip the per-target F-value PNG")
    parser.add_argument("--save-combined-csv", action="store_true", help="Also save the raw combined_df to CSV")
    parser.add_argument("--verbose", action="store_true", help="Print rows dropped during summarisation")
    return parser


def main(argv=None):
    args = build_arg_parser().parse_args(argv)
    cfg, config_path_used = load_config(args.config)
    if config_path_used:
        print(f"Using config: {config_path_used}")
    else:
        print("No config.json found next to the script or in the cwd -- using built-in defaults.")

    if args.base_path:
        cfg["base_path"] = args.base_path
    if args.field_space_csv:
        cfg["field_space_csv"] = args.field_space_csv
    if args.save_combined_csv:
        cfg["save_combined_csv"] = True

    apply_filter = cfg["apply_filter"] and not args.no_filter
    outdir = args.outdir or os.path.join("outdir", args.vine_type)
    os.makedirs(outdir, exist_ok=True)

    folders = cfg["vine_folders"][args.vine_type]
    targets = cfg["plant_targets"] + cfg["fruit_targets"]

    print(f"Loading raw simulation data for vine_type='{args.vine_type}' from {cfg['base_path']} ...")
    _, spur_df, cane_df = load_raw_data(cfg["base_path"], folders, cfg["field_space_csv"])

    if args.vine_type == "spur":
        combined_df = spur_df
    else:
        combined_df = reconstruct_cane_metadata(
            cane_df,
            tuple(cfg["cane_reconstruct_crop_loads"]),
            tuple(cfg["cane_known_good_crop_loads"]),
        )

    if cfg["save_combined_csv"]:
        combined_df.to_csv(os.path.join(outdir, f"{args.vine_type}_df.csv"), index=False)

    per_simulation_df = apply_filter_and_summarise(
        combined_df, cfg["filter"], apply_filter, targets, cfg["input_cols"], outdir, verbose=args.verbose
    )
    print(f"{args.vine_type}: {len(per_simulation_df)} simulations retained after filtering/summarising")
    print("Crop-load levels present:", sorted(per_simulation_df["totalFruitNumber"].unique()))

    run_anova(
        per_simulation_df,
        targets,
        cfg["predictors"],
        outdir,
        args.vine_type,
        make_diagnostic_plot=not args.no_diagnostic_plot,
    )
    print(f"Done. Wrote daily_timeseries_with_treatment.csv, per_simulation_df_with_treatment.csv, "
          f"and f_values_sensitivity_analysis_results_with_inputs.csv to {outdir}/")


if __name__ == "__main__":
    main()