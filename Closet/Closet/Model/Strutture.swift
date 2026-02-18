enum SEASON: String, CaseIterable {
    case WINTER;
    case SUMMER;
    case FALLS;
    case SPRING;
}

enum POS: String, CaseIterable {
    case TOP = "Tops";
    case BOTTOM = "Bottoms";
    case FOOTWEAR = "Footwear";
    case OUTWEAR = "Outwear";
    case ACCESSORIES = "Accessories";
    case FULLBODY = "Fullbody";
    
    var id: String {self.rawValue}
    
}

enum TYPE: String, CaseIterable{
    // TOP
    case T_SHIRT
    case SHIRT
    case SWEATER
    case TOPS
    case JUMPER_AND_CARDIGANS
    case HOODIES_AND_SWEATSHIRTS
    case ACTIVEWEAR
    // Bottoms
    case SKIRTS
    case TROUSERS
    case SHORTS
    case JEANS
    //case ACTIVEWEAR
    // Outwear
    case COATS
    case JACKETS
    case CAPES
    // Full body
    case Dress
    case JUMPSUITS
    case SUITS
    case WORKWEAR
    case BODIES
    // case ACTIVEWEAR
    case ROBES
    // Accessories
    case BAGS
    case TIES
    case SCARVES_AND_GLOVES
    case SOCKS_AND_TIGHTS
    case BELTS
}

enum COL: String, CaseIterable{
    case RED = "Red"
}


struct Cloth {
    let position : POS
    let type : TYPE
    let season : SEASON
    
    var color: [COL]
    var brand: [String]
    var style: [String]
    var description: [String]
}

struct Outfit{
    let outfit_name: String
    var indument: [Cloth]
    let favourite: Bool
}


