import SwiftUI
import Foundation

struct GameView: View {
    @State private var continent: Continent
    @State private var countries: [Country] = []
    @State private var currentIndex = 0
    @State private var knownCount = 0
    @State private var showingResults = false
    @State private var isLoading = true
    @State private var error: Error?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileService = ProfileService.shared
    
    init(continent: Continent) {
        _continent = State(initialValue: continent)
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            if isLoading {
                ProgressView()
            } else if let error = error {
                VStack {
                    Text("Помилка завантаження")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Button("Спробувати знову") {
                        Task {
                            await loadCountries()
                        }
                    }
                    .padding()
                }
            } else if currentIndex < countries.count {
                CountryCard(
                    country: countries[currentIndex],
                    onKnow: {
                        HapticManager.shared.successFeedback()
                        withAnimation(.spring(duration: 0.3)) {
                            knownCount += 1
                            profileService.markCountryAsKnown(countries[currentIndex].id)
                            moveToNextCard()
                        }
                    },
                    onDontKnow: {
                        HapticManager.shared.errorFeedback()
                        withAnimation(.spring(duration: 0.3)) {
                            moveToNextCard()
                        }
                    }
                )
            } else {
                ResultView(
                    knownCount: knownCount,
                    totalCount: countries.count,
                    continent: continent,
                    onDismiss: {
                        dismiss()
                    },
                    onNextContinent: { nextContinent in
                        countries = []
                        currentIndex = 0
                        knownCount = 0
                        continent = nextContinent
                        Task {
                            await loadCountries()
                        }
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Завершити") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
        }
        .task {
            await loadCountries()
        }
    }
    
    private func loadCountries() async {
        isLoading = true
        error = nil
        
        do {
            countries = try await CountryService.shared.loadCountries(for: continent).shuffled()
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    private func moveToNextCard() {
        currentIndex += 1
    }
}

#Preview {
    NavigationStack {
        GameView(continent: .europe)
    }
} 