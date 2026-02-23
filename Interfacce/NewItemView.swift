import SwiftUI
import UIKit

struct NewItemView: View {
    var itemToEdit: Cloth? = nil
    
    // MARK: - State Properties
    @State private var name: String = ""
    
    @State private var selectedPosition: Position = .top
    @State private var selectedType: ClothingType = .tShirt
    @State private var selectedSeason: Season = .summer
    @State private var selectedStyle: String = "Casual"
    
    // BRAND DINAMICO
    @State private var selectedBrand: String = "Unbranded"
    @State private var previousBrand: String = "Unbranded" // Salva la scelta precedente in caso di annullamento
    @State private var showingAddBrandAlert = false
    @State private var newBrandName = ""
    let addNewBrandOption = "+ Aggiungi ..."
    
    @State private var selectedColorUI: String = ""
    
    // FOTO
    @State private var selectedImage: UIImage? = nil
    @State private var showCamera = false
    
    @Environment(ClosetManager.self) private var manager
    @Environment(\.dismiss) var dismiss
    
    let styles = ["Casual", "Elegante", "Sportivo", "Streetwear"]
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
                // 1. NOME
                Section(header: Text("NOME")) {
                    TextField("Esempio: Camicia di lino", text: $name)
                }
                
                // 2. FOTO (Opzionale)
                Section {
                    Button(action: {
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
                
                // 3. CATEGORIA
                Section(header: Text("CATEGORIA")) {
                    Picker("Posizione", selection: $selectedPosition) {
                        ForEach(Position.allCases) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    .onChange(of: selectedPosition) { _, newPosition in
                        // Cerca il primo tipo valido per questa nuova posizione e selezionalo
                        if let firstValidType = ClothingType.allCases.first(where: { $0.possiblePositions.contains(newPosition) }) {
                            selectedType = firstValidType
                        }
                    }
                    
                    Picker("Tipo", selection: $selectedType) {
                        let tipiFiltrati = ClothingType.allCases.filter { type in
                            type.possiblePositions.contains(selectedPosition)
                        }
                        ForEach(tipiFiltrati) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                // 4. STYLE
                Section(header: Text("STYLE")) {
                    Picker("Seleziona", selection: $selectedStyle) {
                        ForEach(styles, id: \.self) { Text($0) }
                    }
                }
                
                // 5. COLORE
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
                                self.selectedColorUI = colorName.uppercased()
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                // 6. BRAND (Unito in un solo Picker)
                Section(header: Text("BRAND")) {
                    Picker("Seleziona", selection: $selectedBrand) {
                        // 1. Mostriamo tutti i brand salvati
                        ForEach(manager.brands, id: \.self) { brandName in
                            Text(brandName).tag(brandName)
                        }
                        
                        Divider() // Crea una linea di separazione visiva carina
                        
                        // 2. Aggiungiamo la voce speciale alla fine
                        Text(addNewBrandOption).tag(addNewBrandOption)
                    }
                    // Intercettiamo il cambio di selezione
                    .onChange(of: selectedBrand) { _, newValue in
                        if newValue == addNewBrandOption {
                            showingAddBrandAlert = true // Apre il popup
                        } else {
                            previousBrand = newValue // Salviamo la scelta valida
                        }
                    }
                }
                
                // 7. SEASON
                Section(header: Text("SEASON")) {
                    Picker("Stagione", selection: $selectedSeason) {
                        ForEach(Season.allCases, id: \.self) { season in
                            Text(season.rawValue).tag(season)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // PULSANTE SALVA
                Section {
                    Button(action: {
                        saveCloth()
                    }) {
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
            .navigationTitle(itemToEdit == nil ? "Aggiungi Capo" : "Modifica Capo")
            .navigationBarItems(leading: Button("Annulla") { dismiss() })
            
            // ALERT: Aggiunta nuovo brand
            .alert("Nuovo Brand", isPresented: $showingAddBrandAlert) {
                TextField("Nome brand", text: $newBrandName)
                
                Button("Annulla", role: .cancel) {
                    // Se annulla, rimettiamo il brand che c'era prima
                    selectedBrand = previousBrand
                    newBrandName = ""
                }
                
                Button("Aggiungi") {
                    let cleanName = newBrandName.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
                    if !cleanName.isEmpty {
                        manager.addNewBrand(cleanName)
                        // Imposta il brand creato come quello selezionato
                        selectedBrand = cleanName
                        previousBrand = cleanName
                    } else {
                        // Se ha lasciato vuoto, torniamo a quello precedente
                        selectedBrand = previousBrand
                    }
                    newBrandName = ""
                }
            } message: {
                Text("Inserisci il nome del brand da aggiungere alla lista.")
            }
        }
        .onAppear {
            if let cloth = itemToEdit {
                name = cloth.name
                selectedPosition = cloth.position
                selectedType = cloth.type
                selectedSeason = cloth.season.first ?? .summer
                selectedStyle = cloth.style.first ?? "Casual"
                selectedBrand = cloth.brand
                previousBrand = cloth.brand
                if let firstColor = cloth.coloreIndumentoRicerca.first {
                    selectedColorUI = firstColor.rawValue.uppercased()
                }
                selectedImage = UIImage(data: cloth.image)
            }
        }
    }
    
    // MARK: - Helper Functions
    
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

        manager.addItem(
            image: finalImageData,
            name : name,
            position: selectedPosition,
            type: selectedType,
            season: [selectedSeason],
            coloreIndumento: [finalColor],
            style: [selectedStyle],
            brand: selectedBrand,
        )
        
        dismiss()
    }
}

// MARK: - Camera Picker
// ... (CameraPicker rimane identico)
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
    }
}
