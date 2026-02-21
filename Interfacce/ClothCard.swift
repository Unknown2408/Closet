import SwiftUI

struct ClothCard: View {
    let cloth: Cloth
    @State private var isFavorite: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Box Immagine
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .aspectRatio(0.85, contentMode: .fit)
                
                if let uiImage = UIImage(data: cloth.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                } else {
                    Image(systemName: "tshirt.fill")
                        .foregroundColor(.gray.opacity(0.3))
                        .font(.largeTitle)
                }
                
                // PULSANTE CUORE - STILE APPLE (NERO)
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isFavorite.toggle()
                    }
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18))
                        .foregroundColor(.black) // Sempre nero come richiesto
                        .padding(12)
                }
            }
            
            // Informazioni Capo
            VStack(alignment: .leading, spacing: 2) {
                Text(cloth.brand.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.black)
                
                Text(cloth.type.rawValue)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
    }
}
