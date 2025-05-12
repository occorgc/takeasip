import SwiftUI
import Cocoa

// Rimuoviamo @main e usiamo un punto di ingresso esplicito
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.animationWindow?.orderOut(nil)
            }
        }
    }
}

struct WaterDropView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.clear
            
            VStack {
                ZStack {
                    // Cerchi pulsanti
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                            .scaleEffect(isAnimating ? 1 + Double(index) * 0.4 : 0.2)
                            .opacity(isAnimating ? 0.0 : 0.8)
                            .animation(
                                Animation.easeOut(duration: 2)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.5),
                                value: isAnimating
                            )
                    }
                    
                    // Cerchio centrale fisso
                    Circle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 50, height: 50)
                    
                    // Icona centrale
                    Image(systemName: "drop.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                }
                .frame(width: 100, height: 100)
                
                Text("take a sip!")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .padding(.top, 5)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .opacity(0.5)
            )
            .onAppear {
                isAnimating = true
            }
        }
    }
}

// Forma d'onda personalizzata
struct WaveShape: Shape {
    var offset: Double
    var waveHeight: CGFloat
    
    var animatableData: Double {
        get { offset }
        set { offset = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height * 0.6
        
        path.move(to: CGPoint(x: 0, y: midHeight))
        
        // Disegna la forma d'onda
        for x in stride(from: 0, to: width, by: 1) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 4 + offset * .pi * 2)
            let y = midHeight + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        // Completa il percorso
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

// Punto di ingresso esplicito
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
