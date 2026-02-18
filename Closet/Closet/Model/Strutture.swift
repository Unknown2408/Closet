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


struct cloth {
    let position : [POS]
    let type : [TYPE]
    let season : [SEASON]
    
    let brand: [String]
    let style: [String]
}
