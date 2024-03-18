//
//  RestingHeartRate.swift
//  Merge Health
//
//  Created by Daniel Bayas on 12/3/24.
//

import UIKit

class RestingHeartRate: UITableViewCell {

    
    @IBOutlet var averageHeartRateLabel: UILabel!
    @IBOutlet var lastHeartRateLabel: UILabel!
    @IBOutlet var averageLast10: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
