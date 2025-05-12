#!/bin/bash

# Script per verificare e installare le dipendenze necessarie
# per la creazione del pacchetto TakeASip

echo "Verifica delle dipendenze per TakeASip..."

# Lista delle dipendenze
DEPS=("create-dmg" "convert" "sips")

# Variabili per i comandi di installazione
BREW_CMD="brew"
NPM_CMD="npm"

# Verifica se Homebrew è installato
check_homebrew() {
    if ! command -v ${BREW_CMD} &>/dev/null; then
        echo "Homebrew non trovato. Per installarlo, visita https://brew.sh"
        echo "oppure esegui:"
        echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        return 1
    fi
    return 0
}

# Verifica se npm è installato
check_npm() {
    if ! command -v ${NPM_CMD} &>/dev/null; then
        echo "npm non trovato. Per installarlo, installa Node.js da https://nodejs.org"
        return 1
    fi
    return 0
}

# Installa create-dmg
install_create_dmg() {
    echo "Tentativo di installazione di create-dmg..."
    
    if check_homebrew; then
        echo "Installazione di create-dmg tramite Homebrew..."
        ${BREW_CMD} install create-dmg
        return $?
    elif check_npm; then
        echo "Installazione di create-dmg tramite npm..."
        ${NPM_CMD} install -g create-dmg
        return $?
    else
        echo "Non è possibile installare create-dmg. Verifica di avere Homebrew o npm."
        return 1
    fi
}

# Installa imagemagick (per il comando convert)
install_imagemagick() {
    echo "Tentativo di installazione di ImageMagick (per convert)..."
    
    if check_homebrew; then
        echo "Installazione di ImageMagick tramite Homebrew..."
        ${BREW_CMD} install imagemagick
        return $?
    else
        echo "Non è possibile installare ImageMagick. Verifica di avere Homebrew."
        return 1
    fi
}

# Verifica e installa le dipendenze
for dep in "${DEPS[@]}"; do
    echo -n "Verifica di ${dep}... "
    
    if command -v ${dep} &>/dev/null; then
        echo "OK"
    else
        echo "MANCANTE"
        
        case "${dep}" in
            "create-dmg")
                install_create_dmg
                ;;
            "convert")
                install_imagemagick
                ;;
            "sips")
                echo "sips dovrebbe essere già presente in macOS. Se non lo è, potrebbe essere un problema con la tua installazione."
                ;;
            *)
                echo "Nessun metodo di installazione disponibile per ${dep}"
                ;;
        esac
    fi
done

echo "Verifica delle dipendenze completata!"
