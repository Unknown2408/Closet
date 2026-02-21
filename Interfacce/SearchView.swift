import SwiftUI

struct SearchView: View {
    // 1. Colleghiamo il Manager (per cercare nel database dei vestiti)
    @Environment(ClosetManager.self) var manager
    
    // 2. Stato per la barra di ricerca
    @State private var searchText = ""
    
    // 3. Configurazione Griglia per i risultati (2 colonne)
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // --- LOGICA DI RICERCA (SOLO NOME/BRAND) ---
    var searchResults: [Cloth] {
        if searchText.isEmpty {
            return []
        } else {
            return manager.inventory.filter { item in
                // Cerca ESCLUSIVAMENTE nel nome che hai inserito (brand)
                // Ignora categorie, colori o ID numerici.
                item.brand.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Funzione helper per le immagini delle Categorie
    func imageName(for position: Position) -> String {
        switch position {
        case .top:        return "maglia"
        case .bottom:     return "pantaloni"
        case .footwear:   return "scarpa"
        case .outerwear:  return "giubbotto"
        case .accessories: return "accessori"
        case .fullbody:   return "vestito_unito"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    
                    // TITOLO
                    Text("My closet")
                        .font(.system(size: 34, weight: .heavy))
                        .padding(.top, 20)
                    
                    // BARRA DI RICERCA
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        // Placeholder
                        TextField("Search items by name...", text: $searchText)
                        
                        // Tasto X per cancellare
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.black, lineWidth: 2))
                    
                    // --- LOGICA DI VISUALIZZAZIONE ---
                    
                    if searchText.isEmpty {
                        // CASO A: NESSUNA RICERCA -> MOSTRA LE CATEGORIE
                        ForEach(Position.allCases) { position in
                            NavigationLink(destination: CategoryDetailView(selectedPosition: position)) {
                                HStack(spacing: 20) {
                                    Image(imageName(for: position))
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                    
                                    Text(position.rawValue)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray.opacity(0.5))
                                }
                                .padding(.vertical, 8)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        
                    } else {
                        // CASO B: RICERCA ATTIVA -> MOSTRA I RISULTATI
                        if searchResults.isEmpty {
                            // Nessun risultato trovato
                            VStack(spacing: 20) {
                                Spacer(minLength: 50)
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No items found for \"\(searchText)\"")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            
                        } else {
                            // Griglia dei vestiti trovati
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(searchResults) { cloth in
                                    // Qui usiamo la TUA ClothCard originale senza modifiche
                                    ClothCard(cloth: cloth)
                                }
                            }
                            .padding(.bottom, 20)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }
}

// Preview per testare
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environment(ClosetManager())
    }
}
