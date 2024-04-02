import UIKit
import HealthKit

class GeneralDashboardVC: UIViewController {
    
    
    
    //Buttons for the different metrics
    @IBOutlet var restingHeartRateButton: UIButton!
    @IBOutlet var heartRateVariabilityButton: UIButton!
    @IBOutlet var respirationRate: UIButton!
    
    @IBOutlet var stepsButton: UIButton!
    @IBOutlet var distanceRunningWalking: UIButton!
    
    @IBOutlet var deepSleep: UIButton!
    @IBOutlet var REMSleepButton: UIButton!
    
    @IBOutlet var lightSleepButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
    }

    
    
    
    func initialUI(){
        view.backgroundColor = UIColor(hex: "F0ECE5")
        restingHeartRateButton.tintColor = UIColor(hex: "161A30")
        heartRateVariabilityButton.tintColor = UIColor(hex: "161A30")
        respirationRate.tintColor = UIColor(hex: "161A30")
        stepsButton.tintColor = UIColor(hex: "161A30")
        distanceRunningWalking.tintColor = UIColor(hex: "161A30")
        deepSleep.tintColor = UIColor(hex: "161A30")
        REMSleepButton.tintColor = UIColor(hex: "161A30")
        lightSleepButton.tintColor = UIColor(hex: "161A30")
    }
    
    @IBAction func restingHeartRate(_ sender: Any) {
        performSegue(withIdentifier: "toIndividualMetric", sender: RestingHeartRateM.shared)
    }
    
    @IBAction func heartRateVariabilityAction(_ sender: Any) {
        performSegue(withIdentifier: "toIndividualMetric", sender: HeartRateVariability.shared)
    }
    
    @IBAction func respirationRateAction(_ sender: Any) {
        performSegue(withIdentifier: "toIndividualMetric", sender: RespiratoryRate.shared)
    }
    
    @IBAction func stepsAction(_ sender: Any) {
        performSegue(withIdentifier: "toIndividualMetric", sender: Steps.shared)
    }
    
    @IBAction func distanceWalkingRunningAction(_ sender: Any) {
        performSegue(withIdentifier: "toIndividualMetric", sender: WalkingRunningDistance.shared)
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! IndividualMetricVC
        
        destVC.modalPresentationStyle = .fullScreen
        
        if let metric = sender as? QuantityMetric {
            destVC.individualMetric = metric
        }
    }

}
