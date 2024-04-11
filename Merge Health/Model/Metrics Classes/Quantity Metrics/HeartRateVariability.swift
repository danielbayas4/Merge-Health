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
    
    override public var unitName: String {
        return "ms"
    }
    
    
    
    
    private override init() {
        super.init()
    }
    
    override func fetchAllData() {
        super.fetchAllData()
    }
    
    

    override func fetchSpecificWeekDay(pastDays: Int, weekDay: Int, completion: @escaping (Int, String) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        

        let type = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
        let calendar = Calendar.current
        
        var endDate = Date()
        if let endOfDay = Calendar.current.date(bySettingHour: 00, minute: 00, second: 00, of: endDate) {
            endDate = endOfDay
        }
        
        let startDate = calendar.date(byAdding: .day, value: -pastDays, to: endDate)!
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let dateComponents = DateComponents(day: 1)
        let statisticsOptions = HKStatisticsOptions.discreteAverage
        
        let query = HKStatisticsCollectionQuery(
            quantityType: type,
            quantitySamplePredicate: predicate,
            options: statisticsOptions,
            anchorDate: startDate,
            intervalComponents: dateComponents
        )
        
        query.initialResultsHandler = { query, results, error in
            guard error == nil else {
                completion(-1, "Error in the initial results handler")
                return
            }
            
            var totalHRV: Double = 0
            var weekDayCount = 0
            
            results?.enumerateStatistics(from: startDate, to: endDate, with: { statistics, _ in
                let dayComponent = calendar.component(.weekday, from: statistics.startDate)
                if let quantity = statistics.averageQuantity(), dayComponent == weekDay {
 
                    let dailyHRV = quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
                    totalHRV += dailyHRV
                    weekDayCount += 1
                }
            })
            

            let averageHRV = weekDayCount > 0 ? Int(totalHRV) / weekDayCount : 0
            completion(averageHRV, "Success")
        }
        
        healthStore.execute(query)

    }

    override func unifyWeekDays() {
        let allWeekDays: [Int] = [2,3,4,5,6,7,1]
        let pastDays = 500
        var averageArray: [Int] = []
        
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
            let averagesString = valuesForProgressView.map { "\(String(format: "%.2f", $0 * 100)) %" }
            
            
            self.valuesPerWeekday = averageArray
            self.valueForProgressView = valuesForProgressView
            self.comparedToMaximumString = averagesString
        }
    }
    
    
    override func fetchAverageTodayActivation() {
        super.fetchAverageTodayGeneral(individualMetric: self, typeIdentifier: .heartRateVariabilitySDNN, unit: HKUnit(from: "ms"), printUnit: "ms") { average in
        }
        
    }
    
    override func fetchLastValueActivation() {
        super.fetchLastValueGeneral(individualMetric: self, typeIdentifier: .heartRateVariabilitySDNN, unit: HKUnit(from: "ms"), printUnit: "ms") { lastValue in
            
        }
    }
    
    override func fetchAverageLastDaysActivation() {
        super.fetchAverageLastDaysGeneral(individualMetric: self, typeIdentifier: .heartRateVariabilitySDNN, unit: HKUnit(from: "ms"), printUnit: "ms") { averageLastDays in
            
        }
    }
    
    
    override func fetchDays(completion: @escaping ([Int], [String], String) -> Void) {
        guard let heartRateVariabilityType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            print("Heart Rate Variability Type is not available in HealthKit")
            return
        }

        let daysLength = -25

        var dayXLabels: [String] = []
        var hrvValues: [Int] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"

        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }

        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: daysLength, to: endDate) else { return }

        let statisticsOptions = HKStatisticsOptions.discreteAverage

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKStatisticsCollectionQuery(
            quantityType: heartRateVariabilityType,
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
                dayXLabels = ["N/A"]
                hrvValues = [-1, -1]
                completion([], [], "N/A")
                return
            }

            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistic, stop in
                if let quantity = statistic.averageQuantity() {
                    let date = statistic.startDate
                    let value = quantity.doubleValue(for: HKUnit(from: "ms"))
                    hrvValues.append(Int(value))

                    let dateString = dateFormatter.string(from: date)
                    dayXLabels.append(dateString)
                }
            }

            completion(hrvValues, dayXLabels, "No error")
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

            let dataSetLabel = "HRV (ms)"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            
            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<30:
                    return UIColor.red
                case 30..<60:
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
                self.dailyBarChart = chartView
            }
        }
    }
    
    override func fetchCustomDays(userinput: Int, completion: @escaping ([Int], [String], String) -> Void) {
            guard let heartRateVariabilityType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
                print("Heart Rate Variability Type is not available in HealthKit")
                return
            }

            // Use user input for the number of days
            let daysLength = -abs(userinput)

            var dayXLabels: [String] = []
            var hrvValues: [Int] = []

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"

            guard HKHealthStore.isHealthDataAvailable() else {
                print("Health data not available")
                return
            }

            let calendar = Calendar.current
            let endDate = Date()
            guard let startDate = calendar.date(byAdding: .day, value: daysLength, to: endDate) else {return}

            let statisticsOptions = HKStatisticsOptions.discreteAverage

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKStatisticsCollectionQuery(
                quantityType: heartRateVariabilityType,
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

                statsCollection.enumerateStatistics(from: startDate, to: endDate) { individual_day, stop in
                    if let quantity = individual_day.averageQuantity() {
                        let date = individual_day.startDate
                        let value = quantity.doubleValue(for: HKUnit(from: "ms"))
                        hrvValues.append(Int(value))

                        let dateString = dateFormatter.string(from: date)
                        dayXLabels.append(dateString)
                    }
                }

                completion(hrvValues, dayXLabels, "No error")
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

            let dataSetLabel = "HRV (ms)"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<30:
                    return UIColor.red
                case 30..<60:
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
                self.dailyCustomBarChart = chartView
            }
        }
    }
    
    
    
    override func fetchWeeks(completion: @escaping ([Int], [String], String) -> Void) {
            guard let heartRateVariabilityType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
                print("Heart Rate Variability Type is not available in HealthKit")
                return
            }

            // Previous 25 weeks
            let weeksLength = -25

            var weekXLabels: [String] = []
            var hrvValues: [Int] = []

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-'W'ww"

            guard HKHealthStore.isHealthDataAvailable() else {
                print("Health data not available")
                return
            }

            let calendar = Calendar.current
            let endDate = Date()
            guard let startDate = calendar.date(byAdding: .weekOfYear, value: weeksLength, to: endDate) else { return }

            let statisticsOptions = HKStatisticsOptions.discreteAverage

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKStatisticsCollectionQuery(
                quantityType: heartRateVariabilityType,
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
                    if let quantity = statistic.averageQuantity() {
                        let date = statistic.startDate

                        let value = quantity.doubleValue(for: HKUnit(from: "ms"))
                        hrvValues.append(Int(value))

                        let dateString = dateFormatter.string(from: date)
                        weekXLabels.append(dateString)
                    }
                }

                completion(hrvValues, weekXLabels, "No error")
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

            let dataSetLabel = "HRV (ms)"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            
            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<30:
                    return UIColor.red
                case 30..<60:
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
                self.weeklyBarChart = chartView
            }
        }
    }
    
    override func fetchMonths(completion: @escaping ([Int], [String], String) -> Void) {
            guard let heartRateVariabilityType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
                print("Heart Rate Variability Type is not available in HealthKit")
                return
            }

            let monthsLength = -25

            var monthXLabels: [String] = []
            var hrvValues: [Int] = []

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM yy"

            guard HKHealthStore.isHealthDataAvailable() else {
                print("Health data not available")
                return
            }

            let calendar = Calendar.current
            let endDate = Date()
            guard let startDate = calendar.date(byAdding: .month, value: monthsLength, to: endDate) else { return }

            let statisticsOptions = HKStatisticsOptions.discreteAverage

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKStatisticsCollectionQuery(
                quantityType: heartRateVariabilityType,
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
                    if let quantity = statistic.averageQuantity() {
                        let date = statistic.startDate
                        let value = quantity.doubleValue(for: HKUnit(from: "ms"))
                        hrvValues.append(Int(value))

                        let dateString = dateFormatter.string(from: date)
                        monthXLabels.append(dateString)
                    }
                }

                completion(hrvValues, monthXLabels, "No error")
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

            let dataSetLabel = "HRV (ms)"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)


            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<30:
                    return UIColor.red
                case 30..<60:
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
                self.monthlyBarChart = chartView
            }
        }
    }
    
    override func fetchYears(completion: @escaping ([Int], [String], String) -> Void) {
            guard let heartRateVariabilityType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
                print("Heart Rate Variability Type is not available in HealthKit")
                return
            }

            let yearsLength = -25

            var yearXLabels: [String] = []
            var hrvValues: [Int] = []

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY"

            guard HKHealthStore.isHealthDataAvailable() else {
                print("Health data not available")
                return
            }

            let calendar = Calendar.current
            let endDate = Date()
            guard let startDate = calendar.date(byAdding: .year, value: yearsLength, to: endDate) else { return }

            let statisticsOptions = HKStatisticsOptions.discreteAverage

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

            let query = HKStatisticsCollectionQuery(
                quantityType: heartRateVariabilityType,
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
                    if let quantity = statistic.averageQuantity() {
                        let date = statistic.startDate
                        // HRV is typically measured in milliseconds (ms)
                        let value = quantity.doubleValue(for: HKUnit(from: "ms"))
                        hrvValues.append(Int(value))

                        let dateString = dateFormatter.string(from: date)
                        yearXLabels.append(dateString)
                    }
                }

                completion(hrvValues, yearXLabels, "No error")
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

            let dataSetLabel = "HRV (ms)"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            
            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<30:
                    return UIColor.red
                case 30..<60:
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
}

