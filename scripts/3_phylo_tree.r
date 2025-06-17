library(sf)
library(dplyr)
library(readr)
library(ggplot2)
library(viridis)
library(rnaturalearth)
remotes::install_github("jinyizju/V.PhyloMaker")
library(V.PhyloMaker)


# -------------------------------
# 📥 Leer archivos de entrada
# -------------------------------

# Matriz de comunidad (filas: celdas, columnas: especies)
comunidad <- read_csv("output/matriz_comunidad.csv")

# Extraer nombres de especies desde columnas (excluyendo 'celda_id')
especies <- colnames(comunidad)[-1]
combined_data <- read.csv("data/combined_gbif_data.csv")
# Crear tabla única de género → familia
tabla_familias <- combined_data %>%
  filter(!is.na(genus), !is.na(family)) %>%
  distinct(genus, family)

##Problemas detectados con sinónimos
# Crear tabla manual de asociaciones genus → family
familias_manuales <- tibble(
  genus = c("Dasyphyllum", "Archidasyphyllum", "Gayella", "Strombocarpa",
            "Caesalpinia", "Echinopsis", "Lithrea", "Neltuma", 
            "Libocedrus", "Acacia"),
  family = c("Asteraceae", "Asteraceae", "Brassicaceae", "Fabaceae",
             "Fabaceae", "Cactaceae", "Anacardiaceae", "Fabaceae",
             "Cupressaceae", "Fabaceae")
)

tabla_familias <- bind_rows(tabla_familias, familias_manuales) %>%
  distinct(genus, .keep_all = TRUE)

# Verifica cuántos géneros únicos tienes
n_distinct(tabla_familias$genus)


# Separar en genus y species
datos_plantas <- tibble(
  species = especies,
  genus = sub(" .*", "", especies),
  epithet = sub(".* ", "", especies)
)
# Asociar familias
datos_plantas <- datos_plantas %>%
  left_join(tabla_familias, by = "genus")

# Verificar especies sin familia
datos_sin_familia <- datos_plantas %>% filter(is.na(family))
nrow(datos_sin_familia)

as.data.frame(datos_plantas)

print(datos_sin_familia$genus)


arbol_resultado <- phylo.maker(
  sp.list = datos_plantas,
  tree = GBOTB.extended,
  nodes = nodes.info.1,
  scenarios = "S3"
)

str(arbol_resultado)
# Extraer el árbol como objeto phylo
arbol_phylo <- arbol_resultado$scenario.3
saveRDS(arbol_phylo, "output/arbol_filogenetico.rds")
