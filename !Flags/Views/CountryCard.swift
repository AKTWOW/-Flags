import SwiftUI

struct CountryCard: View {
    let country: Country
    @State private var isRevealed = false
    @State private var blurRadius: CGFloat = 10
    let onKnow: () -> Void
    let onDontKnow: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Card with information
            VStack(spacing: 0) {
                // Flag at the top
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    
                    Image(country.flagImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                
                // Country information
                ZStack(alignment: .bottom) {
                    VStack(spacing: 32) {
                        // Country name
                        Text(country.localizedName)
                            .font(.system(size: 32, weight: .bold))
                            .padding(.top, 24)
                        
                        // Information
                        VStack(spacing: 24) {
                            infoRow(
                                icon: "house.fill",
                                color: .blue,
                                title: "card.capital".localized,
                                value: country.localizedCapital
                            )
                            
                            infoRow(
                                icon: "person.2.fill",
                                color: .green,
                                title: "card.population".localized,
                                value: country.population
                            )
                            
                            infoRow(
                                icon: "sparkles",
                                color: .orange,
                                title: "card.fun_fact".localized,
                                value: country.localizedFunFact
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        Spacer()
                    }
                    .blur(radius: isRevealed ? 0 : blurRadius)
                    .onChange(of: isRevealed) { oldValue, newValue in
                        if !newValue {
                            withAnimation(
                                .easeInOut(duration: 2)
                                .repeatForever(autoreverses: true)
                            ) {
                                blurRadius = 20
                            }
                        }
                    }
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2)
                            .repeatForever(autoreverses: true)
                        ) {
                            blurRadius = 20
                        }
                    }
                    
                    // "Learn more" button
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            isRevealed.toggle()
                        }
                    } label: {
                        Text(isRevealed ? "card.got_it".localized : "card.reveal".localized)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.red)
                    }
                    .padding(.bottom, 16)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 580)
            .background(Color(.systemBackground))
            .cornerRadius(24)
            .shadow(radius: 20, x: 0, y: 4)
            
            // Buttons under the card
            HStack(spacing: 20) {
                actionButton(title: "card.dont_know".localized, color: .red) {
                    isRevealed = false
                    onDontKnow()
                }
                
                actionButton(title: "card.know".localized, color: .accentColor) {
                    isRevealed = false
                    onKnow()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, -8)
    }
    
    private func infoRow(icon: String, color: Color, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon with gradient
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 16, weight: .medium))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func actionButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Icon
                Text(title == "card.know".localized ? "👍" : "❌")
                    .font(.system(size: 20))
                
                // Text
                Text(title)
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(width: 160, height: 48)
            .background(color)
            .cornerRadius(12)
            .shadow(radius: 10, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    // Button style with animation
    struct ScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.spring(duration: 0.2, bounce: 0.3), value: configuration.isPressed)
        }
    }
}

#Preview {
    CountryCard(
        country: Country(
            id: "netherlands",
            name: "Netherlands",
            capital: "Amsterdam",
            population: "17.5M",
            continent: .europe,
            isIsland: false,
            flagImageName: "netherlands",
            funFact: "Famous for its tulips and windmills"
        ),
        onKnow: {},
        onDontKnow: {}
    )
} 