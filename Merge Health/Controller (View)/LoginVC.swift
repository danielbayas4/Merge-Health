import UIKit
import CLTypingLabel
import FirebaseAuth

class LoginVC: UIViewController, UITextFieldDelegate {
    
    enum Segues {
        static let toMainServices = "toMainServices"
        static let toRegistration = "toRegistration"
        static let toForgotPassword = "toForgotPassword"
    }
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var appTitleLabel: CLTypingLabel!
    
    
    @IBOutlet var rememberMeSwitch: UISwitch!
    
    @IBOutlet var registerButton: UIButton!
    
    @IBOutlet var forgotPasswordButton: UIButton!
    
    @IBOutlet var loginButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialUI()
        
        appTitleLabel.text = "Merge Health!"
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        

        
        //If the user is authenticated, go directly to the tab bar controller
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(UserDefaults.standard.bool(forKey: "RememberMe"))
        
        
        if UserDefaults.standard.bool(forKey: "RememberMe") == true {
            //procede
        } 
        else {
            let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
        }
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: Segues.toMainServices, sender: self)
        }
    }
    
    
    @IBAction func rememberMeAction(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "RememberMe")
        print(sender.isOn)
    }

    

    
    
    func initialUI(){
        view.backgroundColor = UIColor(hex: "F0ECE5")
        //rememberMeSwitch.color = UIColor(hex: "161A30")
        //rememberMeSwitch.thumbTintColor = UIColor(hex: "161A30")
        
        appTitleLabel.textColor = UIColor(hex: "161A30")
        rememberMeSwitch.onTintColor = UIColor(hex: "161A30")
        
        registerButton.tintColor = UIColor(hex: "B6BBC4")
        forgotPasswordButton.tintColor = UIColor(hex: "B6BBC4")
        
        loginButton.tintColor = UIColor(hex: "161A30")
        
        
        //Create the string with the underline
        let registerButtonString = NSMutableAttributedString(string: "Register", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        
        registerButton.setAttributedTitle(registerButtonString, for: .normal)
        
        //Create the string with the underline (for forget password)
        let forgotPasswordString = NSMutableAttributedString(string: "Forgot the password?", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        
        forgotPasswordButton.setAttributedTitle(forgotPasswordString, for: .normal)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         textField.resignFirstResponder() // Dismiss the keyboard
         return true
     }
    
    @IBAction func loginAction(_ sender: Any) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                
                if let e = error {
                    print(e)
                    //FIRAuthErrors to print the errors
                } else {
                    self!.performSegue(withIdentifier: Segues.toMainServices, sender: self)
                }
                
                guard let strongSelf = self else { return }
                
            }
        }
        
        
        
        
        
        
    }
    
    
    @IBAction func registerAction(_ sender: Any) {
        performSegue(withIdentifier: Segues.toRegistration, sender: self)
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        performSegue(withIdentifier: Segues.toForgotPassword, sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segues.toMainServices {
            
            if let destTabBarController = segue.destination as? UITabBarController {
                
                destTabBarController.modalPresentationStyle = .fullScreen
            }
        }
        
        if segue.identifier == Segues.toRegistration {
            let destVC = segue.destination as! RegistrationVC
            destVC.modalPresentationStyle = .fullScreen
        }
        
        if segue.identifier == Segues.toForgotPassword {
            let destVC = segue.destination as! ForgotPasswordVC
            
            destVC.modalPresentationStyle = .fullScreen
        }
    }
}
