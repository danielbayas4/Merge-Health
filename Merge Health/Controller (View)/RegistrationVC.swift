

import UIKit

class RegistrationVC: UIViewController {
    
    
    @IBOutlet var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
    }
        
        func initialUI(){
            registerButton.tintColor = UIColor(hex: "161A30")
        }
}
