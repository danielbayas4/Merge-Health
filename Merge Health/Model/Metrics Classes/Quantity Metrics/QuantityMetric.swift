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
    
    //Graphs
    public var dailyBarChart: BarChartView
    public var dailyCustomBarChart: BarChartView
    
    public var weeklyBarChart: BarChartView
    public var monthlyBarChart: BarChartView
    public var yearsBarChart: BarChartView
    
    public var customValues: [Int]
    
    
    

    
    
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
        
        self.dailyBarChart = BarChartView()
        self.weeklyBarChart = BarChartView()
        self.monthlyBarChart = BarChartView()
        self.yearsBarChart = BarChartView()
        self.dailyCustomBarChart = BarChartView()
        
        self.customValues = []
        
    }
    
    
    
    func fetchAllData() -> Void {
        self.fetchLastValue { _ in
            
        }
        
        self.fetchAverageToday { _ in
            
        }
        
        self.fetchAverageLastDays { _ in
            
        }
        
        self.fetchDays { _, _, _ in
            
        }
        
        self.fetchWeeks { _, _, _ in
            
        }
        
        self.fetchMonths { _, _ , _ in
            
        }
        
        self.fetchYears { _, _, _ in
            
        }
        
        self.barChartDays()
        
        self.barChartWeeks()
        
        self.barChartMonths()
        
        self.barChartYears()
        
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
    

    
    
    
    
    
    
    func fetchDays(completion: @escaping ([Int], [String], String) -> Void) {
        fatalError("The method must be overriden")
    }
    
    func fetchCustomDays(userinput: Int, completion: @escaping ([Int], [String], String) -> Void) {
        fatalError("Must be overwritten")
    }
    
    
    func fetchWeeks(completion: @escaping ([Int], [String], String) -> Void) {
        fatalError("The method must be overriden")
    }

    func fetchMonths(completion: @escaping ([Int], [String], String) -> Void) {
        fatalError("The method must be overriden")
    }
    
    func fetchYears(completion: @escaping ([Int], [String], String) -> Void) {
        
    }
    
    //.
    func fetchValuesPerWeekDay(completion: @escaping ([Int]) -> Void) {
        fatalError("The method must be overriden")
    }
    
    
    
    
    func barChartDays(){
        fatalError("The method must be overriden")
        
    }
    
    func barChartCustomDays(userinput: Int) {
        fatalError("Must be overwritten")
    }
    
    func barChartWeeks() {
        fatalError("The method must be overriden")
    }
    func barChartMonths(){
        fatalError("The method must be overriden")
    }
    
    func barChartYears(){
        fatalError("The method must be overriden")
    }


    
}
