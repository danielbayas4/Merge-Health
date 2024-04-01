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
                    self.latest_value = "\(String(format: "%.0f", lastValue)) breaths/min"
                    completion("\(String(format: "%.0f", lastValue)) breaths/min")
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
        
        let metric = HKQuantityType.quantityType(forIdentifier: .respiratoryRate)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: metric,
            quantitySamplePredicate: predicate,
            options: .discreteAverage) { _, result, _ in
            
            guard let result = result, let avgQuantity = result.averageQuantity() else {
                DispatchQueue.main.async {
                    self.today_average = "N/A"
                    completion("N/A")
                }
                return
            }
            let averageRespiratoryRate = avgQuantity.doubleValue(for: HKUnit(from: "count/min"))
            
            DispatchQueue.main.async {
                self.today_average = "\(String(format: "%.0f", averageRespiratoryRate)) breaths/min"
                completion("\(String(format: "%.0f", averageRespiratoryRate)) breaths/min")
            }
        }
        
        healthStore.execute(query)
    }
    
    override func fetchAverageLastDays(completion: @escaping (String) -> Void) {
        guard let respiratoryRateType = HKQuantityType.quantityType(forIdentifier: .respiratoryRate) else {
            print("Respiratory Rate Type is not available in HealthKit")
            return
        }

        let daysLength = -10

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
                completion("There was an error with the fetching")
                return
            }

            guard let statsCollection = results else {
                DispatchQueue.main.async {
                    self.average_last_days = "N/A"
                    completion("N/A")
                }
                return
            }

            var dailyAverages: [Double] = []


            statsCollection.enumerateStatistics(from: startDate, to: endDate) { individualDay, stop in
                if let quantity = individualDay.averageQuantity() {
                    let value = quantity.doubleValue(for: HKUnit(from: "count/min"))
                    dailyAverages.append(value)
                }
            }

            let overallAverage = dailyAverages.isEmpty ? 0 : dailyAverages.reduce(0, +) / Double(dailyAverages.count)

            DispatchQueue.main.async {
                self.average_last_days = String(format: "%.1f breaths/min", overallAverage)
                completion(String(format: "%.1f breaths/min", overallAverage))
            }
        }

        healthStore.execute(query)
    }

   
    
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
    
    //📌 1/4/24: Terminar de poner los dates en los metrics, y de ahí darle con todo al registro de valores por semana

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

    
    override func fetchWeeks(completion: @escaping ([Int], [String], String) -> Void){
        let number_weeks: Int = 10
        let weekValues = [1]
    }



    override func fetchMonths(completion: @escaping ([Int], [String], String) -> Void) {
        let number_monthts: Int = 10
        let monthValues = [1]
        
    }
    
    override func fetchYears(completion: @escaping ([Int], [String], String) -> Void){
        
    }
    



    override func barChartWeeks() {
        //fatalError("Implementation needed")
    }

    override func barChartMonths()  {
        //fatalError("Implementation needed")
    }
    
    override func barChartYears() {
        
    }
}
