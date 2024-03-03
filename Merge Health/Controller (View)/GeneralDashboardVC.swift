import UIKit

class GeneralDashboardVC: UIViewController {
    
    //Buttons for the different metrics
    @IBOutlet var restingHeartRateButton: UIButton!
    @IBOutlet var heartRateVariabilityButton: UIButton!
    @IBOutlet var walkingHeartRateButton: UIButton!
    
    @IBOutlet var stepsButton: UIButton!
    @IBOutlet var workoutTimeButton: UIButton!
    
    @IBOutlet var deepSleep: UIButton!
    @IBOutlet var REMSleepButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
    }
    
    func initialUI(){
        view.backgroundColor = UIColor(hex: "F0ECE5")
    }
    
    @IBAction func restingHeartRate(_ sender: Any) {
        performSegue(withIdentifier: "toIndividualMetric", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Implement it in a form of a table, and do like
                //let color_ = colors[indexPath.row]
                
                //The use of the sender
                // performSegue(withIdentifier: "ToColorsDetailVC", sender: color_)
        
        
        let destVC = segue.destination as! IndividualMetricVC
        destVC.modalPresentationStyle = .fullScreen
    }

}
