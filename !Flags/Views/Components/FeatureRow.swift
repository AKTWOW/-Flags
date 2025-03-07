import SwiftUI

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Іконка з градієнтом
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary.opacity(0.8))
            }
        }
    }
}

#Preview {
    FeatureRow(
        icon: "globe",
        color: .blue,
        title: "Всі континенти",
        description: "Доступ до всіх країн світу"
    )
} 