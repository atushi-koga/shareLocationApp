//  UserData.swift

import UIKit
import Firebase
import FirebaseDatabase


class UserData: NSObject {
    
    var id: String?
    
    // ユーザ用の名前、uid
    var name: String?
    var uid: String?
    
    init(snapshot: FIRDataSnapshot, myId: String) {
        self.id = snapshot.key
        if let valueDictionary = snapshot.value as? [String: AnyObject] {
            name = valueDictionary["name"] as? String
            uid = valueDictionary["uid"] as? String
        }
    }
}
