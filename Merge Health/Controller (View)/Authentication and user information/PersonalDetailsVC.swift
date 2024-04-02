
import UIKit
import FirebaseAuth
import FirebaseFirestore

class PersonalDetailsVC: UIViewController {
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var mailField: UITextField!
    @IBOutlet var ageField: UITextField!
    
    @IBOutlet var saveChanges: UIButton!
    @IBOutlet var logOutButton: UIButton!
    @IBOutlet var eliminateAccountButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
        saveChanges.tintColor = UIColor(hex: "161A30")
        logOutButton.tintColor = UIColor(hex: "161A30")
        eliminateAccountButton.tintColor = UIColor(hex: "161A30")
        
        if let currentUser = UserDataInformation.shared.currentUser {
            let StringAge = String(currentUser.age)
            
            nameField.text = currentUser.name
            mailField.text = currentUser.email
            ageField.text = StringAge
        }
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
    
    
    @IBAction func saveChangesAction(_ sender: Any) {
        
        guard let name = nameField.text, !name.isEmpty,
              let email = mailField.text, !email.isEmpty,
              let ageString = ageField.text, !ageString.isEmpty,
              let age = Int(ageString)
        
        else {
            print("There is a problem with name or email")
            return
        }
        
        UserDataInformation.shared.updateUserData(name: name, email: email, age: age) { success in
            
            DispatchQueue.main.async {
                if success {
                    print("User information  updated succesfully")
                } else {
                    print("Failed to update the user data")
                }
            }
        }
        
    }
    
    @IBAction func eliminateAccountAction(_ sender: Any) {
        // Check if the user is signed in
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        
        
        user.delete { error in
            if let error = error {
                
                print("Error in deleting account: \(error.localizedDescription)")
                
            } else {
                
                print("User account deleted successfully.")
                
                // Optional: Sign out the user after account deletion
                do {
                    try Auth.auth().signOut()
                    // Navigate to login or any other appropriate screen
                    self.performSegue(withIdentifier: "logOutToLogIn", sender: self)
                } catch let signOutError as NSError {
                    print("Error signing out after account deletion: %@", signOutError)
                }
            }
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
