import SwiftUI

struct ClosetContentView: View {
    @Environment(ClosetManager.self) private var manager
    @State private var showingAddItem = false
    
    // MARK: - Stati per i Filtri
    @State private var selectedSeason: Season? = nil
    @State private var selectedStyle: Style? = nil
    @State private var selectedBrand: String? = nil
    
    // Configurazione griglia a 2 colonne
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    // MARK: - Logica di Filtraggio
    var filteredInventory: [Cloth] {
        manager.inventory.filter { item in
            // 1. Filtro Stagione
            let matchesSeason = selectedSeason == nil || item.season.contains(selectedSeason!)
            // 2. Filtro Stile
            let matchesStyle = selectedStyle == nil || item.style.contains(selectedStyle!)
            // 3. Filtro Brand
            let matchesBrand = selectedBrand == nil || item.brand == selectedBrand
            
            return matchesSeason && matchesStyle && matchesBrand
        }
    }
    
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
                    .padding(.bottom, 10)
                    
                    // CONTROLLO EMPTY STATE (Se l'armadio è vuoto davvero, non se è vuoto per i filtri)
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
                        
                        // MARK: - BARRA DEI FILTRI (Le "Isolette")
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                
                                // 1. Tasto Reset (appare solo se c'è un filtro attivo)
                                if selectedSeason != nil || selectedStyle != nil || selectedBrand != nil {
                                    Button(action: {
                                        withAnimation {
                                            selectedSeason = nil
                                            selectedStyle = nil
                                            selectedBrand = nil
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .font(.title3)
                                    }
                                }
                                
                                // 2. Filtro STAGIONE
                                Menu {
                                    Button("All", action: { selectedSeason = nil })
                                    ForEach(Season.allCases, id: \.self) { season in
                                        Button(season.rawValue) { selectedSeason = season }
                                    }
                                } label: {
                                    FilterChipView(
                                        title: selectedSeason?.rawValue ?? "Season",
                                        isSelected: selectedSeason != nil
                                    )
                                }
                                
                                // 3. Filtro STILE
                                Menu {
                                    Button("All", action: { selectedStyle = nil })
                                    ForEach(Style.allCases, id: \.self) { style in
                                        Button(style.rawValue) { selectedStyle = style }
                                    }
                                } label: {
                                    FilterChipView(
                                        title: selectedStyle?.rawValue ?? "Style",
                                        isSelected: selectedStyle != nil
                                    )
                                }
                                
                                // 4. Filtro BRAND
                                Menu {
                                    Button("All", action: { selectedBrand = nil })
                                    ForEach(manager.brands, id: \.self) { brand in
                                        Button(brand) { selectedBrand = brand }
                                    }
                                } label: {
                                    FilterChipView(
                                        title: selectedBrand ?? "Brand",
                                        isSelected: selectedBrand != nil
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        }
                        
                        // Vista normale con la griglia dei vestiti
                        ScrollView {
                            VStack(alignment: .leading, spacing: 15) {
                                
                                // Mostra il numero di capi trovati se stiamo filtrando
                                if selectedSeason != nil || selectedStyle != nil || selectedBrand != nil {
                                    Text("Found: \(filteredInventory.count)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .padding(.horizontal)
                                } else {
                                    Text("Featured")
                                        .font(.title2.bold())
                                        .padding(.top, 10)
                                        .padding(.horizontal)
                                }
                                
                                // Griglia con i dati FILTRATI
                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(filteredInventory) { item in
                                        NavigationLink(destination: DetailedView(cloth: item)) {
                                            ClothCard(cloth: item)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 16)
                            }
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

// MARK: - Componente Visivo Isoletta
struct FilterChipView: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Image(systemName: "chevron.down")
                .font(.caption2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(isSelected ? Color.black : Color.white)
        .foregroundColor(isSelected ? Color.white : Color.black)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.3), lineWidth: isSelected ? 0 : 1)
        )
    }
}
