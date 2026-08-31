import pandas as pd
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import plotly.express as px
from pathlib import Path


# Define the output directory (relative to current working directory)
outdir = Path("outdir")
outdir.mkdir(exist_ok=True)  # Create 'outdir' if it doesn't exist


# Function to plot plant data
# This function takes a DataFrame, a grouping variable, and a y-axis variable,
# and generates a plot comparing spur and cane vine types.
# It also allows for filtering the data based on certain conditions.
# The function uses Plotly for interactive plotting and matplotlib for color mapping.
# The function also saves the generated plot as a JPEG file in the specified output directory.
def plot_plant_data(df, group_by, y_axis="biomassPlant", filters=None):
    # Apply filters if provided
    if filters is None:
        print("No filters provided, using the whole dataset")
        filtered_df = df.copy()
    else:
        try:
            filters = " ".join(filters.split())

            filtered_df = df[eval(filters)]
            print(
                "number of simulations after filtering:",
                (
                    len(filtered_df["uuid"].unique())
                    if "uuid" in filtered_df.columns
                    else "N/A"
                ),
            )
        except Exception as e:
            print(f"Error applying filters: {e}")
            print("Using the whole dataset")
            filtered_df = df.copy()

    # Check if the group_by column exists in the DataFrame
    print(
        "Number of simulations after filtering:",
        len(filtered_df["uuid"].unique()) if "uuid" in filtered_df.columns else "N/A",
    )
    print("Filtered DataFrame shape:", filtered_df.shape)
    print("Factor summaries (unique values for selected columns):")
    factor_cols = [
        "cca",
        "inputPAR",
        "Tmax",
        "Tmin",
        "ENDING_LEAF_NUMBER",
        "vineType",
        "totalFruitNumber",
    ]  # add/remove as needed

    for col in factor_cols:
        if col in filtered_df.columns:
            print(f"  {col}: {sorted(filtered_df[col].unique())}")

    # filtered_df.to_csv("filtered_data.csv", index=False)
    # print("Filtered data saved to 'filtered_data.csv'.")

    spur_df = filtered_df[filtered_df["vineType"] == "spur"].copy()
    cane_df = filtered_df[filtered_df["vineType"] == "cane"].copy()

    # Divide by 1000 if y_axis is biomassPlant or biomassFruit (convert mg to g)
    if y_axis in ["biomassPlant", "biomassFruit"]:
        spur_df[y_axis] = spur_df[y_axis] / 1000
        cane_df[y_axis] = cane_df[y_axis] / 1000

        y_axis_unit = "(g)"
    else:
        y_axis_unit = ""

    # Format function for labels
    def format_val(val):
        if isinstance(val, (float, int)):
            return f"{val:.1f}"
        return str(val)

    # Create group_id columns
    spur_df["group_id"] = (
        spur_df[group_by].apply(format_val).astype(str)
        + "_"
        + spur_df["uuid"].astype(str)
    )
    cane_df["group_id"] = (
        cane_df[group_by].apply(format_val).astype(str)
        + "_"
        + cane_df["uuid"].astype(str)
    )

    # Get unique group_by values across both datasets
    unique_groups = sorted(
        pd.concat([spur_df[group_by], cane_df[group_by]]).dropna().unique(),
        key=lambda x: (float(x) if isinstance(x, (float, int)) else x),
    )

    # Generate color map using matplotlib viridis
    norm = mcolors.Normalize(vmin=0, vmax=len(unique_groups) - 1)
    cmap = plt.get_cmap("viridis")
    group_colors = [mcolors.to_hex(cmap(norm(i))) for i in range(len(unique_groups))]
    color_map = dict(zip(unique_groups, group_colors))

    # Create figure with 2 subplots
    fig = make_subplots(
        rows=1, cols=2, subplot_titles=("Spur", "Cane"), shared_xaxes=True
    )

    # Add dummy traces for legend only, with colors
    for grp_val in unique_groups:
        label = f"{group_by}={format_val(grp_val)}"
        fig.add_trace(
            go.Scatter(
                x=[None],
                y=[None],
                mode="lines",
                name=label,
                legendgroup=label,
                showlegend=True,
                line=dict(width=3, color=color_map[grp_val]),
            ),
            row=1,
            col=1,
        )

    # Spur subplot: only plot if not empty
    if not spur_df.empty:
        for gid in sorted(spur_df["group_id"].dropna().unique()):
            sub = spur_df[spur_df["group_id"] == gid].sort_values("dayOfYear")
            if sub.empty:
                continue  # Skip if this group is empty
            grp_val = sub[group_by].iloc[0]
            fig.add_trace(
                go.Scatter(
                    x=sub["dayOfYear"],
                    y=sub[y_axis],
                    mode="lines+markers",
                    line=dict(color=color_map[grp_val]),
                    name="",
                    legendgroup=f"{group_by}={format_val(grp_val)}",
                    showlegend=False,
                ),
                row=1,
                col=1,
            )

    # Cane subplot: only plot if not empty
    if not cane_df.empty:
        for gid in sorted(cane_df["group_id"].dropna().unique()):
            sub = cane_df[cane_df["group_id"] == gid].sort_values("dayOfYear")
            if sub.empty:
                continue  # Skip if this group is empty
            grp_val = sub[group_by].iloc[0]
            fig.add_trace(
                go.Scatter(
                    x=sub["dayOfYear"],
                    y=sub[y_axis],
                    mode="lines+markers",
                    line=dict(color=color_map[grp_val]),
                    name="",
                    legendgroup=f"{group_by}={format_val(grp_val)}",
                    showlegend=False,
                ),
                row=1,
                col=2,
            )

    # Update layout with horizontal legend at bottom
    fig.update_layout(
        title_text=f"{y_axis} vs Day of Year grouped by {group_by}",
        height=600,
        width=1500,
        xaxis_title="Day of Year",
        xaxis2_title="Day of Year",
        yaxis_title=f"{y_axis} {y_axis_unit} (Spur)",
        yaxis2_title=f"{y_axis} {y_axis_unit} (Cane)",
        legend=dict(
            orientation="h",
            yanchor="bottom",
            y=-0.3,
            xanchor="center",
            x=0.5,
            font=dict(size=10),
            traceorder="normal",
            itemclick="toggleothers",
            itemdoubleclick="toggle",
        ),
    )

    jpeg_filename = outdir / f"plant_plot_{group_by}_{y_axis}.jpeg"
    fig.write_image(jpeg_filename, format="jpeg")

    print(f"Plots saved as '{jpeg_filename}'")


# read data
# Read the CSV file
# The CSV file is expected to be in the format: /output/FruitCropXL/combine_all_daily_average.csv
# The file contains simulation data for grapevine growth and development.
# The data includes various parameters such as biomass, sugar concentration, and fruit unloading fractions.
# The file is read into a pandas DataFrame for further analysis and plotting.
# The CSV file is expected to be in the format: /output/FruitCropXL/combine_all_daily_average.csv
# The file contains simulation data for grapevine growth and development.
# The data includes various parameters such as biomass, sugar concentration, and fruit unloading fractions.
# The file is read into a pandas DataFrame for further analysis and plotting.
csv_file_path = "/output/FruitCropXL/combine_all_daily_average_new.csv"


def extract_factors(folder_str):
    parts = folder_str.split("_")
    vine_type = parts[1]  # e.g., 'spur' or 'cane'
    return vine_type


big_df = pd.read_csv(csv_file_path)
big_df["vineType"] = big_df["folder"].apply(extract_factors)

# Add a new column: harvestIndex = biomassFruit / biomassPlant
big_df["harvestIndex"] = big_df["biomassFruit"] / big_df["biomassPlant"]

y_axis_options = [
    # "biomassPlant",
    # "biomassFruit",
    "harvestIndex",
    # "phloemSugarConcentration",
    # "fraction_fruitUnloading",
    # "fraction_internodeUnloading",
]
group_by_options = [
    # "cca",
    # "totalFruitNumber",
    # "inputPAR",
    # "ENDING_LEAF_NUMBER",
    "Ta"
]

base_filter_conditions = [
    "(df['cca'] == 900)",
    "(df['inputPAR'] == 1200)",
    "(df['Tmax'] == 27.5)",
    "(df['Tmin'] == 17.5)",
    "(df['ENDING_LEAF_NUMBER'] == 12)",
    # "(df['totalFruitNumber'] <= 50)",
    # "(((df['vineType'] == 'spur') & (df['totalFruitNumber'] <= 50)) | ((df['vineType'] == 'cane') & (df['totalFruitNumber'] <= 160)))",
]


def build_filter(group_by):
    return " & ".join(cond for cond in base_filter_conditions if group_by not in cond)


# Main plotting loop
for y_axis in y_axis_options:
    for group_by in group_by_options:
        print(f"Generating plot for y_axis={y_axis}, group_by={group_by}")
        custom_filters = build_filter(group_by)
        plot_plant_data(
            df=big_df,
            y_axis=y_axis,
            group_by=group_by,
            filters=custom_filters,
        )
