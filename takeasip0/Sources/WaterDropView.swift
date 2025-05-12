import SwiftUI

struct WaterDropView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.clear
            
            VStack {
                Image(systemName: "drop.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.7)
                    .animation(
                        Animation.easeInOut(duration: 1)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                
                Text("Bevi un bicchiere d'acqua!")
                    .font(.caption)
                    .foregroundColor(.primary)
                    .padding(.top, 5)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .opacity(0.8)
            )
            .onAppear {
                isAnimating = true
            }
        }
    }
}
