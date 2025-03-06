import SwiftUI

struct ShimmerEffect: View {
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            let gradient = LinearGradient(
                gradient: Gradient(colors: [
                    .white.opacity(0.0),
                    .white.opacity(0.0),
                    .white.opacity(0.0),
                    .white.opacity(0.1),
                    .white.opacity(0.3),
                    .white.opacity(0.1),
                    .white.opacity(0.0),
                    .white.opacity(0.0),
                    .white.opacity(0.0)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            
            gradient
                .frame(width: 100) // Ширша смуга для більш м'якого ефекту
                .blur(radius: 15) // Розмиття ефекту
                .offset(x: isAnimating ? geometry.size.width : -100)
                .animation(
                    Animation.linear(duration: 2.5) // Повільніша анімація
                        .repeatForever(autoreverses: false)
                        .delay(2) // Пауза між анімаціями
                    ,
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
                .blendMode(.screen)
        }
    }
}

#Preview {
    ZStack {
        Color.blue
        ShimmerEffect()
    }
    .frame(width: 200, height: 50)
    .cornerRadius(12)
} 