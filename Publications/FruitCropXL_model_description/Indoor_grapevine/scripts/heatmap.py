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

harvest_df_u = big_df.loc[big_df.groupby("uuid")["dayOfYear"].idxmax()]
harvest_df_u["biomassPlant_g"] = harvest_df_u["biomassPlant"] / 1000
harvest_df_u["biomassFruit_g"] = harvest_df_u["biomassFruit"] / 1000
# heatmap seems only works well with fixed system and better to fix fruit number as well
harvest_df = harvest_df_u[
    ((harvest_df_u["vineType"] == "spur") & (harvest_df_u["totalFruitNumber"] <= 50))
    # ((harvest_df_u['vineType'] == 'cane') & (harvest_df_u['totalFruitNumber'] <= 160))
]

# Choose dimensions
x_var = "Ta"
y_var = "nightTemperature"
z_var = "biomassPlant_g"
facet_var = "cca"  # The third variable to facet by

# Create a heatmap
for x_var in ["Ta", "Tmax", "Tmin", "dayTemperature", "nightTemperature"]:
    for y_var in [
        "cca",
        # "leafArea",
        # "totalFruitNumber",
        "ENDING_LEAF_NUMBER",
        "inputPAR",
    ]:
        for z_var in [
            "biomassPlant_g",
            "biomassFruit_g",
            # "phloemSugarConcentration",
            # "fraction_fruitUnloading",
            # "harvestIndex",
            # "fraction_internodeUnloading",
        ]:
            for facet_var in [
                "cca",
                # "leafArea",
                # "totalFruitNumber",
                "ENDING_LEAF_NUMBER",
                "inputPAR",
            ]:
                if y_var != facet_var:

                    facet_levels = sorted(harvest_df[facet_var].dropna().unique())
                    ncols = 2
                    nrows = (len(facet_levels) + 1) // ncols

                    fig = make_subplots(
                        rows=nrows,
                        cols=ncols,
                        subplot_titles=[
                            f"{facet_var} = {level}" for level in facet_levels
                        ],
                    )

                    for i, level in enumerate(facet_levels):
                        row = i // ncols + 1
                        col = i % ncols + 1
                        sub_df = harvest_df[harvest_df[facet_var] == level]

                        heatmap_data = sub_df.pivot_table(
                            values=z_var,
                            index=y_var,
                            columns=x_var,
                            aggfunc="median",
                        )

                        fig.add_trace(
                            go.Heatmap(
                                z=heatmap_data.values,
                                x=heatmap_data.columns,
                                y=heatmap_data.index,
                                colorscale="Viridis",
                                coloraxis="coloraxis",
                                colorbar=dict(title=z_var),
                            ),
                            row=row,
                            col=col,
                        )
                        fig.update_xaxes(title_text=x_var, row=row, col=col)
                        fig.update_yaxes(title_text=y_var, row=row, col=col)

                    fig.update_layout(
                        height=300 * nrows,
                        width=600 * ncols,
                        title=f"Faceted Heatmaps of {z_var} by {x_var} × {y_var}, faceted by {facet_var}",
                        showlegend=False,
                        font=dict(size=10),
                        xaxis=dict(dtick=5),
                        yaxis=dict(dtick=100),
                        margin=dict(
                            r=200
                        ),  # Add more right margin space (default is 80)
                    )

                    # Save to file
                    fig.write_image(
                        outdir
                        / f"faceted_heatmaps_of_{z_var}_by_{x_var}_and_{y_var}_faceted_by_{facet_var}.png",
                        width=1200,
                        height=300 * nrows,
                        scale=2,
                    )
                    print("Faceted heatmap saved.")
