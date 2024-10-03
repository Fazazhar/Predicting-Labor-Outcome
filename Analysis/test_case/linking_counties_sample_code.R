# Libraries

library(here)
library(readxl)
library(tidyverse)
library(janitor)
library(tigris)
library(sf)


# Loading LAT data

data_lat <- read_excel(here("Labor action tracker data 12.4.23.xlsx"))


# Filtering only labor actions with one location (note you should handle multiple locations
# as determined by your group) and separating latitude and longitude into new variables

data_lat <- data_lat |>
  clean_names() |>
  filter(number_of_locations == 1) |>
  mutate(lat = as.numeric(sub(",.*", "", latitude_longitude)),
         long = as.numeric(sub(".*, ", "", latitude_longitude))) |>
  select(-latitude_longitude) |>
  filter(!is.na(lat), !is.na(long))


# Downloading U.S. counties shape file

counties <- counties(cb = TRUE)


# Converting latitude and longitude into sf objects

data_lat <- st_as_sf(data_lat, 
                     coords = c("long", "lat"), 
                     crs = 4326)


# Transforming counties shape file into the same CRS as lat_long

counties <- st_transform(counties, st_crs(data_lat))


# Spatial join of data with counties

data_lat <- st_join(data_lat, counties)


