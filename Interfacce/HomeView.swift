import SwiftUI

struct HomeView: View {
    @State private var selection = 0
    
    var body: some View {
        // La TabView deve stare al "livello più alto"
        TabView(selection: $selection) {
            
            // TAB 1: Visualizza il contenuto dell'armadio
            ClosetContentView()
                .tabItem {
                    Label("Closet", systemImage: "hanger")
                }
                .tag(0)
            
            // TAB 2: Visualizza la vista Outfit
            OutfitView()
                .tabItem {
                    Image(systemName: "tshirt")
                        .environment(\.symbolVariants, .none)
                    Text("Outfit")
                }
                .tag(1)
            
            //TAB 3: Ricerca
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2)
            
        }
        .accentColor(.black)
    }
}


struct ClosetContentView: View {
    @Environment(ClosetManager.self) private var manager
    @State private var showingAddItem = false
    
    // Configurazione griglia a 2 colonne
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                SwiftUI.Color.white.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Header: My Closet + Pulsante per aggiungere
                    HStack {
                        Text("My Closet")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Button(action: { showingAddItem = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Featured")
                                .font(.title2.bold())
                                .padding(.top, 10)
                            
                            // Griglia con i dati reali del ClosetManager
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(manager.inventory) { item in
                                    // Avvolgiamo la Card in un NavigationLink
                                    NavigationLink(destination: DetailView(cloth: item)) {
                                        ClothCard(cloth: item)
                                    }
                                    // Questo serve a evitare che i testi diventino blu/grigi cliccabili
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 20)
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                NewItemView()
            }
        }
    }
}

struct ClothCard: View {
    let cloth: Cloth
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Box Immagine
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(SwiftUI.Color.gray.opacity(0.1))
                    .aspectRatio(0.85, contentMode: .fit)
                
                // LOGICA AGGIORNATA PER DATA -> IMAGE
                if let uiImage = UIImage(data: cloth.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                } else {
                    // Placeholder nel caso i dati siano corrotti o mancanti
                    Image(systemName: "tshirt.fill")
                        .foregroundColor(.gray.opacity(0.3))
                        .font(.largeTitle)
                }
            }
            
            // Informazioni Capo
            VStack(alignment: .leading, spacing: 2) {
                Text(cloth.brand.uppercased())
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                
                Text(cloth.type.rawValue)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(ClosetManager())
}
