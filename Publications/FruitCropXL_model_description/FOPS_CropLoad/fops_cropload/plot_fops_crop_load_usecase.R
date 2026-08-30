#!/usr/bin/env Rscript

args_all <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args_all, value = TRUE)
script_path <- if (length(file_arg) > 0) {
  normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/", mustWork = FALSE)
} else {
  ""
}
script_dir <- if (nzchar(script_path)) dirname(script_path) else getwd()
report_dir <- normalizePath(file.path(script_dir, ".."), winslash = "/", mustWork = TRUE)
setwd(report_dir)

source(file.path("scripts", "output_name_utils.R"))
source(file.path("R", "io_load_run.R"))
source(file.path("R", "generic_compare.R"))
source(file.path("R", "apple_crop_load_plots.R"))
source(file.path("R", "apple_crop_load_spatial_plots.R"))

required_packages <- function(require_html = FALSE) {
  pkgs <- c("dplyr", "ggplot2", "lubridate", "patchwork", "readr", "scales", "tibble", "tidyr")
  if (isTRUE(require_html)) {
    pkgs <- c(pkgs, "htmlwidgets", "plotly")
  }
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing) > 0) {
    stop("Missing required R packages: ", paste(missing, collapse = ", "), call. = FALSE)
  }
  invisible(lapply(pkgs, function(pkg) {
    suppressPackageStartupMessages(library(pkg, character.only = TRUE))
  }))
}

split_csv <- function(x, default = character()) {
  if (is.null(x) || length(x) == 0 || !nzchar(trimws(as.character(x[[1]])))) {
    return(default)
  }
  vals <- trimws(unlist(strsplit(as.character(x[[1]]), ",", fixed = TRUE), use.names = FALSE))
  vals[nzchar(vals)]
}

parse_bool <- function(x, default = TRUE) {
  if (is.null(x) || length(x) == 0 || !nzchar(trimws(as.character(x[[1]])))) {
    return(default)
  }
  txt <- tolower(trimws(as.character(x[[1]])))
  if (txt %in% c("true", "t", "1", "yes", "y")) {
    return(TRUE)
  }
  if (txt %in% c("false", "f", "0", "no", "n")) {
    return(FALSE)
  }
  default
}

parse_num_or_null <- function(x) {
  if (is.null(x) || length(x) == 0 || !nzchar(trimws(as.character(x[[1]])))) {
    return(NULL)
  }
  val <- suppressWarnings(as.numeric(x[[1]]))
  if (!is.finite(val)) NULL else val
}

norm_uuid <- function(x) {
  normalize_generic_uuid(x)
}

norm_name <- function(x) {
  tolower(gsub("[^a-z0-9]+", "", trimws(as.character(x))))
}

resolve_col <- function(col_names, candidates, required = FALSE, context = "") {
  hit <- resolve_apple_column(col_names, candidates)
  if (required && is.na(hit)) {
    stop(
      context,
      "\nAvailable columns: ", paste(col_names, collapse = ", "),
      "\nExpected one of: ", paste(candidates, collapse = ", "),
      call. = FALSE
    )
  }
  hit
}

resolve_exact_col <- function(col_names, candidates) {
  nm <- as.character(col_names)
  nn <- norm_name(nm)
  cc <- norm_name(candidates)
  idx <- match(cc, nn)
  idx <- idx[!is.na(idx)]
  if (length(idx) > 0) {
    return(nm[idx[[1]]])
  }
  NA_character_
}

resolve_internode_cp_col <- function(col_names) {
  exact <- resolve_exact_col(
    col_names,
    c("cpt", "Cpt", "cpb", "Cp", "C_p", "phloemSugarConcentration", "Cpm", "c", "cx", "carbonConcentration")
  )
  if (!is.na(exact)) {
    return(exact)
  }
  resolve_col(col_names, c("phloemSugarConcentration", "carbonConcentration"))
}

convert_internode_phi_to_sugar_concentration <- function(values, source_col) {
  raw <- suppressWarnings(as.numeric(values))
  source <- norm_name(source_col)
  if (source %in% c("cpb", "cpt")) {
    carbon_fraction_sorbitol <- 0.3956
    carbon_fraction_sucrose <- 0.4210526
    fraction_sorbitol <- 0.75
    sugar_per_carbon <-
      (1 - fraction_sorbitol) / carbon_fraction_sucrose +
      fraction_sorbitol / carbon_fraction_sorbitol
    return(ifelse(is.finite(raw) & raw >= 0, sqrt(2 * raw) * sugar_per_carbon, NA_real_))
  }
  raw
}

resolve_fops_design_csv <- function(scenario_folder,
                                    design_csv = NULL,
                                    design_csv_pattern = "dual-field-space-*.csv") {
  root <- resolve_generic_dir_hint(scenario_folder)
  if (!dir.exists(root)) {
    stop("Scenario folder not found: ", root, call. = FALSE)
  }

  candidate_dirs <- unique(c(
    root,
    file.path(root, basename(root)),
    list.dirs(root, full.names = TRUE, recursive = FALSE)
  ))
  candidate_dirs <- candidate_dirs[dir.exists(candidate_dirs)]

  if (!generic_param_is_null(design_csv)) {
    design_csv <- trimws(as.character(design_csv[[1]]))
    candidates <- if (grepl("^/", design_csv)) {
      design_csv
    } else {
      file.path(candidate_dirs, design_csv)
    }
    hit <- candidates[file.exists(candidates) & !dir.exists(candidates)][1]
    if (!is.na(hit)) {
      return(normalizePath(hit, winslash = "/", mustWork = FALSE))
    }
    stop(
      "Design CSV not found: ", design_csv,
      "\nSearched in: ", paste(candidate_dirs, collapse = ", "),
      call. = FALSE
    )
  }

  hits <- unlist(lapply(candidate_dirs, function(d) Sys.glob(file.path(d, design_csv_pattern))), use.names = FALSE)
  hits <- unique(hits[file.exists(hits) & !dir.exists(hits)])
  if (length(hits) == 0) {
    stop("No design CSV matching `", design_csv_pattern, "` found under: ", root, call. = FALSE)
  }
  info <- file.info(hits)
  hits[order(info$mtime, decreasing = TRUE)][[1]]
}

find_scenario_file <- function(scenario_dir, uuid, stems) {
  if (is.null(scenario_dir) || is.na(scenario_dir) || !dir.exists(scenario_dir)) {
    return(NA_character_)
  }
  uuid_dash <- norm_uuid(uuid)
  uuid_us <- gsub("-", "_", uuid_dash, fixed = TRUE)
  patterns <- unlist(lapply(stems, function(stem) {
    c(
      paste0(stem, uuid_us, ".csv"),
      paste0(stem, uuid_dash, ".csv"),
      paste0(stem, "*.csv"),
      paste0("*", stem, "*", uuid_us, "*.csv"),
      paste0("*", stem, "*", uuid_dash, "*.csv")
    )
  }), use.names = FALSE)
  hits <- unique(unlist(lapply(patterns, function(p) Sys.glob(file.path(scenario_dir, p))), use.names = FALSE))
  hits <- hits[file.exists(hits) & !dir.exists(hits)]
  if (length(hits) == 0) {
    return(NA_character_)
  }
  hits[order(nchar(basename(hits)), decreasing = FALSE)][[1]]
}

build_scenario_mapping <- function(scenario_folder,
                                   design_csv,
                                   design_csv_pattern,
                                   crop_load_col) {
  design_path <- resolve_fops_design_csv(scenario_folder, design_csv, design_csv_pattern)
  scenario_root <- dirname(design_path)
  design <- read_generic_design(design_path)
  crop_col <- resolve_crop_load_column(design, crop_load_col = crop_load_col)
  if (is.na(crop_col)) {
    stop(
      "Could not resolve crop-load column in design CSV.\nAvailable columns: ",
      paste(names(design), collapse = ", "),
      "\nExpected a column like CropLoad, desiredFruitNumber_postPrune, or fruitTargetPerTree.",
      call. = FALSE
    )
  }

  crop_load <- suppressWarnings(as.numeric(design[[crop_col]]))
  if (all(is.na(crop_load))) {
    crop_load <- suppressWarnings(as.numeric(gsub("[^0-9.]+", "", as.character(design[[crop_col]]))))
  }
  if (all(is.na(crop_load))) {
    stop("Crop-load values could not be parsed from column: ", crop_col, call. = FALSE)
  }
  design$CropLoad <- crop_load
  design$crop_load_label <- paste0(scales::comma(crop_load, accuracy = 1), " fruits")
  design$scenario_label <- design$crop_load_label

  scenario_info <- discover_generic_scenario_dirs(scenario_root, design)
  scenario_info <- scenario_info[order(scenario_info$CropLoad, scenario_info$scenario_uuid), , drop = FALSE]
  scenario_info$crop_load_label <- factor(
    scenario_info$crop_load_label,
    levels = unique(as.character(scenario_info$crop_load_label[order(scenario_info$CropLoad)]))
  )

  map <- scenario_info %>%
    dplyr::mutate(
      uuid = .data$scenario_uuid,
      scenario_folder = .data$scenario_dir,
      CropLoad = suppressWarnings(as.numeric(.data$CropLoad)),
      scenario_label = as.character(.data$crop_load_label)
    )

  map$plant_file <- vapply(seq_len(nrow(map)), function(i) {
    find_scenario_file(map$scenario_folder[[i]], map$uuid[[i]], c("plant-level-"))
  }, character(1))
  map$mean_fruit_file <- vapply(seq_len(nrow(map)), function(i) {
    find_scenario_file(map$scenario_folder[[i]], map$uuid[[i]], c("mean-fruit-"))
  }, character(1))
  map$fruit_array_file <- vapply(seq_len(nrow(map)), function(i) {
    find_scenario_file(map$scenario_folder[[i]], map$uuid[[i]], c("fruitArray_", "fruitOrganArray_"))
  }, character(1))
  map$internode_array_file <- vapply(seq_len(nrow(map)), function(i) {
    find_scenario_file(map$scenario_folder[[i]], map$uuid[[i]], c("internodeArray_"))
  }, character(1))
  map$leaf_array_file <- vapply(seq_len(nrow(map)), function(i) {
    find_scenario_file(map$scenario_folder[[i]], map$uuid[[i]], c("leafArray_"))
  }, character(1))
  map$root_file <- vapply(seq_len(nrow(map)), function(i) {
    find_scenario_file(map$scenario_folder[[i]], map$uuid[[i]], c("root-level-"))
  }, character(1))

  attr(map, "design_csv") <- design_path
  attr(map, "scenario_root") <- scenario_root
  attr(map, "crop_load_col") <- crop_col
  map %>%
    dplyr::select(
      dplyr::any_of(c(
        "uuid", "scenario_folder", "CropLoad", "scenario_label",
        "plant_file", "mean_fruit_file", "fruit_array_file",
        "internode_array_file", "leaf_array_file", "root_file",
        "status"
      )),
      dplyr::everything()
    )
}

read_csv_table <- function(path, kind = "table") {
  if (is.null(path) || is.na(path) || !file.exists(path)) {
    return(tibble::tibble())
  }
  readr::read_csv(path, show_col_types = FALSE, progress = FALSE)
}

normalise_time <- function(df, tz = "Pacific/Auckland") {
  out <- df
  if ("timestamp" %in% names(out)) {
    out$datetime <- suppressWarnings(lubridate::ymd_hms(out$timestamp, tz = tz, quiet = TRUE))
    missing <- is.na(out$datetime)
    if (any(missing)) {
      out$datetime[missing] <- suppressWarnings(as.POSIXct(out$timestamp[missing], tz = tz))
    }
    if (!("dayOfYear" %in% names(out))) {
      out$dayOfYear <- lubridate::yday(out$datetime)
    }
    if (!("hourOfDay" %in% names(out))) {
      out$hourOfDay <- lubridate::hour(out$datetime)
    }
    if (!("date" %in% names(out))) {
      out$date <- as.Date(out$datetime, tz = tz)
    }
  }
  if ("dayOfYear" %in% names(out)) {
    out$dayOfYear <- suppressWarnings(as.numeric(out$dayOfYear))
  }
  if ("hourOfDay" %in% names(out)) {
    out$hourOfDay <- suppressWarnings(as.numeric(out$hourOfDay))
  }
  out
}

time_col_for_daily <- function(df) {
  if ("dayOfYear" %in% names(df)) {
    return("dayOfYear")
  }
  if ("seasonDay" %in% names(df)) {
    return("seasonDay")
  }
  if ("date" %in% names(df)) {
    return("date")
  }
  NA_character_
}

filter_period <- function(df, start = NULL, end = NULL) {
  if (is.null(df) || nrow(df) == 0) {
    return(df)
  }
  tc <- time_col_for_daily(df)
  if (is.na(tc)) {
    return(df)
  }
  out <- df
  vals <- if (identical(tc, "date")) as.Date(out[[tc]]) else suppressWarnings(as.numeric(out[[tc]]))
  keep <- rep(TRUE, nrow(out))
  if (!is.null(start)) {
    keep <- keep & !is.na(vals) & vals >= suppressWarnings(as.numeric(start))
  }
  if (!is.null(end)) {
    keep <- keep & !is.na(vals) & vals <= suppressWarnings(as.numeric(end))
  }
  out[keep, , drop = FALSE]
}

summary_fun <- function(x, aggregation) {
  vals <- suppressWarnings(as.numeric(x))
  vals <- vals[is.finite(vals)]
  if (length(vals) == 0) {
    return(NA_real_)
  }
  switch(
    aggregation,
    daily_sum = sum(vals),
    daily_min = min(vals),
    daily_max = max(vals),
    daily_sd = stats::sd(vals),
    daily_mean = mean(vals),
    mean(vals)
  )
}

fops_crop_load_palette <- function(levels) {
  fixed <- c(
    "199 fruits" = "#0B7285",
    "300 fruits" = "#2F9E44",
    "400 fruits" = "#B08D00",
    "500 fruits" = "#F08C00",
    "600 fruits" = "#D9487A"
  )
  missing <- setdiff(levels, names(fixed))
  if (length(missing) > 0) {
    extra <- c("#009E73", "#56B4E9", "#A6761D", "#666666")
    fixed <- c(fixed, stats::setNames(rep(extra, length.out = length(missing)), missing))
  }
  fixed[levels]
}

fops_crop_load_linetypes <- function(levels) {
  fixed <- c(
    "199 fruits" = "solid",
    "300 fruits" = "longdash",
    "400 fruits" = "dashed",
    "500 fruits" = "dotdash",
    "600 fruits" = "twodash"
  )
  missing <- setdiff(levels, names(fixed))
  if (length(missing) > 0) {
    extra <- c("solid", "longdash", "dashed", "dotdash", "twodash")
    fixed <- c(fixed, stats::setNames(rep(extra, length.out = length(missing)), missing))
  }
  fixed[levels]
}

calc_days_after_full_bloom <- function(day_of_year,
                                       full_bloom_doy = 292,
                                       days_in_bloom_year = 365) {
  day_of_year <- suppressWarnings(as.numeric(day_of_year))
  dplyr::case_when(
    is.na(day_of_year) ~ NA_real_,
    day_of_year >= full_bloom_doy ~ day_of_year - full_bloom_doy,
    day_of_year < full_bloom_doy ~ days_in_bloom_year - full_bloom_doy + day_of_year,
    TRUE ~ NA_real_
  )
}

normalize_x_axis_mode <- function(x) {
  mode <- toupper(trimws(as.character(x %||% "DAFB")))
  if (mode %in% c("DAFB", "DOY")) {
    return(mode)
  }
  if (tolower(mode) == "simulation_day") {
    return("simulation_day")
  }
  "DAFB"
}

aggregate_daily <- function(df, variable, aggregation, map_row, start = NULL, end = NULL) {
  if (is.null(df) || nrow(df) == 0 || !(variable %in% names(df))) {
    return(tibble::tibble())
  }
  work <- normalise_time(df)
  work <- filter_period(work, start = start, end = end)
  tc <- time_col_for_daily(work)
  if (is.na(tc)) {
    stop("No daily time column available in file: ", map_row$scenario_folder, call. = FALSE)
  }
  work$.value <- suppressWarnings(as.numeric(work[[variable]]))
  aggregated <- work %>%
    dplyr::group_by(.data[[tc]]) %>%
    dplyr::summarise(value = summary_fun(.data$.value, aggregation), .groups = "drop") %>%
    dplyr::rename(time_value = dplyr::all_of(tc)) %>%
    dplyr::mutate(
      time_col = tc,
      uuid = map_row$uuid,
      CropLoad = map_row$CropLoad,
      crop_load_label = map_row$scenario_label,
      source_variable = variable,
      aggregation = aggregation
    )
  if ("date" %in% names(work)) {
    date_lookup <- work %>%
      dplyr::group_by(.data[[tc]]) %>%
      dplyr::summarise(date = min(as.Date(.data$date), na.rm = TRUE), .groups = "drop") %>%
      dplyr::rename(time_value = dplyr::all_of(tc))
    aggregated <- dplyr::left_join(aggregated, date_lookup, by = "time_value")
  }
  aggregated
}

get_daily_panel <- function(mapping,
                            table_col,
                            candidates,
                            aggregation,
                            panel,
                            label,
                            y_label,
                            start = NULL,
                            end = NULL,
                            transform = identity,
                            fallback_note = NULL) {
  parts <- list()
  missing <- list()
  for (i in seq_len(nrow(mapping))) {
    row <- mapping[i, , drop = FALSE]
    path <- row[[table_col]][[1]]
    df <- read_csv_table(path)
    if (nrow(df) == 0) {
      missing[[length(missing) + 1]] <- paste0(row$scenario_label, ": missing ", table_col)
      next
    }
    var <- resolve_col(names(df), candidates)
    if (is.na(var)) {
      missing[[length(missing) + 1]] <- paste0(row$scenario_label, ": missing one of ", paste(candidates, collapse = "/"))
      next
    }
    agg <- aggregate_daily(df, var, aggregation, row, start = start, end = end)
    if (nrow(agg) > 0) {
      agg$value <- transform(agg$value)
      agg$panel <- panel
      agg$panel_title <- paste0("(", tolower(panel), ") ", label)
      agg$panel_label <- agg$panel_title
      agg$y_label <- y_label
      agg$fallback_note <- fallback_note %||% ""
      parts[[length(parts) + 1]] <- agg
    }
  }
  out <- dplyr::bind_rows(parts)
  attr(out, "missing") <- paste(missing, collapse = "; ")
  out
}

build_water_flux_panel <- function(mapping, start = NULL, end = NULL) {
  parts <- list()
  missing <- list()

  for (i in seq_len(nrow(mapping))) {
    row <- mapping[i, , drop = FALSE]
    df <- read_csv_table(row$plant_file[[1]])
    if (nrow(df) == 0) {
      missing[[length(missing) + 1]] <- paste0(row$scenario_label, ": missing plant_file")
      next
    }
    var <- resolve_col(names(df), c("waterFlux_optimized"))
    if (is.na(var)) {
      missing[[length(missing) + 1]] <- paste0(row$scenario_label, ": missing waterFlux_optimized")
      next
    }
    df$hourly_WaterFlux_L_plant_h <- suppressWarnings(as.numeric(df[[var]])) * 3600 / 1000000
    agg <- aggregate_daily(df, "hourly_WaterFlux_L_plant_h", "daily_max", row, start = start, end = end)
    if (nrow(agg) > 0) {
      agg$panel <- "B"
      agg$panel_title <- "(b) Daily maximum water flux"
      agg$panel_label <- agg$panel_title
      agg$y_label <- "Water flux (L tree^-1 h^-1)"
      agg$source_variable <- "waterFlux_optimized"
      agg$aggregation <- "daily_max"
      agg$fallback_note <- "waterFlux_optimized converted to L tree^-1 h^-1 as value * 3600 / 1000000, then daily maximum was used"
      parts[[length(parts) + 1]] <- agg
    }
  }

  out <- dplyr::bind_rows(parts)
  attr(out, "missing") <- paste(missing, collapse = "; ")
  out
}

build_fruit_fw_panel <- function(mapping, start = NULL, end = NULL) {
  parts <- list()
  for (i in seq_len(nrow(mapping))) {
    row <- mapping[i, , drop = FALSE]
    df <- read_csv_table(row$mean_fruit_file[[1]])
    if (nrow(df) == 0 || !("meanFruitFW" %in% names(df))) {
      next
    }
    mean_df <- aggregate_daily(df, "meanFruitFW", "daily_mean", row, start = start, end = end)
    mean_df$value <- mean_df$value / 1000
    sd_df <- if ("meanFruitFW_sd" %in% names(df)) {
      aggregate_daily(df, "meanFruitFW_sd", "daily_mean", row, start = start, end = end) %>%
        dplyr::transmute(uuid, time_value, sd_value = value / 1000)
    } else {
      tibble::tibble(uuid = character(), time_value = numeric(), sd_value = numeric())
    }
    out <- dplyr::left_join(mean_df, sd_df, by = c("uuid", "time_value")) %>%
      dplyr::mutate(
        ymin = ifelse(is.finite(.data$sd_value), pmax(0, .data$value - .data$sd_value), NA_real_),
        ymax = ifelse(is.finite(.data$sd_value), .data$value + .data$sd_value, NA_real_),
        panel = "E",
        panel_title = "(e) Mean fruit fresh mass",
        panel_label = .data$panel_title,
        y_label = "Mean fruit fresh mass (g fruit^-1)",
        source_variable = "meanFruitFW",
        aggregation = "daily_mean",
        fallback_note = "meanFruitFW and meanFruitFW_sd converted from mg fruit^-1 to g fruit^-1"
      )
    parts[[length(parts) + 1]] <- out
  }
  dplyr::bind_rows(parts)
}

build_fruit_dmc_panel <- function(mapping, start = NULL, end = NULL) {
  parts <- list()
  for (i in seq_len(nrow(mapping))) {
    row <- mapping[i, , drop = FALSE]
    df <- read_csv_table(row$mean_fruit_file[[1]])
    if (nrow(df) == 0) {
      next
    }
    if ("DMC" %in% names(df)) {
      out <- aggregate_daily(df, "DMC", "daily_mean", row, start = start, end = end)
      src <- "DMC"
    } else if (all(c("meanFruitDW", "meanFruitFW") %in% names(df))) {
      work <- normalise_time(df)
      work$DMC_calc <- suppressWarnings(as.numeric(work$meanFruitDW) / as.numeric(work$meanFruitFW))
      work$DMC_calc[!is.finite(work$DMC_calc)] <- NA_real_
      out <- aggregate_daily(work, "DMC_calc", "daily_mean", row, start = start, end = end)
      src <- "DMC_calc"
    } else {
      next
    }
    dmc_sd <- tibble::tibble(uuid = character(), time_value = numeric(), sd_value = numeric())
    if (all(c("meanFruitDW", "meanFruitFW", "meanFruitDW_sd", "meanFruitFW_sd") %in% names(df))) {
      sd_work <- normalise_time(df)
      mean_dw <- suppressWarnings(as.numeric(sd_work$meanFruitDW))
      mean_fw <- suppressWarnings(as.numeric(sd_work$meanFruitFW))
      sd_dw <- suppressWarnings(as.numeric(sd_work$meanFruitDW_sd))
      sd_fw <- suppressWarnings(as.numeric(sd_work$meanFruitFW_sd))
      sd_work$DMC_sd_calc <- sqrt((sd_dw / mean_fw)^2 + ((mean_dw * sd_fw) / (mean_fw^2))^2)
      sd_work$DMC_sd_calc[!is.finite(sd_work$DMC_sd_calc)] <- NA_real_
      dmc_sd <- aggregate_daily(sd_work, "DMC_sd_calc", "daily_mean", row, start = start, end = end) %>%
        dplyr::transmute(uuid, time_value, sd_value = value)
    }
    out <- dplyr::left_join(out, dmc_sd, by = c("uuid", "time_value")) %>%
      dplyr::mutate(
        ymin = ifelse(is.finite(.data$sd_value), pmax(0, .data$value - .data$sd_value), NA_real_),
        ymax = ifelse(is.finite(.data$sd_value), .data$value + .data$sd_value, NA_real_)
      )
    out <- out %>%
      dplyr::mutate(
        panel = "F",
        panel_title = "(f) Fruit dry matter concentration",
        panel_label = .data$panel_title,
        y_label = "Fruit dry matter concentration (g g^-1)",
        source_variable = src,
        fallback_note = dplyr::case_when(
          is.finite(.data$sd_value) ~ "DMC calculated as meanFruitDW / meanFruitFW; ribbon uses propagated SD from meanFruitDW_sd and meanFruitFW_sd",
          src == "DMC_calc" ~ "DMC calculated as meanFruitDW / meanFruitFW",
          TRUE ~ ""
        )
      )
    parts[[length(parts) + 1]] <- out
  }
  dplyr::bind_rows(parts)
}

build_total_fruit_biomass_panel <- function(mapping, start = NULL, end = NULL) {
  preferred <- get_daily_panel(
    mapping,
    "mean_fruit_file",
    c("totalFruitFW_tree_kg"),
    "daily_mean",
    "G",
    "Total fruit fresh mass",
    "Total fruit fresh mass (kg tree^-1)",
    start,
    end,
    fallback_note = "Preferred fruit:totalFruitFW_tree_kg"
  )
  if (nrow(preferred) > 0) {
    return(preferred)
  }
  parts <- list()
  missing <- list()
  for (i in seq_len(nrow(mapping))) {
    row <- mapping[i, , drop = FALSE]
    df <- read_csv_table(row$mean_fruit_file[[1]])
    if (nrow(df) == 0 || !all(c("meanFruitFW", "totalFruitNumber") %in% names(df))) {
      missing[[length(missing) + 1]] <- paste0(row$scenario_label, ": missing totalFruitFW_tree_kg and cannot calculate from meanFruitFW * totalFruitNumber")
      next
    }
    df$totalFruitFW_tree_kg_calc <- suppressWarnings(as.numeric(df$meanFruitFW) * as.numeric(df$totalFruitNumber) / 1000000)
    agg <- aggregate_daily(df, "totalFruitFW_tree_kg_calc", "daily_mean", row, start = start, end = end)
    if (nrow(agg) > 0) {
      agg$panel <- "G"
      agg$panel_title <- "(g) Total fruit fresh mass"
      agg$panel_label <- agg$panel_title
      agg$y_label <- "Total fruit fresh mass (kg tree^-1)"
      agg$source_variable <- "meanFruitFW * totalFruitNumber"
      agg$aggregation <- "daily_mean"
      agg$fallback_note <- "Calculated as meanFruitFW (mg fruit^-1) * totalFruitNumber / 1000000"
      parts[[length(parts) + 1]] <- agg
    }
  }
  out <- dplyr::bind_rows(parts)
  attr(out, "missing") <- paste(missing, collapse = "; ")
  if (nrow(out) == 0) {
    warning("totalFruitFW_tree_kg not found; total fruit fresh biomass panel omitted because no verified fresh-biomass conversion was available.", call. = FALSE)
  }
  out
}

build_total_fruit_dry_mass_panel <- function(mapping, start = NULL, end = NULL) {
  preferred <- get_daily_panel(
    mapping,
    "mean_fruit_file",
    c("totalFruitDW_tree_kg"),
    "daily_mean",
    "H",
    "Total fruit dry mass",
    "Total fruit dry mass (kg tree^-1)",
    start,
    end,
    fallback_note = "Preferred fruit:totalFruitDW_tree_kg"
  )
  if (nrow(preferred) > 0) {
    return(preferred)
  }
  parts <- list()
  for (i in seq_len(nrow(mapping))) {
    row <- mapping[i, , drop = FALSE]
    df <- read_csv_table(row$mean_fruit_file[[1]])
    if (nrow(df) == 0 || !all(c("meanFruitDW", "totalFruitNumber") %in% names(df))) {
      next
    }
    df$totalFruitDW_tree_kg_calc <- suppressWarnings(as.numeric(df$meanFruitDW) * as.numeric(df$totalFruitNumber) / 1000000)
    agg <- aggregate_daily(df, "totalFruitDW_tree_kg_calc", "daily_mean", row, start = start, end = end)
    if (nrow(agg) > 0) {
      agg$panel <- "H"
      agg$panel_title <- "(h) Total fruit dry mass"
      agg$panel_label <- agg$panel_title
      agg$y_label <- "Total fruit dry mass (kg tree^-1)"
      agg$source_variable <- "meanFruitDW * totalFruitNumber"
      agg$aggregation <- "daily_mean"
      agg$fallback_note <- "Calculated as meanFruitDW (mg fruit^-1) * totalFruitNumber / 1000000"
      parts[[length(parts) + 1]] <- agg
    }
  }
  dplyr::bind_rows(parts)
}

build_internode_nsc_panel <- function(mapping, start = NULL, end = NULL) {
  get_daily_panel(
    mapping,
    "plant_file",
    c("internodeNSC", "cordonNSC"),
    "daily_mean",
    "H",
    "Internode NSC",
    "Internode NSC (g C plant^-1)",
    start,
    end,
    transform = function(x) x / 1000,
    fallback_note = "internodeNSC converted from mg plant^-1 to gC plant^-1"
  )
}

add_temporal_x_axis <- function(temporal,
                                x_axis_mode = "DAFB",
                                dafb_start = 34,
                                dafb_end = NULL,
                                full_bloom_doy = 292,
                                days_in_bloom_year = 365,
                                full_bloom_date = "2021-10-19",
                                harvest_day_of_year = 65,
                                plot_period_start = NULL,
                                plot_period_end = NULL) {
  if (nrow(temporal) == 0) {
    return(temporal)
  }
  mode <- normalize_x_axis_mode(x_axis_mode)
  full_bloom_date <- as.Date(full_bloom_date %||% "2021-10-19")
  if (is.null(dafb_end)) {
    dafb_end <- calc_days_after_full_bloom(
      day_of_year = harvest_day_of_year,
      full_bloom_doy = full_bloom_doy,
      days_in_bloom_year = days_in_bloom_year
    )
  }

  out <- temporal %>%
    dplyr::mutate(
      dayOfYear = suppressWarnings(as.numeric(.data$time_value)),
      date_value = if ("date" %in% names(.)) as.Date(.data$date) else as.Date(NA),
      days_after_full_bloom_doy = calc_days_after_full_bloom(
        day_of_year = .data$dayOfYear,
        full_bloom_doy = full_bloom_doy,
        days_in_bloom_year = days_in_bloom_year
      ),
      days_after_full_bloom_date = ifelse(
        !is.na(.data$date_value) & !is.na(full_bloom_date),
        as.numeric(.data$date_value - full_bloom_date),
        NA_real_
      ),
      days_after_full_bloom = dplyr::if_else(
        is.finite(.data$days_after_full_bloom_date),
        .data$days_after_full_bloom_date,
        .data$days_after_full_bloom_doy
      ),
      simulation_day = as.numeric(dplyr::dense_rank(.data$dayOfYear)),
      x_axis_mode = mode,
      full_bloom_doy = full_bloom_doy,
      days_in_bloom_year = days_in_bloom_year,
      full_bloom_date = as.character(full_bloom_date)
    )

  if (mode == "DAFB") {
    out$x_value <- out$days_after_full_bloom
    out$x_label <- "Days after full bloom"
    out$temporal_x_basis <- ifelse(
      is.finite(out$days_after_full_bloom_date),
      "date_minus_full_bloom_date",
      "wrapped_dayOfYear_minus_full_bloom_doy"
    )
  } else if (mode == "DOY") {
    out$x_value <- out$dayOfYear
    out$x_label <- "Day of year"
    out$temporal_x_basis <- "dayOfYear_with_new_year_wrap_filter"
  } else {
    out$x_value <- out$simulation_day
    out$x_label <- "Day of simulation"
    out$temporal_x_basis <- "dense_rank_dayOfYear"
  }

  if (mode == "DAFB") {
    out <- out %>%
      dplyr::filter(.data$days_after_full_bloom >= dafb_start, .data$days_after_full_bloom <= dafb_end)
  } else if (mode == "DOY") {
    start <- plot_period_start %||% 326
    end <- plot_period_end %||% 26
    if (start > end) {
      out <- out %>% dplyr::filter(.data$dayOfYear >= start | .data$dayOfYear <= end)
    } else {
      out <- out %>% dplyr::filter(.data$dayOfYear >= start, .data$dayOfYear <= end)
    }
  } else {
    start <- plot_period_start %||% 1
    end <- plot_period_end %||% 65
    out <- out %>% dplyr::filter(.data$simulation_day >= start, .data$simulation_day <= end)
  }
  out
}

build_temporal_data <- function(mapping,
                                x_axis_mode = "DAFB",
                                dafb_start = 34,
                                dafb_end = NULL,
                                full_bloom_doy = 292,
                                days_in_bloom_year = 365,
                                full_bloom_date = "2021-10-19",
                                harvest_day_of_year = 65,
                                plot_period_start = NULL,
                                plot_period_end = NULL) {
  panels <- list(
    get_daily_panel(mapping, "plant_file", c("meanAnet"), "daily_max", "A", "Daily maximum net photosynthesis", "A_net (umol CO2 m^-2 s^-1)", NULL, NULL, fallback_note = "meanAnet used directly, then daily maximum was used"),
    build_water_flux_panel(mapping, start = NULL, end = NULL),
    get_daily_panel(mapping, "plant_file", c("xylemWaterPotential"), "daily_min", "C", "Daily minimum PlantBase xylem water potential", "psi_PB (MPa)", NULL, NULL),
    get_daily_panel(mapping, "plant_file", c("phloemSugarConcentration"), "daily_mean", "D", "PlantBase phloem sugar concentration", "c_sug,PB (g sugar cm^-3 phloem sap)", NULL, NULL),
    build_fruit_fw_panel(mapping, NULL, NULL),
    build_fruit_dmc_panel(mapping, NULL, NULL),
    build_total_fruit_biomass_panel(mapping, NULL, NULL),
    build_total_fruit_dry_mass_panel(mapping, NULL, NULL)
  )

  temporal <- dplyr::bind_rows(panels)
  temporal <- add_temporal_x_axis(
    temporal,
    x_axis_mode = x_axis_mode,
    dafb_start = dafb_start,
    dafb_end = dafb_end,
    full_bloom_doy = full_bloom_doy,
    days_in_bloom_year = days_in_bloom_year,
    full_bloom_date = full_bloom_date,
    harvest_day_of_year = harvest_day_of_year,
    plot_period_start = plot_period_start,
    plot_period_end = plot_period_end
  )
  temporal$crop_load_label <- factor(as.character(temporal$crop_load_label), levels = unique(mapping$scenario_label[order(mapping$CropLoad)]))
  temporal$panel_label <- factor(
    temporal$panel_label,
    levels = c(
      "(a) Daily maximum net photosynthesis",
      "(b) Daily maximum water flux",
      "(c) Daily minimum PlantBase xylem water potential",
      "(d) PlantBase phloem sugar concentration",
      "(e) Mean fruit fresh mass",
      "(f) Fruit dry matter concentration",
      "(g) Total fruit fresh mass",
      "(h) Total fruit dry mass"
    )
  )
  temporal
}

fops_temporal_axis_label <- function(label) {
  switch(
    label,
    "A_net (g C plant^-1 h^-1)" = expression(A[net]~(g~C~tree^{-1}~h^{-1})),
    "A_net (umol CO2 m^-2 s^-1)" = expression(A[net]~(mu*mol~CO[2]~m^{-2}~s^{-1})),
    "Water flux (L plant^-1 h^-1)" = expression(Water~flux~(L~tree^{-1}~h^{-1})),
    "Water flux (L tree^-1 h^-1)" = expression(Water~flux~(L~tree^{-1}~h^{-1})),
    "psi_xylem (MPa)" = expression(psi[xylem]~(MPa)),
    "C_p (g sugar cm^-3)" = expression(c[sug*",PB"]~(g~sugar~cm^{-3}~phloem~sap)),
    "C_sug,PB (g sugar g^-1 solution)" = expression(c[sug*",PB"]~(g~sugar~cm^{-3}~phloem~sap)),
    "c_sug,PB (g sugar cm^-3 phloem sap)" = expression(c[sug*",PB"]~(g~sugar~cm^{-3}~phloem~sap)),
    "Mean fruit fresh mass (g fruit^-1)" = expression(Mean~fruit~fresh~mass~(g~fruit^{-1})),
    "Fruit dry matter concentration (g g^-1)" = expression(Fruit~dry~matter~concentration~(g~g^{-1})),
    "Total fruit fresh biomass (kg plant^-1)" = expression(Total~fruit~fresh~mass~(kg~tree^{-1})),
    "Total fruit fresh mass (kg tree^-1)" = expression(Total~fruit~fresh~mass~(kg~tree^{-1})),
    "Total fruit dry mass (kg tree^-1)" = expression(Total~fruit~dry~mass~(kg~tree^{-1})),
    "Fresh mass (kg plant^-1)" = expression(Fresh~mass~(kg~tree^{-1})),
    "Dry mass (kg plant^-1)" = expression(Dry~mass~(kg~tree^{-1})),
    "Fresh mass (kg tree^-1)" = expression(Fresh~mass~(kg~tree^{-1})),
    "Dry mass (kg tree^-1)" = expression(Dry~mass~(kg~tree^{-1})),
    "Fresh mass (g fruit^-1)" = expression(Fresh~mass~(g~fruit^{-1})),
    "Dry matter concentration (g g^-1)" = expression(Dry*"-"*matter~concentration~(g~g^{-1})),
    "Internode NSC (g C plant^-1)" = expression(Internode~NSC~(g~C~plant^{-1})),
    label
  )
}

plot_temporal <- function(temporal) {
  if (nrow(temporal) == 0) {
    stop("No temporal data available for plotting.", call. = FALSE)
  }
  palette <- fops_crop_load_palette(levels(temporal$crop_load_label))
  linetypes <- fops_crop_load_linetypes(levels(temporal$crop_load_label))
  panel_order <- c("A", "B", "C", "D", "E", "F", "G", "H")
  panel_plots <- lapply(panel_order, function(pnl) {
    part <- temporal %>% dplyr::filter(.data$panel == pnl)
    if (nrow(part) == 0) {
      return(NULL)
    }
    panel_title <- unique(part$panel_title)[[1]]
    panel_y_label <- unique(part$y_label)[[1]]
    x_label <- unique(part$x_label)[[1]]
    x_limits <- if (identical(x_label, "Days after full bloom")) c(30, NA_real_) else NULL
    is_bottom_row <- pnl %in% c("G", "H")
    ribbon_part <- part
    if (!all(c("ymin", "ymax") %in% names(ribbon_part))) {
      ribbon_part <- ribbon_part[FALSE, , drop = FALSE]
      ribbon_part$ymin <- numeric()
      ribbon_part$ymax <- numeric()
    } else {
      ribbon_part <- ribbon_part %>% dplyr::filter(is.finite(.data$ymin), is.finite(.data$ymax))
    }

    ggplot2::ggplot(
      part,
      ggplot2::aes(
        x = .data$x_value,
        y = .data$value,
        color = .data$crop_load_label,
        fill = .data$crop_load_label
      )
    ) +
      ggplot2::geom_ribbon(
        data = ribbon_part,
        ggplot2::aes(ymin = .data$ymin, ymax = .data$ymax, group = .data$crop_load_label),
        alpha = 0.10,
        color = NA
      ) +
      ggplot2::geom_line(ggplot2::aes(linetype = .data$crop_load_label), linewidth = 0.65, alpha = 0.95) +
      ggplot2::scale_color_manual(values = palette, name = NULL, drop = FALSE) +
      ggplot2::scale_fill_manual(values = palette, guide = "none", drop = FALSE) +
      ggplot2::scale_linetype_manual(values = linetypes, name = NULL, drop = FALSE) +
      ggplot2::scale_x_continuous(
        breaks = if (identical(x_label, "Days after full bloom")) c(30, 60, 90, 120) else ggplot2::waiver(),
        limits = x_limits,
        expand = ggplot2::expansion(mult = c(0.01, 0.02))
      ) +
      ggplot2::scale_y_continuous(
        expand = ggplot2::expansion(mult = c(0.04, 0.08))
      ) +
      ggplot2::labs(
        title = panel_title,
        x = if (is_bottom_row) x_label else NULL,
        y = fops_temporal_axis_label(panel_y_label)
      ) +
      ggplot2::theme_bw(base_size = 9) +
      ggplot2::theme(
        panel.grid.minor = ggplot2::element_blank(),
        plot.title = ggplot2::element_text(face = "bold", size = 9),
        axis.title.y = ggplot2::element_text(size = 8, margin = ggplot2::margin(r = 3)),
        axis.title.x = ggplot2::element_text(size = 8),
        axis.text = ggplot2::element_text(size = 7.5),
        legend.key.width = grid::unit(1.2, "cm"),
        plot.margin = ggplot2::margin(5.5, 8, 5.5, 12)
      )
  })
  panel_plots <- panel_plots[!vapply(panel_plots, is.null, logical(1))]

  patchwork::wrap_plots(panel_plots, ncol = 2, guides = "collect") &
    ggplot2::theme(
      legend.position = "bottom"
    )
}

standardize_xyz <- function(df, file_path = NA_character_) {
  xcol <- resolve_col(names(df), c("x", "X", "x_m", "positionX", "location_x", "endX"), required = TRUE, context = paste("Missing x coordinate in", file_path))
  ycol <- resolve_col(names(df), c("y", "Y", "y_m", "positionY", "location_y", "endY"), required = TRUE, context = paste("Missing y coordinate in", file_path))
  zcol <- resolve_col(names(df), c("z", "Z", "z_m", "positionZ", "location_z", "endZ"), required = TRUE, context = paste("Missing z coordinate in", file_path))
  df$x <- suppressWarnings(as.numeric(df[[xcol]]))
  df$y <- suppressWarnings(as.numeric(df[[ycol]]))
  df$z <- suppressWarnings(as.numeric(df[[zcol]]))
  df
}

add_fruit_traits <- function(df) {
  out <- df
  fw_col <- resolve_col(names(out), c("freshWeight_g", "freshWeight", "meanFruitFW", "FW", "freshMass_g"))
  dw_col <- resolve_col(names(out), c("dryWeight_g", "dryWeight", "meanFruitDW", "dryMass_g"))
  if (!is.na(dw_col) && grepl("seed", norm_name(dw_col), fixed = TRUE)) {
    dw_col <- NA_character_
  }
  if (!is.na(fw_col)) {
    out$freshMass_g <- suppressWarnings(as.numeric(out[[fw_col]]))
    if (norm_name(fw_col) %in% norm_name(c("meanFruitFW")) && max(out$freshMass_g, na.rm = TRUE) > 1000) {
      out$freshMass_g <- out$freshMass_g / 1000
    }
  } else if (all(c("biomass", "waterMass") %in% names(out))) {
    out$freshMass_g <- (suppressWarnings(as.numeric(out$biomass)) + suppressWarnings(as.numeric(out$waterMass))) / 1000
  } else {
    out$freshMass_g <- NA_real_
  }
  if (!is.na(dw_col)) {
    out$dryMass_g <- suppressWarnings(as.numeric(out[[dw_col]]))
    if (norm_name(dw_col) %in% norm_name(c("meanFruitDW")) && max(out$dryMass_g, na.rm = TRUE) > 1000) {
      out$dryMass_g <- out$dryMass_g / 1000
    }
  } else if ("biomass" %in% names(out)) {
    out$dryMass_g <- suppressWarnings(as.numeric(out$biomass)) / 1000
  } else {
    out$dryMass_g <- NA_real_
  }
  dmc_col <- resolve_col(names(out), c("DMC", "dryMatterPct"))
  if (!is.na(dmc_col)) {
    out$DMC <- suppressWarnings(as.numeric(out[[dmc_col]]))
    if (norm_name(dmc_col) == "drymatterpct" && max(out$DMC, na.rm = TRUE) > 1.5) {
      out$DMC <- out$DMC / 100
    }
  } else {
    out$DMC <- out$dryMass_g / out$freshMass_g
    out$DMC[!is.finite(out$DMC)] <- NA_real_
  }
  out
}

select_spatial_scenarios <- function(mapping, low_crop_load = NULL, high_crop_load = NULL, crop_load_values = NULL) {
  vals <- mapping$CropLoad
  if (!is.null(crop_load_values) && length(crop_load_values) > 0) {
    picked <- suppressWarnings(as.numeric(crop_load_values))
    picked <- picked[is.finite(picked)]
    if (length(picked) >= 2) {
      low_crop_load <- picked[[1]]
      high_crop_load <- picked[[2]]
    }
  }
  low_val <- low_crop_load %||% min(vals, na.rm = TRUE)
  high_val <- high_crop_load %||% max(vals, na.rm = TRUE)
  low <- mapping[which.min(abs(mapping$CropLoad - low_val)), , drop = FALSE]
  high <- mapping[which.min(abs(mapping$CropLoad - high_val)), , drop = FALSE]
  out <- dplyr::bind_rows(low, high)
  out$scenario_role <- c("low_crop_load", "high_crop_load")
  out$scenario_role_label <- c(
    paste0("Low crop load: ", out$scenario_label[[1]]),
    paste0("High crop load: ", out$scenario_label[[2]])
  )
  out
}

build_spatial_data <- function(mapping,
                               snapshot_day = NULL,
                               snapshot_hour = NULL,
                               low_crop_load = NULL,
                               high_crop_load = NULL,
                               crop_load_values = NULL) {
  selected <- select_spatial_scenarios(mapping, low_crop_load, high_crop_load, crop_load_values)
  spatial_parts <- list()
  snapshot_rows <- list()
  diag_rows <- list()

  for (i in seq_len(nrow(selected))) {
    row <- selected[i, , drop = FALSE]

    internode <- read_csv_table(row$internode_array_file[[1]])
    if (nrow(internode) > 0) {
      internode <- normalise_time(standardize_xyz(internode, row$internode_array_file[[1]]), tz = "UTC")
      water_col <- resolve_col(names(internode), c("waterPotential", "xylemWaterPotential", "psi", "psi_xylem", "psiXylem"))
      cp_col <- resolve_internode_cp_col(names(internode))
      sliced <- slice_to_doy_and_hour_r(internode, doy = snapshot_day, hour = snapshot_hour, df_name = paste(row$scenario_role, "internode"))
      data_i <- sliced$data
      if (!is.na(water_col)) {
        spatial_parts[[length(spatial_parts) + 1]] <- data_i %>%
          dplyr::transmute(
            uuid = row$uuid,
            CropLoad = row$CropLoad,
            crop_load_label = row$scenario_label,
            scenario_role = row$scenario_role,
            scenario_role_label = row$scenario_role_label,
            component = "internode",
            trait = "waterPotential",
            trait_label = "A. Internode xylem water potential",
            x, y, z,
            value = suppressWarnings(as.numeric(.data[[water_col]])),
            source_variable = water_col,
            file_path = row$internode_array_file
          )
      }
      if (!is.na(cp_col)) {
        spatial_parts[[length(spatial_parts) + 1]] <- data_i %>%
          dplyr::transmute(
            uuid = row$uuid,
            CropLoad = row$CropLoad,
            crop_load_label = row$scenario_label,
            scenario_role = row$scenario_role,
            scenario_role_label = row$scenario_role_label,
            component = "internode",
            trait = "Cp",
            trait_label = "B. Internode phloem sugar concentration",
            x, y, z,
            value = convert_internode_phi_to_sugar_concentration(.data[[cp_col]], cp_col),
            source_variable = cp_col,
            file_path = row$internode_array_file
          )
      }
      diag_rows[[length(diag_rows) + 1]] <- tibble::tibble(
        uuid = row$uuid,
        CropLoad = row$CropLoad,
        source = "internodeArray",
        file_path = row$internode_array_file,
        status = "ok",
        message = sliced$message,
        selected_snapshot_day = sliced$selected_dayOfYear,
        selected_snapshot_hour = sliced$selected_hourOfDay,
        n_points = nrow(data_i),
        missing_required_variables = paste(c(
          if (is.na(water_col)) "internode xylem water potential" else character(),
          if (is.na(cp_col)) "internode carbon potential or phloem sugar concentration" else character()
        ), collapse = "; ")
      )
      snapshot_rows[[length(snapshot_rows) + 1]] <- tibble::tibble(
        uuid = row$uuid,
        CropLoad = row$CropLoad,
        scenario_role = row$scenario_role,
        source = "internodeArray",
        requested_snapshot_day = snapshot_day %||% NA_real_,
        selected_dayOfYear = sliced$selected_dayOfYear,
        requested_snapshot_hour = snapshot_hour %||% NA_real_,
        selected_hourOfDay = sliced$selected_hourOfDay,
        selected_timestamp = as.character(sliced$selected_timestamp),
        n_points = nrow(data_i)
      )
    } else {
      diag_rows[[length(diag_rows) + 1]] <- tibble::tibble(uuid = row$uuid, CropLoad = row$CropLoad, source = "internodeArray", file_path = row$internode_array_file, status = "missing_file", message = "Missing internodeArray file.", selected_snapshot_day = NA_real_, selected_snapshot_hour = NA_real_, n_points = 0L, missing_required_variables = "internodeArray")
    }

    fruit <- read_csv_table(row$fruit_array_file[[1]])
    if (nrow(fruit) > 0) {
      fruit <- normalise_time(add_fruit_traits(standardize_xyz(fruit, row$fruit_array_file[[1]])), tz = "UTC")
      sliced <- slice_to_doy_and_hour_r(fruit, doy = snapshot_day, hour = snapshot_hour, df_name = paste(row$scenario_role, "fruit"))
      data_f <- sliced$data
      for (trait_info in list(
        list(trait = "freshMass", label = "C. Fruit fresh mass", col = "freshMass_g", src = "freshMass_g"),
        list(trait = "DMC", label = "D. Fruit DMC", col = "DMC", src = "DMC")
      )) {
        spatial_parts[[length(spatial_parts) + 1]] <- data_f %>%
          dplyr::transmute(
            uuid = row$uuid,
            CropLoad = row$CropLoad,
            crop_load_label = row$scenario_label,
            scenario_role = row$scenario_role,
            scenario_role_label = row$scenario_role_label,
            component = "fruit",
            trait = trait_info$trait,
            trait_label = trait_info$label,
            x, y, z,
            value = suppressWarnings(as.numeric(.data[[trait_info$col]])),
            source_variable = trait_info$src,
            file_path = row$fruit_array_file
          )
      }
      diag_rows[[length(diag_rows) + 1]] <- tibble::tibble(
        uuid = row$uuid,
        CropLoad = row$CropLoad,
        source = "fruitArray",
        file_path = row$fruit_array_file,
        status = "ok",
        message = sliced$message,
        selected_snapshot_day = sliced$selected_dayOfYear,
        selected_snapshot_hour = sliced$selected_hourOfDay,
        n_points = nrow(data_f),
        missing_required_variables = paste(c(
          if (all(is.na(data_f$freshMass_g))) "fruit fresh mass" else character(),
          if (all(is.na(data_f$DMC))) "fruit DMC" else character()
        ), collapse = "; ")
      )
      snapshot_rows[[length(snapshot_rows) + 1]] <- tibble::tibble(
        uuid = row$uuid,
        CropLoad = row$CropLoad,
        scenario_role = row$scenario_role,
        source = "fruitArray",
        requested_snapshot_day = snapshot_day %||% NA_real_,
        selected_dayOfYear = sliced$selected_dayOfYear,
        requested_snapshot_hour = snapshot_hour %||% NA_real_,
        selected_hourOfDay = sliced$selected_hourOfDay,
        selected_timestamp = as.character(sliced$selected_timestamp),
        n_points = nrow(data_f)
      )
    } else {
      diag_rows[[length(diag_rows) + 1]] <- tibble::tibble(uuid = row$uuid, CropLoad = row$CropLoad, source = "fruitArray", file_path = row$fruit_array_file, status = "missing_file", message = "Missing fruitArray file.", selected_snapshot_day = NA_real_, selected_snapshot_hour = NA_real_, n_points = 0L, missing_required_variables = "fruitArray")
    }
  }

  data <- dplyr::bind_rows(spatial_parts) %>%
    dplyr::filter(is.finite(.data$x), is.finite(.data$z), is.finite(.data$value))
  data$scenario_role_label <- factor(data$scenario_role_label, levels = unique(selected$scenario_role_label))
  data$trait_label <- factor(data$trait_label, levels = c("A. Internode xylem water potential", "B. Internode phloem sugar concentration", "C. Fruit fresh mass", "D. Fruit DMC"))
  list(data = data, snapshot_info = dplyr::bind_rows(snapshot_rows), diagnostics = dplyr::bind_rows(diag_rows), selected_scenarios = selected)
}

spatial_trait_unit <- function(trait) {
  switch(trait, waterPotential = "MPa", Cp = "g sugar cm^-3 phloem sap", freshMass = "g", DMC = "g g^-1", "")
}

plot_spatial <- function(spatial_data) {
  if (nrow(spatial_data) == 0) {
    stop("No spatial data available for plotting.", call. = FALSE)
  }
  traits <- c("waterPotential", "Cp", "freshMass", "DMC")
  plots <- lapply(seq_along(traits), function(i) {
    trait <- traits[[i]]
    part <- spatial_data %>% dplyr::filter(.data$trait == trait)
    label <- unique(as.character(part$trait_label))[1] %||% trait
    ggplot2::ggplot(part, ggplot2::aes(x = .data$x, y = .data$z, color = .data$value)) +
      ggplot2::geom_point(size = ifelse(identical(trait, "freshMass") || identical(trait, "DMC"), 0.8, 1.1), alpha = 0.82, na.rm = TRUE) +
      ggplot2::facet_grid(ggplot2::vars(.data$scenario_role_label), scales = "fixed") +
      ggplot2::coord_equal() +
      ggplot2::scale_color_viridis_c(option = "D", name = paste0(gsub("^[A-D]\\. ", "", label), "\n", spatial_trait_unit(trait))) +
      ggplot2::labs(title = label, x = "x", y = "z") +
      ggplot2::theme_bw(base_size = 8) +
      ggplot2::theme(
        legend.position = "bottom",
        legend.key.width = grid::unit(12, "mm"),
        panel.grid.minor = ggplot2::element_blank(),
        strip.background = ggplot2::element_rect(fill = "grey94", color = "grey70"),
        strip.text.y = ggplot2::element_text(angle = 0),
        plot.title = ggplot2::element_text(face = "bold", size = 9)
      )
  })
  patchwork::wrap_plots(plots, ncol = 4) +
    patchwork::plot_annotation(title = "Spatial distribution of water, carbon and fruit traits under contrasting crop load")
}

plot_spatial_histograms <- function(spatial_data) {
  ggplot2::ggplot(spatial_data, ggplot2::aes(x = .data$value, y = ggplot2::after_stat(density), fill = .data$scenario_role_label)) +
    ggplot2::geom_histogram(bins = 30, alpha = 0.55, position = "identity", color = "grey25", linewidth = 0.15, na.rm = TRUE) +
    ggplot2::facet_wrap(ggplot2::vars(.data$trait_label), scales = "free", ncol = 2) +
    ggplot2::scale_fill_viridis_d(option = "D", end = 0.85, name = NULL) +
    ggplot2::labs(title = "Within-tree organ distributions under low and high crop load", x = NULL, y = "Density") +
    ggplot2::theme_bw(base_size = 9) +
    ggplot2::theme(legend.position = "bottom", panel.grid.minor = ggplot2::element_blank())
}

plot_main_spatial_figure <- function(spatial_data) {
  high <- spatial_data %>% dplyr::filter(.data$scenario_role == "high_crop_load")
  low_high_colors <- c(
    "low_crop_load" = "#56B4E9",
    "high_crop_load" = "#E69F00"
  )

  make_map <- function(trait_name, title, legend_title) {
    part <- high %>% dplyr::filter(.data$trait == .env$trait_name)
    ggplot2::ggplot(part, ggplot2::aes(x = .data$x, y = .data$z, color = .data$value)) +
      ggplot2::geom_point(size = 0.28, alpha = 0.80, na.rm = TRUE) +
      ggplot2::coord_equal() +
      ggplot2::scale_color_viridis_c(option = "D", name = legend_title) +
      ggplot2::labs(title = title, x = "x (m)", y = "z (m)") +
      ggplot2::theme_bw(base_size = 9) +
      ggplot2::theme(
        panel.grid.minor = ggplot2::element_blank(),
        plot.title = ggplot2::element_text(face = "bold", size = 10)
      )
  }

  make_hist <- function(trait_name, title, x_label) {
    part <- spatial_data %>% dplyr::filter(.data$trait == .env$trait_name)
    ggplot2::ggplot(
      part,
      ggplot2::aes(
        x = .data$value,
        y = ggplot2::after_stat(count / sum(count)),
        fill = .data$scenario_role,
        group = .data$scenario_role
      )
    ) +
      ggplot2::geom_histogram(bins = 20, alpha = 0.58, position = "identity", color = "grey30", linewidth = 0.15, na.rm = TRUE) +
      ggplot2::scale_fill_manual(
        values = low_high_colors,
        breaks = c("low_crop_load", "high_crop_load"),
        labels = c("Low crop load (199 fruits)", "High crop load (600 fruits)"),
        name = NULL
      ) +
      ggplot2::scale_y_continuous(labels = scales::label_percent(accuracy = 1)) +
      ggplot2::labs(title = title, x = x_label, y = "Proportion of organs") +
      ggplot2::theme_bw(base_size = 9) +
      ggplot2::theme(
        panel.grid.minor = ggplot2::element_blank(),
        plot.title = ggplot2::element_text(face = "bold", size = 10),
        legend.position = "bottom"
      )
  }

  p_a <- make_map(
    "waterPotential",
    "(a) Internode xylem water potential",
    "Xylem water\npotential (MPa)"
  )
  p_b <- make_map(
    "Cp",
    "(b) Internode phloem sugar concentration",
    "Phloem sugar concentration\n(g sugar cm^-3 phloem sap)"
  )
  p_c <- make_hist("waterPotential", "(c) Internode xylem water potential", "Water potential (MPa)")
  p_d <- make_hist("Cp", "(d) Internode phloem sugar concentration", "Phloem sugar concentration (g sugar cm^-3 phloem sap)")
  p_e <- make_hist("freshMass", "(e) Fruit fresh mass", "Fresh mass (g)")
  p_f <- make_hist("DMC", "(f) Fruit dry-matter concentration", "Dry-matter concentration (g g^-1)")

  patchwork::wrap_plots(p_a, p_b, p_c, p_d, p_e, p_f, ncol = 2, guides = "collect") &
    ggplot2::theme(legend.position = "bottom")
}

save_plot_formats <- function(plot, stem, formats, width, height, dpi = 300) {
  static <- intersect(formats, c("svg", "png", "pdf"))
  for (fmt in static) {
    path <- paste0(stem, ".", fmt)
    device <- if (identical(fmt, "svg")) grDevices::svg else NULL
    if (is.null(device)) {
      ggplot2::ggsave(path, plot, width = width, height = height, units = "in", dpi = dpi, bg = "white")
    } else {
      ggplot2::ggsave(path, plot, width = width, height = height, units = "in", dpi = dpi, bg = "white", device = device)
    }
  }
  invisible(TRUE)
}

write_interactive_spatial <- function(spatial_data, out_dir) {
  required_packages(require_html = TRUE)
  trait_files <- c(
    waterPotential = "FOPS_crop_load_spatial_waterPotential_3d.html",
    Cp = "FOPS_crop_load_spatial_Cp_3d.html",
    freshMass = "FOPS_crop_load_spatial_freshMass_3d.html",
    DMC = "FOPS_crop_load_spatial_DMC_3d.html"
  )
  for (trait in names(trait_files)) {
    part <- spatial_data %>% dplyr::filter(.data$trait == trait)
    if (nrow(part) == 0) {
      next
    }
    limits <- range(part$value, na.rm = TRUE)
    plt <- plotly::plot_ly()
    for (role in unique(as.character(part$scenario_role_label))) {
      role_part <- part[as.character(part$scenario_role_label) == role, , drop = FALSE]
      plt <- plotly::add_trace(
        plt,
        data = role_part,
        x = ~x,
        y = ~y,
        z = ~z,
        type = "scatter3d",
        mode = "markers",
        name = role,
        marker = list(
          size = 3,
          color = role_part$value,
          colorscale = "Viridis",
          cmin = limits[[1]],
          cmax = limits[[2]],
          colorbar = list(title = paste0(trait, " ", spatial_trait_unit(trait))),
          showscale = identical(role, unique(as.character(part$scenario_role_label))[[1]])
        ),
        text = ~paste0(component, "<br>", trait, "=", signif(value, 4), "<br>CropLoad=", CropLoad),
        hoverinfo = "text"
      )
    }
    plt <- plotly::layout(
      plt,
      title = paste0("FOPS crop-load spatial ", trait),
      scene = list(xaxis = list(title = "x"), yaxis = list(title = "y"), zaxis = list(title = "z"), aspectmode = "data"),
      margin = list(l = 0, r = 0, t = 60, b = 0)
    )
    htmlwidgets::saveWidget(plt, file.path(out_dir, trait_files[[trait]]), selfcontained = FALSE)
  }
}

build_diagnostics <- function(mapping, spatial_result = NULL, temporal = NULL) {
  map_diag <- mapping %>%
    dplyr::transmute(
      uuid,
      CropLoad,
      source = "scenario_mapping",
      found_plant_level_file = !is.na(.data$plant_file) & file.exists(.data$plant_file),
      found_mean_fruit_file = !is.na(.data$mean_fruit_file) & file.exists(.data$mean_fruit_file),
      found_fruitArray_file = !is.na(.data$fruit_array_file) & file.exists(.data$fruit_array_file),
      found_internodeArray_file = !is.na(.data$internode_array_file) & file.exists(.data$internode_array_file),
      selected_snapshot_day = NA_real_,
      selected_snapshot_hour = NA_real_,
      number_of_fruit_points = NA_integer_,
      number_of_internode_points = NA_integer_,
      missing_required_variables = dplyr::case_when(
        !found_plant_level_file ~ "plant-level file",
        !found_mean_fruit_file ~ "mean-fruit file",
        !found_fruitArray_file ~ "fruitArray file",
        !found_internodeArray_file ~ "internodeArray file",
        TRUE ~ ""
      ),
      unit_conversion_applied = "meanFruitFW/meanFruitDW/SD mg_to_g for temporal fruit mass and calculated DMC"
    )
  if (is.null(spatial_result)) {
    return(map_diag)
  }
        spatial_diag <- spatial_result$diagnostics %>%
    dplyr::mutate(
      found_plant_level_file = NA,
      found_mean_fruit_file = NA,
      found_fruitArray_file = ifelse(.data$source == "fruitArray", .data$status == "ok", NA),
      found_internodeArray_file = ifelse(.data$source == "internodeArray", .data$status == "ok", NA),
      number_of_fruit_points = ifelse(.data$source == "fruitArray", .data$n_points, NA_integer_),
      number_of_internode_points = ifelse(.data$source == "internodeArray", .data$n_points, NA_integer_),
      unit_conversion_applied = ifelse(.data$source == "fruitArray", "fruitArray biomass/waterMass converted mg_to_g for fresh and dry mass", "")
    ) %>%
    dplyr::select(dplyr::any_of(names(map_diag)))
  dplyr::bind_rows(map_diag, spatial_diag)
}

build_temporal_fruit_fw_diagnostics <- function(mapping, params) {
  rows <- lapply(seq_len(nrow(mapping)), function(i) {
    row <- mapping[i, , drop = FALSE]
    df <- read_csv_table(row$mean_fruit_file[[1]])
    if (nrow(df) == 0) {
      return(tibble::tibble(
        uuid = row$uuid,
        CropLoad = row$CropLoad,
        scenario_label = row$scenario_label,
        final_dayOfYear = NA_real_,
        final_days_after_full_bloom = NA_real_,
        meanFruitFW_source = "missing_mean_fruit_file",
        meanFruitFW_g = NA_real_,
        meanFruitFW_sd_g = NA_real_,
        meanFruitDW_g = NA_real_,
        DMC = NA_real_,
        totalFruitFW_tree_kg = NA_real_,
        fruitNumber = NA_real_,
        carbonAssimilation_conversion = "meanAnet used directly, then daily_max",
        waterFlux_conversion = "waterFlux_optimized * 3600 / 1000000, then daily_max",
        x_axis_mode = params$x_axis_mode,
        full_bloom_doy = params$full_bloom_doy,
        days_in_bloom_year = params$days_in_bloom_year
      ))
    }
    work <- normalise_time(df)
    work$dayOfYear <- suppressWarnings(as.numeric(work$dayOfYear))
    work$date_value <- if ("date" %in% names(work)) as.Date(work$date) else as.Date(NA)
    full_bloom_date <- as.Date(params$full_bloom_date %||% "2021-10-19")
    work$days_after_full_bloom_doy <- calc_days_after_full_bloom(work$dayOfYear, params$full_bloom_doy, params$days_in_bloom_year)
    work$days_after_full_bloom_date <- ifelse(
      !is.na(work$date_value) & !is.na(full_bloom_date),
      as.numeric(work$date_value - full_bloom_date),
      NA_real_
    )
    work$days_after_full_bloom <- ifelse(
      is.finite(work$days_after_full_bloom_date),
      work$days_after_full_bloom_date,
      work$days_after_full_bloom_doy
    )
    mode <- normalize_x_axis_mode(params$x_axis_mode)
    if (mode == "DAFB") {
      work <- work[work$days_after_full_bloom >= params$dafb_start & work$days_after_full_bloom <= params$dafb_end, , drop = FALSE]
    }
    if (nrow(work) == 0) {
      return(tibble::tibble(
        uuid = row$uuid,
        CropLoad = row$CropLoad,
        scenario_label = row$scenario_label,
        final_dayOfYear = NA_real_,
        final_days_after_full_bloom = NA_real_,
        meanFruitFW_source = "no_rows_in_selected_window",
        meanFruitFW_g = NA_real_,
        meanFruitFW_sd_g = NA_real_,
        meanFruitDW_g = NA_real_,
        DMC = NA_real_,
        totalFruitFW_tree_kg = NA_real_,
        fruitNumber = NA_real_,
        carbonAssimilation_conversion = "meanAnet used directly, then daily_max",
        waterFlux_conversion = "waterFlux_optimized * 3600 / 1000000, then daily_max",
        x_axis_mode = params$x_axis_mode,
        full_bloom_doy = params$full_bloom_doy,
        days_in_bloom_year = params$days_in_bloom_year
      ))
    }
    order_col <- if ("datetime" %in% names(work)) "datetime" else "dayOfYear"
    work <- work[order(work[[order_col]]), , drop = FALSE]
    final <- work[nrow(work), , drop = FALSE]
    fw_g <- if ("meanFruitFW" %in% names(final)) suppressWarnings(as.numeric(final$meanFruitFW) / 1000) else NA_real_
    fw_sd_g <- if ("meanFruitFW_sd" %in% names(final)) suppressWarnings(as.numeric(final$meanFruitFW_sd) / 1000) else NA_real_
    dw_g <- if ("meanFruitDW" %in% names(final)) suppressWarnings(as.numeric(final$meanFruitDW) / 1000) else NA_real_
    dmc <- if ("DMC" %in% names(final)) {
      suppressWarnings(as.numeric(final$DMC))
    } else if (is.finite(dw_g) && is.finite(fw_g) && fw_g != 0) {
      dw_g / fw_g
    } else {
      NA_real_
    }
    fruit_number_col <- resolve_col(names(final), c("totalFruitNumber", "fruitNumber", "nFruit"))
    fruit_number <- if (!is.na(fruit_number_col)) suppressWarnings(as.numeric(final[[fruit_number_col]])) else NA_real_
    total_fw_kg <- if ("totalFruitFW_tree_kg" %in% names(final)) {
      suppressWarnings(as.numeric(final$totalFruitFW_tree_kg))
    } else if (is.finite(fw_g) && is.finite(fruit_number)) {
      fw_g * fruit_number / 1000
    } else {
      NA_real_
    }
    tibble::tibble(
      uuid = row$uuid,
      CropLoad = row$CropLoad,
      scenario_label = row$scenario_label,
      final_dayOfYear = suppressWarnings(as.numeric(final$dayOfYear)),
      final_days_after_full_bloom = suppressWarnings(as.numeric(final$days_after_full_bloom)),
      meanFruitFW_source = if ("meanFruitFW" %in% names(final)) "meanFruitFW" else "missing",
      meanFruitFW_g = fw_g,
      meanFruitFW_sd_g = fw_sd_g,
      meanFruitDW_g = dw_g,
      DMC = dmc,
      totalFruitFW_tree_kg = total_fw_kg,
      fruitNumber = fruit_number,
      carbonAssimilation_conversion = "meanAnet used directly, then daily_max",
      waterFlux_conversion = "waterFlux_optimized * 3600 / 1000000, then daily_max",
      x_axis_mode = params$x_axis_mode,
      full_bloom_doy = params$full_bloom_doy,
      days_in_bloom_year = params$days_in_bloom_year
    )
  })
  dplyr::bind_rows(rows)
}

cli <- parse_cli_args(commandArgs(trailingOnly = TRUE))

formats <- split_csv(cli$format, default = c("svg", "png", "pdf"))
required_packages(require_html = "html" %in% formats)

params <- list(
  scenario_folder = cli$scenario_folder %||% cli$scenarios %||% "../0_Model_output/FOPS_CropLoad",
  design_csv = cli$design_csv %||% "dual-field-space-FOPSCropLoad.csv",
  design_csv_pattern = cli$design_csv_pattern %||% "dual-field-space-*.csv",
  crop_load_col = cli$crop_load_col %||% "CropLoad",
  x_axis_mode = normalize_x_axis_mode(cli$x_axis_mode %||% "DAFB"),
  full_bloom_doy = parse_num_or_null(cli$full_bloom_doy) %||% 292,
  days_in_bloom_year = parse_num_or_null(cli$days_in_bloom_year) %||% 365,
  full_bloom_date = cli$full_bloom_date %||% "2021-10-19",
  dafb_start = parse_num_or_null(cli$dafb_start) %||% 34,
  dafb_end = parse_num_or_null(cli$dafb_end),
  harvest_day_of_year = parse_num_or_null(cli$harvest_day_of_year) %||% 65,
  plot_period_start = parse_num_or_null(cli$plot_period_start),
  plot_period_end = parse_num_or_null(cli$plot_period_end),
  snapshot_day = parse_num_or_null(cli$snapshot_day),
  snapshot_hour = parse_num_or_null(cli$snapshot_hour) %||% 12,
  output_dir = cli$output_dir %||% cli$out_dir %||% "output/FOPS_CropLoad_usecase",
  make_temporal = parse_bool(cli$make_temporal, default = TRUE),
  make_spatial = parse_bool(cli$make_spatial, default = FALSE),
  low_crop_load = parse_num_or_null(cli$low_crop_load),
  high_crop_load = parse_num_or_null(cli$high_crop_load),
  crop_load_values = split_csv(cli$crop_load_values, default = character())
)
if (is.null(params$dafb_end)) {
  params$dafb_end <- calc_days_after_full_bloom(
    day_of_year = params$harvest_day_of_year,
    full_bloom_doy = params$full_bloom_doy,
    days_in_bloom_year = params$days_in_bloom_year
  )
}

dir.create(params$output_dir, recursive = TRUE, showWarnings = FALSE)

mapping <- build_scenario_mapping(
  scenario_folder = params$scenario_folder,
  design_csv = params$design_csv,
  design_csv_pattern = params$design_csv_pattern,
  crop_load_col = params$crop_load_col
)

readr::write_csv(mapping, file.path(params$output_dir, "FOPS_crop_load_scenario_mapping.csv"))

temporal <- NULL
if (isTRUE(params$make_temporal)) {
  temporal <- build_temporal_data(
    mapping,
    x_axis_mode = params$x_axis_mode,
    dafb_start = params$dafb_start,
    dafb_end = params$dafb_end,
    full_bloom_doy = params$full_bloom_doy,
    days_in_bloom_year = params$days_in_bloom_year,
    full_bloom_date = params$full_bloom_date,
    harvest_day_of_year = params$harvest_day_of_year,
    plot_period_start = params$plot_period_start,
    plot_period_end = params$plot_period_end
  )
  readr::write_csv(temporal, file.path(params$output_dir, "FOPS_crop_load_temporal_water_carbon_fruit_data.csv"))
  temporal_fw_diagnostics <- build_temporal_fruit_fw_diagnostics(mapping, params)
  readr::write_csv(temporal_fw_diagnostics, file.path(params$output_dir, "FOPS_crop_load_temporal_fruit_fw_diagnostics.csv"))
  p_temporal <- plot_temporal(temporal)
  save_plot_formats(
    p_temporal,
    file.path(params$output_dir, "FOPS_crop_load_temporal_water_carbon_fruit"),
    formats = formats,
    width = 9.5,
    height = 11.5
  )
}

spatial_result <- NULL
if (isTRUE(params$make_spatial)) {
  spatial_result <- build_spatial_data(
    mapping,
    snapshot_day = params$snapshot_day,
    snapshot_hour = params$snapshot_hour,
    low_crop_load = params$low_crop_load,
    high_crop_load = params$high_crop_load,
    crop_load_values = params$crop_load_values
  )
  readr::write_csv(spatial_result$data, file.path(params$output_dir, "FOPS_crop_load_spatial_low_high_data.csv"))
  readr::write_csv(spatial_result$snapshot_info, file.path(params$output_dir, "FOPS_crop_load_snapshot_info.csv"))
  p_spatial <- plot_spatial(spatial_result$data)
  save_plot_formats(
    p_spatial,
    file.path(params$output_dir, "FOPS_crop_load_spatial_low_high"),
    formats = formats,
    width = 13,
    height = 6.8
  )
  p_hist <- plot_spatial_histograms(spatial_result$data)
  save_plot_formats(
    p_hist,
    file.path(params$output_dir, "FOPS_crop_load_spatial_histograms"),
    formats = intersect(formats, c("svg", "png", "pdf")),
    width = 8,
    height = 5.5
  )
  p_main_spatial <- plot_main_spatial_figure(spatial_result$data)
  save_plot_formats(
    p_main_spatial,
    # This is a 2D diagnostic, not manuscript Figure 8. The manuscript figure
    # is assembled by build_figure8.R from Python 3D panels and R histograms.
    file.path(params$output_dir, "FOPS_crop_load_spatial_distribution_2d_diagnostic"),
    formats = intersect(formats, c("svg", "png", "pdf")),
    width = 10.8,
    height = 11.5
  )
  if ("html" %in% formats) {
    write_interactive_spatial(spatial_result$data, params$output_dir)
  }
}

diagnostics <- build_diagnostics(mapping, spatial_result = spatial_result, temporal = temporal)
readr::write_csv(diagnostics, file.path(params$output_dir, "FOPS_crop_load_diagnostics.csv"))

message("Wrote FOPS crop-load use-case outputs to: ", normalizePath(params$output_dir, winslash = "/", mustWork = FALSE))
message("Design CSV: ", attr(mapping, "design_csv"))
message("Crop-load column used: ", attr(mapping, "crop_load_col"))
