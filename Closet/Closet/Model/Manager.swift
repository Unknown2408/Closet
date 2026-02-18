class Manager {
    // La nostra "unica fonte di verità"
    var wardrobe: [Cloth] = []
    
    /// Funzione di filtraggio universale
    func filterWardrobe(
        position: POS? = nil,
        type: TYPE? = nil,
        season: SEASON? = nil,
        color: COL? = nil,
        brand: String? = nil,
        style: String? = nil
    ) -> [Cloth] {
        
        return wardrobe.filter { cloth in
            // Verifica ogni condizione: se il filtro è presente, deve corrispondere
            let matchPosition = position == nil || cloth.position == position
            let matchType = type == nil || cloth.type == type
            let matchSeason = season == nil || cloth.season == season
            
            // Per i campi che sono Array (colori, brand, style), controlliamo se contengono il valore
            let matchColor = color == nil || cloth.color.contains(color!)
            let matchBrand = brand == nil || cloth.brand.contains(where: { $0.lowercased() == brand!.lowercased() })
            let matchStyle = style == nil || cloth.style.contains(where: { $0.lowercased() == style!.lowercased() })
            
            return matchPosition && matchType && matchSeason && matchColor && matchBrand && matchStyle
        }
    }
}
