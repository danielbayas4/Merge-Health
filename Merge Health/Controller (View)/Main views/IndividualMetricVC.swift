import UIKit
import Charts
import DGCharts

class IndividualMetricVC: UIViewController {
    
    var individualMetric: QuantityMetric = QuantityMetric()
    
    @IBOutlet var metricNameLabel: UILabel!
    
    @IBOutlet var barChartView: BarChartView!
    
    
    
    @IBOutlet var daily: UIButton!
    @IBOutlet var weekly: UIButton!
    @IBOutlet var monthly: UIButton!
    @IBOutlet var yearly: UIButton!
    @IBOutlet var custom: UIButton!
    
    @IBOutlet var averagePerWeekButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
        self.dailyLoading()
        
    }
    
    func initialUI(){
        self.metricNameLabel.text = individualMetric.exposingName
        
        view.backgroundColor = UIColor(hex: "F0ECE5")
        daily.tintColor = UIColor(hex: "161A30")
        weekly.tintColor = UIColor(hex: "161A30")
        monthly.tintColor = UIColor(hex: "161A30")
        yearly.tintColor = UIColor(hex: "161A30")
        custom.tintColor = UIColor(hex: "161A30")
        averagePerWeekButton.tintColor = UIColor(hex: "161A30")
    }
    

    
    
    
    
    @IBAction func averagePerWeekAction(_ sender: Any) {
        performSegue(withIdentifier: "toAveragePerWeek", sender: self)
        
    }
    
    func dailyLoading(){
        let dailyBarChart = individualMetric.dailyBarChart
        self.updateChart(newBarChart: dailyBarChart)
        self.generalChartSettings()
        
        individualMetric.fetchDays { values, dates, error in
            DispatchQueue.main.async {
                self.addAverageLine(values: values)
            }
        }
    }
    
    @IBAction func dailyAction(_ sender: Any) {
        self.dailyLoading()
    }
    
    @IBAction func weeklyAction(_ sender: Any) {
        individualMetric.fetchWeeks { values, dates, error in
            DispatchQueue.main.async {
                let barChart: BarChartView = self.individualMetric.weeklyBarChart
                self.updateChart(newBarChart: barChart)
                self.generalChartSettings()
                self.addAverageLine(values: values)
            }
        }
        
    }
    
    @IBAction func montlyAction(_ sender: Any) {
        individualMetric.fetchMonths { values, dates, error in
            DispatchQueue.main.async {
                let barChart: BarChartView = self.individualMetric.monthlyBarChart
                self.updateChart(newBarChart: barChart)
                self.generalChartSettings()
                self.addAverageLine(values: values)
            }
        }
        
    }
   
    @IBAction func yearlyAction(_ sender: Any) {
        individualMetric.fetchYears { values, dates, error in
            DispatchQueue.main.async {
                let barChart: BarChartView = self.individualMetric.yearsBarChart
                self.updateChart(newBarChart: barChart)
                self.generalChartSettings()
                self.addAverageLine(values: values)
            }
        }

        
    }
    
    @IBAction func customAction(_ sender: Any) {
        self.presentCustomRangeInputAlert()

    }
    
    func presentCustomRangeInputAlert() {
        let alertController = UIAlertController(title: "Custom Range", message: "Enter the number of past days:", preferredStyle: .alert)
        
        
        
        alertController.addTextField { textField in
            textField.placeholder = "Number of days"
            textField.keyboardType = .numberPad
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first, let userInputString = textField.text, let userInput = Int(userInputString) {
                self?.fetchAndDisplayCustomData(userInput: userInput)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func fetchAndDisplayCustomData(userInput: Int) {
        
        individualMetric.barChartCustomDays(userinput: userInput)
        
        self.individualMetric.fetchCustomDays(userinput: userInput) { [weak self] values, dates, error in
            
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                let barChart = self.individualMetric.dailyCustomBarChart
                self.updateChart(newBarChart: barChart)
                self.generalChartSettings()
                self.addAverageLine(values: values)
                
            }
        }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAveragePerWeek" {
            let destVC = segue.destination as! AveragePerWeekVC
            destVC.individualMetric = self.individualMetric //possible bug: I am not sure if this will completely work.
            destVC.modalPresentationStyle = .fullScreen
        }
    }
    
    
    func updateChart(newBarChart: BarChartView) -> Void {
        barChartView.copyAllSettings(from: newBarChart)
        barChartView.leftAxis.removeAllLimitLines()
    }
    
    func addAverageLine(values: [Int]) {
        let averageValue = Double(values.reduce(0, +)) / Double(values.count)
        let averageLine = ChartLimitLine(limit: averageValue, label: "Average")
        averageLine.lineWidth = 2.0
        averageLine.lineColor = .red
        averageLine.labelPosition = .rightTop
        averageLine.valueFont = .systemFont(ofSize: 10)
        
        self.barChartView.leftAxis.addLimitLine(averageLine)
    }
    
    func generalChartSettings() {
        //General characteristics
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.labelRotationAngle = -45
        barChartView.xAxis.wordWrapEnabled = true
        barChartView.xAxis.avoidFirstLastClippingEnabled = true
        
        barChartView.xAxis.drawLabelsEnabled = true
        barChartView.xAxis.drawAxisLineEnabled = true
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
}
