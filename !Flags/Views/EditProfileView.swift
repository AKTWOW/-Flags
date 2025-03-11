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
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var profileService: ProfileService
    @State private var showingSignOutConfirmation = false
    @State private var isRestoringPurchases = false
    @State private var showingRestoreError = false
    @Binding var showingSupportView: Bool
    @Binding var showingAuthView: Bool
    
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
                    Label {
                        Text("profile.edit.restore_purchases".localized)
                    } icon: {
                        Image(systemName: "arrow.clockwise")
                    }
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
                Label {
                    Text("profile.edit.contact_support".localized)
                } icon: {
                    Image(systemName: "questionmark.circle")
                }
            }
            
            if authService.isAuthenticated {
                Button(role: .destructive) {
                    showingSignOutConfirmation = true
                } label: {
                    Label {
                        Text("profile.edit.signout".localized)
                    } icon: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            } else {
                Button {
                    showingAuthView = true
                } label: {
                    Label {
                        Text("profile.edit.signin".localized)
                    } icon: {
                        Image(systemName: "person.crop.circle.badge.plus")
                    }
                }
            }
        }
        .confirmationDialog(
            "profile.edit.signout_warning.title".localized,
            isPresented: $showingSignOutConfirmation,
            titleVisibility: .hidden
        ) {
            Button("profile.edit.signout".localized, role: .destructive) {
                Task {
                    do {
                        try await authService.signOutWithoutConfirmation()
                        dismiss()
                    } catch {
                        // Handle error if needed
                    }
                }
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
    @State private var showingAuthView = false
    @State private var showingDeleteAccountConfirmation = false
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
                    HStack {
                        TextField("profile.edit.name".localized, text: $name)
                        Image(systemName: "pencil")
                            .foregroundColor(.gray)
                    }
                    
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
                
                AccountSettingsSection(
                    showingSupportView: $showingSupportView,
                    showingAuthView: $showingAuthView
                )
                
                if authService.isAuthenticated {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteAccountConfirmation = true
                        } label: {
                            Label {
                                Text("profile.edit.delete_account".localized)
                            } icon: {
                                Image(systemName: "trash")
                            }
                        }
                    } footer: {
                        Text("profile.edit.delete_account_note".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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
            .sheet(isPresented: $showingEmojiPicker) {
                EmojiPickerView(avatarName: $avatarName, isPresented: $showingEmojiPicker)
            }
            .fullScreenCover(isPresented: $showingSupportView) {
                SupportView(email: authService.currentUser?.email ?? "")
            }
        }
        .sheet(isPresented: $showingAuthView) {
            AuthView()
        }
        .confirmationDialog(
            "profile.edit.delete_account_warning.title".localized,
            isPresented: $showingDeleteAccountConfirmation,
            titleVisibility: .visible
        ) {
            Button("profile.edit.delete_account_confirm".localized, role: .destructive) {
                Task {
                    do {
                        try await authService.deleteAccount()
                        dismiss()
                    } catch {
                        // TODO: Show error alert
                    }
                }
            }
            Button("common.cancel".localized, role: .cancel) {}
        } message: {
            Text("profile.edit.delete_account_warning.message".localized)
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