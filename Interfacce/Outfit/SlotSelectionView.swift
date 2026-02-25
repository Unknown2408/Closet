//
//  SlotSelectionView.swift
//  Closet
//
//  Created by Federico Busciglio on 25/02/26.
//


import SwiftUI

struct SlotSelectionView: View {
    @Environment(ClosetManager.self) var closetManager
    @Environment(\.dismiss) var dismiss
    
    let position: Position
    
    // Il binding all'array principale dell'outfit
    @Binding var outfitItems: [Cloth]
    
    // Array temporaneo per i capi scelti in questa sessione
    @State private var tempSelectedItems: [Cloth] = []
    
    // Filtri locali della schermata
    @State private var selectedType: ClothingType? = nil
    @State private var selectedSeason: Season? = nil
    @State private var selectedStyle: Style? = nil
    @State private var showFavoritesOnly: Bool = false
    
    @State private var filteredInventory: [Cloth] = []
    
    // 🔥 1. VARIABILE PER I SUGGERIMENTI MAGIC MATCH
    @State private var magicMatchSuggestions: [Cloth] = []
    
    private func applyFilters() {
        // Uniamo i capi già presenti nell'outfit con quelli appena selezionati in questa schermata
        let combinedItems = outfitItems + tempSelectedItems
        let allSelectedIDs = Set(combinedItems.map { $0.id })
        
        // --- CALCOLO DEI SUGGERIMENTI MAGIC MATCH ---
        if !combinedItems.isEmpty {
            // Chiediamo al manager cosa sta bene con i capi già scelti
            let allSuggestions = closetManager.getCascadingSuggestions(for: combinedItems)
            // Filtriamo i suggerimenti per mostrare SOLO quelli della posizione corrente (es. solo Tops)
            magicMatchSuggestions = allSuggestions.filter { item in
                item.type.possiblePositions.contains(position) && !allSelectedIDs.contains(item.id)
            }
        } else {
            magicMatchSuggestions = []
        }
        
        // --- CALCOLO DELLA GRIGLIA NORMALE ---
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
                
                // --- SEZIONE CAPI APPENA SCELTI (Temp) ---
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
                
                // --- 🔥 MAGIC MATCH SUGGESTIONS (Mostrato solo se ci sono suggerimenti per questo slot) ---
                if !magicMatchSuggestions.isEmpty {
                    MagicMatchList(items: magicMatchSuggestions) { item in
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        withAnimation {
                            tempSelectedItems.append(item)
                            applyFilters()
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // --- I FILTRI ---
                OutfitBuilderFilters(
                    currentPosition: position,
                    selectedType: $selectedType,
                    selectedSeason: $selectedSeason,
                    selectedStyle: $selectedStyle,
                    showFavoritesOnly: $showFavoritesOnly
                )
                .padding(.top, tempSelectedItems.isEmpty ? 15 : 0)
                
                Divider().padding(.horizontal)
                
                // --- LA GRIGLIA DELL'ARMADIO ---
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
                    Button("Cancel") { dismiss() }
                    .foregroundStyle(.red)
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