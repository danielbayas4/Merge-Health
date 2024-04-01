
import Foundation
import HealthKit
import DGCharts

class Steps: QuantityMetric {
    static let shared = Steps()
    
    override var todayTVC_Name: String {
        return todayTVC_Names.steps
    }
    override var exposingName: String {
        return exposingNames.steps
    }
    
    private override init() {
        super.init()
    }
    
    override func fetchAllData() {
        
        self.fetchExpectedTotalValueUntilNow { _ in
            
        }
        
        self.fetchLastValue { _ in
            
        }
        
        
        
        self.fetchAverageLastDays { _ in
            
            
        }

        
        self.fetchSumUntilNow { _ in
            
            
        }
        
    }
    
    
    
    
    override func fetchSumUntilNow(completion: @escaping (String) -> Void) {
        
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion("Step Count type is unavailable")
            self.totalValueUntilNow = "Step Count type is unavailable"
            return
        }
        
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.timeZone = NSTimeZone.local
        let startDate = calendar.date(from: components)!
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, statistics, error) in
            guard error == nil, let statistics = statistics, let sum = statistics.sumQuantity() else {
                self.totalValueUntilNow = "Query failed or no data returned"
                completion("Query failed or no data returned")
                return
            }

            // Convert the total number of steps to a string and call the completion handler
            let totalSteps = sum.doubleValue(for: HKUnit.count())
            self.totalValueUntilNow = "\(Int(totalSteps)) steps"
            completion("\(Int(totalSteps)) steps")
        }
        
        healthStore.execute(query)
    }
    
    
    
    
    override func fetchLastValue(completion: @escaping (String) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            self.latest_value = "Health data not available"
            completion("Health data not available")
            return
        }

        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion("Step Count type is unavailable")
            self.latest_value = "Step Count type is unavailable"
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: stepCountType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
                        guard error == nil, let lastSample = results?.first as? HKQuantitySample else {
                            self.latest_value = "Query failed or no data returned"
                            completion("Query failed or no data returned")
                            return
                        }

                        // Extract the quantity from the last sample and convert it to a string
                        let lastQuantity = lastSample.quantity.doubleValue(for: HKUnit.count())
                        self.latest_value = "\(Int(lastQuantity)) steps"
                        completion("\(Int(lastQuantity)) steps")
                    }
        
        
        self.healthStore.execute(query)
        
    }
    
    
    
    
    //How many steps I regularly have made until the given point
    override func fetchExpectedTotalValueUntilNow(completion: @escaping (String) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            self.generallyUntilNow = "Health data not available"
            completion("Health data not available")
            return
        }
        
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            self.generallyUntilNow = "Step Count type is unavailable"
            completion("Step Count type is unavailable")
            return
        }
        
        let group = DispatchGroup()
        var dailyTotals: [Double] = []
        
        for offSet in -10..<0 {
            group.enter()
            
            self.fetchStepsForDayUntilPoint(offset: offSet, stepType: stepCountType, completion: { total in
                
                dailyTotals.append(total)
                group.leave()
            })
        }
        
        
        
        group.notify(queue: .main) {
            let averageSteps = dailyTotals.reduce(0, +) / Double(dailyTotals.count)
            self.generallyUntilNow = "\(Int(averageSteps)) steps"
            completion("\(Int(averageSteps)) steps")
            
        }
        
        
        
        
    }
    
    func fetchStepsForDayUntilPoint(offset: Int, stepType: HKQuantityType, completion: @escaping (Double) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: calendar.date(byAdding: .day, value: offset, to: now)!)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        components.day! += offset
        
        let endDate = calendar.date(from: components)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endDate, options: .strictEndDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, _ in
                    guard let sum = statistics?.sumQuantity() else {
                        completion(0)
                        return
                    }
                    let totalSteps = sum.doubleValue(for: HKUnit.count())
                    completion(totalSteps)
                }
        
        healthStore.execute(query)
}
    
    
    //Forecast of how many steps at the end of the day (based on the last 10 days)
    override func fetchAverageLastDays(completion: @escaping (String) -> Void) {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("Step Count Type is not available in HealthKit")
            return
        }
        
        let daysLength = -20
        
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: daysLength, to: endDate) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startDate,
            intervalComponents: DateComponents(day: 1)
        )
        
        query.initialResultsHandler = { _, results, error in
            if error != nil {
                completion("N/A")
                return
            }
            
            guard let statsCollection = results else {
                self.average_last_days = "N/A"
                completion("N/A")
                return
            }
            
            var dailySums: [Double] = []
            var parallelDates: [Date] = []
            
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { individual_day, _ in
                if let quantity = individual_day.sumQuantity() {
                    let date = individual_day.startDate
                    let steps = quantity.doubleValue(for: HKUnit.count())
                    dailySums.append(steps)
                    parallelDates.append(date)
                    
                }
            }
            
            
            let totalSum = dailySums.reduce(0, +)
            let averageSteps = totalSum / Double(dailySums.count)
            
            DispatchQueue.main.async {
                self.average_last_days = "\(Int(averageSteps)) steps"
                completion("\(Int(averageSteps)) steps")
            }
        }
        
        healthStore.execute(query)
    }
    
    
    
    override func fetchDays(completion: @escaping ([Int], [String], String) -> Void) {
        
    }

    
    override func fetchWeeks(completion: @escaping ([Int], [String], String) -> Void){
        let number_weeks: Int = 10
        let weekValues = [1]
    }



    override func fetchMonths(completion: @escaping ([Int], [String], String) -> Void) {
        let number_monthts: Int = 10
        let monthValues = [1]
        
    }
    
    override func fetchYears(completion: @escaping ([Int], [String], String) -> Void){
        
    }
    

    
    override func barChartDays(){

        //fatalError("Implementation needed")
    }
    
    override func barChartWeeks(){
        
        //fatalError("Implementation needed")
    }
    
    override func barChartMonths(){
        
        //fatalError("Implementation needed")
    }
}
