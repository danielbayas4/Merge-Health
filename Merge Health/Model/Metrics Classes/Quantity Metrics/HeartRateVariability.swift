import Foundation
import HealthKit
import DGCharts


class HeartRateVariability: QuantityMetric {
    
    static let shared = HeartRateVariability()
    override var todayTVC_Name: String {
        return todayTVC_Names.heartRateVariability
    }
    override var exposingName: String {
        return exposingNames.heartRateVariability
    }
    
    
    
    
    private override init() {
        super.init()
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
        
        let metric = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let now = Date.now
        let startDay = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startDay, end: now, options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        
        //The most recent HRV value
        let query = HKSampleQuery(sampleType: metric, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard error == nil else {
                completion("N/A")
                print("Error fetching \(self.exposingName): \(String(describing: error))")
                return
            }
            
            if let lastResult = results?.first as? HKQuantitySample {
                let lastValue = lastResult.quantity.doubleValue(for: HKUnit(from: "ms"))
                
                DispatchQueue.main.async {
                    self.latest_value = "\(String(format: "%.2f", lastValue)) ms"
                    completion("\(String(format: "%.2f", lastValue)) ms")
                }
                
            }
        }
        
        healthStore.execute(query)
    } //working
    
    override func fetchAverageToday(completion: @escaping (String) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        
        let metric = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: metric,
            quantitySamplePredicate: predicate,
            options: .discreteAverage) { _, result, _ in
            
            guard let result = result, let avgQuantity = result.averageQuantity() else {
                DispatchQueue.main.async {
                    self.today_average = "N/A"
                    completion("N/A")
                    
                }
                return
            }
            
            let averageHRV = avgQuantity.doubleValue(for: HKUnit(from: "ms"))
            
            DispatchQueue.main.async {
                self.today_average = "\(String(format: "%.2f", averageHRV)) ms"
                completion("\(String(format: "%.2f", averageHRV)) ms")
            }
        }
        
        healthStore.execute(query)
    }
    
    override func fetchAverageLastDays(completion: @escaping (String) -> Void) {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            print("HRV Type is not available in HealthKit")
            return
        }

        let daysLength = -10

        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: daysLength, to: endDate) else { return }

        // Defining the cumulative sum
        let statisticsOptions = HKStatisticsOptions.discreteAverage

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: hrvType,
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
            
            

            // For loop per each of the metrics
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { individualDay, stop in
                if let quantity = individualDay.averageQuantity() {
                    let value = quantity.doubleValue(for: HKUnit(from: "ms"))
                    dailyAverages.append(value)
                }
            }

            let overallAverage = dailyAverages.isEmpty ? 0 : dailyAverages.reduce(0, +) / Double(dailyAverages.count)

            DispatchQueue.main.async {
                self.average_last_days = String(format: "%.0f ms", overallAverage)
                completion(String(format: "%.0f ms", overallAverage))
            }
        }

        healthStore.execute(query)
    }
    
    
    
    
    
    
    
    
    
    
    
    override func fetchDays(completion: @escaping ([Int]) -> Void) {
        
        
    }
    
    override func fetchWeeks(completion: @escaping ([Int]) -> Void) {
        

    }
    
    override func fetchMonths(completion: @escaping ([Int]) -> Void){

 
    }

    override func barChartWeek() -> BarChartView {
        fatalError("Implementation needed")
    }

    override func barChartMonth() -> BarChartView {
        fatalError("Implementation needed")
    }

    override func barChartYear() -> BarChartView {
        fatalError("Implementation needed")
    }
}

