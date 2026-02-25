import SwiftUI

// 1. IL DIZIONARIO DEI COLORI
private let uiColorsDict: [String: Color] = [
    "WHITE": .white, "LIGHT GRAY": Color(white: 0.8), "GRAY": .gray, "DARK GRAY": Color(white: 0.2), "BLACK": .black,
    "RED": .red, "MAROON": Color(red: 0.5, green: 0, blue: 0), "ORANGE": .orange, "BEIGE": Color(red: 0.96, green: 0.96, blue: 0.86), "YELLOW": .yellow,
    "GREEN": .green, "OLIVE": Color(red: 0.5, green: 0.5, blue: 0), "BLUE": .blue, "NAVY": Color(red: 0, green: 0, blue: 0.5), "PURPLE": .purple,
    "PINK": .pink, "BROWN": .brown, "CYAN": .cyan, "TEAL": Color(red: 0, green: 0.5, blue: 0.5), "MAGENTA": Color(red: 1, green: 0, blue: 1)
]

struct DetailedView: View {
    let cloth: Cloth
    @Environment(ClosetManager.self) private var manager
    @Environment(\.dismiss) var dismiss
    
    @State private var showingEditSheet = false
    @State private var showingMatchesSheet = false
    
    @State private var showingDeleteConfirm = false
    
    var currentCloth: Cloth {
        manager.inventory.first(where: { $0.id == cloth.id }) ?? cloth
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 1. NOME E BRAND SOPRA L'IMMAGINE
                    VStack(alignment: .leading, spacing: 5) {
                        Text(currentCloth.name)
                            .font(.title.bold())
                        Text(currentCloth.brand.uppercased())
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // 2. BOX IMMAGINE
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.05))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)

                        if let uiImage = UIImage(data: currentCloth.image) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .padding(20)
                        } else {
                            Image(systemName: "tshirt.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(60)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 350)
                    .padding(.horizontal)

                    Divider().padding(.horizontal)

                    // 3. TUTTI I DETTAGLI (Style, Season, Colors)
                    VStack(alignment: .leading, spacing: 15) {
                        
                        // Style
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Style").font(.headline)
                            Text(currentCloth.style.map { $0.rawValue }.joined(separator: ", "))
                                .foregroundColor(.secondary)
                        }
                        
                        // Season
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Season").font(.headline)
                            Text(currentCloth.season.map { $0.rawValue }.joined(separator: ", "))
                                .foregroundColor(.secondary)
                        }
                        
                        // Colors
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Colors").font(.headline)
                            ForEach(currentCloth.coloreIndumentoRicerca, id: \.self) { coloreEnum in
                                HStack(spacing: 8) {
                                    Text(coloreEnum.rawValue.capitalized).foregroundColor(.secondary)
                                    Circle()
                                        .fill(uiColorsDict[coloreEnum.rawValue.uppercased()] ?? Color.gray)
                                        .frame(width: 14, height: 14)
                                        .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: 1))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // Pulsante Match (rimane fisso in basso)
            Button(action: { showingMatchesSheet = true }) {
                Text("Match")
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
        .navigationBarTitleDisplayMode(.inline)
        // 4. PULSANTI NELLA BARRA DI NAVIGAZIONE IN ALTO
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                
                // Pulsante Cuore
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        manager.toggleFavorite(ofItemWithID: currentCloth.id)
                    }
                }) {
                    Image(systemName: currentCloth.favourite ? "heart.fill" : "heart")
                        .foregroundColor(currentCloth.favourite ? .red : .black)
                }
                
                // Pulsante Ellipsis (...)
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteConfirm = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) { NewItemView(itemToEdit: currentCloth) }
        .sheet(isPresented: $showingMatchesSheet) { MatchCreationSheet(anchorCloth: currentCloth) }
        
        .alert("Delete Item", isPresented: $showingDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                manager.removeItem(withID: currentCloth.id)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this item? This action cannot be undone.")
        }
    }
}

// MARK: - Modale Abbinamenti (Totalmente rifatta e interattiva)
struct MatchCreationSheet: View {
    let anchorCloth: Cloth
    @Environment(ClosetManager.self) private var closetManager
    @Environment(\.dismiss) var dismiss
    
    // Stato locale per creare un outfit al volo
    @State private var selectedItems: [Cloth] = []
    @State private var outfitName: String = ""
    @State private var showingSaveAlert = false
    
    // Suggerimenti basati sugli item attualmente selezionati
    var suggestions: [Cloth] {
        let rawSuggestions = closetManager.getCascadingSuggestions(for: selectedItems)
        // Evitiamo di mostrare tra i suggerimenti capi che abbiamo già aggiunto
        return rawSuggestions.filter { sugg in
            !selectedItems.contains(where: { $0.id == sugg.id })
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                
                // 1. SELECTED ITEMS (I capi che stiamo assemblando)
                VStack(alignment: .leading) {
                    Text("Your look so far")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(selectedItems) { item in
                                ZStack(alignment: .topTrailing) {
                                    // La ClothCard ridotta per la lista orizzontale
                                    ClothCard(cloth: item)
                                        .frame(width: 120)
                                    
                                    // Pulsante per rimuovere (non mostrato per il capo principale)
                                    if item.id != anchorCloth.id {
                                        Button(action: {
                                            withAnimation { selectedItems.removeAll(where: { $0.id == item.id }) }
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                                .background(Circle().fill(Color.white))
                                        }
                                        .padding(4)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
                
                Divider()
                
                // 2. SUGGESTIONS (I Magic Matches)
                VStack(alignment: .leading) {
                    Text("Magic Matches")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if suggestions.isEmpty {
                        Text("No more matches found.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(suggestions) { item in
                                    ZStack(alignment: .topTrailing) {
                                        ClothCard(cloth: item)
                                            .frame(width: 120)
                                        
                                        // Pulsante per aggiungere
                                        Button(action: {
                                            withAnimation { selectedItems.append(item) }
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.black)
                                                .background(Circle().fill(Color.white))
                                        }
                                        .padding(4)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Build Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        showingSaveAlert = true
                    }
                    // Non ha senso salvare un outfit con 1 solo capo
                    .disabled(selectedItems.count < 2)
                }
            }
            // Alert per dare il nome all'outfit prima di salvare
            .alert("Save Outfit", isPresented: $showingSaveAlert) {
                TextField("Outfit Name", text: $outfitName)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    let name = outfitName.isEmpty ? "New Match Outfit" : outfitName
                    closetManager.addOutfit(name: name, items: selectedItems.map { $0.id })
                    dismiss()
                }
            } message: {
                Text("Give a name to your new creation.")
            }
            .onAppear {
                // Inizializza l'outfit con il capo da cui siamo partiti!
                selectedItems = [anchorCloth]
            }
        }
    }
}
