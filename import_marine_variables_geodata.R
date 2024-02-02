library(terra)
library(geodata)

?geodata::bio_oracle

var_names <- c("Calcite", "Chlorophyll", "Cloud.cover", "Current.Velocity", "Diffuse.attenuation", "Dissolved.oxygen", "Ice.cover", "Ice.thickness", "Iron", "Light.bottom", "Nitrate", "Par", "pH", "Phosphate", "Phytoplankton", "Primary.productivity", "Salinity", "Silicate", "Temperature")


# currently, geodata::bio_oracle() only supports one variable at a time, so let's loop:
for (v in var_names) {
  geodata::bio_oracle(path = "outputs", var = v, stat = ifelse(v == "pH", "", "Mean"), benthic = FALSE)  # check help file for other values of "stat" and "benthic"
}

list.files("outputs")
var_files <- list.files("outputs/bio-oracle", pattern = "\\.tif$", full.names = TRUE)
var_files

# vars <- rast(var_files)  # Error: [rast] extents do not match

# exclude the different vars for now:
vars <- terra::rast(var_files[-grep("pH|calcite|Par", var_files)])
terra::nlyr(vars)
terra::plot(vars)

# check their extents:
terra::ext(rast(var_files[grep("pH", var_files)]))
terra::ext(rast(var_files[grep("calcite", var_files)]))
terra::ext(rast(var_files[grep("Par", var_files)]))

# combine, project and append the different vars:
vars2 <- terra::rast(var_files[grep("pH|calcite|Par", var_files)])
terra::plot(vars2)
terra::crs(vars2, proj = TRUE)
vars2 <- terra::project(vars2, vars)
vars <- c(vars, vars2)
terra::nlyr(vars)
