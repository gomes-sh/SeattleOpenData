#' List available Seattle Open Data datasets
#'
#' Retrieves a live catalog of Seattle Open Data datasets from the Seattle
#' Open Data Portal catalog table (`CATALOG_DATASET_ID`) and returns dataset
#' metadata that can be used with [seattle_pull_dataset()].
#'
#' The returned tibble includes both the official Socrata dataset `uid` and a
#' human-readable `key`. The `uid` is the stable identifier used by the Seattle
#' Open Data Portal and Socrata API, while the `key` is generated from the
#' dataset name using [janitor::make_clean_names()] to make datasets easier to
#' reference in R code, especially in classroom and reproducible research
#' settings.
#'
#' Most users will begin by calling `seattle_list_datasets()`, searching the
#' returned catalog for a dataset of interest, and then passing either the `key`
#' or `uid` to [seattle_pull_dataset()].
#'
#' @return A tibble containing available Seattle Open Data datasets. Important
#'   columns include:
#'   \describe{
#'     \item{key}{A human-readable dataset key generated from the dataset name.}
#'     \item{uid}{The official Socrata dataset identifier used by Seattle Open
#'       Data.}
#'     \item{name}{The dataset name from the Seattle Open Data catalog.}
#'   }
#'   Additional metadata columns from the Seattle Open Data catalog may also
#'   be returned.
#'
#' @examples
#' if (interactive() && curl::has_internet()) {
#'   catalog <- seattle_list_datasets()
#'
#'   # View available datasets
#'   catalog
#'
#'   # Search for datasets containing a keyword
#'   catalog[
#'     grepl("KEYWORD", catalog$name, ignore.case = TRUE),
#'     c("key", "uid", "name")
#'   ]
#' }
#'
#' @importFrom rlang .data
#' @export
seattle_list_datasets <- function() {
  .seattle_catalog_tbl()
}

.seattle_catalog_tbl <- function() {
  raw <- .seattle_dataset_request(
    dataset_id = "phjv-68rp",
    limit = 50000,
    timeout_sec = 30,
    clean_names = TRUE,
    coerce_types = FALSE
  )

  raw |>
    dplyr::filter(.data$type == "dataset") |>
    dplyr::mutate(
      key = janitor::make_clean_names(.data$name)
    ) |>
    dplyr::filter(!is.na(.data$uid), nzchar(.data$uid)) |>
    dplyr::distinct(.data$uid, .keep_all = TRUE) |>
    dplyr::relocate("key", "uid", "name")
}

