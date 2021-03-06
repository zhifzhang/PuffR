#' Add area sources to a list for later use in CALPUFF
#' @description Add area sources to a list for later use in CALPUFF
#' @param src_name the name of the source emitting the species.
#' @param species_name the name of the species undergoing emissions.
#' @param lat_dec_deg a vector of 4 latitude values for the area source in units of decimal degrees.
#' @param lon_dec_deg a vector of 4 longitude values for the area source in units of decimal degrees.
#' @param x_coord_km a vector of 4 UTM easting values for the area source in km units.
#' @param y_coord_km a vector of 4 UTM northing values for the area source in km units.
#' @param UTM_zone the UTM zone for the area source.
#' @param UTM_hemisphere the UTM hemisphere for the area source.
#' @param effective_height the effective height of the area source in meters above ground level (m AGL).
#' @param base_elev the ground elevation at the location of the area source in meters above sea level (m ASL).
#' @param init_sigma_z the initial sigma z value for the area source in meters.
#' @param emission_rate the rate of constant emissions from the area source; units are defined in the 'emission_units' argument.
#' @param emission_units the units applied to the value defined in the 'emission_rate' argument. The possible selections are: (1) "g/m2/s", (2) "kg/m2/hr", (3) "lb/m2/hr", (4) "tons/m2/yr", (5) "Odour Unit * m/s", (6) "Odour Unit * m/min", (7) "metric tons/m2/yr", (8) "Bq/m2/s", and (9) "GBq/m2/yr".
#' @export calpuff_add_area_sources

calpuff_add_area_sources <- function(src_name,
                                     species_name,
                                     lat_dec_deg = NULL,
                                     lon_dec_deg = NULL,
                                     x_coord_km = NULL,
                                     y_coord_km = NULL,
                                     UTM_zone = NULL,
                                     UTM_hemisphere = NULL,
                                     effective_height,
                                     base_elev,
                                     init_sigma_z,
                                     emission_rate,
                                     emission_units){
  
  # Add require statements
  require(rgdal)
  require(raster)
  require(stringr)
  require(plyr)
  
  # Get expected filename for area sources
  area_sources_filename <-
    paste0(unlist(str_split(getwd(),
                            pattern = "/"))[length(unlist(str_split(getwd(),
                                                                    pattern = "/")))],
           "--area_sources.txt")
  
  # Create area sources text file with header if it doesn't exist
  if (file.exists(area_sources_filename) == FALSE){
    
    # Create empty file in working folder
    file.create(area_sources_filename)
    
    # Add header row to new area sources file
    cat(paste0("src_name", ",",
               "species_name", ",",
               "lat_dec_deg_1", ",",
               "lon_dec_deg_1", ",",
               "lat_dec_deg_2", ",",
               "lon_dec_deg_2", ",",
               "lat_dec_deg_3", ",",
               "lon_dec_deg_3", ",",
               "lat_dec_deg_4", ",",
               "lon_dec_deg_4", ",",
               "x_coord_km_1", ",",
               "y_coord_km_1", ",",
               "x_coord_km_2", ",",
               "y_coord_km_2", ",",
               "x_coord_km_3", ",",
               "y_coord_km_3", ",",
               "x_coord_km_4", ",",
               "y_coord_km_4", ",",
               "UTM_zone", ",",
               "UTM_hemisphere", ",",
               "effective_height", ",",
               "base_elev", ",",
               "init_sigma_z", ",",
               "emission_rate", ",",
               "emission_units"),
        sep = "\n",
        file = area_sources_filename,
        append = TRUE)
    
  }
  
  # Determine whether lon/lat provided
  if (!is.null(lat_dec_deg) & !is.null(lon_dec_deg)){
    lon_lat_provided <- TRUE
  } else {
    lon_lat_provided <- FALSE
  }
  
  # Determine whether UTM coordinates and zone information provided
  if (!is.null(x_coord_km) & !is.null(y_coord_km)
      & !is.null(UTM_zone) & !is.null(UTM_hemisphere)){
    UTM_provided <- TRUE
  } else {
    UTM_provided <- FALSE
  }  
  
  # If both lon/lat provided, convert to UTM
  if (lon_lat_provided == TRUE & UTM_provided == FALSE){
    
    # Get matrix of longitude and latitude for source location
    lat_lon_dec_deg <- cbind(lon_dec_deg, lat_dec_deg)
    
    # Determine the UTM zone
    UTM_zone <- unique((floor((lon_dec_deg + 180)/6) %% 60) + 1)[1]
    
    # Determine whether source is in the Northern Hemisphere or the Southern Hemisphere
    UTM_hemisphere <- unique(ifelse(lat_dec_deg >= 0, "N", "S"))[1]
    
    # Define a PROJ.4 projection string for a lat/lon projection
    proj_string_longlat <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
    
    # Define a PROJ.4 projection string for a UTM projection
    proj_string_UTM <- paste0("+proj=utm +zone=",
                              UTM_zone,
                              " +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
    
    # Project as UTM coordinates from the determined UTM zone
    UTM_location <- project(lat_lon_dec_deg, proj_string_UTM)
    
    # Define the UTM x coordinates in km units
    x_coord_km <- UTM_location[,1] / 1000
    
    # Define the UTM y coordinates in km units
    y_coord_km <- UTM_location[,2] / 1000
    
  }
  
  # If UTM coordinates provided, convert to lon/lat
  if (lon_lat_provided == FALSE & UTM_provided == TRUE){
    
    # Define a PROJ.4 projection string for a lat/lon projection
    proj_string_longlat <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
    
    # Define a PROJ.4 projection string for a UTM projection
    proj_string_UTM <- paste0("+proj=utm +zone=",
                              UTM_zone,
                              " +ellps=WGS84 +datum=WGS84 +units=m +no_defs")
    
    # Create a SpatialPoints object for the UTM coordinates
    UTM_m_SP <- SpatialPoints(matrix(c(x_coord_km * 1000,
                                       y_coord_km * 1000),
                                     nrow = 4,
                                     ncol = 2),
                              proj4string = CRS(proj_string_UTM))
    
    # Project as UTM coordinates from the determined UTM zone
    latlon_SP <- spTransform(UTM_m_SP, CRS(proj_string_longlat))
    
    # Extract the latitude values in decimal degrees from the SpatialPoints object
    lat_dec_deg <- latlon_SP@coords[,2]
    
    # Extract the longitude values in decimal degrees from the SpatialPoints object
    lon_dec_deg <- latlon_SP@coords[,1]
    
  }
  
  # Write the values to the file
  cat(paste0(src_name, ",",
             species_name, ",",
             format(lat_dec_deg[1], small.interval = 6), ",",
             format(lon_dec_deg[1], small.interval = 6), ",",
             format(lat_dec_deg[2], small.interval = 6), ",",
             format(lon_dec_deg[2], small.interval = 6), ",",
             format(lat_dec_deg[3], small.interval = 6), ",",
             format(lon_dec_deg[3], small.interval = 6), ",",
             format(lat_dec_deg[4], small.interval = 6), ",",
             format(lon_dec_deg[4], small.interval = 6), ",",
             format(x_coord_km[1], small.interval = 3), ",",
             format(y_coord_km[1], small.interval = 3), ",",
             format(x_coord_km[2], small.interval = 3), ",",
             format(y_coord_km[2], small.interval = 3), ",",
             format(x_coord_km[3], small.interval = 3), ",",
             format(y_coord_km[3], small.interval = 3), ",",
             format(x_coord_km[4], small.interval = 3), ",",
             format(y_coord_km[4], small.interval = 3), ",",
             UTM_zone, ",",
             UTM_hemisphere, ",",
             effective_height, ",",
             base_elev, ",",
             init_sigma_z, ",",
             emission_rate, ",",
             emission_units),
      sep = "\n",
      file = area_sources_filename,
      append = TRUE)
  
}
