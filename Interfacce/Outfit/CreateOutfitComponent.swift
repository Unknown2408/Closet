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

// Componente 2: Capi già scelti
struct SelectedItemsHeader: View {
    @Binding var selectedItems: [Cloth]
    @Binding var isMatchingEnabled: Bool
    
    var body: some View {
        if !selectedItems.isEmpty {
            VStack(alignment: .leading, spacing: 15) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(selectedItems) { item in
                            ItemThumbnail(cloth: item, actionIcon: "minus.circle.fill") {
                                withAnimation { selectedItems.removeAll { $0.id == item.id } }
                            }
                        }
                    }.padding(.horizontal)
                }
                
                Button(action: { withAnimation { isMatchingEnabled.toggle() }}) {
                    Label(isMatchingEnabled ? "Hide Match" : "Magic Match ✨", systemImage: "sparkles")
                        .frame(maxWidth: .infinity).font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(isMatchingEnabled ? .secondary : .black)
                .padding(.horizontal)
            }
        }
    }
}

// Componente 3: I Filtri (Pills + Dropdowns)
struct OutfitBuilderFilters: View {
    @Binding var selectedPosition: Position
    @Binding var selectedType: ClothingType?
    @Binding var selectedSeason: Season?
    @Binding var selectedStyle: Style?
    
    var body: some View {
        VStack(spacing: 15) {
            // Pills per la Posizione (Macro)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Position.allCases) { pos in
                        Button(pos.rawValue) {
                            withAnimation {
                                selectedPosition = pos
                                selectedType = nil // Reset tipo quando cambi posizione
                            }
                        }
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(selectedPosition == pos ? Color.black : Color.gray.opacity(0.1))
                        .foregroundColor(selectedPosition == pos ? .white : .primary)
                        .clipShape(Capsule())
                    }
                }.padding(.horizontal)
            }
            
            // Menù a tendina (Micro)
            HStack(spacing: 10) {
                // Filtro Tipo (dinamico)
                Menu {
                    Button("All Types") { selectedType = nil }
                    ForEach(ClothingType.allCases.filter { $0.possiblePositions.contains(selectedPosition) }) { type in
                        Button(type.rawValue) { selectedType = type }
                    }
                } label: {
                    FilterLabel(title: selectedType?.rawValue ?? "Type", icon: "line.3.horizontal.decrease")
                }
                
                // Filtro Stagione
                Menu {
                    Button("All Seasons") { selectedSeason = nil }
                    ForEach(Season.allCases, id: \.self) { s in
                        Button(s.rawValue) { selectedSeason = s }
                    }
                } label: {
                    FilterLabel(title: selectedSeason?.rawValue ?? "Season", icon: "leaf")
                }
                
                // Filtro Stile (aggiornato con enum)
                Menu {
                    Button("All Styles") { selectedStyle = nil }
                    ForEach(Style.allCases) { s in
                        Button(s.rawValue) { selectedStyle = s }
                    }
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
        .cornerRadius(8)
    }
}

// Componente 4: Griglia Armadio
struct ClosetSelectionGrid: View {
    let items: [Cloth]
    let onAdd: (Cloth) -> Void
    
    var body: some View {
        if items.isEmpty {
            // ⭐️ OTTIMIZZAZIONE UX: Usa la View nativa Apple per gli stati vuoti
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
