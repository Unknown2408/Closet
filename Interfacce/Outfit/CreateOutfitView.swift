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
    
    // Use the Style enum for filtering
    @State private var selectedStyle: Style? = nil
    
    // --- FILTER LOGIC (Computed Property) ---
    private var filteredInventory: [Cloth] {
        
        // ⚡️ OPTIMIZATION: Create a Set of IDs.
        // Searching inside a Set is instantaneous, preventing UI lag when inventory is large.
        let selectedItemIDs = Set(selectedItems.map { $0.id })
        
        return closetManager.inventory.filter { item in
            
            // 1. Exclude if already selected
            let isNotSelected = !selectedItemIDs.contains(item.id)
            
            // 2. Macro-Position Filter (e.g., Tops)
            let matchesPosition = item.type.possiblePositions.contains(selectedPosition)
            
            // 3. Micro-Type Filter (e.g., T-shirts) - Only if a specific type is selected
            let matchesType = selectedType == nil || item.type == selectedType
            
            // 4. Season Filter (item.season is an array [Season])
            let matchesSeason = selectedSeason == nil || item.season.contains(selectedSeason!)
            
            // 5. Style Filter (using Style enum)
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
