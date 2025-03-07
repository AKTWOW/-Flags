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
            .navigationTitle("profile.edit.emoji_picker.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("profile.edit.emoji_picker.done".localized) {
                        isPresented = false
                    }
                }
            }
        }
    }
}

struct SignOutConfirmationView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var profileService: ProfileService
    
    var body: some View {
        VStack(spacing: 16) {
            Text("profile.edit.signout_warning.title".localized)
                .fontWeight(.bold)
            Text("profile.edit.signout_warning.points".localized)
            Text("profile.edit.signout_warning.note".localized)
                .fontWeight(.medium)
        }
    }
}

struct AccountSettingsSection: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var profileService: ProfileService
    @State private var showingSignOutConfirmation = false
    @State private var isRestoringPurchases = false
    @State private var showingRestoreError = false
    @Binding var showingSupportView: Bool
    
    var body: some View {
        Section {
            Button {
                Task {
                    isRestoringPurchases = true
                    let success = await profileService.restorePurchases()
                    if !success {
                        showingRestoreError = true
                    }
                    isRestoringPurchases = false
                }
            } label: {
                HStack {
                    Text("profile.edit.restore_purchases".localized)
                    Spacer()
                    if isRestoringPurchases {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
            
            Button {
                showingSupportView = true
            } label: {
                Text("profile.edit.contact_support".localized)
            }
            
            Button(role: .destructive) {
                showingSignOutConfirmation = true
            } label: {
                Text("profile.edit.signout".localized)
            }
        }
        .confirmationDialog(
            "profile.edit.signout_warning.title".localized,
            isPresented: $showingSignOutConfirmation,
            titleVisibility: .hidden
        ) {
            Button("profile.edit.signout".localized, role: .destructive) {
                authService.signOut()
            }
            Button("common.cancel".localized, role: .cancel) {}
        } message: {
            SignOutConfirmationView(isPresented: $showingSignOutConfirmation)
        }
        .alert("profile.edit.restore_error.title".localized, isPresented: $showingRestoreError) {
            Button("common.ok".localized, role: .cancel) {}
        } message: {
            Text("profile.edit.restore_error.message".localized)
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var profileService: ProfileService
    @EnvironmentObject private var authService: AuthService
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
                    TextField("profile.edit.name".localized, text: $name)
                    
                    Button {
                        showingEmojiPicker = true
                    } label: {
                        HStack {
                            Text("profile.edit.avatar".localized)
                            Spacer()
                            Text(avatarName)
                        }
                    }
                }
                
                if authService.isAuthenticated {
                    AccountSettingsSection(showingSupportView: $showingSupportView)
                }
            }
            .navigationTitle("profile.edit.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("common.cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.done".localized) {
                        saveProfile()
                        dismiss()
                    }
                }
            }
            .alert("profile.edit.restore_error.title".localized, isPresented: $showingRestoreError) {
                Button("common.ok".localized, role: .cancel) {}
            } message: {
                Text("profile.edit.restore_error.message".localized)
            }
            .sheet(isPresented: $showingEmojiPicker) {
                EmojiPickerView(avatarName: $avatarName, isPresented: $showingEmojiPicker)
            }
            .fullScreenCover(isPresented: $showingSupportView) {
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