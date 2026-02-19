import SwiftUI

struct NewItemView: View {
    // Recuperiamo il manager dall'ambiente per usare la funzione addItem
    @Environment(ClosetManager.self) private var manager
    @Environment(\.dismiss) var dismiss // Per chiudere la schermata dopo il salvataggio
    
    // STATI LOCALI per i campi del form
    @State private var brand: String = ""
    @State private var description: String = ""
    @State private var selectedPosition: Position = .top
    @State private var selectedType: ClothingType = .tShirt
    @State private var selectedSeasons: Set<Season> = []
    @State private var selectedColor: coloreIndumento = .RED // Default dal tuo enum
    @State private var style: String = "" // Stringa singola che poi trasformiamo in array
    @State private var image: String = "hanger" // Per ora un placeholder
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informazioni Base")) {
                    TextField("Brand", text: $brand)
                    TextField("Descrizione", text: $description)
                    TextField("Stile (es. Casual, Elegante)", text: $style)
                }
                
                Section(header: Text("Categoria")) {
                    Picker("Posizione", selection: $selectedPosition) {
                        ForEach(Position.allCases) { pos in
                            Text(pos.rawValue).tag(pos)
                        }
                    }
                    
                    Picker("Tipo", selection: $selectedType) {
                        ForEach(ClothingType.allCases) { type in
                            // Mostriamo solo i tipi coerenti con la posizione selezionata
                            if type.possiblePositions.contains(selectedPosition) {
                                Text(type.rawValue).tag(type)
                            }
                        }
                    }
                }
                
                Section(header: Text("Stagioni (Seleziona multiple)")) {
                    ForEach(Season.allCases, id: \.self) { season in
                        HStack {
                            Text(season.rawValue)
                            Spacer()
                            if selectedSeasons.contains(season) {
                                Image(systemName: "checkmark").foregroundColor(.black)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedSeasons.contains(season) {
                                selectedSeasons.remove(season)
                            } else {
                                selectedSeasons.insert(season)
                            }
                        }
                    }
                }
                
                Section(header: Text("Colore")) {
                    Picker("Colore principale", selection: $selectedColor) {
                        ForEach(coloreIndumento.allCases, id: \.self) { color in
                            Text(color.rawValue).tag(color)
                        }
                    }
                }
            }
            .navigationTitle("Nuovo Capo")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        salvaNuovoCapo()
                    }
                    .disabled(brand.isEmpty) // Disabilita se non c'è il brand
                }
            }
        }
    }
    
    // Funzione che richiama il tuo manager
    private func salvaNuovoCapo() {
        manager.addItem(
            image: image, // Qui andrà il nome dell'immagine scattata
            position: selectedPosition,
            type: selectedType,
            season: Array(selectedSeasons),
            coloreIndumento: [selectedColor],
            style: [style],
            brand: brand,
            description: description
        )
        dismiss() // Chiude la modale
    }
}

#Preview {
    // Creiamo un'istanza di test
    let mockManager = ClosetManager()
    
    // Aggiungiamo un elemento di prova per vedere se la griglia funziona
    mockManager.addItem(
        image: "LogoApp", // Usa un'immagine che hai negli Assets
        position: .top,
        type: .tShirt,
        season: [.summer],
        coloreIndumento: [.RED],
        style: ["Casual"],
        brand: "Balmain",
        description: "T-shirt di prova"
    )
    
    return HomeView()
        .environment(mockManager)
}
