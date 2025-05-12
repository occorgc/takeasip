import SwiftUI
import Cocoa

@main
struct WaterReminderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var animationWindow: NSWindow?
    var timer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Crea l'icona nella barra menu per accesso all'app
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "drop.fill", accessibilityDescription: "Water")
            
            // Crea il menu contestuale
            let menu = NSMenu()
            
            menu.addItem(NSMenuItem(title: "Mostra Promemoria", action: #selector(showReminderNow), keyEquivalent: "m"))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Impostazioni", action: #selector(openSettings), keyEquivalent: ","))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Esci", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            
            statusItem?.menu = menu
        }
        
        // Configura il timer per mostrare il promemoria ogni 15 minuti
        startTimer()
    }
    
    func startTimer() {
        // Intervallo di 15 minuti (900 secondi)
        timer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            self?.showReminder()
        }
    }
    
    @objc func showReminderNow() {
        showReminder()
    }
    
    @objc func openSettings() {
        // Semplice finestra impostazioni (da implementare in futuro)
        let alert = NSAlert()
        alert.messageText = "Impostazioni"
        alert.informativeText = "In futuro qui ci saranno le impostazioni per personalizzare il timer e l'animazione."
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func showReminder() {
        // Crea una finestra senza bordi nell'angolo in alto a destra
        if animationWindow == nil {
            let contentView = WaterDropView()
            let hostingView = NSHostingView(rootView: contentView)
            
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 150, height: 150),
                styleMask: [.borderless],
                backing: .buffered,
                defer: false
            )
            
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.level = .floating
            window.contentView = hostingView
            
            animationWindow = window
        }
        
        if let screen = NSScreen.main {
            // Posiziona la finestra nell'angolo in alto a destra
            let screenRect = screen.visibleFrame
            let windowSize = CGSize(width: 150, height: 150)
            let origin = CGPoint(
                x: screenRect.maxX - windowSize.width - 10,
                y: screenRect.maxY - windowSize.height - 10
            )
            
            animationWindow?.setFrameOrigin(origin)
            animationWindow?.orderFront(nil)
            
            // Chiudi la finestra dopo 3 secondi
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.animationWindow?.orderOut(nil)
            }
        }
    }
}
