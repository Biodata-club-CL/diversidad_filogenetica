library(readxl)
library(tidyr)
library(dplyr)
library(rgbif)

user <- "ricardosegovia"
pwd <- "salas11"
email <- "segoviacortes@gmail.com"

# 1. Cargar datos
cat <- read_excel("/home/ricardo/Documents/arch_doc/projects/Fondecyt_2026/Catalogo.xlsx")
# 2. Obtener listado de especies válidas (endémicas, nativas o sin categoría) y determinadas
colnames(cat)
species_list <- cat %>%
  filter(determined == TRUE) %>%
  filter(status %in% c("Endémica", "Nativa") | is.na(status)) %>%
  filter(plant_habit_1 == "Árbol") %>%
  pull(scientific_name) %>%
  unique()


# Initialize list to store datasets
datasets_list <- list()

# Loop through each species
for(species_name in species_list){
  
  cat("Processing:", species_name, "\n")
  
  # Get taxon key
  taxon_info <- name_backbone(species_name)
  taxon_key <- taxon_info$usageKey
  
  # Define and execute GBIF download request
  gbif_download <- occ_download(
    pred("taxonKey", taxon_key),
    pred("country", "CL"), 
    pred("hasGeospatialIssue", FALSE), 
    pred("hasCoordinate", TRUE), 
    pred("occurrenceStatus", "PRESENT"), 
    pred_gte("year", 2000), 
    user = user, pwd = pwd, email = email,
    format = "SIMPLE_CSV"
  )
  
  # Wait for the download to complete
  occ_download_wait(gbif_download)
  
  # Import downloaded data
  data_downloaded <- occ_download_get(gbif_download) |>
    occ_download_import()
  
  # Store data in the list with species name
  datasets_list[[species_name]] <- data_downloaded
  
  cat("Completed:", species_name, "\n")
}

# combine and reduce data
combined_data <- bind_rows(datasets_list) #%>%
#  filter(between(decimalLatitude, -55.0, -15.0),
#         between(decimalLongitude, -74.0, -68.0))

dim(combined_data)  # Verifica dimensiones después del filtrado
# Export combined data to CSV
write.csv(combined_data2, "combined_gbif_data.csv", row.names = FALSE)