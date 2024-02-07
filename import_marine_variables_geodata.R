library(terra)
library(geodata)

# (set working directory to source file location)

?geodata::bio_oracle

layer_names <- c("Calcite", "Chlorophyll", "Cloud.cover", "Current.Velocity", "Diffuse.attenuation", "Dissolved.oxygen", "Ice.cover", "Ice.thickness", "Iron", "Light.bottom", "Nitrate", "Par", "pH", "Phosphate", "Phytoplankton", "Primary.productivity", "Salinity", "Silicate", "Temperature")

# currently, geodata::bio_oracle() only supports one layeriable at a time, so let's loop:
for (v in layer_names) {
  geodata::bio_oracle(path = "../outputs", var = v, stat = ifelse(v == "pH", "", "Mean"), benthic = FALSE)  # check help file for other values of "stat" and "benthic"
}

list.files("../outputs")
layer_files <- list.files("../outputs/bio-oracle", pattern = "\\.tif$", full.names = TRUE)
layer_files

# layers <- terra::rast(layer_files)  # Error: [rast] extents do not match

# exclude the different layers for now:
layers <- terra::rast(layer_files[-grep("pH|calcite|Par", layer_files)])
terra::nlyr(layers)
terra::plot(layers)

# check their extents:
terra::ext(rast(layer_files[grep("pH", layer_files)]))
terra::ext(rast(layer_files[grep("calcite", layer_files)]))
terra::ext(rast(layer_files[grep("Par", layer_files)]))

# combine, project and append the different layers:
layers2 <- terra::rast(layer_files[grep("pH|calcite|Par", layer_files)])
terra::plot(layers2)
terra::crs(layers2, proj = TRUE)
layers2 <- terra::project(layers2, layers)
layers <- c(layers, layers2)
terra::nlyr(layers)
