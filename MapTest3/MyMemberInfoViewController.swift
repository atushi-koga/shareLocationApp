//
//  MyMemberInfoViewController.swift
//  MapTest3
//
//  Created by Mahina on 2016/08/20.
//  Copyright © 2016年 atsushi koga. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class MyMemberInfoViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    
    // 自身のuid
    var uid: String?
    
    // 選択したメンバーの名前、uid
    var memberName: String?
    var memberId: String?
    
    // DB上のroot/usersパス
    var usersRef = FIRDatabase.database().reference().child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // メンバーの名前、IDをラベルに設定
        uid = FIRAuth.auth()?.currentUser?.uid
        nameLabel.text = memberName
        idLabel.text = memberId
        
        // 位置確認ボタンの表示設定
        locationButton.layer.borderWidth = 1.2
        locationButton.backgroundColor = UIColor.orangeColor()
        
    }

    // 許可された時のみ、選択したメンバーの位置確認画面へ遷移
    @IBAction func tapLocationButton(sender: AnyObject) {
        
        // メンバーの位置確認が許可されているか判定（プッシュ通知による許可に変更予定）
        usersRef.child(uid!).child("log").child(memberId!).observeEventType(.Value, withBlock: { snapshot in
            if snapshot.exists() == true {
                self.performSegueWithIdentifier("memberLocation", sender: nil)
            } else {
                // 許可無いことを通知
                SVProgressHUD.showErrorWithStatus("許可されていません")
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // 位置確認画面への遷移時に、メンバーのuidを渡す
        if segue.identifier == "memberLocation" {
            let memberLocationViewController = segue.destinationViewController as! MemberLocationViewController
            memberLocationViewController.memberUid = memberId
            memberLocationViewController.memberName = memberName
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
