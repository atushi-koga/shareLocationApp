//  UserSearchViewController.swift

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth


class UserSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // 自身のuid保持
    var uid: String?
    
    // 登録したいユーザ用配列
    var userArray = [UserData]()
    
    // usersパス
    var usersRef = FIRDatabase.database().reference().child("users")
    
    // 登録したいユーザのuid、displayNameの保存先
    var searchId: String?
    var newMemberName: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = FIRAuth.auth()?.currentUser?.uid
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        tableView.delegate = self
        tableView.dataSource = self
        naviItem.title = "新規登録"
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchId = self.searchBar.text
        userArray = []
        
        // searchWordをもとにデータ選別、テーブルビューを更新
        usersRef.child(searchId!).observeEventType(.Value, withBlock: { snapshot in
            
            // snapshotのnull判定
            if snapshot.exists() {
                let userData = UserData(snapshot: snapshot, myId: self.uid!)
                self.userArray.insert(userData, atIndex: 0)
                self.tableView.reloadData()
                print("snapshot.extists() == true")
            } else {
                print("snapshot.extists() == false")
                return
            }
        })
        // キーボード閉じる
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.searchBar.text = ""
        
        // テーブビューを白紙に更新
        userArray = []
        self.tableView.reloadData()
    }
    
    // セル数を決定
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
    
    // セルを返す
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let userData = userArray[indexPath.row]
        if let name = userData.name {
            cell.textLabel?.text = name
            newMemberName = name
        }
        return cell
    }
    
    // セルタップ時のアクション。既存ユーザ → ユーザ情報の確認、新規ユーザ → ユーザIDの保存。
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        performSegueWithIdentifier("newMemberInfoSegue", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        if segue.identifier == "newMemberInfoSegue" {
            let userInfoViewController = segue.destinationViewController as! UserInfoViewController
            userInfoViewController.newMemberName = self.newMemberName!
            userInfoViewController.newMemberUid = searchId!
        }
        
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
