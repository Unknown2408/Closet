import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins

struct ClothCard: View {
    let cloth: Cloth
    @Environment(ClosetManager.self) var manager
    
    @State private var processedImage: UIImage? = nil
    @State private var isProcessing = false

    var isCurrentFavorite: Bool {
        manager.inventory.first(where: { $0.id == cloth.id })?.favourite ?? false
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // BOX IMMAGINE
            ZStack(alignment: .bottomTrailing) {
                Color.white
                
                if let uiImage = processedImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 4)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    ZStack {
                        Color.gray.opacity(0.05)
                        ProgressView()
                            .controlSize(.small)
                    }
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
        .onAppear {
            processImageIfNeeded()
        }
    }
    
    private func processImageIfNeeded() {
        guard processedImage == nil else { return }
        removeBackground()
    }

    private func removeBackground() {
        guard let inputImage = UIImage(data: cloth.image) else { return }
        
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            // FISSA L'ORIENTAMENTO: Usiamo l'orientamento originale della UIImage
            guard let ciImage = CIImage(image: inputImage)?.oriented(forExifOrientation: Int32(CGImagePropertyOrientation(inputImage.imageOrientation).rawValue)) else { return }
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            let request = VNGenerateForegroundInstanceMaskRequest()
            
            do {
                try handler.perform([request])
                guard let result = request.results?.first else {
                    updateImageOnMainThread(inputImage)
                    return
                }
                
                let maskBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
                
                if let output = applyMask(mask: maskBuffer, to: ciImage) {
                    updateImageOnMainThread(output)
                } else {
                    updateImageOnMainThread(inputImage)
                }
                
            } catch {
                updateImageOnMainThread(inputImage)
            }
        }
    }
    
    private func updateImageOnMainThread(_ image: UIImage) {
        DispatchQueue.main.async {
            withAnimation(.easeIn(duration: 0.3)) {
                self.processedImage = image
                self.isProcessing = false
            }
        }
    }
    
    private func applyMask(mask: CVPixelBuffer, to image: CIImage) -> UIImage? {
        let ciMask = CIImage(cvPixelBuffer: mask)
        let filter = CIFilter.maskToAlpha()
        filter.inputImage = ciMask
        
        guard let alphaMask = filter.outputImage else { return nil }
        
        let blendFilter = CIFilter.sourceAtopCompositing()
        blendFilter.inputImage = image
        blendFilter.backgroundImage = alphaMask
        
        let context = CIContext()
        if let cgImage = context.createCGImage(blendFilter.outputImage ?? image, from: image.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}

// Helper per convertire l'orientamento UIImage in CGImagePropertyOrientation
extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .down: self = .down
            case .left: self = .left
            case .right: self = .right
            case .upMirrored: self = .upMirrored
            case .downMirrored: self = .downMirrored
            case .leftMirrored: self = .leftMirrored
            case .rightMirrored: self = .rightMirrored
            @unknown default: self = .up
        }
    }
}
