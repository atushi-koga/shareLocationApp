//  RefugeViewController.swift

import UIKit
import RealmSwift

class RefugeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    let realm = try! Realm()
    
    // カテゴリ名の異なるCategoryオブジェクトが複数入る
    var categories = try! Realm().objects(Category)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ナビゲーションバータイトル
        naviItem.title = "災害時避難場所"        
    }
    
    // 入力画面から戻った時にテーブルビューを更新
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // カテゴリ名変更に伴い、Refugeオブジェクトが0になった既存カテゴリを削除
        for category in categories {
            if category.owner.count == 0 {
                try! realm.write {
                    realm.delete(category)
                }
            }
        }
        tableView.reloadData()
    }
    
    // カテゴリ毎にセクションを用意
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categories.count
    }
    
    // カテゴリ名をセクション名とする
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = categories[section]
        return category.name
    }
    
    // Categoryオブジェクトに含まれるownerプロパティの数をセル数とする
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = categories[section]
        return category.owner.count
    }
    
    // セルタイトル
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let category = categories[indexPath.section]
        cell.textLabel?.text = category.owner[indexPath.row].place
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    // セルタップ時に編集画面へ遷移
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("detailRefugeSegue", sender: nil)
    }

    // 遷移先の画面へデータ渡す
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Document画面
        if segue.identifier == "exit" {
        } else {
            
        let detailRefugeViewController = segue.destinationViewController as! DetailRefugeViewController
        
            // 編集画面
            if segue.identifier == "detailRefugeSegue" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let category = categories[indexPath!.section]
                detailRefugeViewController.refuge = category.owner[indexPath!.row]
                detailRefugeViewController.naviItem.title = "\(category.owner[indexPath!.row].place)"
            } else {
                
                // 新規作成画面
                let refuge = Refuge()
                let refugeArray = try! Realm().objects(Refuge)
                if refugeArray.count != 0 {
                    refuge.id = refugeArray.max("id")! + 1
                }
                detailRefugeViewController.refuge = refuge
            }
        }
    }
    
    // セルの編集モード（削除）
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    // Deleteボタンタップ時にセル削除、セル=0ならばセクション削除
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            try! realm.write {
                let category = categories[indexPath.section]
                self.realm.delete(category.owner[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                if category.owner.count == 0 {
                    self.realm.delete(category)
                    tableView.reloadData()
                }
            }
        }
    }
    
    // 編集ボタンタップで、セルを編集モードに変更
    @IBAction func tapEditButton(sender: AnyObject) {
        let edit = !self.tableView.editing
        self.tableView.setEditing(edit, animated: true)
        if edit == true {
            self.editButton.title = "完了"
        } else {
            self.editButton.title = "編集"
        }
    }
    
    @IBAction func unwind (segue: UIStoryboardSegue) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
