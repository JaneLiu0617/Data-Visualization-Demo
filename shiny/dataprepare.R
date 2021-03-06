library(tidyverse)
library(stringr)
library(readr)
library(tidyr)


# add identifying column to raw data files and load all files -------
data_path <- "raw-data"
file_names <- dir(data_path, pattern = "*.csv")

all_data <- data_frame(type = file_names) %>%
  mutate(
    file_contents = map(file_names, ~ read_csv(file.path(data_path, .))),
    type = str_replace(type, ".csv", "")
  ) %>%
  unnest() %>%
  rename(date = Date, close = Close) %>%
  mutate(date = as.POSIXct(date, format = "%d-%B-%y")) %>%
  select(type, date, close)

# subset for desired types ------------------------------------------
trend_data <- all_data %>%
  filter(
    type %in% c("rental", "rlest", "shop", "smallbiz", "travel", "unempl"),
    date >= "2007-01-01" & date < "2017-08-01"
  )

# check for beg / end dates -----------------------------------------
trend_data %>%
  group_by(type) %>%
  summarise(min(date), max(date))

# description data --------------------------------------------------
trend_description <- data_frame(
  type = c("rental", "rlest", "shop", "smallbiz", "travel", "unempl")
) %>%
  mutate(
    text = case_when(
      type == "rental" ~ "The Google Rental Index tracks queries related to Revenue, Net income, DilutedEPS, Net profit margin, etc.",
      type == "rlest" ~ "The Google Real Estate Index. ",
      type == "shop" ~  "The Google Shop Index. ",
      type == "smallbiz" ~ "The Google Small Business Index tracks queries related to small business, make money, franchise, work from home, chamber or commerce, etc.",
      type == "travel" ~ "The Google Travel Index tracks queries related to airlines, hotels, beach, southwest, las vegas, flights, etc.",
      type == "unempl" ~ "The Google Unemployment Index tracks queries related to unemployment, food stamps, social security, edd, disability, etc."
    )
  )

# write data --------------------------------------------------------
write_csv(trend_data, path = "trend_data.csv")
write_csv(trend_description, path = "trend_description.csv")