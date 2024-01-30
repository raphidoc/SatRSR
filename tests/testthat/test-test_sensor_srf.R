#' Test for the sensor_srf function

library(devtools)
library(purrr)
library(dplyr)
library(tidyr)
library(SatRSR)

LwLong <- readr::read_csv("/home/raphael/R/SatRSR/inst/test_unique_obs_Lw.csv")
LwLong <- readr::read_csv("/home/raphael/R/SatRSR/inst/test_multiple_obs_Lw.csv")

# test <- sensor_srf(
#   Waves = LwLong$Wavelength,
#   Values = LwLong$Lw,
#   Sensor = "WISE"
# )

SensorRSR <- sensor_rsr("WISE")

test <- LwLong %>%
  group_by(UUID) %>%
  nest() %>%
mutate(SensorWL = purrr::map(
  .x = data,
  ~compute_srf(
    Waves = .x$Wavelength,
    Values = .x$Lw,
    SensorRSR = SensorRSR
  ),
  .progress = TRUE
))

test <- test %>%
  unnest(SensorWL)


# t <- purrr::map(
#   .x = test$data,
#   ~compute_srf(
#     Waves = .x$Wavelength,
#     Values = .x$Lw,
#     SensorRSR = SensorRSR
#   ),
#   .progress = TRUE
# )
# 
# test <- bind_rows(t)
