//
//  StockCategory.swift
//  MapTest3
//
//  Created by Mahina on 2016/09/02.
//  Copyright © 2016年 atsushi koga. All rights reserved.
//

import RealmSwift

class StockCategory: Object {

    dynamic var name: String = ""
    dynamic var type: Int = 0
    let owner = LinkingObjects(fromType: Stock.self, property: "category")
    
}
