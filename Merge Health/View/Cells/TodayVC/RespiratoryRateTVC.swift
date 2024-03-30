//
//  WalkingHeartRateTVC.swift
//  Merge Health
//
//  Created by Daniel Bayas on 28/3/24.
//

import UIKit

class RespiratoryRateTVC: UITableViewCell {
    
    @IBOutlet var averageValue: UILabel!
    
    @IBOutlet var lastValue: UILabel!
    
    @IBOutlet var forecastedAverageToday: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(hex: "F0ECE5")
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
        
        self.averageValue.text = RespiratoryRate.shared.today_average
        self.lastValue.text = RespiratoryRate.shared.latest_value
        self.forecastedAverageToday.text = RespiratoryRate.shared.average_last_days
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
