import SwiftUI

struct ProThankYouView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileService = ProfileService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                    .padding(.top, 40)
                
                Text("Дякуємо, що ви з нами!")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Ви маєте повний доступ\nдо всіх континентів")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Button {
                    profileService.resetProStatus()
                    dismiss()
                } label: {
                    Text("Скинути PRO статус")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Готово") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProThankYouView()
} 