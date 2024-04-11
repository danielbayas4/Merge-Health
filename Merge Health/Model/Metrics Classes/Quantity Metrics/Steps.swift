
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
    
    override public var unitName: String {
        return "Steps"
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
    
    override func fetchSpecificWeekDay(pastDays: Int, weekDay: Int, completion: @escaping (Int, String) -> Void){
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        
        
        
        let type = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        
        var endDate = Date()
        
        if let endOfDay = Calendar.current.date(bySettingHour: 00, minute: 00, second: 00, of: endDate) {
            endDate = endOfDay
        }
        
        let startDate = calendar.date(byAdding: .day, value: -pastDays, to: endDate)!
    
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let dateComponents = DateComponents(day: 1)
        
        let query = HKStatisticsCollectionQuery(quantityType: type,
                                                quantitySamplePredicate: predicate,
                                                anchorDate: startDate,
                                                intervalComponents: dateComponents)
        
        query.initialResultsHandler = { query, results, error in
            
            guard error == nil else {
                completion(-1, "Error in the initial results handler")
                return
            }
            
            var totalSteps: Double = 0
            var weekDayCount = 0
            
            results?.enumerateStatistics(from: startDate, to: endDate, with: { statistics, _ in
                
                let dayComponent = calendar.component(.weekday, from: statistics.startDate)
                
                
                if let quantity = statistics.sumQuantity() {
                    if dayComponent == weekDay {
                        let dailySteps = quantity.doubleValue(for: HKUnit.count())
                        totalSteps += dailySteps
                        weekDayCount += 1
                    }
                    
                }
                
                
            })
            
            let averageSteps = Int(totalSteps) / weekDayCount
            completion(averageSteps, "Success")
        }
        
        healthStore.execute(query)
    }
    
    
    override func unifyWeekDays(){
        
        
        let allWeekDays: [Int] = [2,3,4,5,6,7,1]
        let pastDays = 500
        var averageArray: [Int] = [ ]
        
        
        let dispatchGroup = DispatchGroup()
        
        for weekDay in allWeekDays {
            dispatchGroup.enter()
            
            self.fetchSpecificWeekDay(pastDays: pastDays, weekDay: weekDay) { averageWeekDay, error in
                averageArray.append(averageWeekDay)
                
                dispatchGroup.leave()
                
            }

        }
        
        dispatchGroup.notify(queue: .main) {
             
            guard let maxValue = averageArray.max(), maxValue > 0 else {
                print("No data available or maximum value is zero.")
                return
            }
            
            let valuesForProgressView = averageArray.map { Float($0) / Float(maxValue) }
            
            let averagesString = valuesForProgressView.map { "\(String(format: "%.2f", $0 * 100)) %"}
            
            self.valuesPerWeekday = averageArray
            self.valueForProgressView = valuesForProgressView
            self.comparedToMaximumString = averagesString
            
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

                completion(stepsValues, dayXLabels, "No error")
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
    
    

    
    override func fetchWeeks(completion: @escaping ([Int], [String], String) -> Void) {
            guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                print("\(self.exposingName) Type is not available in HealthKit")
                return
            }

            // Previous 25 weeks
            let weeksLength = -25

            var weekXLabels: [String] = []
            var stepsValues: [Int] = []

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-'W'ww"

            guard HKHealthStore.isHealthDataAvailable() else {
                print("Health data not available")
                return
            }

            let calendar = Calendar.current
            let endDate = Date()
            guard let startDate = calendar.date(byAdding: .weekOfYear, value: weeksLength, to: endDate) else { return }

            let statisticsOptions = HKStatisticsOptions.cumulativeSum

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: statisticsOptions,
                anchorDate: startDate,
                intervalComponents: DateComponents(weekOfYear: 1)
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
                        weekXLabels.append(dateString)
                    }
                }

                
                completion(stepsValues, weekXLabels, "No error")
            }
        

            healthStore.execute(query)
        }

    override func barChartWeeks() {
        let chartView = BarChartView()

        var xLabels: [String] = []
        var values: [Int] = []

        fetchWeeks { values_, dates, error in
            xLabels = dates
            values = values_

            let dataSetLabel = "Steps per week"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<10000:
                    return UIColor.blue
                case 10000..<50000:
                    return UIColor.green
                default:
                    return UIColor.red
                }
            }

            chartDataSet.colors = colors

            let chartData = BarChartData(dataSet: chartDataSet)

            chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xLabels)
            chartView.data = chartData
            chartView.xAxis.labelCount = xLabels.count

            DispatchQueue.main.async {
                self.weeklyBarChart = chartView
            }
        }
    }
    
    




    override func fetchMonths(completion: @escaping ([Int], [String], String) -> Void) {
            guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                print("Step Count Type is not available in HealthKit")
                return
            }

            let monthsLength = -25

            var monthXLabels: [String] = []
            var stepsValues: [Int] = []

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM yy"

            guard HKHealthStore.isHealthDataAvailable() else {
                print("Health data not available")
                return
            }

            let calendar = Calendar.current
            let endDate = Date()
            guard let startDate = calendar.date(byAdding: .month, value: monthsLength, to: endDate) else { return }

            let statisticsOptions = HKStatisticsOptions.cumulativeSum

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: statisticsOptions,
                anchorDate: startDate,
                intervalComponents: DateComponents(month: 1)
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
                        monthXLabels.append(dateString)
                    }
                }

                completion(stepsValues, monthXLabels, "No error")
            }

            healthStore.execute(query)
        }

    override func barChartMonths() {
        let chartView = BarChartView()

        var xLabels: [String] = []
        var values: [Int] = []

        fetchMonths { values_, dates, error in
            xLabels = dates
            values = values_

            let dataSetLabel = "Steps per month"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<150000:
                    return UIColor.blue
                case 150000..<300000:
                    return UIColor.orange
                case 300000..<450000:
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
                self.monthlyBarChart = chartView
            }
        }
    }
    
    override func fetchYears(completion: @escaping ([Int], [String], String) -> Void) {
            guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                print("Step Count Type is not available in HealthKit")
                return
            }

            let yearsLength = -25

            var yearXLabels: [String] = []
            var stepsValues: [Int] = []

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY"

            guard HKHealthStore.isHealthDataAvailable() else {
                print("Health data not available")
                return
            }

            let calendar = Calendar.current
            let endDate = Date()
            guard let startDate = calendar.date(byAdding: .year, value: yearsLength, to: endDate) else { return }

            let statisticsOptions = HKStatisticsOptions.cumulativeSum

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: statisticsOptions,
                anchorDate: startDate,
                intervalComponents: DateComponents(year: 1)
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
                        yearXLabels.append(dateString)
                    }
                }

                completion(stepsValues, yearXLabels, "No error")
            }

            healthStore.execute(query)
        }

    override func barChartYears() {
        let chartView = BarChartView()

        var xLabels: [String] = []
        var values: [Int] = []

        fetchYears { values_, dates, error in
            xLabels = dates
            values = values_

            let dataSetLabel = "Steps per year"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<1825000:
                    return UIColor.red
                case 1825000..<3650000:
                    return UIColor.orange
                case 3650000..<5475000:
                    return UIColor.green
                default:
                    return UIColor.blue
                }
            }

            chartDataSet.colors = colors

            let chartData = BarChartData(dataSet: chartDataSet)

            chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xLabels)
            chartView.data = chartData
            chartView.xAxis.labelCount = xLabels.count

            DispatchQueue.main.async {
                self.yearsBarChart = chartView
            }
        }
    }
    
    
    override func fetchCustomDays(userinput: Int, completion: @escaping ([Int], [String], String) -> Void) {
            guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
                print("Step Count Type is not available in HealthKit")
                return
            }


            let daysLength = -abs(userinput)

            var dayXLabels: [String] = []
            var stepValues: [Int] = []

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
                        stepValues.append(Int(value))

                        let dateString = dateFormatter.string(from: date)
                        dayXLabels.append(dateString)
                    }
                }

                completion(stepValues, dayXLabels, "No error")
            }

            healthStore.execute(query)
        }

    override func barChartCustomDays(userinput: Int) {
        let chartView = BarChartView()

        var xLabels: [String] = []
        var values: [Int] = []

        fetchCustomDays(userinput: userinput) { values_, dates, error in
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
                case 0..<5000:
                    return UIColor.blue
                case 5000..<10000:
                    return UIColor.orange
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
                self.dailyCustomBarChart = chartView
            }
        }
    }
    
    
}
