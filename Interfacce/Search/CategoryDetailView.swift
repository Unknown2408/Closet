import SwiftUI

struct CategoryDetailView: View {
    @Environment(ClosetManager.self) var manager
    
    // Il tipo di vestito che stiamo visualizzando (es. T-Shirt)
    let selectedType: ClothingType
    
    // MARK: - Stati per i Filtri
    @State private var selectedSeason: Season? = nil
    @State private var selectedStyle: Style? = nil
    @State private var selectedBrand: String? = nil
    
    // Stato per il colore (salviamo la stringa es. "Red")
    @State private var selectedColorName: String? = nil
    
    // Configurazione Griglia
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    // MARK: - Dati Colori (Nomi Aggiornati)
    let uiColors: [String: Color] = [
        "White": .white,
        "Light Gray": Color(white: 0.8),
        "Gray": .gray,
        "Dark Gray": Color(white: 0.2),
        "Black": .black,
        "Red": .red,
        "Maroon": Color(red: 0.5, green: 0, blue: 0),
        "Orange": .orange,
        "Beige": Color(red: 0.96, green: 0.96, blue: 0.86),
        "Yellow": .yellow,
        "Green": .green,
        "Olive": Color(red: 0.5, green: 0.5, blue: 0),
        "Blue": .blue,
        "Navy": Color(red: 0, green: 0, blue: 0.5),
        "Purple": .purple,
        "Pink": .pink,
        "Brown": .brown,
        "Cyan": .cyan,
        "Teal": Color(red: 0, green: 0.5, blue: 0.5),
        "Magenta": Color(red: 1, green: 0, blue: 1)
    ]
    
    // MARK: - Logica di Filtraggio Combinata
    var filteredClothes: [Cloth] {
        return manager.inventory.filter { item in
            // 1. Filtro Base
            let typeMatch = item.type == selectedType
            
            // 2. Filtri Opzionali
            let seasonMatch = selectedSeason == nil || item.season.contains(selectedSeason!)
            let styleMatch = selectedStyle == nil || item.style.contains(selectedStyle!)
            let brandMatch = selectedBrand == nil || item.brand == selectedBrand
            
            // 3. Filtro Colore
            let colorMatch: Bool
            if let colorName = selectedColorName {
                let requiredEnum = getColorEnum(from: colorName)
                colorMatch = item.coloreIndumentoRicerca.contains(requiredEnum)
            } else {
                colorMatch = true
            }
            
            return typeMatch && seasonMatch && styleMatch && brandMatch && colorMatch
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - BARRA DEI FILTRI (Isolette)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    
                    // Tasto Reset
                    if selectedSeason != nil || selectedStyle != nil || selectedBrand != nil || selectedColorName != nil {
                        Button(action: {
                            withAnimation {
                                selectedSeason = nil
                                selectedStyle = nil
                                selectedBrand = nil
                                selectedColorName = nil
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .font(.title3)
                        }
                    }
                    
                    // Filtro STAGIONE
                    Menu {
                        Button("All", action: { selectedSeason = nil })
                        ForEach(Season.allCases, id: \.self) { season in
                            Button(season.rawValue) { selectedSeason = season }
                        }
                    } label: {
                        FilterChipView(
                            title: selectedSeason?.rawValue ?? "Season",
                            isSelected: selectedSeason != nil
                        )
                    }
                    
                    // MARK: - Filtro COLORE
                    Menu {
                        Button("All", action: { selectedColorName = nil })
                        ForEach(Array(uiColors.keys).sorted(), id: \.self) { colorName in
                            Button(action: { selectedColorName = colorName }) {
                                Label {
                                    Text(colorName)
                                } icon: {
                                    // Qui usiamo la funzione helper per creare un'immagine reale
                                    if let color = uiColors[colorName] {
                                        Image(uiImage: createColorImage(color))
                                    }
                                }
                            }
                        }
                    } label: {
                        FilterChipView(
                            title: selectedColorName ?? "Color",
                            isSelected: selectedColorName != nil
                        )
                    }
                    
                    // Filtro STILE
                    Menu {
                        Button("All", action: { selectedStyle = nil })
                        ForEach(Style.allCases, id: \.self) { style in
                            Button(style.rawValue) { selectedStyle = style }
                        }
                    } label: {
                        FilterChipView(
                            title: selectedStyle?.rawValue ?? "Style",
                            isSelected: selectedStyle != nil
                        )
                    }
                    
                    // Filtro BRAND
                    Menu {
                        Button("All", action: { selectedBrand = nil })
                        ForEach(manager.brands, id: \.self) { brand in
                            Button(brand) { selectedBrand = brand }
                        }
                    } label: {
                        FilterChipView(
                            title: selectedBrand ?? "Brand",
                            isSelected: selectedBrand != nil
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .background(Color.white)
            
            Divider()
            
            // MARK: - GRIGLIA CONTENUTO
            ScrollView {
                if filteredClothes.isEmpty {
                    VStack(spacing: 20) {
                        Spacer(minLength: 100)
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No items found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Try to modify the filters or add new items")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredClothes) { cloth in
                            NavigationLink(destination: DetailedView(cloth: cloth)) {
                                ClothCard(cloth: cloth)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(selectedType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Conversione Stringa -> Enum
    private func getColorEnum(from name: String) -> coloreIndumento {
        switch name {
        case "White": return .white
        case "Light Gray": return .lightGray
        case "Gray": return .gray
        case "Dark Gray": return .darkGray
        case "Black": return .black
        case "Beige": return .beige
        case "Brown": return .brown
        case "Red": return .red
        case "Maroon": return .maroon
        case "Orange": return .orange
        case "Yellow": return .yellow
        case "Green": return .green
        case "Olive": return .olive
        case "Teal": return .teal
        case "Cyan": return .cyan
        case "Blue": return .blue
        case "Navy": return .navy
        case "Purple": return .purple
        case "Magenta": return .magenta
        case "Pink": return .pink
        default: return .black
        }
    }
    
    // Funzione per creare un pallino colorato CON BORDO NERO come Immagine reale
    func createColorImage(_ color: Color) -> UIImage {
        // Aumentiamo leggermente la dimensione per ospitare il bordo senza tagliare
        let size = CGSize(width: 22, height: 22)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            // Definiamo un rettangolo leggermente più piccolo dell'immagine totale
            // per assicurarci che il bordo non venga tagliato
            let rect = CGRect(x: 1, y: 1, width: 20, height: 20)
            
            // 1. RIEMPIMENTO (Il colore scelto)
            UIColor(color).setFill()
            cgContext.fillEllipse(in: rect)
            
            // 2. BORDO (Nero e sottile)
            UIColor.black.setStroke() // Colore del bordo
            cgContext.setLineWidth(1.0) // Spessore della linea (1 punto)
            cgContext.strokeEllipse(in: rect) // Disegna il bordo
        }
    }
}
