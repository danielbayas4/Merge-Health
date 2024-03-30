import Foundation
import HealthKit
import DGCharts

class RespiratoryRate: QuantityMetric {
    static let shared = RespiratoryRate()
    
    override var todayTVC_Name: String {
        return todayTVC_Names.respiratoryRate
    }
    override var exposingName: String {
        return exposingNames.respiratoryRate
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
        
        let metric = HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!
        let now = Date.now
        let startDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startDay, end: now, options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        

        let query = HKSampleQuery(sampleType: metric, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard error == nil else {
                completion("N/A")
                print("Error fetching \(self.exposingName): \(String(describing: error))")
                return
            }
            
            if let lastResult = results?.first as? HKQuantitySample {

                let lastValue = lastResult.quantity.doubleValue(for: HKUnit(from: "count/min"))
                
                DispatchQueue.main.async {
                    self.latest_value = "\(String(format: "%.2f", lastValue)) breaths/min"
                    completion("\(String(format: "%.2f", lastValue)) breaths/min")
                }
                
            }
        }
        
        healthStore.execute(query)
    }
    
    override func fetchAverageToday(completion: @escaping (String) -> Void) {
        
    }
    
    override func fetchAverageLastDays(completion: @escaping (String) -> Void) {
        
    }

   
    
    override func fetchWeeks(completion: @escaping ([Int]) -> Void) {
        

    }
    
    override func fetchDays(completion: @escaping ([Int]) -> Void) {
        
        
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
