import SwiftUI
import UIKit

struct EditOutfitView: View {
    // Access to app logic
    @Environment(ClosetManager.self) var closetManager
    // System variable to close the modal
    @Environment(\.dismiss) var dismiss
    
    // The ID of the outfit being edited
    let outfitId: UUID
    
    // Internal state variables for temporary editing
    @State private var outfitName: String = ""
    @State private var selectedItems: [Cloth] = []
    
    // Controls if the user requested suggestions
    @State private var isMatchingEnabled: Bool = false
    
    // --- 1. FILTER STATE VARIABLES ---
    @State private var selectedPosition: Position = .top
    @State private var selectedType: ClothingType? = nil
    @State private var selectedSeason: Season? = nil
    @State private var selectedStyle: Style? = nil
    
    // --- 2. FILTER LOGIC (Identical to CreateOutfitView) ---
    private var filteredInventory: [Cloth] {
        
        // ⚡️ OPTIMIZATION: Create a Set of IDs.
        // Searching inside a Set is instantaneous, preventing UI lag.
        let selectedItemIDs = Set(selectedItems.map { $0.id })
        
        return closetManager.inventory.filter { item in
            
            // 1. Exclude if already selected
            let isNotSelected = !selectedItemIDs.contains(item.id)
                
            // 2. Macro-Position Filter (e.g., Tops)
            let matchesPosition = item.type.possiblePositions.contains(selectedPosition)
            
            // 3. Micro-Type Filter (e.g., T-shirts) - Only if selected
            let matchesType = selectedType == nil || item.type == selectedType
            
            // 4. Season Filter (item.season is [Season])
            let matchesSeason = selectedSeason == nil || item.season.contains(selectedSeason!)
                
            // 5. Style Filter (updated with Style enum)
            let matchesStyle = selectedStyle == nil || item.style.contains(selectedStyle!)
                
            return isNotSelected && matchesPosition && matchesType && matchesSeason && matchesStyle
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    
                    // 1. OUTFIT NAME
                    VStack(alignment: .leading) {
                        Text("Outfit Name")
                            .font(.headline)
                        TextField("e.g. Office, Night Out...", text: $outfitName)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)
                    
                    // 2. SELECTED ITEMS (Shown only if not empty)
                    if !selectedItems.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Outfit in progress (\(selectedItems.count))")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(selectedItems) { item in
                                        // Use ItemThumbnail component for removal
                                        ItemThumbnail(cloth: item, actionIcon: "minus.circle.fill") {
                                            withAnimation {
                                                selectedItems.removeAll { $0.id == item.id }
                                                if selectedItems.isEmpty {
                                                    isMatchingEnabled = false
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // MAGIC MATCH BUTTON
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isMatchingEnabled.toggle()
                            }
                        }) {
                            Text(isMatchingEnabled ? "Hide Match" : "Magic Match ✨")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.black)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal)
                    }
                    
                    // 3. MAGIC MATCH SUGGESTIONS
                    if isMatchingEnabled && !selectedItems.isEmpty {
                        
                        let suggestions = closetManager.getCascadingSuggestions(for: selectedItems)
                        
                        if !suggestions.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Suggested for this outfit ✨")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(suggestions) { item in
                                            ItemThumbnail(cloth: item, actionIcon: "sparkles") {
                                                withAnimation {
                                                    selectedItems.append(item)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical, 15)
                            .background(Color.yellow.opacity(0.1))
                            .transition(.move(edge: .top).combined(with: .opacity))
                        } else {
                            Text("No perfect match found for this combination.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                        }
                    }
                    
                    Divider().padding(.horizontal)
                    
                    // 4. THE BUILDER (Filters + Dynamic Grid)
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Build your look")
                            .font(.title2).bold().padding(.horizontal)
                        
                        // Filters component
                        OutfitBuilderFilters(
                            selectedPosition: $selectedPosition,
                            selectedType: $selectedType,
                            selectedSeason: $selectedSeason,
                            selectedStyle: $selectedStyle
                        )
                        
                        // Grid with filtered inventory
                        ClosetSelectionGrid(items: filteredInventory) { item in
                            withAnimation { selectedItems.append(item) }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Edit Outfit")
            .navigationBarTitleDisplayMode(.inline)
            
            // 5. LOAD INITIAL DATA
            .onAppear {
                if let outfit = closetManager.outfits.first(where: { $0.id == outfitId }) {
                    outfitName = outfit.outfitName
                    selectedItems = closetManager.items(for: outfit)
                }
            }
            
            // 6. TOOLBAR (Cancel / Save)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let finalName = outfitName.trimmingCharacters(in: .whitespaces).isEmpty ? "Edited Outfit" : outfitName
                        let itemsIds = selectedItems.map { $0.id }
                        closetManager.updateOutfit(id: outfitId, newName: finalName, newItems: itemsIds)
                        dismiss()
                    }
                    .disabled(selectedItems.isEmpty)
                }
            }
        }
    }
}
