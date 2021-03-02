# zip_periods

This repository creates data for an article manuscript. 

## Metadata
All ZIP code counts are sourced from St. Louis City and St. Louis County COVID-19 dashboards directly, and are available [here](https://github.com/slu-openGIS/MO_HEALTH_Covid_Tracking). All per capita rates are rates per 1,000 estimated individuals.

Column definitions are as follows:

  * `zip` - ZCTA GEOID number
  * `total_pop` - estimated population, with partial ZCTAs interpolated using areal weighted interpolation, sourced from [`STL_BOUNDARY_ZCTA`](https://github.com/slu-openGIS/STL_BOUNDARY_ZCTA)
  * `period1` - count of *total* cases as of 2021-06-30
  * `period2` - count of *total* cases as of 2021-09-30
  * `period2` - count of *total* cases as of 2021-12-31
  * `delta2` - count of *new* cases as of 2021-09-30
  * `delta3` - count of *new* cases as of 2021-12-31
  * `delta1_rate` - per capita *new* cases as of 2021-06-30
  * `delta2_rate` - per capita *new* cases as of 2021-09-30
  * `delta3_rate` - per capita *new* cases as of 2021-12-31

The `.geojson` file only contains `zip`, `delta1_rate`, `delta2_rate`, and `delta3_rate` since those are the columns that will be mapped.