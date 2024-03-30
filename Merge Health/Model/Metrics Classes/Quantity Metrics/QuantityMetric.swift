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
    
    //Actual part of the super class
    public var healthStore = HKHealthStore()
    public var todayTVC_Name: String {
        return "Generic TVC"
    }
    public var exposingName: String {
        return "QuantityMetric (Abstract)"
    }

    
    
    
    //TODAY VIEW
    public var average_last_days: String
    
    //Discrete metrics
    public var latest_value: String
    public var today_average: String
    
    //Accumulative metrics
    public var totalValueUntilNow: String
    public var totalValueEndOfDay: String
    
    public var generallyUntilNow: String
    
    //Per week day
    public var valuesPerWeekday: [Int]
    public var comparedToMaximum: [String] //Instance: 56%
    
    //For the graphing
    public var lastNDays: [Int]
    public var lastNWeeks: [Int]
    public var lastNMonths: [Int]
    
    

    
    
    init() {
        //TODAY VIEW
        self.average_last_days = "N/A"
        //Discrete metrics
        self.latest_value = "N/A"
        self.today_average = "N/A"
        //Accumulative metrics
        self.totalValueUntilNow = "N/A"
        self.totalValueEndOfDay = "N/A"
        self.generallyUntilNow = "N/A"

        
        //Per week day
        self.valuesPerWeekday = []
        self.comparedToMaximum = []
        
        //For the graphing
        self.lastNDays = []
        self.lastNWeeks = []
        self.lastNMonths = []
        

    }
    
    
    
    func fetchAllData() -> Void {
        
//        self.fetchWeeks { _ in
//            
//        }
//        
//        self.fetchMonths { _ in
//            
//        }
//        
//        self.fetchDays { _ in
//            
//        }
//        
//        self.fetchValuesPerWeekDay { _ in
//
//        }
        
    }
    
    
    func fetchAverageToday(completion: @escaping (String) -> Void) {
        fatalError("The method must be overriden")
    }
    func fetchLastValue(completion: @escaping (String) -> Void){
        fatalError("The method must be overriden")
    }
    func fetchAverageLastDays(completion: @escaping (String) -> Void) {
        fatalError("The method must be overriden")
    }

    func fetchExpectedTotalValueUntilNow(completion: @escaping (String) -> Void) {
        fatalError("The method must be overriden")
    }
    func fetchSumUntilNow(completion: @escaping (String) -> Void) {
        fatalError("The method must be overriden")
    }
    

    
    func fetchWeeks(completion: @escaping ([Int]) -> Void) {
        fatalError("The method must be overriden")
    }
    func fetchDays(completion: @escaping ([Int]) -> Void) {
        fatalError("The method must be overriden")
    }
    func fetchMonths(completion: @escaping ([Int]) -> Void) {
        fatalError("The method must be overriden")
    }
    //.
    func fetchValuesPerWeekDay(completion: @escaping ([Int]) -> Void) {
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


    
}
