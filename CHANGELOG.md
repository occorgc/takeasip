# Changelog

Tutte le modifiche significative al progetto saranno documentate in questo file.

Il formato è basato su [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
e questo progetto aderisce al [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2023-05-12

### Aggiunto
- Prima versione stabile dell'applicazione
- Interfaccia utente in inglese
- Menu nella barra di stato con icona a goccia
- Animazione della goccia che cade quando è il momento di bere
- Notifiche di sistema
- Impostazioni per personalizzare l'intervallo di promemoria (5 min, 10 min, 15 min, 30 min, 1 ora)
- Sistema di persistenza delle impostazioni tramite UserDefaults
- Supporto per macOS 10.15+
- Script per la creazione di file DMG per la distribuzione
- Makefile per facilitare la compilazione e il packaging

### Cambiato
- Rinominato da "WaterReminder" a "TakeASip"
- Tradotte tutte le stringhe dall'italiano all'inglese
- Migliorata l'animazione della goccia d'acqua
- Ottimizzato il consumo di memoria

### Corretto
- Risolto problema con le notifiche che non apparivano su alcuni sistemi
- Corretto il posizionamento della finestra di animazione su schermi multipli
