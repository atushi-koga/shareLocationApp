//  MemberLocationViewController.swift

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class MemberLocationViewController: UIViewController, MKMapViewDelegate,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var slideInView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var memberUid: String?
    var memberName: String!

    // DB上のroot/locationsパス、root/usersパス
    var locationsRef = FIRDatabase.database().reference().child("locations")
    var usersRef = FIRDatabase.database().reference().child("users")
    
    // slideInViewのframe幅を管理
    var slideInViewOpen = false
    
    // 位置データを入れる辞書配列、その位置データを入れる配列、住所を入れる配列を用意
    var locationDic: [String: AnyObject] = [ : ]
    var locationArray:[AnyObject] = []
    var addressArray: [String] = []
    
    // 位置データカウンター
    var dataCount: Int?
    
    // ピンの種類を設定するフラグ
    var annotaionFlag = false
    
    // 強調ピン(青色)を入れる配列
    var annotationArray: [MKPointAnnotation] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テーブルビューの初期設定
        tableView.delegate = self
        tableView.dataSource = self
                
        //マップビューの初期設定
        mapView.delegate = self
        
        // メンバーの位置情報を取得・更新
        locationsRef.child(memberUid!).observeEventType(.ChildAdded, withBlock: { snapshot in
            let valueDictionary = snapshot.value as! [String: AnyObject]
            let dateAndTime = valueDictionary["dateAndTime"] as? String
            let latitude = valueDictionary["latitude"] as? CLLocationDegrees
            let longitude = valueDictionary["longitude"] as? CLLocationDegrees
            let address = valueDictionary["address"] as? String // 0918
            
            if (latitude != nil)&&(longitude != nil)&&(dateAndTime != nil)&&(address != nil) {
                self.locationDic = [ "dateAndTime": dateAndTime!, "latitude": latitude!, "longitude": longitude!, "address": address!]      // 0918
                self.locationArray.insert(self.locationDic, atIndex: 0)
                
                // ピンの設置
                self.settingAnnotation(latitude!, longitude!, dateAndTime!)
            }
        })


         // 位置データの数を取得
         locationsRef.child(memberUid!).observeEventType(.Value, withBlock: { snapshot in
            let valueDictionary = snapshot.value
            self.dataCount = valueDictionary?.count
            
            // 最新の位置履歴をマップの中心とする（無ければ東京駅を中心）
            let newLatitude = self.locationArray.first?["latitude"] as? CLLocationDegrees
            let newLongitude = self.locationArray.first?["longitude"] as? CLLocationDegrees
            let region: MKCoordinateRegion
            if (newLatitude != nil) && (newLongitude != nil) {
                let coordinate = CLLocationCoordinate2DMake(newLatitude!, newLongitude!)
                region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
            } else {
                // 東京駅を中心に四方1,000kmを表示領域に設定
                let coordinate = CLLocationCoordinate2DMake(35.68, 139.76)
                region = MKCoordinateRegionMakeWithDistance(coordinate, 1000000, 1000000)
            }
            self.mapView.setRegion(region, animated: true)
            
            // テーブルビュー更新
            self.tableView.reloadData()
         })
    }

    // ピンの位置、タイトルを設定
    func settingAnnotation(latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, _ dateAndTime: String) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        annotation.title = dateAndTime
        self.mapView.addAnnotation(annotation)
    }

    // ピンを表示。Flagの値により赤色・青色を使い分け    0918
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseIdRed = "pin"
        let reuseIdBlue = "pin2"
        
        // 画面表示時に設置する赤色ピン
        if annotaionFlag == false {
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdRed) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdRed)
                pinView?.animatesDrop = false
                pinView?.canShowCallout = true
            } else {
                pinView?.annotation = annotation
            }
            return pinView
            
        // テーブルセルタップ時に、設置する青色ピン
        } else {
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdBlue) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdBlue)
                pinView?.animatesDrop = true
                pinView?.canShowCallout = true
                pinView?.pinTintColor = UIColor.blueColor()
            } else {
                pinView?.annotation = annotation
            }
            annotaionFlag = false
            return pinView
        }
    }
    
    // セクション数
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // セクション名
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(memberName)さんの位置履歴"
    }
    
    // セル数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationArray.count
    }
    
    // セルのタイトル、サブタイトル
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        // タイトルに時刻を表示
        let dateAndTime = locationArray[indexPath.row]["dateAndTime"] as? String
        cell.textLabel?.text = dateAndTime
        
        // サブタイトルに住所を表示 0918
        let address = locationArray[indexPath.row]["address"] as? String
        cell.detailTextLabel?.text = address

        return cell
    }
    
    // セルタップ時アクション  0918
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // ピン初期化
        self.mapView.removeAnnotations(annotationArray)
        annotationArray = []
        
        // 選択したセルの位置情報を取得
        let latitude = locationArray[indexPath.row]["latitude"] as? CLLocationDegrees
        let longitude = locationArray[indexPath.row]["longitude"] as? CLLocationDegrees
        let time = locationArray[indexPath.row]["dateAndTime"] as? String
        
        // 取得した位置にマップ移動
        if (latitude != nil)&&(longitude != nil)&&(time != nil) {
            let coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
            let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
            self.mapView.setRegion(region, animated: true)
            
            // 強調ピン(青色)を設置
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = time!
            annotationArray.insert(annotation, atIndex: 0)
            annotaionFlag = true
            self.mapView.addAnnotation(annotationArray.first!)
        }
        
        // slideInViewを閉じる
        slideInViewOpen = !self.slideInViewOpen
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.slideInView.frame = self.slideInViewFrame(self.slideInViewOpen)
        })
    }
    
    // slideInViewの初期表示設定
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        slideInView.frame = slideInViewFrame(self.slideInViewOpen)
        slideInView.backgroundColor = UIColor.orangeColor()
    }
    
    // サーチボタンタップでslideInViewの表示切り替え
    @IBAction func tapListButton(sender: AnyObject) {
        slideInViewOpen = !self.slideInViewOpen
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.slideInView.frame = self.slideInViewFrame(self.slideInViewOpen)
        })
    }
    
    // slideInViewの表示/非表示を切り替え
    func slideInViewFrame(open: Bool) -> CGRect {
        var frame = slideInView.frame
        frame.origin.x = self.view.bounds.maxX
        frame.origin.y = self.topLayoutGuide.length
        if open {
            frame.origin.x -= frame.size.width
        }
        return frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
