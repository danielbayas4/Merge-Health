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
        super.fetchAllData()
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

