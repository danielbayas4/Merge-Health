

import UIKit
import HealthKit

class TodayVC: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    //VARIABLES FOR THE TABLE CELLS
    var averageHeartRate: String = "Healthkit process wasn't reached"
    var lastStoredRHRValue: String = "Healthkit process wasn't reached"
    var averageRHRLast10days: String = "Healthkit process wasn't reached"
    //.
    var stepsToday: String = "Healthkit process wasn't reached"
    var stepsLast10Days: String = "Healthkit process wasn't reached"
    
    let healthStore = HKHealthStore()
    var metricsDisplayed = ["RestingHeartRate"]
     
    //New change
    
     override func viewDidLoad() {
         //the table is loaded at the initial load, so it does not know about the modification of the variables that populates it
         super.viewDidLoad()
         self.tableView.reloadData()
        
         
         if HKHealthStore.isHealthDataAvailable() {
             self.fetchHeartRateData()
             self.fetchLastRestingHeartRate()
             self.fetchAverageRestingHeartRateForLastTenDays()
             //.
             self.fetchStepCountData()
         }
         
         tableView.register(UINib(nibName: "RestingHeartRate", bundle: nil), forCellReuseIdentifier: "RestingHeartRate")
         
     }
    
    
    func fetchHeartRateData() {
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        
        
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            guard let result = result, let avgQuantity = result.averageQuantity() else {
                DispatchQueue.main.async {
                    self.averageHeartRate = "N/A"
                    self.tableView.reloadData()
                }
                return
            }
            let heartRate = avgQuantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async {
                self.averageHeartRate = "\(Int(heartRate)) BPM"
                self.tableView.reloadData()
            }
        }
        
        healthStore.execute(query)
    }
    
    
    func fetchLastRestingHeartRate() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }

        let healthStore = HKHealthStore()
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        print(sortDescriptor)
        
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard error == nil else {
                print("Error fetching resting heart rate: \(String(describing: error))")
                return
            }
            
            if let lastResult = results?.first as? HKQuantitySample {
                let lastValue = lastResult.quantity.doubleValue(for: HKUnit(from: "count/min"))
                DispatchQueue.main.async {
                    // Update your variable here
                    self.lastStoredRHRValue = "\(Int(lastValue)) BPM"
                    // Now you can refresh your table view or specific cell to display this value
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    
    func fetchAverageRestingHeartRateForLastTenDays() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            print("Resting Heart Rate Type is not available in HealthKit")
            return
        }

        //date components for the past 10 days
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -10, to: endDate) else { return }

        
        
        // define the cumulative sum
        let statisticsOptions = HKStatisticsOptions.discreteAverage

        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        // Define the query to calculate the sum
        let query = HKStatisticsCollectionQuery(
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: statisticsOptions,
            anchorDate: startDate,
            intervalComponents: DateComponents(day: 1))

        // Set the initial results handler
        query.initialResultsHandler = { query, results, error in
            guard let statsCollection = results else {
                // Handle any errors here
                return
            }
            
            var dailyAverages: [Double] = []

            // Enumerate through the collection
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistics, stop in
                if let quantity = statistics.averageQuantity() {
                    let date = statistics.startDate
                    let averageValue = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    dailyAverages.append(averageValue)
                    print("Average resting heart rate for \(date): \(Int(averageValue)) BPM")
                    
                    //Hacer que calcule el average en los anteriores 10 días, y de ahí que lo ponga dentro de esa variable
                }
                
                print("daily averages ", dailyAverages)
            }
            
            
            let overallAverage = dailyAverages.reduce(0, { current_value, nextCollectionElement in
                current_value + nextCollectionElement
            }) / Double(dailyAverages.count)
            
            DispatchQueue.main.async {
                self.averageRHRLast10days = String(format: "%.2f BPM", overallAverage)
                print("Overall Average Resting Heart Rate for the Last 10 Days: \(self.averageRHRLast10days)")
            }
        }

        // Execute the query
        healthStore.execute(query)
    }
    
    //Tengo que ponerme un poco m´ås las pilas que no me estoy moviendo lo
    
    func fetchStepCountData() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sumQuantity = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.stepsToday = "N/A"
                }
                return
            }
            let steps = sumQuantity.doubleValue(for: HKUnit.count())
            print(steps)
            
            DispatchQueue.main.async {
                self.stepsToday = "\(Int(steps)) Steps"
                
            }
        }

        healthStore.execute(query)
    }
    
    //fetching sleep information
    
    //fetching more data (decide man)
    
}

extension TodayVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentMetric = metricsDisplayed[indexPath.row]
        if currentMetric == "RestingHeartRate" {
            return 230 //Based on the units size in the storyboard
        }
        
        return 200
        
    }
}

extension TodayVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        metricsDisplayed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentMetric = metricsDisplayed[indexPath.row]
        //Ideally it should base the decision of order based on the array
        
        if currentMetric == "RestingHeartRate" {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: currentMetric) as? RestingHeartRate else {
                fatalError("Cell is not dequed correctly")
            }
            cell.averageHeartRateLabel.text = self.averageHeartRate
            cell.lastHeartRateLabel.text = self.lastStoredRHRValue
            cell.averageLast10.text = self.averageRHRLast10days
            return cell
        }
        
//        else if currentMetric == "Steps" {
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: currentMetric) as? RestingHeartRate else {
//                fatalError("Cell is not dequed correctly")
//            }
//            return cell
//        }
        else {
            fatalError("Unknown metric: \(currentMetric)")
        }
    }
    
    
}













//    func fetchSleepAnalysisData() {
//        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
//        let now = Date()
//        let startOfDay = Calendar.current.startOfDay(for: now)
//        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
//
//        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, results, _ in
//            guard let results = results else {
//                DispatchQueue.main.async {
//                    self.sleepAnalysisLabel.text = "N/A"
//                }
//                return
//            }
//
//            var totalSleep = 0.0
//            for result in results as? [HKCategorySample] ?? [] {
//                let sleepTime = result.endDate.timeIntervalSince(result.startDate)
//                totalSleep += sleepTime
//            }
//
//            // Convert sleep time from seconds to hours
//            let totalSleepHours = totalSleep / 3600
//            DispatchQueue.main.async {
//                self.sleepAnalysisLabel.text = String(format: "%.2f Hours", totalSleepHours)
//            }
//        }
//
//        healthStore.execute(query)
//    }
