# set working directory to source file location


# load packages:
library(sdmpredictors)
library(maps)


# explore datasets in the sdmpredictors package
datasets <- list_datasets(terrestrial = FALSE, marine = TRUE)
datasets

# explore layers in a dataset
layers <- list_layers(datasets = datasets)
str(layers)
head(layers)
names(layers)
unique(layers$dataset_code)
unique(layers[layers$dataset_code == "Bio-ORACLE", ]$name)  # 304 vars
unique(layers[layers$dataset_code == "MARSPEC", ]$name)  # 42 vars

layers_bioracle <- unique(layers[layers$dataset_code == "Bio-ORACLE", c("name", "layer_code")])
layers_marspec <- unique(layers[layers$dataset_code == "MARSPEC", c("name", "layer_code")])

unique(layers[layers$dataset_code == "MARSPEC", ]$cellsize_lonlat)  # 0.08333333
unique(layers[layers$dataset_code == "Bio-ORACLE", ]$cellsize_lonlat)  # 0.08333333

#chosen_vars_marspec <- c("Bathymetry", "Distance to shore", "Sea surface salinity (annual mean)", "Sea surface salinity (annual variance)", "Sea surface temperature (annual mean)", "Sea surface temperature (variance)")
#chosen_vars_bioracle <- c("Chlorophyll A (mean)", "Chlorophyll A (range)", "Dissolved oxygen", "Nitrate", "pH", "Primary production (mean at mean depth)", "Primary production (range at mean depth)", "Current velocity (mean)", "Current velocity (range)", "Dissolved oxygen concentration (mean)", "Dissolved oxygen concentration (range)", "Primary production (mean)", "Primary production (range)")
#load_layers(layers[(layers$name %in% chosen_vars_marspec & layers$dataset_code == "MARSPEC") | (layers$name %in% chosen_vars_bioracle & layers$dataset_code == "Bio-ORACLE"),], datadir = "layers")

future <- list_layers_future(terrestrial = FALSE)
head(future)
unique(future$dataset_code)  # "Bio-ORACLE" only
unique(future$layer_code)
unique(future[ , c("dataset_code", "model", "scenario", "year", "version")])

nrow(future)  # 697
names(layers_bioracle)
head(layers_bioracle)
names(future)
names(future)[2] <- "future_layer_code"
future <- merge(future, layers_bioracle, by.x = "current_layer_code", by.y = "layer_code", all.x = TRUE, sort = FALSE)
nrow(future)  # 697
head(future)

write.csv(future, "../data/vars_future.csv", row.names = FALSE)


# choose variables from most complete scenarios:

unique(future$model)  # "UKMO-HadCM3" "AOGCM"

unique(future[future$model == "UKMO-HadCM3" & future$scenario == "A1B" & future$year == 2100, "name"])  # only 5 vars with future values
unique(future[future$model == "AOGCM" & future$scenario == "RCP26" & future$year == 2050, "name"])  # 81 vars with future values

#chosen_vars <- c("BO2_chlomean_ss", "BO2_chlorange_ss", "BO2_curvelmean_ss", "BO2_curvelrange_ss", "BO2_tempmean_ss", "BO2_temprange_ss", "BO2_salinitymean_bdmean", "BO2_salinityrange_bdmean", "BO2_tempmean_bdmean", "BO2_temprange_bdmean")
#length(chosen_vars)  # 10
#tail(future)
#chosen_vars <- unique(future[future$model == "AOGCM" & future$scenario == "RCP60" & future$year == 2100, "current_layer_code"])
chosen_vars <- c("BO2_chlomax_ss", "BO2_chlomin_ss", "BO2_chlomean_ss", "BO2_chlorange_ss", "BO2_curvelmax_ss", "BO2_curvelmin_ss", "BO2_curvelmean_ss", "BO2_curvelrange_ss", "BO2_salinitymax_ss", "BO2_salinitymean_ss", "BO2_salinitymin_ss", "BO2_salinityrange_ss", "BO2_tempmax_ss", "BO2_tempmin_ss", "BO2_tempmean_ss", "BO2_temprange_ss", "BO2_salinitymax_bdmean", "BO2_salinitymin_bdmean","BO2_salinitymean_bdmean",  "BO2_salinityrange_bdmean", "BO2_tempmax_bdmean", "BO2_tempmin_bdmean", "BO2_tempmean_bdmean", "BO2_temprange_bdmean")
length(chosen_vars)  # 24

unique(future$scenario)  # "A1B" "B1" "A2" "RCP26" "RCP45" "RCP60" "RCP85"

unique(future[c("model", "year", "scenario")])
# UKMO-HadCM3 2100
# UKMO-HadCM3 2200
#       AOGCM 2050
#       AOGCM 2100

unique(future[c("model", "year", "scenario")])
#       model year scenario
# UKMO-HadCM3 2100      A1B
# UKMO-HadCM3 2200      A1B
# UKMO-HadCM3 2100       B1
# UKMO-HadCM3 2200       B1
# UKMO-HadCM3 2100       A2
#       AOGCM 2050    RCP26
#       AOGCM 2100    RCP45
#       AOGCM 2050    RCP60
#       AOGCM 2050    RCP85
#       AOGCM 2100    RCP26
#       AOGCM 2100    RCP85
#       AOGCM 2100    RCP60
#       AOGCM 2050    RCP45


chosen_vars_2050_rcp26 <- get_future_layers(chosen_vars, scenario = "RCP26", year = 2050)$layer_code
chosen_vars_2050_rcp85 <- get_future_layers(chosen_vars, scenario = "RCP85", year = 2050)$layer_code
chosen_vars_2100_rcp26 <- get_future_layers(chosen_vars, scenario = "RCP26", year = 2100)$layer_code
chosen_vars_2100_rcp85 <- get_future_layers(chosen_vars, scenario = "RCP85", year = 2100)$layer_code

# so, 2 years x 2 emissions scenarios x 1 climate model


# download specific layers to the data directory
options(sdmpredictors_datadir = "../data/layers")
layers_curr <- load_layers(chosen_vars, rasterstack = FALSE)  # rasterstack TRUE gave error different extent
layers_curr
length((layers_curr))  # 24

layers_curr_stack <- stack(layers_curr)  # error: different extent
unique(sapply(layers_curr, extent))


# cut layers to Atlantic extent:
map("world")
atlantic_extent <- extent(-100, 35, -79.5, 80)  # tried several until right
plot(atlantic_extent, col = "orange", add = TRUE)

layers_curr <- lapply(layers_curr, crop, atlantic_extent)
layers_curr_stack <- stack(layers_curr)

plot(layers_curr_stack, maxnl = dim(layers_curr_stack)[3])
plot(layers_curr_stack[[1]])

