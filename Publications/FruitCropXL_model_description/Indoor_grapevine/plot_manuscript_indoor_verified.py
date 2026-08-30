"""Create manuscript indoor-grapevine figures from the audited outputs.

The source tables contain the corrected four-level cane crop-load analysis.
Mean fruit dry weight is deliberately excluded because that derived response
is still under review. Bands are the 10th--90th percentile range across
deterministic treatment combinations, not biological uncertainty.
"""

from pathlib import Path

import matplotlib as mpl
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


SCRIPT_DIR = Path(__file__).resolve().parent
OUTDIR = SCRIPT_DIR / "outdir"
MANUSCRIPT_FIGURES = SCRIPT_DIR.parent / "06_figures"

COLORS = {"spur": "#0072B2", "cane": "#D55E00"}
SYSTEM_LABELS = {"spur": "Spur system", "cane": "Cane system"}

mpl.rcParams.update(
    {
        "font.family": "serif",
        "font.size": 10,
        "axes.labelsize": 10,
        "axes.titlesize": 11,
        "legend.fontsize": 9,
        "xtick.labelsize": 9,
        "ytick.labelsize": 9,
        "axes.linewidth": 0.8,
    }
)


def read_analysis(vine_type):
    analysis_dir = OUTDIR / vine_type
    anova = pd.read_csv(
        analysis_dir / "f_values_sensitivity_analysis_results_with_inputs.csv"
    )
    summary = pd.read_csv(
        analysis_dir / "per_simulation_df_with_treatment.csv"
    )
    return anova, summary


spur_anova, spur_summary = read_analysis("spur")
cane_anova, cane_summary = read_analysis("cane")
summaries = {"spur": spur_summary, "cane": cane_summary}

fig, axes = plt.subplots(2, 2, figsize=(9.2, 7.2))
ax_a, ax_b, ax_c, ax_d = axes.flatten()

# (a) Partial eta-squared values for the dominant fruit-biomass-fraction terms.
factor_map = {
    "leafArea": "Leaf area",
    "totalFruitNumber": "Crop load",
    "totalFruitNumber:leafArea": "Crop load × leaf area",
    "leafArea:incomingRadiation": "Leaf area × radiation",
}


def eta_value(table, factor):
    rows = table[
        table["Target"].eq("harvest_index") & table["index"].eq(factor)
    ]
    return float(rows["Partial_Eta2"].iloc[0]) if len(rows) else 0.0


factors = list(factor_map)
y = np.arange(len(factors))
height = 0.34
for offset, vine_type, table in [
    (-height / 2, "spur", spur_anova),
    (height / 2, "cane", cane_anova),
]:
    values = [eta_value(table, factor) for factor in factors]
    ax_a.barh(
        y + offset,
        values,
        height,
        color=COLORS[vine_type],
        label=SYSTEM_LABELS[vine_type],
    )
ax_a.set_yticks(y)
ax_a.set_yticklabels([factor_map[factor] for factor in factors])
ax_a.invert_yaxis()
ax_a.set_xlim(0, 1)
ax_a.set_xlabel(r"Partial $\eta^2$")
ax_a.set_title(
    "(a) Fruit-biomass-fraction sensitivity", loc="left", fontweight="bold"
)


def plot_leaf_number_response(ax, column, ylabel, title):
    for vine_type, data in summaries.items():
        grouped = data.groupby("ENDING_LEAF_NUMBER")[column]
        means = grouped.mean()
        lower = grouped.quantile(0.10)
        upper = grouped.quantile(0.90)
        ax.plot(
            means.index,
            means.values,
            marker="o",
            linewidth=1.4,
            color=COLORS[vine_type],
            label=SYSTEM_LABELS[vine_type],
        )
        ax.fill_between(
            means.index,
            lower.values,
            upper.values,
            color=COLORS[vine_type],
            alpha=0.16,
            linewidth=0,
        )
    ax.set_xticks([3, 6, 9, 12])
    ax.set_xlabel("Final leaf number per shoot")
    ax.set_ylabel(ylabel)
    ax.set_title(title, loc="left", fontweight="bold")
    ax.grid(alpha=0.2, linewidth=0.5)


plot_leaf_number_response(
    ax_b,
    "harvest_index",
    "Fruit biomass fraction",
    "(b) Fruit biomass fraction",
)
plot_leaf_number_response(
    ax_c,
    "fraction_fruitUnloading",
    "Fruit unloading fraction",
    "(c) Carbon unloading to fruit",
)
plot_leaf_number_response(
    ax_d,
    "meanFruitSc",
    r"Fruit sugar concentration (g g$^{-1}$)",
    "(d) Fruit sugar concentration",
)

handles, labels = ax_b.get_legend_handles_labels()
fig.legend(
    handles,
    labels,
    loc="lower center",
    ncol=2,
    bbox_to_anchor=(0.5, 0.01),
    frameon=False,
)

fig.tight_layout(rect=[0, 0.06, 1, 1])

analysis_png = OUTDIR / "Figure6_verified.png"
analysis_pdf = OUTDIR / "Figure6_verified.pdf"
manuscript_png = MANUSCRIPT_FIGURES / "06B_Figure7_harvest_index_sensitivity.png"
manuscript_pdf = MANUSCRIPT_FIGURES / "06B_Figure7_harvest_index_sensitivity.pdf"

fig.savefig(analysis_png, dpi=300, bbox_inches="tight")
fig.savefig(analysis_pdf, bbox_inches="tight")
fig.savefig(manuscript_png, dpi=300, bbox_inches="tight")
fig.savefig(manuscript_pdf, bbox_inches="tight")


# Supplementary sensitivity figure. Internal table field names are retained on
# the bars for traceability; only the reader-facing response names are changed.
targets = [
    ("harvest_index", "Fruit biomass fraction"),
    ("meanFruitSc", "Fruit soluble-sugar concentration"),
    ("fraction_fruitUnloading", "Fruit unloading fraction"),
    ("biomassPlant", "Whole-plant biomass"),
]
tables = {"spur": spur_anova, "cane": cane_anova}
fig_s, axes_s = plt.subplots(4, 2, figsize=(9.2, 12.0))
for row, (target, response_label) in enumerate(targets):
    for col, vine_type in enumerate(["spur", "cane"]):
        ax = axes_s[row, col]
        table = tables[vine_type]
        subset = (
            table.loc[table["Target"].eq(target)]
            .sort_values("Partial_Eta2", ascending=False)
            .head(5)
            .sort_values("Partial_Eta2")
        )
        ax.barh(subset["index"], subset["Partial_Eta2"], color=COLORS[vine_type])
        ax.set_xlim(left=0)
        ax.set_xlabel(r"Partial $\eta^2$")
        ax.set_title(
            f"({chr(97 + 2 * row + col)}) {SYSTEM_LABELS[vine_type]}",
            loc="left",
            fontweight="bold",
        )
        if col == 0:
            ax.set_ylabel(response_label)
        ax.grid(axis="x", alpha=0.2, linewidth=0.5)
fig_s.tight_layout()
fig_s.savefig(
    MANUSCRIPT_FIGURES / "06B_FigureS1_HGU_sensitivity.png",
    dpi=300,
    bbox_inches="tight",
)
fig_s.savefig(
    MANUSCRIPT_FIGURES / "06B_FigureS1_HGU_sensitivity.pdf",
    bbox_inches="tight",
)
