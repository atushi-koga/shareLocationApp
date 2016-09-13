//  DetailEmergItemViewController.swift

import UIKit
import RealmSwift

class DetailEmergItemViewController: UIViewController {
    
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    @IBOutlet weak var naviItem: UINavigationItem!
    
    var realm = try! Realm()
    var item: Item!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // データソースの情報を、作成画面に反映させる（新規の場合は初期データ）
        categoryTextField.text = item.category?.name
        itemTextField.text = item.name
        memoTextView.text = item.memo

        // 背景タップでキーボード閉じる
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailEmergItemViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // 備考欄に枠線付与
        memoTextView.layer.borderWidth = 0.5
    }
    
    @IBAction func tapSaveButton(sender: AnyObject) {
        try! realm.write {
            
            // 以前に同じカテゴリを作成済みか確認
            // 新しいカテゴリ名で保存する時、Categoryオブジェクトを新規作成
            let itemCategory = try! Realm().objects(ItemCategory).filter("name = '\(categoryTextField.text!)'").first
            if itemCategory == nil {
                let newItemCategory = ItemCategory()
                newItemCategory.name = categoryTextField.text!
                item.category = newItemCategory
            } else {
                item.category = itemCategory
            }
            
            item.name = itemTextField.text!
            item.memo = memoTextView.text!
            realm.add(item, update: true)
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
