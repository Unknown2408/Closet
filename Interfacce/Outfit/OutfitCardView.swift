import SwiftUI
import UIKit

struct OutfitCardView: View {
    @Environment(ClosetManager.self) var closetManager
    let outfit: Outfit
    
    var body: some View {
        // TRUCCO INFALLIBILE:
        // Cerchiamo l'outfit aggiornato in tempo reale direttamente dal manager qui dentro il body.
        // In questo modo SwiftUI "ascolta" ogni minimo cambiamento dell'array outfits!
        let currentOutfit = closetManager.outfits.first(where: { $0.id == outfit.id }) ?? outfit
        let isFavorite = currentOutfit.favourite
        
        VStack(alignment: .leading, spacing: 10) {
            
            // --- 1. ANTEPRIMA VISIVA DEI VESTITI ---
            let clothes = closetManager.items(for: currentOutfit)
            
            if clothes.isEmpty {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 80)
                    .overlay(Image(systemName: "hanger").foregroundColor(.gray))
            } else {
                HStack(spacing: -15) {
                    ForEach(clothes.prefix(3)) { cloth in
                        if let uiImage = UIImage(data: cloth.image) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                    }
                    
                    if clothes.count > 3 {
                        Text("+\(clothes.count - 3)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .frame(width: 45, height: 45)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
                .padding(.vertical, 5)
            }
            
            // --- 2. TESTO INFORMATIVO E PULSANTE ---
            HStack(alignment: .bottom) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentOutfit.outfitName)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text("\(currentOutfit.items.count) items")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Pulsante Cuore
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        // USA IL NUOVO NOME DELLA FUNZIONE per gli Outfit!
                        closetManager.toggleFavorite(ofOutfitWithID: currentOutfit.id)
                    }
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.black)
                        .font(.system(size: 22))
                        .padding(.trailing, 5)
                        .padding(.bottom, 5)
                }
                .buttonStyle(.plain) // Evita conflitti di tap all'interno della lista/griglia
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
    }
}
