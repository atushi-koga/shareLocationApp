//  DocumentViewController.swift

import UIKit

class DocumentViewController: UIViewController {
    
    @IBOutlet weak var refugeButton: UIButton!
    @IBOutlet weak var itemButton: UIButton!
    @IBOutlet weak var stockButton: UIButton!

    
    override func viewDidLayoutSubviews() {
        refugeButton.layer.borderWidth = 1.2
        refugeButton.backgroundColor = UIColor.orangeColor()
        itemButton.layer.borderWidth = 1.2
        itemButton.backgroundColor = UIColor.orangeColor()
        stockButton.layer.borderWidth = 1.2
        stockButton.backgroundColor = UIColor.orangeColor()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
