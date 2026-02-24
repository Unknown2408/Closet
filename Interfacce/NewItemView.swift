import SwiftUI
import UIKit
import Combine
import PhotosUI

struct NewItemView: View {
    var itemToEdit: Cloth? = nil
    
    // MARK: - State Properties
    @State private var name: String = ""
    @State private var selectedPosition: Position = .top
    @State private var selectedType: ClothingType = .tShirt
    @State private var selectedSeason: Season = .summer
    
    // CORREZIONE 1: Uso l'enum Style al posto della String
    @State private var selectedStyle: Style = .casual
    
    @State private var selectedBrand: String = "Unbranded"
    @State private var previousBrand: String = "Unbranded"
    @State private var showingAddBrandAlert = false
    @State private var newBrandName = ""
    let addNewBrandOption = "+ Aggiungi ..."
    
    // PHOTO
    @State private var selectedColorUI: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showCamera = false
    @State private var pickerItem: PhotosPickerItem? = nil
    
    // Stato per monitorare la tastiera
    @State private var isKeyboardVisible = false
    
    @Environment(ClosetManager.self) private var manager
    @Environment(\.dismiss) var dismiss
    
    // CORREZIONE 2: Rimosso let styles = ["Casual", "Elegante", ...] manuale
    
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
                Section(header: Text("NOME")) {
                    TextField("Esempio: Camicia di lino", text: $name)
                }
                
                Section {
                    Button(action: {
                        hideKeyboard()
                        showCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text(selectedImage == nil ? "Scatta Foto (Opzionale)" : "Cambia Foto")
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.primary)
                    }
                    .fullScreenCover(isPresented: $showCamera) {
                        CameraPicker(image: $selectedImage)
                            .ignoresSafeArea()
                    }
                    
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .clipped()
                    }
                }
                
                Section(header: Text("CATEGORIA")) {
                    Picker("Posizione", selection: $selectedPosition) {
                        ForEach(Position.allCases) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    .onChange(of: selectedPosition) { _, newPosition in
                        if let firstValidType = ClothingType.allCases.first(where: { $0.possiblePositions.contains(newPosition) }) {
                            selectedType = firstValidType
                        }
                    }
                    
                    Picker("Tipo", selection: $selectedType) {
                        let tipiFiltrati = ClothingType.allCases.filter { $0.possiblePositions.contains(selectedPosition) }
                        ForEach(tipiFiltrati) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                // CORREZIONE 3: Uso Style.allCases per iterare
                Section(header: Text("STYLE")) {
                    Picker("Seleziona", selection: $selectedStyle) {
                        ForEach(Style.allCases) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                }
                
                colorSection
                
                Section(header: Text("BRAND")) {
                    Picker("Seleziona", selection: $selectedBrand) {
                        ForEach(manager.brands, id: \.self) { Text($0).tag($0) }
                        Divider()
                        Text(addNewBrandOption).tag(addNewBrandOption)
                    }
                    .onChange(of: selectedBrand) { _, newValue in
                        if newValue == addNewBrandOption {
                            showingAddBrandAlert = true
                        } else {
                            previousBrand = newValue
                        }
                    }
                }
                
                Section(header: Text("SEASON")) {
                    Picker("Stagione", selection: $selectedSeason) {
                        ForEach(Season.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Button(action: { saveCloth() }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(name.isEmpty || selectedColorUI.isEmpty ? Color.gray : Color.black)
                            .cornerRadius(10)
                    }
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(PlainButtonStyle())
                    .disabled(name.isEmpty || selectedColorUI.isEmpty)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(itemToEdit == nil ? "Aggiungi Capo" : "Modifica Capo")
            .navigationBarItems(leading: Button("Annulla") { dismiss() })
            .alert("Nuovo Brand", isPresented: $showingAddBrandAlert) {
                TextField("Nome brand", text: $newBrandName)
                Button("Annulla", role: .cancel) {
                    selectedBrand = previousBrand
                    newBrandName = ""
                }
                Button("Aggiungi") {
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
                Text("Inserisci il nome del brand da aggiungere alla lista.")
            }
        }
        // --- GESTURE AD ALTA SENSIBILITÀ (SOGLIA 30) ---
        .gesture(
            DragGesture()
                .onEnded { value in
                    // Se lo spostamento è superiore a 30 (molto sensibile)
                    if abs(value.translation.width) > 30 {
                        if isKeyboardVisible {
                            // Step 1: Chiude la tastiera se aperta
                            hideKeyboard()
                        } else {
                            // Step 2: Chiude la tendina se la tastiera è già chiusa
                            dismiss()
                        }
                    }
                }
        )
        // Listener per lo stato della tastiera
        .onReceive(Publishers.Merge(
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification).map { _ in true },
            NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification).map { _ in false }
        )) { isVisible in
            self.isKeyboardVisible = isVisible
        }
        .onAppear {
            if let cloth = itemToEdit {
                name = cloth.name
                selectedPosition = cloth.position
                selectedType = cloth.type
                selectedSeason = cloth.season.first ?? .summer
                
                // CORREZIONE 4: Fallback su un valore dell'enum, non una stringa
                selectedStyle = cloth.style.first ?? .casual
                
                selectedBrand = cloth.brand
                previousBrand = cloth.brand
                if let firstColor = cloth.coloreIndumentoRicerca.first {
                    selectedColorUI = firstColor.rawValue.uppercased()
                }
                selectedImage = UIImage(data: cloth.image)
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private var colorSection: some View {
        Section(header: Text("COLORE: \(selectedColorUI)")) {
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(Array(uiColors.keys).sorted(), id: \.self) { colorName in
                    ZStack {
                        Circle()
                            .fill(uiColors[colorName]!)
                            .frame(width: 44, height: 44)
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        if selectedColorUI == colorName {
                            Image(systemName: "checkmark")
                                .foregroundColor(isColorDark(colorName) ? .white : .black)
                                .font(.system(size: 14, weight: .bold))
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

    func isColorDark(_ colorName: String) -> Bool {
        let darkColors = ["BLACK", "NAVY", "DARK GRAY", "PURPLE", "MAROON", "BROWN", "MAGENTA", "TEAL", "OLIVE"]
        return darkColors.contains(colorName)
    }

    func saveCloth() {
        let finalImageData: Data
        if let uiImage = selectedImage, let data = uiImage.jpegData(compressionQuality: 0.7) {
            finalImageData = data
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 100)
            let placeholder = UIImage(systemName: "tshirt.fill", withConfiguration: config)?.withTintColor(.systemGray6)
            finalImageData = placeholder?.jpegData(compressionQuality: 0.1) ?? Data()
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

        // CORREZIONE 5: Aggiorna se esiste, crea se non esiste, usando l'enum
        if let cloth = itemToEdit {
            manager.updateItem(
                id: cloth.id,
                image: finalImageData,
                name: name,
                position: selectedPosition,
                type: selectedType,
                season: [selectedSeason],
                coloreIndumento: [finalColor],
                style: [selectedStyle],
                brand: selectedBrand
            )
        } else {
            manager.addItem(
                image: finalImageData,
                name: name,
                position: selectedPosition,
                type: selectedType,
                season: [selectedSeason],
                coloreIndumento: [finalColor],
                style: [selectedStyle],
                brand: selectedBrand
            )
        }
        
        dismiss()
    }
}

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
