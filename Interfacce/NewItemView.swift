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
    @State private var brand: String = ""
    
    // Usiamo direttamente i tuoi Enum come stato iniziale!
    @State private var selectedPosition: Position = .top
    @State private var selectedType: ClothingType = .tShirt
    @State private var selectedSeason: Season = .summer
    @State private var selectedStyle: String = "Casual"
    
    // Gestione Colore (usiamo la stringa maiuscola per l'interfaccia visiva)
    @State private var selectedColorUI: String = ""
    
    // Gestione Foto
    @State private var selectedImage: UIImage? = nil
    @State private var showCamera = false
    
    @Environment(ClosetManager.self) private var manager
    @Environment(\.dismiss) var dismiss
    
    let styles = ["Casual", "Elegante", "Sportivo", "Streetwear"]
    
    // Colori visivi per l'interfaccia utente (Griglia)
    let uiColors: [String: Color] = [
        "WHITE": .white, "GREY": .gray, "BLACK": .black,
        "RED": .red, "BURGUNDY": Color(red: 0.5, green: 0, blue: 0),
        "PINK": .pink, "YELLOW": .yellow,
        "GREEN": .green, "BLUE": .blue, "NAVY": Color(red: 0, green: 0, blue: 0.5),
        "BROWN": .brown, "BEIGE": Color(red: 0.96, green: 0.96, blue: 0.86)
    ]
    let columns = [GridItem(.adaptive(minimum: 50))]

    var body: some View {
        NavigationStack {
            Form {
                // 1. Nome
                Section(header: Text("NOME")) {
                    TextField("Esempio: Camicia di lino", text: $description)
                }
                
                // 2. Add Photo (OPZIONALE)
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
                    // ORA SI APRE A TUTTO SCHERMO
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
                
                // 3. Posizione e Tipo (DIPENDENTI)
                Section(header: Text("CATEGORIA")) {
                    // Selezione MACRO
                    Picker("Posizione", selection: $selectedPosition) {
                        ForEach(Position.allCases) { position in
                            Text(position.rawValue).tag(position)
                        }
                    }
                    // Quando la posizione cambia, forziamo il reset del tipo
                    .onChange(of: selectedPosition) { newPosition in
                        // Cerca il primo tipo valido per questa nuova posizione e selezionalo
                        if let firstValidType = ClothingType.allCases.first(where: { $0.possiblePositions.contains(newPosition) }) {
                            selectedType = firstValidType
                        }
                    }
                    
                    // Selezione MICRO (Filtrata dinamicamente)
                    Picker("Tipo", selection: $selectedType) {
                        // Filtriamo i tipi che appartengono alla Position selezionata
                        let tipiFiltrati = ClothingType.allCases.filter { type in
                            type.possiblePositions.contains(selectedPosition)
                        }
                        
                        ForEach(tipiFiltrati) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                // 4. Style
                Section(header: Text("STYLE")) {
                    Picker("Seleziona", selection: $selectedStyle) {
                        ForEach(styles, id: \.self) { Text($0) }
                    }
                }
                
                // 5. Colore
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
                
                // 6. Brand
                Section(header: Text("BRAND")) {
                    TextField("Esempio: Nike, Zara...", text: $brand)
                }
                
                // 7. Season
                Section(header: Text("SEASON")) {
                    Picker("Stagione", selection: $selectedSeason) {
                        // Usa l'Enum Season reale!
                        ForEach(Season.allCases, id: \.self) { season in
                            Text(season.rawValue).tag(season)
                        }
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
                            .background(description.isEmpty || selectedColorUI.isEmpty ? Color.gray : Color.black)
                            .cornerRadius(10)
                    }
                    .listRowInsets(EdgeInsets())
                    .buttonStyle(PlainButtonStyle())
                    .disabled(description.isEmpty || selectedColorUI.isEmpty)
                }
            }
            .navigationTitle("Aggiungi Capo")
            .navigationBarItems(leading: Button("Annulla") { dismiss() })
        }
    }
    
    // MARK: - Helper Functions
    
    func isColorDark(_ colorName: String) -> Bool {
        let darkColors = ["BLACK", "NAVY", "BURGUNDY", "BROWN"]
        return darkColors.contains(colorName)
    }
    
    func saveCloth() {
        // 1. Gestione Immagine
        let finalImageData: Data
        if let uiImage = selectedImage, let data = uiImage.jpegData(compressionQuality: 0.7) {
            finalImageData = data
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 100)
            let placeholder = UIImage(systemName: "tshirt.fill", withConfiguration: config)?.withTintColor(.systemGray6)
            finalImageData = placeholder?.jpegData(compressionQuality: 0.1) ?? Data()
        }
        
        // 2. MAPPING COLORE (Dalla UI String al tuo Enum coloreIndumento)
        let finalColor: coloreIndumento
        switch selectedColorUI {
        case "WHITE": finalColor = .white
        case "BLACK": finalColor = .black
        case "GREY": finalColor = .grey
        case "RED": finalColor = .red
        case "BLUE": finalColor = .blue
        case "NAVY": finalColor = .navy
        case "GREEN": finalColor = .green
        case "PINK": finalColor = .pink
        case "BURGUNDY": finalColor = .burgundy
        case "YELLOW": finalColor = .yellow
        case "BROWN": finalColor = .brown
        case "BEIGE": finalColor = .beige
        default: finalColor = .black
        }

        // 3. Chiamata al Manager
        // Passiamo direttamente gli @State (che ora sono già i tuoi Enum!)
        manager.addItem(
            image: finalImageData,
            position: selectedPosition,
            type: selectedType,
            season: [selectedSeason],
            coloreIndumento: [finalColor],
            style: [selectedStyle],
            brand: brand,
            description: description
        )
        
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
