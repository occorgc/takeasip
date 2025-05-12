# TakeASip 💧

TakeASip è una semplice applicazione per macOS che ti ricorda di bere acqua durante la giornata, mostrando notifiche e un'elegante animazione di una goccia d'acqua.

![TakeASip Screenshot](docs/images/screenshot.png)

## Caratteristiche

- ⏰ Timer personalizzabile (5 min, 10 min, 15 min, 30 min, 1 ora)
- �� Animazione elegante con una goccia d'acqua che cade
- 🔔 Notifiche del sistema
- 🖥️ Si integra nella barra di stato di macOS
- 🚀 Leggero e non invasivo

## Requisiti

- macOS 10.15 (Catalina) o superiore
- Almeno 10MB di spazio su disco

## Installazione

### Metodo 1: Installer DMG

1. Scarica il file DMG dalla [pagina Releases](https://github.com/occorgc/takeasip/releases)
2. Apri il file DMG
3. Trascina l'app TakeASip nella cartella Applicazioni
4. Apri l'app dalla cartella Applicazioni

### Metodo 2: Compilazione da sorgente

```bash
# Clona il repository
git clone https://github.com/occorgc/takeasip.git
cd takeasip

# Compila l'app
make build

# (Opzionale) Installa l'app
make install

# (Opzionale) Crea un file DMG
make dmg
```

## Utilizzo

1. Apri l'app TakeASip
2. Un'icona a forma di goccia apparirà nella barra di stato
3. Fai clic sull'icona per accedere al menu
4. Da qui puoi:
   - Mostrare un promemoria immediato ("Drink Now")
   - Modificare le impostazioni del timer ("Settings")
   - Visualizzare informazioni sull'app ("About")
   - Chiudere l'app ("Quit")

## Personalizzazione

Puoi personalizzare l'intervallo di tempo tra le notifiche nelle Impostazioni, scegliendo tra:
- 5 minuti
- 10 minuti
- 15 minuti (predefinito)
- 30 minuti
- 1 ora

## Sviluppo

Questo progetto è scritto in Swift e utilizza il framework AppKit/SwiftUI per l'interfaccia utente.

### Struttura del progetto

```
takeasip/
├── scripts/            # Script di utilità per il build e il packaging
├── takeasip/           # Codice sorgente dell'applicazione
│   ├── TakeASip.swift  # File sorgente principale
│   └── Resources/      # Risorse (icone, file plist, ecc.)
├── Makefile            # Comandi per compilare e distribuire l'app
└── docs/               # Documentazione
```

## Licenza

Questo progetto è rilasciato sotto la licenza MIT. Vedi il file [LICENSE](LICENSE) per i dettagli.

## Contatti

Creato da occorgc - [GitHub](https://github.com/occorgc)

---

*Mantieniti idratato! 💧*
