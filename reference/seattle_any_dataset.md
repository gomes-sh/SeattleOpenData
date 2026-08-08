# Pull any Seattle Open Data dataset from a Socrata JSON endpoint

Downloads data from any Seattle Open Data Socrata JSON endpoint and
returns the result as a tibble. This function is useful for datasets
that are not included in the curated catalog returned by
\[seattle_list_datasets()\].

## Usage

``` r
seattle_any_dataset(
  json_link,
  limit = 10000,
  timeout_sec = 30,
  clean_names = TRUE,
  coerce_types = TRUE
)
```

## Arguments

- json_link:

  A single Socrata dataset JSON endpoint URL, such as
  \`"https://data.seattle.gov/resource/abcd-1234.json"\`.

- limit:

  Number of rows to retrieve. Defaults to 10,000.

- timeout_sec:

  Request timeout in seconds. Defaults to 30.

- clean_names:

  Logical. If \`TRUE\`, column names are converted to snake_case using
  \[janitor::clean_names()\]. Defaults to \`TRUE\`.

- coerce_types:

  Logical. If \`TRUE\`, the package attempts lightweight,
  heuristic-based type coercion after downloading the data. Columns are
  converted only when at least 95 percent of non-missing values can be
  parsed as the target type. This helps avoid unsafe conversions when
  source data are inconsistent.

## Value

A tibble containing rows from the requested Seattle Open Data endpoint.

## Details

Seattle Open Data datasets have Socrata JSON endpoints that usually
follow this pattern:

\`https://data.seattle.gov/resource/\<dataset_uid\>.json\`

For example, a dataset with the Socrata UID \`"abcd-1234"\` would have
the JSON endpoint:

\`https://data.seattle.gov/resource/abcd-1234.json\`

Users can find a dataset's UID from the Seattle Open Data Portal URL,
the API documentation page for the dataset, or the output of
\[seattle_list_datasets()\].

\`seattle_any_dataset()\` bypasses the package catalog and sends a
request directly to the supplied JSON endpoint. Unlike
\[seattle_pull_dataset()\], it does not look up defaults such as catalog
keys, date fields, or default ordering.

This function is intended for direct endpoint access. For catalog-based
workflows using readable keys or Socrata UIDs, use
\[seattle_pull_dataset()\].

## Examples

``` r
# Examples that hit the live Seattle Open Data API are guarded so CRAN
# checks do not fail when the network is unavailable or slow.
if (interactive() && curl::has_internet()) {
  # Build a JSON endpoint from a Socrata UID
  uid <- "jguv-t9rb"
  endpoint <- paste0("https://data.seattle.gov/resource/", uid, ".json")

  out <- try(seattle_any_dataset(endpoint, limit = 3), silent = TRUE)
  if (!inherits(out, "try-error")) {
    head(out)
  }
}
```
