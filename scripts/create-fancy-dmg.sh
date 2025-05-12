#!/bin/bash

# Script per creare un DMG professionale per TakeASip
# Questo script utilizza create-dmg per generare un DMG con sfondo personalizzato
# e posizionamento corretto di icone

# Percorsi assoluti
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$( cd "${SCRIPT_DIR}/.." && pwd )"

# Variabili
APP_NAME="TakeASip"
VERSION="1.0.0"
DMG_NAME="${APP_NAME}-${VERSION}"
BUILD_DIR="${BASE_DIR}/build"
RELEASE_DIR="${BASE_DIR}/release"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
DMG_PATH="${RELEASE_DIR}/${DMG_NAME}.dmg"
BACKGROUND_DIR="${BUILD_DIR}/background"
BACKGROUND_IMAGE="${BACKGROUND_DIR}/background.png"
RESOURCES_DIR="${BASE_DIR}/takeasip/Resources"

# Dimensioni e posizioni
ICON_SIZE=80
WINDOW_WIDTH=540
WINDOW_HEIGHT=380
ICON_POSITION_X=120
ICON_POSITION_Y=180
APPLICATIONS_POSITION_X=420
APPLICATIONS_POSITION_Y=180

# Colori
BACKGROUND_COLOR="#f5f5f7"  # Grigio chiaro stile Apple

# Verifica la presenza di create-dmg
if ! command -v create-dmg &> /dev/null; then
    echo "Il comando 'create-dmg' non è stato trovato."
    echo "Per installarlo, esegui: brew install create-dmg"
    echo "...oppure esegui: npm install -g create-dmg"
    echo "Utilizzo lo script semplice come fallback..."
    "${SCRIPT_DIR}/create-simple-dmg.sh"
    exit $?
fi

# Verifica che l'app sia stata compilata
if [ ! -d "${APP_PATH}" ]; then
    echo "Errore: l'app non esiste. Compilala prima con 'make build'"
    exit 1
fi

# Crea le directory necessarie
mkdir -p "${RELEASE_DIR}"
mkdir -p "${BACKGROUND_DIR}"

# Rimuovi il DMG esistente se presente
if [ -f "${DMG_PATH}" ]; then
    echo "Rimozione del DMG esistente..."
    rm -f "${DMG_PATH}"
fi

# Funzione per creare l'immagine di sfondo
create_background_image() {
    echo "Creazione dell'immagine di sfondo..."
    
    # Verifica se abbiamo convert (ImageMagick)
    if command -v convert &> /dev/null; then
        # Crea uno sfondo stilizzato con convert
        convert -size ${WINDOW_WIDTH}x${WINDOW_HEIGHT} \
            xc:"${BACKGROUND_COLOR}" \
            -font Helvetica-Bold -pointsize 16 -fill "#333333" \
            -gravity north -annotate +0+70 "Installa TakeASip" \
            -font Helvetica -pointsize 12 -fill "#666666" \
            -gravity north -annotate +0+100 "Trascina l'icona nella cartella Applicazioni" \
            -font Helvetica-Oblique -pointsize 10 -fill "#999999" \
            -gravity south -annotate +0+30 "Copyright © 2023 Rocco Geremia Ciccone" \
            "${BACKGROUND_IMAGE}"
        
        # Verifica la creazione
        if [ -f "${BACKGROUND_IMAGE}" ]; then
            echo "Sfondo creato con successo: ${BACKGROUND_IMAGE}"
            return 0
        fi
    fi
    
    # Fallback con testo semplice se convert non funziona
    echo "ImageMagick non disponibile, creo un'immagine di sfondo semplice..."
    
    # Verifica se abbiamo sips (utility macOS)
    if command -v sips &> /dev/null; then
        # Crea un'immagine vuota
        sips -s format png -s formatOptions 100 \
             --padToHeightWidth ${WINDOW_HEIGHT} ${WINDOW_WIDTH} \
             -s backgroundColor "${BACKGROUND_COLOR}" \
             "${RESOURCES_DIR}/AppIcon.png" \
             --out "${BACKGROUND_IMAGE}" &>/dev/null
        
        echo "Sfondo creato con sips: ${BACKGROUND_IMAGE}"
        return 0
    fi
    
    # Fallback estremo - nessun sfondo
    echo "Impossibile creare un'immagine di sfondo personalizzata."
    return 1
}

# Crea l'immagine di sfondo
create_background_image

# Verifica se volicon esiste (icona del volume)
VOLICON="${RESOURCES_DIR}/AppIcon.icns"
if [ ! -f "${VOLICON}" ]; then
    echo "Icona del volume non trovata, provo alternative..."
    VOLICON="${RESOURCES_DIR}/AppIcon.png"
    
    if [ ! -f "${VOLICON}" ]; then
        echo "Nessuna icona trovata, procedo senza"
        VOLICON=""
    fi
fi

# Opzioni per create-dmg
OPTS=()
OPTS+=("--volname" "${APP_NAME}")
OPTS+=("--window-pos" "200" "120")
OPTS+=("--window-size" "${WINDOW_WIDTH}" "${WINDOW_HEIGHT}")
OPTS+=("--icon-size" "${ICON_SIZE}")
OPTS+=("--icon" "${APP_NAME}.app" "${ICON_POSITION_X}" "${ICON_POSITION_Y}")
OPTS+=("--app-drop-link" "${APPLICATIONS_POSITION_X}" "${APPLICATIONS_POSITION_Y}")
OPTS+=("--no-internet-enable")
OPTS+=("--format" "UDZO")

# Aggiungi volicon se disponibile
if [ -n "${VOLICON}" ]; then
    OPTS+=("--volicon" "${VOLICON}")
fi

# Aggiungi background se disponibile
if [ -f "${BACKGROUND_IMAGE}" ]; then
    OPTS+=("--background" "${BACKGROUND_IMAGE}")
    # Se vogliamo che le icone si posizionino automaticamente
    # OPTS+=("--icon-size" "${ICON_SIZE}")
    OPTS+=("--text-size" "12")
fi

echo "Creazione di un DMG professionale per ${APP_NAME}..."
echo "Opzioni: ${OPTS[@]}"

# Crea il DMG con create-dmg
create-dmg "${OPTS[@]}" "${DMG_PATH}" "${APP_PATH}"

# Verifica il risultato
if [ $? -eq 0 ]; then
    echo "DMG creato con successo: ${DMG_PATH}"
    echo "Verifica DMG..."
    hdiutil verify "${DMG_PATH}"
    
    if [ $? -eq 0 ]; then
        echo "DMG verificato correttamente."
        echo "Puoi distribuire questo file su GitHub."
    else
        echo "Attenzione: Il DMG è stato creato ma non è stato verificato correttamente."
    fi
else
    echo "Errore durante la creazione del DMG. Provo con il metodo semplice..."
    "${SCRIPT_DIR}/create-simple-dmg.sh"
fi
