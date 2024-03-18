
import UIKit

class PersonalDetailsVC: UIViewController {

    @IBOutlet var saveChanges: UIButton!
    @IBOutlet var logOutButton: UIButton!
    @IBOutlet var eliminateAccountButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
        saveChanges.tintColor = UIColor(hex: "161A30")
        logOutButton.tintColor = UIColor(hex: "161A30")
        eliminateAccountButton.tintColor = UIColor(hex: "161A30")
    }
    
    
    func initialUI(){
        view.backgroundColor = UIColor(hex: "F0ECE5")
    }
}
