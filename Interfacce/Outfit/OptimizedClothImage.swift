import SwiftUI
import UIKit

struct OptimizedClothImage: View {
    let imageData: Data
    let targetSize: CGSize // Passiamo la dimensione desiderata per ottimizzare la memoria
    
    // Variabile di stato per l'immagine caricata
    @State private var loadedImage: UIImage? = nil
    
    var body: some View {
        ZStack {
            if let uiImage = loadedImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                // Placeholder durante il caricamento
                Color.gray.opacity(0.2)
                ProgressView()
            }
        }
        .task {
            await loadOptimizedImage()
        }
        .onChange(of: imageData) { _, _ in
            Task { await loadOptimizedImage() }
        }
    }
    
    // --- IL CARICAMENTO ASINCRONO IN BACKGROUND ---
    private func loadOptimizedImage() async {
        Task.detached(priority: .userInitiated) {
            if let originalImage = UIImage(data: imageData) {
                // preparingThumbnail alleggerisce pesantemente l'immagine prima di mostrarla
                let thumbnail = originalImage.preparingThumbnail(of: targetSize) ?? originalImage
                
                await MainActor.run {
                    self.loadedImage = thumbnail
                }
            }
        }
    }
}
