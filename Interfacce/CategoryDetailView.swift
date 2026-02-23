import SwiftUI

struct CategoryDetailView: View {
    @Environment(ClosetManager.self) var manager
    
    // CAMBIAMENTO: Ora riceviamo un TIPO di vestito (Type)
    let selectedType: ClothingType
    
    // Filtriamo l'inventario per POSIZIONE
    var filteredClothes: [Cloth] {
        return manager.inventory.filter { $0.type == selectedType }
    }
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            if filteredClothes.isEmpty {
                VStack {
                    Spacer(minLength: 100)
                    Text("No items in \(selectedType.rawValue)")
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
        .navigationTitle(selectedType.rawValue)
    }
}
