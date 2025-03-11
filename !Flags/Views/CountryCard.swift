import SwiftUI

struct CountryCard: View {
    let country: Country
    @State private var isRevealed = false
    @State private var blurRadius: CGFloat = 10
    let onKnow: () -> Void
    let onDontKnow: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            let isIPad = geometry.size.width > 600
            let cardWidth = isIPad ? min(geometry.size.width * 0.7, 600) : geometry.size.width - 32
            let flagHeight: CGFloat = isIPad ? 200 : 180
            let cardHeight: CGFloat = isIPad ? 480 : 580
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Card with information
                    VStack(spacing: 0) {
                        // Flag at the top
                        ZStack {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(.systemBackground))
                            
                            Image(country.flagImageName)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: flagHeight)
                                .background(Color(.systemBackground))
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 23.5,
                                        style: .continuous
                                    )
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: flagHeight)
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 24,
                                style: .continuous
                            )
                        )
                        .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
                        .overlay(
                            RoundedRectangle(
                                cornerRadius: 24,
                                style: .continuous
                            )
                            .stroke(Color(.systemGray5), lineWidth: 0.5)
                        )
                        
                        // Divider line
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 1)
                            .padding(.horizontal, 16)
                        
                        // Country information
                        ZStack(alignment: .bottom) {
                            VStack(spacing: isIPad ? 20 : 28) {
                                // Country name
                                Text(country.localizedName)
                                    .font(.system(size: isIPad ? 36 : 32, weight: .bold))
                                    .padding(.top, isIPad ? 24 : 32)
                                    .padding(.horizontal, 24)
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.7)
                                    .lineLimit(2)
                                
                                // Information
                                VStack(spacing: isIPad ? 16 : 24) {
                                    infoRow(
                                        icon: "house.fill",
                                        color: .blue,
                                        title: "card.capital".localized,
                                        value: country.localizedCapital,
                                        isIPad: isIPad
                                    )
                                    
                                    infoRow(
                                        icon: "person.2.fill",
                                        color: .green,
                                        title: "card.population".localized,
                                        value: country.localizedPopulation,
                                        isIPad: isIPad
                                    )
                                    
                                    infoRow(
                                        icon: "sparkles",
                                        color: .orange,
                                        title: "card.fun_fact".localized,
                                        value: country.localizedFunFact,
                                        isIPad: isIPad
                                    )
                                }
                                .padding(.horizontal, isIPad ? 32 : 16)
                                
                                Spacer(minLength: 0)
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
                                    .font(.system(size: isIPad ? 18 : 16, weight: .medium))
                                    .foregroundColor(.red)
                            }
                            .padding(.bottom, 16)
                        }
                    }
                    .frame(width: cardWidth)
                    .frame(height: cardHeight)
                    .background(Color(.systemBackground))
                    .cornerRadius(24)
                    .shadow(radius: 20, x: 0, y: 4)
                    
                    // Buttons under the card
                    HStack(spacing: 16) {
                        actionButton(title: "card.dont_know".localized, color: .red) {
                            isRevealed = false
                            onDontKnow()
                        }
                        .frame(width: isIPad ? 180 : nil)
                        
                        actionButton(title: "card.know".localized, color: .accentColor) {
                            isRevealed = false
                            onKnow()
                        }
                        .frame(width: isIPad ? 180 : nil)
                    }
                }
                .padding(.horizontal, isIPad ? 0 : 16)
                .padding(.vertical, 32)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func infoRow(icon: String, color: Color, title: String, value: String, isIPad: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon with gradient
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: isIPad ? 40 : 36, height: isIPad ? 40 : 36)
                
                Image(systemName: icon)
                    .font(.system(size: isIPad ? 18 : 16))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: isIPad ? 15 : 14))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: isIPad ? 17 : 16, weight: .medium))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
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
            .frame(minWidth: 140)
            .frame(height: 48)
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