#!/bin/zsh

# Script di installazione per TakeASip

APP_NAME="TakeASip"
APP_BUNDLE="${APP_NAME}.app"
APP_PATH="/Applications/${APP_BUNDLE}"

# Colori per output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

# Funzione per mostrare messaggi
print_message() {
    echo "${BLUE}==>${RESET} $1"
}

print_success() {
    echo "${GREEN}✓${RESET} $1"
}

print_warning() {
    echo "${YELLOW}!${RESET} $1"
}

print_error() {
    echo "${RED}✗${RESET} $1"
}

# Funzione per verificare se l'app è già installata
check_installation() {
    if [[ -d "$APP_PATH" ]]; then
        print_warning "TakeASip è già installato in /Applications."
        read -q "REPLY?Vuoi reinstallare? (y/n) "
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_message "Installazione annullata."
            exit 0
        fi
    fi
}

# Funzione per installare l'app
install_app() {
    print_message "Installazione di TakeASip..."
    
    # Rimuovi versione precedente se esiste
    if [[ -d "$APP_PATH" ]]; then
        print_message "Rimozione della versione precedente..."
        rm -rf "$APP_PATH"
    fi
    
    # Copia l'app in /Applications
    if [[ -d "$APP_BUNDLE" ]]; then
        cp -R "$APP_BUNDLE" /Applications/
        print_success "TakeASip è stato installato in /Applications."
    else
        print_error "Impossibile trovare $APP_BUNDLE nella directory corrente."
        exit 1
    fi
}

# Funzione per aggiungere l'app ai login items
add_to_login_items() {
    print_message "Aggiungere TakeASip agli elementi di login? (si avvierà automaticamente all'accensione)"
    read -q "REPLY?Aggiungere agli elementi di login? (y/n) "
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        osascript -e "tell application \"System Events\" to make login item at end with properties {path:\"$APP_PATH\", hidden:false}"
        print_success "TakeASip è stato aggiunto agli elementi di login."
    else
        print_message "TakeASip non verrà avviato automaticamente all'accensione."
    fi
}

# Funzione per avviare l'app
launch_app() {
    print_message "Avviare TakeASip adesso?"
    read -q "REPLY?Avviare ora? (y/n) "
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        open "$APP_PATH"
        print_success "TakeASip è stato avviato."
    else
        print_message "Puoi avviare TakeASip manualmente in qualsiasi momento dalla cartella Applicazioni."
    fi
}

# Funzione principale
main() {
    echo "🚀 ${BLUE}Installazione di TakeASip${RESET} 🚀"
    echo "-----------------------------"
    
    check_installation
    install_app
    add_to_login_items
    launch_app
    
    echo "-----------------------------"
    echo "${GREEN}Installazione completata!${RESET}"
    echo "Per supporto: https://github.com/tuonome/takeasip"
}

# Esegui la funzione principale
main
