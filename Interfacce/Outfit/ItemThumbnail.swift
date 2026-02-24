import SwiftUI
import UIKit // Aggiunto per usare UIImage e UIImpactFeedbackGenerator

struct ItemThumbnail: View {
    let cloth: Cloth
    let actionIcon: String
    let action: () -> Void
    
    // 1. Variabile di stato per l'immagine caricata
    @State private var loadedImage: UIImage? = nil
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            VStack {
                // 2. Se l'immagine è pronta, la mostra. Altrimenti mostra un caricamento.
                if let uiImage = loadedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        ProgressView() // Rotellina di caricamento
                    }
                    // 3. Fa partire il caricamento ottimizzato asincrono
                    .task {
                        await loadOptimizedImage()
                    }
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
        // Se l'immagine dovesse cambiare, la ricarichiamo
        .onChange(of: cloth.image) { _, _ in
            Task { await loadOptimizedImage() }
        }
    }
    
    // --- LA MAGIA DEL BACKGROUND RENDERING ---
    private func loadOptimizedImage() async {
        // Task.detached sposta il lavoro pesante fuori dal thread della UI
        Task.detached(priority: .userInitiated) {
            if let originalImage = UIImage(data: cloth.image) {
                
                let targetSize = CGSize(width: 160, height: 160)
                
                let thumbnail = originalImage.preparingThumbnail(of: targetSize) ?? originalImage
                
                // Riporta l'immagine ottimizzata sul thread principale per visualizzarla
                await MainActor.run {
                    self.loadedImage = thumbnail
                }
            }
        }
    }
}
