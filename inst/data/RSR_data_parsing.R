#' RSR data parsing
#' 
#' 

library(readr)
library(dplyr)
library(tidyr)
library(rhdf5)

# create the hdf5 file used to store the RSR of the sensors

RSRDataF <- file.path("/home/raphael/R/SatRSR/inst/data/RSR_data.h5")

if (!file.exists(RSRDataF)) {
  message('Creating RSR h5 data file')
  RSRData <- H5Fcreate(RSRDataF)
} else {
  message('Opening existing h5 data file')
  RSRData <- H5Fopen(RSRDataF)
}

# The structure of the RSR tables is as follow:
# Columns:
# Wavelength, *Sensor Band Central Wavelength*{1,n}
# Row:
# one row per wavelength
# Cells:
# One spectral response value per cell

# Data dir path for original sensor RSR files

RSRDir <- "/home/raphael/R/SatRSR/data/"


# WISE --------------------------------------------------------------------

WISEF <- file.path(RSRDir, "WISE_Gaussian.csv")

WISERSR <- read_csv(WISEF)

h5write(WISERSR, RSRData, "WISE")

H5Fclose(RSRData)

# MSI_S2A -----------------------------------------------------------------


# MSI_S2B -----------------------------------------------------------------


# OLI ---------------------------------------------------------------------


# OLI2 --------------------------------------------------------------------



