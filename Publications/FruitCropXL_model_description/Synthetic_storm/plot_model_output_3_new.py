"""
Plot the storm event (days 200-207) from the Bordeaux climate CSV.

Produces TWO figures:
  1. Five-panel hourly comparison of storm and default air temperature,
     relative humidity, total radiation, wind speed, and soil water potential.
  2. Daily-summary "results" figure as a subplot grid: daily rainfall total,
     daily temp range, daily mean RH & wind, and end-of-day soil water status.

Usage:
    python plot_model_output_3_new.py
Requires: pandas, matplotlib
"""

import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

# Figure typography
AXIS_LABEL_SIZE = 13
TICK_LABEL_SIZE = 11
TITLE_SIZE = 14
LEGEND_SIZE = 12

plt.rcParams.update({
    "font.family": "serif",
    "axes.labelsize": AXIS_LABEL_SIZE,
    "axes.titlesize": TITLE_SIZE,
    "xtick.labelsize": TICK_LABEL_SIZE,
    "ytick.labelsize": TICK_LABEL_SIZE,
    "legend.fontsize": LEGEND_SIZE,
})

SCRIPT_DIR = Path(__file__).resolve().parent
CSV_PATH = SCRIPT_DIR / "DAI_2012_12L_stormPub/run-config/Exp2012_Dai_Bordeaux_climateConditionsAfterVeraison-STORM.csv"
DEFAULT_CSV_PATH = SCRIPT_DIR / "DAI_2012_12L_storm_default/run-config/Exp2012_Dai_Bordeaux_climateConditionsAfterVeraison_storm_default.csv"

# Okabe-Ito colourblind-safe scenario colours, matching the response figure.
COLOR_STORM = "#D55E00"   # vermillion
COLOR_DEFAULT = "#0072B2"  # blue

# Simulation window, from the model run configuration:
#   Start day of year: 200, Hour of day: 0, Number of simulation days: 8
SIM_START_DAY, SIM_START_HOUR = 200, 0
SIM_DURATION_HOURS = 8 * 24  # 192

start_abs_hour = SIM_START_DAY * 24 + SIM_START_HOUR
end_abs_hour = start_abs_hour + SIM_DURATION_HOURS

df = pd.read_csv(CSV_PATH)
df["abs_hour"] = df["day"] * 24 + df["hour"]
df = df[(df["abs_hour"] >= start_abs_hour) & (df["abs_hour"] <= end_abs_hour)].copy()

df_default = pd.read_csv(DEFAULT_CSV_PATH)
df_default["abs_hour"] = df_default["day"] * 24 + df_default["hour"]
df_default = df_default[
    (df_default["abs_hour"] >= start_abs_hour)
    & (df_default["abs_hour"] <= end_abs_hour)
].copy()

# Hours since actual simulation start (t=0 = Day 200, 00:00) -- matches the
# x-axis used in plot_model_output.py exactly, since that script now derives
# its own t=0 from the model run's first logged timestamp.
df["hours"] = df["abs_hour"] - start_abs_hour
df = df.sort_values("hours")
df_default["hours"] = df_default["abs_hour"] - start_abs_hour
df_default = df_default.sort_values("hours")

# Storm phases as fractions of the 192h run (3 days approach / 3 days heavy
# rain / 2 days clearing), expressed directly in hours-since-sim-start so
# they match plot_model_output.py's shading regardless of calendar offset.
phase_bounds = [
    (0, 72, "Approach", "#f5f0c8"),
    (72, 144, "Heavy rain", "#dbe6f2"),
    (144, 192, "Clearing", "#dcf2df"),
]
PHASE_ALPHA = 0.4

# ---------------------------------------------------------------------------
# FIGURE 1 — hourly timeline
# ---------------------------------------------------------------------------
fig1, axes = plt.subplots(5, 1, figsize=(12, 11), sharex=True)

panels = [
    ("temp", "Ta (°C)"),
    ("rh", "RH (0–1)"),
    ("totalRadiation", r"Radiation ($\mu$mol m$^{-2}$ s$^{-1}$)"),
    ("wind", r"Wind speed (m s$^{-1}$)"),
    ("soilWater_Potential", r"$\psi_{\mathrm{soil}}$ (MPa)"),
]

for ax, (col, ylabel) in zip(axes, panels):
    # Draw the default first and storm last so the storm forcing remains
    # visible wherever the trajectories overlap.
    ax.plot(df_default["hours"], df_default[col], label="Default conditions",
            color=COLOR_DEFAULT, linewidth=1.2, zorder=2)
    ax.plot(df["hours"], df[col], label="Storm (dry-to-wet)",
            color=COLOR_STORM, linewidth=1.2, zorder=3)
    ax.set_ylabel(ylabel)
    ax.grid(alpha=0.3)

# Shade the three storm phases across all panels
for ax in axes:
    for start_h, end_h, label, color in phase_bounds:
        ax.axvspan(start_h, end_h, color=color, alpha=PHASE_ALPHA, zorder=0)

# Label phases once, on the top panel
for start_h, end_h, label, color in phase_bounds:
    mid_h = (start_h + end_h) / 2
    axes[0].text(mid_h, 1.02, label, transform=axes[0].get_xaxis_transform(),
                 ha="center", va="bottom", fontsize=AXIS_LABEL_SIZE, fontweight="bold",
                 clip_on=False)

axes[-1].set_xlabel("Time since simulation start (h)")
axes[-1].set_xlim(0, 192)
axes[-1].set_xticks(range(0, 193, 24))

fig1.tight_layout(rect=[0, 0.06, 1, 0.98])

# Shared scenario legend, matching the response figure's display order.
plotted_handles, plotted_labels = axes[0].get_legend_handles_labels()
handle_by_label = dict(zip(plotted_labels, plotted_handles))
labels = ["Storm (dry-to-wet)", "Default conditions"]
handles = [handle_by_label[label] for label in labels]
fig1.legend(
    handles,
    labels,
    loc="lower center",
    ncol=len(labels),
    bbox_to_anchor=(0.5, 0.025),
    frameon=False,
)

fig1.savefig(SCRIPT_DIR / "storm_event_plot.png", dpi=300, bbox_inches="tight")
fig1.savefig(SCRIPT_DIR / "storm_event_plot.pdf", bbox_inches="tight")
fig1.savefig(SCRIPT_DIR / "storm_forcing_full.png", dpi=300, bbox_inches="tight")
fig1.savefig(SCRIPT_DIR / "storm_forcing_full.pdf", bbox_inches="tight")

# ---------------------------------------------------------------------------
# FIGURE 2 — daily summary / results grid
# ---------------------------------------------------------------------------
daily = df.groupby("day").agg(
    temp_min=("temp", "min"),
    temp_max=("temp", "max"),
    temp_mean=("temp", "mean"),
    rh_mean=("rh", "mean"),
    wind_mean=("wind", "mean"),
    wind_max=("wind", "max"),
    rad_max=("totalRadiation", "max"),
    rain_total=("rainfall", "sum"),
    soilPotential_end=("soilWater_Potential", "last"),
    soilContent_end=("soilWater_content", "last"),
).reset_index()

phase_colors = []
for d in daily["day"]:
    d_start_hour = (d - SIM_START_DAY) * 24 - SIM_START_HOUR  # this day's midnight, in hours-since-sim-start
    for start_h, end_h, label, color in phase_bounds:
        if start_h <= d_start_hour < end_h:
            phase_colors.append(color)
            break
    else:
        phase_colors.append("lightgray")

fig2, rax = plt.subplots(2, 2, figsize=(12, 9))

# Daily rainfall total
rax[0, 0].bar(daily["day"], daily["rain_total"], color=phase_colors, edgecolor="black", linewidth=0.5)
rax[0, 0].set_title("Daily Rainfall Total (mm)")
rax[0, 0].set_ylabel("mm")
rax[0, 0].grid(alpha=0.3)

# Daily temperature range (min-max) with mean marker
rax[0, 1].vlines(daily["day"], daily["temp_min"], daily["temp_max"], color="gray", linewidth=6, alpha=0.5)
rax[0, 1].scatter(daily["day"], daily["temp_mean"], color="tab:red", zorder=5, label="Daily mean")
rax[0, 1].set_title("Daily Temperature Range (°C)")
rax[0, 1].set_ylabel("°C")
rax[0, 1].legend(fontsize=LEGEND_SIZE)
rax[0, 1].grid(alpha=0.3)

# Daily mean RH & mean wind (twin axes)
rax[1, 0].plot(daily["day"], daily["rh_mean"], color="tab:blue", marker="o", label="Mean RH")
rax[1, 0].set_ylabel("Relative Humidity (0-1)", color="tab:blue")
rax[1, 0].tick_params(axis="y", labelcolor="tab:blue")
rax[1, 0].set_title("Daily Mean RH & Wind")
rax[1, 0].grid(alpha=0.3)
rax_wind = rax[1, 0].twinx()
rax_wind.plot(daily["day"], daily["wind_mean"], color="tab:green", marker="s", label="Mean Wind")
rax_wind.set_ylabel("Wind (m/s)", color="tab:green")
rax_wind.tick_params(axis="y", labelcolor="tab:green")

# End-of-day soil water status (twin axes)
rax[1, 1].plot(daily["day"], daily["soilPotential_end"], color="tab:brown", marker="o", label="Soil Potential")
rax[1, 1].set_ylabel("Soil Water Potential", color="tab:brown")
rax[1, 1].tick_params(axis="y", labelcolor="tab:brown")
rax[1, 1].set_title("End-of-Day Soil Water Status")
rax[1, 1].grid(alpha=0.3)
rax_content = rax[1, 1].twinx()
rax_content.plot(daily["day"], daily["soilContent_end"], color="tab:purple", marker="s", linestyle="--", label="Soil Content")
rax_content.set_ylabel("Soil Water Content", color="tab:purple")
rax_content.tick_params(axis="y", labelcolor="tab:purple")

for a in rax.flat:
    a.set_xlabel("Day of year")
    a.set_xticks(daily["day"])

fig2.suptitle(f"Storm Event — Daily Summary (Day {SIM_START_DAY}\u2013{SIM_START_DAY+8})", fontsize=TITLE_SIZE)
fig2.tight_layout(rect=[0, 0, 1, 0.96])
fig2.savefig(SCRIPT_DIR / "storm_event_daily_summary.png", dpi=300)

plt.close(fig1)
plt.close(fig2)
