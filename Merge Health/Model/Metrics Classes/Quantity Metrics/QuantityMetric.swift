//
//  metric.swift
//  Merge Health
//
//  Created by Daniel Bayas on 26/3/24.
//

import Foundation
import HealthKit
import DGCharts



class QuantityMetric: QuantityMetricProtocol {
    
    
    public var healthStore = HKHealthStore()
    
    
    public var todayTVC_Name: String {
        return "Generic TVC"
    }
    public var latest_value: String
    public var today_average: String
    public var average_last_10_days: String
    
    
    init() {
        self.latest_value = "Not fetched yet"
        self.today_average = "Not fetched yet"
        self.average_last_10_days = "Not fetched yet"
    }
    
    
    
    func fetchAllData() -> Void {
        
        self.fetchAverageToday { _ in
                
        }
        
        self.fetchDays { _ in
            
        }
    }
    
    
    func fetchAverageToday(completion: @escaping (String) -> Void) {
        fatalError("The method must be overriden")
    }
    func fetchLastValue(completion: @escaping (String) -> Void){
        fatalError("The method must be overriden")
    }
    
    
    ///At the moment just from the last 10 days
    func fetchWeeks(completion: @escaping ([Int]) -> Void) {
        fatalError("The method must be overriden")
    }
    func fetchDays(completion: @escaping ([Int]) -> Void) {
        fatalError("The method must be overriden")
    }
    func fetchMonths(completion: @escaping ([Int]) -> Void) {
        fatalError("The method must be overriden")
    }
    
    
    func barChartWeek() -> BarChartView {
        fatalError("The method must be overriden")
    }
    func barChartMonth() -> BarChartView {
        fatalError("The method must be overriden")
    }
    func barChartYear() -> BarChartView {
        fatalError("The method must be overriden")
    }

    func getValuesPerWeekDay() -> [Int] {
        fatalError("The method must be overriden")
    }
    
}
