#!/bin/bash

# Script per creare un file .dmg per TakeASip

# Versione corrente
VERSION="1.0.0"

# Nome dell'app e del file .dmg
APP_NAME="TakeASip"
DMG_NAME="${APP_NAME}-${VERSION}"

# Percorsi importanti
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BUILD_DIR="${SCRIPT_DIR}/build"
RELEASE_DIR="${SCRIPT_DIR}/release"
APP_PATH="${BUILD_DIR}/${APP_NAME}.app"
DMG_PATH="${RELEASE_DIR}/${DMG_NAME}.dmg"

# Funzione di pulizia
cleanup() {
    echo "Pulizia vecchi file..."
    rm -rf "${BUILD_DIR}"
    rm -rf "${RELEASE_DIR}"
    mkdir -p "${BUILD_DIR}"
    mkdir -p "${RELEASE_DIR}"
}

# Compila l'app
build_app() {
    echo "Compilazione di ${APP_NAME}..."
    
    # Usa xcodebuild se è un progetto Xcode
    if [ -f "${SCRIPT_DIR}/${APP_NAME}.xcodeproj/project.pbxproj" ]; then
        xcodebuild -project "${SCRIPT_DIR}/${APP_NAME}.xcodeproj" -scheme "${APP_NAME}" -configuration Release -derivedDataPath "${BUILD_DIR}" build
        
        # Copia l'app nella directory di build
        cp -R "${BUILD_DIR}/Build/Products/Release/${APP_NAME}.app" "${BUILD_DIR}/"
    else
        # Se è un singolo file Swift, compila direttamente
        swiftc -O -sdk $(xcrun --show-sdk-path --sdk macosx) "${SCRIPT_DIR}/takeasip/${APP_NAME}.swift" -o "${BUILD_DIR}/${APP_NAME}"
        
        # Crea la struttura base dell'app
        mkdir -p "${APP_PATH}/Contents/MacOS"
        mkdir -p "${APP_PATH}/Contents/Resources"
        
        # Copia l'eseguibile
        cp "${BUILD_DIR}/${APP_NAME}" "${APP_PATH}/Contents/MacOS/"
        
        # Crea un basic Info.plist
        cat > "${APP_PATH}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIdentifier</key>
    <string>com.roccociccone.${APP_NAME}</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2023 Rocco Geremia Ciccone. All rights reserved.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF
    fi
    
    echo "Compilazione completata!"
}

# Crea il file DMG
create_dmg() {
    echo "Creazione del file DMG..."
    
    # Verifica se hdiutil è disponibile
    if ! command -v hdiutil &> /dev/null; then
        echo "hdiutil non è disponibile, impossibile creare il DMG."
        exit 1
    fi
    
    # Crea un DMG temporaneo
    TEMP_DMG="${BUILD_DIR}/temp.dmg"
    
    # Crea un volume DMG
    hdiutil create -volname "${APP_NAME}" -srcfolder "${APP_PATH}" -ov -format UDZO "${DMG_PATH}"
    
    echo "File DMG creato in: ${DMG_PATH}"
}

# Funzione principale
main() {
    echo "Inizio creazione del pacchetto per ${APP_NAME} v${VERSION}..."
    
    cleanup
    build_app
    create_dmg
    
    echo "Processo completato con successo!"
}

# Avvia il processo
main
