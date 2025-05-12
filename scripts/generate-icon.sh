#!/bin/bash

# Script per generare un'icona ICNS da un file SVG

SVG_FILE="takeasip/Resources/AppIcon.svg"
ICONSET_DIR="takeasip/Resources/AppIcon.iconset"
ICNS_FILE="takeasip/Resources/AppIcon.icns"

# Verifica che il file SVG esista
if [ ! -f "$SVG_FILE" ]; then
    echo "Errore: File SVG non trovato: $SVG_FILE"
    exit 1
fi

# Crea la directory per l'iconset se non esiste
mkdir -p "$ICONSET_DIR"

# Dimensioni richieste per un file ICNS
SIZES=(16 32 128 256 512)

# Genera le icone in varie dimensioni
for size in "${SIZES[@]}"; do
    # Dimensione normale
    echo "Generazione icona ${size}x${size}..."
    sips -s format png --resampleHeightWidth "$size" "$size" "$SVG_FILE" --out "${ICONSET_DIR}/icon_${size}x${size}.png" 2>/dev/null || {
        # Se sips fallisce, prova con inkscape o convert
        if command -v inkscape >/dev/null 2>&1; then
            inkscape -w "$size" -h "$size" "$SVG_FILE" -o "${ICONSET_DIR}/icon_${size}x${size}.png"
        elif command -v convert >/dev/null 2>&1; then
            convert -background none -resize "${size}x${size}" "$SVG_FILE" "${ICONSET_DIR}/icon_${size}x${size}.png"
        else
            echo "Errore: Non è possibile convertire l'SVG in PNG. Installa 'inkscape' o 'imagemagick'."
            exit 1
        fi
    }
    
    # Dimensione @2x (Retina)
    double_size=$((size * 2))
    echo "Generazione icona ${size}x${size}@2x (${double_size}x${double_size})..."
    sips -s format png --resampleHeightWidth "$double_size" "$double_size" "$SVG_FILE" --out "${ICONSET_DIR}/icon_${size}x${size}@2x.png" 2>/dev/null || {
        # Se sips fallisce, prova con inkscape o convert
        if command -v inkscape >/dev/null 2>&1; then
            inkscape -w "$double_size" -h "$double_size" "$SVG_FILE" -o "${ICONSET_DIR}/icon_${size}x${size}@2x.png"
        elif command -v convert >/dev/null 2>&1; then
            convert -background none -resize "${double_size}x${double_size}" "$SVG_FILE" "${ICONSET_DIR}/icon_${size}x${size}@2x.png"
        else
            echo "Errore: Non è possibile convertire l'SVG in PNG. Installa 'inkscape' o 'imagemagick'."
            exit 1
        fi
    }
done

# Crea il file ICNS
echo "Generazione del file ICNS..."
iconutil -c icns "$ICONSET_DIR" -o "$ICNS_FILE" || {
    echo "Errore durante la creazione del file ICNS. Assicurati che 'iconutil' sia disponibile."
    exit 1
}

echo "Icona ICNS creata con successo: $ICNS_FILE"
