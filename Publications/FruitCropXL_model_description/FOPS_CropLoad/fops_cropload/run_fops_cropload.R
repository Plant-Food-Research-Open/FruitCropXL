#!/usr/bin/env Rscript

# Avoid lubridate's system-time-zone probe (which calls timedatectl) on
# headless hosts without access to the system D-Bus.  All workflow timestamp
# conversions supply their intended time zone explicitly.
if (!nzchar(Sys.getenv("TZ", unset = ""))) {
  Sys.setenv(TZ = "UTC")
}

args_all <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args_all, value = TRUE)
script_path <- if (length(file_arg) > 0) {
  normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/", mustWork = FALSE)
} else {
  ""
}
workflow_dir <- normalizePath(dirname(script_path), winslash = "/", mustWork = TRUE)
options(fops_cropload_dir = workflow_dir)

source(file.path(workflow_dir, "fops_standalone_helpers.R"))
source(file.path(workflow_dir, "prepare_cropload_data.R"))
source(file.path(workflow_dir, "plot_temporal_response.R"))
source(file.path(workflow_dir, "plot_organ_distributions.R"))
source(file.path(workflow_dir, "plot_nsc_reserve.R"))

run_fops_cropload()
