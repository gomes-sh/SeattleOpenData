# Pull a Seattle Open Data dataset

Downloads a dataset from the Seattle Open Data Socrata API using either
a human-readable catalog \`key\` or the official Socrata dataset \`uid\`
returned by \[seattle_list_datasets()\].

## Usage

``` r
seattle_pull_dataset(
  dataset,
  limit = 10000,
  filters = list(),
  date = NULL,
  from = NULL,
  to = NULL,
  date_field = NULL,
  where = NULL,
  order = NULL,
  timeout_sec = 30,
  clean_names = TRUE,
  coerce_types = TRUE
)
```

## Arguments

- dataset:

  A single dataset \`key\` or Socrata dataset \`uid\` from
  \[seattle_list_datasets()\]. For example, a key may look like
  \`"example_dataset_name"\`, while a UID may look like \`"abcd-1234"\`.

- limit:

  Number of rows to retrieve. Defaults to 10,000.

- filters:

  Optional named list of exact-match filters. Each list name should be a
  field name in the dataset, and each value should be the value or
  values to match. Vector values are translated into SQL-style \`IN\`
  conditions in the generated SoQL query. For example, \`filters =
  list(FILTER_FIELD = c("VALUE_1", "VALUE_2"))\` returns rows where
  \`FILTER_FIELD\` is either \`"VALUE_1"\` or \`"VALUE_2"\`.

- date:

  Optional single date used to match all records from that day. Requires
  \`date_field\`.

- from:

  Optional start date, inclusive. Requires \`date_field\`.

- to:

  Optional end date, exclusive. Requires \`date_field\`.

- date_field:

  Optional date or datetime column to use with \`date\`, \`from\`, or
  \`to\`. This must be supplied when any date filter is used. Users can
  identify available date columns by inspecting the dataset on the
  Seattle Open Data Portal or by pulling a small sample with \`limit\`.

- where:

  Optional raw SoQL \`WHERE\` clause for advanced filtering. SoQL is the
  Socrata Query Language used by Seattle Open Data. If \`date\`,
  \`from\`, or \`to\` are also supplied, their generated conditions are
  combined with \`where\` using \`AND\`.

- order:

  Optional raw SoQL \`ORDER BY\` clause, such as \`"DATE_FIELD DESC"\`.

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

A tibble containing rows from the requested Seattle Open Data dataset.

## Details

When a catalog \`key\` is supplied, \`seattle_pull_dataset()\` first
retrieves the live Seattle Open Data catalog to look up the
corresponding Socrata \`uid\`, then sends a second request to download
the dataset itself. Supplying a \`uid\` directly is more stable and
avoids ambiguity, while keys are provided for readability and
classroom-friendly workflows.

Dataset keys are generated from dataset names using
\[janitor::make_clean_names()\]. Because keys are derived from live
catalog metadata, Socrata UIDs are the most stable identifiers.

\`seattle_pull_dataset()\` is designed for common catalog-based
workflows. For arbitrary Socrata JSON endpoints that are not included in
the package catalog, use \[seattle_any_dataset()\].

The \`filters\` argument is intended for simple exact-match filtering.
For more complex conditions, use the \`where\` argument with raw SoQL
syntax.

Internally, filter field names are wrapped in \`TRIM()\` when
constructing SoQL queries to reduce mismatches caused by leading or
trailing whitespace in source data.

Type coercion is intentionally conservative. When \`coerce_types =
TRUE\`, the package attempts to infer common R column types from the API
response, but columns with inconsistent values may remain character
columns.

Datetime coercion is also conservative. Timezone offsets and sub-second
precision may not always be preserved during automatic parsing, and
columns with inconsistent datetime formats may remain character columns.

## Examples

``` r
if (interactive() && curl::has_internet()) {
  # Pull by human-readable key
  seattle_pull_dataset("seattle_pet_licenses", limit = 3)

  # Pull by Socrata UID
  seattle_pull_dataset("jguv-t9rb", limit = 3)

  # Filter to one value
  seattle_pull_dataset(
    "jguv-t9rb",
    limit = 3,
    filters = list(primary_breed = "Domestic Shorthair")
  )

  # Filter to multiple values
  seattle_pull_dataset(
    "jguv-t9rb",
    limit = 10,
    filters = list(primary_breed = c("Domestic Shorthair", "American Shorthair"))
  )

  # Date filtering
  seattle_pull_dataset(
    "jguv-t9rb",
    from = "2023-01-01",
    to = "2024-01-01",
    date_field = "license_issue_date",
    limit = 100
  )

  # Advanced filtering with raw SoQL
  seattle_pull_dataset(
    "jguv-t9rb",
    where = "species = 'Dog' AND secondary_breed = 'Mix'",
    order = "license_issue_date DESC",
    limit = 100
  )
}
```
