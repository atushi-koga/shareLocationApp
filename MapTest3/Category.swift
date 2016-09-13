//
//  Category.swift
//  MapTest3
//
//  Created by Mahina on 2016/08/25.
//  Copyright © 2016年 atsushi koga. All rights reserved.
//

import RealmSwift

class Category: Object {
    
    dynamic var name: String = ""
    dynamic var type: Int = 0
    let owner = LinkingObjects(fromType: Refuge.self, property: "category")
}
