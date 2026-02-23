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
            VStack(spacing: 0) {
                
                // --- CUSTOM HEADER ---
                // Questo mantiene il testo GRANDE a SINISTRA, e il menu a DESTRA sulla stessa riga.
                HStack(alignment: .center) {
                    Text("My Outfits")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer() // Spinge i bottoni a destra
                    
                    if isEditing {
                        // Azioni in Edit Mode
                        HStack(spacing: 16) {
                            if !selectedOutfits.isEmpty {
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    withAnimation {
                                        closetManager.markAsFavorite(outfitIDs: selectedOutfits, isFavorite: true)
                                        isEditing = false
                                        selectedOutfits.removeAll()
                                    }
                                }) {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.primary)
                                        .font(.title3)
                                }
                                
                                Button(action: {
                                    showingDeleteConfirm = true
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                }
                            }
                            
                            Button("Cancel") {
                                withAnimation {
                                    isEditing = false
                                    selectedOutfits.removeAll()
                                }
                            }
                            .font(.body.bold())
                        }
                    } else {
                        // Menu normale
                        Menu {
                            Button {
                                withAnimation(.easeInOut) { showFavoritesOnly.toggle() }
                            } label: {
                                Label(
                                    showFavoritesOnly ? "Show All" : "Favorites Only",
                                    systemImage: showFavoritesOnly ? "square.grid.2x2" : "heart.fill"
                                )
                            }
                            
                            Divider()
                            
                            Button { isShowingCreateOutfit = true } label: {
                                Label("Create New Outfit", systemImage: "plus")
                            }
                            
                            Button {
                                withAnimation { isEditing = true }
                            } label: {
                                Label("Select Items", systemImage: "checkmark.circle")
                            }
                            .disabled(filteredOutfits.isEmpty)
                            
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.title2) // Un po' più grande per bilanciare il titolo
                                .symbolVariant(showFavoritesOnly ? .fill : .none)
                                .foregroundColor(showFavoritesOnly ? .red : .primary)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                
                // --- GRIGLIA DEGLI OUTFIT O EMPTY STATE ---
                if closetManager.outfits.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "No Outfits",
                        systemImage: "hanger",
                        description: Text("Tap the icon in the top right to create your first outfit!")
                    )
                    Spacer()
                } else if filteredOutfits.isEmpty {
                    Spacer()
                    ContentUnavailableView(
                        "No Favorites",
                        systemImage: "heart.slash",
                        description: Text("You haven't added any outfits to your favorites yet.")
                    )
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredOutfits) { outfit in
                                if isEditing {
                                    // MODO EDIT: Selezione multipla
                                    OutfitCardView(outfit: outfit)
                                        .overlay(
                                            ZStack {
                                                if selectedOutfits.contains(outfit.id) {
                                                    Color.black.opacity(0.2)
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
                                            if selectedOutfits.contains(outfit.id) {
                                                selectedOutfits.remove(outfit.id)
                                            } else {
                                                selectedOutfits.insert(outfit.id)
                                            }
                                        }
                                } else {
                                    // MODO NORMALE
                                    NavigationLink(destination: OutfitDetailView(outfitId: outfit.id)) {
                                        OutfitCardView(outfit: outfit)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar) // ⭐️ Essenziale: Nasconde la barra nativa iOS per far spazio alla nostra
        }
        .sheet(isPresented: $isShowingCreateOutfit) {
            CreateOutfitView()
        }
        .alert("Delete Outfit", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                withAnimation {
                    for id in selectedOutfits {
                        closetManager.deleteOutfit(id: id)
                    }
                    isEditing = false
                    selectedOutfits.removeAll()
                }
            }
        } message: {
            Text("Are you sure you want to delete \(selectedOutfits.count) outfit(s)? The items will remain in your closet.")
        }
    }
}

#Preview {
    OutfitsView()
        .environment(ClosetManager())
}
