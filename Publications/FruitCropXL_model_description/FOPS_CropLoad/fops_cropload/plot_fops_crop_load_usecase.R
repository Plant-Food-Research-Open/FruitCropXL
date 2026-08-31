#!/usr/bin/env Rscript

# Backward-compatible command-line name for the standalone workflow.
# Keep the implementation in run_fops_cropload.R so both entry points have
# identical path handling and never require the parent repository's R code.
args_all <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args_all, value = TRUE)
script_path <- if (length(file_arg) > 0) {
  normalizePath(sub("^--file=", "", file_arg[[1]]), winslash = "/", mustWork = FALSE)
} else {
  normalizePath("plot_fops_crop_load_usecase.R", winslash = "/", mustWork = FALSE)
}
source(file.path(dirname(script_path), "run_fops_cropload.R"))
