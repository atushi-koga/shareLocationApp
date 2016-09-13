//  DetailStockViewController.swift

import UIKit
import RealmSwift

class DetailStockViewController: UIViewController {

    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var naviItem: UINavigationItem!
    
    var stock: Stock!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // データソースの情報を、作成画面に反映させる（新規の場合は初期データ）
        categoryTextField.text = stock.category?.name
        nameTextField.text = stock.name
        memoTextView.text = stock.memo
        
        // 背景タップでキーボード閉じる
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailStockViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // 備考欄に枠線付与
        memoTextView.layer.borderWidth = 0.5

    }
    
    @IBAction func tapSaveButton(sender: AnyObject) {
        try! realm.write {
            
            // 以前に同じカテゴリを作成済みか確認
            // 新しいカテゴリ名で保存する時、Categoryオブジェクトを新規作成
            let stockCategory = try! Realm().objects(StockCategory).filter("name = '\(categoryTextField.text!)'").first
            if stockCategory == nil {
                let newStockCategory = StockCategory()
                newStockCategory.name = categoryTextField.text!
                stock.category = newStockCategory
            } else {
                stock.category = stockCategory
            }
            
            stock.name = nameTextField.text!
            stock.memo = memoTextView.text!
            realm.add(stock, update: true)
        }
        //一つ前の画面に戻る
        navigationController?.popViewControllerAnimated(true)
    }
    

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
