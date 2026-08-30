# Spatial organ-distribution figure writers for the FOPS CropLoad workflow.

fops_plot_internode_3d <- function(selected_scenarios, params) {
  high <- selected_scenarios[selected_scenarios$scenario_role == "high_crop_load", , drop = FALSE]
  if (nrow(high) == 0 || is.na(high$internode_array_file[[1]]) || !file.exists(high$internode_array_file[[1]])) {
    warning("High-crop-load internodeArray file is unavailable; skipping Python internode 3D plots.", call. = FALSE)
    return(invisible(NULL))
  }

  python <- Sys.which("python3")
  plot_script <- file.path(getOption("fops_cropload_dir", getwd()), "plot_internode_3d.py")
  if (!nzchar(python) || !file.exists(plot_script)) {
    warning("Python 3 or fops_cropload/plot_internode_3d.py is unavailable; skipping Python internode 3D plots.", call. = FALSE)
    return(invisible(NULL))
  }

  output_dir <- file.path(params$output_dir, "FOPS_high_crop_load_internode_3d")
  plot_label <- paste0("FOPS high crop load: ", high$scenario_label[[1]])
  args <- c(
    plot_script,
    "--internode_csv", high$internode_array_file[[1]],
    "--internode_metrics", "waterPotential,cp",
    "--snapshot_hour", as.character(params$snapshot_hour),
    "--outdir", output_dir,
    "--exact_outdir", "true",
    "--targets", "FOPS_high_crop_load_internodes",
    "--plot_label", shQuote(plot_label),
    "--view_elev", "24",
    "--view_azim", "-75",
    "--interactive", "false",
    "--histograms", "false",
    "--publication_style", "true"
  )
  # The dedicated FOPS internode panel represents the harvest snapshot unless
  # the caller explicitly requests another snapshot day.
  snapshot_day <- params$snapshot_day %||% params$harvest_day_of_year
  if (!is.null(snapshot_day) && is.finite(snapshot_day)) {
    args <- c(args, "--snapshot_doy", as.character(snapshot_day))
  }

  matplotlib_dir <- file.path(tempdir(), "matplotlib-fops-cropload")
  dir.create(matplotlib_dir, recursive = TRUE, showWarnings = FALSE)
  status <- system2(python, args = args, env = paste0("MPLCONFIGDIR=", matplotlib_dir))
  if (!identical(status, 0L)) {
    warning("Python internode 3D plotting failed with exit status ", status, ".", call. = FALSE)
  }
  invisible(output_dir)
}

fops_plot_organ_distributions <- function(spatial_result, params, formats) {
  spatial_data <- spatial_result$data
  requested_snapshot_day <- params$snapshot_day %||% params$harvest_day_of_year
  selected_snapshot_days <- unique(stats::na.omit(spatial_result$snapshot_info$selected_dayOfYear))
  selected_snapshot_text <- if (length(selected_snapshot_days) == 1) {
    as.character(selected_snapshot_days[[1]])
  } else {
    paste(selected_snapshot_days, collapse = ", ")
  }
  snapshot_caption <- if (is.finite(requested_snapshot_day) && is.finite(params$harvest_day_of_year) &&
    identical(as.numeric(requested_snapshot_day), as.numeric(params$harvest_day_of_year) - 1) &&
    length(selected_snapshot_days) == 1 && selected_snapshot_days[[1]] == requested_snapshot_day) {
    paste0("One day before harvest (DOY ", requested_snapshot_day, "). Histogram proportions are calculated separately for each crop-load treatment.")
  } else if (is.finite(requested_snapshot_day) && is.finite(params$harvest_day_of_year) &&
    identical(as.numeric(requested_snapshot_day), as.numeric(params$harvest_day_of_year)) &&
    length(selected_snapshot_days) == 1 && selected_snapshot_days[[1]] == requested_snapshot_day) {
    paste0("Harvest snapshot (DOY ", requested_snapshot_day, "). Histogram proportions are calculated separately for each crop-load treatment.")
  } else if (is.finite(requested_snapshot_day) && length(selected_snapshot_days) > 0 &&
    !all(selected_snapshot_days == requested_snapshot_day)) {
    paste0("Requested DOY ", requested_snapshot_day, "; nearest available spatial snapshot: DOY ", selected_snapshot_text,
      ". Histogram proportions are calculated separately for each crop-load treatment.")
  } else if (length(selected_snapshot_days) > 0) {
    paste0("Spatial snapshot (DOY ", selected_snapshot_text, "). Histogram proportions are calculated separately for each crop-load treatment.")
  } else {
    "Spatial snapshot. Histogram proportions are calculated separately for each crop-load treatment."
  }
  histogram_plot <- plot_spatial_histograms(spatial_data, snapshot_caption = snapshot_caption)
  save_plot_formats(
    histogram_plot,
    file.path(params$output_dir, "FOPS_crop_load_spatial_histograms"),
    formats = intersect(formats, c("svg", "png", "pdf")),
    width = 10.8,
    height = 6.5
  )

  if ("html" %in% formats) {
    write_interactive_spatial(spatial_data, params$output_dir)
  }
  internode_3d_dir <- NULL
  if (isTRUE(params$make_internode_3d)) {
    internode_3d_dir <- fops_plot_internode_3d(spatial_result$selected_scenarios, params)
  }
  invisible(list(histograms = histogram_plot, internode_3d_dir = internode_3d_dir))
}
