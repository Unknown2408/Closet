import Foundation
import Observation
import SwiftUI

// 1. SEASONS (Stagioni)
enum Season: String, CaseIterable, Codable {
    case winter = "Winter"
    case summer = "Summer"
    case fall = "Fall"   // "Autumn" va bene pure, ma Fall è standard US
    case spring = "Spring"
}

// 2. POSITION (Macro-Categorie)
enum Position: String, CaseIterable, Codable, Identifiable {
    case top = "Tops"
    case bottom = "Bottoms"
    case footwear = "Footwear"
    case outerwear = "Outerwear" // Corretto da "Outwear"
    case accessories = "Accessories"
    case fullbody = "Fullbody"
    
    // ID che ritorna il valore della stringa associata
    var id: String { self.rawValue }
}

// 3. CLOTHING TYPE (Micro-Categorie)
enum ClothingType: String, CaseIterable, Codable, Identifiable {
    // TOP
    case tShirt = "T-shirts"
    case shirt = "Shirts"
    case sweater = "Sweaters"
    case tops = "Tops" // Mantenuto come richiesto
    case cardigan = "Cardigans"
    case hoodie = "Hoodies"
    
    // Bottoms
    case skirt = "Skirts"
    case trousers = "Trousers" // o "Pants"
    case shorts = "Shorts"
    case jeans = "Jeans"
    
    // Outerwear
    case coat = "Coats"
    case jacket = "Jackets"
    case cape = "Capes"
    
    // Full body
    case dress = "Dresses"
    case jumpsuit = "Jumpsuits"
    case suit = "Suits"
    case robe = "Robes"
    
    // Activewear (Uncountable nouns, treated as plural context)
    case activewear = "Activewear"
    case workwear = "Workwear"
    
    // Accessories
    case bag = "Bags"
    case tie = "Ties"
    case scarf = "Scarves"
    case belt = "Belts"
    case glasses = "Glasses"
    case hat = "Hats"
    case jewellery = "Jewellery"
    
    // Footwear
    case flats = "Flats"
    case heels = "Heels"
    case sandals = "Sandals"
    case sneakers = "Sneakers"
    case boots = "Boots"
    
    var id: String { self.rawValue }
    
    // LOGICA DELLE POSIZIONI
    var possiblePositions: [Position] {
        switch self {
        case .tShirt, .shirt, .sweater, .cardigan, .hoodie, .tops:
            return [.top]
            
        case .skirt, .trousers, .shorts, .jeans:
            return [.bottom]
            
        case .coat, .jacket, .cape:
            return [.outerwear]
            
        case .dress, .jumpsuit, .suit, .robe:
            return [.fullbody]
            
        case .bag, .tie, .scarf, .belt, .glasses, .hat, .jewellery:
            return [.accessories]
            
        case .flats, .heels, .sandals, .sneakers, .boots:
            return [.footwear]
            
        case .activewear:
            return [.top, .bottom, .fullbody]
            
        case .workwear:
            return [.top, .bottom, .fullbody, .outerwear]
        }
    }
}

// DA FARE
// Ho aggiunto Codable per poterlo salvare nel JSON insieme al vestito
enum Color: String, CaseIterable, Codable {
    case RED = "Red"
}


// Ho aggiunto Identifiable (per le liste UI) e Codable (per il salvataggio)
struct Cloth: Identifiable, Codable {
    // ID per l'inserimento nell'inventory
    var id = UUID()
    
    // immagine associata
    var image: String
    
    // variabili per la ricerca
    var position : Position
    var type : ClothingType
    var season : [Season]
    var color: [Color]
    var brand: String
    var style: [String]
    var description: String
    
    var favourite: Bool = false
}

struct Outfit: Identifiable, Codable {
    var id = UUID()
    let outfitName: String
    
    var items: [UUID]
    
    var favourite: Bool = false
    var dateCreated: Date = Date()
}

