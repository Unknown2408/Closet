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
    
    /// Inizializzatore
    init() {
        load() // Appena la classe viene creata, prova a caricare i dati
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
    func addItem(image: String, position: Position, type: ClothingType,  season: [Season], color: [Color], style: [String], brand: String, description: String ){
        // Rimuovo gli spazi vuori
        let cleanBrand = brand.trimmingCharacters(in: .whitespacesAndNewlines)
        // Creo l'oggetto
        let newItem = Cloth(image: image, position: position, type: type, season: season, color: color, brand: cleanBrand, style: style, description: description)
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
    
}

