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
            OutfitsView()
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

