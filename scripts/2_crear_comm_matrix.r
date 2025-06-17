# Cargar librerías
library(sf)
library(dplyr)
library(tidyr)
library(readr)
library(stringr)

# 1. Leer datos limpios
occs <- read_csv("data/occs_limpias.csv")

#corregir scientificNames, eliminando autores
# Función para extraer las dos primeras palabras + "var." si existe
extraer_nombre <- function(nombre) {
  # Extraemos las primeras dos palabras y, si existe, "var." + la siguiente
  resultado <- str_extract(
    nombre,
    "^([:alpha:]+\\s[:alpha:]+)(?:\\svar\\.\\s[:alpha:]+)?"
  )
  return(resultado)
}

##Casos especiales
occs$scientificName <- occs$scientificName %>%
  gsub("Nothofagus ×leoni Espinosa", "Nothofagus leoni", .) %>%
  gsub("Temu cruckshanksii \\(Hook. & Arn.\\) O.Berg", "Blepharocalyx cruckshanksii", .)

# Aplicamos la función al vector
occs$scientificName <- sapply(occs$scientificName, extraer_nombre, USE.NAMES = FALSE)
head(occs)
unique(occs$scientificName)


# Parámetro ajustable: tamaño de celda (en km)
cellsize_km <- 50
cellsize_m <- cellsize_km * 1000

# Convertir a objeto espacial y reproyectar
occs_sf <- occs %>%
  st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), crs = 4326) %>%
  st_transform(3857)

# Crear bounding box de los datos
bbox <- st_bbox(occs_sf)

# Expandir artificialmente el bbox para asegurar margen
bbox_exp <- bbox
buffer <- 50000  # 50 km
bbox_exp["xmin"] <- bbox["xmin"] - buffer
bbox_exp["xmax"] <- bbox["xmax"] + buffer
bbox_exp["ymin"] <- bbox["ymin"] - buffer
bbox_exp["ymax"] <- bbox["ymax"] + buffer

# Crear grilla sobre el bbox expandido
grid <- st_make_grid(
  st_as_sfc(bbox_exp),
  cellsize = c(cellsize_m, cellsize_m),
  square = TRUE
)

# Convertir a sf y asignar IDs de norte a sur
grid_sf <- st_sf(geometry = grid) %>%
  mutate(centroid = st_centroid(geometry)) %>%
  mutate(lat = st_coordinates(centroid)[,2]) %>%
  arrange(desc(lat)) %>%
  mutate(celda_id = paste0("C", row_number()))
class(grid_sf)
#save grid_sf as a rds object
saveRDS(grid_sf, "data/grid_sf.rds")
# Cruzar ocurrencias con celdas
occs_with_cells <- st_join(occs_sf, grid_sf, left = FALSE)

# Crear matriz sitio x especie
comunidad <- occs_with_cells %>%
  st_drop_geometry() %>%
  select(celda_id, scientificName) %>%
  distinct() %>%
  mutate(presencia = 1) %>%
  pivot_wider(names_from = scientificName, values_from = presencia, values_fill = 0)
dim(comunidad)  # Ver dimensiones de la matriz
colnames(comunidad)
# Guardar resultado
write_csv(comunidad, "output/matriz_comunidad.csv")

