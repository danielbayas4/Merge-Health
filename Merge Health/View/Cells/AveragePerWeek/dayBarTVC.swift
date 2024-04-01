import UIKit

class dayBarTVC: UITableViewCell {
    
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var writtenValue: UILabel!
    @IBOutlet var weekDay: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressView.progress = 0.75 //This should change according to the fetches data
        progressView.progressViewStyle = .bar
        progressView.trackTintColor = .gray
        progressView.progressTintColor = UIColor(hex: "161A30")
        self.backgroundColor = UIColor(hex: "F0ECE5")
        
        progressView.transform = progressView.transform.scaledBy(x: 1, y: 16)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
