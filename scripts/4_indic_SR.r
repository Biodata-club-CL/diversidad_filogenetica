library(sf)
library(dplyr)
library(readr)
library(ggplot2)
library(viridis)
library(rnaturalearth)


# -------------------------------
# 📥 Leer archivos de entrada
# -------------------------------

# Matriz de comunidad (filas: celdas, columnas: especies)
comunidad <- read_csv("output/matriz_comunidad.csv")

# Grilla completa (generada previamente y guardada en RDS)
grid_sf <- readRDS("data/grid_sf.rds")

# -------------------------------
# 🧮 Calcular riqueza por celda
# -------------------------------

riqueza <- comunidad %>%
  mutate(riqueza = rowSums(across(-celda_id))) %>%
  select(celda_id, riqueza)

# -------------------------------
# ✂️ Recortar grilla a Chile continental
# -------------------------------

# Descargar Chile
chile <- ne_countries(scale = "medium", country = "Chile", returnclass = "sf")

# Recorte geográfico manual para excluir islas y Antártica
chile_continental <- st_crop(chile, xmin = -76, xmax = -66, ymin = -56, ymax = -17)

# Asegurar proyección común
grid_sf <- st_transform(grid_sf, 4326)
chile_continental <- st_transform(chile_continental, 4326)

# Calcular centroides y filtrar
centroides <- st_centroid(st_geometry(grid_sf))
dentro_chile <- st_within(centroides, st_geometry(chile_continental))
en_chile <- lengths(dentro_chile) > 0
grid_crop <- grid_sf[en_chile, ]

# -------------------------------
# 🧬 Unir grilla recortada con riqueza
# -------------------------------

grid_rich <- grid_crop %>%
  left_join(riqueza, by = "celda_id")


# -------------------------------
# 🗺️ Visualización
# -------------------------------

ggplot(grid_rich) +
  geom_sf(aes(fill = riqueza), color = "grey30", size = 0.1) +
  scale_fill_viridis(option = "magma", direction = -1, na.value = "white") +
  labs(title = paste0("Riqueza de especies por celda (", cellsize_km, " km)"),
       fill = "Riqueza") +
  theme_minimal()



