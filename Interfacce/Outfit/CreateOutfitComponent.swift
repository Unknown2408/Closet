import SwiftUI

// Componente 1: Nome
struct OutfitNameSection: View {
    @Binding var outfitName: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Outfit Name").font(.headline)
            TextField("e.g. Summer Party", text: $outfitName)
                .textFieldStyle(.roundedBorder)
        }.padding(.horizontal)
    }
}

// 🔥 ECCO IL COMPONENTE MANCANTE: OutfitSlotRow
struct OutfitSlotRow: View {
    let position: Position
    let items: [Cloth]
    let onAdd: () -> Void
    let onRemove: (Cloth) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                Text(position.rawValue)
                    .font(.headline)
                Spacer()
                Button(action: onAdd) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .font(.subheadline).bold()
                }
            }
            
            if items.isEmpty {
                Button(action: onAdd) {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(height: 80)
                        .overlay(
                            Image(systemName: "plus")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }
                .buttonStyle(.plain)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(items) { item in
                            ItemThumbnail(cloth: item, actionIcon: "minus.circle.fill") {
                                onRemove(item)
                            }
                        }
                        
                        Button(action: onAdd) {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundColor(.gray.opacity(0.5))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "plus")
                                        .foregroundColor(.gray)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// Componente 3: I Filtri (Pills + Dropdowns)
struct OutfitBuilderFilters: View {
    let currentPosition: Position
    
    @Binding var selectedType: ClothingType?
    @Binding var selectedSeason: Season?
    @Binding var selectedStyle: Style?
    @Binding var showFavoritesOnly: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                
                Button(action: {
                    withAnimation { showFavoritesOnly.toggle() }
                }) {
                    HStack {
                        Image(systemName: showFavoritesOnly ? "heart.fill" : "heart")
                        Text("Favs")
                    }
                    .font(.caption).bold()
                    .padding(10)
                    .background(showFavoritesOnly ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                    .foregroundColor(showFavoritesOnly ? .red : .primary)
                    .cornerRadius(8)
                }
                
                Menu {
                    ForEach(ClothingType.allCases.filter { $0.possiblePositions.contains(currentPosition) }) { type in
                        Button(type.rawValue) { selectedType = type }
                    }
                    Button("All Types") { selectedType = nil }
                } label: {
                    FilterLabel(title: selectedType?.rawValue ?? "Type", icon: "line.3.horizontal.decrease")
                }
                
                Menu {
                    ForEach(Season.allCases, id: \.self) { s in
                        Button(s.rawValue) { selectedSeason = s }
                    }
                } label: {
                    FilterLabel(title: selectedSeason?.rawValue ?? "Season", icon: "leaf")
                }
                
                Menu {
                    ForEach(Style.allCases) { s in
                        Button(s.rawValue) { selectedStyle = s }
                    }
                    Button("All Styles") { selectedStyle = nil }
                } label: {
                    FilterLabel(title: selectedStyle?.rawValue ?? "Style", icon: "tag")
                }
            }
            .padding(.horizontal)
        }
    }
}

// Sotto-componente per le label dei filtri
struct FilterLabel: View {
    let title: String
    let icon: String
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .font(.caption).bold()
        .padding(10)
        .background(Color.gray.opacity(0.1))
        .foregroundColor(.primary)
        .cornerRadius(8)
    }
}

// Componente 4: Griglia Armadio
struct ClosetSelectionGrid: View {
    let items: [Cloth]
    let onAdd: (Cloth) -> Void
    
    var body: some View {
        if items.isEmpty {
            ContentUnavailableView(
                "Nessun capo trovato",
                systemImage: "magnifyingglass",
                description: Text("Prova a cambiare i filtri per vedere più risultati.")
            )
            .padding()
        } else {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(items) { item in
                    ItemThumbnail(cloth: item, actionIcon: "plus.circle.fill") { onAdd(item) }
                }
            }.padding(.horizontal)
        }
    }
}

// Componente 5: Lista Suggerimenti Match
struct MagicMatchList: View {
    let items: [Cloth]
    let onAdd: (Cloth) -> Void
    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading) {
                Text("Suggested for you ✨").font(.headline).padding(.horizontal)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(items) { item in
                            ItemThumbnail(cloth: item, actionIcon: "plus.circle.fill") { onAdd(item) }
                        }
                    }.padding(.horizontal)
                }
            }
            .padding(.vertical, 15).background(Color.yellow.opacity(0.1)).cornerRadius(12).padding(.horizontal)
        }
    }
}
