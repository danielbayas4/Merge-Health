
import UIKit

class StepsTVC: UITableViewCell {
    
    
    
    @IBOutlet var stepsUntilNow: UILabel!
    
    @IBOutlet var lastValueLabel: UILabel! //bug_possible: It might not be connected
    
    @IBOutlet var generallyUntilNowLabel: UILabel!
    
    @IBOutlet var averageLastDaysValueLabel: UILabel!
    
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Design
        self.backgroundColor = UIColor(hex: "F0ECE5")
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
        
        
        
        self.stepsUntilNow.text = Steps.shared.totalValueUntilNow
        
        self.generallyUntilNowLabel.text = Steps.shared.generallyUntilNow
        
        
        self.lastValueLabel.text = Steps.shared.latest_value
        self.averageLastDaysValueLabel.text = Steps.shared.average_last_days
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
