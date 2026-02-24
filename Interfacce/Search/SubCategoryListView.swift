import SwiftUI

struct SubCategoryListView: View {
    // Riceve la posizione cliccata dalla SearchView
    let position: Position

    var validTypes: [ClothingType] {
        ClothingType.allCases.filter { type in
            type.possiblePositions.contains(position)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Genera la lista testuale (senza icone)
                ForEach(validTypes) { type in
                    NavigationLink(destination: CategoryDetailView(selectedType: type)) {
                        HStack {
                            Text(type.rawValue)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        .padding(.vertical, 18)
                        .padding(.horizontal, 24)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                        .padding(.horizontal, 24)
                }
            }
            .padding(.top, 10)
        }
        .navigationTitle(position.rawValue) // Il titolo in alto sarà "Tops", "Bottoms", ecc.
        .navigationBarTitleDisplayMode(.large)
    }
}
