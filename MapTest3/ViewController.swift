// ViewController.swift

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var slideInView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationButton: UIButton!

    var locationManager: CLLocationManager!
    var timer: NSTimer!
    
    // 自身のuid
    var uid: String?

    // DB上のroot/locationsパス
    var locationsRef = FIRDatabase.database().reference().child("locations")
    
    // slideInViewのframe幅を管理
    var slideInViewOpen = false
    
    // ①位置データを入れる辞書配列、②その位置データを入れる配列、③住所を入れる配列
    var locationDic: [String: AnyObject] = [ : ]
    var locationArray:[AnyObject] = []
    
    // 位置データカウンター
    var dataCount: Int?
    
    // ピンの種類を設定するフラグ
    var annotaionFlag = false
    
    // 強調ピン(青色)を入れる配列
    var annotationArray: [MKPointAnnotation] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ボタン表示の設定
        locationButton.setTitle("現在地を取得する", forState: .Normal)
        locationButton.setTitle("取得中", forState: .Disabled)
        
        // テーブルビューの初期設定
        tableView.delegate = self
        tableView.dataSource = self
        
        // locationButtonの初期設定
        locationButton.layer.borderWidth = 0.8
        locationButton.backgroundColor = UIColor.lightGrayColor()
        locationButton.layer.cornerRadius = 8
        
        // 位置情報認証ステータスを確認。認証なければ設定促す。
        let status = CLLocationManager.authorizationStatus()
        if ((status == .Restricted) || (status == .Denied)) {
            print("ローカル通知で有効にするよう促す")
        }
        
        locationManager = CLLocationManager()
        
        if (status == .NotDetermined) {
            locationManager.requestAlwaysAuthorization()
            print("位置情報サービスリクエストを送信")
        }
        
        // 現在地の表示設定をON
        mapView.showsUserLocation = true
        mapView.delegate = self

        uid = FIRAuth.auth()?.currentUser?.uid
    }
    
    
    // 画面表示のたびに最新位置データ取得、表示
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // データ初期化
        locationArray = []
        mapView.removeAnnotations(mapView.annotations)
        locationsRef.child(uid!).removeAllObservers()
        
        // 自身の位置履歴を取得・更新（DB上にデータない時は、in以降は実行されず）
        locationsRef.child(uid!).observeEventType(.ChildAdded, withBlock: { snapshot in
            let valueDictionary = snapshot.value as! [String : AnyObject]
            let dateAndTime = valueDictionary["dateAndTime"] as? String
            let latitude = valueDictionary["latitude"] as? CLLocationDegrees
            let longitude = valueDictionary["longitude"] as? CLLocationDegrees
            let address = valueDictionary["address"] as? String     // 0918
            
            if (latitude != nil)&&(longitude != nil)&&(dateAndTime != nil)&&(address != nil) {
                self.locationDic = ["dateAndTime": dateAndTime!, "latitude": latitude!, "longitude": longitude!, "address": address!]   // 0918
                self.locationArray.insert(self.locationDic, atIndex: 0)
                
                // ピンの設置
                self.settingAnnotation(latitude!, longitude!, dateAndTime!)
            }
        })
        
        // 位置データの数を取得（locationArrayへのデータ設定完了後に実行）
        locationsRef.child(uid!).observeEventType(.Value, withBlock: { snapshot in
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
    
    // ピンを表示。Flagの値により赤色・青色を使い分け
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        // 現在地アイコン表示
        if annotation is MKUserLocation {
            return nil
        }

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
    
    // 位置取得が失敗した時に呼び出し
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // タイマーを破棄
        if timer != nil {
            if timer.valid {
                timer.invalidate()
            }
        }
        
        // 位置更新ボタン有効化
        locationButton.enabled = true
        locationButton.alpha = 1.0

        // 更新ボタンタップしてもらうようローカル通知
        
        print("位置情報を取得できませんでした。位置情報取得を停止します。")
    }
    
    // 位置情報更新のたびに呼び出し
    var i = 0   // カウンター(デバッグ用)
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("位置情報更新\(i)")
        i = i + 1
        let location = locations.last!
        let nowLati = location.coordinate.latitude
        let nowLongi = location.coordinate.longitude
        print("緯度：\(nowLati)、経度\(nowLongi)")
    }
    
    // ボタンタップで自身の位置情報を取得開始
    @IBAction func tapLocationButton(sender: AnyObject) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.distanceFilter = 1000
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.activityType = CLActivityType.Fitness
            locationManager.allowsBackgroundLocationUpdates = true  // バックグランド下で位置情報取得（capabilities、plist設定済み）
            locationManager.startUpdatingLocation()
            
            // タイマーが既に動作中ならば一旦破棄
            if timer != nil {
                if timer.valid {
                    timer.invalidate()
                }
            }
            
            // 位置情報を1分毎にサーバへ保存するタイマーを作成
            timer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: #selector(ViewController.onTimer(_:)), userInfo: nil, repeats: true)
            
            // ボタン表示変更
            locationButton.enabled = false
            locationButton.alpha = 0.5
        }
        print("位置情報取得開始")
    }
    
    // タイマーメソッド：取得した最新位置情報をサーバへアップ
    func onTimer(timer: NSTimer) {
        if let location = locationManager.location {
            let coordinate: CLLocationCoordinate2D = location.coordinate
            self.upLocation(coordinate.latitude, coordinate.longitude)
            self.removeLocation()
        }
    }
    
    // 0918更新：位置データ(時刻、緯度、経度、住所)をサーバへアップ
    func upLocation(latitude: CLLocationDegrees, _ longitude: CLLocationDegrees) {
        let date = NSDate()
        let dateAndTimeString: String = dateAndTimeFormat(date)

         let myGeocoder: CLGeocoder = CLGeocoder()
         myGeocoder.reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude), completionHandler: {(placemarks, error) in
            var address: String = ""
            if(error == nil) {
                for placemark in placemarks! {
                    // 住所取得できない場合は住所不明、もしくは空文字
                    let administarative = placemark.administrativeArea ?? "住所不明"
                    let locality = placemark.locality ?? ""
                    let thorough = placemark.thoroughfare ?? ""
                    let subthorough = placemark.subThoroughfare ?? ""
                    address = "\(administarative)\(locality)\(thorough)\(subthorough)"
                    
                    // サーバへデータ送信
                    let postData: [String: AnyObject] = ["dateAndTime": dateAndTimeString, "latitude": latitude,    "longitude": longitude, "address": address]
                    self.locationsRef.child(self.uid!).childByAutoId().setValue(postData)
                }
            } else {
                address = "住所不明"
         
                // サーバへデータ送信
                let postData: [String: AnyObject] = ["dateAndTime": dateAndTimeString, "latitude": latitude,    "longitude": longitude, "address": address]
                self.locationsRef.child(self.uid!).childByAutoId().setValue(postData)
            }
            print("サーバへ送信")
        })
    }
    
    // 自身の位置データが96個（2日分）を上回ったら、古い方から削除
    func removeLocation() {
        self.locationsRef.child(uid!).observeEventType(.Value, withBlock: { snapshot in
            let count = snapshot.childrenCount
            var refArray: [FIRDatabaseReference] = []
            for item in snapshot.children {
                let snapshotItem = item as! FIRDataSnapshot
                refArray.insert(snapshotItem.ref, atIndex: 0)
            }
            if count > 5 {
                refArray.last!.removeValue()
            }
        })
    }
    
    // 取得した位置情報の時刻と現在時刻を比較し、ボタンタイトルを設定する
    func setButtonTitle() {
        
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let locationDateString = (locationArray.first!["dateAndTime"] as? String) {
            if let locationDate = formatter.dateFromString(locationDateString) {
                let interval = date.timeIntervalSinceReferenceDate - locationDate.timeIntervalSinceReferenceDate
                if interval < 3600 {
                    locationButton.enabled = false
                    locationButton.alpha = 0.5
                } else {
                    locationButton.enabled = true
                    locationButton.alpha = 1.0
                }
            }
        }
    }
    
    // セクション数を設定
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    // セクション名
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "あなたの位置履歴"
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


     // セルタップ時アクション
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
    
    // slideInViewを全表示もしくは一部表示
    func slideInViewFrame(open: Bool) -> CGRect {
        var frame = slideInView.frame
        frame.origin.x = self.view.bounds.maxX
        frame.origin.y = self.topLayoutGuide.length
        if open {
            frame.origin.x -= frame.size.width
        }
        return frame
    }
    
    // 画面消える時、slideInViewを閉じる
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        slideInViewOpen = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.slideInView.frame = self.slideInViewFrame(self.slideInViewOpen)
        })
    }
    
    // NSDateを日付&時刻のString型に変換
    func dateAndTimeFormat(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateAndTimeString: String = formatter.stringFromDate(date)
        return dateAndTimeString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
