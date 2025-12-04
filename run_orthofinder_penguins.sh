#!/usr/bin/env bash
set -euo pipefail

echo "Asegúrate de tener activado el entorno de OrthoFinder:"
echo "  conda activate ortho_env"
echo

# Carpeta de input para OrthoFinder
INPUT_DIR="orthofinder_input"

# Crear carpeta de entrada si no existe
mkdir -p "${INPUT_DIR}"

echo "========================================="
echo "Preparando archivos de entrada para OrthoFinder..."
echo "Origen: data/*/protein.faa"
echo "Destino: ${INPUT_DIR}/<ESPECIE>.faa"
echo "========================================="
echo

# Copiar automáticamente los protein.faa de cada especie
for dir in data/*/; do
    [ -d "$dir" ] || continue

    species="$(basename "$dir")"
    protein_faa="${dir}protein.faa"

    echo "Especie: ${species}"

    if [[ -f "${protein_faa}" ]]; then
        cp "${protein_faa}" "${INPUT_DIR}/${species}.faa"
        echo "  [OK] Copiado: ${protein_faa} -> ${INPUT_DIR}/${species}.faa"
    else
        echo "  [WARN] No se encontró protein.faa en ${dir}, se omite esta especie."
    fi

    echo
done

echo "========================================="
echo "Contenido de ${INPUT_DIR}:"
ls -1 "${INPUT_DIR}" || echo "  (vacío)"
echo "========================================="
echo

# Ejecutar OrthoFinder
echo "Ejecutando OrthoFinder sobre los proteomas encontrados..."
echo

orthofinder -f "${INPUT_DIR}" -t 4 -a 4

echo
echo "========================================="
echo "OrthoFinder finalizado."
echo "Revisa la carpeta:"
echo "  ${INPUT_DIR}/OrthoFinder/Results_*/"
echo "El archivo de orthogrupos que usa el análisis en R es:"
echo "  Orthogroups/Orthogroups.txt"
echo "========================================="
