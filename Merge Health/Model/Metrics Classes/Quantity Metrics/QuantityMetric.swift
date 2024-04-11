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

    public var unitName: String {
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
    public var valuesPerWeekday: [Int] //Instance : 56 BPM
    public var comparedToMaximumString: [String] //Instance: 56%
    public var valueForProgressView: [Float] //Instance: 0.56
    
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
        self.comparedToMaximumString = []
        self.valueForProgressView = []
        
        self.dailyBarChart = BarChartView()
        self.weeklyBarChart = BarChartView()
        self.monthlyBarChart = BarChartView()
        self.yearsBarChart = BarChartView()
        self.dailyCustomBarChart = BarChartView()
        
        self.customValues = []
        
    }
    
    
    
    func fetchAllData() -> Void {
        self.fetchAverageTodayActivation()
        self.fetchLastValueActivation()
        self.fetchAverageLastDaysActivation()
        
        
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
        
        self.unifyWeekDays()
        
//        self.fetchAverageStepsForMondays(pastDays: 20) { _, _ in
//            
//        }
        
        
        
    }
    
    func fetchSpecificWeekDay(pastDays: Int, weekDay: Int, completion: @escaping (Int, String) -> Void){
        //Should be overwritten
    }
    
    func unifyWeekDays(){
        //Should be overwritten
    }
    

  
    
    
    
    //This is a more efficient way of executing the fetching functions
    func fetchAverageTodayGeneral(individualMetric: QuantityMetric, typeIdentifier: HKQuantityTypeIdentifier, unit: HKUnit, printUnit: String, completion: @escaping (String) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        
        let type = HKQuantityType.quantityType(forIdentifier: typeIdentifier)!
        let now = Date.now
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        
        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            
            guard let result = result, let avgQuantity = result.averageQuantity() else {
                DispatchQueue.main.async {
                    individualMetric.today_average = "N/A"
                    
                    completion("N/A")
                }
                return
            }
            
            let average = avgQuantity.doubleValue(for: unit)
            
            DispatchQueue.main.async {
                individualMetric.today_average = "\(String(format: "%.2f", average)) \(printUnit)"
                completion("\(String(format: "%.2f", average)) \(printUnit)")
            }
        }
        
        
        healthStore.execute(query)
    }
    
    func fetchAverageTodayActivation(){
        //This just exist to have consistency with all the sub-classes
    }
    
    func fetchLastValueGeneral(individualMetric: QuantityMetric, typeIdentifier: HKQuantityTypeIdentifier, unit: HKUnit, printUnit: String, completion: @escaping (String) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        
        let metric = HKQuantityType.quantityType(forIdentifier: typeIdentifier)!
        let now = Date.now
        let startDay = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startDay, end: now, options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: metric, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard error == nil else {
                completion("N/A")
                print("Error fetching resting heart rate: \(String(describing: error))")
                return
            }
            
            if let lastResult = results?.first as? HKQuantitySample {
                let lastValue = lastResult.quantity.doubleValue(for: unit)
                DispatchQueue.main.async {
                    self.latest_value = "\(String(format: "%.2f", lastValue)) \(printUnit)"
                    completion("\(String(format: "%.2f", lastValue)) \(printUnit)")
                }
                
            }
        }
        
        healthStore.execute(query)
    }
    
    func fetchLastValueActivation() {
        
    }
    
    

    func fetchAverageLastDaysGeneral(individualMetric: QuantityMetric, typeIdentifier: HKQuantityTypeIdentifier, unit: HKUnit, printUnit: String, completion: @escaping (String) -> Void){
        
        guard let type = HKQuantityType.quantityType(forIdentifier: typeIdentifier) else {
            print("\(self.exposingName) is not available in HealthKit")
            return
        }

        let daysLength = -25

        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: daysLength, to: endDate) else { return }


        let statisticsOptions = HKStatisticsOptions.discreteAverage

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: statisticsOptions,
            anchorDate: startDate,
            intervalComponents: DateComponents(day: 1)
        )

        query.initialResultsHandler = { query, results, error in
            if error != nil {
                completion("There was an error with the fetching")
                return
            }

            guard let statsCollection = results else {
                DispatchQueue.main.async {
                    self.average_last_days = "N/A"

                    completion("N/A")
                }
                return
            }
            
            
            


            var dailyAverages: [Double] = []


            statsCollection.enumerateStatistics(from: startDate, to: endDate) { individualDay, stop in
                if let quantity = individualDay.averageQuantity() {
                    let value = quantity.doubleValue(for: unit)
                    dailyAverages.append(value)
                }
            }

            let overallAverage = dailyAverages.isEmpty ? 0 : dailyAverages.reduce(0, +) / Double(dailyAverages.count)

            DispatchQueue.main.async {
                self.average_last_days = String(format: "%.2f \(printUnit)", overallAverage)
                completion(String(format: "%.2f \(printUnit)", overallAverage))
            }
        }

        healthStore.execute(query)
    }






    func fetchAverageLastDaysActivation(){
        
    }

    func fetchExpectedTotalValueUntilNow(completion: @escaping (String) -> Void) {
        fatalError("The method must be overriden")
    }
    func fetchSumUntilNow(completion: @escaping (String) -> Void) {
        fatalError("The method must be overriden")
    }
    

    
    
    
    
    
    
    func fetchDays(completion: @escaping ([Int], [String], String) -> Void) {
        //fatalError("The method must be overriden")
    }
    
    func fetchCustomDays(userinput: Int, completion: @escaping ([Int], [String], String) -> Void) {
        //fatalError("Must be overwritten")
    }
    
    
    func fetchWeeks(completion: @escaping ([Int], [String], String) -> Void) {
        //fatalError("The method must be overriden")
    }

    func fetchMonths(completion: @escaping ([Int], [String], String) -> Void) {
        //fatalError("The method must be overriden")
    }
    
    func fetchYears(completion: @escaping ([Int], [String], String) -> Void) {
        
    }
    
    //.
    func fetchValuesPerWeekDay(completion: @escaping ([Int]) -> Void) {
        //fatalError("The method must be overriden")
    }
    
    
    
    
    func barChartDays(){
        //fatalError("The method must be overriden")
        
    }
    
    func barChartCustomDays(userinput: Int) {
        //fatalError("Must be overwritten")
    }
    
    func barChartWeeks() {
        //fatalError("The method must be overriden")
    }
    func barChartMonths(){
        //fatalError("The method must be overriden")
    }
    
    func barChartYears(){
        //fatalError("The method must be overriden")
    }


    
}
