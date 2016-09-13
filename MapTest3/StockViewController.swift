//  StockViewController.swift

import UIKit
import RealmSwift

class StockViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    let realm = try! Realm()
    
    // カテゴリ名の異なるStockCategoryオブジェクトが複数入る
    var stockCategories = try! Realm().objects(StockCategory)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // ナビゲーションバータイトル
        naviItem.title = "備蓄品"
    }
    
    // 入力画面から戻った時にテーブルビューを更新
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // カテゴリ名変更に伴い、Stockオブジェクトが0になった既存カテゴリを削除
        for stockCategory in stockCategories {
            if stockCategory.owner.count == 0 {
                try! realm.write {
                    realm.delete(stockCategory)
                }
            }
        }
        tableView.reloadData()
    }
    
    // カテゴリ毎にセクションを用意
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return stockCategories.count
    }
    
    // カテゴリ名をセクション名とする
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let stockCategory = stockCategories[section]
        return stockCategory.name
    }
    
    // Categoryオブジェクトに含まれるownerプロパティの数をセル数とする
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let stockCategory = stockCategories[section]
        return stockCategory.owner.count
    }
    
    // セルタイトル
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        let stockCategory = stockCategories[indexPath.section]
        cell.textLabel?.text = stockCategory.owner[indexPath.row].name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell

 }
    
    // セルタップ時に編集画面へ遷移
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("detailStockSegue", sender: nil)
    }
    
    // 遷移先の画面へデータ渡す
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Document画面

        if segue.identifier == "exit" {
        } else {
            
            let detailStockViewController = segue.destinationViewController as! DetailStockViewController
            
            // 編集画面
            if segue.identifier == "detailStockSegue" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let stockCategory = stockCategories[indexPath!.section]
                detailStockViewController.stock = stockCategory.owner[indexPath!.row]
                detailStockViewController.naviItem.title = "\(stockCategory.owner[indexPath!.row].name)"
            } else {
                
                // 新規作成画面
                let stock = Stock()
                let stockArray = try! Realm().objects(Stock)
                if stockArray.count != 0 {
                    stock.id = stockArray.max("id")! + 1
                }
                detailStockViewController.stock = stock
                // 他の画面にも適用させる
                detailStockViewController.naviItem.title = "新規登録"
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
                let stockCategory = stockCategories[indexPath.section]
                self.realm.delete(stockCategory.owner[indexPath.row])
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                if stockCategory.owner.count == 0 {
                    self.realm.delete(stockCategory)
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
