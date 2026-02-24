import SwiftUI

struct ClothCard: View {
    let cloth: Cloth
    
    // 1. Importiamo il manager per avere accesso alla "Fonte di Verità"
    @Environment(ClosetManager.self) var manager
    
    // 2. Calcoliamo se è preferito guardando direttamente nel database (manager)
    var isCurrentFavorite: Bool {
        manager.inventory.first(where: { $0.id == cloth.id })?.favourite ?? false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // BOX IMMAGINE INDISTRUTTIBILE
            Rectangle()
                .fill(Color.gray.opacity(0.1)) // 1. Lo sfondo base
                .aspectRatio(0.85, contentMode: .fit) // 2. La proporzione bloccata
                .overlay {
                    // 3. L'immagine "spalmata" sopra, forzata al centro
                    if let uiImage = UIImage(data: cloth.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        // IMMAGINE DI DEFAULT SISTEMATA
                        Image(systemName: "tshirt.fill")
                            .resizable()
                            .scaledToFill()
                            .padding(40) // Lascia "respirare" l'icona
                            .foregroundColor(.gray.opacity(0.3))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12)) // 4. Taglia l'immagine che straborda
                .overlay(alignment: .bottomTrailing) {
                    // 5. IL TUO NUOVO PULSANTE CUORE (Messo come overlay in basso a destra)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            manager.toggleFavorite(ofItemWithID: cloth.id)
                        }
                    }) {
                        Image(systemName: isCurrentFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(8) // Padding per staccare il bottone dal bordo
                }
            
            // INFORMAZIONI CAPO
            VStack(alignment: .leading, spacing: 3) {
                // Nome
                Text(cloth.name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                // Brand
                Text(cloth.brand.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                
                // Tipo
                Text(cloth.type.rawValue)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
    }
}
