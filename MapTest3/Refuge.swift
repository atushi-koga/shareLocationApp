//  Refuge.swift
// *プロパティを追加した時は、古い.realmファイルを更新するため、simulator内のアプリアイコンを一度削除してから再ビルドを行う。

import RealmSwift

class Refuge: Object {
    
    // 管理用プライマリーキー
    dynamic var id = 1
    
    // カテゴリ
    dynamic var category: Category?
    
    // 場所
    dynamic var place = ""
    
    // 住所
    dynamic var address = ""
    
    // 電話番号
    dynamic var tel = ""
    
    // 収容人数
    dynamic var capacity = ""
    
    // 優先度
    dynamic var priority = "1"
    
    // メモ
    dynamic var memo = ""
        
    // idをプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }

}

