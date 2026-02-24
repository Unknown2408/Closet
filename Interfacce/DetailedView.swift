import SwiftUI
import Vision
import CoreImage.CIFilterBuiltins

// 1. IL DIZIONARIO DEI COLORI
private let uiColorsDict: [String: Color] = [
    "WHITE": .white, "LIGHT GRAY": Color(white: 0.8), "GRAY": .gray, "DARK GRAY": Color(white: 0.2), "BLACK": .black,
    "RED": .red, "MAROON": Color(red: 0.5, green: 0, blue: 0), "ORANGE": .orange, "BEIGE": Color(red: 0.96, green: 0.96, blue: 0.86), "YELLOW": .yellow,
    "GREEN": .green, "OLIVE": Color(red: 0.5, green: 0.5, blue: 0), "BLUE": .blue, "NAVY": Color(red: 0, green: 0, blue: 0.5), "PURPLE": .purple,
    "PINK": .pink, "BROWN": .brown, "CYAN": .cyan, "TEAL": Color(red: 0, green: 0.5, blue: 0.5), "MAGENTA": Color(red: 1, green: 0, blue: 1)
]

struct DetailedView: View {
    let cloth: Cloth
    @Environment(ClosetManager.self) private var manager
    @Environment(\.dismiss) var dismiss
    
    @State private var showingEditSheet = false
    @State private var showingMatchesSheet = false
    @State private var processedImage: UIImage? = nil
    
    var currentCloth: Cloth {
        manager.inventory.first(where: { $0.id == cloth.id }) ?? cloth
    }
    
    var body: some View {
        VStack {
            // Header: Cuore ed Ellipsis
            HStack(spacing: 20) {
                Spacer()
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        manager.toggleFavorite(ofItemWithID: currentCloth.id)
                    }
                }) {
                    Image(systemName: currentCloth.favourite ? "heart.fill" : "heart")
                        .font(.system(size: 24))
                        .foregroundColor(currentCloth.favourite ? .red : .black)
                }
                
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label("Modify", systemImage: "pencil")
                    }
                    Button(role: .destructive, action: {
                        manager.removeItem(withID: currentCloth.id)
                        dismiss()
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Box Immagine
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)

                        if let uiImage = processedImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .padding(20)
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 350)
                    .padding(.horizontal)

                    // Info
                    VStack(alignment: .leading, spacing: 5) {
                        Text(currentCloth.brand.uppercased())
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        Text(currentCloth.name)
                            .font(.title2.bold())
                    }
                    .padding(.horizontal)

                    Divider().padding(.horizontal)

                    // Sezione Colori
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Colors").font(.headline)
                        ForEach(currentCloth.coloreIndumentoRicerca, id: \.self) { coloreEnum in
                            HStack(spacing: 8) {
                                Text(coloreEnum.rawValue.capitalized).foregroundColor(.secondary)
                                Circle()
                                    .fill(uiColorsDict[coloreEnum.rawValue.uppercased()] ?? Color.gray)
                                    .frame(width: 14, height: 14)
                                    .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // Pulsante Match
            Button(action: { showingMatchesSheet = true }) {
                Text("Match ✨")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 10)
        }
        .onAppear { removeBackground() }
        .sheet(isPresented: $showingEditSheet) { NewItemView(itemToEdit: currentCloth) }
        .sheet(isPresented: $showingMatchesSheet) { MatchCreationSheet(anchorCloth: currentCloth) }
    }
    
    // MARK: - Logica Vision
    private func removeBackground() {
        guard processedImage == nil, let inputImage = UIImage(data: currentCloth.image) else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Utilizziamo l'estensione definita altrove nel progetto
            let orientation = CGImagePropertyOrientation(inputImage.imageOrientation)
            guard let ciImage = CIImage(image: inputImage)?.oriented(orientation) else { return }
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            let request = VNGenerateForegroundInstanceMaskRequest()
            
            do {
                try handler.perform([request])
                guard let result = request.results?.first else { return }
                let mask = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
                
                if let output = applyMask(mask: mask, to: ciImage) {
                    DispatchQueue.main.async {
                        withAnimation { self.processedImage = output }
                    }
                }
            } catch {
                DispatchQueue.main.async { self.processedImage = inputImage }
            }
        }
    }
    
    private func applyMask(mask: CVPixelBuffer, to image: CIImage) -> UIImage? {
        let ciMask = CIImage(cvPixelBuffer: mask)
        let filter = CIFilter.maskToAlpha()
        filter.inputImage = ciMask
        guard let alpha = filter.outputImage else { return nil }
        
        let blend = CIFilter.sourceAtopCompositing()
        blend.inputImage = image
        blend.backgroundImage = alpha
        
        let context = CIContext()
        if let cg = context.createCGImage(blend.outputImage ?? image, from: image.extent) {
            return UIImage(cgImage: cg)
        }
        return nil
    }
}

// MARK: - Modale Abbinamenti
struct MatchCreationSheet: View {
    let anchorCloth: Cloth
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Cerca abbinamenti per \(anchorCloth.name)...")
                    .foregroundColor(.gray)
            }
            .navigationTitle("Match ✨")
            .toolbar {
                Button("Fatto") { dismiss() }
            }
        }
    }
}
