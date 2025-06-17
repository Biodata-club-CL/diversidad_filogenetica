# Tutorial: Cálculo de Diversidad Filogenética en R

Este tutorial enseña cómo calcular la diversidad filogenética (PD) y su versión estandarizada (ses.PD) a partir de registros de ocurrencia de especies de arboles de Chile obtenidos de GBIF. El flujo de trabajo utiliza una grilla espacial sobre el territorio de Chile y un árbol filogenético generado con `V.PhyloMaker`.

## Requisitos

Antes de comenzar, asegúrate de tener instaladas las siguientes bibliotecas de R:

```r
install.packages(c("sf", "dplyr", "readr", "ggplot2", "tidyr", "vegan", "picante", "viridis", "patchwork"))
```

```r
remotes::install_github("jinyizju/V.PhyloMaker")
```

# Estructura del proyecto

## El directorio tiene la siguiente estructura:

<pre><code> ``` ├── data/ # Datos de entrada y resultados intermedios ├── output/ # Resultados principales como la matriz de comunidad ├── figures/ # Mapas y visualizaciones finales ├── R/ # Funciones auxiliares en R ├── scripts/ # Scripts que se deben ejecutar en orden │ ├── 1_get_clean_data_set.r │ ├── 2_crear_comm_matrix.r │ ├── 3_phylo_tree.r │ ├── 4_indic_SR.r │ ├── 5_indic_DF.R │ ├── 6_mapas.r └── README.md # Este archivo ``` </code></pre>


## Instrucciones

### 1. Preparar los datos limpios

Ejecutar `1_get_clean_data_set.r` para filtrar y depurar los registros de ocurrencia.

### 2. Crear la matriz de comunidad

Ejecutar `2_crear_comm_matrix.r` para generar la matriz de presencia/ausencia por celda (`output/matriz_comunidad.csv`).

### 3. Generar el árbol filogenético

Ejecutar `3_phylo_tree.r` para construir un árbol filogenético a partir de los nombres de especies usando `V.PhyloMaker`.

### 4. Calcular riqueza de especies (SR)

Ejecutar `4_indic_SR.r` para calcular la riqueza de especies por celda.

### 5. Calcular PD y ses.PD

Ejecutar `5_indic_DF.R` para calcular la diversidad filogenética (PD) y la diversidad filogenética estandarizada (ses.PD) por celda.

### 6. Visualizar los resultados

Ejecutar `6_mapas.r` para generar mapas de riqueza, PD y ses.PD. El resultado combinado se guarda como un archivo PDF en la carpeta `figures/`.

## Créditos

Este tutorial fue desarrollado con fines educativos en el marco del Club de Programación de la Facultad de Ciencias Naturales y Oceanográficas de la Universidad de Concepción.

---

