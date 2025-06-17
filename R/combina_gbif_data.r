#' Unifica tipos de columnas y combina una lista de data.frames GBIF
#'
#' @param lista_df Lista de data.frames descargados desde GBIF
#' @return Un único data.frame combinado
#' @examples
#' combined_data <- unificar_y_combinar_datasets(datasets_list)

unificar_y_combinar_datasets <- function(lista_df) {
  # Obtener todos los nombres de columnas presentes
  todas_columnas <- unique(unlist(lapply(lista_df, names)))
  
  # Completar data.frames con columnas faltantes
  lista_df <- lapply(lista_df, function(df) {
    faltantes <- setdiff(todas_columnas, names(df))
    for (col in faltantes) {
      df[[col]] <- NA
    }
    df <- df[, todas_columnas]
    return(df)
  })
  
  # Detectar columnas con tipos distintos
  tipos_por_columna <- lapply(lista_df, function(df) sapply(df, class))
  tipos_df <- bind_rows(tipos_por_columna)
  
  columnas_conflictivas <- names(tipos_df)[apply(tipos_df, 2, function(x) length(unique(x)) > 1)]
  
  # Forzar columnas conflictivas a character
  lista_df_limpia <- lapply(lista_df, function(df) {
    for (col in columnas_conflictivas) {
      df[[col]] <- as.character(df[[col]])
    }
    return(df)
  })
  
  # Combinar
  df_combinado <- bind_rows(lista_df_limpia)
  return(df_combinado)
}
