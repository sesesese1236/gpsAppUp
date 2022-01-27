//
//  ViewController.swift
//  gpsAppUp
//
//  Created by WENDRA RIANTO on 2022/01/06.
//

import UIKit
import CoreLocation
import MapKit
import RealmSwift

class YourExistence : Object{
    @objc dynamic var id:String = NSUUID().uuidString
    @objc dynamic var time:Date? = nil
    @objc dynamic var latitude:Double = 0
    @objc dynamic var longitude:Double = 0
    @objc dynamic var altitude:Double = 0
    @objc dynamic var group:String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{

    
    @IBOutlet weak var labelLat: UILabel!
    @IBOutlet weak var labelLon: UILabel!
    @IBOutlet weak var labelSpeed: UILabel!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var btnStart: UIButton!
    let status = CLLocationManager.authorizationStatus()
    var locationManager : CLLocationManager!
    @IBOutlet weak var mapView: MKMapView!
    public var startDate:Date? = nil
    public var stopDate:Date? = nil
    let userCalendar = Calendar.current
    var groupDate:Date? = nil
    public var searchDate:Date? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager=CLLocationManager()
        
        
        
        let config = Realm.Configuration(schemaVersion:1)
        Realm.Configuration.defaultConfiguration = config
        
        locationManager.requestWhenInUseAuthorization()
        if checkAuthorization(){
            locationManager.delegate = self
            locationManager.distanceFilter = 1
//            locationManager.startUpdatingLocation()
        }
        btnStop.isEnabled = false
        
        mapView.delegate = self
        mapView.mapType = MKMapType.hybrid
        mapUpdate()
        
        mapView.removeAnnotations(mapView.annotations)
        
        if(startDate != nil && stopDate != nil){
            annotation()
        }else if(searchDate != nil){
            annotation()
        }
        let testcords:[CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 35.6804, longitude: 139.7690),
            CLLocationCoordinate2D(latitude: 36.2380, longitude: 137.9720),
            CLLocationCoordinate2D(latitude: 34.6937, longitude: 135.5023)]
        let polyLine = MKPolyline(coordinates: testcords, count: testcords.count)
        mapView.addOverlay(polyLine)
    }


    @IBAction func clickStart(_ sender: UIButton) {
        if checkAuthorization(){
            locationManager.startUpdatingLocation()
        }
        groupDate = Date()
        mapUpdate()
        switchOnOff()
    }
    
    @IBAction func clickSearch(_ sender: UIButton) {
        if checkAuthorization(){
            if(btnStart.isEnabled == false){
                locationManager.stopUpdatingLocation()
                mapView.userTrackingMode = MKUserTrackingMode.none
                
                btnStop.isEnabled = false
                btnStart.isEnabled = true
            }
        }
    }
    
    @IBAction func clickStop(_ sender: UIButton) {
        if checkAuthorization(){
            locationManager.stopUpdatingLocation()
        }
        mapView.userTrackingMode = MKUserTrackingMode.none
        switchOnOff()
        groupDate = nil
    }
    
    
    func mapUpdate(){
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        mapView.userTrackingMode = MKUserTrackingMode.follow
    }
    
    
    func checkAuthorization() -> Bool{
        if status == CLAuthorizationStatus.authorizedAlways ||
            status == CLAuthorizationStatus.authorizedWhenInUse {
            return true
        }else{
            return false
        }
    }
    
    
    func switchOnOff(){
        btnStart.isEnabled = !(btnStart.isEnabled)
        btnStop.isEnabled = !(btnStop.isEnabled)
    }
    
    
    func locationManager(_ manager:CLLocationManager,didUpdateLocations locations:[CLLocation]){
        let db : YourExistence = YourExistence()
        let realm = try! Realm()
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        let altitude = location?.altitude
        let currentDateTime = Date()
        print("lantidude\(latitude!). longitude\(longitude!)")
        let dateformatter = DateFormatter()
        dateformatter.calendar = Calendar(identifier: .gregorian)
        dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss Z"
        db.time = currentDateTime
        db.latitude = latitude!
        db.longitude = longitude!
        db.altitude = altitude!
        db.group = dateformatter.string(from:groupDate!)
        
        try! realm.write {
            realm.add(db)
        }
        
        
        labelLat.text = String(latitude!)
        labelLon.text = String(longitude!)
        
//        let dbList: Results<YourExistence> = realm.objects(YourExistence.self)
        
//        for db in dbList{
//            print(db.id)
//            print(db.time!)
//            print(db.latitude)
//            print(db.longitude)
//            print()
//            print()
//        }
    }
    func annotation(){
        var coor1 = CLLocation(latitude: 0, longitude: 0)
        var coor2 = CLLocation(latitude: 0, longitude: 0)
        var time1 = 0.0
        var time2 = 0.0
        let realm = try! Realm()
        print(startDate!)
        print(stopDate!)
        var gpsList:Results<YourExistence>
        if(searchDate != nil){
            gpsList = realm.objects(YourExistence.self).filter("group = %@", searchDate!)
        }else{
            gpsList = realm.objects(YourExistence.self).filter("time <= %@ AND time >= %@", stopDate! ,startDate!)
        }
        
        let dateformatter = DateFormatter()
        var cords:[CLLocationCoordinate2D] = []
//        print("test")
        for loc in gpsList{
            let annonation:MKPointAnnotation = MKPointAnnotation()
            annonation.coordinate = CLLocationCoordinate2DMake(loc.latitude, loc.longitude)
            annonation.title = "You"
            annonation.subtitle = dateformatter.string(from:loc.time!)
            mapView.addAnnotation(annonation)
            cords+=[CLLocationCoordinate2D(latitude:loc.latitude , longitude:loc.longitude)]
//            print("test2")
            if(loc.time == startDate!){
                coor1 = CLLocation(latitude:loc.latitude, longitude:loc.longitude)
                time1 = loc.time!.timeIntervalSince1970
                time1 = time1/1000
            }
            if(loc.time == stopDate!){
                coor2 = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
                time2 = loc.time!.timeIntervalSince1970
                time2 = time2/1000
            }
        }
        let distance = coor2.distance(from:coor1)
        let distanceTime = (time2-time1)/60
        labelSpeed.text = String(distance/distanceTime)+"M/Min"
        let polyLine = MKPolyline(coordinates: cords, count: cords.count)
        mapView.addOverlay(polyLine)
    }
    
    func mapView(_ mapView:MKMapView,rendererFor overlay: MKOverlay)-> MKOverlayRenderer{
        
        if let polyline = overlay as? MKPolyline{
            
            let polylineRenderer = MKPolylineRenderer(polyline: polyline)
            polylineRenderer.strokeColor = .blue
            polylineRenderer.lineWidth = 2.0
            
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
}

