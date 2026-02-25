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
    @State private var selectedStyle: Style? = nil
    
    // 🔥 1. NUOVO STATO: Invece di una computed property, usiamo una variabile di stato!
    @State private var filteredInventory: [Cloth] = []
    
    // 🔥 2. LA FUNZIONE CHE FILTRA: La chiamiamo solo quando serve
    private func applyFilters() {
        // ⚡️ OTTIMIZZAZIONE: Creiamo un Set di ID per velocizzare la ricerca
        let selectedItemIDs = Set(selectedItems.map { $0.id })
        
        filteredInventory = closetManager.inventory.filter { item in
            // 1. Esclude se è già selezionato
            let isNotSelected = !selectedItemIDs.contains(item.id)
            
            // 2. Filtro Macro-Posizione (es. Tops)
            let matchesPosition = item.type.possiblePositions.contains(selectedPosition)
            
            // 3. Filtro Micro-Tipo (es. T-shirts)
            let matchesType = selectedType == nil || item.type == selectedType
            
            // 4. Filtro Stagione
            let matchesSeason = selectedSeason == nil || item.season.contains(selectedSeason!)
            
            // 5. Filtro Stile
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
                        
                        // Pass all bindings to the filter component
                        OutfitBuilderFilters(
                            selectedPosition: $selectedPosition,
                            selectedType: $selectedType,
                            selectedSeason: $selectedSeason,
                            selectedStyle: $selectedStyle
                        )
                        
                        // Filtered Closet Selection Grid
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
                        .foregroundStyle(.red) // 🔴 Cancel in rosso
                }
                ToolbarItem(placement: .confirmationAction) {
                    // 🟢 Save diventa Done
                    Button("Done") {
                        let name = outfitName.isEmpty ? "New Outfit" : outfitName
                        closetManager.addOutfit(name: name, items: selectedItems.map { $0.id })
                        dismiss()
                    }
                    .disabled(selectedItems.isEmpty)
                }
            }
            // 🔥 3. AGGIORNIAMO I FILTRI SOLO QUANDO SERVE:
            .onAppear {
                applyFilters() // Primo caricamento
            }
            // Osserviamo i cambiamenti (sintassi iOS 17+)
            .onChange(of: selectedPosition) { _, _ in applyFilters() }
            .onChange(of: selectedType) { _, _ in applyFilters() }
            .onChange(of: selectedSeason) { _, _ in applyFilters() }
            .onChange(of: selectedStyle) { _, _ in applyFilters() }
            .onChange(of: selectedItems.count) { _, _ in applyFilters() } // Aggiorna se aggiungo/rimuovo un capo
        }
    }
}
