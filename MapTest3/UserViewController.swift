//  UserViewController.swift

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var naviItem: UINavigationItem!
    
    // 自身のuid
    var uid: String?
    
    // 登録済みメンバー用配列
    var userArray = [UserData]()
    
    // root/usersパス
    var usersRef = FIRDatabase.database().reference().child("users")
    
    // メンバーのuid、displayName
    var memberUid: String?
    var memberName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        naviItem.title = "登録メンバー"

        uid = FIRAuth.auth()?.currentUser?.uid
        
        // 登録済みユーザを表示（＊nil対応を要追記）
        userArray = []
        usersRef.child(uid!).child("myMembers").observeEventType(.ChildAdded, withBlock: { snapshot in
            let userData = UserData(snapshot: snapshot, myId: self.uid!)
            self.userArray.insert(userData, atIndex: 0)
            self.tableView.reloadData()
        })
    }
    
    // セル数を決定
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    // セルを返す
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = userArray[indexPath.row].name ?? ""
        return cell
    }
    
    // セルタップでメンバー詳細画面へ移動。
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        memberName = userArray[indexPath.row].name
        memberUid = userArray[indexPath.row].uid
        performSegueWithIdentifier("myMemberInfoSegue", sender: nil)
    }
    
    // 詳細画面への移動前処理
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "myMemberInfoSegue" {
            let myMemberInfoViewController:MyMemberInfoViewController = segue.destinationViewController as! MyMemberInfoViewController
            myMemberInfoViewController.memberName = memberName
            myMemberInfoViewController.memberId = memberUid
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

