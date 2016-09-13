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
    
    var uid: String?
    var memberUid: String?
    var memberName: String!

    // DB上のroot/locationsパス、root/usersパス
    var locationsRef = FIRDatabase.database().reference().child("locations")
    var usersRef = FIRDatabase.database().reference().child("users")
    
    // slideInViewのframe幅を管理
    var slideInViewOpen = false
    
    // ①位置データを入れる辞書配列、②その位置データを入れる配列、③住所を入れる配列
    var locationDic: [String: AnyObject] = [ : ]
    var locationArray:[AnyObject] = []
    var addressArray: [String] = []
    
    // 位置データカウンター
    var dataCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テーブルビューの初期設定
        tableView.delegate = self
        tableView.dataSource = self
        
        // slideInviewの初期設定
        slideInView.layer.borderWidth = 1.0
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MemberLocationViewController.slideView(_:)))
        slideInView.addGestureRecognizer(tapGestureRecognizer)
        
        //マップビューの初期設定
        mapView.delegate = self
        
        // 自身のuidを取得
//        uid = FIRAuth.auth()?.currentUser?.uid
        
        // メンバーの位置情報を取得・更新
        locationsRef.child(memberUid!).observeEventType(.ChildAdded, withBlock: { snapshot in
            let valueDictionary = snapshot.value as! [String: AnyObject]
            let latitude = valueDictionary["latitude"] as? CLLocationDegrees
            let longitude = valueDictionary["longitude"] as? CLLocationDegrees
            let dateAndTime = valueDictionary["dateAndTime"] as? String
            
            if (latitude != nil)&&(longitude != nil)&&(dateAndTime != nil) {
                self.locationDic = ["latitude": latitude!, "longitude": longitude!, "dateAndTime": dateAndTime!]
                self.locationArray.insert(self.locationDic, atIndex: 0)
                
                // ピンの設置
                self.settingAnnotation(latitude!, longitude!, dateAndTime!)
            }
        })


         // 位置データの数を取得
         locationsRef.child(memberUid!).observeEventType(.Value, withBlock: { snapshot in
            let valueDictionary = snapshot.value
            self.dataCount = valueDictionary!.count
            self.addressArray = [String](count: self.dataCount, repeatedValue: "")
         
            // 逆ジオコーディング結果をlocationArrayと紐付けするために数字ラベルを付与
            var count = 0
            for location in self.locationArray {
                count = count + 1
                let latitude = location["latitude"] as? CLLocationDegrees
                let longitude = location["longitude"] as? CLLocationDegrees
                self.reverseGeocode(latitude!, longitude!, count)
            }
         })

    }
    
    // 逆ジオコーディング
    func reverseGeocode(latitude: CLLocationDegrees, _ longitude: CLLocationDegrees, _ count: Int) {
        let myGeocoder: CLGeocoder = CLGeocoder()
        myGeocoder.reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude), completionHandler: {(placemarks, error) in
            var address: String = ""
            if(error == nil) {
                for placemark in placemarks! {
                    // 住所取得できない場合は住所不明、もしくは空文字。
                    let administarative = placemark.administrativeArea ?? "住所不明"
                    let locality = placemark.locality ?? ""
                    let thorough = placemark.thoroughfare ?? ""
                    let subthorough = placemark.subThoroughfare ?? ""
                    address = "\(administarative)\(locality)\(thorough)\(subthorough)"
                }
            } else {
                address = "住所不明"
            }
            self.addressArray[count - 1] = address
            
            // 最新の位置履歴をマップの中心とする（無ければ東京駅を中心）
            let newLatitude = self.locationArray.first?["latitude"] as? CLLocationDegrees
            let newLongitude = self.locationArray.first?["longitude"] as? CLLocationDegrees
            let region: MKCoordinateRegion
            if (newLatitude != nil) && (newLongitude != nil) {
                let coordinate = CLLocationCoordinate2DMake(newLatitude!, newLongitude!)
                region = MKCoordinateRegionMakeWithDistance(coordinate, 100000, 100000)
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

    // ピン追加時に呼び出し
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
            pinView?.canShowCallout = true
        } else {
            pinView?.annotation = annotation
        }
        return pinView
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
        
        // サブタイトルに住所を表示
        if addressArray.count == locationArray.count {
            let address = addressArray[indexPath.row]
            cell.detailTextLabel?.text = address
        }
/*
        let latitude = locationArray[indexPath.row]["latitude"] as? CLLocationDegrees
        let longitude = locationArray[indexPath.row]["longitude"] as? CLLocationDegrees
        
        // 逆ジオコーディング
        let myGeocoder: CLGeocoder = CLGeocoder()
        myGeocoder.reverseGeocodeLocation(CLLocation(latitude: latitude!, longitude: longitude!), completionHandler: {(placemarks, error) in
            if(error == nil) {
                for placemark in placemarks! {
                    // 取得できない住所は空文字。
                    let administarative = placemark.administrativeArea ?? "住所不明"
                    let locality = placemark.locality ?? ""
                    let thorough = placemark.thoroughfare ?? ""
                    let subthorough = placemark.subThoroughfare ?? ""
                    cell.detailTextLabel?.text = "\(administarative)\(locality)\(thorough)\(subthorough)"
                }
            } else {
                cell.detailTextLabel?.text = "住所不明"
            }
        })
*/
        return cell
    }
    
    // slideInViewの初期表示設定
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        slideInView.frame = slideInViewFrame(self.slideInViewOpen)
        slideInView.backgroundColor = UIColor.orangeColor()
    }
    
    // slideInViewタップ時のアクション
    func slideView(tapGestureRecognizer: UITapGestureRecognizer) {
        if tapGestureRecognizer.view != nil {
            slideInViewOpen = !self.slideInViewOpen
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.slideInView.frame = self.slideInViewFrame(self.slideInViewOpen)
            })
        }
    }
    
    // slideInViewを全表示もしくは一部表示
    func slideInViewFrame(open: Bool) -> CGRect {
        var frame = slideInView.frame
        frame.origin.x = self.view.bounds.maxX
        frame.origin.y = self.topLayoutGuide.length + 30
        if open {
            frame.origin.x -= frame.size.width
        } else {
            frame.origin.x -= 20
        }
        return frame
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
