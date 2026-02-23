import SwiftUI

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
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // CONTROLLO EMPTY STATE
                    if manager.inventory.isEmpty {
                        
                        // Vista quando l'armadio è vuoto
                        Spacer()
                        ContentUnavailableView(
                            "No Items",
                            systemImage: "tshirt",
                            description: Text("Tap the + icon in the top right to add your clothing item!")
                        )
                        Spacer()
                        
                    } else {
                        
                        // Vista normale con la griglia dei vestiti
                        ScrollView {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Featured")
                                    .font(.title2.bold())
                                    .padding(.top, 10)
                                
                                Spacer()
                                
                                // Griglia con i dati reali del ClosetManager
                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(manager.inventory) { item in
                                        NavigationLink(destination: DetailView(cloth: item)) {
                                            ClothCard(cloth: item)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                            .padding(.horizontal) // Allineamento corretto
                            .padding(.bottom, 16)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                NewItemView()
            }
        }
    }
}
