// TakeASip - A Simple Water Reminder
// Created by Rocco Geremia Ciccone
// Copyright © 2023. All rights reserved.

import SwiftUI
import Cocoa
import UserNotifications

// MARK: - AppDelegate
class AppDelegate: NSObject, NSApplicationDelegate {
    // MARK: - Properties
    private var statusItem: NSStatusItem?
    private var animationWindow: NSWindow?
    private var timer: Timer?
    private let reminderInterval: TimeInterval = 900 // 15 minutes
    private let reminderTolerance: TimeInterval = 60 // 1 minute tolerance
    
    // MARK: - Lifecycle
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        requestNotificationPermission()
        setupStatusItem()
        startTimer()
        print("TakeASip started successfully")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        animationWindow?.orderOut(nil)
        animationWindow = nil
        print("TakeASip terminating")
    }
    
    // MARK: - Setup
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        guard let button = statusItem?.button else {
            print("Errore: Impossibile creare l'icona nella barra di stato.")
            NSApp.terminate(nil)
            return
        }
            
        button.image = NSImage(systemSymbolName: "drop.fill", accessibilityDescription: "TakeASip")
        button.toolTip = "TakeASip - Promemoria per bere acqua"
            
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Bevi ora", action: #selector(showReminderNow), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Impostazioni", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Informazioni", action: #selector(showAbout), keyEquivalent: "i"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Esci", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem?.menu = menu
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: reminderInterval, repeats: true) { [weak self] _ in
            self?.showReminder()
        }
        timer?.tolerance = reminderTolerance
        print("Timer avviato (intervallo di 15 minuti).")
    }
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Errore durante la richiesta di permessi per le notifiche: \(error)")
            } else {
                print("Permesso per le notifiche: \(granted ? "concesso" : "negato")")
            }
        }
    }

    // MARK: - Actions
    @objc private func openSettings() {
        let alert = NSAlert()
        alert.messageText = "Impostazioni"
        alert.informativeText = "Qui potrai personalizzare l'intervallo dei promemoria e l'animazione."
        alert.addButton(withTitle: "OK")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "TakeASip"
        alert.informativeText = "Un semplice promemoria per bere acqua.\nCreato da Rocco Geremia Ciccone.\nVersione 1.0"
        alert.addButton(withTitle: "OK")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    @objc private func showReminderNow() {
        print("Visualizzazione manuale del promemoria.")
        showReminder()
    }
    
    // MARK: - Show Reminder
    private func showReminder() {
        print("Visualizzazione del promemoria.")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Invia anche una notifica del sistema
            self.sendNotification()

            let windowWidth: CGFloat = 180
            let windowHeight: CGFloat = 150

            // Creiamo la finestra solo se non esiste ancora
            if self.animationWindow == nil {
                print("Creazione della finestra di animazione.")
                let window = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
                    styleMask: [.borderless],
                    backing: .buffered,
                    defer: false
                )
                window.level = .floating
                window.backgroundColor = .clear
                window.isOpaque = false
                window.hasShadow = true
                window.isMovableByWindowBackground = false
                self.animationWindow = window
            }

            // Crea una nuova istanza della vista SwiftUI
            let newContentView = WaterDropView()
            
            // Crea una nuova hosting view per la nuova vista
            let newHostingView = NSHostingView(rootView: newContentView)
            newHostingView.frame = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
            
            // Imposta la nuova hosting view come contenuto della finestra
            self.animationWindow?.contentView = newHostingView

            // Posiziona e mostra la finestra
            if let screen = NSScreen.main, let window = self.animationWindow {
                let screenRect = screen.visibleFrame
                let origin = CGPoint(
                    x: screenRect.maxX - windowWidth - 20,
                    y: screenRect.maxY - windowHeight - 20
                )

                window.setFrameOrigin(origin)
                window.orderFront(nil)

                // Nascondi automaticamente la finestra dopo un ritardo
                let hideDelay: TimeInterval = 5.0
                DispatchQueue.main.asyncAfter(deadline: .now() + hideDelay) { [weak window] in
                    window?.orderOut(nil)
                }
            } else {
                print("Errore: Impossibile ottenere lo schermo principale o l'istanza della finestra.")
            }
        }
    }
    
    private func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "TakeASip"
        content.body = "È ora di bere un po' d'acqua!"
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Errore nell'invio della notifica: \(error)")
            }
        }
    }
}

// MARK: - SwiftUI View (WaterDropView)
struct WaterDropView: View {
    // MARK: - Proprietà di stato per l'animazione
    @State private var dropPosition: CGFloat = -50
    @State private var splashScale: CGFloat = 0.0
    @State private var rippleScale: CGFloat = 0.0
    @State private var rippleOpacity: Double = 0.8
    @State private var showText: Bool = false
    @State private var puddleOpacity: Double = 0.0
    @State private var puddleScale: CGFloat = 0.8

    // MARK: - Costanti di stile
    let dropColor = Color(red: 0.0, green: 0.5, blue: 0.9) // Blu più intenso
    let backgroundColor = Color(NSColor.windowBackgroundColor).opacity(0.85)
    let textColor = Color(NSColor.labelColor)

    var body: some View {
        ZStack {
            // Sfondo arrotondato
            RoundedRectangle(cornerRadius: 15)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)

            ZStack {
                // Pozzanghera e onde
                ZStack {
                    // Base della pozzanghera
                    Ellipse()
                        .fill(dropColor.opacity(0.4 * puddleOpacity))
                        .frame(width: 80, height: 30)
                        .scaleEffect(puddleScale)

                    // Onde circolari
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(dropColor.opacity(max(0, (rippleOpacity / Double(i+1)) * puddleOpacity)), lineWidth: 1.5)
                            .frame(width: 40 + CGFloat(i*20))
                            .scaleEffect(rippleScale)
                    }
                }
                .offset(y: 30)

                // Schizzi d'acqua
                ZStack {
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(dropColor)
                            .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 4...8))
                            .offset(x: CGFloat.random(in: -15...15), y: CGFloat.random(in: -10...0))
                            .scaleEffect(splashScale)
                            .opacity(puddleOpacity > 0.5 ? 1 : 0)
                     }
                }
                .offset(y: 25)
                .opacity(splashScale > 0 ? 1 : 0)

                // Goccia che cade
                Image(systemName: "drop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(dropColor)
                    .offset(y: dropPosition)
                    .opacity(dropPosition > 25 ? 0 : 1)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)

                // Testo del promemoria
                Text("take a sip!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(textColor)
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 20)
                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
            }
        }
        .frame(width: 180, height: 150)
        .onAppear(perform: startAnimation)
    }

    // MARK: - Funzioni di animazione
    private func reset() {
        // Reset di tutte le proprietà di stato per iniziare l'animazione da zero
        dropPosition = -50
        splashScale = 0.0
        rippleScale = 0.0
        rippleOpacity = 0.8
        showText = false
        puddleOpacity = 0.0
        puddleScale = 0.8
    }

    private func startAnimation() {
        reset()
        
        // Sequenza di animazione: goccia che cade
        withAnimation(.easeIn(duration: 0.6).delay(0.2)) {
            dropPosition = 30
            puddleOpacity = 1.0
            puddleScale = 1.0
        }

        // Schizzi e onde
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5).speed(1.5)) {
                splashScale = 1.0
            }
            withAnimation(.easeOut(duration: 1.0)) {
                rippleScale = 1.2
                rippleOpacity = 0.0
            }

            // Fade degli schizzi
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.3)) {
                    splashScale = 0.0
                }
            }
        }

        // Mostra testo
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.5)) {
                showText = true
            }
        }

        // Fade della pozzanghera
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.8)) {
                puddleOpacity = 0.0
                puddleScale = 0.6
            }
        }
    }
}

// MARK: - Application Entry Point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)