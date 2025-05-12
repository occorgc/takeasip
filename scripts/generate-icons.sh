#!/bin/bash

# Script per generare le icone per TakeASip
# Questo script converte un'immagine SVG/PNG in un set di icone per macOS

# Percorsi assoluti
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$( cd "${SCRIPT_DIR}/.." && pwd )"

# Variabili
APP_NAME="TakeASip"
SOURCE_ICON="${BASE_DIR}/takeasip/Resources/AppIcon.svg"
SOURCE_ICON_PNG="${BASE_DIR}/takeasip/Resources/AppIcon.png"
ICONSET_DIR="${BASE_DIR}/build/AppIcon.iconset"
ICONS_DIR="${BASE_DIR}/takeasip/Resources"
ICNS_FILE="${ICONS_DIR}/AppIcon.icns"

# Crea la directory iconset se non esiste
mkdir -p "${ICONSET_DIR}"

# Verifica se abbiamo sips e iconutil (strumenti macOS per icone)
if ! command -v sips &> /dev/null || ! command -v iconutil &> /dev/null; then
    echo "Errore: sips e iconutil sono necessari per generare le icone."
    echo "Questi strumenti sono inclusi in macOS. Verifica la tua installazione."
    exit 1
fi

# Converte SVG in PNG se necessario
if [ -f "${SOURCE_ICON}" ]; then
    echo "Trovato file SVG, converto in PNG..."
    
    # Verifica se abbiamo rsvg-convert
    if command -v rsvg-convert &> /dev/null; then
        echo "Uso rsvg-convert per la conversione..."
        rsvg-convert -w 1024 -h 1024 "${SOURCE_ICON}" -o "${SOURCE_ICON_PNG}"
    # Alternativa con Inkscape
    elif command -v inkscape &> /dev/null; then
        echo "Uso Inkscape per la conversione..."
        inkscape -w 1024 -h 1024 "${SOURCE_ICON}" -o "${SOURCE_ICON_PNG}"
    # Alternativa con convert (ImageMagick)
    elif command -v convert &> /dev/null; then
        echo "Uso ImageMagick per la conversione..."
        convert -density 300 "${SOURCE_ICON}" -resize 1024x1024 "${SOURCE_ICON_PNG}"
    else
        echo "Nessun convertitore SVG trovato. Installa rsvg-convert, Inkscape o ImageMagick."
        echo "Verifico se esiste un'immagine PNG..."
        
        if [ ! -f "${SOURCE_ICON_PNG}" ]; then
            echo "Errore: Nessuna immagine PNG trovata e impossibile convertire SVG."
            exit 1
        fi
    fi
elif [ ! -f "${SOURCE_ICON_PNG}" ]; then
    echo "Errore: Nessuna icona di origine trovata (né SVG né PNG)."
    exit 1
fi

echo "Generazione delle icone di diverse dimensioni..."

# Dimensioni per le icone macOS (in pixel)
ICON_SIZES=(16 32 64 128 256 512 1024)

# Genera tutte le dimensioni richieste
for size in "${ICON_SIZES[@]}"; do
    # Icona regolare
    sips -z ${size} ${size} "${SOURCE_ICON_PNG}" --out "${ICONSET_DIR}/icon_${size}x${size}.png"
    
    # Icona @2x (retina), eccetto per 1024 che è già la dimensione massima
    if [ ${size} -lt 512 ]; then
        sips -z $((size*2)) $((size*2)) "${SOURCE_ICON_PNG}" --out "${ICONSET_DIR}/icon_${size}x${size}@2x.png"
    fi
done

# Crea il file ICNS
echo "Generazione del file ICNS..."
mkdir -p "$(dirname "${ICNS_FILE}")"
iconutil -c icns -o "${ICNS_FILE}" "${ICONSET_DIR}"

if [ $? -eq 0 ]; then
    echo "File ICNS creato con successo: ${ICNS_FILE}"
    
    # Copia anche alcune dimensioni specifiche per altri usi
    cp "${ICONSET_DIR}/icon_16x16.png" "${ICONS_DIR}/AppIcon-16.png"
    cp "${ICONSET_DIR}/icon_32x32.png" "${ICONS_DIR}/AppIcon-32.png"
    cp "${ICONSET_DIR}/icon_128x128.png" "${ICONS_DIR}/AppIcon-128.png"
    cp "${ICONSET_DIR}/icon_512x512.png" "${ICONS_DIR}/AppIcon-512.png"

    # Crea icone per uso specifico nel DMG
    cp "${ICONSET_DIR}/icon_32x32.png" "${ICONS_DIR}/drop-icon.png"
    cp "${ICONSET_DIR}/icon_32x32.png" "${ICONS_DIR}/folder-icon.png"
    
    echo "Icone generate con successo!"
else
    echo "Errore nella generazione del file ICNS."
    exit 1
fi
