import UIKit

class IndividualMetricVC: UIViewController {
    //Buttons for the graph
    @IBOutlet var daily: UIButton!
    @IBOutlet var weekly: UIButton!
    @IBOutlet var monthly: UIButton!
    @IBOutlet var yearly: UIButton!
    @IBOutlet var custom: UIButton!
    
    
    
    @IBOutlet var averagePerWeekButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
        
        // Do any additional setup after loading the view.
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAveragePerWeek" {
            let destVC = segue.destination //as! AveragePerWeekVC
            destVC.modalPresentationStyle = .fullScreen
        }
    }
}
