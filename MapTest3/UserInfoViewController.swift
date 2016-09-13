//  UserInfoViewController.swift

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class UserInfoViewController: UIViewController {
    
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var uidLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!

    var newMemberName: String?
    var newMemberUid: String?
    var myUid: String?
    var usersRef = FIRDatabase.database().reference().child("users")
    var myMembersRef: FIRDatabaseReference!
    var logRef: FIRDatabaseReference!
    
    //  DBに登録済みかどうかを判定するフラグ
    var flagMymember = false
    var flagLog = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviItem.title = "新規メンバー情報"
        nameLabel.text = self.newMemberName
        uidLabel.text = self.newMemberUid
        
        myUid = FIRAuth.auth()?.currentUser?.uid
        
        myMembersRef = usersRef.child(myUid!).child("myMembers")
        logRef = usersRef.child(myUid!).child("log")
        
        // 登録済みメンバーかどうか確認
        myMembersRef.observeEventType(.Value, withBlock: { snapshot in
            // uidを比較
            for item in snapshot.children {
                let FIRitem = item as! FIRDataSnapshot
                let valueDictionary = FIRitem.value as? [String: AnyObject]
                let itemUid = valueDictionary!["uid"] as? String
                if itemUid! == self.newMemberUid! {
                    print("myMemberに登録済み")
                    self.flagMymember = true
                    break
                }
            }
            
            // 必要？
            self.logRef.child(self.newMemberUid!).observeEventType(.Value, withBlock: { snapshot in
                if snapshot.exists() == true {
                    self.flagLog = true
                    print("logに登録済み")
                }
                
                // 既に登録済みの場合
                if (self.flagMymember == true) && (self.flagLog == true) {
                    self.registerButton.setTitle("登録済み", forState: .Normal)
                    self.registerButton.enabled = false
                }
            })
        })
    }
    
    @IBAction func tapRegister(sender: AnyObject) {
        
        if flagMymember == false {
            // myMemberに登録されてないので新たに登録
            myMembersRef.childByAutoId().setValue(["name": self.newMemberName!, "uid": self.newMemberUid!])
        }
        
        if flagLog == false {
            // logに登録されてないので新たに登録
            logRef.child(self.newMemberUid!).setValue(["location": true])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
