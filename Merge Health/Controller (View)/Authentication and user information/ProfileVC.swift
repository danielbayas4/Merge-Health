import UIKit
import HealthKit
import FirebaseFirestore
import FirebaseAuth

class ProfileVC: UIViewController {
    
    let healthStore = HKHealthStore()
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var toPersonalDetailsButton: UIButton!
    
    @IBOutlet var appleHealthButton: UIButton!
    @IBOutlet var polarButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
    }
    
    func initialUI(){
        view.backgroundColor = UIColor(hex: "F0ECE5")
        
        toPersonalDetailsButton.layer.borderWidth = 1
        toPersonalDetailsButton.layer.borderColor = UIColor.black.cgColor
        
        toPersonalDetailsButton.imageView?.contentMode = .center
        
        appleHealthButton.tintColor = UIColor(hex: "161A30")
        polarButton.tintColor = UIColor(hex: "161A30")
        
        if let currentUser = UserDataInformation.shared.currentUser {
            nameLabel.text = currentUser.name
        }
    }

    
    
    
    @IBAction func appleHealthAction(_ sender: Any) {
        if HKHealthStore.isHealthDataAvailable() {
                    let typesToRead: Set<HKObjectType> = [
                        HKQuantityType(.restingHeartRate),
                        HKQuantityType(.heartRate),
                        HKQuantityType(.stepCount),
                        HKCategoryType(.sleepAnalysis),
                        HKQuantityType(.activeEnergyBurned),
                        HKQuantityType(.heartRateVariabilitySDNN),
                        HKQuantityType(.respiratoryRate),
                        HKWorkoutType.workoutType(),
                        HKQuantityType(.distanceWalkingRunning)
                    ]
                    
                    healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
                        if !success {
                            DispatchQueue.main.async {
                                UserDefaults.standard.set(false, forKey: "authorization_granted")
                                print("Authorization not granted")
                                self.showHealthDataUnavailableAlert()
                            }
                        } else {
                            DispatchQueue.main.async {
                                print("Authorization granted")
                                
                                //User Defaults
                                
                                UserDefaults.standard.set(true, forKey: "authorization_granted")
                                
                                if let userID = Auth.auth().currentUser?.uid {
                                    let db = Firestore.firestore()
                                    let userDocument = db.collection("users").document(userID)
                                    userDocument.updateData(["connection_to_healthkit": true]) { error in
                                        if let error = error {
                                            print("Error updating the document")
                                        } else  {
                                            print("The update of the document was succesful")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else {
                DispatchQueue.main.async {
                    //self.showHealthDataUnavailableAlert()
                }
                }
    }
    
    
    
    
    
    
    
    @IBAction func toPersonalDetailsAction(_ sender: Any) {
        performSegue(withIdentifier:"toPersonalDetails", sender: self)
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destVC = segue.destination as! PersonalDetailsVC
        
        destVC.modalPresentationStyle = .fullScreen
        
    }
    
    func showHealthDataUnavailableAlert() {
        let alertController = UIAlertController(title: "Health Data Unavailable", message: "This device does not support HealthKit or access to health data is restricted.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            //exp: handle the user response
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    
    
}
