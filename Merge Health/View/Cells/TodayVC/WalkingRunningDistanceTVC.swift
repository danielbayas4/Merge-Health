//
//  WalkingRunningDistanceTVC.swift
//  Merge Health
//
//  Created by Daniel Bayas on 28/3/24.
//

import UIKit

class WalkingRunningDistanceTVC: UITableViewCell {

    @IBOutlet var sumUntilNow: UILabel!
    @IBOutlet var lastSession: UILabel!
    @IBOutlet var generallyUntilNow: UILabel!
    @IBOutlet var forecastedEndDay: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Design
        self.backgroundColor = UIColor(hex: "F0ECE5")
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        
        //Data fetching
        self.sumUntilNow.text = WalkingRunningDistance.shared.totalValueUntilNow
        self.lastSession.text = WalkingRunningDistance.shared.latest_value
        self.generallyUntilNow.text = WalkingRunningDistance.shared.generallyUntilNow
        self.forecastedEndDay.text = WalkingRunningDistance.shared.average_last_days
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
