
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
        super.fetchAllData()
        
        self.fetchExpectedTotalValueUntilNow { _ in
            
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
    
    
    override func fetchLastValueActivation() {
        super.fetchLastValueGeneral(individualMetric: self, typeIdentifier: .stepCount, unit: HKUnit.count(), printUnit: "steps") { lastValue in
        }
    }
    
    override func fetchAverageLastDaysActivation() {
        self.fetchAverageLastDaysSpecific { averageValue in
            
        }
    }
    
    //Forecast of how many steps at the end of the day (based on the last 10 days)
    func fetchAverageLastDaysSpecific(completion: @escaping (String) -> Void) {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("Step Count Type is not available in HealthKit")
            return
        }
        
        let daysLength = -25
        
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
    
    
    override func fetchDays(completion: @escaping ([Int], [String], String) -> Void) {
            guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                print("Step Count type is not available in HealthKit")
                return
            }

            let daysLength = -25

            var dayXLabels: [String] = []
            var stepsValues: [Int] = []

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"

            guard HKHealthStore.isHealthDataAvailable() else {
                print("Health data not available")
                return
            }

            let calendar = Calendar.current
            let endDate = Date()
            guard let startDate = calendar.date(byAdding: .day, value: daysLength, to: endDate) else { return }

            let statisticsOptions = HKStatisticsOptions.cumulativeSum

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: statisticsOptions,
                anchorDate: startDate,
                intervalComponents: DateComponents(day: 1)
            )

            query.initialResultsHandler = { query, results, error in
                if error != nil {
                    completion([], [], "There was an error trying to fetch the data")
                    return
                }

                guard let statsCollection = results else {
                    completion([], [], "N/A")
                    return
                }

                statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistic, stop in
                    if let quantity = statistic.sumQuantity() {
                        let date = statistic.startDate
                        let value = quantity.doubleValue(for: HKUnit.count())
                        stepsValues.append(Int(value))

                        let dateString = dateFormatter.string(from: date)
                        dayXLabels.append(dateString)
                    }
                }
            }

            healthStore.execute(query)
        }

    override func barChartDays() {
        let chartView = BarChartView()

        var xLabels: [String] = []
        var values: [Int] = []

        fetchDays { values_, dates, error in
            xLabels = dates
            values = values_

            let dataSetLabel = "Steps"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<3000:
                    return UIColor.red
                case 3000..<7000:
                    return UIColor.orange
                case 7000..<10000:
                    return UIColor.yellow
                default:
                    return UIColor.green
                }
            }

            chartDataSet.colors = colors

            let chartData = BarChartData(dataSet: chartDataSet)

            chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xLabels)
            chartView.data = chartData
            chartView.xAxis.labelCount = xLabels.count

            DispatchQueue.main.async {
                self.dailyBarChart = chartView
            }
        }
    }
    
    
    
    
    
    
    


    override func fetchMonths(completion: @escaping ([Int], [String], String) -> Void) {
        let number_monthts: Int = 10
        let monthValues = [1]
        
    }
    
    override func fetchYears(completion: @escaping ([Int], [String], String) -> Void){
        
    }
    

    


    override func barChartMonths(){
        
        //fatalError("Implementation needed")
    }
    
    override func barChartYears() {
        
    }
}
