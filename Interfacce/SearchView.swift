import SwiftUI

struct SearchView: View {
    @Environment(ClosetManager.self) var manager
    @State private var searchText = ""
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // --- LOGICA DI RICERCA ---
    var searchResults: [Cloth] {
        if searchText.isEmpty {
            return []
        } else {
            return manager.inventory.filter { item in
                item.brand.localizedCaseInsensitiveContains(searchText) ||
                item.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
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
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    // 1. TITOLO FISSO IN ALTO
                    Text("My Closet")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.top, 16)
                    
                    // 2. BARRA DI RICERCA CUSTOM FISSA
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search by name or brand...", text: $searchText)
                            .submitLabel(.search)
                        
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
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                    
                    // 3. SCROLLVIEW
                    ScrollView {
                        VStack(alignment: .leading, spacing: 30) {
                            
                            if searchText.isEmpty {
                                // CASO A: NESSUNA RICERCA -> MOSTRA LE MACRO-CATEGORIE (Tops, Bottoms...)
                                ForEach(Position.allCases) { position in
                                    //Punta alla vista intermedia, con le sotto-categorie
                                    NavigationLink(destination: SubCategoryListView(position: position)) {
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
                                    LazyVGrid(columns: columns, spacing: 20) {
                                        ForEach(searchResults) { cloth in
                                            NavigationLink(destination: DetailView(cloth: cloth)) {
                                                ClothCard(cloth: cloth)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 50)
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
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
