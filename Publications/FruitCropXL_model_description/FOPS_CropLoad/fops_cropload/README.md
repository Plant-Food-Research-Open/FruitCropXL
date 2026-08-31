# FOPS CropLoad plotting workflow

This folder is a portable FOPS CropLoad figure workflow. It can be copied to
its own Git repository together with the FOPS input data; none of the scripts
depend on the parent project's `R/` or `scripts/` folders.

- `fops_standalone_helpers.R` contains the small set of input discovery and
  command-line helpers required by this standalone workflow.
- `prepare_cropload_data.R` contains shared input, transformation, and data-preparation helpers.
- `plot_temporal_response.R` writes the temporal water, carbon, and fruit response figure.
- `plot_organ_distributions.R` writes organ-distribution histograms.
- `plot_nsc_reserve.R` writes the whole-tree and internode NSC-reserve figure.
- `run_fops_cropload.R` is the command-line entry point.
- `plot_internode_3d.py` and `func.py` are the local Python 3D internode plotter and its helper.

For backward compatibility in the parent repository,
`scripts/plot_fops_crop_load_usecase.R` forwards to `run_fops_cropload.R`.

When `--make_spatial true` is used, `plot_organ_distributions.R` reads the
retained spatial CSVs in this folder.  If enabled, it also runs
`plot_internode_3d.py` from `internode_snapshot_plot_data.csv`.  It does not
re-extract a spatial snapshot from raw simulation outputs. Set
`--make_internode_3d false` to skip the Python 3D output. With
`--make_spatial false`, pass `--make_internode_3d true` to render only those
3D panels, without the other spatial figures.

## Portable folder layout

Keep scripts, copied FOPS data, and regenerated figures together as follows:

```text
fops_cropload/
├── run_fops_cropload.R
├── *.R
├── *.py
├── data/
│   └── FOPS_CropLoad/
│       ├── dual-field-space-FOPSCropLoad.csv
│       └── <scenario UUID>/
│           ├── plant-level-<scenario UUID>.csv
│           ├── mean-fruit-<scenario UUID>.csv
│           ├── fruitArray_<scenario UUID>.csv
│           └── internodeArray_<scenario UUID>.csv
└── output/
    └── FOPS_CropLoad_usecase/
```

Preserve the design CSV and scenario UUID directories when copying data. The
temporal and reserve figures require the `plant-level-*` and
`mean-fruit-*` files; the 3D internode panels additionally require
`internodeArray_*`; the full spatial workflow also uses `fruitArray_*`.
`output/` is safe to commit when you want versioned processed data and figures.

## Run directly

### Plot committed/prepared data

From the `FOPS_CropLoad` directory, this reads the prepared temporal and
reserve CSVs and the retained spatial snapshot. It does not read or modify
`FOPS_CropLoad_output/`.

```bash
Rscript --vanilla fops_cropload/run_fops_cropload.R \
  --regenerate_nonspatial false \
  --make_temporal true --make_full_sim_reserve true --make_spatial true \
  --make_internode_3d false \
  --format png --output_dir _qa_test_output/prepared
```

Omit `--make_internode_3d false` to additionally write the two 3D internode
panels from the retained `internode_snapshot_plot_data.csv`.

### Regenerate non-spatial summaries from raw output

The raw output is the sibling `FOPS_CropLoad_output/` directory. UUID folders
are joined to `dual-field-space-FOPSCropLoad.csv`; treatment order is never
inferred from directory order. This command regenerates only temporal and
whole-tree summary data. Spatial figures still read the retained snapshot in
`fops_cropload/`.

```bash
Rscript --vanilla fops_cropload/run_fops_cropload.R \
  --scenario_folder FOPS_CropLoad_output \
  --design_csv dual-field-space-FOPSCropLoad.csv \
  --make_temporal true --make_full_sim_reserve true --make_spatial true \
  --make_internode_3d false \
  --format png --output_dir _qa_test_output/regenerated
```

The `--scenario_folder` argument may be omitted in this repository layout.
Use a separate `--output_dir` for QA so committed prepared CSVs and manuscript
figures are not overwritten.

`build_figure8.R` similarly uses `FOPS_crop_load_spatial_low_high_data.csv`
for histogram panels and `internode_snapshot_plot_data.csv` for the two 3D
panels. It accepts explicit `--spatial-csv`, `--internode-csv`, `--output`,
and `--panel-dir` paths when a manuscript Figure 8 export is required.

## Generate individual figures

Append one of the following option sets to either command above.

### Temporal response

```bash
--make_temporal true --make_full_sim_reserve false --make_spatial false
```

Writes `FOPS_crop_load_temporal_water_carbon_fruit.*`.

### NSC reserve

```bash
--make_temporal false --make_full_sim_reserve true --make_spatial false
```

Writes `FOPS_crop_load_reserve_full_simulation.*`, with whole-tree and total-internode reserve panels.

### Organ distributions

```bash
--make_temporal false --make_full_sim_reserve false --make_spatial true
```

Writes the organ-distribution histograms and local Python 3D internode panels for the selected high crop load. Add `--make_internode_3d false` to omit only the Python 3D panels.

### High-crop-load 3D panels only

```bash
--make_temporal false --make_full_sim_reserve false --make_spatial false \
--make_internode_3d true --snapshot_day 65 --snapshot_hour 12
```

Writes `FOPS_high_crop_load_internode_3d/` without the other spatial figures.
If `--snapshot_day` is omitted, the 3D workflow uses
`--harvest_day_of_year` (65 by default).

### All figures

```bash
--make_temporal true --make_full_sim_reserve true --make_spatial true
```

## Requirements

The R workflow needs `dplyr`, `ggplot2`, `lubridate`, `patchwork`, `readr`,
`scales`, `tibble`, and `tidyr`. The optional HTML spatial outputs also need
`htmlwidgets` and `plotly`. Python 3 with `numpy`, `pandas`, and
`matplotlib` is required for the internode 3D panels.
