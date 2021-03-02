# create data ####

# === # === # === # === # === # === # === # === # === # === # === # === #

## dependencies ####
### tidyverse packages ####
library(dplyr)
library(readr)
library(tidyr)

### spatial packages ####
library(sf)

# === # === # === # === # === # === # === # === # === # === # === # === #

## load data ####
city <- read_csv("https://raw.githubusercontent.com/slu-openGIS/MO_HEALTH_Covid_Tracking/master/data/zip/zip_stl_city.csv")
county <- read_csv("https://raw.githubusercontent.com/slu-openGIS/MO_HEALTH_Covid_Tracking/master/data/zip/zip_stl_county.csv")
pop <- read_csv("https://raw.githubusercontent.com/slu-openGIS/STL_BOUNDARY_ZCTA/master/data/demographics/STL_ZCTA_City_County_Total_Pop.csv") %>%
  rename(zip = GEOID_ZCTA)
geom <- st_read("https://raw.githubusercontent.com/slu-openGIS/STL_BOUNDARY_ZCTA/master/data/geometries/STL_ZCTA_City_County.geojson") %>%
  rename(zip = GEOID_ZCTA) %>%
  mutate(zip = as.numeric(zip))

# === # === # === # === # === # === # === # === # === # === # === # === #

## subset to target days ####
### identify target days ####
end_dates <- seq(as.Date("2020-07-01"), length = 7, by = "months")-1
end_dates <- c(end_dates[1], end_dates[4], end_dates[7])

### subset ####
city <- filter(city, report_date %in% end_dates) %>%
  select(report_date, zip, cases)
county <- filter(county, report_date %in% end_dates) %>%
  select(report_date, zip, cases)

# === # === # === # === # === # === # === # === # === # === # === # === #

## bind and clean ####
region <- bind_rows(city, county) %>%
  group_by(report_date, zip) %>%
  summarize(cases = sum(cases, na.rm = TRUE)) %>%
  ungroup() %>%
  mutate(period = case_when(
    report_date == end_dates[1] ~ "period1",
    report_date == end_dates[2] ~ "period2",
    report_date == end_dates[3] ~ "period3"
  )) %>%
  select(period, zip, cases) %>%
  pivot_wider(id_cols = zip, names_from = period, values_from = cases) %>%
  mutate(
    period1 = ifelse(is.na(period1) == TRUE, 0, period1),
    period2 = ifelse(is.na(period2) == TRUE, 0, period2),
    period3 = ifelse(is.na(period3) == TRUE, 0, period3)
  ) %>%
  mutate(
    delta2 = period2-period1,
    delta3 = period3-period2
  )

## clean-up
rm(city, county, end_dates)

# === # === # === # === # === # === # === # === # === # === # === # === #

## calculate rates ####
region_rate <- left_join(pop, region, by = "zip") %>%
  filter(zip %in% c(63045, 63155, 63304) == FALSE) %>%
  mutate(
    delta1_rate = period1/total_pop*1000,
    delta2_rate = delta2/total_pop*1000,
    delta3_rate = delta3/total_pop*1000
  )

## clean-up
rm(pop, region)

# === # === # === # === # === # === # === # === # === # === # === # === #

## create geometric data ####
region_geom <- left_join(geom, region_rate) %>%
  select(zip, delta1_rate, delta2_rate, delta3_rate)

# === # === # === # === # === # === # === # === # === # === # === # === #

## write data ####
write_csv(region_rate, "data/region_rate.csv")
st_write(region_geom, "data/region_rate.geojson", delete_dsn = TRUE)

## clean-up
rm(geom, region_geom, region_rate)
