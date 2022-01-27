//
//  SearchController.swift
//  gpsAppUp
//
//  Created by WENDRA RIANTO on 2022/01/13.
//

import Foundation
import CoreLocation
import MapKit
import RealmSwift
import Charts
import SwiftUI

class SearchController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return group.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return group[row]
    }
    
    @IBOutlet weak var groupPicker: UIPickerView!
    @IBOutlet weak var chart: BarChartView!
    var searchDate :String = ""
    let unitsSold = [10.0, 4.0, 6.0, 3.0, 12.0, 16.0]
    var averageData:[Double] = []
    var group:[String?]  = []
    var searchGroup:String = ""
        
        override func viewDidLoad() {
            super.viewDidLoad()
            let realm = try! Realm()
            let gpsList = Set(realm.objects(YourExistence.self).value(forKey: "group") as! [String])
            for loc in gpsList{
                group.append(loc)
            }
            self.groupPicker.delegate = self
            self.groupPicker.dataSource = self
        }
        
        func setLineGraph(){
            var entry = [BarChartDataEntry]()
            if(averageData.count > 10){
                
            }
            for (i,d) in averageData.enumerated(){
                entry.append(BarChartDataEntry(x: Double(i),y: d))
            }
            
            let dataset = BarChartDataSet(entries: entry, label: "Meter/Minute")
            let data = BarChartData(dataSet: dataset)
            chart.data = data
//            chart = "Item Sold Chart"
//            chart.chartDescription?.text = "Item Sold Chart"
        }
    func average(){
        averageData.removeAll()
        let realm = try! Realm()
        let gpsList:Results<YourExistence> = realm.objects(YourExistence.self).filter("group = %@", searchDate)
        print(gpsList)
        var loc1:YourExistence? = nil
//        print("test")
        for loc in gpsList {
            if(loc1 == nil){
                loc1 = loc
            }else{
                let time1 = loc1!.time!.timeIntervalSince1970/1000
                let time2 = loc.time!.timeIntervalSince1970/100
                let distanceTime = (time2-time1)/60
                let coor1 = CLLocation(latitude: loc1!.latitude,longitude: loc1!.longitude)
                let coor2 = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
                let distance = coor2.distance(from:coor1)
                averageData.append(Double(distance/distanceTime))
                loc1 = loc
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let dateformatter = DateFormatter()
//        dateformatter.calendar = Calendar(identifier: .gregorian)
//        dateformatter.dateFormat = "yyyy/MM/dd HH:mm:ss Z"
        searchDate = group[row]!
        average()
        setLineGraph()
    }
}
