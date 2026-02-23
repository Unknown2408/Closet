import SwiftUI

struct ClosetContentView: View {
    @Environment(ClosetManager.self) private var manager
    @State private var showingAddItem = false
    
    // NUOVO: Riceve il nome dalla HomeView
    let nome: String
    
    // Configurazione griglia a 2 colonne
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // NUOVO: Logica per il titolo dinamico
    var headerTitle: String {
        let cleanName = nome.trimmingCharacters(in: .whitespaces)
        if cleanName.isEmpty {
            return "My Closet" // Se ha cliccato "Forse più tardi"
        } else {
            return "Closet of \(cleanName)" // Se ha inserito un nome
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                SwiftUI.Color.white.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    // Header: Titolo Dinamico + Pulsante per aggiungere
                    HStack {
                        // Utilizziamo headerTitle invece di "My Closet" fisso
                        Text(headerTitle)
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.black)
                            .minimumScaleFactor(0.6) // Utile se il nome è molto lungo per non farlo tagliare
                            .lineLimit(1)
                        
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
                            
                            Spacer()
                            
                            // Griglia con i dati reali del ClosetManager
                            // Griglia con i dati reali del ClosetManager
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(manager.inventory) { item in
                                    // CANCELLA l'onDelete e lascia solo cloth: item
                                    NavigationLink(destination: DetailView(cloth: item)) {
                                        ClothCard(cloth: item)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 25) // Allineamento corretto
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                NewItemView()
            }
        }
    }
}
