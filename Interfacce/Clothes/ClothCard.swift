import SwiftUI

struct ClothCard: View {
    let cloth: Cloth
    @Environment(ClosetManager.self) var manager
    
    var isCurrentFavorite: Bool {
        manager.inventory.first(where: { $0.id == cloth.id })?.favourite ?? false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // BOX IMMAGINE SNELLITO
            ZStack(alignment: .bottomTrailing) {
                // Sfondo della card (bianco o leggero grigio)
                Color.gray.opacity(0.05)
                
                if let uiImage = UIImage(data: cloth.image) {
                    // Questa è l'immagine che NewItemView ha già scontornato per noi!
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
                } else {
                    Image(systemName: "tshirt.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(40)
                        .foregroundColor(.gray.opacity(0.3))
                }
                
                // PULSANTE CUORE
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        manager.toggleFavorite(ofItemWithID: cloth.id)
                    }
                }) {
                    Image(systemName: isCurrentFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(.white)
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                        )
                }
                .padding(8)
            }
            .aspectRatio(0.85, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
            )
            
            // INFORMAZIONI CAPO
            VStack(alignment: .leading, spacing: 2) {
                Text(cloth.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(cloth.brand.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(cloth.type.rawValue)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
    }
}
