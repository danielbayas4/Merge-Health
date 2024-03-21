

import UIKit
import FirebaseAuth

class RegistrationVC: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var registerButton: UIButton!
    
    @IBOutlet var nameTextField: UITextField!
    
    @IBOutlet var emailTextField: UITextField!
    
    @IBOutlet var repeatEmailTextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var repeatPasswordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
    }
        
    func initialUI(){
        registerButton.tintColor = UIColor(hex: "161A30")
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        repeatEmailTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextfield.delegate = self
        
    }
    
    @IBAction func registerAction(_ sender: Any) {
        
        //Optional chaining
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                
                //authResult is the user data
                
                if let e = error {
                    print(e.localizedDescription)
                    //Pop up to show the user the error
                } else {
                    //Navigation to the main program
                    self.performSegue(withIdentifier: "registrationToMain" , sender: self)
                    
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
