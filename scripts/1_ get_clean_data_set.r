library(readxl)
library(tidyr)
library(dplyr)
library(rgbif)
#source("R/combina_gbif_data.r")
library(sf)
library(rnaturalearth)
library(CoordinateCleaner)


# user <- "tu.usuario.gbif"  # Reemplaza con tu usuario de GBIF
# pwd <- "tu.contraseña.gbif"  # Reemplaza con tu contraseña de GBIF
# email <- "tu.correo"

# # 1. Cargar datos
# cat <- read_excel("/home/ricardo/Documents/arch_doc/projects/Fondecyt_2026/Catalogo.xlsx")
# # 2. Obtener listado de especies válidas (endémicas, nativas o sin categoría) y determinadas
# colnames(cat)
# species_list <- cat %>%
#   filter(determined == TRUE) %>%
#   filter(status %in% c("Endémica", "Nativa") | is.na(status)) %>%
#   filter(plant_habit_1 == "Árbol") %>%
#   pull(scientific_name) %>%
#   unique()


# # Initialize list to store datasets
# datasets_list <- list()

# # Loop through each species
# for(species_name in species_list){

#   cat("Processing:", species_name, "\n")

#   # Get taxon key
#   taxon_info <- name_backbone(species_name)
#   taxon_key <- taxon_info$usageKey

#   # Define and execute GBIF download request
#   gbif_download <- occ_download(
#     pred("taxonKey", taxon_key),
#     pred("country", "CL"),
#     pred("hasGeospatialIssue", FALSE),
#     pred("hasCoordinate", TRUE),
#     pred("occurrenceStatus", "PRESENT"),
#     pred_gte("year", 2000),
#     user = user, pwd = pwd, email = email,
#     format = "SIMPLE_CSV"
#   )

#   # Wait for the download to complete
#   occ_download_wait(gbif_download)

#   # Import downloaded data
#   data_downloaded <- occ_download_get(gbif_download) |>
#     occ_download_import()

#   # Store data in the list with species name
#   datasets_list[[species_name]] <- data_downloaded

#   cat("Completed:", species_name, "\n")
# }


# # Estandariza columnas conflictivas antes de combinar
# datasets_list_clean <- lapply(datasets_list, function(df) {
#   df %>%
#     mutate(
#       catalogNumber = as.character(catalogNumber),
#       # Agrega aquí otras columnas si te da error con ellas también
#       institutionCode = as.character(institutionCode)
#     )
# })

# # Combina los datos
# combined_data <- unificar_y_combinar_datasets(datasets_list)

# # Export combined data to CSV
# write.csv(combined_data, "data/combined_gbif_data.csv", row.names = FALSE)

## Limpieza de datos
combined_data <- read.csv("data/combined_gbif_data.csv")
head(combined_data)
combined_data <- combined_data %>%
  select(
    scientificName,
    catalogNumber,
    institutionCode,
    decimalLatitude,
    decimalLongitude,
    year,
    month,
    day
  ) %>%
  filter(!is.na(decimalLatitude) & !is.na(decimalLongitude)) %>%
  distinct()

str(combined_data)

## crop del dataset a Chile continental
# Convertir el data.frame a objeto espacial
occs_sf <- combined_data %>%
  filter(!is.na(decimalLatitude), !is.na(decimalLongitude)) %>%
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326)

# Descargar y recortar la capa de Chile
chile <- ne_countries(scale = "medium", country = "Chile", returnclass = "sf")

# Recorte manual para excluir Magallanes y Antártica
chile_continental <- st_crop(chile, xmin = -76, xmax = -66, ymin = -56, ymax = -17)

head(occs_sf)
# Hacer intersección espacial
occs_crop <- st_filter(occs_sf, chile_continental)
head(occs_crop)

# Convertir de vuelta a data.frame para limpieza posterior
occs_crop_df <- occs_crop %>%
  mutate(
    decimalLongitude = st_coordinates(geometry)[,1],
    decimalLatitude = st_coordinates(geometry)[,2]
  ) %>%
  st_drop_geometry()
  head(occs_crop_df)

# #Limpieza de coordenadas usando clean_coordinates
# Asegurar columnas mínimas requeridas
clean_input <- occs_crop_df %>%
  select(
    species = scientificName,
    decimalLatitude,
    decimalLongitude,
    year
  ) %>%
  mutate(iso_a2 = "CL")  # obligatorio para algunas pruebas
head(clean_input)
# Aplicar filtros estándar sugeridos por Zizka et al. (2019)
cc_flags <- clean_coordinates(
  x = clean_input,
  lon = "decimalLongitude",
  lat = "decimalLatitude",
  species = "species",
  countries = "iso_a2",
  tests = c("capitals", "centroids", "equal", "gbif", "institutions",
            "seas", "zeros", "urban"),
  value = "flagged"
)

# Verificar resumen de limpieza
summary(cc_flags)
str(cc_flags)

# Conservar solo los puntos que pasaron todas las pruebas
occs_limpias <- occs_crop_df[cc_flags, ]

## guardar datos limpios
write.csv(occs_limpias, "data/occs_limpias.csv", row.names = FALSE)
