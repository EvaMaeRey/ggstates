## code to prepare `DATASET` dataset goes here

library

state_attributes <- state.x77 |>
  data.frame() |>
  tibble::rownames_to_column(var = "state_name")

usethis::use_data(state_attributes, overwrite = TRUE)


st_read(system.file("shape/nc.shp", package="sf")) %>% class()

states_reference <- sf::read_sf("data-raw/cb_2018_us_state_20m/cb_2018_us_state_20m.shp") %>%
  filter(NAME != "Puerto Rico",
         NAME != "District of Colombia") %>%
  rename(state_name = NAME) %>%
  rename(state_abb = STUSPS) %>%
  select(state_abb, state_name, geometry)

states_reference %>% class()

library(sf)
ggnc:::create_geometries_reference(sfdata = states_reference,
                                   id_cols = c(state_name, state_abb)) ->
state_reference_full

as_Spatial(state_reference_full, crs =NAD83)

# this should be converted to an sf object and then resaved I think
usethis::use_data(state_reference_full, overwrite = TRUE)


