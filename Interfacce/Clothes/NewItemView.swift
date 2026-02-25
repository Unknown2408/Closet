import SwiftUI
import UIKit
import Combine
import PhotosUI
import Vision
import CoreImage.CIFilterBuiltins

struct NewItemView: View {
    var itemToEdit: Cloth? = nil
    
    // MARK: - State Properties
    @State private var name: String = ""
    @State private var selectedPosition: Position = .top
    @State private var selectedType: ClothingType = .tShirt
    
    @State private var isAllSeasons: Bool = false
    @State private var selectedSeasons: Set<Season> = [.summer]
    
    @State private var selectedStyle: Style = .casual
    
    @State private var selectedBrand: String = "Unbranded"
    @State private var previousBrand: String = "Unbranded"
    @State private var showingAddBrandAlert = false
    @State private var newBrandName = ""
    let addNewBrandOption = "+ Add ..."
    
    // PHOTO
    @State private var selectedColorUI: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showCamera = false
    
    // BACKGROUND REMOVAL
    @State private var isProcessingImage = false
    
    // GALLERIA
    @State private var showPhotoLibrary = false
    @State private var pickerItem: PhotosPickerItem? = nil
    
    @State private var isKeyboardVisible = false
    
    @Environment(ClosetManager.self) private var manager
    @Environment(\.dismiss) var dismiss
    
    let uiColors: [String: Color] = [
        "WHITE": .white, "LIGHT GRAY": Color(white: 0.8), "GRAY": .gray, "DARK GRAY": Color(white: 0.2), "BLACK": .black,
        "RED": .red, "MAROON": Color(red: 0.5, green: 0, blue: 0), "ORANGE": .orange, "BEIGE": Color(red: 0.96, green: 0.96, blue: 0.86), "YELLOW": .yellow,
        "GREEN": .green, "OLIVE": Color(red: 0.5, green: 0.5, blue: 0), "BLUE": .blue, "NAVY": Color(red: 0, green: 0, blue: 0.5), "PURPLE": .purple,
        "PINK": .pink, "BROWN": .brown, "CYAN": .cyan, "TEAL": Color(red: 0, green: 0.5, blue: 0.5), "MAGENTA": Color(red: 1, green: 0, blue: 1)
    ]
    
    let columns = [GridItem(.adaptive(minimum: 50))]
    
    var body: some View {
        NavigationStack {
            Form {
                nameSection
                photoSection
                categorySection
                styleSection
                colorSection
                brandSection
                seasonSection // Sezione stagioni aggiornata
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(itemToEdit == nil ? "Add an Item" : "Modify Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { saveCloth() }) {
                        Text(itemToEdit == nil ? "Done" : "Done")
                            .fontWeight(.bold)
                    }
                    // Controllo di validazione: nome, colore e almeno 1 stagione se non è "All Seasons"
                    .disabled(name.isEmpty || selectedColorUI.isEmpty || isProcessingImage || (!isAllSeasons && selectedSeasons.isEmpty))
                }
            }
            .alert("New Brand", isPresented: $showingAddBrandAlert) {
                TextField("Name Brand", text: $newBrandName)
                Button("Cancel", role: .cancel) {
                    selectedBrand = previousBrand
                    newBrandName = ""
                }
                Button("Add") {
                    let cleanName = newBrandName.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
                    if !cleanName.isEmpty {
                        manager.addNewBrand(cleanName)
                        selectedBrand = cleanName
                        previousBrand = cleanName
                    } else {
                        selectedBrand = previousBrand
                    }
                    newBrandName = ""
                }
            } message: {
                Text("Insert the new brand...")
            }
        }
        .gesture(
            DragGesture().onEnded { value in
                if abs(value.translation.width) > 30 {
                    if isKeyboardVisible { hideKeyboard() } else { dismiss() }
                }
            }
        )
        .onReceive(Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification).map { _ in true },
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification).map { _ in false }
        )) { isVisible in
            self.isKeyboardVisible = isVisible
        }
        .onChange(of: pickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run { processBackgroundRemoval(for: uiImage) }
                }
            }
        }
        .onAppear { loadExistingItemData() }
    }
    
    // MARK: - SOTTO-VISTE ESTRATTE
    
    private var nameSection: some View {
        Section(header: Text("NAME")) {
            TextField("Example: linen shirt", text: $name)
        }
    }
    
    private var photoSection: some View {
        Section {
            Menu {
                Button(action: { hideKeyboard(); showCamera = true }) { Label("Take a picture", systemImage: "camera") }
                Button(action: { showPhotoLibrary = true }) { Label("Choose from the gallery", systemImage: "photo.on.rectangle") }
                if selectedImage != nil {
                    Button(role: .destructive) {
                        withAnimation { selectedImage = nil; pickerItem = nil }
                    } label: { Label("Delete picture", systemImage: "trash") }
                }
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                    Text(selectedImage == nil ? "Add a picture" : "Change picture")
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down").font(.caption).foregroundColor(.gray)
                }
                .foregroundColor(.primary)
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker(image: Binding(
                    get: { selectedImage },
                    set: { newImage in if let img = newImage { processBackgroundRemoval(for: img) } }
                )).ignoresSafeArea()
            }
            .photosPicker(isPresented: $showPhotoLibrary, selection: $pickerItem, matching: .images)
            
            if let image = selectedImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        .clipped()
                        .listRowInsets(EdgeInsets())
                    
                    if isProcessingImage {
                        Color.white.opacity(0.7)
                        VStack(spacing: 10) {
                            ProgressView()
                            Text("Removing background...").font(.caption).bold()
                        }
                    }
                }
            }
        }
    }
    
    private var categorySection: some View {
        Section(header: Text("CATEGORY")) {
            Picker("Position", selection: $selectedPosition) {
                ForEach(Position.allCases) { position in Text(position.rawValue).tag(position) }
            }
            .onChange(of: selectedPosition) { _, newPosition in
                if let firstValidType = ClothingType.allCases.first(where: { $0.possiblePositions.contains(newPosition) }) {
                    selectedType = firstValidType
                }
            }
            
            Picker("Type", selection: $selectedType) {
                let tipiFiltrati = ClothingType.allCases.filter { $0.possiblePositions.contains(selectedPosition) }
                ForEach(tipiFiltrati) { type in Text(type.rawValue).tag(type) }
            }
        }
    }
    
    private var styleSection: some View {
        Section(header: Text("STYLE")) {
            Picker("Select a style", selection: $selectedStyle) {
                ForEach(Style.allCases) { style in Text(style.rawValue).tag(style) }
            }
        }
    }
    
    private var colorSection: some View {
        Section(header: Text("COLOR: \(selectedColorUI)")) {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(Array(uiColors.keys).sorted(), id: \.self) { colorName in
                    ZStack {
                        Circle().fill(uiColors[colorName]!).frame(width: 44, height: 44).overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        if selectedColorUI == colorName {
                            Image(systemName: "checkmark").foregroundColor(isColorDark(colorName) ? .white : .black).font(.system(size: 14, weight: .bold))
                        }
                    }
                    .onTapGesture {
                        hideKeyboard()
                        self.selectedColorUI = colorName.uppercased()
                    }
                }
            }
            .padding(.vertical, 10)
        }
    }
    
    private var brandSection: some View {
        Section(header: Text("BRAND")) {
            Picker("Select a brand", selection: $selectedBrand) {
                ForEach(manager.brands, id: \.self) { Text($0).tag($0) }
                Divider()
                Text(addNewBrandOption).tag(addNewBrandOption)
            }
            .onChange(of: selectedBrand) { _, newValue in
                if newValue == addNewBrandOption { showingAddBrandAlert = true } else { previousBrand = newValue }
            }
        }
    }
    
    // ⭐️ NUOVA SEZIONE STAGIONI
    private var seasonSection: some View {
        Section(header: Text("SEASON")) {
            // Pulsante All Seasons
            Toggle(isOn: $isAllSeasons) {
                Text("All Seasons")
                    .fontWeight(.medium)
            }
            .tint(.black)
            .onChange(of: isAllSeasons) { _, newValue in
                if newValue {
                    // Se attiviamo All Seasons, cancelliamo le selezioni singole
                    selectedSeasons.removeAll()
                }
            }
            
            // Griglia con le 4 stagioni base (Scompare o si disabilita se All Seasons è attivo)
            if !isAllSeasons {
                let baseSeasons: [Season] = [.winter, .spring, .summer, .fall]
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(baseSeasons, id: \.self) { season in
                        Button(action: {
                            if selectedSeasons.contains(season) {
                                selectedSeasons.remove(season)
                            } else {
                                selectedSeasons.insert(season)
                            }
                        }) {
                            Text(season.rawValue)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(selectedSeasons.contains(season) ? Color.black : Color.gray.opacity(0.1))
                                .foregroundColor(selectedSeasons.contains(season) ? .white : .primary)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 5)
            }
        }
    }

    // MARK: - FUNZIONI DI LOGICA
    private func loadExistingItemData() {
        if let cloth = itemToEdit {
            name = cloth.name
            selectedPosition = cloth.position
            selectedType = cloth.type
            selectedStyle = cloth.style.first ?? .casual
            selectedBrand = cloth.brand
            previousBrand = cloth.brand
            if let firstColor = cloth.coloreIndumentoRicerca.first {
                selectedColorUI = firstColor.rawValue.uppercased()
            }
            selectedImage = UIImage(data: cloth.image)
            
            // CARICA LE STAGIONI ESISTENTI
            if cloth.season.contains(.allSeasons) {
                isAllSeasons = true
                selectedSeasons.removeAll()
            } else {
                isAllSeasons = false
                selectedSeasons = Set(cloth.season)
            }
        }
    }
    
    private func processBackgroundRemoval(for inputImage: UIImage) {
        self.selectedImage = inputImage
        self.isProcessingImage = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let ciImage = CIImage(image: inputImage)?.oriented(forExifOrientation: Int32(CGImagePropertyOrientation(inputImage.imageOrientation).rawValue)) else {
                updateImageOnMainThread(inputImage); return
            }
            
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
            let request = VNGenerateForegroundInstanceMaskRequest()
            
            do {
                try handler.perform([request])
                guard let result = request.results?.first else { updateImageOnMainThread(inputImage); return }
                let maskBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
                if let output = applyMask(mask: maskBuffer, to: ciImage) {
                    updateImageOnMainThread(output)
                } else { updateImageOnMainThread(inputImage) }
            } catch { updateImageOnMainThread(inputImage) }
        }
    }
    
    private func updateImageOnMainThread(_ image: UIImage) {
        DispatchQueue.main.async { withAnimation { self.selectedImage = image; self.isProcessingImage = false } }
    }
    
    private func applyMask(mask: CVPixelBuffer, to image: CIImage) -> UIImage? {
        let ciMask = CIImage(cvPixelBuffer: mask)
        let filter = CIFilter.maskToAlpha()
        filter.inputImage = ciMask
        guard let alphaMask = filter.outputImage else { return nil }
        
        let blendFilter = CIFilter.sourceAtopCompositing()
        blendFilter.inputImage = image
        blendFilter.backgroundImage = alphaMask
        
        if let cgImage = CIContext().createCGImage(blendFilter.outputImage ?? image, from: image.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func isColorDark(_ colorName: String) -> Bool {
        let darkColors = ["BLACK", "NAVY", "DARK GRAY", "PURPLE", "MAROON", "BROWN", "MAGENTA", "TEAL", "OLIVE"]
        return darkColors.contains(colorName)
    }

    func saveCloth() {
        let finalImageData: Data
        if let uiImage = selectedImage, let data = uiImage.pngData() {
            finalImageData = data
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 100)
            let placeholder = UIImage(systemName: "tshirt.fill", withConfiguration: config)?.withTintColor(.systemGray6)
            finalImageData = placeholder?.pngData() ?? Data()
        }

        let finalColor: coloreIndumento
        switch selectedColorUI {
            case "WHITE": finalColor = .white
            case "LIGHT GRAY": finalColor = .lightGray
            case "GRAY": finalColor = .gray
            case "DARK GRAY": finalColor = .darkGray
            case "BLACK": finalColor = .black
            case "BEIGE": finalColor = .beige
            case "BROWN": finalColor = .brown
            case "RED": finalColor = .red
            case "MAROON": finalColor = .maroon
            case "ORANGE": finalColor = .orange
            case "YELLOW": finalColor = .yellow
            case "GREEN": finalColor = .green
            case "OLIVE": finalColor = .olive
            case "TEAL": finalColor = .teal
            case "CYAN": finalColor = .cyan
            case "BLUE": finalColor = .blue
            case "NAVY": finalColor = .navy
            case "PURPLE": finalColor = .purple
            case "MAGENTA": finalColor = .magenta
            case "PINK": finalColor = .pink
            default: finalColor = .black
        }

        // SALVATAGGIO STAGIONI
        let finalSeasons: [Season] = isAllSeasons ? [.allSeasons] : Array(selectedSeasons)

        if let cloth = itemToEdit {
            manager.updateItem(id: cloth.id, image: finalImageData, name: name, position: selectedPosition, type: selectedType, season: finalSeasons, coloreIndumento: [finalColor], style: [selectedStyle], brand: selectedBrand)
        } else {
            manager.addItem(image: finalImageData, name: name, position: selectedPosition, type: selectedType, season: finalSeasons, coloreIndumento: [finalColor], style: [selectedStyle], brand: selectedBrand)
        }
        dismiss()
    }
}

// CameraPicker & Extension
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage { parent.image = uiImage }
            parent.dismiss()
        }
    }
}

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
