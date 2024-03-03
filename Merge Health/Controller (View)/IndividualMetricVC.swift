import UIKit

class IndividualMetricVC: UIViewController {
    
    @IBOutlet var averagePerWeekButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
        
        // Do any additional setup after loading the view.
    }
    
    func initialUI(){
        view.backgroundColor = UIColor(hex: "F0ECE5")
    }
    
    @IBAction func averagePerWeekAction(_ sender: Any) {
        performSegue(withIdentifier: "toAveragePerWeek", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAveragePerWeek" {
            let destVC = segue.destination as! AveragePerWeekVC
            destVC.modalPresentationStyle = .fullScreen
        }
    }

}
