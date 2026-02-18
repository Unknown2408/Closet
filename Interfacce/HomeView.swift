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
                    Label("Outfit", systemImage: "tshirt")
                }
                .tag(1)
            
            //TAB 3: Ricerca
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(0)
            
        }
        .accentColor(.black)
    }
}


struct ClosetContentView: View {
    @State private var showingAddItem = false
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                // Header: Welcome + Nome
                VStack(alignment: .leading, spacing: 5) {
                    
                    HStack{
                        Text("My closet")
                            .font(.system(size: 40, weight: .bold, design: .default))
                            .foregroundColor(.black)
                    
                        Spacer() // Spinge il bottone tutto a destra (opzionale)

                        Button(action: {
                            
                            showingAddItem = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.8))
                                        .blur(radius: 0.5)
                                )
                        }
                        // Questo "ascolta" quando showingAddItem diventa true e apre la vista
                        .sheet(isPresented: $showingAddItem) {
                            NewItemView()
                        }
                        
                    }
                    
                    
                }
                .padding(.horizontal, 30)
                .padding(.top)
                
                Spacer()
                
                // Pulsanti Funzioni
                HStack(spacing: 25) {
                    Spacer()
                    
                    // Lente di ingrandimento
                    CircleButton(icon: "magnifyingglass") {
                        print("Cerca")
                    }
                    
                    // Più (per aggiungere)
                    CircleButton(icon: "plus", isMain: true) {
                        print("Aggiungi")
                    }
                    
                    // Cestino
                    CircleButton(icon: "trash") {
                        print("Elimina")
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 50)
            }
            
            
        }
    }
}

// Sottovista per i pulsanti rotondi
struct CircleButton: View {
    let icon: String
    var isMain: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1)) // Sfondo leggermente visibile
                    .frame(width: isMain ? 80 : 65, height: isMain ? 80 : 65)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                
                Image(systemName: icon)
                    .font(.system(size: isMain ? 30 : 22, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    HomeView()
}
