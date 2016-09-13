//  EmergItemViewController.swift

import UIKit
import RealmSwift

class EmergItemViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var itemCategories = try! Realm().objects(ItemCategory)
    let realm = try! Realm()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // カテゴリ名変更に伴い、Itemオブジェクトが0になった既存カテゴリを削除
        for category in itemCategories {
            if category.owner.count == 0 {
                try! realm.write {
                    realm.delete(category)
                }
            }
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        naviItem.title = "非常用持ち出し品"
    }
    
    // カテゴリの数だけセクションを用意
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return itemCategories.count
    }
    
    // カテゴリ名をセクション名とする
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return itemCategories[section].name
    }
    
    // 同カテゴリ内のitem数をセル数とする
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemCategories[section].owner.count
    }

    // セルタイトルを持ち出し品名とする
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let itemCategory = itemCategories[indexPath.section]
        cell.textLabel!.text = itemCategory.owner[indexPath.row].name
        return cell
    }
    
    // セルタップ時に作成画面へ遷移
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("detailEmergItemSegue", sender: nil)
    }
    
    // 画面遷移時にデータ渡す
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Document画面
        if segue.identifier == "exit" {
        } else {
            
            let detailEmergItemViewController = segue.destinationViewController as! DetailEmergItemViewController
            
            if segue.identifier == "detailEmergItemSegue" {
                // 編集画面
                let indexPath = tableView.indexPathForSelectedRow
                let itemCategory = itemCategories[indexPath!.section]
                detailEmergItemViewController.item = itemCategory.owner[indexPath!.row]
                detailEmergItemViewController.naviItem.title = itemCategory.owner[indexPath!.row].name
            } else {
                // 新規作成画面
                let item = Item()
                let itemArray = try! Realm().objects(Item)
                if itemArray.count != 0 {
                    item.id = itemArray.max("id")! + 1
                }
                detailEmergItemViewController.item = item
            }
        }
    }
    
    // セルの編集モード（削除）
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    // Deleteボタンタップ時にセル削除、セル=0ならばセクション削除
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            try! realm.write {
                let category = itemCategories[indexPath.section]
                realm.delete(category.owner[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                if category.owner.count == 0 {
                    realm.delete(category)
                    tableView.reloadData()
                }
            }
        }
    }
    
    // 編集ボタンタップで、セルを編集モードに変更
    @IBAction func tapEditButton(sender: AnyObject) {
        let edit = !self.tableView.editing
        tableView.setEditing(edit, animated: true)
        if edit == true {
            self.editButton.title = "完了"
        } else {
            self.editButton.title = "編集"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
