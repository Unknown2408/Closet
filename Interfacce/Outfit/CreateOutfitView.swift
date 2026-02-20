import SwiftUI
import UIKit // Sempre per la conversione delle immagini

struct CreateOutfitView: View {
    // Accesso al cervello dell'app
    @Environment(ClosetManager.self) var closetManager
    // Variabile di sistema per chiudere la modale
    @Environment(\.dismiss) var dismiss
    
    // Variabili di stato interne per la creazione temporanea
    @State private var outfitName: String = ""
    @State private var selectedItems: [Cloth] = []
    
    // Controlla se l'utente ha richiesto i suggerimenti
    @State private var isMatchingEnabled: Bool = false
    
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
                                        // Usa il componente ItemThumbnail
                                        ItemThumbnail(cloth: item, actionIcon: "minus.circle.fill") {
                                            selectedItems.removeAll { $0.id == item.id }
                                            if selectedItems.isEmpty {
                                                isMatchingEnabled = false
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
                                                selectedItems.append(item)
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
                    
                    // 4. TUTTO L'ARMADIO
                    VStack(alignment: .leading) {
                        Text("Il tuo armadio")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        let availableItems = closetManager.inventory.filter { item in
                            !selectedItems.contains(where: { $0.id == item.id })
                        }
                        
                        if availableItems.isEmpty {
                            Text("Non hai altri capi disponibili.")
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                ForEach(availableItems) { item in
                                    ItemThumbnail(cloth: item, actionIcon: "plus.circle.fill") {
                                        withAnimation {
                                            selectedItems.append(item)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Nuovo Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        let finalName = outfitName.isEmpty ? "Nuovo Outfit" : outfitName
                        let itemsIds = selectedItems.map { $0.id }
                        closetManager.addOutfit(name: finalName, items: itemsIds)
                        dismiss()
                    }
                    .disabled(selectedItems.isEmpty)
                }
            }
        }
    }
}
