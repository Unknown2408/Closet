import SwiftUI

struct SearchView: View {
    @Environment(ClosetManager.self) var manager
    @State private var searchText = ""
    
    // --- SETUP GRIGLIA PER I RISULTATI ---
    // Serve per mostrare le ClothCard quando trovi un vestito
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // --- LOGICA DI RICERCA PER ID ---
    var searchResults: [Cloth] {
        if searchText.isEmpty {
            return []
        } else {
            return manager.inventory.filter { item in
                // Converte l'UUID in stringa e controlla se contiene il testo cercato
                // es. se l'ID è "E621E1F8...", scrivendo "E621" lo troverà.
                item.id.uuidString.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // Funzione helper per le immagini delle Categorie (quando non si cerca)
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
                        
                        // Placeholder aggiornato
                        TextField("Search by Item ID ...", text: $searchText)
                        
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.black, lineWidth: 2))
                    
                    // --- LOGICA DI VISUALIZZAZIONE ---
                    
                    if searchText.isEmpty {
                        // CASO A: NESSUNA RICERCA -> MOSTRA LE CATEGORIE MACRO
                        // (Questa è la lista che avevi prima)
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
                        // CASO B: RICERCA ATTIVA -> MOSTRA I VESTITI TROVATI PER ID
                        if searchResults.isEmpty {
                            VStack(spacing: 20) {
                                Spacer(minLength: 50)
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No item found with this ID")
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            // Mostra i risultati usando le ClothCard
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(searchResults) { cloth in
                                    // Qui mostriamo direttamente il vestito trovato
                                    ClothCard(cloth: cloth)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }
}


// Preview
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environment(ClosetManager())
    }
}
