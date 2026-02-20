import SwiftUI

struct ClothCard: View {
    // Il capo specifico che questa card deve mostrare
    let cloth: Cloth
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Box Immagine
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .aspectRatio(0.85, contentMode: .fit)
                
                // LOGICA PER DATA -> IMAGE
                if let uiImage = UIImage(data: cloth.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                } else {
                    // Placeholder nel caso i dati siano corrotti o mancanti
                    Image(systemName: "tshirt.fill")
                        .foregroundColor(.gray.opacity(0.3))
                        .font(.largeTitle)
                }
            }
            
            // Informazioni Capo
            VStack(alignment: .leading, spacing: 2) {
                Text(cloth.brand.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(cloth.type.rawValue)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
    }
}
