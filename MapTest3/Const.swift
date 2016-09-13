//
//  Const.swift
//  MapTest3
//
//  Created by Mahina on 2016/08/05.
//  Copyright © 2016年 atsushi koga. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

struct CommonConst {
    
    // アカウント名保持用
    static let DisplayNameKey = "DISPLAYNAME"
    
    // 自身のユーザID
    static let uid: String! = FIRAuth.auth()?.currentUser?.uid
    
    // 共通位置情報保存先パス
    static let LocationPath = "locations"
    
    // ユーザ情報（ロケーションId用の辞書配列）
    static var locationId: String = "location_" + uid

}