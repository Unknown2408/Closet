import SwiftUI

struct CategoryDetailView: View {
    @Environment(ClosetManager.self) var manager
    
    // CAMBIAMENTO: Ora riceviamo una MACRO categoria (Position)
    let selectedPosition: Position
    
    // Filtriamo l'inventario per POSIZIONE
    var filteredClothes: [Cloth] {
        return manager.inventory.filter { $0.position == selectedPosition }
    }
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            if filteredClothes.isEmpty {
                VStack {
                    Spacer(minLength: 100)
                    Text("No items in \(selectedPosition.rawValue)")
                        .foregroundColor(.gray)
                }
            } else {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredClothes) { cloth in
                        ClothCard(cloth: cloth)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(selectedPosition.rawValue)
    }
}
