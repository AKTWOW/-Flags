import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(LocalizedStringKey("terms.content"))
                    .padding()
            }
            .navigationTitle(LocalizedStringKey("terms.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizedStringKey("Close")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TermsView()
} 