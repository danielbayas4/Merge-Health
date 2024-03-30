import UIKit
import HealthKit

class GeneralDashboardVC: UIViewController {
    
    //Buttons for the different metrics
    @IBOutlet var restingHeartRateButton: UIButton!
    @IBOutlet var heartRateVariabilityButton: UIButton!
    @IBOutlet var walkingHeartRateButton: UIButton!
    
    @IBOutlet var stepsButton: UIButton!
    @IBOutlet var workoutTimeButton: UIButton!
    
    @IBOutlet var deepSleep: UIButton!
    @IBOutlet var REMSleepButton: UIButton!
    //Just a testing
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
    }
    
    @IBAction func restingHeartRateAction(_ sender: Any) {
        
    }
    
    @IBAction func stepsAction(_ sender: Any) {
        
    }
    
    
    func initialUI(){
        view.backgroundColor = UIColor(hex: "F0ECE5")
        restingHeartRateButton.tintColor = UIColor(hex: "161A30")
        heartRateVariabilityButton.tintColor = UIColor(hex: "161A30")
        walkingHeartRateButton.tintColor = UIColor(hex: "161A30")
        stepsButton.tintColor = UIColor(hex: "161A30")
        workoutTimeButton.tintColor = UIColor(hex: "161A30")
        deepSleep.tintColor = UIColor(hex: "161A30")
        REMSleepButton.tintColor = UIColor(hex: "161A30")
    }
    
    @IBAction func restingHeartRate(_ sender: Any) {
        performSegue(withIdentifier: "toIndividualMetric", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! IndividualMetricVC
        destVC.modalPresentationStyle = .fullScreen
        //exp: send the information that will identify the type of metric choosen
        
        
        //Implement it in a form of a table, and do like
                //let color_ = colors[indexPath.row]
                
                //The use of the sender
                // performSegue(withIdentifier: "ToColorsDetailVC", sender: color_)
        
        
    }

}