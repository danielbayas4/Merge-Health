

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegistrationVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var registerButton: UIButton!
    
    @IBOutlet var nameTextField: UITextField!
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var repeatEmailTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var repeatPasswordTextfield: UITextField!
    
    @IBOutlet var ageTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
    }
        
    func initialUI(){
        view.backgroundColor = UIColor(hex: "F0ECE5")
        
        registerButton.tintColor = UIColor(hex: "161A30")
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        
        
        repeatEmailTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextfield.delegate = self
        
        
        
    }
    
    
    /// Main functionality that connects it to Firebase
    @IBAction func registerAction(_ sender: Any) {
        
        //Optional chaining
        if let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let ageText = ageTextField.text, let intAge = Int(ageText) {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                
                //authResult is the user data
                
                let db = Firestore.firestore()
                
                if let e = error {
                    print(e.localizedDescription)

                } else {
                    
                    
                    
                    if let userID = authResult?.user.uid {
                        let appPreferences: [String: Any] = [
                                    "notificationsEnabled": true,
                                    "theme": "normal",
                                    "fontSize": 12,
                                    "PolarAPIConnection": ""
                                ]
                        
                        
                        db.collection("users").document(userID).setData([
                            "name": name,
                            "email": email,
                            "age": intAge,
                            "appPreferences": appPreferences,
                            "healthKitConnection": false,
                            "polarAPIData": [ ]
                        ]) { error in
                            
                            if let error = error {
                                print ("There was an error writing at the document: \(error)")
                            } else {
                                print ("The user name was succesfully written")
                            }
                        }

                        self.performSegue(withIdentifier: "registrationToMain" , sender: self)
                        
                    }
                   
                }
        }

        }
        
        UserDataInformation.shared.fetchUserData { success in
            if success {
                DispatchQueue.main.async {
                            //exp: Puedo hacer una modificación de mi UI
                        }
                
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UITabBarController {
            
            destination.modalPresentationStyle = .fullScreen
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            // Dismiss the keyboard
            textField.resignFirstResponder()
            return true
        }
    

    
}
