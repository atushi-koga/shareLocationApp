//
//  Stock.swift
//  MapTest3
//
//  Created by Mahina on 2016/09/02.
//  Copyright © 2016年 atsushi koga. All rights reserved.
//

import RealmSwift

class Stock: Object {

    // 管理用プライマリーキー
    dynamic var id = 1
    
    // カテゴリ
    dynamic var category: StockCategory?
    
    // 名前
    dynamic var name = ""
    
    dynamic var memo = ""
    
    // idをプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
