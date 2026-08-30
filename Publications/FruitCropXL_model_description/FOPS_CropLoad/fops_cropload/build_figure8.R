#!/usr/bin/env Rscript

# Rebuild manuscript Figure 8 from the original division of labour:
# Python draws the two 3D internode panels; R draws the four histograms.

args <- commandArgs(trailingOnly = TRUE)
arg_value <- function(name, default = NULL) {
  hit <- match(name, args)
  if (is.na(hit) || hit == length(args)) default else args[[hit + 1L]]
}

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_arg)) sub("^--file=", "", script_arg[[1]]) else "build_figure8.R"
script_dir <- dirname(normalizePath(script_path, mustWork = FALSE))
framework_dir <- normalizePath(file.path(script_dir, "..", ".."), mustWork = FALSE)

spatial_csv <- arg_value(
  "--spatial-csv",
  file.path(framework_dir, "12_FOPS_CropLoad_usecase", "FOPS_crop_load_spatial_low_high_data.csv")
)
internode_csv <- arg_value(
  "--internode-csv",
  file.path(
    "/home/jzhu/Workspace/Github/2-Functional-structural-fruit-crop-model-evaluation",
    "Model_analysis/0_Model_output/FOPS_CropLoad/Old-version",
    "629bd1e0_617c_49f0_9dc1_b9533cdd7f27",
    "internodeArray_629bd1e0_617c_49f0_9dc1_b9533cdd7f27.csv"
  )
)
output_file <- arg_value(
  "--output",
  file.path(framework_dir, "06_figures", "06B_Figure8_FOPS_crop_load_spatial_distribution.png")
)
panel_dir <- arg_value(
  "--panel-dir",
  file.path(framework_dir, "12_FOPS_CropLoad_usecase", "FOPS_600_internode_3d")
)

required <- c("dplyr", "ggplot2", "patchwork", "readr", "scales", "tibble")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Missing R packages: ", paste(missing, collapse = ", "), call. = FALSE)
}
if (!file.exists(spatial_csv)) stop("Spatial evidence CSV not found: ", spatial_csv, call. = FALSE)
if (!file.exists(internode_csv)) stop("Internode input CSV not found: ", internode_csv, call. = FALSE)

dir.create(panel_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
run_panel_dir <- tempfile("figure8-3d-panels-")
dir.create(run_panel_dir, recursive = TRUE, showWarnings = FALSE)
on.exit(unlink(run_panel_dir, recursive = TRUE, force = TRUE), add = TRUE)

python_script <- file.path(script_dir, "plot_internode_3d.py")
python <- Sys.which("python3")
if (!nzchar(python)) stop("python3 is unavailable.", call. = FALSE)

matplotlib_dir <- file.path(tempdir(), "matplotlib-figure8")
dir.create(matplotlib_dir, recursive = TRUE, showWarnings = FALSE)
python_args <- c(
  python_script,
  "--internode_csv", internode_csv,
  "--internode_metrics", "waterPotential,cp",
  "--snapshot_doy", "65",
  "--snapshot_hour", "12",
  "--outdir", run_panel_dir,
  "--exact_outdir", "true",
  "--targets", "FOPS_600_internodes",
  "--plot_label", "FOPS_600_fruits",
  "--view_elev", "24",
  "--view_azim", "-75",
  "--interactive", "false",
  "--histograms", "false",
  "--publication_style", "true"
)
python_status <- system2(
  python,
  args = python_args,
  env = paste0("MPLCONFIGDIR=", matplotlib_dir)
)
if (!identical(python_status, 0L)) {
  stop("Python 3D-panel generation failed with exit status ", python_status, ".", call. = FALSE)
}
fresh_python_outputs <- file.path(
  run_panel_dir,
  c(
    "internodes_waterPotential_3d.png",
    "internodes_Cp_3d.png",
    "internode_snapshot_diagnostics.csv"
  )
)
if (!all(file.exists(fresh_python_outputs))) {
  stop("Python completed without writing fresh 3D panels and diagnostics.", call. = FALSE)
}
generated_files <- list.files(run_panel_dir, full.names = TRUE, recursive = FALSE)
if (!all(file.copy(generated_files, panel_dir, overwrite = TRUE))) {
  stop("Could not promote fresh Python outputs to the retained panel directory.", call. = FALSE)
}

spatial_data <- readr::read_csv(spatial_csv, show_col_types = FALSE)
trait_order <- c("waterPotential", "Cp", "freshMass", "DMC")
panel_titles <- c(
  waterPotential = "(c) Internode water potential",
  Cp = "(d) Internode phloem sugar concentration",
  freshMass = "(e) Fruit fresh mass",
  DMC = "(f) Fruit dry-matter concentration"
)
x_labels <- list(
  waterPotential = expression(Water~potential~(MPa)),
  Cp = expression(c[plain("sug,o")]~(g~sugar~cm^{-3}~phloem~sap)),
  freshMass = expression(Fresh~mass~(g)),
  DMC = expression(Dry * plain("-") * matter~concentration~(g~g^{-1}))
)
treatment_labels <- c(
  low_crop_load = "Low crop load (n = 199 fruits)",
  high_crop_load = "High crop load (n = 600 fruits)"
)
treatment_colors <- c(
  "Low crop load (n = 199 fruits)" = "#0072B2",
  "High crop load (n = 600 fruits)" = "#D55E00"
)

histogram_parts <- list()
for (trait_name in trait_order) {
  trait_data <- spatial_data |>
    dplyr::filter(.data$trait == .env$trait_name, is.finite(.data$value))
  value_range <- range(trait_data$value, na.rm = TRUE)
  if (diff(value_range) == 0) value_range <- value_range + c(-0.5, 0.5)
  breaks <- seq(value_range[[1]], value_range[[2]], length.out = 31)
  for (role in names(treatment_labels)) {
    values <- trait_data$value[trait_data$scenario_role == role]
    values <- values[is.finite(values)]
    counts <- graphics::hist(
      values,
      breaks = breaks,
      plot = FALSE,
      include.lowest = TRUE,
      right = FALSE
    )$counts
    histogram_parts[[length(histogram_parts) + 1L]] <- tibble::tibble(
      trait = trait_name,
      treatment_label = treatment_labels[[role]],
      xmin = breaks[-length(breaks)],
      xmax = breaks[-1],
      proportion = counts / sum(counts)
    )
  }
}

histogram_data <- dplyr::bind_rows(histogram_parts) |>
  dplyr::mutate(
    treatment_label = factor(.data$treatment_label, levels = names(treatment_colors))
  )
common_y_max <- max(histogram_data$proportion, na.rm = TRUE) * 1.08

plots <- lapply(trait_order, function(trait_name) {
  part <- histogram_data |> dplyr::filter(.data$trait == .env$trait_name)
  ggplot2::ggplot(
    part,
    ggplot2::aes(
      xmin = .data$xmin,
      xmax = .data$xmax,
      ymin = 0,
      ymax = .data$proportion,
      fill = .data$treatment_label
    )
  ) +
    ggplot2::geom_rect(alpha = 0.48, color = "grey25", linewidth = 0.18) +
    ggplot2::scale_fill_manual(values = treatment_colors, name = NULL, drop = FALSE) +
    ggplot2::scale_y_continuous(
      limits = c(0, common_y_max),
      labels = scales::label_percent(accuracy = 1),
      expand = ggplot2::expansion(mult = c(0, 0.02))
    ) +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = c(0.025, 0.025))) +
    ggplot2::labs(title = panel_titles[[trait_name]], x = x_labels[[trait_name]], y = "Percentage of organs") +
    ggplot2::theme_bw(base_family = "serif", base_size = 11) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(color = "grey90", linewidth = 0.35),
      plot.title = ggplot2::element_text(face = "bold", hjust = 0, size = 13),
      axis.title = ggplot2::element_text(size = 13),
      legend.position = "bottom",
      legend.key.width = grid::unit(10, "mm"),
      plot.margin = ggplot2::margin(6, 12, 6, 12)
    )
})

histogram_plot <- patchwork::wrap_plots(plots, ncol = 2) +
  patchwork::plot_layout(guides = "collect", axes = "collect_y", axis_titles = "collect_y") +
  patchwork::plot_annotation(
    caption = "Harvest snapshot (138 DAFB). Internode distributions: n = 11,018 internodes per treatment.",
    theme = ggplot2::theme(
      plot.caption = ggplot2::element_text(family = "serif", hjust = 0, color = "grey30", size = 11),
      plot.margin = ggplot2::margin(6, 8, 8, 20)
    )
  ) &
  ggplot2::theme(legend.position = "bottom")

histogram_png <- file.path(panel_dir, "FOPS_crop_load_spatial_histograms.png")
ggplot2::ggsave(
  histogram_png,
  histogram_plot,
  width = 10.8,
  height = 6.5,
  units = "in",
  dpi = 300,
  bg = "white"
)

water_png <- file.path(panel_dir, "internodes_waterPotential_3d.png")
sugar_png <- file.path(panel_dir, "internodes_Cp_3d.png")
magick <- Sys.which("magick")
if (!nzchar(magick)) stop("ImageMagick 'magick' is unavailable.", call. = FALSE)

top_png <- file.path(panel_dir, "Figure8_3d_top_row.png")
top_status <- system2(
  magick,
  args = c(water_png, sugar_png, "+append", "-resize", "3240x", top_png)
)
if (!identical(top_status, 0L)) stop("ImageMagick top-row composition failed.", call. = FALSE)
compose_status <- system2(
  magick,
  args = c(top_png, histogram_png, "-append", output_file)
)
if (!identical(compose_status, 0L)) stop("ImageMagick Figure 8 composition failed.", call. = FALSE)

message("Wrote Figure 8: ", normalizePath(output_file, winslash = "/", mustWork = TRUE))
message("3D source: ", normalizePath(internode_csv, winslash = "/", mustWork = TRUE))
message("Histogram source: ", normalizePath(spatial_csv, winslash = "/", mustWork = TRUE))
