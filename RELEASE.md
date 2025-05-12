# Guida al Rilascio di TakeASip

Questo documento descrive il processo per creare e rilasciare una nuova versione di TakeASip.

## Preparazione al Rilascio

1. Aggiorna il numero di versione nel file `takeasip/Resources/Info.plist`
2. Aggiorna il `CHANGELOG.md` con le modifiche della nuova versione
3. Assicurati che tutti i test siano passati
4. Verifica che l'app funzioni correttamente sul tuo sistema

## Compilazione e Creazione del DMG

```bash
# Compila l'app
make build

# Crea il DMG standard
make dmg
# oppure
# Crea il DMG con layout personalizzato
./scripts/create-fancy-dmg.sh
```

Il file DMG sarà creato nella directory `release/`.

## Rilascio su GitHub

1. Vai alla pagina del tuo repository su GitHub
2. Clicca su "Releases" nella barra laterale
3. Clicca su "Draft a new release"
4. Inserisci il tag della versione (es. `v1.0.0`)
5. Inserisci un titolo per il rilascio (es. "TakeASip 1.0.0")
6. Copia le note di rilascio dal `CHANGELOG.md`
7. Trascina e rilascia il file DMG nell'area "Attach binaries..."
8. Clicca su "Publish release"

## Post-Rilascio

1. Annuncia il rilascio sui canali appropriati
2. Monitora i feedback degli utenti
3. Correggi eventuali bug segnalati dagli utenti

---

*Nota: Ogni volta che rilasci una nuova versione, ricordati di incrementare il numero di versione nel file Info.plist.*
