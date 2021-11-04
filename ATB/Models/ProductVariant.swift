
import Foundation

class VariantAttribute {
    
    var name = ""
    var value = ""
    
    init() {}
    
    init(info: NSDictionary) {
        name = info["attribute_title"] as? String ?? ""
        value = info["variant_attirbute_value"] as? String ?? ""
    }
}

class ProductVariant {
    
    var id = ""
    var title = ""
    var stock_level = ""
    var price = ""
    var attributes = [VariantAttribute]()
    var isSelected: Bool = true
    
    // only used in editing
    var isUpdated: Bool = false
    
    init(attributes: [VariantAttribute]) {
        self.attributes = attributes
    }
    
    init(info: NSDictionary) {
        self.id = info.object(forKey: "id") as? String ?? ""
        if(self.id == "")
        {
            let nID = info.object(forKey: "id") as? Int ?? 0
            self.id = String(nID)
        }
//        self.title = info.object(forKey: "title") as? String ?? ""

        self.stock_level = info.object(forKey: "stock_level") as? String ?? ""

        self.price = info.object(forKey: "price") as? String ?? ""
        
        if let attributeDicts = info.object(forKey: "attributes") as? [NSDictionary] {
            for attributeDict in attributeDicts {
                let attribute = VariantAttribute(info: attributeDict)
                                
                attributes.append(attribute)
            }
        }        
    }
}

// UI model
class VariationModel {
    
    var name: String = ""
    var values: [String] = []
    var selected: Int?
}
