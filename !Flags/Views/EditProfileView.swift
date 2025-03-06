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
    @EnvironmentObject private var profileService: ProfileService
    @State private var name = ""
    @State private var avatarName = ""
    
    var body: some View {
        Form {
            Section("Профіль") {
                TextField("Ім'я", text: $name)
                TextField("Аватар", text: $avatarName)
            }
            
            Section("Налаштування") {
                Button("Відновити покупки") {
                    Task {
                        await profileService.checkPurchaseStatus()
                    }
                }
                
                Button(role: .destructive) {
                    profileService.resetToGuest()
                    dismiss()
                } label: {
                    Text("Вийти та видалити")
                }
            }
        }
        .navigationTitle("Налаштування")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            name = profileService.currentProfile.name
            avatarName = profileService.currentProfile.avatarName
        }
        .onChange(of: name) { newValue in
            profileService.updateName(newValue)
        }
        .onChange(of: avatarName) { newValue in
            profileService.updateAvatarName(newValue)
        }
    }
}

#Preview {
    EditProfileView()
} 