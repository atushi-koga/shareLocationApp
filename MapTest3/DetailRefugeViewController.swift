//  DetailRefugeViewController.swift

import UIKit
import RealmSwift

class DetailRefugeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var placeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var telTextField: UITextField!
    @IBOutlet weak var capacityTextField: UITextField!
    @IBOutlet weak var priorytyTextField: UITextField!
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var refuge: Refuge!
    var realm = try! Realm()
    var flag = true
    
    let dfcontentInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    
    // storyboardでのUI部品レイアウトと画面初期表示を合わせる(これがないとなぜかずれる)
    // (navigationControllerのadjustScrollViewControllerの影響？→確認)
    override func viewWillLayoutSubviews() {
        if flag == true {
            scrollView.contentInset = UIEdgeInsetsZero
            scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
            scrollView.contentOffset = CGPointMake(0, 0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        memoTextView.delegate = self
        
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
        scrollView.contentOffset = CGPointMake(0, 0)
        
        // メモ欄に枠線を付与
        memoTextView.layer.borderWidth = 0.5
        
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture = UITapGestureRecognizer(target:self, action:#selector(DetailRefugeViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        // データソースの情報を、作成画面に反映させる（新規の場合は初期データ）
        categoryTextField.text = refuge.category?.name
        placeTextField.text = refuge.place
        addressTextField.text = refuge.address
        telTextField.text = refuge.tel
        capacityTextField.text = refuge.capacity
        priorytyTextField.text = refuge.priority
        memoTextView.text = refuge.memo
    }
    
    // 保存ボタンタップで、作成内容を保存
    @IBAction func tapSaveButton(sender: AnyObject) {
        try! realm.write {
            
            // 以前に同じカテゴリを作成済みか確認
            let category = try! Realm().objects(Category).filter("name = '\(categoryTextField.text!)'").first
            if category == nil {
                // 新しいカテゴリ名で保存する場合、Categoryオブジェクトを新規作成
                let newCategory = Category()
                newCategory.name = categoryTextField.text!
                refuge.category = newCategory
                // 同時にCategoryオブジェクトのownerにrefugeオブジェクトが代入されるLinkingObject)
                
            } else {
                refuge.category = category
            }
            refuge.place = placeTextField.text!
            refuge.address = addressTextField.text!
            refuge.tel = telTextField.text!
            refuge.capacity = capacityTextField.text!
            refuge.priority = priorytyTextField.text!
            refuge.memo = memoTextView.text!
            realm.add(refuge, update: true)
        }
        //一つ前の画面に戻る
        navigationController?.popViewControllerAnimated(true)
    }
    
    // キーボードを閉じる
    func dismissKeyboard() {
        view.endEditing(true)
    }

    // キーボードの出現・消失を見張るオブザーバを設置
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailRefugeViewController.keyboardWillBeShown(_:)), name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailRefugeViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:  UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillBeShown(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue, animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue {
                restoreScrollViewSize()
                
                let convertedKeyboardFrame = scrollView.convertRect(keyboardFrame, fromView: nil)
                let offsetY: CGFloat = CGRectGetMaxY(memoTextView.frame) - CGRectGetMinY(convertedKeyboardFrame)
                if offsetY < 0 {
                    return
                } else {
                    updateScrollViewSize(offsetY, duration: animationDuration)
                }
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        restoreScrollViewSize()
        scrollView.contentOffset = CGPointMake(0, 0)
    }
    
    func updateScrollViewSize(moveSize: CGFloat, duration: NSTimeInterval) {
        // メモ入力の時だけスクロールさせる
        if self.memoTextView.isFirstResponder() {
            flag = false
            UIView.beginAnimations("ResizeForKeyboard", context: nil)
            UIView.setAnimationDuration(duration)
            let contentInsets = UIEdgeInsetsMake(0, 0, moveSize, 0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            scrollView.contentOffset = CGPointMake(0, moveSize)
            UIView.commitAnimations()
        }
    }

    func restoreScrollViewSize() {
        scrollView.contentInset = UIEdgeInsetsZero
        scrollView.scrollIndicatorInsets = UIEdgeInsetsZero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
