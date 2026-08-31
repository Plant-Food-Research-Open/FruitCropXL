"""
Regenerates Figure 6 and Supplementary Figures S1-S3 for the indoor-grapevine
manuscript section, from the already-computed spur/cane CSVs.

Prerequisites (expected relative to OUTDIR, default "outdir"):
    outdir/spur/f_values_sensitivity_analysis_results_with_inputs.csv
    outdir/cane/f_values_sensitivity_analysis_results_with_inputs.csv
    outdir/spur/per_simulation_df_with_treatment.csv
    outdir/cane/per_simulation_df_with_treatment.csv
    outdir/spur/daily_timeseries_with_treatment.csv
    outdir/cane/daily_timeseries_with_treatment.csv

Usage:
    python generate_figures.py
"""

import os
import string

import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import seaborn as sns

# ---------------------------------------------------------------------------
# Global style, matching the manuscript's other figures
# ---------------------------------------------------------------------------
mpl.rcParams.update({
    "font.family": "serif",
    "font.size": 11,
    "axes.labelsize": 11,
    "axes.titlesize": 11,
    "legend.fontsize": 9,
    "xtick.labelsize": 9,
    "ytick.labelsize": 9,
    "axes.linewidth": 0.8,
    "figure.dpi": 150,
})

COLORS = {"spur": "#0072B2", "cane": "#D55E00"}
OUTDIR = "outdir"


def load_data(outdir=OUTDIR):
    spur_anova = pd.read_csv(f"{outdir}/spur/f_values_sensitivity_analysis_results_with_inputs.csv")
    cane_anova = pd.read_csv(f"{outdir}/cane/f_values_sensitivity_analysis_results_with_inputs.csv")

    spur_summary = pd.read_csv(f"{outdir}/spur/per_simulation_df_with_treatment.csv")
    cane_summary = pd.read_csv(f"{outdir}/cane/per_simulation_df_with_treatment.csv")
    all_summary = pd.concat([spur_summary, cane_summary], ignore_index=True)

    spur_daily = pd.read_csv(f"{outdir}/spur/daily_timeseries_with_treatment.csv")
    cane_daily = pd.read_csv(
        f"{outdir}/cane/daily_timeseries_with_treatment.csv",
        dtype={"baseScenarioFile": "string"},  # avoids DtypeWarning: NaN for reconstructed cane_40/50 rows
    )
    all_daily = pd.concat([spur_daily, cane_daily], ignore_index=True)

    return spur_anova, cane_anova, spur_summary, cane_summary, all_summary, all_daily


# ===========================================================================
# Figure 6
# ===========================================================================
def make_figure6(spur_anova, cane_anova, all_summary, outdir=OUTDIR):
    factor_map = {
        "leafArea": "Leaf area",
        "totalFruitNumber": "Crop load",
        "totalFruitNumber:leafArea": "Crop load x leaf area",
        "leafArea:incomingRadiation": "Leaf area x radiation",
        "cca": "CO2",
    }

    def get_eta(df, factor):
        row = df[(df["Target"] == "harvest_index") & (df["index"] == factor)]
        return row["Partial_Eta2"].values[0] if len(row) else 0.0

    factors = list(factor_map.keys())
    factor_labels = list(factor_map.values())
    spur_vals = [get_eta(spur_anova, f) for f in factors]
    cane_vals = [get_eta(cane_anova, f) for f in factors]

    fig = plt.figure(figsize=(11, 12))
    gs = fig.add_gridspec(3, 2, height_ratios=[1.1, 1, 1], hspace=0.45, wspace=0.35)
    ax_A = fig.add_subplot(gs[0, 0])
    ax_B = fig.add_subplot(gs[0, 1])
    ax_C = fig.add_subplot(gs[1, 0])
    ax_D = fig.add_subplot(gs[1, 1])
    ax_E = fig.add_subplot(gs[2, 0])
    ax_F = fig.add_subplot(gs[2, 1])

    # Panel A: placeholder for GroIMP renders.
    ax_A.axis("off")
    ax_A.text(0.5, 0.5, "Insert spur / cane\n3D plant renders here\n(GroIMP screenshots)",
              ha='center', va='center', fontsize=10, color='gray',
              bbox=dict(boxstyle='round', facecolor='#f0f0f0', edgecolor='gray'))
    ax_A.set_title("(a)", loc="left", fontweight="bold", pad=8)

    # Panel B: dominant drivers of harvest index (partial eta-squared)
    x = np.arange(len(factors))
    width = 0.35
    ax_B.bar(x - width / 2, spur_vals, width, label="Spur system", color=COLORS["spur"])
    ax_B.bar(x + width / 2, cane_vals, width, label="Cane system", color=COLORS["cane"])
    ax_B.set_xticks(x)
    ax_B.set_xticklabels(factor_labels, rotation=20, ha='right')
    ax_B.set_ylabel(r"Effect size, $\eta_p^2$")
    ax_B.set_title("(b) Dominant drivers of harvest index", loc="left", fontweight="bold", pad=8)

    # Panels C-F: treatment-mean line plots vs leaf number, mean +/- 1 SD band.
    # SD (not SEM) is used deliberately: it shows variability across the
    # retained treatment combinations, not uncertainty in the estimated mean.
    line_specs = [
        (ax_C, 'c', 'harvest_index', 'Harvest index (\u2013)', 'Harvest index vs. leaf number'),
        (ax_D, 'd', 'fraction_fruitUnloading', 'Unloading fraction (\u2013)', 'Fruit unloading fraction'),
        (ax_E, 'e', 'meanFruitDW', 'Dry mass (mg)', 'Mean fruit dry mass'),
        (ax_F, 'f', 'meanFruitSc', r"$\overline{C}_{\mathrm{fruit}}$ (g sugar g$^{-1}$ water)",
         'Mean fruit sugar concentration'),
    ]

    for ax, letter, col, ylabel, title in line_specs:
        for vt, sub in all_summary.groupby("vineType"):
            means = sub.groupby("ENDING_LEAF_NUMBER")[col].mean()
            stds = sub.groupby("ENDING_LEAF_NUMBER")[col].std()
            ax.plot(means.index, means.values, marker='o', color=COLORS[vt],
                    label=f"{vt.capitalize()} system")
            ax.fill_between(means.index, means.values - stds.values, means.values + stds.values,
                             color=COLORS[vt], alpha=0.2)
        ax.set_xlabel("Final leaf number per shoot")
        ax.set_ylabel(ylabel)
        ax.set_title(f"({letter}) {title}", loc="left", fontweight="bold", pad=8)

    plotted_handles, plotted_labels = ax_C.get_legend_handles_labels()
    handle_by_label = dict(zip(plotted_labels, plotted_handles))
    legend_labels = ["Spur system", "Cane system"]
    legend_handles = [handle_by_label[l] for l in legend_labels]
    fig.legend(legend_handles, legend_labels, loc="lower center", ncol=2,
               bbox_to_anchor=(0.5, 0.01), frameon=False)

    fig.savefig(f"{outdir}/Figure6.png", dpi=300, bbox_inches="tight")
    fig.savefig(f"{outdir}/Figure6.pdf", bbox_inches="tight")
    plt.close(fig)


# ===========================================================================
# Supplementary Figure S1: broader sensitivity analysis
# ===========================================================================
def make_figureS1(spur_anova, cane_anova, outdir=OUTDIR):
    s1_targets = [
        ('harvest_index', 'Harvest index'),
        ('meanFruitSc', 'Fruit soluble sugar concentration'),
        ('fraction_fruitUnloading', 'Fruit unloading fraction'),
        ('biomassPlant', 'Whole-plant biomass'),
    ]
    panel_letters = iter(string.ascii_lowercase)
    fig, axes = plt.subplots(4, 2, figsize=(10, 10), constrained_layout=True)
    fig.set_constrained_layout_pads(w_pad=0.1, h_pad=0.1, hspace=0.05, wspace=0.15)

    for row, (target, title) in enumerate(s1_targets):
        for col, (anova_df, vine_type) in enumerate([(spur_anova, 'Spur'), (cane_anova, 'Cane')]):
            ax = axes[row, col]
            letter = next(panel_letters)
            top5 = (anova_df[anova_df['Target'] == target]
                    .sort_values('Partial_Eta2', ascending=False).head(5))
            ax.barh(top5['index'], top5['Partial_Eta2'], color='skyblue')
            ax.invert_yaxis()
            ax.tick_params(axis='y', labelsize=9)
            ax.set_xlabel(r"Effect size, $\eta_p^2$")
            ax.set_title(f"({letter}) {title}", loc="left", fontweight="bold", fontsize=11, pad=8)

    fig.canvas.draw()
    for col, vine_type in enumerate(['Spur', 'Cane']):
        pos = axes[0, col].get_position()
        x_center = (pos.x0 + pos.x1) / 2
        fig.text(x_center, pos.y1 + 0.035, vine_type, ha='center', fontsize=14, fontweight='bold')

    fig.savefig(f"{outdir}/FigureS1.pdf", bbox_inches="tight")
    fig.savefig(f"{outdir}/FigureS1.png", dpi=300, bbox_inches="tight")
    plt.close(fig)


# ===========================================================================
# Supplementary Figure S2: seasonal source-sink dynamics
# ===========================================================================
def make_figureS2(all_daily, outdir=OUTDIR):
    s2_metrics = [
        ('meanFruitDW', 'Fruit dry mass (mg)', 'Fruit dry mass'),
        ('meanFruitSc', 'Sugar concentration (g sugar g$^{-1}$ water)', 'Fruit sugar concentration'),
        ('harvest_index', 'Harvest index (\u2013)', 'Harvest index'),
        ('fraction_fruitUnloading', 'Unloading fraction (\u2013)', 'Fruit unloading fraction'),
    ]
    panel_letters = iter(string.ascii_lowercase)
    fig, axes = plt.subplots(4, 2, figsize=(10, 14), constrained_layout=True)
    fig.set_constrained_layout_pads(w_pad=0.1, h_pad=0.05, hspace=0.02, wspace=0.15)

    for row, (col_name, ylabel, title_text) in enumerate(s2_metrics):
        for col, vine_type in enumerate(['spur', 'cane']):
            ax = axes[row, col]
            letter = next(panel_letters)
            sub = all_daily[all_daily['vineType'] == vine_type]
            # errorbar='sd': shows spread across retained treatment
            # combinations, not standard error of the mean.
            sns.lineplot(data=sub, x='dayOfYear', y=col_name, hue='ENDING_LEAF_NUMBER',
                         palette='viridis', ax=ax, legend=(row == 0 and col == 1),
                         errorbar='sd')
            ax.set_ylabel(ylabel)
            ax.set_xlabel("Day of Year")
            ax.set_title(f"({letter}) {title_text}", loc="left", fontweight="bold", fontsize=11, pad=8)

    fig.canvas.draw()
    for col, vine_type in enumerate(['Spur', 'Cane']):
        pos = axes[0, col].get_position()
        x_center = (pos.x0 + pos.x1) / 2
        fig.text(x_center, pos.y1 + 0.02, vine_type, ha='center', fontsize=14, fontweight='bold')

    fig.savefig(f"{outdir}/FigureS2.pdf", bbox_inches="tight")
    fig.savefig(f"{outdir}/FigureS2.png", dpi=300, bbox_inches="tight")
    plt.close(fig)


# ===========================================================================
# Supplementary Figure S3: leaf number x crop-load response surface
# ===========================================================================
def make_figureS3(spur_summary, cane_summary, outdir=OUTDIR):
    s3_targets = [
        ('harvest_index', 'Harvest index (\u2013)'),
        ('meanFruitDW', 'Mean fruit dry mass (mg)'),
        ('meanFruitSc', r"$\overline{C}_{\mathrm{fruit}}$ (g sugar g$^{-1}$ water)"),
    ]
    fig, axes = plt.subplots(3, 2, figsize=(9, 12), constrained_layout=True)
    fig.set_constrained_layout_pads(w_pad=0.1, h_pad=0.3, hspace=0.08, wspace=0.15)
    panel_letters = iter(string.ascii_lowercase)

    for row, (target, title) in enumerate(s3_targets):
        vmin = min(spur_summary[target].min(), cane_summary[target].min())
        vmax = max(spur_summary[target].max(), cane_summary[target].max())
        for col, (summary_df, vine_type) in enumerate([(spur_summary, 'Spur'), (cane_summary, 'Cane')]):
            ax = axes[row, col]
            letter = next(panel_letters)
            pivot = summary_df.pivot_table(index='totalFruitNumber', columns='ENDING_LEAF_NUMBER',
                                            values=target, aggfunc='mean')
            im = ax.imshow(pivot.values, aspect='auto', cmap='viridis', origin='lower',
                            vmin=vmin, vmax=vmax)
            for i in range(pivot.shape[0]):
                for j in range(pivot.shape[1]):
                    val = pivot.values[i, j]
                    normalized = (val - vmin) / (vmax - vmin)
                    ax.text(j, i, f"{val:.2f}", ha='center', va='center',
                            color='white' if normalized < 0.5 else 'black', fontsize=8)
            ax.set_xticks(range(len(pivot.columns)))
            ax.set_xticklabels(pivot.columns.astype(int))
            ax.set_yticks(range(len(pivot.index)))
            ax.set_yticklabels(pivot.index.astype(int))
            ax.set_xlabel("Final leaf number per shoot")
            if col == 0:
                ax.set_ylabel("Crop load (fruit number)")
            ax.set_title(f"({letter})", loc="left", fontweight="bold", fontsize=11, pad=10)
            fig.colorbar(im, ax=ax, fraction=0.046, label=title)

    fig.canvas.draw()
    for col, vine_type in enumerate(['Spur', 'Cane']):
        pos = axes[0, col].get_position()
        x_center = (pos.x0 + pos.x1) / 2
        fig.text(x_center, pos.y1 + 0.02, vine_type, ha='center', fontsize=14, fontweight='bold')

    fig.savefig(f"{outdir}/FigureS3.pdf", bbox_inches="tight")
    fig.savefig(f"{outdir}/FigureS3.png", dpi=300, bbox_inches="tight")
    plt.close(fig)


if __name__ == "__main__":
    os.makedirs(OUTDIR, exist_ok=True)
    spur_anova, cane_anova, spur_summary, cane_summary, all_summary, all_daily = load_data()

    make_figure6(spur_anova, cane_anova, all_summary)
    make_figureS1(spur_anova, cane_anova)
    make_figureS2(all_daily)
    make_figureS3(spur_summary, cane_summary)

    print(f"Done. Figure6, FigureS1, FigureS2, FigureS3 (.pdf and .png) saved to {OUTDIR}/")
