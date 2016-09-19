//  InitialViewController.swift

import UIKit
import ESTabBarController
import Firebase
import FirebaseAuth

class InitialViewController: UIViewController {
    
    var tabSet = "初期画面"
    
    override func viewDidAppear(animated: Bool) {
        
        // ログイン済み → タブ画面
        // 非ログイン → ログイン画面
        if FIRAuth.auth()?.currentUser != nil {
            setupTab()
        } else {
            dispatch_async(dispatch_get_main_queue()) {
                let loginViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Login")
                // モーダル表示
                self.presentViewController(loginViewController!, animated: true, completion: nil)
            }
        }
    }

    func setupTab() {
        let tabBarController = ESTabBarController(tabIconNames: ["Document",  "Location", "User", "Setting"])
        tabBarController.selectedColor = UIColor(red: 1.0, green: 0.44, blue: 0.11, alpha: 1.0)
        tabBarController.buttonsBackgroundColor = UIColor(red: 0.96, green: 0.91, blue: 0.87, alpha: 1.0)
        addChildViewController(tabBarController)
        view.addSubview(tabBarController.view)
        tabBarController.view.frame = self.view.bounds
        tabBarController.didMoveToParentViewController(self)
        
        
        // 各タブにViewControllerを割り当て
        // "Location"、"User"はナビゲーションバー表示のため、NavigationControllerを割り当て
        let documentViewController = storyboard?.instantiateViewControllerWithIdentifier("Document")
        tabBarController.setViewController(documentViewController, atIndex: 0)
        let locationViewController = storyboard?.instantiateViewControllerWithIdentifier("Location")
        tabBarController.setViewController(locationViewController, atIndex: 1)
        let userViewController = storyboard?.instantiateViewControllerWithIdentifier("User")
        tabBarController.setViewController(userViewController, atIndex: 2)
        let settingViewController = storyboard?.instantiateViewControllerWithIdentifier("Setting")
        tabBarController.setViewController(settingViewController, atIndex: 3)
        
        // 起動画面の設定
        switch tabSet {
            case "Location":
                tabBarController.setSelectedIndex(1, animated: false)
            case "User":
                tabBarController.setSelectedIndex(2, animated: false)
            case "Setting":
                tabBarController.setSelectedIndex(3, animated: false)
            default:
                tabBarController.setSelectedIndex(0, animated: false)
                break
        }
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
