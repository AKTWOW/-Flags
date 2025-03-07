import SwiftUI

struct SupportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AuthService.shared
    @StateObject private var emailService = EmailService.shared
    
    @State private var email: String = ""
    @State private var description: String = ""
    @State private var isSending = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, description
    }
    
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
                    TextField("support.email".localized, text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .disabled(authService.isAuthenticated)
                        .focused($focusedField, equals: .email)
                } header: {
                    Text("support.email".localized)
                } footer: {
                    if email.count > 30 {
                        Text("support.email_max_length".localized)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("support.description_placeholder".localized)
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                            .focused($focusedField, equals: .description)
                    }
                } header: {
                    Text("support.description".localized)
                } footer: {
                    HStack {
                        Text("\(description.count)/2000")
                            .foregroundColor(description.count > 2000 ? .red : .secondary)
                        Spacer()
                    }
                }
            }
            .navigationTitle("support.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await sendSupportRequest()
                        }
                    } label: {
                        if isSending {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text("support.send".localized)
                        }
                    }
                    .disabled(!isFormValid || isSending)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("common.done".localized) {
                            focusedField = nil
                        }
                    }
                }
            }
            .alert("common.error".localized, isPresented: $showingError) {
                Button("common.ok".localized, role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func sendSupportRequest() async {
        guard isFormValid else { return }
        
        isSending = true
        focusedField = nil
        
        do {
            try await emailService.sendSupportEmail(
                email: email,
                description: description
            )
            isSending = false
            dismiss()
        } catch {
            isSending = false
            errorMessage = (error as? EmailError)?.localizedDescription ?? error.localizedDescription
            showingError = true
        }
    }
}

#Preview {
    SupportView(email: "test@example.com")
} 