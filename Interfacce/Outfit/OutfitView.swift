import SwiftUI

struct OutfitsView: View {
    // 1. Accediamo al nostro "cervello" condiviso
    @Environment(ClosetManager.self) var closetManager
    
    // 2. Variabile di stato per mostrare la schermata "Crea Outfit" (Fase 3)
    @State private var isShowingCreateOutfit = false
    
    // 3. Layout: definiamo una griglia a due colonne flessibili
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                // CONTROLLO EMPTY STATE: Se non ci sono outfit, mostriamo un bel messaggio
                if closetManager.outfits.isEmpty {
                    ContentUnavailableView(
                        "No Outfits",
                        systemImage: "hanger",
                        description: Text("Tap the icon in the top right to create your first outfit!")
                    )
                    .padding(.top, 50)
                } else {
                    // SE CI SONO OUTFIT: Mostriamo la griglia
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(closetManager.outfits) { outfit in
                            // ⭐️ MODIFICA FASE 4: La card ora è un link cliccabile!
                            NavigationLink(destination: OutfitDetailView(outfitId: outfit.id)) {
                                OutfitCardView(outfit: outfit)
                            }
                            .buttonStyle(.plain) // ⚠️ Evita che la card diventi blu al tap
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Outfits")
            // 4. TOOLBAR E MENU A TENDINA
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        // Pulsante 1: Crea Nuovo
                        Button {
                            isShowingCreateOutfit = true
                        } label: {
                            Label("Create New Outfit", systemImage: "plus")
                        }
                        
                        // Pulsante 2: Modifica (per abilitare cancellazioni o riordino)
                        Button {
                            print("Edit mode to be implemented")
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                    } label: {
                        // L'icona del menù visibile all'utente (i 3 puntini)
                        Image(systemName: "ellipsis.circle")
                            .font(.title3) // Per renderla un filo più grande
                    }
                }
            }
            // 5. MODALE DI CREAZIONE: Si apre quando isShowingCreateOutfit è true
            .sheet(isPresented: $isShowingCreateOutfit) {
                CreateOutfitView()
            }
        }
    }
}

// Preview per vedere il risultato al volo
#Preview {
    OutfitsView()
        .environment(ClosetManager()) // Passiamo un manager vuoto per la preview
}
