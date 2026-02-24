import SwiftUI
import UIKit

struct EditOutfitView: View {
    // Accesso al cervello dell'app
    @Environment(ClosetManager.self) var closetManager
    // Variabile di sistema per chiudere la modale
    @Environment(\.dismiss) var dismiss
    
    // L'ID dell'outfit che stiamo modificando
    let outfitId: UUID
    
    // Variabili di stato interne per la modifica temporanea
    @State private var outfitName: String = ""
    @State private var selectedItems: [Cloth] = []
    
    // Controlla se l'utente ha richiesto i suggerimenti
    @State private var isMatchingEnabled: Bool = false
    
    // --- 1. NUOVE VARIABILI DI STATO PER I FILTRI ---
    @State private var selectedPosition: Position = .top
    @State private var selectedType: ClothingType? = nil
    @State private var selectedSeason: Season? = nil
    @State private var selectedStyle: Style? = nil
    
    // --- 2. LOGICA DI FILTRAGGIO (Identica a CreateOutfitView) ---
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
                    
                    // 1. NOME OUTFIT
                    VStack(alignment: .leading) {
                        Text("Nome Outfit")
                            .font(.headline)
                        TextField("Es. Ufficio, Uscita Serale...", text: $outfitName)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)
                    
                    // 2. CAPI SELEZIONATI (Si mostra solo se c'è qualcosa)
                    if !selectedItems.isEmpty {
                        VStack(alignment: .leading) {
                            Text("L'outfit in costruzione (\(selectedItems.count))")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(selectedItems) { item in
                                        // Usa il componente ItemThumbnail per rimuovere
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
                        
                        // IL PULSANTE "MATCH"
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isMatchingEnabled.toggle()
                            }
                        }) {
                            Text(isMatchingEnabled ? "Nascondi Match" : "Match")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.black)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal)
                    }
                    
                    // 3. MAGIA: SUGGERIMENTI DI MATCHING A CASCATA
                    if isMatchingEnabled && !selectedItems.isEmpty {
                        
                        let suggestions = closetManager.getCascadingSuggestions(for: selectedItems)
                        
                        if !suggestions.isEmpty {
                            VStack(alignment: .leading) {
                                Text("Consigliati per questo outfit ✨")
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
                            Text("Nessun capo perfetto trovato per questo abbinamento.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                                .padding(.vertical, 10)
                        }
                    }
                    
                    Divider().padding(.horizontal)
                    
                    // 4. THE BUILDER (Filtri + Griglia Dinamica)
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Aggiungi capi")
                            .font(.title2).bold().padding(.horizontal)
                        
                        // Inseriamo il componente filtri
                        OutfitBuilderFilters(
                            selectedPosition: $selectedPosition,
                            selectedType: $selectedType,
                            selectedSeason: $selectedSeason,
                            selectedStyle: $selectedStyle
                        )
                        
                        // Inseriamo la griglia con l'inventario filtrato
                        ClosetSelectionGrid(items: filteredInventory) { item in
                            withAnimation { selectedItems.append(item) }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Modifica Outfit")
            .navigationBarTitleDisplayMode(.inline)
            
            // 5. CARICAMENTO DATI INIZIALI
            .onAppear {
                if let outfit = closetManager.outfits.first(where: { $0.id == outfitId }) {
                    outfitName = outfit.outfitName
                    selectedItems = closetManager.items(for: outfit)
                }
            }
            
            // 6. TOOLBAR (Annulla / Salva)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        let finalName = outfitName.trimmingCharacters(in: .whitespaces).isEmpty ? "Outfit Modificato" : outfitName
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
