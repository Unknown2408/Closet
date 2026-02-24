import SwiftUI

struct CreateOutfitView: View {
    @Environment(ClosetManager.self) var closetManager
    @Environment(\.dismiss) var dismiss
    
    // --- OUTFIT DATA ---
    @State private var outfitName: String = ""
    @State private var selectedItems: [Cloth] = []
    @State private var isMatchingEnabled: Bool = false
    
    // --- FILTER STATE ---
    @State private var selectedPosition: Position = .top
    @State private var selectedType: ClothingType? = nil
    @State private var selectedSeason: Season? = nil
    
    // Usa il nuovo enum Style al posto della stringa
    @State private var selectedStyle: Style? = nil
    
    // --- FILTER LOGIC (Computed Property) ---
        private var filteredInventory: [Cloth] {
            
            // ⚡️ OTTIMIZZAZIONE: Creiamo un Set di ID.
            // La ricerca dentro un Set è istantanea, evitando che l'app "scatti" quando hai tanti vestiti!
            let selectedItemIDs = Set(selectedItems.map { $0.id })
            
            return closetManager.inventory.filter { item in
                
                // 1. Escludi se già selezionato (ora è velocissimo)
                let isNotSelected = !selectedItemIDs.contains(item.id)
                
                // 2. Filtro Macro-Posizione (es. Tops)
                let matchesPosition = item.type.possiblePositions.contains(selectedPosition)
                
                // 3. Filtro Micro-Tipo (es. T-shirts) - Solo se selezionato
                let matchesType = selectedType == nil || item.type == selectedType
                
                // 4. Filtro Stagione (item.season è [Season])
                let matchesSeason = selectedSeason == nil || item.season.contains(selectedSeason!)
                
                // 5. Filtro Stile (aggiornato con l'enum Style)
                let matchesStyle = selectedStyle == nil || item.style.contains(selectedStyle!)
                
                return isNotSelected && matchesPosition && matchesType && matchesSeason && matchesStyle
            }
        }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // 1. Name & Selected Items Header
                    Group {
                        OutfitNameSection(outfitName: $outfitName)
                        SelectedItemsHeader(selectedItems: $selectedItems, isMatchingEnabled: $isMatchingEnabled)
                    }
                    
                    // 2. Magic Match Suggestions
                    if isMatchingEnabled && !selectedItems.isEmpty {
                        MagicMatchList(items: closetManager.getCascadingSuggestions(for: selectedItems)) { item in
                            withAnimation { selectedItems.append(item) }
                        }
                    }
                    
                    Divider().padding(.horizontal)
                    
                    // 3. The Builder (Filters + Grid)
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Build your look")
                            .font(.title2).bold().padding(.horizontal)
                        
                        // Passiamo tutti i binding ai filtri (rimosso l'array "styles")
                        OutfitBuilderFilters(
                            selectedPosition: $selectedPosition,
                            selectedType: $selectedType,
                            selectedSeason: $selectedSeason,
                            selectedStyle: $selectedStyle
                        )
                        
                        // Griglia dell'armadio filtrata
                        ClosetSelectionGrid(items: filteredInventory) { item in
                            withAnimation { selectedItems.append(item) }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("New Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let name = outfitName.isEmpty ? "New Outfit" : outfitName
                        closetManager.addOutfit(name: name, items: selectedItems.map { $0.id })
                        dismiss()
                    }
                    .disabled(selectedItems.isEmpty)
                }
            }
        }
    }
}
