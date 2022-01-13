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

class SearchController: UIViewController{
    @IBOutlet weak var groupPicker: UIPickerView!
    @IBOutlet weak var chart: BarChartData!
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
        let unitsSold = [10.0, 4.0, 6.0, 3.0, 12.0, 16.0]
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            setLineGraph()
        }
        
        func setLineGraph(){
            var entry = [ChartDataEntry]()
            
            for (i,d) in unitsSold.enumerated(){
                entry.append(ChartDataEntry(x: Double(i),y: d))
            }
            
            let dataset = BarChartDataSet(entries: entry,label: "Units Sold")
            
            chart.addDataSet(dataset)
//            chart = "Item Sold Chart"
//            chart.chartDescription?.text = "Item Sold Chart"
        }
}
