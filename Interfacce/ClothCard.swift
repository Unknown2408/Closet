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
            
            // BOX IMMAGINE
            ZStack(alignment: .bottomTrailing) {
                // 1. Lo sfondo grigio per quando non c'è immagine
                Color.gray.opacity(0.1)
                
                // 2. L'immagine del capo
                if let uiImage = UIImage(data: cloth.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "tshirt.fill")
                        .foregroundColor(.gray.opacity(0.3))
                        .font(.largeTitle)
                }
                
                // 3. PULSANTE CUORE CON CERCHIO - COLLEGATO AL MANAGER
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        // Modifica direttamente il dato nel manager
                        manager.toggleFavorite(ofItemWithID: cloth.id)
                    }
                }) {
                    Image(systemName: isCurrentFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16)) // Dimensione icona
                        .foregroundColor(.black) // <--- ORA È SEMPRE NERO
                        .padding(8) // Spazio tra icona e bordo del cerchio
                        .background(
                            Circle()
                                .fill(Color.white) // Sfondo bianco del cerchio
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1) // Leggera ombra
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1) // Sottile bordo grigio
                        )
                }
                .padding(8) // Padding esterno per posizionare il bottone nell'angolo
            }
            // 4. Forza la proporzione del contenitore
            .aspectRatio(0.85, contentMode: .fit)
            // 5. TAGLIA via la parte di foto "strabordante" con i bordi arrotondati
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
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
