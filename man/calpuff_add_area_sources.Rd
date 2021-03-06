% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/calpuff_add_area_sources.R
\name{calpuff_add_area_sources}
\alias{calpuff_add_area_sources}
\title{Add area sources to a list for later use in CALPUFF}
\usage{
calpuff_add_area_sources(src_name, species_name, lat_dec_deg = NULL,
  lon_dec_deg = NULL, x_coord_km = NULL, y_coord_km = NULL,
  UTM_zone = NULL, UTM_hemisphere = NULL, effective_height, base_elev,
  init_sigma_z, emission_rate, emission_units)
}
\arguments{
\item{src_name}{the name of the source emitting the species.}

\item{species_name}{the name of the species undergoing emissions.}

\item{lat_dec_deg}{a vector of 4 latitude values for the area source in units of decimal degrees.}

\item{lon_dec_deg}{a vector of 4 longitude values for the area source in units of decimal degrees.}

\item{x_coord_km}{a vector of 4 UTM easting values for the area source in km units.}

\item{y_coord_km}{a vector of 4 UTM northing values for the area source in km units.}

\item{UTM_zone}{the UTM zone for the area source.}

\item{UTM_hemisphere}{the UTM hemisphere for the area source.}

\item{effective_height}{the effective height of the area source in meters above ground level (m AGL).}

\item{base_elev}{the ground elevation at the location of the area source in meters above sea level (m ASL).}

\item{init_sigma_z}{the initial sigma z value for the area source in meters.}

\item{emission_rate}{the rate of constant emissions from the area source; units are defined in the 'emission_units' argument.}

\item{emission_units}{the units applied to the value defined in the 'emission_rate' argument. The possible selections are: (1) "g/m2/s", (2) "kg/m2/hr", (3) "lb/m2/hr", (4) "tons/m2/yr", (5) "Odour Unit * m/s", (6) "Odour Unit * m/min", (7) "metric tons/m2/yr", (8) "Bq/m2/s", and (9) "GBq/m2/yr".}
}
\description{
Add area sources to a list for later use in CALPUFF
}

