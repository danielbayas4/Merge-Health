//
//  HeartRateVariabilityTVC.swift
//  Merge Health
//
//  Created by Daniel Bayas on 28/3/24.
//

import UIKit

class HeartRateVariabilityTVC: UITableViewCell {
    
    
    
    @IBOutlet var lastValueLabel: UILabel!
    
    @IBOutlet var averageValueLabel: UILabel!
    
    
    @IBOutlet var averageLastDaysLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(hex: "F0ECE5")
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
        
        
        
        self.lastValueLabel.text = HeartRateVariability.shared.latest_value
        self.averageValueLabel.text = HeartRateVariability.shared.today_average
        self.averageLastDaysLabel.text = HeartRateVariability.shared.average_last_days
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
