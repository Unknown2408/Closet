//
//  NewItemView.swift
//  Closet
//
//  Created by Nitharsan on 19/02/26.
//


import SwiftUI
import UIKit

struct NewItemView: View {
    // MARK: - State Properties
    @State private var description: String = ""
    @State private var selectedCategory: String = "T-Shirts"
    @State private var selectedStyle: String = "Casual"
    @State private var selectedColor: String = ""
    @State private var brand: String = ""
    @State private var selectedSeason: String = "Summer"
    @State private var selectedImage: UIImage? = nil
    @State private var showCamera = false
    
    // Accediamo al manager reale (Sostituisci ClosetManager con il tuo se diverso)
    @Environment(ClosetManager.self) private var manager
    @Environment(\.dismiss) var dismiss
    
    let categories = ["T-Shirts", "Shirt", "Pants", "Top", "Gonna", "Footwear", "Outwear"]
    let styles = ["Casual", "Elegante", "Sportivo", "Streetwear"]
    let seasons = ["Spring", "Summer", "Autumn", "Winter"]
    
    let colors: [String: Color] = [
        "WHITE": .white, "LIGHT GRAY": Color(white: 0.8), "GRAY": .gray, "DARK GRAY": Color(white: 0.2), "BLACK": .black,
        "RED": .red, "MAROON": Color(red: 0.5, green: 0, blue: 0), "ORANGE": .orange, "BEIGE": Color(red: 0.96, green: 0.96, blue: 0.86), "YELLOW": .yellow,
        "GREEN": .green, "OLIVE": Color(red: 0.5, green: 0.5, blue: 0), "BLUE": .blue, "NAVY": Color(red: 0, green: 0, blue: 0.5), "PURPLE": .purple,
        "PINK": .pink, "BROWN": .brown, "CYAN": .cyan, "TEAL": Color(red: 0, green: 0.5, blue: 0.5), "MAGENTA": Color(red: 1, green: 0, blue: 1)
    ]
    
    let columns = [GridItem(.adaptive(minimum: 50))]

    var body: some View {
        NavigationStack {
            Form {
                // 1. Nome
                Section(header: Text("NOME")) {
                    TextField("Esempio: Camicia di lino", text: $description)
                }
                
                // 2. Add Photo (ORA OPZIONALE)
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
                    .sheet(isPresented: $showCamera) {
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
                
                // 3. Categoria
                Section(header: Text("CATEGORIA")) {
                    Picker("Seleziona", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                }
                
                // 4. Style
                Section(header: Text("STYLE")) {
                    Picker("Seleziona", selection: $selectedStyle) {
                        ForEach(styles, id: \.self) { Text($0) }
                    }
                }
                
                // 5. Colore
                Section(header: Text("COLORE: \(selectedColor)")) {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(Array(colors.keys).sorted(), id: \.self) { colorName in
                            ZStack {
                                Circle()
                                    .fill(colors[colorName]!)
                                    .frame(width: 44, height: 44)
                                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                                
                                if selectedColor == colorName {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(isColorDark(colorName) ? .white : .black)
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .onTapGesture {
                                self.selectedColor = colorName.uppercased()
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                // 6. Brand
                Section(header: Text("BRAND")) {
                    TextField("Esempio: Nike, Zara...", text: $brand)
                }
                
                // 7. Season
                Section(header: Text("SEASON")) {
                    Picker("Stagione", selection: $selectedSeason) {
                        ForEach(seasons, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }
                
                // Pulsante Salva
                Section {
                    Button(action: {
                        saveCloth()
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(description.isEmpty || selectedColor.isEmpty ? Color.gray : Color.black)
                            .cornerRadius(10)
                    }
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(PlainButtonStyle())
                    // Ora la foto NON è più richiesta per abilitare il tasto
                    .disabled(description.isEmpty || selectedColor.isEmpty)
                }
            }
            .navigationTitle("Aggiungi Indumento")
            .navigationBarItems(leading: Button("Annulla") { dismiss() })
        }
    }
    
    // MARK: - Helper Functions
    
    func isColorDark(_ colorName: String) -> Bool {
        let darkColors = ["BLACK", "NAVY", "DARK GRAY", "PURPLE", "MAROON", "BROWN", "MAGENTA"]
        return darkColors.contains(colorName)
    }
    
    func saveCloth() {
        // 1. Gestione Immagine Opzionale
        let finalImageData: Data
        if let uiImage = selectedImage, let data = uiImage.jpegData(compressionQuality: 0.7) {
            finalImageData = data
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 100)
            let placeholder = UIImage(systemName: "tshirt.fill", withConfiguration: config)?.withTintColor(.systemGray6)
            finalImageData = placeholder?.jpegData(compressionQuality: 0.1) ?? Data()
        }
        
        // 2. MAPPING: Stringhe UI -> Enum del tuo modello
        
        // Categoria
        let position: Position
        let type: ClothingType
        switch selectedCategory {
        case "Pants", "Gonna":
            position = .bottom
            type = (selectedCategory == "Trousers") ? .trousers : .skirt // Cambia .pants/.skirt con i tuoi veri case
        case "Footwear":
            position = .footwear // Cambia con il tuo vero case
            type = .sneakers    // Cambia con il tuo vero case
        default:
            position = .top
            type = .shirt
        }
        
        // Stagione
        let season: Season
        switch selectedSeason {
        case "Spring": season = .spring
        case "Summer": season = .summer
        case "Fall": season = .fall
        case "Winter": season = .winter
        default: season = .summer
        }
        
        // Colore (Assicurati che i case dell'enum corrispondano a quelli che hai creato)
        let colore: coloreIndumento
        switch selectedColor {
        case "WHITE": colore = .white
        case "BLACK": colore = .black
        case "RED": colore = .red
        case "BLUE", "NAVY", "CYAN": colore = .blue // Puoi raggruppare più stringhe nello stesso case!
        case "GREEN", "OLIVE", "TEAL": colore = .green
        case "YELLOW": colore = .yellow
        // Aggiungi gli altri colori qui...
        default: colore = .black // Colore di default se non trova corrispondenza
        }

        // 3. Chiamata al TUO manager.addItem
        // I parametri ora rispettano esattamente la firma della tua funzione!
        manager.addItem(
            image: finalImageData,
            position: position,
            type: type,
            season: [season],
            coloreIndumento: [colore], // Passiamo il colore mappato dentro un array
            style: [selectedStyle],
            brand: brand,
            description: description
        )
        
        // Chiude la schermata e torna alla Home
        dismiss()
    }
}

// MARK: - Camera Picker
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
