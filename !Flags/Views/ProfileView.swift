import SwiftUI

enum ActiveSheet: Identifiable {
    case editProfile
    case proUpgrade
    case auth
    case proThankYou
    case knownCountries
    
    var id: Int {
        switch self {
        case .editProfile: return 1
        case .proUpgrade: return 2
        case .auth: return 3
        case .proThankYou: return 4
        case .knownCountries: return 5
        }
    }
}

struct ProfileView: View {
    @StateObject private var profileService = ProfileService.shared
    @State private var activeSheet: ActiveSheet?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        let _ = Logger.shared.debug("Rendering ProfileView", file: #file, function: #function, line: #line)
        let _ = Logger.shared.debug("AuthProvider = \(profileService.currentProfile.authProvider)")
        let _ = Logger.shared.debug("Is Guest? = \(profileService.currentProfile.authProvider == .guest)")
        
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Хедер профілю
                            profileHeader
                            
                            // Прогрес
                            progressSection
                            
                            // Ачівки
                            achievementsSection
                            
                            // Відвідані країни
                            visitedCountriesSection
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                    }
                    
                    if profileService.currentProfile.authProvider == .guest {
                        Divider()
                            .background(Color(.systemGray4))
                        
                        signInButton
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(Color(.systemBackground))
                    }
                }
            }
            .navigationTitle("Профіль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .editProfile:
                    EditProfileView()
                        .environmentObject(profileService)
                        .environmentObject(AuthService.shared)
                case .proUpgrade:
                    ProUpgradeView()
                case .auth:
                    AuthView()
                case .proThankYou:
                    ProThankYouView()
                case .knownCountries:
                    KnownCountriesView()
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    refreshProfile()
                }
            }
        }
    }
    
    private func refreshProfile() {
        Logger.shared.info("Оновлюємо ProfileView")
        
        // Перезавантажуємо профіль
        profileService.reloadProfile()
        
        // Форсуємо оновлення UI
        DispatchQueue.main.async {
            Logger.shared.debug("Оновлюємо UI з \(self.profileService.currentProfile.knownCountries.count) країнами")
            withAnimation {
                self.profileService.objectWillChange.send()
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Text(profileService.currentProfile.avatarName)
                    .font(.system(size: 60))
                    .frame(width: 100, height: 100)
                    .background(Circle().fill(Color.accentColor.opacity(0.1)))
                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                
                Button {
                    activeSheet = .editProfile
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.accentColor)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                }
                .offset(x: 35, y: 35)
                
                if profileService.currentProfile.isPro {
                    Button {
                        activeSheet = .proThankYou
                    } label: {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.yellow)
                            .background(
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .frame(width: 32, height: 32)
                            )
                    }
                    .offset(x: -35, y: -35)
                }
            }
            
            VStack(spacing: 4) {
                Text(profileService.currentProfile.name)
                    .font(.title2.bold())
                
                Text(profileService.currentProfile.level.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var progressSection: some View {
        let knownCount = profileService.currentProfile.knownCountries.count
        Logger.shared.debug("Рендеримо прогрес секцію", file: #file, function: #function, line: #line)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Прогрес")
                    .font(.headline)
                
                if !profileService.currentProfile.isPro {
                    Text("PRO")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                if !profileService.currentProfile.isPro {
                    Button {
                        activeSheet = .proUpgrade
                    } label: {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                    }
                }
            }
            
            VStack(spacing: 12) {
                // Основний прогрес
                VStack(spacing: 8) {
                    HStack {
                        Text(progressEmoji)
                            .font(.title3)
                        Text(progressTitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .blur(radius: profileService.currentProfile.isPro ? 0 : 4)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(progressColor)
                                .frame(width: CGFloat(profileService.currentProfile.progress) * geometry.size.width, height: 8)
                        }
                    }
                    .frame(height: 8)
                    .blur(radius: profileService.currentProfile.isPro ? 0 : 4)
                }
                
                // Мотиваційний текст
                if let motivationalText = nextMilestoneText {
                    Text(motivationalText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .blur(radius: profileService.currentProfile.isPro ? 0 : 4)
                }
                
                // Кнопка дії
                if profileService.currentProfile.isPro {
                    Button {
                        activeSheet = .knownCountries
                    } label: {
                        HStack {
                            Image(systemName: "map.fill")
                                .font(.subheadline)
                            Text("Подивитися вивчені країни")
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .id(knownCount) // Форсуємо оновлення при зміні кількості країн
    }
    
    private var progressEmoji: String {
        let progress = profileService.currentProfile.progress
        switch progress {
        case 0..<0.3: return "🌱"
        case 0.3..<0.7: return "🌿"
        case 0.7..<1.0: return "🌳"
        case 1.0: return "🎯"
        default: return "🌱"
        }
    }
    
    private var progressTitle: String {
        let count = profileService.currentProfile.knownCountries.count
        switch count {
        case 0:
            return "Почніть свою подорож світом!"
        case 1...10:
            return "Ви відкрили \(count) із 195 країн! Чудовий початок!"
        case 11...50:
            return "Вже \(count) країн вивчено – Ви справжній мандрівник!"
        case 51...100:
            return "\(count) країн – Ви експерт з географії!"
        case 101...194:
            return "Неймовірно! \(count) країн вже відкрито!"
        case 195:
            return "Вітаємо! Ви підкорили весь світ! 🎉"
        default:
            return "Вивчено \(count) із 195 країн"
        }
    }
    
    private var nextMilestoneText: String? {
        let count = profileService.currentProfile.knownCountries.count
        switch count {
        case 0...9:
            let remaining = 10 - count
            return "Перший рубіж – 10 країн! Залишилось \(remaining)!"
        case 10...24:
            let remaining = 25 - count
            return "Наступна ціль – 25 країн! Ще \(remaining)!"
        case 25...49:
            let remaining = 50 - count
            return "Попереду важливий рубіж – 50 країн! Залишилось \(remaining)!"
        case 50...99:
            let remaining = 100 - count
            return "Прямуємо до сотні! Ще \(remaining) країн!"
        case 100...194:
            let remaining = 195 - count
            return "До повного підкорення світу залишилось \(remaining) країн!"
        default:
            return nil
        }
    }
    
    private var progressColor: Color {
        let progress = profileService.currentProfile.progress
        switch progress {
        case 0..<0.3: return .red
        case 0.3..<0.7: return .yellow
        case 0.7..<1.0: return .blue
        case 1.0: return .green
        default: return .red
        }
    }
    
    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Нагороди")
                    .font(.headline)
                
                if !profileService.currentProfile.isPro {
                    Text("PRO")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 8) {
                ForEach(profileService.currentProfile.achievements) { achievement in
                    AchievementCard(achievement: achievement, activeSheet: $activeSheet)
                }
            }
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var visitedCountriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🌍")
                    .font(.title2)
                Text("Відвідані країни")
                    .font(.headline)
                
                Spacer()
                
                Text("Незабаром!")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
            }
            
            Text("Невдовзі ви зможете створити власну мапу подорожей!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var signInButton: some View {
        Button {
            activeSheet = .auth
        } label: {
            Text("Увійти")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.accentColor)
                .cornerRadius(16)
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    @StateObject private var profileService = ProfileService.shared
    @Binding var activeSheet: ActiveSheet?
    
    private var gradientColors: [Color] {
        switch achievement.id {
        case "living_atlas":
            return [Color(hex: "#4158D0"), Color(hex: "#C850C0")]
        case "geography_witcher":
            return [Color(hex: "#FF6B6B"), Color(hex: "#FFD93D")]
        case "traveler":
            return [Color(hex: "#00C6FB"), Color(hex: "#005BEA")]
        case "sea_conqueror":
            return [Color(hex: "#48C6EF"), Color(hex: "#6F86D6")]
        case "cartography_sherlock":
            return [Color(hex: "#A8C0FF"), Color(hex: "#3F2B96")]
        case "alien_tourist":
            return [Color(hex: "#08AEEA"), Color(hex: "#2AF598")]
        case "daily_challenge":
            return [Color(hex: "#FF0844"), Color(hex: "#FFB199")]
        default:
            return [Color(hex: "#4158D0"), Color(hex: "#C850C0")]
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Іконка досягнення
            ZStack {
                Circle()
                    .fill(
                        achievement.isUnlocked ?
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color(.systemGray4), Color(.systemGray4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .shadow(color: achievement.isUnlocked ? gradientColors[0].opacity(0.3) : Color(.systemGray4).opacity(0.3), radius: 8)
                
                if achievement.isUnlocked {
                    Image(achievementImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                } else {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 17, weight: .bold))
                
                Text(achievement.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .blur(radius: profileService.currentProfile.isPro ? 0 : 4)
            }
            
            Spacer()
            
            if !profileService.currentProfile.isPro {
                Button {
                    activeSheet = .proUpgrade
                } label: {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.orange)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
    
    private var achievementImage: String {
        switch achievement.id {
        case "living_atlas":
            return "atlas"
        case "geography_witcher":
            return "vidmak"
        case "traveler":
            return "traveler"
        case "sea_conqueror":
            return "sea"
        case "cartography_sherlock":
            return "sherlock"
        case "alien_tourist":
            return "alien"
        case "daily_challenge":
            return "daily"
        default:
            return "atlas"
        }
    }
}

struct CustomProgressViewStyle: ProgressViewStyle {
    let progress: Double
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(progressColor)
                    .frame(width: CGFloat(progress) * geometry.size.width, height: 8)
            }
        }
    }
    
    private var progressColor: Color {
        switch progress {
        case 0..<0.3: return .red
        case 0.3..<0.7: return .yellow
        case 0.7..<1.0: return .blue
        case 1.0: return .green
        default: return .red
        }
    }
}

#Preview {
    ProfileView()
} 