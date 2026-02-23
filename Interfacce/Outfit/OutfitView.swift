import SwiftUI

struct OutfitsView: View {
    @Environment(ClosetManager.self) var closetManager
    
    // Variabili di stato base
    @State private var isShowingCreateOutfit = false
    @State private var showFavoritesOnly = false
    
    // Variabili per la modalità di selezione/modifica (Edit Mode)
    @State private var isEditing = false
    @State private var selectedOutfits: Set<UUID> = []
    @State private var showingDeleteConfirm = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Filtro per mostrare solo i preferiti se attivato
    var filteredOutfits: [Outfit] {
        if showFavoritesOnly {
            return closetManager.outfits.filter { $0.favourite }
        } else {
            return closetManager.outfits
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                
                // --- CUSTOM HEADER ---
                HStack(alignment: .center) {
                    Text("My Outfits")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // Se siamo in modalità modifica, mostriamo le azioni
                    if isEditing {
                        HStack(spacing: 20) {
                            if !selectedOutfits.isEmpty {
                                
                                // --- Pulsante Preferiti Multipli ---
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    
                                    withAnimation {
                                        // Usiamo la funzione appena creata nel manager!
                                        closetManager.markAsFavorite(outfitIDs: selectedOutfits, isFavorite: true)
                                        
                                        // Usciamo dall'edit mode e svuotiamo la selezione
                                        isEditing = false
                                        selectedOutfits.removeAll()
                                    }
                                }) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.black)
                                        .font(.title3)
                                }
                                
                                // --- Pulsante Cestino Multiplo ---
                                Button(action: {
                                    showingDeleteConfirm = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                }
                            }
                            
                            Button("Annulla") {
                                withAnimation {
                                    isEditing = false
                                    selectedOutfits.removeAll()
                                }
                            }
                            .font(.body.bold())
                        }
                    } else {
                        // Menu normale (visibile solo se non siamo in Edit Mode)
                        Menu {
                            Button {
                                withAnimation(.easeInOut) {
                                    showFavoritesOnly.toggle()
                                }
                            } label: {
                                Label(
                                    showFavoritesOnly ? "Mostra Tutti" : "Solo Preferiti",
                                    systemImage: showFavoritesOnly ? "square.grid.2x2" : "heart.fill"
                                )
                            }
                            
                            Divider()
                            
                            Button {
                                isShowingCreateOutfit = true
                            } label: {
                                Label("Create New Outfit", systemImage: "plus")
                            }
                            
                            Button {
                                withAnimation {
                                    isEditing = true
                                }
                            } label: {
                                Label("Select Items", systemImage: "checkmark.circle")
                            }
                            .disabled(filteredOutfits.isEmpty)
                            
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title2)
                                .symbolVariant(showFavoritesOnly ? .fill : .none)
                                .foregroundColor(showFavoritesOnly ? .red : .primary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 5)
                
                
                // --- CONTROLLO EMPTY STATE ---
                if closetManager.outfits.isEmpty {
                    ContentUnavailableView(
                        "No Outfits",
                        systemImage: "hanger",
                        description: Text("Tap the icon in the top right to create your first outfit!")
                    )
                    .padding(.top, 50)
                    
                } else if filteredOutfits.isEmpty {
                    ContentUnavailableView(
                        "Nessun Preferito",
                        systemImage: "heart.slash",
                        description: Text("Non hai ancora aggiunto nessun outfit ai preferiti.")
                    )
                    .padding(.top, 50)
                    
                } else {
                    // --- GRIGLIA DEGLI OUTFIT ---
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredOutfits) { outfit in
                            
                            if isEditing {
                                // MODO EDIT: Selezione multipla
                                OutfitCardView(outfit: outfit)
                                    .overlay(
                                        ZStack {
                                            if selectedOutfits.contains(outfit.id) {
                                                Color.black.opacity(0.2) // Scurisce la card selezionata
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.blue)
                                                    .background(Circle().fill(Color.white))
                                            } else {
                                                Image(systemName: "circle")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.white)
                                                    .shadow(radius: 2)
                                            }
                                        }
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .onTapGesture {
                                        let generator = UIImpactFeedbackGenerator(style: .light)
                                        generator.impactOccurred()
                                        
                                        // Aggiungi o rimuovi dall'array dei selezionati
                                        if selectedOutfits.contains(outfit.id) {
                                            selectedOutfits.remove(outfit.id)
                                        } else {
                                            selectedOutfits.insert(outfit.id)
                                        }
                                    }
                            } else {
                                // MODO NORMALE: Tap per aprire il dettaglio
                                NavigationLink(destination: OutfitDetailView(outfitId: outfit.id)) {
                                    OutfitCardView(outfit: outfit)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            // Nasconde la barra nativa per usare il nostro custom Header
            .navigationBarHidden(true)
            
            // Modale di Creazione
            .sheet(isPresented: $isShowingCreateOutfit) {
                CreateOutfitView()
            }
            // Alert di conferma per l'eliminazione multipla
            .alert("Elimina Outfit", isPresented: $showingDeleteConfirm) {
                Button("Annulla", role: .cancel) { }
                Button("Elimina", role: .destructive) {
                    withAnimation {
                        for id in selectedOutfits {
                            closetManager.deleteOutfit(id: id)
                        }
                        isEditing = false
                        selectedOutfits.removeAll()
                    }
                }
            } message: {
                Text("Sei sicuro di voler eliminare \(selectedOutfits.count) outfit? I vestiti rimarranno nel tuo armadio.")
            }
        }
    }
}

#Preview {
    OutfitsView()
        .environment(ClosetManager())
}
