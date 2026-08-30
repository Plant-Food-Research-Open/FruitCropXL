# Minimal helpers bundled with the FOPS CropLoad workflow.
#
# Keep this file dependency-free apart from the R packages loaded by
# required_packages().  It allows this directory to be copied to a separate
# repository without also copying the parent project's R/ and scripts/ trees.

`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0) {
    return(y)
  }
  txt <- trimws(as.character(x))
  if (length(txt) == 0 || all(!nzchar(txt))) {
    return(y)
  }
  x
}

parse_cli_args <- function(args) {
  out <- list()
  i <- 1
  while (i <= length(args)) {
    arg <- args[[i]]
    if (!grepl("^--", arg)) {
      i <- i + 1
      next
    }
    if (grepl("=", arg, fixed = TRUE)) {
      parts <- strsplit(arg, "=", fixed = TRUE)[[1]]
      out[[sub("^--", "", parts[[1]])]] <- paste(parts[-1], collapse = "=")
    } else {
      key <- sub("^--", "", arg)
      if (i < length(args) && !grepl("^--", args[[i + 1]])) {
        out[[key]] <- args[[i + 1]]
        i <- i + 1
      } else {
        out[[key]] <- "TRUE"
      }
    }
    i <- i + 1
  }
  out
}

generic_param_is_null <- function(x) {
  if (is.null(x) || length(x) == 0) {
    return(TRUE)
  }
  txt <- trimws(as.character(x[[1]]))
  !nzchar(txt) || tolower(txt) %in% c("null", "none", "na", "nan")
}

resolve_generic_dir_hint <- function(path_hint) {
  if (generic_param_is_null(path_hint)) {
    return(NA_character_)
  }
  hint <- trimws(as.character(path_hint[[1]]))
  candidates <- unique(c(
    hint,
    gsub("0_Model-output", "0_Model_output", hint, fixed = TRUE),
    gsub("0_Model_output", "0_Model-output", hint, fixed = TRUE),
    file.path("..", "0_Model_output", basename(hint)),
    file.path("..", "0_Model-output", basename(hint))
  ))
  hit <- candidates[dir.exists(candidates)][1]
  if (!is.na(hit)) {
    return(normalizePath(hit, winslash = "/", mustWork = FALSE))
  }
  normalizePath(hint, winslash = "/", mustWork = FALSE)
}

normalize_generic_uuid <- function(x) {
  vals <- as.character(x %||% NA_character_)
  vapply(vals, function(val) {
    if (is.na(val)) {
      return(NA_character_)
    }
    txt <- trimws(val)
    txt <- basename(gsub("/+$", "", txt))
    txt <- trimws(gsub("^\\[|\\]$", "", txt))
    txt <- tolower(gsub("_", "-", txt, fixed = TRUE))
    if (!nzchar(txt)) NA_character_ else txt
  }, character(1), USE.NAMES = FALSE)
}

read_generic_design <- function(design_csv) {
  if (!file.exists(design_csv)) {
    stop("Design CSV not found: ", design_csv, call. = FALSE)
  }
  design <- utils::read.csv(design_csv, stringsAsFactors = FALSE, check.names = FALSE)
  uuid_candidates <- c("uuid", "UUID", "options_uuid", "scenario_uuid", "simulation_uuid", "id")
  uuid_col <- uuid_candidates[uuid_candidates %in% names(design)][1]
  if (is.na(uuid_col)) {
    stop(
      "No UUID column found in design CSV. Expected one of: ",
      paste(uuid_candidates, collapse = ", "),
      ". Available columns: ", paste(names(design), collapse = ", "),
      call. = FALSE
    )
  }
  design$scenario_uuid <- normalize_generic_uuid(design[[uuid_col]])
  design$scenario_label <- substr(design$scenario_uuid, 1, 8)
  tibble::as_tibble(design)
}

discover_generic_scenario_dirs <- function(scenario_folder, design) {
  scenario_folder <- resolve_generic_dir_hint(scenario_folder)
  child_dirs <- list.dirs(scenario_folder, full.names = TRUE, recursive = FALSE)
  child_dirs <- child_dirs[dir.exists(child_dirs) & !grepl("^\\.", basename(child_dirs))]
  folder_tbl <- tibble::tibble(
    scenario_dir = normalizePath(child_dirs, winslash = "/", mustWork = FALSE),
    folder_uuid = normalize_generic_uuid(child_dirs)
  )
  folder_tbl <- folder_tbl[!duplicated(folder_tbl$folder_uuid), , drop = FALSE]
  idx <- match(design$scenario_uuid, folder_tbl$folder_uuid)
  out <- design
  out$scenario_dir <- folder_tbl$scenario_dir[idx]
  out$status <- ifelse(is.na(out$scenario_dir), "missing_output_dir", "matched")
  out$scenario_id <- sprintf("S%02d", seq_len(nrow(out)))
  out <- dplyr::relocate(out, scenario_dir, status, .after = scenario_label)
  dplyr::relocate(out, scenario_id, .after = scenario_label)
}

apple_norm_name <- function(x) {
  gsub("[^a-z0-9]+", "", tolower(trimws(as.character(x))))
}

resolve_apple_column <- function(col_names, candidates) {
  if (length(col_names) == 0 || length(candidates) == 0) {
    return(NA_character_)
  }
  names_raw <- as.character(col_names)
  names_norm <- apple_norm_name(names_raw)
  candidates_norm <- apple_norm_name(candidates)
  idx <- which(names_norm %in% candidates_norm)
  if (length(idx) > 0) {
    return(names_raw[idx[[1]]])
  }
  for (candidate in candidates_norm) {
    idx <- which(grepl(candidate, names_norm, fixed = TRUE))
    if (length(idx) > 0) {
      return(names_raw[idx[[1]]])
    }
  }
  NA_character_
}

resolve_crop_load_column <- function(design, crop_load_col = NULL) {
  if (!is.null(crop_load_col) && nzchar(crop_load_col) && crop_load_col %in% names(design)) {
    return(crop_load_col)
  }
  resolve_apple_column(
    names(design),
    c(
      "CropLoad", "cropLoad", "crop_load", "crop_load_level", "fruit_load",
      "fruitNumber", "fruit_number", "nFruit", "numberOfFruit",
      "desiredFruitNumber_postPrune", "fruitTargetPerTree"
    )
  )
}

slice_to_doy_and_hour_r <- function(df, doy = NULL, hour = NULL, df_name = "") {
  work <- df
  messages <- character()
  has_timestamp <- "timestamp" %in% names(work)
  if (has_timestamp) {
    work$timestamp <- suppressWarnings(lubridate::ymd_hms(work$timestamp, tz = "UTC", quiet = TRUE))
    missing_timestamp <- is.na(work$timestamp)
    if (any(missing_timestamp)) {
      work$timestamp[missing_timestamp] <- suppressWarnings(as.POSIXct(df$timestamp[missing_timestamp], tz = "UTC"))
    }
    if (!("dayOfYear" %in% names(work))) work$dayOfYear <- lubridate::yday(work$timestamp)
    if (!("hourOfDay" %in% names(work))) work$hourOfDay <- lubridate::hour(work$timestamp)
  } else {
    if (!is.null(doy) && !("dayOfYear" %in% names(work))) stop(df_name, ": need 'dayOfYear' or 'timestamp' to select DOY=", doy, call. = FALSE)
    if (!is.null(hour) && !("hourOfDay" %in% names(work))) stop(df_name, ": need 'hourOfDay' or 'timestamp' to select hour=", hour, call. = FALSE)
  }

  selected_doy <- NA_real_
  selected_hour <- NA_real_
  selected_timestamp <- as.POSIXct(NA_real_, origin = "1970-01-01", tz = "UTC")
  if (!is.null(doy)) {
    values <- suppressWarnings(as.numeric(work$dayOfYear))
    exact <- !is.na(values) & values == as.integer(doy)
    if (any(exact)) {
      work <- work[exact, , drop = FALSE]
    } else {
      distance <- abs(values - as.numeric(doy))
      nearest <- suppressWarnings(min(distance, na.rm = TRUE))
      work <- if (is.finite(nearest)) work[!is.na(distance) & distance == nearest, , drop = FALSE] else work[FALSE, , drop = FALSE]
      messages <- c(messages, sprintf("[%s] No exact DOY=%s; using nearest available day.", df_name, doy))
    }
  }
  if (!is.null(hour) && nrow(work) > 0) {
    values <- suppressWarnings(as.numeric(work$hourOfDay))
    exact <- !is.na(values) & values == as.integer(hour)
    if (any(exact)) {
      work <- work[exact, , drop = FALSE]
    } else {
      distance <- abs(values - as.numeric(hour))
      nearest <- suppressWarnings(min(distance, na.rm = TRUE))
      work <- if (is.finite(nearest)) work[!is.na(distance) & distance == nearest, , drop = FALSE] else work[FALSE, , drop = FALSE]
      messages <- c(messages, sprintf("[%s] No exact hour=%s; using nearest available hour.", df_name, hour))
    }
  }
  if (has_timestamp && nrow(work) > 0 && any(!is.na(work$timestamp))) {
    selected_timestamp <- max(work$timestamp, na.rm = TRUE)
    work <- work[work$timestamp == selected_timestamp, , drop = FALSE]
  }
  if ("dayOfYear" %in% names(work) && nrow(work) > 0) selected_doy <- suppressWarnings(as.numeric(work$dayOfYear[[1]]))
  if ("hourOfDay" %in% names(work) && nrow(work) > 0) selected_hour <- suppressWarnings(as.numeric(work$hourOfDay[[1]]))
  messages <- c(messages, sprintf("[%s] Sliced at DOY=%s, hour=%s, timestamp=%s, n=%s", df_name, ifelse(is.na(selected_doy), "any", selected_doy), ifelse(is.na(selected_hour), "any", selected_hour), ifelse(is.na(selected_timestamp), "NA", format(selected_timestamp, "%Y-%m-%d %H:%M:%S %Z")), nrow(work)))
  message(paste(messages, collapse = "\n"))
  list(data = work, selected_dayOfYear = selected_doy, selected_hourOfDay = selected_hour, selected_timestamp = selected_timestamp, message = paste(messages, collapse = "\n"))
}
