#!/bin/bash

# Script semplificato per creare un DMG

# Imposta la directory di base
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_DIR="$( cd "${SCRIPT_DIR}/.." && pwd )"

# Variabili
APP_NAME="TakeASip"
VERSION="1.0.0"
BUILD_DIR="${BASE_DIR}/build"
RELEASE_DIR="${BASE_DIR}/release"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
DMG_PATH="${RELEASE_DIR}/${APP_NAME}-${VERSION}.dmg"

echo "Percorsi:"
echo "  Script directory: ${SCRIPT_DIR}"
echo "  Base directory: ${BASE_DIR}"
echo "  Build directory: ${BUILD_DIR}"
echo "  App path: ${APP_PATH}"
echo "  DMG path: ${DMG_PATH}"

# Verifica esistenza app
if [ ! -d "${APP_PATH}" ]; then
    echo "Errore: app non trovata. Compila prima con 'make build'"
    exit 1
fi

# Assicurati che la directory release esista
mkdir -p "${RELEASE_DIR}"

# Rimuovi DMG esistente
if [ -f "${DMG_PATH}" ]; then
    echo "Rimozione DMG esistente..."
    rm -f "${DMG_PATH}"
fi

# Crea DMG
echo "Creazione DMG semplice..."
hdiutil create -volname "${APP_NAME}" -srcfolder "${APP_PATH}" -ov -format UDZO "${DMG_PATH}"

if [ $? -eq 0 ]; then
    echo "DMG creato con successo: ${DMG_PATH}"
else
    echo "Errore nella creazione del DMG"
    exit 1
fi

# Verifica il DMG
echo "Verifica del DMG..."
hdiutil verify "${DMG_PATH}"

if [ $? -eq 0 ]; then
    echo "DMG verificato con successo"
else
    echo "DMG non verificato, potrebbe esserci un problema"
fi
