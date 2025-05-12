# Makefile per TakeASip

# Variabili
APP_NAME = TakeASip
VERSION = 1.0.0
SRC_FILE = takeasip/TakeASip.swift
RESOURCES_DIR = takeasip/Resources
BUILD_DIR = build
RELEASE_DIR = release
DMG_NAME = $(APP_NAME)-$(VERSION)

# Percorsi
APP_PATH = $(BUILD_DIR)/$(APP_NAME).app
DMG_PATH = $(RELEASE_DIR)/$(DMG_NAME).dmg

# Default target
all: build

# Pulizia
clean:
	@echo "Pulizia..."
	@rm -rf $(BUILD_DIR)
	@rm -rf $(RELEASE_DIR)
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(RELEASE_DIR)

# Compila app
build: clean
	@echo "Compilazione di $(APP_NAME)..."
	@mkdir -p $(APP_PATH)/Contents/MacOS
	@mkdir -p $(APP_PATH)/Contents/Resources
	@swiftc -O -sdk $$(xcrun --show-sdk-path --sdk macosx) $(SRC_FILE) -o $(APP_PATH)/Contents/MacOS/$(APP_NAME)
	@cp -f takeasip/Resources/Info.plist $(APP_PATH)/Contents/ 2>/dev/null || :
	@cp -R takeasip/Resources/* $(APP_PATH)/Contents/Resources/ 2>/dev/null || :
	@echo "Compilazione completata!"

# Crea DMG
dmg: build
	@echo "Creazione del file DMG..."
	@hdiutil create -volname "$(APP_NAME)" -srcfolder "$(APP_PATH)" -ov -format UDZO "$(DMG_PATH)"
	@echo "File DMG creato: $(DMG_PATH)"

# Installa app localmente
install: build
	@echo "Installazione di $(APP_NAME)..."
	@cp -R $(APP_PATH) /Applications/
	@echo "$(APP_NAME) installato in /Applications/"

# Target per sviluppo rapido, ricompila e avvia
run: build
	@echo "Avvio di $(APP_NAME)..."
	@open $(APP_PATH)

# Help
help:
	@echo "Targets disponibili:"
	@echo "  all: Compilazione dell app"
	@echo "  clean: Pulizia dei file generati"
	@echo "  build: Compilazione dell app"
	@echo "  dmg: Crea un file DMG per la distribuzione"
	@echo "  install: Installa l app in /Applications"
	@echo "  run: Compila e avvia l app"
	@echo "  help: Mostra questo messaggio di aiuto"

.PHONY: all clean build dmg install run help
