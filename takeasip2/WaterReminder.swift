import SwiftUI
import Cocoa

// AppDelegate handles the application lifecycle and logic
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var animationWindow: NSWindow?
    var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // --- Make the app a background agent (no Dock icon) ---
        // This MUST be done early, before the status item might activate the app
        NSApp.setActivationPolicy(.accessory)
        // -----------------------------------------------------

        // Create the icon in the menu bar
        setupStatusItem()

        // Configure and start the timer
        startTimer()

        print("Water Reminder App Started (with custom pop-up)")
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Clean up timer when the app quits
        timer?.invalidate()
        print("Water Reminder App Terminating")
    }


    // MARK: - Setup

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength) // Use squareLength for better consistency

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "drop.fill", accessibilityDescription: "Water Reminder")
            button.toolTip = "Water Reminder" // Add a tooltip

            // Create the context menu
            let menu = NSMenu()

            menu.addItem(NSMenuItem(title: "Show Reminder Now", action: #selector(showReminderNow), keyEquivalent: "r")) // Changed key equivalent
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ","))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit Water Reminder", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")) // Clearer title

            statusItem?.menu = menu
        } else {
             print("Error: Could not create status bar item.")
             // Consider quitting if the status item is essential and fails
             NSApp.terminate(nil)
        }
    }

    func startTimer() {
        // Invalidate existing timer before starting a new one
        timer?.invalidate()

        // Interval of 15 minutes (900 seconds)
        // Use tolerance for better battery performance
        timer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            self?.showReminder()
        }
        timer?.tolerance = 60 // Allow system some flexibility
        print("Reminder timer started (15 min interval).")

        // Optional: Show reminder once on launch?
        // showReminder()
    }

    // MARK: - Actions

    @objc func showReminderNow() {
        print("Manually triggering reminder window.")
        showReminder()
    }

    @objc func openSettings() {
        // Simple settings placeholder alert
        let alert = NSAlert()
        alert.messageText = "Settings"
        alert.informativeText = "Here you will eventually be able to customize the timer interval and perhaps the animation."
        alert.addButton(withTitle: "OK")
        // Make sure the alert window can appear even if the app is accessory
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    func showReminder() {
        print("Showing reminder window.")
        // Ensure UI updates happen on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let windowWidth: CGFloat = 180 // Slightly wider to better fit text
            let windowHeight: CGFloat = 150

            // Create the custom window if it doesn't exist
            if self.animationWindow == nil {
                let contentView = WaterDropView() // Your custom SwiftUI view
                let hostingView = NSHostingView(rootView: contentView)
                hostingView.frame = NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight) // Set frame on hosting view

                let window = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
                    styleMask: [.borderless], // No title bar, borderless
                    backing: .buffered,
                    defer: false
                )

                window.level = .floating // Keep window on top
                window.backgroundColor = .clear // Transparent background
                window.isOpaque = false
                window.hasShadow = true // Add a subtle shadow for depth
                window.contentView = hostingView
                // window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary] // Behave well with spaces/fullscreen
                window.isMovableByWindowBackground = false // Prevent dragging

                self.animationWindow = window
                print("Created animation window.")

            } else {
                // If window exists, just update the SwiftUI view to reset the animation state
                if let hostingView = self.animationWindow?.contentView as? NSHostingView<WaterDropView> {
                    // Create a *new* instance of the view to trigger .onAppear and reset state
                    let newContentView = WaterDropView()
                    hostingView.rootView = newContentView
                    print("Reset animation in existing window.")
                } else {
                    print("Warning: Could not find hosting view to reset animation.")
                    // Fallback: Force close and recreate (less efficient)
                    self.animationWindow?.orderOut(nil)
                    self.animationWindow = nil
                    self.showReminder() // Recurse to recreate
                    return
                }
            }

            // Calculate position and show the window
            if let screen = NSScreen.main {
                let screenRect = screen.visibleFrame // Area excluding Dock and Menu Bar
                let origin = CGPoint(
                    x: screenRect.maxX - windowWidth - 20, // Position from top-right corner
                    y: screenRect.maxY - windowHeight - 20
                )

                self.animationWindow?.setFrameOrigin(origin)
                self.animationWindow?.orderFront(nil) // Bring window to front

                // Automatically hide the window after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                    // Check if the window still exists before trying to hide it
                    if self?.animationWindow?.isVisible ?? false {
                         self?.animationWindow?.orderOut(nil) // Hide the window
                         print("Hid animation window after timeout.")
                    }
                }
            } else {
                 print("Error: Could not get main screen information.")
            }
        } // End DispatchQueue.main.async
    }
}

// MARK: - SwiftUI View (Your Custom Animation)

struct WaterDropView: View {
    @State private var dropPosition: CGFloat = -50 // Start further above
    @State private var splashScale: CGFloat = 0.0
    @State private var rippleScale: CGFloat = 0.0
    @State private var rippleOpacity: Double = 0.8
    @State private var showText: Bool = false
    @State private var puddleOpacity: Double = 0.0 // Start invisible
    @State private var puddleScale: CGFloat = 0.8 // Start smaller

    // Define colors
    let dropColor = Color.blue
    let backgroundColor = Color(NSColor.windowBackgroundColor).opacity(0.85) // Slightly more opaque background
    let textColor = Color(NSColor.labelColor) // Adapts to light/dark mode

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 15)
                .fill(backgroundColor)
                // .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2) // Optional shadow on the background itself

            // Animation Elements
            ZStack {
                // --- Puddle and Ripple ---
                ZStack {
                    // Puddle Base
                    Ellipse()
                        .fill(dropColor.opacity(0.4 * puddleOpacity))
                        .frame(width: 80, height: 30)
                        .scaleEffect(puddleScale)

                    // Ripples
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(dropColor.opacity(max(0, (rippleOpacity / Double(i+1)) * puddleOpacity)), lineWidth: 1.5) // Ensure opacity >= 0
                            .frame(width: 40 + CGFloat(i*20)) // Slightly larger ripples
                            .scaleEffect(rippleScale)
                    }
                }
                .offset(y: 30) // Position the puddle area lower

                // --- Splash ---
                // Shown briefly when the drop hits
                 ZStack {
                    // Splash particles (simplified)
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(dropColor)
                            .frame(width: CGFloat.random(in: 2...4), height: CGFloat.random(in: 4...8))
                            .offset(x: CGFloat.random(in: -15...15), y: CGFloat.random(in: -10...0))
                            .scaleEffect(splashScale)
                            .opacity(puddleOpacity > 0.5 ? 1 : 0) // Only visible during splash/ripple phase
                     }
                }
                .offset(y: 25) // Position splash near impact point
                .opacity(splashScale > 0 ? 1 : 0) // Fade splash out quickly


                // --- Falling Drop ---
                Image(systemName: "drop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(dropColor)
                    .offset(y: dropPosition)
                    // Hide drop just before impact visually
                    .opacity(dropPosition > 25 ? 0 : 1)

                // --- Reminder Text ---
                Text("take a sip!")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(textColor)
                    .opacity(showText ? 1 : 0)
                     // Slide in from bottom, centered vertically relative to background
                    .offset(y: showText ? 0 : 20)
            }
        }
        .frame(width: 180, height: 150) // Match window size
        .onAppear(perform: startAnimation) // Trigger animation when view appears
        // .onDisappear(perform: reset) // Optional: Reset state if needed, but creating new instance handles this
    }

    private func reset() {
        // This might not be strictly needed if we recreate the View instance each time
        dropPosition = -50
        splashScale = 0.0
        rippleScale = 0.0
        rippleOpacity = 0.8
        showText = false
        puddleOpacity = 0.0
        puddleScale = 0.8
        print("View state reset.")
    }

    private func startAnimation() {
        // Ensure we start from a clean state (important if view is reused unexpectedly)
        reset()
        print("Starting animation sequence...")

        // Animation Sequence:
        // 1. Drop falls
        withAnimation(.easeIn(duration: 0.6).delay(0.2)) {
            dropPosition = 30 // Target position (impact point)
            puddleOpacity = 1.0 // Puddle appears as drop falls
            puddleScale = 1.0
        }

        // 2. Impact: Splash and Ripple start (slight delay after drop reaches position)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5).speed(1.5)) { // Bouncy splash
                 splashScale = 1.0
             }
            withAnimation(.easeOut(duration: 1.0)) { // Ripple expands
                rippleScale = 1.2 // Expand slightly beyond base
                rippleOpacity = 0.0 // Fade out ripple lines
            }

             // Fade out splash quickly after it appears
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                 withAnimation(.easeOut(duration: 0.3)) {
                     splashScale = 0.0
                 }
             }
        }


        // 3. Text appears as ripple fades
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeIn(duration: 0.5)) {
                showText = true
            }
        }

        // 4. Puddle fades out after text appears
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { // Let text show for a bit
             withAnimation(.easeOut(duration: 0.8)) {
                 puddleOpacity = 0.0
                 puddleScale = 0.6 // Shrink as it fades
             }
         }
    }
}

// MARK: - Custom Shape (Not used in this version, keep if needed for future)
/*
struct WaveShape: Shape {
    // ... (keep your WaveShape code here if you plan to use it later) ...
}
*/

// MARK: - Application Entry Point

// Explicitly create the application instance and delegate
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// Run the application's main event loop
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)