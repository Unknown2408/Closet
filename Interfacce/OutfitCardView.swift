import SwiftUI
import UIKit // Aggiunto per usare UIImage in totale sicurezza

struct OutfitCardView: View {
    // Recuperiamo il manager dall'ambiente per poter usare le sue funzioni
    @Environment(ClosetManager.self) var closetManager
    
    // L'outfit specifico che questa card deve mostrare
    let outfit: Outfit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // 1. ANTEPRIMA VISIVA DEI VESTITI
            // Usiamo la funzione che avevi già creato per trasformare gli UUID in capi reali!
            let clothes = closetManager.items(for: outfit)
            
            if clothes.isEmpty {
                // Se l'outfit per qualche motivo è vuoto, mostriamo un placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 80)
                    .overlay(Image(systemName: "hanger").foregroundColor(.gray))
            } else {
                // Mostriamo le immagini sovrapposte (max 3 per non sbordare)
                HStack(spacing: -15) { // Lo spacing negativo crea l'effetto sovrapposizione!
                    ForEach(clothes.prefix(3)) { cloth in
                        
                        // CORREZIONE: Gestione dei byte (Data) -> Immagine visualizzabile (UIImage)
                        if let uiImage = UIImage(data: cloth.image) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2)) // Bordo bianco per staccarle
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                        } else {
                            // PIANO B: Se i dati non formano un'immagine valida, mostriamo un'icona
                            Image(systemName: "tshirt")
                                .resizable()
                                .scaledToFit()
                                .padding(10)
                                .frame(width: 50, height: 50)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                        }
                    }
                    
                    // Se ci sono più di 3 capi, mostriamo un pallino "+X"
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
            
            // 2. TESTO INFORMATIVO
            VStack(alignment: .leading, spacing: 4) {
                Text(outfit.outfitName)
                    .font(.headline)
                    .lineLimit(1) // Tronca il testo se è troppo lungo
                
                Text("\(outfit.items.count) items")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        // Colore di sfondo che si adatta automaticamente al Dark/Light mode di iOS
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
    }
}
