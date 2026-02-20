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
                    
                    // 2. CAPI SELEZIONATI (Si mostra solo se c'è qualcosa)
                    if !selectedItems.isEmpty {
                        VStack(alignment: .leading) {
                            Text("L'outfit in costruzione (\(selectedItems.count))")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(selectedItems) { item in
                                        // Componente in basso: con la X per rimuoverlo
                                        ItemThumbnail(cloth: item, actionIcon: "minus.circle.fill") {
                                            selectedItems.removeAll { $0.id == item.id }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // 3. MAGIA: SUGGERIMENTI DI MATCHING A CASCATA
                    // Chiamiamo la tua funzione passandogli i capi attuali
                    let suggestions = closetManager.getCascadingSuggestions(for: selectedItems)
                    
                    if !selectedItems.isEmpty && !suggestions.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Consigliati per questo outfit ✨")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(suggestions) { item in
                                        // Toccando si aggiunge all'outfit
                                        ItemThumbnail(cloth: item, actionIcon: "sparkles") {
                                            selectedItems.append(item)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 15)
                        .background(Color.yellow.opacity(0.1)) // Sfondo leggero per dare risalto ai suggerimenti
                    }
                    
                    // 4. TUTTO L'ARMADIO (Tutti i capi, eccetto quelli già scelti)
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
                            // Griglia a 3 colonne per il resto dei vestiti
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                                ForEach(availableItems) { item in
                                    ItemThumbnail(cloth: item, actionIcon: "plus.circle.fill") {
                                        selectedItems.append(item)
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
                // Tasto Annulla
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        dismiss()
                    }
                }
                // Tasto Salva
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        let finalName = outfitName.isEmpty ? "Nuovo Outfit" : outfitName
                        // Estraiamo solo gli UUID come vuole la tua funzione addOutfit
                        let itemsIds = selectedItems.map { $0.id }
                        closetManager.addOutfit(name: finalName, items: itemsIds)
                        dismiss() // Chiudiamo la modale
                    }
                    .disabled(selectedItems.isEmpty) // Il tasto è grigio/disabilitato se l'outfit è vuoto
                }
            }
        }
    }
}

// COMPONENTE EXTRA: La singola miniatura del vestito riutilizzata più volte
struct ItemThumbnail: View {
    let cloth: Cloth
    let actionIcon: String
    let action: () -> Void // L'azione da fare quando cliccato
    
    var body: some View {
        Button(action: action) {
            VStack {
                if let uiImage = UIImage(data: cloth.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "tshirt")
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            // Aggiungiamo il bottoncino (es. il + o la X) in alto a destra
            .overlay(alignment: .topTrailing) {
                Image(systemName: actionIcon)
                    .foregroundStyle(actionIcon == "minus.circle.fill" ? .red : .blue)
                    .background(Circle().fill(.white))
                    .offset(x: 5, y: -5)
            }
            .shadow(color: .black.opacity(0.1), radius: 2)
        }
        .buttonStyle(.plain) // Evita che l'immagine diventi tutta blu su iOS
    }
}
