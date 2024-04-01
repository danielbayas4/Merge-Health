import Foundation
import HealthKit
import DGCharts

class WalkingRunningDistance: QuantityMetric {
    
    static let shared = WalkingRunningDistance()
    override var todayTVC_Name: String {
        return todayTVC_Names.walkingRunningDistance
    }
    override var exposingName: String {
        return exposingNames.walkingRunningDistance
    }
    
    
    private override init() {
        super.init()
    }
    
    override func fetchAllData() {
        
        self.fetchAverageLastDays { _ in
            
        }
        self.fetchExpectedTotalValueUntilNow { _ in
            
        }
        
        self.fetchLastValue { _ in
            
        }
        
        self.fetchSumUntilNow { _ in
            
        }
        
    }
    
    override func fetchSumUntilNow(completion: @escaping (String) -> Void) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion("Distance Walking/Running type is unavailable")
            self.totalValueUntilNow = "Distance Walking/Running type is unavailable"
            return
        }
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.timeZone = NSTimeZone.local
        let startDate = calendar.date(from: components)!
        let endDate = Date()
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, statistics, error) in
            
            guard error == nil, let statistics = statistics, let sum = statistics.sumQuantity() else {
                self.totalValueUntilNow = "Query failed or no data returned"
                completion("Query failed or no data returned")
                return
            }

            let totalDistanceKM = sum.doubleValue(for: HKUnit.meterUnit(with: .kilo))
            let totalDistanceMeters = sum.doubleValue(for: HKUnit.meter())
            self.totalValueUntilNow = "\(Int(totalDistanceKM)) km / \(Int(totalDistanceMeters)) m"
            completion("\(Int(totalDistanceKM)) km / \(Int(totalDistanceMeters)) m")
        }
        
        healthStore.execute(query)
    }
    
    override func fetchLastValue(completion: @escaping (String) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            self.latest_value = "Health data not available"
            completion("Health data not available")
            return
        }

        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion("Distance Walking/Running type is unavailable")
            self.latest_value = "Distance Walking/Running type is unavailable"
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: distanceType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard error == nil, let lastSample = results?.first as? HKQuantitySample else {
                self.latest_value = "Query failed or no data returned"
                completion("Query failed or no data returned")
                return
            }

            // Extract the quantity from the last sample and convert it to kilometers and meters
            let lastQuantity = lastSample.quantity.doubleValue(for: HKUnit.meter())
            let kilometers = lastQuantity / 1000
            let meters = lastQuantity.truncatingRemainder(dividingBy: 1000)

            // Extract the end date's hour and minute
            let endDate = lastSample.endDate
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: endDate)
            
            self.latest_value = String(format: "%.2f km / %.0f m (%@)", kilometers, meters, timeString)
            completion(self.latest_value)
        }
        
        self.healthStore.execute(query)
    }
    
    override func fetchAverageLastDays(completion: @escaping (String) -> Void) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            print("Distance Walking/Running Type is not available in HealthKit")
            return
        }
        
        let daysLength = -20
        
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: daysLength, to: endDate) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: distanceType,
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
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { individual_day, _ in
                if let quantity = individual_day.sumQuantity() {
                    let distanceMeters = quantity.doubleValue(for: HKUnit.meter())
                    dailySums.append(distanceMeters)
                }
            }
            
            let totalSum = dailySums.reduce(0, +)
            let averageDistanceMeters = totalSum / Double(dailySums.count)
            let averageDistanceKilometers = averageDistanceMeters / 1000
            
            DispatchQueue.main.async {
                let formattedDistance = String(format: "%.1f km / %.0f m", averageDistanceKilometers, averageDistanceMeters)
                self.average_last_days = formattedDistance
                completion(formattedDistance)
            }
        }
        
        healthStore.execute(query)
    }
    
    override func fetchExpectedTotalValueUntilNow(completion: @escaping (String) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            self.generallyUntilNow = "Health data not available"
            completion("Health data not available")
            return
        }
        
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            self.generallyUntilNow = "Distance Walking/Running type is unavailable"
            completion("Distance Walking/Running type is unavailable")
            return
        }
        
        let group = DispatchGroup()
        var dailyTotals: [Double] = []
        
        for offSet in -10..<0 {
            group.enter()
            
            self.fetchDistanceForDayUntilPoint(offset: offSet, distanceType: distanceType, completion: { total in
                dailyTotals.append(total)
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            let averageDistanceMeters = dailyTotals.reduce(0, +) / Double(dailyTotals.count)
            let averageDistanceKM = averageDistanceMeters / 1000
            self.generallyUntilNow = String(format: "%.1f km / %.0f m", averageDistanceKM, averageDistanceMeters)
            completion(self.generallyUntilNow)
        }
    }
    
    
    func fetchDistanceForDayUntilPoint(offset: Int, distanceType: HKQuantityType, completion: @escaping (Double) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: calendar.date(byAdding: .day, value: offset, to: now)!)
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        components.day! += offset
        
        let endDate = calendar.date(from: components)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endDate, options: .strictEndDate)
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, _ in
                    guard let sum = statistics?.sumQuantity() else {
                        completion(0)
                        return
                    }
                    let totalDistance = sum.doubleValue(for: HKUnit.meter())
                    completion(totalDistance)
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


    override func barChartDays() {
        //fatalError("Implementation needed")
    }

    override func barChartWeeks() {
        //fatalError("Implementation needed")
    }

    override func barChartMonths() {
        //fatalError("Implementation needed")
    }
}
