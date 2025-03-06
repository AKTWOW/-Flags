import SwiftUI

struct EmojiPickerView: View {
    @Binding var avatarName: String
    @Binding var isPresented: Bool
    
    private let emojis = ["😊", "😎", "🤓", "🧐", "🤠", "🥳", "🤪", "😇", "🦸‍♂️", "🦹‍♂️", "🧙‍♂️", "🧚‍♂️"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 20) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button {
                            avatarName = emoji
                            isPresented = false
                        } label: {
                            Text(emoji)
                                .font(.system(size: 40))
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Оберіть аватар")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct AccountSettingsSection: View {
    @EnvironmentObject private var profileService: ProfileService
    @EnvironmentObject private var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Section {
            Button(action: {
                profileService.resetToGuest()
                dismiss()
            }) {
                HStack {
                    Text("Вийти та видалити")
                        .foregroundColor(.red)
                    Spacer()
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 24)
                }
            }
            
            NavigationLink(destination: SupportView(email: authService.currentUser?.email ?? "")) {
                HStack {
                    Text("Написати в підтримку")
                    Spacer()
                    Image(systemName: "envelope")
                        .frame(width: 24)
                }
            }
            
            Button(action: {
                Task {
                    try? await StoreService.shared.restorePurchases()
                }
            }) {
                HStack {
                    Text("Відновити покупки")
                    Spacer()
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 24)
                }
            }
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileService = ProfileService.shared
    @StateObject private var authService = AuthService.shared
    @State private var showingSignOutConfirmation = false
    @State private var showingEmojiPicker = false
    @State private var showingRestoreError = false
    @State private var showingSupportView = false
    @State private var isRestoringPurchases = false
    @State private var name: String
    @State private var avatarName: String
    
    init() {
        _name = State(initialValue: ProfileService.shared.currentProfile.name)
        _avatarName = State(initialValue: ProfileService.shared.currentProfile.avatarName)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Ім'я", text: $name)
                    
                    Button {
                        showingEmojiPicker = true
                    } label: {
                        HStack {
                            Text("Аватар")
                            Spacer()
                            Text(avatarName)
                        }
                    }
                }
                
                if authService.isAuthenticated {
                    AccountSettingsSection()
                }
            }
            .navigationTitle("Редагування профілю")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        saveProfile()
                        dismiss()
                    }
                }
            }
            .alert("Ви впевнені, що хочете вийти?", isPresented: $showingSignOutConfirmation) {
                Button("Скасувати", role: .cancel) {}
                Button("Вийти та втратити прогрес", role: .destructive) {
                    authService.signOut()
                    dismiss()
                }
            } message: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("⚠️ Якщо ви вийдете, ваш прогрес буде втрачено!")
                        .fontWeight(.bold)
                    Text("🔹 Відкриті країни – скинуться.")
                    Text("🔹 Нагороди – заблокуються.")
                    Text("🔹 Досягнення – зникнуть.")
                    Text("\nЦе безповоротно, якщо ви не увійдете знову!")
                        .fontWeight(.medium)
                }
            }
            .alert("Покупки не знайдено", isPresented: $showingRestoreError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Ми не знайшли покупку на цьому акаунті. Переконайтеся, що ви увійшли під правильним акаунтом Apple ID.")
            }
            .sheet(isPresented: $showingEmojiPicker) {
                EmojiPickerView(avatarName: $avatarName, isPresented: $showingEmojiPicker)
            }
            .sheet(isPresented: $showingSupportView) {
                SupportView(email: authService.currentUser?.email ?? "")
            }
        }
    }
    
    private func saveProfile() {
        profileService.updateName(name)
        profileService.updateAvatar(avatarName)
    }
}

#Preview {
    EditProfileView()
} 