//
//  resting_heart_rate.swift
//

import Foundation
import DGCharts
import HealthKit

class RestingHeartRateM: QuantityMetric {
    
    static let shared = RestingHeartRateM()
    
    private override init() {
        super.init()
    }
    
    override var todayTVC_Name: String {
        return todayTVC_Names.restingHeartRate
    }
    override var exposingName: String {
        return exposingNames.restingHeartRate
    }
    
    override func fetchAllData() {
        self.fetchLastValue { _ in
            
        }
        
        self.fetchAverageToday { _ in
            
        }
        
        self.fetchAverageLastDays { _ in
            
        }
    }

    
    override func fetchLastValue(completion: @escaping (String) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        
        let metric = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
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
                let lastValue = lastResult.quantity.doubleValue(for: HKUnit(from: "count/min"))
                DispatchQueue.main.async {
                    self.latest_value = "\(Int(lastValue)) BPM"
                    completion("\(Int(lastValue)) BPM")
                }
                
            }
        }
        
        healthStore.execute(query)
    }
    
    override func fetchAverageToday(completion: @escaping (String) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        let now = Date.now //Date()
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            
            guard let result = result, let avgQuantity = result.averageQuantity() else {
                DispatchQueue.main.async {
                    self.today_average = "N/A"
                    
                    completion("N/A")
                }
                return
            }
            let heartRate = avgQuantity.doubleValue(for: HKUnit(from: "count/min"))
            
            DispatchQueue.main.async {
                self.today_average = "\(Int(heartRate)) BPM"
                completion("\(Int(heartRate)) BPM")
            }
        }
        
        healthStore.execute(query)
    }
    
    override func fetchAverageLastDays(completion: @escaping (String) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            print("Resting Heart Rate Type is not available in HealthKit")
            return
        }
    
        
        let daysLength = -10
        
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: daysLength, to: endDate) else {return}
        
        //defining the cumulative sum
        let statisticsOptions = HKStatisticsOptions.discreteAverage
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: statisticsOptions,
            anchorDate: startDate,
            intervalComponents: DateComponents(day: 1)
        )
    
        query.initialResultsHandler = { query, results, error in
            if error != nil {
                completion("There was an error fetching the data")
                return
            }
            
            
            guard let statsCollection = results else {
                self.average_last_days = "N/A"
                completion("N/A")
                return
            }
        
            var dailyAverages: [Double] = []
            var parallelDates: [Date] = []
            
            
            //For loop per each of the metrics
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { individual_day, stop in
                if let quantity = individual_day.averageQuantity() {
                    let date = individual_day.startDate
                    let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    dailyAverages.append(value)
                    parallelDates.append(date)

                }
            }
            
            let overallAverage = dailyAverages.reduce(0, { current_value, nextCollectionElement in
                current_value + nextCollectionElement
            }) / Double(dailyAverages.count)
            
            DispatchQueue.main.async {
                self.average_last_days = String(format: "%.2f BPM", overallAverage)

            }
            
        }
        
        healthStore.execute(query)
        
        
    }
    
    
    
    
    
    
    
    
    
    
    override func fetchDays(completion: @escaping ([Int]) -> Void) {
        
    }
    
    

    
    override func fetchWeeks(completion: @escaping ([Int]) -> Void){
        let number_weeks: Int = 10
        let weekValues = [1]
    }



    override func fetchMonths(completion: @escaping ([Int]) -> Void) {
        let number_monthts: Int = 10
        let monthValues = [1]
        
    }
    

    
    
    
    
    
    
    //Creation of the chart objects

    override func barChartWeek() -> BarChartView {
        let chartView = BarChartView()
        
        //let weekValues = self.fetchWeeks()
        
        return chartView
    }

    override func barChartMonth() -> BarChartView{
        let chartView = BarChartView()
        
        return chartView
    }

    override func barChartYear() -> BarChartView {
        let chartView = BarChartView()
        
        return chartView
    }
}



