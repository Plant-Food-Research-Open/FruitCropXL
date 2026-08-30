# Temporal-response figure writer for the FOPS CropLoad workflow.

fops_plot_temporal_response <- function(temporal, params, formats) {
  plot <- plot_temporal(
    temporal,
    harvest_day_of_year = params$harvest_day_of_year,
    shade_postharvest = params$shade_postharvest
  )
  save_plot_formats(
    plot,
    file.path(params$output_dir, "FOPS_crop_load_temporal_water_carbon_fruit"),
    formats = formats,
    width = 9.5,
    height = 11.5
  )
  invisible(plot)
}
