
library(ggplot2)
library(viridis)
library(dplyr)
library(sf)
library(patchwork)
# -------------------------------
# Mapas
# -------------------------------
#Species_Richness
SR<-ggplot(grid_rich) +
  geom_sf(aes(fill = riqueza), color = "grey30", size = 0.1) +
  scale_fill_viridis(option = "magma", direction = -1, na.value = "white") +
  labs(title = paste0("Riqueza de especies"),
       fill = "Riqueza") +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),  # elimina los valores del eje x
    axis.ticks.x = element_blank(), # elimina las marcas del eje x
    panel.grid.major.x = element_blank() # elimina la grilla vertical
  )

# PD Observado
pd <- ggplot(grid_pd_crop) +
  geom_sf(aes(fill = PD), color = "grey30", size = 0.1) +
  scale_fill_viridis(option = "plasma", na.value = "white") +
  labs(title = "Diversidad Filogenética\nObservada (PD)",
       fill = "PD") +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),  # elimina los valores del eje x
    axis.ticks.x = element_blank(), # elimina las marcas del eje x
    panel.grid.major.x = element_blank() # elimina la grilla vertical
  )

# SES-PD
ses_pd <- ggplot(grid_sespd_crop) +
  geom_sf(aes(fill = pd.obs.z), color = "grey30", size = 0.1) +
  scale_fill_viridis(option = "cividis", na.value = "white") +
  labs(title = "Diversidad Filogenética\nEstandarizada (sesPD)",
       fill = "SES-PD (z)") +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),  # elimina los valores del eje x
    axis.ticks.x = element_blank(), # elimina las marcas del eje x
    panel.grid.major.x = element_blank() # elimina la grilla vertical
  )



# Categorizar según z-score
grid_sespd_crop <- grid_sespd_crop %>%
  mutate(
    categoria_ses = case_when(
      pd.obs.z < -1 ~ "Baja",
      pd.obs.z > 1 ~ "Alta",
      TRUE ~ "Neutra"
    )
  )


# Mapa categórico
ses_pd_sign <- ggplot(grid_sespd_crop) +
  geom_sf(aes(fill = categoria_ses), color = "grey30", size = 0.1) +
  scale_fill_manual(
    values = c(
      "Baja" = "#d73027",    # rojo
      "Neutra" = "#ffffbf",  # amarillo claro
      "Alta" = "#1a9850"     # verde
    ),
    na.value = "white"
  ) +
  labs(
    title = "Categorías de Diversidad\nFilogenética Estandarizada (SES)",
    fill = "Diversidad\nfilogenética"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_blank(),  # elimina los valores del eje x
    axis.ticks.x = element_blank(), # elimina las marcas del eje x
    panel.grid.major.x = element_blank() # elimina la grilla vertical
  )



# Combinar con patchwork
(SR | pd | ses_pd | ses_pd_sign)
