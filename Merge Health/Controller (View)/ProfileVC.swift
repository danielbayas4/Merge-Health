import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet var toPersonalDetailsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
        
        toPersonalDetailsButton.layer.borderWidth = 1
        toPersonalDetailsButton.layer.borderColor = UIColor.black.cgColor
        
        toPersonalDetailsButton.imageView?.contentMode = .center
        
        // Do any additional setup after loading the view.
    }
    
    func initialUI(){
        view.backgroundColor = UIColor(hex: "F0ECE5")
    }
    
    @IBAction func toPersonalDetailsAction(_ sender: Any) {
        performSegue(withIdentifier:"toPersonalDetails", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destVC = segue.destination as! PersonalDetailsVC
        
        //destVC.modalPresentationStyle = .fullScreen
        
    }
    
    
}
