import UIKit

class RegistrationVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
    }
    
    func initialUI(){
        view.backgroundColor = UIColor(hex: "F0ECE5")
        navigationController?.navigationBar.tintColor = UIColor(hex:"161A30")
        
    }

}
