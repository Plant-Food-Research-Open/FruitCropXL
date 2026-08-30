#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from datetime import datetime
import argparse
import os
from pathlib import Path
import numpy as np
import pandas as pd

# headless plotting
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401

matplotlib.rcParams.update({
    "font.family": "serif",
    "font.size": 13,
    "axes.labelsize": 13,
    "axes.titlesize": 13,
    "legend.fontsize": 11,
    "xtick.labelsize": 11,
    "ytick.labelsize": 11,
    "axes.linewidth": 0.8,
    "figure.dpi": 300,
})

# your existing internode plotters (PNG + HTML)
from func import (
    plot_internode_waterPotential,
    plot_internode_waterPotential_interactive,
)

# ============================ Units & helpers ============================

def unit_label_for_series(name: str) -> str:
    n = (name or "").lower()
    if n in ("waterpotential", "water_potential"):
        return "MPa"
    if n in ("cp", "sugar", "sugarconcentration", "sugar_concentration"):
        return "g sugar cm⁻³ phloem sap"
    if n in ("sugarconcentration_fruit", "sugar_concentration_fruit"):
        return "g/cm³"
    if n == "cpt":
        return "model unit"
    if n in ("dryweight_g", "freshweight_g"):
        return "g"
    if n in ("fabs", "leaf_fabs"):
        return "fraction"
    if n in ("rangexy_m", "rangexyz_m", "fruitrange_xy_m", "fruitrange_xyz_m"):
        return "m"
    return ""

def parse_bool(x, default=True):
    if x is None:
        return bool(default)
    s = str(x).strip().lower()
    if s in ("1", "true", "t", "yes", "y", "on"):
        return True
    if s in ("0", "false", "f", "no", "n", "off"):
        return False
    return bool(default)

def histogram_bar(values, title, save_path, xlabel="", bins=30):
    vals = np.asarray(values, dtype=float)
    vals = vals[np.isfinite(vals)]
    plt.figure(figsize=(7, 4.5))
    plt.hist(vals, bins=bins, edgecolor="black")
    plt.title(title)
    if xlabel:
        plt.xlabel(xlabel)
    plt.ylabel("Count")
    plt.tight_layout()
    plt.savefig(save_path, dpi=160)
    plt.close()

def plot_3d_scatter(df, xcol, ycol, zcol, vcol, title, save_path_png, unit=""):
    for c in (xcol, ycol, zcol, vcol):
        if c not in df.columns:
            raise ValueError(f"Missing column '{c}' for 3D plot.")
    xyz = df[[xcol, ycol, zcol]].astype(float).values
    vals = df[vcol].astype(float).values

    fig = plt.figure(figsize=(7, 6))
    ax = fig.add_subplot(111, projection='3d')
    sc = ax.scatter(xyz[:, 0], xyz[:, 1], xyz[:, 2], c=vals, s=8)
    cb = fig.colorbar(sc, ax=ax, fraction=0.03, pad=0.08)
    lab = f"{vcol}" + (f" ({unit})" if unit else "")
    cb.set_label(lab)
    ax.set_xlabel(xcol)
    ax.set_ylabel(ycol)
    ax.set_zlabel(zcol)
    ax.set_title(title)
    plt.tight_layout()
    plt.savefig(save_path_png, dpi=160)
    plt.close()

def parse_xyz(arg_str, default=("x","y","z")):
    if not arg_str:
        return default
    parts = [p.strip() for p in arg_str.split(",")]
    if len(parts) != 3:
        raise ValueError(f"XYZ must have 3 comma-separated names, got: {arg_str}")
    return tuple(parts)

def parse_center_xyz(arg_str, default=(0.0, 0.0, 0.0)):
    if not arg_str:
        return default
    parts = [p.strip() for p in str(arg_str).split(",")]
    if len(parts) != 3:
        raise ValueError(f"Center must have 3 comma-separated values, got: {arg_str}")
    try:
        return (float(parts[0]), float(parts[1]), float(parts[2]))
    except ValueError as exc:
        raise ValueError(f"Center coordinates must be numeric, got: {arg_str}") from exc

# ============================ DOY + hour slicer ============================

def _slice_to_doy_and_hour(df, doy=None, hour=None, df_name=""):
    """
    Slice df to a specific day-of-year and hour.
    Prefers 'dayOfYear'/'hourOfDay'; otherwise derives them from 'timestamp'.
    If no exact DOY/hour exists, falls back to nearest and prints what was used.
    If multiple timestamps remain, keeps the latest one.
    """
    work = df.copy()

    has_ts = 'timestamp' in work.columns
    if has_ts:
        work['timestamp'] = pd.to_datetime(work['timestamp'], errors='coerce')
        if 'dayOfYear' not in work.columns:
            work['dayOfYear'] = work['timestamp'].dt.dayofyear
        if 'hourOfDay' not in work.columns:
            work['hourOfDay'] = work['timestamp'].dt.hour
    else:
        if doy is not None and 'dayOfYear' not in work.columns:
            raise ValueError(f"{df_name}: need 'dayOfYear' or 'timestamp' to select DOY={doy}.")
        if hour is not None and 'hourOfDay' not in work.columns:
            raise ValueError(f"{df_name}: need 'hourOfDay' or 'timestamp' to select hour={hour}.")

    # DOY slice
    if doy is not None:
        doy_series = pd.to_numeric(work['dayOfYear'], errors='coerce')
        exact = work[doy_series == int(doy)]
        if exact.empty:
            diff = (doy_series.astype(float) - float(doy)).abs()
            min_diff = diff.min()
            work = work[diff == min_diff]
            used = sorted(set(pd.to_numeric(work['dayOfYear'], errors='coerce').dropna().astype(int)))
            print(f"[{df_name}] No exact DOY={doy}. Using nearest DOY(s) {used} (Δ={float(min_diff)}).")
        else:
            work = exact

    # Hour slice
    if hour is not None:
        hr_series = pd.to_numeric(work['hourOfDay'], errors='coerce')
        exact = work[hr_series == int(hour)]
        if exact.empty:
            diff = (hr_series.astype(float) - float(hour)).abs()
            min_diff = diff.min()
            work = work[diff == min_diff]
            used = sorted(set(pd.to_numeric(work['hourOfDay'], errors='coerce').dropna().astype(int)))
            print(f"[{df_name}] No exact hour={hour}. Using nearest hour(s) {used} (Δ={float(min_diff)}).")
        else:
            work = exact

    # keep latest timestamp if present
    if has_ts and work['timestamp'].notna().any():
        latest_ts = work['timestamp'].max()
        work = work[work['timestamp'] == latest_ts].copy()
        print(f"[{df_name}] Sliced at DOY={doy if doy is not None else 'latest'}, "
              f"hour={hour if hour is not None else 'any'}, timestamp={latest_ts}, n={len(work)}")
    else:
        print(f"[{df_name}] Sliced at DOY={doy if doy is not None else 'any'}, "
              f"hour={hour if hour is not None else 'any'}, n={len(work)}")

    return work

# ============================ Loaders ============================

def load_csv(csv_path, df_name):
    if not csv_path:
        raise FileNotFoundError(f"{df_name} CSV not provided.")
    if not os.path.exists(csv_path):
        raise FileNotFoundError(f"{df_name} CSV not found: {csv_path}")
    df = pd.read_csv(csv_path)
    if 'timestamp' in df.columns:
        df['timestamp'] = pd.to_datetime(df['timestamp'], errors='coerce')
    return df

def load_internodes(args):
    if not args.internode_csv:
        raise FileNotFoundError("Internode CSV not provided.")
    if not os.path.exists(args.internode_csv):
        raise FileNotFoundError(f"Internode CSV not found: {args.internode_csv}")
    header = pd.read_csv(args.internode_csv, nrows=0).columns.tolist()
    requested_xyz = list(parse_xyz(args.internode_xyz))
    wanted = {
        'timestamp', 'dayOfYear', 'hourOfDay',
        'waterPotential', 'sugarConcentration', 'cpb', 'cpt',
        'x', 'y', 'z', 'endX', 'endY', 'endZ', 'nodeID', 'parentID',
        *requested_xyz
    }
    usecols = [col for col in header if col in wanted]
    df = pd.read_csv(args.internode_csv, usecols=usecols)
    if 'timestamp' in df.columns:
        df['timestamp'] = pd.to_datetime(df['timestamp'], errors='coerce')
    df = _slice_to_doy_and_hour(df, args.snapshot_doy, args.snapshot_hour, "internodes")
    # Keep raw carbon-potential fields distinct from derived Cp/sugar concentration.
    if 'sugarConcentration' in df.columns:
        df['Cp'] = pd.to_numeric(df['sugarConcentration'], errors='coerce')
        df['sugarConcentration'] = df['Cp']
        cp_source = 'sugarConcentration'
        cp_conversion = 'C_sug,o = sugarConcentration'
    elif 'cpb' in df.columns or 'cpt' in df.columns:
        cp_col = 'cpb' if 'cpb' in df.columns else 'cpt'
        carbon_potential = pd.to_numeric(df[cp_col], errors='coerce')
        carbon_potential = carbon_potential.where(carbon_potential >= 0)
        carbon_fraction_sorbitol = (6 * 12.011) / (6 * 12.011 + 14 * 1.008 + 6 * 15.999)
        carbon_fraction_sucrose = (12 * 12.011) / (12 * 12.011 + 22 * 1.008 + 11 * 15.999)
        carbon_fraction_apple_phloem = 0.75 * carbon_fraction_sorbitol + 0.25 * carbon_fraction_sucrose
        df['Cp'] = np.sqrt(2.0 * carbon_potential) / carbon_fraction_apple_phloem
        df['sugarConcentration'] = df['Cp']
        cp_source = cp_col
        cp_conversion = (
            f'C_sug,o = sqrt(2 * {cp_col}) / '
            '(0.75 * fC_sorbitol + 0.25 * fC_sucrose)'
        )
    else:
        cp_source = ''
        cp_conversion = ''
    df.attrs['cp_source'] = cp_source
    df.attrs['cp_conversion'] = cp_conversion
    xcol, ycol, zcol = parse_xyz(args.internode_xyz)
    for c in (xcol, ycol, zcol):
        if c not in df.columns:
            raise ValueError(f"Internode CSV missing coordinate column '{c}'.")
    return df, (xcol, ycol, zcol)

def load_fruit(args):
    df = load_csv(args.fruit_csv, "Fruit")
    df = _slice_to_doy_and_hour(df, args.snapshot_doy, args.snapshot_hour, "fruit")
    # derived weights
    if 'biomass' not in df.columns or 'waterMass' not in df.columns:
        raise ValueError("Fruit CSV must contain 'biomass' and 'waterMass'.")
    df['dryWeight_g']   = df['biomass'].astype(float) / 1000.0
    df['freshWeight_g'] = (df['biomass'].astype(float) + df['waterMass'].astype(float)) / 1000.0
    if 'sugarConcentration_fruit' not in df.columns:
        raise ValueError("Fruit CSV missing 'sugarConcentration_fruit'.")
    xcol, ycol, zcol = parse_xyz(args.fruit_xyz)
    for c in (xcol, ycol, zcol):
        if c not in df.columns:
            raise ValueError(f"Fruit CSV missing coordinate column '{c}'.")
    return df, (xcol, ycol, zcol)

def load_leaf(args):
    df = load_csv(args.leaf_csv, "Leaf")
    df = _slice_to_doy_and_hour(df, args.snapshot_doy, args.snapshot_hour, "leaf")
    # pick fabs column
    metric = args.leaf_metric.strip() if args.leaf_metric else "fabs"
    if metric not in df.columns:
        # proxy fallback if metric==fabs
        if metric == "fabs":
            for cand in ("AlimActual", "Alim"):
                if cand in df.columns:
                    print(f"[leaf] Using proxy '{cand}' as fabs")
                    df['fabs'] = df[cand].astype(float)
                    break
        if "fabs" not in df.columns:
            raise ValueError(f"Leaf CSV missing requested column '{metric}' and no usable proxy found.")
    # ensure coords
    xcol, ycol, zcol = parse_xyz(args.leaf_xyz)
    for c in (xcol, ycol, zcol):
        if c not in df.columns:
            raise ValueError(f"Leaf CSV missing coordinate column '{c}'.")
    return df, (xcol, ycol, zcol), ("fabs" if metric=="fabs" else metric)

# ============================ Plot orchestrators ============================

def plot_nodes_metric(df, value_col, outdir, pretty_label,
                      plot_label="", interactive=True, histograms=True,
                      view_elev=30, view_azim=-60,
                      publication_style=False):
    unit = unit_label_for_series(value_col)
    label_with_unit = f"{pretty_label} ({unit})" if unit else pretty_label
    panel_title = None
    panel_subtitle = None
    colorbar_label = None
    if publication_style:
        if value_col == "waterPotential":
            panel_title = "(a) Spatial distribution of xylem water potential"
            colorbar_label = "Xylem water potential (MPa)"
        elif value_col == "Cp":
            panel_title = r"(b) Spatial distribution of $C_{\mathrm{sug,O}}$"
            colorbar_label = r"$C_{\mathrm{sug,o}}$ (g sugar cm$^{-3}$ phloem sap)"
    y = df[value_col].astype(float).to_numpy()
    png_path  = os.path.join(outdir, f'internodes_{value_col}_3d.png')
    svg_path = str(Path(png_path).with_suffix(".svg"))
    pdf_path = str(Path(png_path).with_suffix(".pdf"))
    html_path = os.path.join(outdir, f'internodes_{value_col}.html')
    hist_path = os.path.join(outdir, f'internodes_{value_col}_hist.png')
    plot_internode_waterPotential(
        df, y.squeeze(), png_path, label_with_unit, plot_label, '',
        view_elev=view_elev, view_azim=view_azim,
        panel_title=panel_title,
        panel_subtitle=panel_subtitle,
        colorbar_label=colorbar_label,
        also_svg=publication_style
    )
    written = [png_path]
    if publication_style:
        written.extend([svg_path, pdf_path])
    if interactive:
        plot_internode_waterPotential_interactive(
            df, y.squeeze(), html_path, label_with_unit, plot_label, '',
            view_elev=view_elev, view_azim=view_azim
        )
        written.append(html_path)
    if histograms:
        histogram_bar(y, f"{label_with_unit} distribution", hist_path, xlabel=label_with_unit)
        written.append(hist_path)
    print(f"[internodes] {value_col}: wrote\n  - " + "\n  - ".join(written))


def write_internode_diagnostics(df, metrics, args, outdir):
    if not metrics:
        return
    selected_timestamp = ""
    if 'timestamp' in df.columns and df['timestamp'].notna().any():
        selected_timestamp = str(pd.to_datetime(df['timestamp']).max())
    rows = []
    for metric in metrics:
        if metric not in df.columns:
            continue
        values = pd.to_numeric(df[metric], errors='coerce')
        finite = values[np.isfinite(values)]
        source_variable = metric
        conversion = 'none'
        if metric == 'Cp':
            source_variable = df.attrs.get('cp_source', '')
            conversion = df.attrs.get('cp_conversion', '')
        rows.append({
            'targets': args.targets,
            'plot_label': args.plot_label,
            'internode_csv': str(Path(args.internode_csv).resolve()),
            'requested_snapshot_doy': args.snapshot_doy,
            'requested_snapshot_hour': args.snapshot_hour,
            'selected_timestamp': selected_timestamp,
            'selected_dayOfYear': int(pd.to_datetime(selected_timestamp).dayofyear) if selected_timestamp else '',
            'selected_hourOfDay': int(pd.to_datetime(selected_timestamp).hour) if selected_timestamp else '',
            'n_internodes': len(df),
            'metric': metric,
            'source_variable': source_variable,
            'conversion': conversion,
            'unit': unit_label_for_series(metric),
            'minimum': float(finite.min()) if len(finite) else np.nan,
            'maximum': float(finite.max()) if len(finite) else np.nan,
        })
    if rows:
        path = os.path.join(outdir, 'internode_snapshot_diagnostics.csv')
        pd.DataFrame(rows).to_csv(path, index=False)
        print(f"[internodes] diagnostics: wrote\n  - {path}")


def write_internode_snapshot_plot_data(df, outdir):
    """Write the exact time-sliced internode table supplied to the 3D plots."""
    path = os.path.join(outdir, 'internode_snapshot_plot_data.csv')
    df.to_csv(path, index=False)
    print(f"[internodes] filtered plot data: wrote\n  - {path}")

def plot_fruit_metric(df, xyz, vcol, title_base, outdir):
    unit = unit_label_for_series(vcol if vcol.endswith("_g") else "sugarconcentration_fruit" if "sugar" in vcol else vcol)
    xcol, ycol, zcol = xyz
    png3d = os.path.join(outdir, f'fruit_{vcol}_3d.png')
    plot_3d_scatter(df, xcol, ycol, zcol, vcol,
                    f"{title_base} ({unit})" if unit else title_base,
                    png3d, unit=unit)
    hist = os.path.join(outdir, f'fruit_{vcol}_hist.png')
    histogram_bar(df[vcol], f"{title_base} distribution", hist,
                  xlabel=f"{vcol} ({unit})" if unit else vcol)
    print(f"[fruit] {vcol}: wrote\n  - {png3d}\n  - {hist}")

def plot_fruit_range_distribution(df, xyz, outdir, mode="xy", center=(0.0, 0.0, 0.0), bins=24):
    xcol, ycol, zcol = xyz
    for c in (xcol, ycol, zcol):
        if c not in df.columns:
            raise ValueError(f"Fruit CSV missing coordinate column '{c}'.")

    xc = pd.to_numeric(df[xcol], errors="coerce").astype(float).to_numpy()
    yc = pd.to_numeric(df[ycol], errors="coerce").astype(float).to_numpy()
    zc = pd.to_numeric(df[zcol], errors="coerce").astype(float).to_numpy()
    cx, cy, cz = center

    mode_norm = str(mode).strip().lower()
    if mode_norm == "xy":
        rr = np.sqrt((xc - cx) ** 2 + (yc - cy) ** 2)
        range_col = "rangeXY_m"
    elif mode_norm == "xyz":
        rr = np.sqrt((xc - cx) ** 2 + (yc - cy) ** 2 + (zc - cz) ** 2)
        range_col = "rangeXYZ_m"
    else:
        raise ValueError(f"Unsupported fruit_range_mode '{mode}'. Use 'xy' or 'xyz'.")

    keep = np.isfinite(rr) & np.isfinite(xc) & np.isfinite(yc) & np.isfinite(zc)
    if not np.any(keep):
        raise ValueError("No finite fruit coordinates available for range distribution.")

    plot_df = df.loc[keep].copy()
    plot_df[range_col] = rr[keep]

    pretty = "Fruit spatial range (XY)" if mode_norm == "xy" else "Fruit spatial range (XYZ)"
    png3d = os.path.join(outdir, f"fruit_{range_col}_3d.png")
    hist = os.path.join(outdir, f"fruit_{range_col}_hist.png")

    plot_3d_scatter(plot_df, xcol, ycol, zcol, range_col, f"{pretty} (m)", png3d, unit="m")
    histogram_bar(plot_df[range_col], f"{pretty} distribution", hist, xlabel="Range (m)", bins=bins)
    print(f"[fruit] {range_col}: wrote\n  - {png3d}\n  - {hist}")

def plot_leaf_metric(df, xyz, vcol, outdir, pretty="Leaf fabs"):
    unit = unit_label_for_series("fabs")
    xcol, ycol, zcol = xyz
    png3d = os.path.join(outdir, 'leaf_fabs_3d.png' if vcol=="fabs" else f'leaf_{vcol}_3d.png')
    plot_3d_scatter(df, xcol, ycol, zcol, vcol,
                    f"{pretty} ({unit})" if unit else pretty,
                    png3d, unit=unit)
    hist = os.path.join(outdir, 'leaf_fabs_hist.png' if vcol=="fabs" else f'leaf_{vcol}_hist.png')
    histogram_bar(df[vcol], f"{pretty} distribution", hist,
                  xlabel=f"{vcol} ({unit})" if unit else vcol)
    print(f"[leaf] {vcol}: wrote\n  - {png3d}\n  - {hist}")

# ============================ Main ============================

def main():
    NOW = datetime.now().strftime("%Y-%m-%d-%H-%M-%S")
    parser = argparse.ArgumentParser(description='Plot-only: control internodes, fruit, and leaf independently')
    # Choose which components to plot just by providing their CSVs.
    parser.add_argument('--internode_csv', type=str, default='',
                        help='Internode CSV path. If omitted, internode plots are skipped.')
    parser.add_argument('--fruit_csv', type=str, default='',
                        help='Fruit CSV path. If omitted, fruit plots are skipped.')
    parser.add_argument('--leaf_csv', type=str, default='',
                        help='Leaf CSV path. If omitted, leaf plots are skipped.')

    # Metrics to plot per component
    parser.add_argument('--internode_metrics', type=str, default='waterPotential,sugar',
                        help=('Comma-separated internode metrics: waterPotential, cp '
                              '(derived concentration), sugar (legacy alias), or cpt (raw model state).'))
    parser.add_argument('--fruit_metrics', type=str, default='dry,fresh,sugar',
                        help='Comma-separated metrics for fruit: dry, fresh, sugar.')
    parser.add_argument('--leaf_metric', type=str, default='fabs',
                        help='Leaf metric column name; if "fabs" missing, tries AlimActual, then Alim.')

    # Optional coordinate column names per file
    parser.add_argument('--internode_xyz', type=str, default='x,y,z', help='XYZ columns for internodes.')
    parser.add_argument('--fruit_xyz',    type=str, default='x,y,z', help='XYZ columns for fruit.')
    parser.add_argument('--leaf_xyz',     type=str, default='x,y,z', help='XYZ columns for leaves.')

    # Time slice
    parser.add_argument('--snapshot_doy', type=int, default=None,
                        help='Day-of-year (1–366) to slice. If omitted, latest DOY is used.')
    parser.add_argument('--snapshot_hour', type=int, default=13,
                        help='Hour-of-day to slice (0–23). Default: 13 (midday).')

    # Output naming
    parser.add_argument('--outdir', type=str, default='outputs', help='Base output directory.')
    parser.add_argument('--targets', type=str, default='plots', help='Label used in output folder name.')
    parser.add_argument('--exact_outdir', type=str, default='false',
                        help='Write directly to --outdir instead of creating a timestamped child folder.')
    parser.add_argument('--plot_label', type=str, default='',
                        help='Scenario label included in internode plot titles.')
    parser.add_argument('--view_elev', type=float, default=30,
                        help='Static 3D camera elevation in degrees (default: 30).')
    parser.add_argument('--view_azim', type=float, default=-60,
                        help='Static 3D camera azimuth in degrees (default: -60).')
    parser.add_argument('--interactive', type=str, default='true',
                        help='Write interactive internode HTML outputs (true/false).')
    parser.add_argument('--histograms', type=str, default='true',
                        help='Write internode histogram outputs (true/false).')
    parser.add_argument('--publication_style', type=str, default='false',
                        help='Use compact A/B panel styling and also write SVG/PDF files (true/false).')
    parser.add_argument('--fruit_range_hist', type=str, default='true',
                        help='Whether to plot fruit spatial range distribution (true/false).')
    parser.add_argument('--fruit_range_mode', type=str, default='xy',
                        help="Range mode for fruit distribution: 'xy' or 'xyz'.")
    parser.add_argument('--fruit_range_center', type=str, default='0,0,0',
                        help='Range center as x,y,z (model coordinate units, typically m).')
    parser.add_argument('--fruit_range_bins', type=int, default=24,
                        help='Number of bins for fruit range histogram.')

    args = parser.parse_args()
    outdir = args.outdir if parse_bool(args.exact_outdir, default=False) else os.path.join(
        args.outdir, f"{args.targets}_{NOW}"
    )
    Path(outdir).mkdir(parents=True, exist_ok=True)

    # ---------------- Internodes ----------------
    if args.internode_csv:
        try:
            node_df, node_xyz = load_internodes(args)
            if 'timestamp' in node_df.columns and node_df['timestamp'].notna().any():
                print(f"Plotting internodes at {node_df['timestamp'].iloc[0]} (DOY={args.snapshot_doy or 'latest'}, hour={args.snapshot_hour}), n={len(node_df)}")
            write_internode_snapshot_plot_data(node_df, outdir)
            metrics_raw = [m.strip().lower() for m in args.internode_metrics.split(",") if m.strip()]
            # map aliases
            metrics = []
            for m in metrics_raw:
                if m in ("waterpotential", "water_potential"):
                    metrics.append("waterPotential")
                elif m in ("cp", "c_p"):
                    metrics.append("Cp")
                elif m in ("sugar", "sugarconcentration", "sugar_concentration"):
                    metrics.append("sugarConcentration")
                elif m == "cpt":
                    metrics.append("cpt")
                else:
                    print(f"[internodes] Unknown metric '{m}' skipped.")
            # plot each requested metric if present
            for m in metrics:
                if m not in node_df.columns:
                    print(f"[internodes] Skipping {m}: column not in CSV (or cannot be derived).")
                    continue
                if m == "waterPotential":
                    pretty = "Xylem water potential"
                elif m == "Cp":
                    pretty = "Cp"
                elif m == "cpt":
                    pretty = "Raw cpt"
                else:
                    pretty = "Sugar concentration"
                plot_nodes_metric(
                    node_df,
                    m,
                    outdir,
                    pretty,
                    plot_label=args.plot_label,
                    interactive=parse_bool(args.interactive, default=True),
                    histograms=parse_bool(args.histograms, default=True),
                    view_elev=args.view_elev,
                    view_azim=args.view_azim,
                    publication_style=parse_bool(args.publication_style, default=False)
                )
            write_internode_diagnostics(node_df, metrics, args, outdir)
        except Exception as e:
            print(f"[internodes] Skipped due to error: {e}")

    # ---------------- Fruit ----------------
    if args.fruit_csv:
        try:
            fruit_df, fruit_xyz = load_fruit(args)
            if 'timestamp' in fruit_df.columns and fruit_df['timestamp'].notna().any():
                print(f"Plotting fruit at {fruit_df['timestamp'].iloc[0]} (DOY={args.snapshot_doy or 'latest'}, hour={args.snapshot_hour}), n={len(fruit_df)}")
            metrics_raw = [m.strip().lower() for m in args.fruit_metrics.split(",") if m.strip()]
            for m in metrics_raw:
                if m == "dry":
                    plot_fruit_metric(fruit_df, fruit_xyz, "dryWeight_g", "Fruit dry weight", outdir)
                elif m == "fresh":
                    plot_fruit_metric(fruit_df, fruit_xyz, "freshWeight_g", "Fruit fresh weight", outdir)
                elif m in ("sugar", "sugarconcentration", "sugar_concentration", "sugar_fruit"):
                    plot_fruit_metric(fruit_df, fruit_xyz, "sugarConcentration_fruit", "Fruit sugar concentration", outdir)
                else:
                    print(f"[fruit] Unknown metric '{m}' skipped.")

            if parse_bool(args.fruit_range_hist, default=True):
                center = parse_center_xyz(args.fruit_range_center, default=(0.0, 0.0, 0.0))
                bins = int(args.fruit_range_bins) if args.fruit_range_bins is not None else 24
                if bins < 2:
                    bins = 2
                plot_fruit_range_distribution(
                    fruit_df,
                    fruit_xyz,
                    outdir=outdir,
                    mode=args.fruit_range_mode,
                    center=center,
                    bins=bins
                )
        except Exception as e:
            print(f"[fruit] Skipped due to error: {e}")

    # ---------------- Leaves ----------------
    if args.leaf_csv:
        try:
            leaf_df, leaf_xyz, leaf_vcol = load_leaf(args)
            if 'timestamp' in leaf_df.columns and leaf_df['timestamp'].notna().any():
                print(f"Plotting leaves at {leaf_df['timestamp'].iloc[0]} (DOY={args.snapshot_doy or 'latest'}, hour={args.snapshot_hour}), n={len(leaf_df)}")
            pretty = "Leaf fabs" if leaf_vcol == "fabs" else f"Leaf {leaf_vcol}"
            plot_leaf_metric(leaf_df, leaf_xyz, leaf_vcol, outdir, pretty=pretty)
        except Exception as e:
            print(f"[leaf] Skipped due to error: {e}")

if __name__ == "__main__":
    main()
