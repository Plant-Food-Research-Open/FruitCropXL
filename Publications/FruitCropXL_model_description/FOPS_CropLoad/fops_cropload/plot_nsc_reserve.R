# Whole-tree and internode NSC-reserve figure writer for FOPS CropLoad.

fops_plot_nsc_reserve <- function(reserve_data, params, formats) {
  plot <- plot_full_simulation_reserve(
    reserve_data,
    harvest_day_of_year = params$harvest_day_of_year
  )
  save_plot_formats(
    plot,
    file.path(params$output_dir, "FOPS_crop_load_reserve_full_simulation"),
    formats = intersect(formats, c("svg", "png", "pdf")),
    width = 9.5,
    height = 7.5
  )
  invisible(plot)
}
