//
//  ItemCategory.swift
//  MapTest3
//
//  Created by Mahina on 2016/08/27.
//  Copyright © 2016年 atsushi koga. All rights reserved.
//

import RealmSwift

class ItemCategory: Object {

    dynamic var name = ""
    dynamic var type = 0
    let owner = LinkingObjects(fromType: Item.self, property: "category")
    
}
