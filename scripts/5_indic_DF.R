#install.packages("picante")
library(picante)
library(dplyr)
library(tibble)

comunidad <- read_csv("output/matriz_comunidad.csv")
phylo_tree <- readRDS("output/arbol_filogenetico.rds")
phylo_tree$tip.label <- gsub("_", " ", phylo_tree$tip.label)
grid_sf <- readRDS("data/grid_sf.rds")

# Convertir celda_id como rownames (requisito de picante)
matriz_community <- comunidad %>%
  column_to_rownames("celda_id")

# Diversidad filogenética absoluta
pd_resultados <- pd(matriz_community, phylo_tree, include.root = FALSE)
# Visualizar
head(pd_resultados)
pd_resultados$site <- rownames(pd_resultados) 

set.seed(123)  # reproducibilidad
ses_pd_resultados <- ses.pd(matriz_community, phylo_tree,
                            null.model = "taxa.labels", runs = 999, include.root = FALSE)
##demora par de minutos

# Save
ses_pd_resultados$site <- rownames(ses_pd_resultados) 

saveRDS(pd_resultados, "output/pd.rds")
saveRDS(ses_pd_resultados, "output/ses_pd.rds")




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

pd <- pd_resultados %>%
  select(celda_id = site,
        PD)

grid_PD <- grid_crop %>%
  left_join(pd, by = "celda_id")





grid_sespd <- grid_sf %>%
  left_join(ses_pd_resultados, by = c("celda_id" = "site"))

# 4. Descargar y recortar Chile continental
chile <- ne_countries(scale = "medium", country = "Chile", returnclass = "sf")
chile_continental <- st_crop(chile, xmin = -76, xmax = -66, ymin = -56, ymax = -17)
chile_continental <- st_transform(chile_continental, 4326)

# 5. Calcular centroides y hacer el crop de la grilla
centroides <- st_centroid(st_geometry(grid_sf))
dentro_chile <- st_within(centroides, st_geometry(chile_continental))
en_chile <- lengths(dentro_chile) > 0

grid_pd_crop <- grid_pd[en_chile, ]
grid_sespd_crop <- grid_sespd[en_chile, ]




