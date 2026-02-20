import SwiftUI
import UIKit // Aggiunto per usare UIImage

struct ItemThumbnail: View {
    let cloth: Cloth
    let actionIcon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                if let uiImage = UIImage(data: cloth.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "tshirt")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .overlay(alignment: .topTrailing) {
                Image(systemName: actionIcon)
                    .foregroundStyle(actionIcon == "minus.circle.fill" ? .red : .blue)
                    .background(Circle().fill(.white))
                    .offset(x: 5, y: -5)
            }
            .shadow(color: .black.opacity(0.1), radius: 2)
        }
        .buttonStyle(.plain)
    }
}
