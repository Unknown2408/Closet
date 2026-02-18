import Foundation

// 1. STAGIONI
enum Season: String, CaseIterable, Codable {
    case winter = "Inverno"
    case summer = "Estate"
    case falls = "Autunno" // Di solito è "Fall" o "Autumn"
    case spring = "Primavera"
}

// 2. POSIZIONE (Macro-Categorie)
enum Position: String, CaseIterable, Codable, Identifiable {
    case top = "Tops"
    case bottom = "Bottoms"
    case footwear = "Footwear"
    case outwear = "Outwear" // O "Outerwear"
    case accessories = "Accessories"
    case fullbody = "Fullbody"
    
    var id: String { self.rawValue }
}

// 3. TIPO DI CAPO (Micro-Categorie)
enum ClothingType: String, CaseIterable, Codable, Identifiable {
    // TOP
    case tShirt = "T-shirt"
    case shirt = "Camicia"
    case sweater = "Maglione"
    // case TOPS (Rimosso: è ridondante avere una categoria generica dentro i tipi specifici)
    case cardigan = "Cardigan"
    case hoodie = "Felpa"
    
    // Bottoms
    case skirt = "Gonna"
    case trousers = "Pantaloni"
    case shorts = "Pantaloncini"
    case jeans = "Jeans"
    
    // Outwear
    case coat = "Cappotto"
    case jacket = "Giacca"
    case cape = "Mantella"
    
    // Full body
    case dress = "Abito"
    case jumpsuit = "Tuta Intera"
    case suit = "Completo"
    case robe = "Accappatoio/Vestaglia"
    
    // Activewear (Caso speciale multi-ruolo)
    case activewear = "Abbigliamento Sportivo"
    case workwear = "Abbigliamento Lavoro"
    
    // Accessories
    case bag = "Borsa"
    case tie = "Cravatta"
    case scarf = "Sciarpa"
    case belt = "Cintura"
    case glasses = "Occhiali"
    case hat = "Cappello"
    case jewellery = "Gioielli"
    
    // Footwear
    case flats = "Scarpe Basse"
    case heels = "Tacchi"
    case sandals = "Sandali"
    case sneakers = "Sneakers"
    case boots = "Stivali"
    
    var id: String { self.rawValue }
    
    // LOGICA CORRETTA DELLE POSIZIONI
    var possiblePositions: [Position] {
        switch self {
        case .tShirt, .shirt, .sweater, .cardigan, .hoodie:
            return [.top]
            
        case .skirt, .trousers, .shorts, .jeans:
            return [.bottom]
            
        case .coat, .jacket, .cape:
            return [.outwear] // CORRETTO (Era .BOTTOM prima)
            
        case .dress, .jumpsuit, .suit, .robe:
            return [.fullbody]
            
        case .bag, .tie, .scarf, .belt, .glasses, .hat, .jewellery:
            return [.accessories]
            
        case .flats, .heels, .sandals, .sneakers, .boots:
            return [.footwear]
            
        case .activewear:
            return [.top, .bottom, .fullbody] // Rimosso duplicato
            
        case .workwear:
            return [.top, .bottom, .fullbody, .outwear]
        }
    }
}

// DA FARE
enum COL: String, CaseIterable{
    case RED = "Red"
}


struct Cloth {
    var id = UUID()
    
    var position : [Position]
    let type : ClothingType
    var season : [Season]
    
    var color: [COL]
    var brand: String
    var style: [String]
    var description: String
}

struct Outfit{
    var id = UUID()
    let outfit_name: String
    
    var items: [UUID]
    
    var favourite: Bool = false
    var dateCrated: Date = Date()
}


