import SwiftUI

struct SlotSelectionView: View {
    @Environment(ClosetManager.self) var closetManager
    @Environment(\.dismiss) var dismiss
    
    let position: Position
    @Binding var outfitItems: [Cloth]
    
    @State private var tempSelectedItems: [Cloth] = []
    @State private var selectedType: ClothingType? = nil
    @State private var selectedSeason: Season? = nil
    @State private var selectedStyle: Style? = nil
    @State private var showFavoritesOnly: Bool = false
    @State private var filteredInventory: [Cloth] = []
    @State private var magicMatchSuggestions: [Cloth] = []
    
    private func applyFilters() {
        let combinedItems = outfitItems + tempSelectedItems
        let allSelectedIDs = Set(combinedItems.map { $0.id })
        
        // --- 🔥 LOGICA SUGGERIMENTI CORRETTA ---
        // Suggeriamo solo se c'è già ALMENO un capo nell'outfit principale.
        // Se outfitItems è vuoto, significa che l'utente sta scegliendo i primi pezzi,
        // quindi non mostriamo suggerimenti di matching.
        if !outfitItems.isEmpty {
            let allSuggestions = closetManager.getCascadingSuggestions(for: combinedItems)
            magicMatchSuggestions = allSuggestions.filter { item in
                item.type.possiblePositions.contains(position) && !allSelectedIDs.contains(item.id)
            }
        } else {
            // Se l'outfit è ancora totalmente vuoto, i suggerimenti rimangono nascosti
            magicMatchSuggestions = []
        }
        
        // --- FILTRO GRIGLIA NORMALE ---
        filteredInventory = closetManager.inventory.filter { item in
            let matchesPosition = item.type.possiblePositions.contains(position)
            let isNotSelected = !allSelectedIDs.contains(item.id)
            let matchesType = selectedType == nil || item.type == selectedType
            let matchesSeason = selectedSeason == nil || item.season.contains(selectedSeason!)
            let matchesStyle = selectedStyle == nil || item.style.contains(selectedStyle!)
            let matchesFavorites = !showFavoritesOnly || item.favourite
            
            return matchesPosition && isNotSelected && matchesType && matchesSeason && matchesStyle && matchesFavorites
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                if !tempSelectedItems.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Selected (\(tempSelectedItems.count))")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(tempSelectedItems) { item in
                                    ItemThumbnail(cloth: item, actionIcon: "minus.circle.fill") {
                                        withAnimation {
                                            tempSelectedItems.removeAll { $0.id == item.id }
                                            applyFilters()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                }
                
                if !magicMatchSuggestions.isEmpty {
                    MagicMatchList(items: magicMatchSuggestions) { item in
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        withAnimation {
                            tempSelectedItems.append(item)
                            applyFilters()
                        }
                    }
                }
                
                OutfitBuilderFilters(
                    currentPosition: position,
                    selectedType: $selectedType,
                    selectedSeason: $selectedSeason,
                    selectedStyle: $selectedStyle,
                    showFavoritesOnly: $showFavoritesOnly
                )
                .padding(.top, tempSelectedItems.isEmpty ? 15 : 0)
                
                Divider().padding(.horizontal)
                
                ScrollView {
                    ClosetSelectionGrid(items: filteredInventory) { item in
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        withAnimation {
                            tempSelectedItems.append(item)
                            applyFilters()
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Select \(position.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }.foregroundStyle(.red)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        outfitItems.append(contentsOf: tempSelectedItems)
                        dismiss()
                    }
                    .disabled(tempSelectedItems.isEmpty)
                }
            }
            .onAppear { applyFilters() }
            .onChange(of: selectedType) { _, _ in applyFilters() }
            .onChange(of: selectedSeason) { _, _ in applyFilters() }
            .onChange(of: selectedStyle) { _, _ in applyFilters() }
            .onChange(of: showFavoritesOnly) { _, _ in applyFilters() }
        }
    }
}
