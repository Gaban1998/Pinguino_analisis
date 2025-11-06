# Proyecto TFM – Análisis de tRNAs y sesgo de uso de codones en pingüinos - PEC2

**Autor:** Gabriel Peña Peña

**Máster en Bioinformática y Bioestadística – UOC (2025)**

**Tutor:** Dr. Guillem Ylla Bou

## 0. Descripción general

Este repositorio contiene los scripts, datos y flujo reproducible empleados en la PEC2 del Trabajo Final de Máster, centrado en la anotación y análisis de genes de tRNA en genomas de pingüinos mediante tRNAscan-SE 2.0, como parte del estudio:

“*Filogenia vs. ambiente térmico en el sesgo de uso de codones de pingüinos: integración de genómica comparada y abundancia de tRNAs*”

El flujo se desarrolla en WSL (Ubuntu) para usuarios de Windows y usa entornos conda para garantizar la reproducibilidad.

## 1. Requisitos e instalación del entorno

### a. Instalar WSL (en caso de Windows):

iniciar la aplicacion PowerShell y utilizar el siguiente comando:

``` bash
wsl --install
```

Esto instala Ubuntu por defecto. Posteriormente reiniciar el equipo y crea un usuario cuando se solicite.

### b. Actualizar e instalar Miniconda en Ubuntu:

``` bash
sudo apt update && sudo apt upgrade -y
cd ~
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
bash miniconda.sh
source ~/.bashrc
```

### c. Configurar conda y crear entorno de análisis:

``` bash
conda config --add channels bioconda
conda config --add channels conda-forge
conda create -n trna_env tRNAscan-SE -y
conda activate trna_env
```

Se verifica que la instalación de funcione:

``` bash
tRNAscan-SE -h
```

## 2. Estructura del proyecto

``` text
Pinguino_analisis/
 ├─ run_trnascan_eukaryotic.sh
 ├─ PEC2_codones_trna_penguins.qmd
 └─ data/
     ├─ APT_FOR/cds_from_genomic.fna, *_genomic.fna
     ├─ EUD_MIN/cds_from_genomic.fna, *_genomic.fna
     ├─ SPH_DEM/cds_from_genomic.fna, *_genomic.fna
     └─ SPH_MEN/cds_from_genomic.fna, *_genomic.fna
```

## 3 Descarga de genomas desde NCBI

Cada carpeta de especie dentro de `data/` debe contener los genomas obtenidos desde
[NCBI GenBank](https://www.ncbi.nlm.nih.gov/genome/).

Por ejemplo:

- **Aptenodytes forsteri** (Emperor penguin)  
- **Eudyptula minor** (Little penguin)  
- **Spheniscus demersus** (African penguin)  
- **Spheniscus mendiculus** (Galápagos penguin)

Dentro de cada carpeta (`data/APE_FOR/`, `data/EUD_MIN/`, etc.) deben estar los siguientes archivos:

cds_from_genomic.fna (Secuencias codificantes (CDS) obtenidas del archivo GFF)
*_genomic.fna (Genoma completo (usado por tRNAscan-SE))

Los archivos pueden descargarse manualmente desde el portal GenBank, en este repositorio no se incluyen los archivos FASTA/GFF para reducir tamaño, pero el flujo de trabajo asume que cada especie tiene estos dos archivos en su carpeta correspondiente.

## 4. Ejecución de tRNAscan-SE

Desde Ubuntu/WSL ejecutar en la carpeta del proyecto (Pinguino_analisis) el script `run_trnascan_eukaryotic.sh`:

``` text
conda activate trna_env
./run_trnascan_eukaryotic.sh
```

El script detecta automáticamente los archivos genómicos que terminan en \_genomic.fna (excluyendo cds_from_genomic.fna) dentro de cada carpeta de especie y genera los archivos:

-   trnascan.txt (resultados detallados)
-   trnascan.stats.txt

## 5. Análisis de codones y tRNAs en R/Quarto

El flujo de análisis de la PEC2 se implementa en el archivo:

- `PEC2_codones_trna_penguins.qmd`

Este documento Quarto:

- Lee las secuencias codificantes (`cds_from_genomic.fna`) y los resultados de tRNAscan-SE (`trnascan.txt`)
  para cada especie.
- Aplica control de calidad a las CDS.
- Calcula el uso relativo de codones (RSCU) y métricas de sesgo por aminoácido.
- Integra la información de abundancia de tRNAs y genera las figuras principales
  (heatmap de RSCU, PCA, clustering jerárquico, gráficos codón–tRNA, etc.).

### 5.1 Requisitos para ejecutar el `.qmd`

Se recomienda tener instalado:

- R (versión ≥ 4.5.2)
- Quarto (RStudio con soporte Quarto)
- Paquetes de R usados en el documento (cargados en el primer chunk):
  `tidyverse`, `readr`, `Biostrings`, `pheatmap`, `ggrepel`, `scales`, `dplyr`, `ggplot2`, entre otros.

Si al ejecutar aparecen errores de “paquete no encontrado”, se pueden instálar con:

```r
install.packages(c("tidyverse", "readr", "pheatmap", "ggrepel", "scales", `dplyr`, `ggplot2`))
BiocManager::install("Biostrings")
```

### 5.2 Cómo generar el informe HTML

Desde la carpeta del proyecto (Pinguino_analisis/), una vez disponibles los archivos:

- `data/*/cds_from_genomic.fna`

- `data/*/trnascan.txt`

Se pueden renderizar los análisis con:

`quarto render PEC2_codones_trna_penguins.qmd`

Esto generará el archivo:

`PEC2_codones_trna_penguins.html`

que contiene el informe reproducible de la PEC2 (figuras, tablas y descripción del flujo).
