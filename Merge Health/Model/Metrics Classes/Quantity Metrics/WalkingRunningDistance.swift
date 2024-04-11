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
    
    override public var unitName: String {
        return "Distance"
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
    
    override func fetchSpecificWeekDay(pastDays: Int, weekDay: Int, completion: @escaping (Int, String) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        

        let type = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
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
            
            var totalDistance: Double = 0
            var weekDayCount = 0
            
            results?.enumerateStatistics(from: startDate, to: endDate, with: { statistics, _ in
                
                let dayComponent = calendar.component(.weekday, from: statistics.startDate)
                
                if let quantity = statistics.sumQuantity() {
                    if dayComponent == weekDay {
                        let dailyDistance = quantity.doubleValue(for: HKUnit.meter())
                        totalDistance += dailyDistance
                        weekDayCount += 1
                    }
                    
                }
                
            })
            
            let averageDistance = weekDayCount > 0 ? Int(totalDistance) / weekDayCount : 0
            completion(averageDistance, "Success")
        }
        
        healthStore.execute(query)
    }
    
    override func unifyWeekDays(){
        
        //From monday to sunday (Sunday is 1)
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
            
            debugPrint("VALUES: ", averageArray, " / PROGRESS VIEW", valuesForProgressView, " / STRING", averagesString)
            
            self.valuesPerWeekday = averageArray
            self.valueForProgressView = valuesForProgressView
            self.comparedToMaximumString = averagesString
            
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
    

    override func fetchLastValueActivation() {
        self.fetchLastValueSpecific { lastValue in
            
        }
    }
    func fetchLastValueSpecific(completion: @escaping (String) -> Void) {
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


            let lastQuantity = lastSample.quantity.doubleValue(for: HKUnit.meter())
            let kilometers = lastQuantity / 1000
            let meters = lastQuantity.truncatingRemainder(dividingBy: 1000)

 
            let endDate = lastSample.endDate
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: endDate)
            
            self.latest_value = String(format: "%.2f km / %.0f m (%@)", kilometers, meters, timeString)
            completion(self.latest_value)
        }
        
        self.healthStore.execute(query)
    }
    
    
    override func fetchAverageLastDaysActivation() {
        self.fetchAverageLastDaysSpecific { averageLastDays in
            
        }
    }
    func fetchAverageLastDaysSpecific(completion: @escaping (String) -> Void) {
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
            guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
                print("Distance Walking/Running Type is not available in HealthKit")
                return
            }

            // Past 25 days
            let daysLength = -25

            var dayXLabels: [String] = []
            var distanceValues: [Int] = []

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
                quantityType: distanceType,
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
                        let value = quantity.doubleValue(for: HKUnit.meter())
                        distanceValues.append(Int(value)) // Convert meters to an Int

                        let dateString = dateFormatter.string(from: date)
                        dayXLabels.append(dateString)
                    }
                }

                completion(distanceValues, dayXLabels, "No error")
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

            let dataSetLabel = "Distance (m)"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<4000:
                    return UIColor.red
                case 4000..<9000:
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
            guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
                print("\(self.exposingName) Type is not available in HealthKit")
                return
            }


            let weeksLength = -25

            var weekXLabels: [String] = []
            var distanceValues: [Int] = []

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
                quantityType: distanceType,
                quantitySamplePredicate: predicate,
                options: statisticsOptions,
                anchorDate: startDate,
                intervalComponents: DateComponents(weekOfYear: 1)
            )

            query.initialResultsHandler = { query, results, error in
                if error != nil {
                    completion([], [], "There was an error trying to fetch the data of \(self.exposingName)")
                    return
                }

                guard let statsCollection = results else {
                    completion([], [], "N/A")
                    return
                }

                statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistic, stop in
                    if let quantity = statistic.sumQuantity() {
                        let date = statistic.startDate
                        let value = quantity.doubleValue(for: HKUnit.meter())
                        distanceValues.append(Int(value)) // Convert meters to an Int

                        let dateString = dateFormatter.string(from: date)
                        weekXLabels.append(dateString)
                    }
                }

                completion(distanceValues, weekXLabels, "No error")
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

            let dataSetLabel = "Distance (m) per week"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<28000:
                    return UIColor.red
                case 28000..<63000:
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
                self.weeklyBarChart = chartView
            }
        }
    }
    
    override func fetchMonths(completion: @escaping ([Int], [String], String) -> Void) {
            guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
                print("Distance Walking/Running Type is not available in HealthKit")
                return
            }

            let monthsLength = -25

            var monthXLabels: [String] = []
            var distanceValues: [Int] = []

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
                quantityType: distanceType,
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
                        let value = quantity.doubleValue(for: HKUnit.meter())
                        distanceValues.append(Int(value)) // Convert meters to an Int

                        let dateString = dateFormatter.string(from: date)
                        monthXLabels.append(dateString)
                    }
                }

                completion(distanceValues, monthXLabels, "No error")
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

            let dataSetLabel = "Distance (m) per month"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<120000:
                    return UIColor.red
                case 120000..<270000:
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
            guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
                print("Distance Walking/Running Type is not available in HealthKit")
                return
            }

            let yearsLength = -25

            var yearXLabels: [String] = []
            var distanceValues: [Int] = []

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
                quantityType: distanceType,
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
                        let value = quantity.doubleValue(for: HKUnit.meter())
                        distanceValues.append(Int(value))

                        let dateString = dateFormatter.string(from: date)
                        yearXLabels.append(dateString)
                    }
                }

                completion(distanceValues, yearXLabels, "No error")
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

            let dataSetLabel = "Distance (m) per year" // Label as meters

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<1600000: //365*4000 = 1460000
                    return UIColor.red
                case 1600000..<3285000:
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
                self.yearsBarChart = chartView
            }
        }
    }
    
    override func fetchCustomDays(userinput: Int, completion: @escaping ([Int], [String], String) -> Void) {
            guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
                print("Distance Walking/Running Type is not available in HealthKit")
                return
            }

            let daysLength = -abs(userinput)

            var dayXLabels: [String] = []
            var distanceValues: [Int] = []

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
                quantityType: distanceType,
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
                        let value = quantity.doubleValue(for: HKUnit.meter())
                        distanceValues.append(Int(value)) // Convert meters to an Int

                        let dateString = dateFormatter.string(from: date)
                        dayXLabels.append(dateString)
                    }
                }

                completion(distanceValues, dayXLabels, "No error")
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

            let dataSetLabel = "Distance (m)" // Label as meters

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<4000:
                    return UIColor.red
                case 4000..<10000:
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
                self.dailyCustomBarChart = chartView
            }
        }
    }

}
