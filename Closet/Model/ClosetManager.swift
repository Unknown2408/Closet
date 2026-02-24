import Foundation
import Observation
import SwiftUI

// Fonte di verità per mantenere lo stato condiviso fra le interfacce
@Observable class ClosetManager {
    // SET-Up
    /// Array in cui depositiamo ogni capo
    public var inventory: [Cloth] = []
    /// Array in cui depositiamo gli outfit
    public var outfits: [Outfit] = []
    
    // NUOVO: Vettore dinamico dei brand
    public var brands: [String] = ["Adidas", "Gucci", "H&M", "Levi's", "Nike", "Unbranded", "Zara"]
    
    /// Regole di abbinamento
    var colorRules: [String: [String]] = [:]
    
    /// Definisco la cartella in cui andranno salvati i dati
    private var archiveURL: URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("closet.json")
    }
    
    // MEMORIA
    /// Creo la struct in cui inserire i dati da salvare
    private struct ClosetData: Codable {
        var inventory: [Cloth]
        var outfits: [Outfit]
        var brands: [String]? // Opzionale per non far crashare i vecchi salvataggi senza brand
    }
    
    /// Carico il file json dei colori
    func loadColorRules() -> [String: [String]] {
        guard let url = Bundle.main.url(forResource: "ColorRules", withExtension: "json") else {
            print("Errore: File ColorRules.json non trovato!")
            return [:]
        }
        
        let decoder = JSONDecoder()
        
        do {
            let data = try Data(contentsOf: url)
            let colorRules = try decoder.decode([String: [String]].self, from: data)
            return colorRules
        } catch {
            print("Errore durante la decodifica dei colori: \(error)")
            return [:]
        }
    }
    
    /// Inizializzatore
    init() {
        load() // Appena la classe viene creata, prova a caricare i dati
        self.colorRules = loadColorRules()
    }
    
    /// Definisco la funzione save
    func save() {
        let encoder = JSONEncoder()
        // Salviamo anche i brand dinamici!
        let dataToSave = ClosetData(inventory: inventory, outfits: outfits, brands: brands)
        
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try encoder.encode(dataToSave)
            try data.write(to: archiveURL)
            print("Salvataggio effettuato con successo")
        } catch {
            print("Errore durante la salvataggio: \(error)")
        }
    }
    
    /// Definisco la funzione per in caricamento dei dati all'apertura dell'app
    func load() {
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: archiveURL)
            let loadedData = try decoder.decode(ClosetData.self, from: data)
            self.inventory = loadedData.inventory
            self.outfits = loadedData.outfits
            
            // Carichiamo i brand salvati. Se è la prima volta, mantiene quelli di default
            if let savedBrands = loadedData.brands {
                self.brands = savedBrands
            }
            
            print("Caricamento effettuato con successo")
        } catch {
            print("Nessun dato precedente trovato o errore caricamento: \(error)")
        }
    }
    
    // NUOVA FUNZIONE: Aggiunta Brand
    func addNewBrand(_ brandName: String) {
        let cleanName = brandName.trimmingCharacters(in: .whitespacesAndNewlines).capitalized
        // Se non è vuoto e non esiste già, lo aggiunge e salva
        if !cleanName.isEmpty && !brands.contains(cleanName) {
            brands.append(cleanName)
            brands.sort() // Mantiene l'ordine alfabetico
            save()
        }
    }
    
    // Gestione dei vestiti (Corretto per usare l'enum Style e tolto l'errore di battitura)
    func addItem(image: Data, name: String, position: Position, type: ClothingType, season: [Season], coloreIndumento: [coloreIndumento], style: [Style], brand: String) {
        let cleanBrand = brand.trimmingCharacters(in: .whitespacesAndNewlines)
        let newItem = Cloth(image: image, name: name, position: position, type: type, season: season, coloreIndumentoRicerca: coloreIndumento, brand: cleanBrand, style: style)
        inventory.append(newItem)
        save()
    }
    
    func removeItem(withID id: UUID) {
        if let index = inventory.firstIndex(where: { $0.id == id }) {
            inventory.remove(at: index)
            save()
        }
    }
    
    // (Corretto per usare l'enum Style)
    func updateItem(id: UUID, image: Data, name: String, position: Position, type: ClothingType, season: [Season], coloreIndumento: [coloreIndumento], style: [Style], brand: String) {
            if let index = inventory.firstIndex(where: { $0.id == id }) {
                let cleanBrand = brand.trimmingCharacters(in: .whitespacesAndNewlines)
                
                inventory[index].image = image
                inventory[index].name = name
                inventory[index].position = position
                inventory[index].type = type
                inventory[index].season = season
                inventory[index].coloreIndumentoRicerca = coloreIndumento
                inventory[index].style = style
                inventory[index].brand = cleanBrand
                
                save()
            }
    }
    
    func deleteMultipleItems(withIds ids: Set<UUID>) {
        inventory = inventory.filter { !ids.contains($0.id) }
        save()
    }
    
    func toggleFavorite(ofItemWithID id: UUID) {
        if let index = inventory.firstIndex(where: {$0.id == id}) {
            inventory[index].favourite.toggle()
            save()
        }
    }
    
    func toggleFavorite(ofOutfitWithID id: UUID) { // <-- Guarda qui, ho cambiato il nome!
            if let index = outfits.firstIndex(where: { $0.id == id }) {
                outfits[index].favourite.toggle()
                save()
            }
    }
    
    
    // Gestione outfit
    func addOutfit(name: String, items: [UUID]) {
        let newOutfit = Outfit(outfitName: name, items: items)
        outfits.append(newOutfit)
        save()
    }
    
    // Funzione per aggiornare un outfit esistente
    func updateOutfit(id: UUID, newName: String, newItems: [UUID]) {
        if let index = outfits.firstIndex(where: { $0.id == id }) {
            outfits[index].outfitName = newName
            outfits[index].items = newItems
            save() // Salva sul disco
        }
    }
    
    func deleteOutfit(id: UUID) {
        if let index = outfits.firstIndex(where: { $0.id == id }) {
            outfits.remove(at: index)
            save()
        }
    }
        
    func deleteMultipleOutfits(withIds ids: Set<UUID>) {
        outfits = outfits.filter { !ids.contains($0.id) }
        save()
    }
    
    // Funzione per impostare come preferiti più outfit contemporaneamente
    func markAsFavorite(outfitIDs: Set<UUID>, isFavorite: Bool = true) {
        for id in outfitIDs {
            if let index = outfits.firstIndex(where: { $0.id == id }) {
                outfits[index].favourite = isFavorite
            }
        }
        save() // Salviamo sul disco una sola volta dopo averli modificati tutti!
    }
    
    func items(for outfit: Outfit) -> [Cloth] {
        return inventory.filter { outfit.items.contains($0.id) }
    }
    
    // COLOR MATCHING
    func getCascadingSuggestions(for selectedItems: [Cloth]) -> [Cloth] {
        guard !selectedItems.isEmpty else { return [] }
                
        let occupiedPositions = selectedItems.map { $0.position }
        var commonValidColors: Set<String> = []
                
        if let firstItem = selectedItems.first,
           let firstColor = firstItem.coloreIndumentoRicerca.first {
            let compatibleWithFirst = colorRules[firstColor.rawValue] ?? []
            commonValidColors = Set(compatibleWithFirst)
        }
                
        for item in selectedItems.dropFirst() {
            if let color = item.coloreIndumentoRicerca.first {
                let colorString: String = color.rawValue
                let arrayColoriCompatibili: [String] = colorRules[colorString] ?? []
                let compatibleWithItem: Set<String> = Set(arrayColoriCompatibili)
                commonValidColors.formIntersection(compatibleWithItem)
            }
        }
                
        let suggestions = inventory.filter { item in
                    
            // ⭐️ NUOVA REGOLA DEL LAYERING:
            let isPositionFree: Bool
                        
            if item.position == .outerwear {
                // Massimo 2 Outerwear sovrapposti (es. Hoodie + Jacket)
                let outerwearCount = occupiedPositions.filter { $0 == .outerwear }.count
                isPositionFree = outerwearCount < 2
            } else if item.position == .accessories {
                // Nessun limite per gli accessori!
                isPositionFree = true
            } else {
                // Per tops, pantaloni e scarpe: limite ferreo di 1 solo capo
                isPositionFree = !occupiedPositions.contains(item.position)
            }
                        
            let hasValidColor = item.coloreIndumentoRicerca.contains { color in
                commonValidColors.contains(color.rawValue)
            }
                        
            return isPositionFree && hasValidColor
        }
                
        return suggestions
    }
}
