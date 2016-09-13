//  SettingViewController.swift

import UIKit
import Firebase
import FirebaseAuth

class SettingViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    // root/usersパス
    let usersRef = FIRDatabase.database().reference().child("users")
    
    var uid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = FIRAuth.auth()?.currentUser?.uid
        idLabel.text = uid
        
        // ID、アカウント名をLabelに設定
        let ud = NSUserDefaults.standardUserDefaults()
        var accountName = ud.valueForKey("DISPLAYNAME") as? String
        
        // アカウント名をNSUserDefaultsで取得できなかった場合
        if accountName == nil {
            usersRef.child(uid!).observeEventType(.Value, withBlock: { snapshot in
                let valueDictionary = snapshot.value as! [String : AnyObject]
                accountName = valueDictionary["name"] as? String
                self.nameLabel.text = accountName
            })
        }
        else {
            nameLabel.text = accountName
        }
    }
    
    func setUserInfo() {
        uid = FIRAuth.auth()?.currentUser?.uid
        idLabel.text = uid
        
        // ID、アカウント名をLabelに設定
        let ud = NSUserDefaults.standardUserDefaults()
        var accountName = ud.valueForKey("DISPLAYNAME") as? String
        
        // アカウント名をNSUserDefaultsで取得できなかった場合
        if accountName == nil {
            usersRef.child(uid!).observeEventType(.Value, withBlock: { snapshot in
                let valueDictionary = snapshot.value as! [String : AnyObject]
                accountName = valueDictionary["name"] as? String
                self.nameLabel.text = accountName
            })
        }
        else {
            nameLabel.text = accountName
        }
    }

    // ログアウトボタンタップ
    @IBAction func tapLogoutButton(sender: AnyObject) {
        
        // ログアウト
        try! FIRAuth.auth()?.signOut()
        
        // ログイン画面を表示
        let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Login")
        self.presentViewController(loginViewController!, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
