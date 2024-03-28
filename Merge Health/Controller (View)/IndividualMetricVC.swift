import UIKit

class IndividualMetricVC: UIViewController {
    
    //var metric: QuantityMetric = QuantityMetric(name: "")
    
    @IBOutlet var daily: UIButton!
    @IBOutlet var weekly: UIButton!
    @IBOutlet var monthly: UIButton!
    @IBOutlet var yearly: UIButton!
    @IBOutlet var custom: UIButton!
    
    
    
    //BarChartObject
    
    
    
    
    
    
    @IBOutlet var averagePerWeekButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
    }
    
    func initialUI(){
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
    
    @IBAction func dailyAction(_ sender: Any) {
        
    }
    
    @IBAction func weeklyAction(_ sender: Any) {
        
        self.updateChart(/*new chart*/)
        
    }
    
    @IBAction func montlyAction(_ sender: Any) {
        
        self.updateChart(/*new chart*/)
        
    }
   
    @IBAction func yearlyAction(_ sender: Any) {
        self.updateChart(/*new chart*/)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAveragePerWeek" {
            let destVC = segue.destination as! AveragePerWeekVC
            destVC.modalPresentationStyle = .fullScreen
            //exp: send the information that will identify the type of metric choosen
        }
    }
    
    
    func updateChart(/*new chart*/) -> Void {
        
        
        
        //chartView.removeFromSuperView()
        
        //chartView = newChart
        
        //view.addSubview(chartView)
        
        
        
        
        //Get the quantityMetricObject, and then uses the function
        
        //Possibly something related to the layout of the graph
    }
}
