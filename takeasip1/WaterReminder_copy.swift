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
        } else {
            // Aggiorna la vista per ripristinare l'animazione
            if let hostingView = animationWindow?.contentView as? NSHostingView<WaterDropView> {
                let newContentView = WaterDropView()
                hostingView.rootView = newContentView
            }
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
            
            // Chiudi la finestra dopo 5 secondi
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.animationWindow?.orderOut(nil)
            }
        }
    }
}

struct WaterDropView: View {
    @State private var dropPosition: CGFloat = -30 // Inizialmente fuori dallo schermo (sopra)
    @State private var splashScale: CGFloat = 0.0
    @State private var rippleScale: CGFloat = 0.0
    @State private var rippleOpacity: Double = 0.8
    @State private var showText: Bool = false
    @State private var puddleOpacity: Double = 1.0
    @State private var puddleScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.clear
            
            ZStack {
                // Elementi animati
                ZStack {
                    // Pozzanghera
                    Ellipse()
                        .fill(Color.blue.opacity(0.4 * puddleOpacity))
                        .frame(width: 80, height: 30)
                        .offset(y: 30)
                        .scaleEffect(puddleScale)
                    
                    // Effetto ripple/onda
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(Color.blue.opacity((rippleOpacity / Double(i+1)) * puddleOpacity), lineWidth: 2)
                            .frame(width: 40 + CGFloat(i*15))
                            .scaleEffect(rippleScale)
                            .offset(y: 30)
                    }
                    
                    // Effetto splash
                    ZStack {
                        // Splash a sinistra
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addQuadCurve(
                                to: CGPoint(x: -15, y: -20),
                                control: CGPoint(x: -5, y: -5)
                            )
                        }
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .scaleEffect(splashScale)
                        .opacity(puddleOpacity)
                        .offset(x: -10, y: 20)
                        
                        // Splash a destra
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addQuadCurve(
                                to: CGPoint(x: 15, y: -20),
                                control: CGPoint(x: 5, y: -5)
                            )
                        }
                        .stroke(Color.blue, lineWidth: 2)
                        .frame(width: 20, height: 20)
                        .scaleEffect(splashScale)
                        .opacity(puddleOpacity)
                        .offset(x: 10, y: 20)
                    }
                    
                    // Goccia che cade
                    Image(systemName: "drop.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                        .offset(y: dropPosition)
                        .opacity(dropPosition > 25 ? 0 : 1) // Scompare quando tocca la pozzanghera
                }
                
                // Testo al centro
                Text("take a sip!")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .opacity(showText ? 1 : 0)
                    .offset(y: showText ? 0 : 40) // Si sposta al centro quando appare
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .opacity(0.5)
            )
            .onAppear {
                // Resetta lo stato per assicurare che l'animazione riparta
                reset()
                
                // Avvia la sequenza di animazione
                startAnimation()
            }
        }
    }
    
    private func reset() {
        // Ripristina tutti i valori iniziali
        dropPosition = -30
        splashScale = 0.0
        rippleScale = 0.0
        rippleOpacity = 0.8
        showText = false
        puddleOpacity = 1.0
        puddleScale = 1.0
    }
    
    private func startAnimation() {
        // Sequenza di animazione
        withAnimation(Animation.easeIn(duration: 0.7).delay(0.3)) {
            // Animazione 1: La goccia cade
            dropPosition = 30
        }
        
        // Quando la goccia tocca la superficie
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Animazione 2: Splash
            withAnimation(Animation.easeOut(duration: 0.3)) {
                splashScale = 1.0
            }
            
            // Animazione 3: Ripple/onda
            withAnimation(Animation.easeOut(duration: 1.2)) {
                rippleScale = 1.0
                rippleOpacity = 0.0
            }
            
            // Animazione 4: Fade out della pozzanghera
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(Animation.easeOut(duration: 0.7)) {
                    puddleOpacity = 0.0
                    puddleScale = 0.7
                }
                
                // Animazione 5: Mostra il testo al centro
                withAnimation(Animation.easeIn(duration: 0.5).delay(0.3)) {
                    showText = true
                }
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
