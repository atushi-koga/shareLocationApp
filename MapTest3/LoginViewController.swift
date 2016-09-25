//  LoginViewController.swift

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var textFieldMailAddress: UITextField!
    @IBOutlet weak var textFIeldPassword: UITextField!
    @IBOutlet weak var textFIeldAccount: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var accountButton: UIButton!
    
    
    // アカウント作成時のユーザ情報保存先パス
    let usersRef = FIRDatabase.database().reference().child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ボタン表示の設定
        loginButton.layer.borderWidth = 1.2
        loginButton.backgroundColor = UIColor.orangeColor()
        accountButton.layer.borderWidth = 1.2
        accountButton.backgroundColor = UIColor.orangeColor()
        
        // 背景をタップしたらキーボードを閉じる
        let tapGesture = UITapGestureRecognizer(target:self, action:#selector(DetailRefugeViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // キーボードを閉じる
    func dismissKeyboard() {
        view.endEditing(true)
    }

    // ログインボタンタップ
    @IBAction func tapButtonLogin(sender: AnyObject) {
        if let address = textFieldMailAddress.text, let password = textFIeldPassword.text {
            if address.characters.isEmpty || password.characters.isEmpty {
                
                // ローカル通知表示
                setLocalNotification("エラー", "必要項目を入力してください")
                return
            }
            // 処理中を表示
            SVProgressHUD.show()
            
            FIRAuth.auth()?.signInWithEmail(address, password: password, completion: { user, error in
                if error != nil {
                    self.setLocalNotification("エラー", "メールアドレスとパスワードを確認してください")
                    SVProgressHUD.dismiss()
                    
                } else {
                    if let displayName = user?.displayName {
                        self.setDisplayName(displayName)
                    }
                    
                    SVProgressHUD.showSuccessWithStatus("ログイン完了")
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            })
        }
    }
    
    // アカウント作成ボタンタップ
    @IBAction func tapButtonAccountCreate(sender: AnyObject) {
            if let address = textFieldMailAddress.text, let password = textFIeldPassword.text,
                let displayName = textFIeldAccount.text {
                if address.characters.isEmpty || password.characters.isEmpty || displayName.characters.isEmpty {
                    
                    setLocalNotification("エラー", "必要項目を入力してください")
                    return
                }
                SVProgressHUD.show()
                
                FIRAuth.auth()?.createUserWithEmail(address, password: password) { user, error in
                    if error != nil {
                        self.setLocalNotification("エラー", "メールアドレスとパスワードを確認してください")
                        SVProgressHUD.dismiss()
                        
                    } else {
                        FIRAuth.auth()?.signInWithEmail(address, password: password) {user, error in
                            if error != nil {
                                self.setLocalNotification("エラー", "アカウントを作成しましたが、ログインできませんでした。\n" + "再度ログインを試みてください。")
                                SVProgressHUD.dismiss()
                                
                            } else {
                                if let user = user {
                                    let request = user.profileChangeRequest()
                                    request.displayName = displayName
                                    request.commitChangesWithCompletion() { error in
                                        if error != nil {
                                            print(error)
                                        } else {
                                            self.setDisplayName(displayName)
                                            
                                            // ユーザ情報保存
                                            print("CommonConst.uid")
                                            print(CommonConst.uid)
                                            print("FIRAuth.auth()?.currentUser?.uid")
                                            print(FIRAuth.auth()?.currentUser?.uid)
                                            self.usersRef.child((FIRAuth.auth()?.currentUser?.uid)!).setValue(["name": displayName])
                                            self.usersRef.child((FIRAuth.auth()?.currentUser?.uid)!).child("log").child((FIRAuth.auth()?.currentUser?.uid)!).setValue(["location": true])
                                            
                                            
                                            SVProgressHUD.showSuccessWithStatus("アカウント作成完了")
                                            self.dismissViewControllerAnimated(true, completion: nil)
                                        }
                                    }
                                }
                            }
                        }
                }
        }
        
    }
        
    }
    
    // ローカル通知を作成
    func setLocalNotification(title: String, _ message: String) {
        let notification = UILocalNotification()
        notification.fireDate = NSDate()
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertTitle = title
        notification.alertBody = message
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    // NSUserDefaultsに表示名を保存
    func setDisplayName(name: String) {
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setValue(name, forKey: "DISPLAYNAME")
        ud.synchronize()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
