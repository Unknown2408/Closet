import SwiftUI

// Dizionario dei colori
let uiColors: [String: Color] = [
    "WHITE": .white, "LIGHT GRAY": Color(white: 0.8), "GRAY": .gray, "DARK GRAY": Color(white: 0.2), "BLACK": .black,
    "RED": .red, "MAROON": Color(red: 0.5, green: 0, blue: 0), "ORANGE": .orange, "BEIGE": Color(red: 0.96, green: 0.96, blue: 0.86), "YELLOW": .yellow,
    "GREEN": .green, "OLIVE": Color(red: 0.5, green: 0.5, blue: 0), "BLUE": .blue, "NAVY": Color(red: 0, green: 0, blue: 0.5), "PURPLE": .purple,
    "PINK": .pink, "BROWN": .brown, "CYAN": .cyan, "TEAL": Color(red: 0, green: 0.5, blue: 0.5), "MAGENTA": Color(red: 1, green: 0, blue: 1)
]

// MARK: - DETAIL VIEW PRINCIPALE
struct DetailView: View {
    let cloth: Cloth
    
    @Environment(ClosetManager.self) private var manager
    @Environment(\.dismiss) var dismiss
    
    // RIMOSSO: @State private var isFavorite ... (Non serve più!)
    @State private var showingEditSheet = false
    @State private var showingMatchesSheet = false
    
    // Calcola il capo aggiornato in tempo reale dal Manager
    var currentCloth: Cloth {
        manager.inventory.first(where: { $0.id == cloth.id }) ?? cloth
    }
    
    var body: some View {
        VStack {
            // 1. Menu in alto con Cuoricino e Ellipsis
            HStack(spacing: 20) {
                Spacer()
                
                // --- TASTO PREFERITO MODIFICATO ---
                Button(action: {
                    // Chiama la funzione specifica del tuo ClosetManager
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        manager.toggleFavorite(ofItemWithID: currentCloth.id)
                    }
                }) {
                    // Usa direttamente i dati di currentCloth
                    Image(systemName: currentCloth.favourite ? "heart.fill" : "heart")
                        .font(.system(size: 24))
                        // Diventa ROSSO se preferito, NERO se no
                        .foregroundColor(.black) 
                        // Piccolo effetto ingrandimento quando attivo
                        .scaleEffect(currentCloth.favourite ? 1.1 : 1.0)
                }
                
                Menu {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Label("Modify", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        manager.removeItem(withID: currentCloth.id)
                        dismiss()
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 2. Immagine
                    if let uiImage = UIImage(data: currentCloth.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .frame(height: 300)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                    }

                    // 3. Info Prodotto
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text(currentCloth.brand)
                                .font(.title2.bold())
                            Spacer()
                        }
                        
                        Text(currentCloth.type.rawValue)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // 4. Dettagli Extra
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Brand").font(.headline)
                            Text(currentCloth.brand).foregroundColor(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Season").font(.headline)
                            Text(currentCloth.season.map { $0.rawValue }.joined(separator: ", "))
                                .foregroundColor(.secondary)
                        }

                        // SEZIONE COLORI
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Colors").font(.headline)
                            
                            ForEach(currentCloth.coloreIndumentoRicerca, id: \.self) { coloreEnum in
                                HStack(spacing: 8) {
                                    Text(coloreEnum.rawValue.capitalized)
                                        .foregroundColor(.secondary)
                                    
                                    Circle()
                                        .fill(uiColors[coloreEnum.rawValue.uppercased()] ?? Color.gray)
                                        .frame(width: 14, height: 14)
                                        .overlay(
                                            Circle().stroke(Color.black.opacity(0.1), lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // 5. Pulsante Match
            Button(action: {
                showingMatchesSheet = true
            }) {
                Text("Match ✨")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(25)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 10)
        }
        .navigationTitle(currentCloth.name)
        .navigationBarTitleDisplayMode(.inline)
        // RIMOSSO: .onAppear { ... } perché ora currentCloth si aggiorna da solo
        .sheet(isPresented: $showingEditSheet) {
            NewItemView(itemToEdit: currentCloth)
        }
        .sheet(isPresented: $showingMatchesSheet) {
            MatchCreationSheet(anchorCloth: currentCloth)
        }
    }
}


// MARK: - MODALE INTERATTIVA CREAZIONE OUTFIT
struct MatchCreationSheet: View {
    let anchorCloth: Cloth
    @Environment(ClosetManager.self) private var manager
    @Environment(\.dismiss) var dismiss
    
    // 1. Qui salviamo i capi che stiamo aggiungendo all'outfit (parte con il capo scelto)
    @State private var selectedItems: [Cloth] = []
    
    // 2. Calcoliamo i suggerimenti in tempo reale basandoci su TUTTO ciò che è in selectedItems
    var suggestions: [Cloth] {
        let rawSuggestions = manager.getCascadingSuggestions(for: selectedItems)
        // Filtriamo i suggerimenti per NON mostrare i capi che abbiamo già aggiunto
        return rawSuggestions.filter { sugg in
            !selectedItems.contains(where: { $0.id == sugg.id })
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                
                // --- SEZIONE 1: L'OUTFIT CHE STAI CREANDO ---
                VStack(alignment: .leading) {
                    Text("Your Outfit")
                        .font(.title3.bold())
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(selectedItems) { item in
                                // Il tasto meno (-) rimuove il capo
                                ItemThumbnail(cloth: item, actionIcon: "minus.circle.fill") {
                                    withAnimation(.spring()) {
                                        // Non permettiamo di rimuovere il capo principale (anchorCloth)
                                        if item.id != anchorCloth.id {
                                            selectedItems.removeAll(where: { $0.id == item.id })
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 20)
                
                Divider()
                    .padding(.horizontal)
                
                // --- SEZIONE 2: I SUGGERIMENTI DELL'ALGORITMO ---
                VStack(alignment: .leading) {
                    Text("Magic Matches ✨")
                        .font(.title3.bold())
                        .padding(.horizontal)
                    
                    if suggestions.isEmpty {
                        Text("No more matches found for these items.")
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.top, 10)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(suggestions) { item in
                                    // Il tasto più (+) aggiunge il capo all'outfit
                                    ItemThumbnail(cloth: item, actionIcon: "plus.circle.fill") {
                                        withAnimation(.spring()) {
                                            selectedItems.append(item)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
                
                // --- SEZIONE 3: PULSANTE SALVA ---
                Button(action: {
                    // TODO: Implementare il salvataggio con manager.addOutfit(...)
                    // Nota: ti servirà un modo per chiedere il nome dell'outfit all'utente
                    print("Salvataggio outfit con \(selectedItems.count) capi!")
                    dismiss()
                }) {
                    Text("Save Outfit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedItems.count > 1 ? Color.black : Color.gray)
                        .cornerRadius(25)
                }
                .disabled(selectedItems.count < 2) // Disabilita se c'è solo il capo di partenza
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            }
            .navigationTitle("Build Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.black)
                }
            }
            // Inizializza l'array con il capo da cui siamo partiti
            .onAppear {
                selectedItems = [anchorCloth]
            }
        }
    }
}
