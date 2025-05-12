# Istruzioni di Installazione - TakeASip

Questo documento contiene istruzioni dettagliate per installare, aggiornare e disinstallare TakeASip.

## Installazione Standard

### Tramite file DMG
1. Scarica il file `.dmg` dalla [pagina delle release](https://github.com/tuonome/takeasip/releases)
2. Fai doppio clic sul file `.dmg` per montarlo
3. Trascina l'app `TakeASip` nella cartella Applicazioni
4. Espelli il volume DMG
5. Apri l'app dalla cartella Applicazioni

### Tramite Makefile (da sorgente)
1. Clona il repository o scarica il codice sorgente
   ```bash
   git clone https://github.com/tuonome/takeasip.git
   cd takeasip
   ```
2. Verifica le dipendenze
   ```bash
   make deps
   ```
3. Compila e installa
   ```bash
   make install
   ```
4. Per avviare l'app
   ```bash
   make run
   ```
5. Per creare un file DMG
   ```bash
   make dmg
   ```

### Tramite script di installazione
1. Scarica i file sorgente
2. Apri il terminale nella cartella del progetto
3. Esegui lo script di installazione
   ```bash
   ./install.sh
   ```
4. Segui le istruzioni a schermo

## Configurazione All'avvio Automatico

### Tramite Preferenze di Sistema
1. Apri Preferenze di Sistema
2. Vai su "Utenti e Gruppi"
3. Seleziona la scheda "Elementi login"
4. Clicca sul pulsante "+" in basso a sinistra
5. Vai nella cartella `/Applications`
6. Seleziona `TakeASip.app`
7. Clicca su "Aggiungi"

### Tramite launchd (avanzato)
1. Copia il file `com.roccociccone.TakeASip.plist` nella cartella `~/Library/LaunchAgents/`
   ```bash
   cp docs/com.roccociccone.TakeASip.plist ~/Library/LaunchAgents/
   ```
2. Carica il file con launchctl
   ```bash
   launchctl load ~/Library/LaunchAgents/com.roccociccone.TakeASip.plist
   ```

## Aggiornamento

### Aggiornamento Manuale
1. Esci da TakeASip se è in esecuzione
2. Scarica la nuova versione
3. Sostituisci la versione precedente in `/Applications`

### Aggiornamento Automatico
TakeASip attualmente non dispone di aggiornamenti automatici. Controlla periodicamente la pagina delle release su GitHub per nuove versioni.

## Disinstallazione

### Disinstallazione Standard
1. Apri il Finder
2. Vai alla cartella Applicazioni
3. Trascina `TakeASip.app` nel Cestino
4. Svuota il Cestino

### Pulizia Completa
Per rimuovere anche le preferenze e i file temporanei:

```bash
rm -rf ~/Library/Preferences/com.roccociccone.TakeASip.plist
rm -rf ~/Library/Caches/com.roccociccone.TakeASip
rm -rf ~/Library/Application\ Support/TakeASip
```

Se hai configurato l'avvio automatico con launchd:
```bash
launchctl unload ~/Library/LaunchAgents/com.roccociccone.TakeASip.plist
rm ~/Library/LaunchAgents/com.roccociccone.TakeASip.plist
```

## Risoluzione dei Problemi di Installazione

### "App danneggiata" su macOS
Se vedi un messaggio che indica che l'app è danneggiata:

1. Apri Preferenze di Sistema
2. Vai su "Sicurezza e Privacy"
3. Nella scheda "Generale", clicca su "Apri comunque"
4. Segui le istruzioni a schermo

### Problemi di permessi
Se ricevi errori relativi ai permessi:

```bash
chmod +x /Applications/TakeASip.app/Contents/MacOS/TakeASip
```

### App non si avvia
Prova a eseguirla da terminale per vedere eventuali errori:

```bash
/Applications/TakeASip.app/Contents/MacOS/TakeASip
```
