# Getting Started with Seattle Open Data

``` text
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  warning = FALSE,
  message = FALSE
)
```

``` text
library(seattleOpenData)
library(dplyr)
library(ggplot2)
```

## Introduction

Welcome to the `seattleOpenData` package, an R package designed to
provide convenient access to the Seattle Open Data Portal.

The package provides a streamlined interface for discovering and
downloading datasets from Seattle Open Data. It helps bridge the gap
between raw Socrata API endpoints and tidy data analysis in R.

The package provides three primary functions:

- [`seattle_list_datasets()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_list_datasets.md)
  for browsing available datasets
- [`seattle_pull_dataset()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_pull_dataset.md)
  for downloading datasets using a catalog key or Socrata UID
- [`seattle_any_dataset()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_any_dataset.md)
  for downloading data directly from a Socrata JSON endpoint

## Listing Available Datasets

The first step in a typical workflow is to use
[`seattle_list_datasets()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_list_datasets.md)
to retrieve the live Seattle Open Data catalog.

``` text
catalog <- seattle_list_datasets()

catalog
```

The returned catalog includes information about the datasets available
through the portal. Two especially important columns are:

- `key`, a human-readable dataset identifier generated from the dataset
  name
- `uid`, the official Socrata dataset identifier

You can search the catalog for datasets containing a keyword.

``` text
catalog |>
  filter(grepl("Pet", name, ignore.case = TRUE)) |>
  select(key, uid, name)
```

Replace `Pet` with a useful search term related to the example dataset
selected for the package.

## Pulling a Dataset

The primary way to download data is with
[`seattle_pull_dataset()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_pull_dataset.md).

A dataset can be requested using either its human-readable catalog key
or its official Socrata UID.

### Pulling by UID

``` text
example_data_uid <- seattle_pull_dataset(
  dataset = "jguv-t9rb",
  limit = 5
)

example_data_uid
```

### Pulling by Key

``` text
example_data_key <- seattle_pull_dataset(
  dataset = "seattle_pet_licenses",
  limit = 5
)

example_data_key
```

Both calls should return data from the same dataset.

## Keys and UIDs

Dataset keys are easier to read, while Socrata UIDs are more stable.

For reproducible research and long-term workflows, using the official
Socrata UID is generally recommended.

## Filtering Data

The `filters` argument can be used for simple exact-match filtering.

``` text
filtered_data <- seattle_pull_dataset(
  dataset = "jguv-t9rb",
  limit = 25,
  filters = list(
    primary_breed = "Domestic Shorthair"
  )
)

filtered_data
```

You can confirm that the filter worked by inspecting the unique values
in the selected field.

``` text
filtered_data |>
  distinct(primary_breed)
```

Multiple values can also be supplied.

``` text
filtered_multiple <- seattle_pull_dataset(
  dataset = "jguv-t9rb",
  limit = 50,
  filters = list(
    primary_breed = c("Domestic Shorthair", "American Shorthair")
  )
)

filtered_multiple
```

Multiple fields can be combined within the same filter list.

``` text
filtered_combination <- seattle_pull_dataset(
  dataset = "jguv-t9rb",
  limit = 50,
  filters = list(
    species = "Dog",
    secondary_breed = "Mix"
  )
)

filtered_combination
```

## Filtering by Date

If the example dataset contains a date or datetime field, records can be
filtered using `from`, `to`, and `date_field`.

``` text
date_filtered_data <- seattle_pull_dataset(
  dataset = "jguv-t9rb",
  from = "2023-01-01",
  to = "2024-01-01",
  date_field = "license_issue_date",
  limit = 100
)

date_filtered_data
```

The `from` date is inclusive, while the `to` date is exclusive.

A single day can also be requested using the `date` argument.

``` text
single_day_data <- seattle_pull_dataset(
  dataset = "jguv-t9rb",
  date = "2023-03-04",
  date_field = "license_issue_date",
  limit = 100
)

single_day_data
```

## Pulling Data from Any Socrata Endpoint

The preferred workflow is to use
[`seattle_list_datasets()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_list_datasets.md)
together with
[`seattle_pull_dataset()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_pull_dataset.md).

However, when a dataset is not available in the package catalog,
[`seattle_any_dataset()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_any_dataset.md)
can download data directly from a Socrata JSON endpoint.

Seattle Open Data endpoints typically follow this structure:

``` text
https://data.seattle.gov/resource/<dataset_uid>.json
```

For example:

``` text
https://data.seattle.gov/resource/jguv-t9rb.json
```

The endpoint can then be supplied directly to
[`seattle_any_dataset()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_any_dataset.md).

``` text
endpoint_data <- seattle_any_dataset(
  json_link = "https://data.seattle.gov/resource/jguv-t9rb.json",
  limit = 5
)

endpoint_data
```

## Which function should you use?

Use
[`seattle_pull_dataset()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_pull_dataset.md)
when the dataset is available through
[`seattle_list_datasets()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_list_datasets.md).

Use
[`seattle_any_dataset()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_any_dataset.md)
when you already have a valid Socrata JSON endpoint or when the dataset
is not included in the package catalog.

## Example Analysis

Once the data have been downloaded, they can be analyzed using standard
R tools.

The following example counts the number of records in a categorical
field.

``` text
category_summary <- seattle_pull_dataset(
  dataset = "jguv-t9rb",
  limit = 500
) |>
  filter(!is.na(primary_breed)) |>
  count(primary_breed, sort = TRUE)

category_summary
```

The results can then be visualized.

``` text
category_summary |>
  slice_head(n = 10) |>
  ggplot(
    aes(
      x = n,
      y = reorder(primary_breed, n)
    )
  ) +
  geom_col() +
  theme_minimal() +
  labs(
    title = "Most Frequent Categories",
    x = "Number of Records",
    y = "Breeds"
  )
```

This example demonstrates the complete workflow from discovering a
dataset to downloading, filtering, summarizing, and visualizing it.

## Summary

The `seattleOpenData` package provides a consistent interface for
working with data from the Seattle Open Data Portal.

In this vignette, you learned how to:

- browse available datasets using
  [`seattle_list_datasets()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_list_datasets.md)
- download datasets by key or UID using
  [`seattle_pull_dataset()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_pull_dataset.md)
- filter data using fields, values, and dates
- access a Socrata JSON endpoint using
  [`seattle_any_dataset()`](https://nyc-open-data-lab.github.io/SeattleOpenData/reference/seattle_any_dataset.md)
- perform a simple analysis and visualization

These functions allow users to focus on analysis rather than manually
constructing API requests.

## How to Cite

If you use this package for research or educational purposes, cite it
using the package citation returned by:

``` text
citation("seattleOpenData")
```
