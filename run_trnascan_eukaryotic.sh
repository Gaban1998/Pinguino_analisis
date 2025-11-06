#!/usr/bin/env bash
set -euo pipefail

# Se ajusta para que los patrones que no hagan match den array vacío
shopt -s nullglob

echo "Asegúrate de tener activado el entorno:  conda activate trna_env"
echo

for dir in data/*/; do
    [ -d "$dir" ] || continue

    species="$(basename "$dir")"
    echo "-----------------------------------------"
    echo "Procesando carpeta: $species"

    # Se construye la lista de candidatos *genomic.fna excluyendo cds_from_genomic.fna
    fasta_candidates=()
    for f in "${dir}"*genomic.fna; do
        base="$(basename "$f")"
        if [[ "$base" == "cds_from_genomic.fna" ]]; then
            continue
        fi
        fasta_candidates+=("$f")
    done

    if ((${#fasta_candidates[@]} == 0)); then
        echo "  [SKIP] No se encontró ningún archivo genómico adecuado (*genomic.fna distinto de cds_from_genomic.fna) en $dir"
        continue
    elif ((${#fasta_candidates[@]} > 1)); then
        echo "  [WARN] Hay varios candidatos a genoma en $dir:"
        for f in "${fasta_candidates[@]}"; do
            echo "    - $(basename "$f")"
        done
        echo "  Usando el primero por defecto."
    fi

    fasta="${fasta_candidates[0]}"
    fasta_basename="$(basename "$fasta")"

    echo "  FASTA genómico elegido: $fasta_basename"

    cd "$dir"

    echo "  Ejecutando tRNAscan-SE..."
    tRNAscan-SE \
        -o trnascan.txt \
        -m trnascan.stats.txt \
        "$fasta_basename"

    echo "  Listo: $(pwd)/trnascan.txt"
    cd - > /dev/null
done

echo "-----------------------------------------"
echo "Todos los análisis de tRNAs finalizados."

