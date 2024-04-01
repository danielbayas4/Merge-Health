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
    
    
    override func fetchAllData() {
        super.fetchAllData()
        
    }

    
    override func fetchLastValue(completion: @escaping (String) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        
        let metric = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        let now = Date.now
        let startDay = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startDay, end: now, options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: metric, predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]) { (query, results, error) in
            guard error == nil else {
                completion("N/A")
                print("Error fetching resting heart rate: \(String(describing: error))")
                return
            }
            
            if let lastResult = results?.first as? HKQuantitySample {
                let lastValue = lastResult.quantity.doubleValue(for: HKUnit(from: "count/min"))
                DispatchQueue.main.async {
                    self.latest_value = "\(Int(lastValue)) BPM"
                    completion("\(Int(lastValue)) BPM")
                }
                
            }
        }
        
        healthStore.execute(query)
    }
    
    override func fetchAverageToday(completion: @escaping (String) -> Void) {
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return
        }
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        let now = Date.now //Date()
        let startOfDay = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        
        let query = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: predicate, options: .discreteAverage) { _, result, _ in
            
            guard let result = result, let avgQuantity = result.averageQuantity() else {
                DispatchQueue.main.async {
                    self.today_average = "N/A"
                    
                    completion("N/A")
                }
                return
            }
            let heartRate = avgQuantity.doubleValue(for: HKUnit(from: "count/min"))
            
            DispatchQueue.main.async {
                self.today_average = "\(Int(heartRate)) BPM"
                completion("\(Int(heartRate)) BPM")
            }
        }
        
        healthStore.execute(query)
    }
    
    override func fetchAverageLastDays(completion: @escaping (String) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            print("Resting Heart Rate Type is not available in HealthKit")
            return
        }
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        
        let daysLength = -10
        
        let calendar = Calendar.current
        let endDate = Date()
        guard let startDate = calendar.date(byAdding: .day, value: daysLength, to: endDate) else {return}
        
        //defining the cumulative sum
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
                completion("There was an error fetching the data")
                return
            }
            
            
            guard let statsCollection = results else {
                self.average_last_days = "N/A"
                completion("N/A")
                return
            }
        
            var dailyAverages: [Double] = []
            var parallelDates: [Date] = []
            var stringParallelDates: [String] = []
            
            

            statsCollection.enumerateStatistics(from: startDate, to: endDate) { individual_day, stop in
                if let quantity = individual_day.averageQuantity() {
                    let date = individual_day.startDate
                    let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    dailyAverages.append(value)
                    parallelDates.append(date)

                    
                    let dateString = dateFormatter.string(from: date)
                    stringParallelDates.append(dateString)

                }
            }
            
            
            let overallAverage = dailyAverages.reduce(0, { current_value, nextCollectionElement in
                current_value + nextCollectionElement
            }) / Double(dailyAverages.count)
            
            DispatchQueue.main.async {
                self.average_last_days = String(format: "%.2f BPM", overallAverage)

            }
            
        }
        
        healthStore.execute(query)
        
        
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



