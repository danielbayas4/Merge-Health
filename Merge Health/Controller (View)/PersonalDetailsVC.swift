
import UIKit
import FirebaseAuth

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
    
    @IBAction func logOutAction(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            
            self.performSegue(withIdentifier: "logOutToLogIn", sender: Any?.self)
            
            
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    func initialUI(){
        view.backgroundColor = UIColor(hex: "F0ECE5")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LoginVC {
            
            destination.modalPresentationStyle = .fullScreen
            
        }
    }
}
