import SwiftUI

struct ClothCard: View {
    let cloth: Cloth
    @State private var isFavorite: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // BOX IMMAGINE
            ZStack(alignment: .bottomTrailing) {
                // 1. Lo sfondo grigio
                Color.gray.opacity(0.1)
                
                // 2. L'immagine
                if let uiImage = UIImage(data: cloth.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "tshirt.fill")
                        .foregroundColor(.gray.opacity(0.3))
                        .font(.largeTitle)
                }
                
                // 3. PULSANTE CUORE - STILE APPLE (NERO)
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isFavorite.toggle()
                    }
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                        .padding(12)
                }
            }
            // 4. Forza la proporzione del contenitore
            .aspectRatio(0.85, contentMode: .fit)
            // 5. TAGLIA via la parte di foto "strabordante" con i bordi arrotondati
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // INFORMAZIONI CAPO
            VStack(alignment: .leading, spacing: 3) {
                // NUOVO: Nome dato dall'utente (Salvato come 'description')
                Text(cloth.name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                // Brand (Modificato leggermente in grigio per non confonderlo col nome)
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
