// PostData.swift
// 投稿データ読み込み用クラス。読み込みたいデータをプロパティに持ち、Firebaseからの読み込みコードを設定しておくことで、読み込み場所でのコードを簡素化させる。

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase

class PostData: NSObject {
    
    var id: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    var position: String?
    var date: NSDate?

    init(snapshot: FIRDataSnapshot, myId: String) {
        self.id = snapshot.key
        let valueDictionary = snapshot.value as! [String: AnyObject]
        
        self.latitude = valueDictionary["latitude"] as? CLLocationDegrees
        self.longitude = valueDictionary["longitude"] as? CLLocationDegrees
        self.position = valueDictionary["address"] as? String
        self.date = NSDate(timeIntervalSinceReferenceDate: valueDictionary["time"] as! NSTimeInterval)
        
    }
}
