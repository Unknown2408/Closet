enum SEASON {
    case WINTER;
    case SUMMER;
    case FALLS;
    case SPRING;
}

enum POS: String {
    case TOP = "Tops";
    case BOTTOM = "Bottoms";
    case FOOTWEAR = "Footwear";
    case OUTWEAR = "Outwear";
    case ACCESSORIES = "Accessories";
    case FULLBODY = "Fullbody";
}

enum TYPE{
    
}

enum COL{
    
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


