#!/bin/zsh

# Script per inizializzare il repository Git

# Colori per output
GREEN="\033[0;32m"
BLUE="\033[0;34m"
RESET="\033[0m"

echo "${BLUE}Inizializzazione del repository Git per TakeASip${RESET}"

# Inizializza Git se non è già inizializzato
if [ ! -d ".git" ]; then
    git init
    echo "${GREEN}Repository Git inizializzato${RESET}"
else
    echo "Repository Git già inizializzato"
fi

# Aggiungi i file
git add .

# Esegui il primo commit
git commit -m "Commit iniziale per TakeASip"

echo "${GREEN}Repository Git inizializzato con successo!${RESET}"
echo ""
echo "Per connettere il repository a GitHub:"
echo "1. Crea un nuovo repository su GitHub"
echo "2. Esegui i seguenti comandi:"
echo "   git remote add origin https://github.com/tuonome/takeasip.git"
echo "   git push -u origin master"
