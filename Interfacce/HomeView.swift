import SwiftUI

struct HomeView: View {
    @State private var selection = 0
    // NUOVO: Aggiunta variabile per ricevere il nome inserito
    let nome: String
    
    var body: some View {
        // La TabView deve stare al "livello più alto"
        TabView(selection: $selection) {
            
            // TAB 1: Visualizza il contenuto dell'armadio
            // Passiamo il nome alla vista figlia
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
