//
//  resting_heart_rate.swift
//

import Foundation

import DGCharts
import HealthKit

class RestingHeartRateM: QuantityMetric {
    static let shared = RestingHeartRateM()
    
    private override init() {
        super.init()
    }
    

    override var todayTVC_Name: String {
        return todayTVC_Names.restingHeartRate
    }
    override var exposingName: String {
        return exposingNames.restingHeartRate
    }
    
    override public var unitName: String {
        return "BPM"
    }
    
    
    override func fetchAllData() {
        super.fetchAllData()
        
    }
    
    
    override func fetchSpecificWeekDay(pastDays: Int, weekDay: Int, completion: @escaping (Int, String) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        

        let type = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
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
            
            var totalHeartRate: Double = 0
            var weekDayCount = 0
            
            results?.enumerateStatistics(from: startDate, to: endDate, with: { statistics, _ in
                let dayComponent = calendar.component(.weekday, from: statistics.startDate)
                if let quantity = statistics.averageQuantity(), dayComponent == weekDay {

                    let dailyHeartRate = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    totalHeartRate += dailyHeartRate
                    weekDayCount += 1
                }
            })
            
            
            let averageHeartRate = weekDayCount > 0 ? Int(totalHeartRate) / weekDayCount : 0 
            

            completion(averageHeartRate, "Success")
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
    
    
    
    
    func simplifiedUnifyWeekDaysForTesting(from averageArray: [Int]) -> (maxValue: Int, valuesForProgressView: [Float], averagesString: [String]) {
        guard let maxValue = averageArray.max(), maxValue > 0 else {
            print("No data available or maximum value is zero.")
            return (0, [], [])
        }
        
        let valuesForProgressView = averageArray.map { round(Float($0) / Float(maxValue) * 100) / 100 }
        
        //Here make it so that the values have a maximum of two decimals
        
        let averagesString = valuesForProgressView.map { "\(String(format: "%.0f", $0 * 100))%" }
        
        return (maxValue, valuesForProgressView, averagesString)
    }
    
    
    
    
    
    
    override func fetchAverageTodayActivation() {
        super.fetchAverageTodayGeneral(individualMetric: self, typeIdentifier: .restingHeartRate, unit: HKUnit(from: "count/min"), printUnit: "BPM") { average in
        }
    }
    
    override func fetchLastValueActivation() {
        super.fetchLastValueGeneral(individualMetric: self, typeIdentifier: .restingHeartRate, unit: HKUnit(from: "count/min"), printUnit: "BPM") { lastValue in
            
        }
    }
    
    override func fetchAverageLastDaysActivation() {
        super.fetchAverageLastDaysGeneral(individualMetric: self, typeIdentifier: .restingHeartRate, unit: HKUnit(from: "count/min"), printUnit: "BPM") { averageLastDays in
            
        }
    }
    
    
    
    
    
    
    
    override func fetchDays(completion: @escaping ([Int], [String], String) -> Void) {
        
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            print("Resting Heart Rate Type is not available in HealthKit")
            return
        }
        
        let daysLength = -25
        
        var dayXLabels: [String] = []
        var heartRateValues: [Int] = []
        
        
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
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: statisticsOptions,
            anchorDate: startDate,
            intervalComponents: DateComponents(day: 1)
        )
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                
                completion( [] , [] , "The was an error trying to fetch the data")
                return
            }
            
            guard let statsCollection = results else {
                dayXLabels = ["N/A"]
                heartRateValues = [-1, -1]
                completion([], [], "N/A")
                return
            }
            
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { individual_day, stop in
                if let quantity = individual_day.averageQuantity() {
                    let date = individual_day.startDate
                    let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    heartRateValues.append(Int(value))
                    
                    let dateString = dateFormatter.string(from: individual_day.startDate)
                    dayXLabels.append(dateString)
                }
            }
            
            completion(heartRateValues, dayXLabels, "No error")

        }
        
        healthStore.execute(query)
        //
    }
    

    override func fetchCustomDays(userinput: Int, completion: @escaping ([Int], [String], String) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            print("Resting Heart Rate Type is not available in HealthKit")
            
            return
        }
        
        //past 10 days
        let daysLength = -abs(userinput)
        
        var dayXLabels: [String] = []
        var heartRateValues: [Int] = []
        
        
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
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: statisticsOptions,
            anchorDate: startDate,
            intervalComponents: DateComponents(day: 1)
        )
        
        query.initialResultsHandler = { query, results, error in
            
            if error != nil {
                
                completion( [] , [] , "The was an error trying to fetch the data")
                return
            }
            
            guard let statsCollection = results else {
                dayXLabels = ["N/A"]
                heartRateValues = [-1, -1]
                completion([], [], "N/A")
                return
            }
            
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { individual_day, stop in
                if let quantity = individual_day.averageQuantity() {
                    let date = individual_day.startDate
                    let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    heartRateValues.append(Int(value))
                    
                    let dateString = dateFormatter.string(from: individual_day.startDate)
                    dayXLabels.append(dateString)
                }
            }

            completion(heartRateValues, dayXLabels, "No error")

        }
        
        healthStore.execute(query)
    }
    

    
    override func fetchWeeks(completion: @escaping ([Int], [String], String) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            print("Resting Heart Rate Type is not available in HealthKit")
            return
        }
        
        // Previous 25 weeks
        let weeksLength = -25
        
        var weekXLabels: [String] = []
        var heartRateValues: [Int] = []
        
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
            quantityType: heartRateType,
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
                    let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    heartRateValues.append(Int(value))
                    
                    let dateString = dateFormatter.string(from: statistic.startDate)
                    weekXLabels.append(dateString)
                }
            }
            
            completion(heartRateValues, weekXLabels, "No error")
            
        }
        
        
        healthStore.execute(query)
    }



    override func fetchMonths(completion: @escaping ([Int], [String], String) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            print("Resting Heart Rate Type is not available in HealthKit")
            return
        }
        
        let monthsLength = -25
        
        var monthXLabels: [String] = []
        var heartRateValues: [Int] = []
        
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
            quantityType: heartRateType,
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
                    let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    heartRateValues.append(Int(value))
                    
                    let dateString = dateFormatter.string(from: statistic.startDate)
                    monthXLabels.append(dateString)
                }
            }
            
            completion(heartRateValues, monthXLabels, "No error")
        }
        
        healthStore.execute(query)
    }
    
    override func fetchYears(completion: @escaping ([Int], [String], String) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            print("Resting Heart Rate Type is not available in HealthKit")
            return
        }
        

        let yearsLength = -25
        
        var yearXLabels: [String] = []
        var heartRateValues: [Int] = []
        
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
            quantityType: heartRateType,
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
                    heartRateValues.append(Int(value))
                    
                    let dateString = dateFormatter.string(from: statistic.startDate)
                    yearXLabels.append(dateString)
                }
            }
            completion(heartRateValues, yearXLabels, "No error")
        }
        
        healthStore.execute(query)
    }

    
    
    
    
    
    
    //Creation of the chart objects

    override func barChartDays() {
        let chartView = BarChartView()
        
        var xLabels: [String] = []
        var values: [Int] = []
        
        fetchDays { values_, dates, error in
            xLabels = dates
            values = values_
            
            let dataSetLabel = "Beats per minute"
            
            var dataEntries: [BarChartDataEntry] = []
            
        

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)
            
            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<45:
                    return UIColor.blue
                
                case 45..<57:
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
    
    override func barChartCustomDays(userinput: Int) {
        let chartView = BarChartView()
        
        var xLabels: [String] = []
        var values: [Int] = []
        
        fetchCustomDays (userinput: userinput){ values_, dates, error in
            xLabels = dates
            values = values_
            
            let dataSetLabel = "Beats per minute"
            
            var dataEntries: [BarChartDataEntry] = []
            
        

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)
            
            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<45:
                    return UIColor.blue
                
                case 45..<57:
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
    


    override func barChartWeeks() {
        let chartView = BarChartView()
        
        var xLabels: [String] = []
        var values: [Int] = []
        
        fetchWeeks { values_, dates, error in
            xLabels = dates
            values = values_
            
            let dataSetLabel = "Beats per minute"
            
            var dataEntries: [BarChartDataEntry] = []
            
            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)
            
            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<45:
                    return UIColor.blue
                
                case 45..<57:
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

    override func barChartMonths() {
        let chartView = BarChartView()

        var xLabels: [String] = []
        var values: [Int] = []

        fetchMonths { values_, dates, error in
            xLabels = dates
            values = values_

            let dataSetLabel = "Beats per minute"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<45:
                    return UIColor.blue

                case 45..<57:
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
    
    override func barChartYears() {
        let chartView = BarChartView()

        var xLabels: [String] = []
        var values: [Int] = []
        
        fetchYears { values_, dates, error in
            xLabels = dates
            values = values_

            let dataSetLabel = "Beats per minute"

            var dataEntries: [BarChartDataEntry] = []

            for i in 0..<values.count {
                let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]))
                dataEntries.append(dataEntry)
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: dataSetLabel)

            
            let colors: [UIColor] = values.map { value in
                switch value {
                case 0..<45:
                    return UIColor.blue
                case 45..<57:
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



