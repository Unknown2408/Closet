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
        }
    }
}

// 4. COLORI (Espanso a 20 colori per combaciare con la UI)
enum coloreIndumento: String, CaseIterable, Codable {
    // Scala di grigi e neutri
    case white = "White"
    case lightGray = "Light Gray"
    case gray = "Gray"
    case darkGray = "Dark Gray"
    case black = "Black"
    
    // Marroni e Beige
    case beige = "Beige"
    case brown = "Brown"
    
    // Rossi, Rosa e Viola
    case red = "Red"
    case maroon = "Maroon"
    case pink = "Pink"
    case purple = "Purple"
    case magenta = "Magenta"
    
    // Gialli e Arancioni
    case orange = "Orange"
    case yellow = "Yellow"
    
    // Verdi e Blu
    case green = "Green"
    case olive = "Olive"
    case teal = "Teal"
    case cyan = "Cyan"
    case blue = "Blue"
    case navy = "Navy"
}

enum Style: String, CaseIterable, Codable, Identifiable {
    case streetwear = "Streetwear"
    case sporty = "Sporty"
    case elegant = "Elegant"
    case formal = "Formal"
    case casual = "Casual"
    
    var id: String { self.rawValue }
}

// Ho aggiunto Identifiable (per le liste UI) e Codable (per il salvataggio)
struct Cloth: Identifiable, Codable {
    // ID per l'inserimento nell'inventory
    var id = UUID()
    
    // immagine associata
    var image: Data
    
    // variabili per la ricerca
    var name: String
    var position : Position
    var type : ClothingType
    var season : [Season]
    var coloreIndumentoRicerca: [coloreIndumento]
    var brand: String
    var style: [Style]
    
    
    var favourite: Bool = false
}

struct Outfit: Identifiable, Codable {
    var id = UUID()
    var outfitName: String
    
    var items: [UUID]
    var favourite: Bool = false
    var dateCreated: Date = Date()
}
