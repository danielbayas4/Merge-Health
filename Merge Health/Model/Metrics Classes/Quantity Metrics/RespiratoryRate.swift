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
        super.fetchAllData()
    }
    
    override func fetchAverageTodayActivation() {
        super.fetchAverageTodayGeneral(individualMetric: self, typeIdentifier: .respiratoryRate, unit: HKUnit(from: "count/min"), printUnit: "breaths/min") { final_value in
            
        }
    }
    
    override func fetchLastValueActivation() {
        super.fetchLastValueGeneral(individualMetric: self, typeIdentifier: .respiratoryRate, unit: HKUnit(from: "count/min"), printUnit: "breaths/min") { lastValue in
            
        }
    }
    
    override func fetchAverageLastDaysActivation() {
        super.fetchAverageLastDaysGeneral(individualMetric: self, typeIdentifier: .respiratoryRate, unit: HKUnit(from: "count/min"), printUnit: "breaths/min") { averageLastDays in
            
        }
    }
    
    
    
    //    override func fetchAverageLastDays(completion: @escaping (String) -> Void) {
    //        guard let respiratoryRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else {
    //            print("Respiratory Rate Type is not available in HealthKit")
    //            return
    //        }
    //
    //        let daysLength = -10
    //
    //        let calendar = Calendar.current
    //        let endDate = Date()
    //        guard let startDate = calendar.date(byAdding: .day, value: daysLength, to: endDate) else { return }
    //
    //
    //        let statisticsOptions = HKStatisticsOptions.discreteAverage
    //
    //        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
    //
    //        let query = HKStatisticsCollectionQuery(
    //            quantityType: respiratoryRateType,
    //            quantitySamplePredicate: predicate,
    //            options: statisticsOptions,
    //            anchorDate: startDate,
    //            intervalComponents: DateComponents(day: 1)
    //        )
    //
    //        query.initialResultsHandler = { query, results, error in
    //            if error != nil {
    //                completion("There was an error with the fetching")
    //                return
    //            }
    //
    //            guard let statsCollection = results else {
    //                DispatchQueue.main.async {
    //                    self.average_last_days = "N/A"
    //                    completion("N/A")
    //                }
    //                return
    //            }
    //
    //            var dailyAverages: [Double] = []
    //
    //
    //            statsCollection.enumerateStatistics(from: startDate, to: endDate) { individualDay, stop in
    //                if let quantity = individualDay.averageQuantity() {
    //                    let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
    //                    dailyAverages.append(value)
    //                }
    //            }
    //
    //            let overallAverage = dailyAverages.isEmpty ? 0 : dailyAverages.reduce(0, +) / Double(dailyAverages.count)
    //
    //            DispatchQueue.main.async {
    //                self.average_last_days = String(format: "%.1f breaths/min", overallAverage)
    //                completion(String(format: "%.1f breaths/min", overallAverage))
    //            }
    //        }
    //
    //        healthStore.execute(query)
    //    }
    
    
    
    override func fetchDays(completion: @escaping ([Int], [String], String) -> Void) {
        guard let respiratoryRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else {
            print("Respiratory Rate Type is not available in HealthKit")
            return
        }
        
        let daysLength = -25
        
        var dayXLabels: [String] = []
        var respiratoryRates: [Int] = []
        
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
            quantityType: respiratoryRateType,
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
                respiratoryRates = [-1, -1]
                completion([], [], "N/A")
                return
            }
            
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { statistic, stop in
                if let quantity = statistic.averageQuantity() {
                    let date = statistic.startDate
                    let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    respiratoryRates.append(Int(value))
                    
                    let dateString = dateFormatter.string(from: date)
                    dayXLabels.append(dateString)
                }
            }
            
            completion(respiratoryRates, dayXLabels, "No error")
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
            
            let dataSetLabel = "Breaths per minute"
            
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)
            
            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<12:
                    return UIColor.blue
                case 12..<20:
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
                self.dailyBarChart = chartView
            }
        }
    }
    
    override func fetchCustomDays(userinput: Int, completion: @escaping ([Int], [String], String) -> Void) {
            guard let respirationRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else {
                print("Respiration Rate Type is not available in HealthKit")
                return
            }
        
        
            let daysLength = -abs(userinput)

            var dayXLabels: [String] = []
            var respirationRateValues: [Int] = []

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
                quantityType: respirationRateType,
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
                    if let quantity = statistic.averageQuantity() {
                        let date = statistic.startDate
                        
                        let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                        respirationRateValues.append(Int(value))

                        let dateString = dateFormatter.string(from: date)
                        dayXLabels.append(dateString)
                    }
                }

                completion(respirationRateValues, dayXLabels, "No error")
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

            let dataSetLabel = "Breaths per minute"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)
            
            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<12:
                    return UIColor.blue
                case 12..<20:
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
                self.dailyCustomBarChart = chartView
            }
        }
    }
    
    
    override func fetchWeeks(completion: @escaping ([Int], [String], String) -> Void) {
        guard let respirationRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else {
            print("Respiration Rate Type is not available in HealthKit")
            return
        }
        
        let weeksLength = -25
        
        var weekXLabels: [String] = []
        var respirationRateValues: [Int] = []
        
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
            quantityType: respirationRateType,
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
                    
                    let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    respirationRateValues.append(Int(value))
                    
                    let dateString = dateFormatter.string(from: statistic.startDate)
                    weekXLabels.append(dateString)
                }
            }
            
            completion(respirationRateValues, weekXLabels, "No error")
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
            
            let dataSetLabel = "Breaths per minute"
            
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)
            
            
            let colors: [UIColor] = values.map { value in
                
                switch value {
                case 0..<12:
                    return UIColor.blue
                case 12..<20:
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
        guard let respiratoryRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else {
            print("Respiratory Rate Type is not available in HealthKit")
            return
        }
        
        let monthsLength = -25
        
        var monthXLabels: [String] = []
        var respiratoryRateValues: [Int] = []
        
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
            quantityType: respiratoryRateType,
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
                    let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    respiratoryRateValues.append(Int(round(value)))
                    
                    let dateString = dateFormatter.string(from: statistic.startDate)
                    monthXLabels.append(dateString)
                }
            }
            
            completion(respiratoryRateValues, monthXLabels, "No error")
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
            
            let dataSetLabel = "Breaths per minute"
            
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)
            
            
            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<12:
                    return UIColor.blue
                case 12..<16:
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
                self.monthlyBarChart = chartView
            }
        }
    }
    
    
    
    override func fetchYears(completion: @escaping ([Int], [String], String) -> Void) {
        guard let respiratoryRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else {
            print("Respiratory Rate Type is not available in HealthKit")
            return
        }
        
        let yearsLength = -25
        
        var yearXLabels: [String] = []
        var respiratoryRateValues: [Int] = []
        
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
            quantityType: respiratoryRateType,
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
                    
                    let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    respiratoryRateValues.append(Int(value))
                    
                    let dateString = dateFormatter.string(from: date)
                    yearXLabels.append(dateString)
                }
            }
            
            completion(respiratoryRateValues, yearXLabels, "No error")
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
            
            let dataSetLabel = "Breaths per minute"
            
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)
            
            
            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<12:
                    return UIColor.blue
                case 12..<20:
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
                self.yearsBarChart = chartView
            }
        }
    }
}
