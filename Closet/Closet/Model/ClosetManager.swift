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
    /// Regole di abbinamento
    var colorRules: [String: [String]] = [:]
    
    ///Definisco la cartella in cui andranno salvati i dati (da capire se serve effettivamente se usiamo già parthenokit)
    private var archiveURL: URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("closet.json")
    }
    
    // MEMORIA
    /// Creo la struct in cui inserire i dati da salvare
    private struct ClosetData: Codable{
        var inventory: [Cloth]
        var outfits: [Outfit]
    }
    
    /// Carico il file json
    func loadColorRules() -> [String: [String]] {
        // 1. Uso 'guard let' per assicurarmi che l'URL esista senza forzare con il '!'
        guard let url = Bundle.main.url(forResource: "ColorRules", withExtension: "json") else {
            print("Errore: File ColorRules.json non trovato!")
            return [:] // Restituisco un dizionario vuoto come piano B
        }
        
        let decoder = JSONDecoder()
        
        // 2. Apro il do-catch e uso i 'try' normali (senza punto esclamativo)
        do {
            let data = try Data(contentsOf: url)
            let colorRules = try decoder.decode([String: [String]].self, from: data)
            return colorRules
        } catch {
            // 3. Se i dati sono illeggibili o il JSON è scritto male, catturo l'errore
            print("Errore durante la decodifica dei colori: \(error)")
            return [:] // Piano B anche qui
        }
    }
    
    /// Inizializzatore
    init() {
        load() // Appena la classe viene creata, prova a caricare i dati
        self.colorRules = loadColorRules()
    }
    
    /// Definisco la funzione save
    func save() {
        let encoder = JSONEncoder() // creo l'encoder
        let dataToSave = ClosetData(inventory: inventory, outfits: outfits) // inserisco i dati da salvare
        
        encoder.outputFormatting = .prettyPrinted // do un formato leggibile per il file
        
        do{ // salvo
            let data = try encoder.encode(dataToSave)
            try data.write(to: archiveURL)
            print("Salvataggio effettuato con successo")
        } catch{
            print("Errore durante la salvataggio: \(error)")
        }
    }
    
    /// Definisco la funzione per in caricamento dei dati all'apertura dell'app
    func load(){
        let decoder = JSONDecoder()
        do{
            let data = try Data(contentsOf: archiveURL)
            let loadedData = try decoder.decode(ClosetData.self, from: data)
            self.inventory = loadedData.inventory
            self.outfits = loadedData.outfits
            print("Caricamento effettuato con successo")
        } catch {
            print("Errore durante il caricamento: \(error)")
        }
    }
    
    // Gestione dei vestiti
    
    /// Aggiunta di un indumento all'inventario
    func addItem(image: Data, position: Position, type: ClothingType,  season: [Season], coloreIndumento: [coloreIndumento], style: [String], brand: String, description: String ){
        // Rimuovo gli spazi vuori
        let cleanBrand = brand.trimmingCharacters(in: .whitespacesAndNewlines)
        // Creo l'oggetto
        let newItem = Cloth(image: image, position: position, type: type, season: season, coloreIndumentoRicerca: coloreIndumento, brand: cleanBrand, style: style, description: description)
        // inserisco nell'inventario
        inventory.append(newItem)
        save()
    }
    
    /// Rimozione capo
    func removeItem(withID id: UUID){
        // Ricerca dell'indice
        if let index = inventory.firstIndex(where: { $0.id == id }) {
            inventory.remove(at: index)
            save()
        }
    }
    
    // Funzione per eliminazione multipla (Bulk Delete)
    // Accetta un Set<UUID> perché è quello che ci restituisce la lista di SwiftUI
    func deleteMultipleItems(withIds ids: Set<UUID>) {
        
        // LOGICA DEL FILTRO:
        // "Ricostruisci l'inventario tenendo solo gli elementi il cui ID
        // NON (!) è contenuto nella lista 'ids' da cancellare"
        inventory = inventory.filter { item in
            !ids.contains(item.id)
        }
        save()
    }
    
    /// Contrassegno capi preferiti
    func toggleFavorite(ofItemWithID id: UUID){
        if let index = inventory.firstIndex(where: {$0.id == id}) {
            inventory[index].favourite.toggle()
            save()
        }
    }
    
    // Gestione outfit
    
    /// Aggiunta outfit
    func addOutfit(name: String, items: [UUID]){
        var newOutfit = Outfit(outfitName: name, items: items)
        outfits.append(newOutfit)
        save()
    }
    
    func deleteOutfit(id: UUID){
        if let index = outfits.firstIndex(where: { $0.id == id }) {
            outfits.remove(at: index)
            save()
        }
    }
        
    func deleteMultipleOutfits(withIds ids: Set<UUID>) {
            
        // LOGICA DEL FILTRO:
        // "Ricostruisci l'inventario tenendo solo gli elementi il cui ID
        // NON (!) è contenuto nella lista 'ids' da cancellare"
        outfits = outfits.filter { outfit in
            !ids.contains(outfit.id)
        }
        save()
    }
    
    /// Restituisce i capi reali appartenenti a un determinato outfit
    func items(for outfit: Outfit) -> [Cloth] {
        return inventory.filter { outfit.items.contains($0.id) }
    }
    
    // COLOR MATCHING
    /// Suggerisce capi compatibili con un outfit in costruzione
    func getCascadingSuggestions(for selectedItems: [Cloth]) -> [Cloth] {
        
        // Se l'utente non ha ancora selezionato nulla, non suggeriamo niente
        // (oppure potresti ritornare l'intero 'inventory')
        guard !selectedItems.isEmpty else { return [] }
        
        // 1. ELIMINIAMO I DOPPIONI: Capiamo quali parti del corpo sono già "vestite"
        // Creiamo un array con le posizioni (Top, Bottom, ecc.) già presenti nell'outfit
        let occupiedPositions = selectedItems.map { $0.position }
        
        // 2. TROVIAMO I COLORI IN COMUNE (L'Intersezione)
        var commonValidColors: Set<String> = []
        
        // Prendiamo i colori compatibili con il PRIMO capo selezionato
        if let firstItem = selectedItems.first,
           let firstColor = firstItem.coloreIndumentoRicerca.first {
            let compatibleWithFirst = colorRules[firstColor.rawValue] ?? []
            commonValidColors = Set(compatibleWithFirst)
        }
        
        // Ora cicliamo sui capi successivi (se ci sono) e restringiamo il cerchio
        // dropFirst() salta il primo capo che abbiamo già analizzato
        // Ora cicliamo sui capi successivi (se ci sono) e restringiamo il cerchio
        for item in selectedItems.dropFirst() {
                
            if let color = item.coloreIndumentoRicerca.first {
                // 1. Diciamo esplicitamente a Swift che questa è una Stringa
                let colorString: String = color.rawValue
                
                // 2. Estraiamo l'array dal dizionario. Se non c'è, restituiamo un array di stringhe vuoto
                let arrayColoriCompatibili: [String] = colorRules[colorString] ?? []
                    
                // 3. Convertiamo l'array in un Set in modo esplicito
                let compatibleWithItem: Set<String> = Set(arrayColoriCompatibili)
                    
                // 4. Facciamo l'intersezione matematica
                commonValidColors.formIntersection(compatibleWithItem)
            }
        }
        
        // 3. FILTRIAMO L'INVENTARIO
        let suggestions = inventory.filter { item in
            // Regola A: Il capo non deve coprire una parte del corpo già vestita
            let isPositionFree = !occupiedPositions.contains(item.position)
            
            // Regola B: Il capo deve avere un colore che rientra nei "commonValidColors"
            let hasValidColor = item.coloreIndumentoRicerca.contains { color in
                commonValidColors.contains(color.rawValue)
            }
            
            return isPositionFree && hasValidColor
        }
        
        return suggestions
    }
    
}
