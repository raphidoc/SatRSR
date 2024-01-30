#' sensor_rsr
#' 
#' @description Fetch the Relative Spectral Resonse of a sensor in the h5 database
#' 
#' @param Sensor sensor name for which to fetch the RSR.
#'  Available are: "WISE".
#'  
#' @return a data frame of RSR with structure, Wavelength, *Sensor Band Central Wavelength*{1,n}
#'  
#' @author Raphaël Mabit
#'  
#' @import rhdf5
#' @export
sensor_rsr <- function(Sensor="WISE") {
  
  RSRFile <- system.file("data/RSR_data.h5", package = "SatRSR")
  
  if (file.exists(RSRFile)) {
    
    message(paste0('Reading RSR data from: ', RSRFile))
    RSRData <- H5Fopen(RSRFile)
    SensorRSR <- RSRData&Sensor
    SensorRSR <- SensorRSR[]
    return(SensorRSR)
    
  } else {
    
    stop(paste0(RSRFile," does not exist"))
    return(NULL)
    
  }
}

#' compute_srf
#' 
#' @description Transform spectral data to the response of a sensor.
#'  Originally writted by Simon Bélanger, re-implemented by Raphaël mabit 
#' 
#' @param Waves wavelengths of the original spectroradiometric values
#' @param Values sepctroradiometric values (radiance, irradiance, reflectance)
#' @param SensorRSR Sensor RSR as outputted by \link[SatRSR]{sensor_rsr}
#' @param ID 
#'  
#' @return A long format data frame, with columns `Sensor`, `SensorWavelength`, `SensorValues`,
#'  
#' @export

compute_srf <- function(Waves, Values, SensorRSR) {
  
  # interpolate the input spectra to RSR
  ValuesInt <- spline(Waves, Values, xout=SensorRSR$Wavelength, method = "natural")$y
  ValuesInt[ValuesInt < 0] = 0
  
  ValuesInt[SensorRSR$Wavelength < min(Waves)] = 0
  ValuesInt[SensorRSR$Wavelength > max(Waves)] = 0
  
  ValuesSensor <- list()
  WavesSensor <- list()
  
  # loop on wavebands
  for (i in 2:ncol(SensorRSR)) {
    
    # integrate on non-zero RSR
    ix = which(SensorRSR[,i] > 0)
    
    FXLinear <- approxfun(
      SensorRSR$Wavelength[ix],
      SensorRSR[ix,i]*ValuesInt[ix])
    
    X = integrate(
      FXLinear,
      min(SensorRSR$Wavelength[ix]),
      max(SensorRSR$Wavelength[ix]),
      subdivisions=100,
      stop.on.error = FALSE)[1]
    
    Numerator = X$value
    
    FXLinear <- approxfun(
      SensorRSR$Wavelength[ix],
      SensorRSR[ix,i])
    
    X = integrate(
      FXLinear,
      min(SensorRSR$Wavelength[ix]),
      max(SensorRSR$Wavelength[ix]),
      subdivisions=1000,
      stop.on.error = FALSE)[1]
    
    Denominator = X$value
    
    Temp = Numerator/Denominator
    
    ValuesSensor <- append(ValuesSensor, Temp) 
    WavesSensor <- append(WavesSensor, colnames(SensorRSR)[i])
  
  }
  
  WavesSensor <- as.numeric(WavesSensor)
  ValuesSensor <- as.numeric(ValuesSensor)
  
  ValuesSensorTbl <- tibble(
    #Sensor = Sensor,
    WavesSensor,
    ValuesSensor
  )

  return(ValuesSensorTbl)
}

