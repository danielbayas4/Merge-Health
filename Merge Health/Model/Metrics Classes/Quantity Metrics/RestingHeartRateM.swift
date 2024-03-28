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
    
    override func fetchLastValue(completion: @escaping (String) -> Void) {
        let metric = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        let now = Date.now
        let startDay = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startDay, end: now, options: .strictEndDate)
        
        //📌 28/3/24: Continue with all the querrying that I need.
        //Eliminar todo lo del delagate, para que solo quede el fetchall.
        //let query =
        
    }

    
    
    override func fetchAverageToday(completion: @escaping (String) -> Void) {
        
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
        //After this the code continue executing the rest of the code
    }
    
    
    override func fetchDays(completion: @escaping ([Int]) -> Void) {
        let number_days: Int = 10
        let dayValues = [1]
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



