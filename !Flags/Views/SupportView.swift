import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    
    @State private var email: String = ""
    @State private var description: String = ""
    @State private var isSending = false
    
    init(email: String) {
        _email = State(initialValue: email)
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && 
        email.contains("@") && 
        email.count <= 30 &&
        !description.isEmpty &&
        description.count <= 2000
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Ваша пошта", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disabled(authService.isAuthenticated)
                } header: {
                    Text("Ваша пошта")
                } footer: {
                    if email.count > 30 {
                        Text("Максимальна довжина пошти - 30 символів")
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                } header: {
                    Text("Опис проблеми")
                } footer: {
                    HStack {
                        Text("\(description.count)/2000")
                            .foregroundColor(description.count > 2000 ? .red : .secondary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Написати в підтримку")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        sendSupportRequest()
                    } label: {
                        if isSending {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text("Відправити")
                        }
                    }
                    .disabled(!isFormValid || isSending)
                }
            }
        }
    }
    
    private func sendSupportRequest() {
        guard isFormValid else { return }
        
        isSending = true
        // TODO: Implement sending support request
        // Тут буде логіка відправки запиту в підтримку
        
        // Симулюємо відправку
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSending = false
            dismiss()
        }
    }
}

#Preview {
    SupportView(email: "test@example.com")
} 