import SwiftUI

struct CategoryDetailView: View {
    @Environment(ClosetManager.self) var manager
    
    // Il tipo di vestito che stiamo visualizzando (es. T-Shirt)
    let selectedType: ClothingType
    
    // MARK: - Stati per i Filtri
    @State private var selectedSeason: Season? = nil
    @State private var selectedStyle: Style? = nil
    @State private var selectedBrand: String? = nil
    
    // Configurazione Griglia
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    // MARK: - Logica di Filtraggio Combinata
    var filteredClothes: [Cloth] {
        return manager.inventory.filter { item in
            // 1. Filtro Base: Deve corrispondere al TIPO della categoria attuale
            let typeMatch = item.type == selectedType
            
            // 2. Filtri Opzionali (Isolette)
            let seasonMatch = selectedSeason == nil || item.season.contains(selectedSeason!)
            let styleMatch = selectedStyle == nil || item.style.contains(selectedStyle!)
            let brandMatch = selectedBrand == nil || item.brand == selectedBrand
            
            return typeMatch && seasonMatch && styleMatch && brandMatch
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - BARRA DEI FILTRI (Isolette)
            // La mettiamo fuori dalla ScrollView principale così rimane fissa in alto
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    
                    // Tasto Reset (appare solo se c'è un filtro attivo)
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
                    
                    // Filtro STAGIONE
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
                    
                    // Filtro STILE
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
                    
                    // Filtro BRAND
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
            .background(Color.white) // Assicura che lo sfondo sia opaco mentre scorri sotto
            
            Divider()
            
            // MARK: - GRIGLIA CONTENUTO
            ScrollView {
                if filteredClothes.isEmpty {
                    VStack(spacing: 20) {
                        Spacer(minLength: 100)
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No item found")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Try to modify the filters or add new items")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredClothes) { cloth in
                            // Ho aggiunto il NavigationLink per coerenza con l'altra vista
                            NavigationLink(destination: DetailedView(cloth: cloth)) {
                                ClothCard(cloth: cloth)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(selectedType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Assicurati di avere FilterChipView definito nel progetto (come nella risposta precedente).
// Se serve, eccolo di nuovo per comodità (puoi metterlo in un file separato UtilityViews.swift per non ripeterlo):
/*
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
*/
