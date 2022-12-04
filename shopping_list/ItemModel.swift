//
//  ItemModel.swift
//  shopping_list
//

import Foundation

class ItemModel: NSObject, NSCoding {

    var name: String?

    init(name: String) {
        self.name = name
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let value = object as? ItemModel {
            return self.name == value.name
        } else {
            return super.isEqual(object)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
    }
}

