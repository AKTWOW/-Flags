import SwiftUI

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with color background
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(color)
                .clipShape(Circle())
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 8)
    }
}

#Preview {
    FeatureRow(
        icon: "globe",
        color: .blue,
        title: "All continents",
        description: "Access to all countries in the world"
    )
} 