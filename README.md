# TakeASip

<p align="center">
  <img src="docs/images/icon.png" alt="TakeASip Logo" width="200">
</p>

<p align="center">
  <strong>Un'applicazione minimale per macOS che ti ricorda di bere acqua regolarmente.</strong>
</p>

<p align="center">
  <a href="#caratteristiche">Caratteristiche</a> •
  <a href="#installazione">Installazione</a> •
  <a href="#uso">Uso</a> •
  <a href="#sviluppo">Sviluppo</a> •
  <a href="#licenza">Licenza</a>
</p>

## Caratteristiche

- ☑️ Icona nella barra di stato per accesso rapido
- ☑️ Promemoria ogni 15 minuti con una piacevole animazione
- ☑️ Design minimalista e non intrusivo
- ☑️ Notifiche di sistema
- ☑️ Avvio automatico (opzionale)
- ☑️ Supporta temi chiari e scuri di macOS
- ☑️ Leggero e con basso consumo di memoria
- ☑️ Non richiede connessione internet

## Screenshots

<p align="center">
  <img src="docs/images/screenshot.png" alt="Screenshot" width="600">
</p>

## Installazione

### Download diretto

1. Scarica il file `.dmg` dalla [pagina delle release](https://github.com/tuonome/takeasip/releases)
2. Apri il file `.dmg` e trascina l'app nella cartella Applicazioni
3. Apri l'app dalla cartella Applicazioni
4. (Opzionale) Imposta l'app per avviarsi all'accensione

### Installazione da terminale usando il Makefile

Se hai scaricato il codice sorgente, puoi compilare e installare l'app usando:

```bash
cd takeasip
make install
```

## Uso

### Aggiungere TakeASip agli elementi di login

1. Apri le Preferenze di Sistema
2. Vai su "Utenti e Gruppi"
3. Seleziona la scheda "Elementi login"
4. Clicca sul pulsante "+" e seleziona TakeASip

### Menu

Cliccando sull'icona nella barra di stato avrai accesso a:

- **Bevi ora**: Mostra immediatamente il promemoria
- **Impostazioni**: Configura l'app (funzionalità future)
- **Informazioni**: Mostra informazioni sull'app
- **Esci**: Chiude l'app

## Requisiti di sistema

- macOS 11.0 (Big Sur) o superiore
- Memoria: 10MB
- Spazio su disco: 5MB

## Sviluppo

TakeASip è sviluppato in Swift utilizzando SwiftUI e AppKit. Per eseguire il progetto:

1. Clona il repository
   ```bash
   git clone https://github.com/tuonome/takeasip.git
   cd takeasip
   ```

2. Compila e avvia l'app
   ```bash
   make run
   ```

3. Per creare un file DMG per la distribuzione
   ```bash
   make dmg
   ```

## Roadmap

- [ ] Personalizzazione degli intervalli di tempo
- [ ] Statistiche sul consumo di acqua
- [ ] Temi personalizzati
- [ ] Supporto multilingua
- [ ] Sincronizzazione cross-device

## Contribuire

Le contribuzioni sono benvenute! Leggi [CONTRIBUTING.md](CONTRIBUTING.md) per maggiori dettagli su come contribuire.

## Licenza

Questo progetto è rilasciato sotto licenza MIT. Vedi il file [LICENSE](LICENSE) per i dettagli.

## Crediti

Sviluppato con ♥️ da Rocco Geremia Ciccone.

---

<p align="center">
  Made with ❤️ in Italia
</p>
